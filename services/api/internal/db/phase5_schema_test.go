package db_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// phase5_schema_test.go proves migration 00005's constraints actually ENFORCE
// the Phase-5 security model on a freshly-migrated database — the guarantees the
// Go code assumes but never exercises (it never UPDATEs a gate_script, never
// writes an out-of-policy audit row). If any of these constraints were broken in
// the migration, the deploy would silently violate the model; these tests are
// the first-deploy gate that the schema is real.

func migratedPool(t *testing.T) (context.Context, *pgxpool.Pool) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, dbpkg.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	return ctx, pool
}

func seedToolAndScript(t *testing.T, ctx context.Context, p *pgxpool.Pool) (toolID, scriptID uuid.UUID) {
	t.Helper()
	require.NoError(t, p.QueryRow(ctx,
		`INSERT INTO tools (global_uri, name) VALUES ($1, 'send-email') RETURNING id`,
		"tendant://tools/se-"+uuid.NewString()).Scan(&toolID))
	require.NoError(t, p.QueryRow(ctx,
		`INSERT INTO gate_scripts (tool_id, version, manifest, manifest_hash, wasm, tier, attached_by_principal)
		 VALUES ($1, 1, '{}'::jsonb, 'h', '\x00'::bytea, 'byo_wasm', 'owner') RETURNING id`,
		toolID).Scan(&scriptID))
	return toolID, scriptID
}

// FR-025: gate_scripts are append-only modulo `status`.
func TestSchema_GateScriptsAppendOnlyTrigger(t *testing.T) {
	ctx, p := migratedPool(t)
	_, scriptID := seedToolAndScript(t, ctx, p)

	// status updates are the ONLY permitted mutation.
	_, err := p.Exec(ctx, `UPDATE gate_scripts SET status='disabled' WHERE id=$1`, scriptID)
	require.NoError(t, err, "status update must be allowed")

	// Every other column is immutable — the trigger must reject it.
	for _, mut := range []struct {
		name, sql string
	}{
		{"wasm", `UPDATE gate_scripts SET wasm='\x0102'::bytea WHERE id=$1`},
		{"manifest", `UPDATE gate_scripts SET manifest='{"x":1}'::jsonb WHERE id=$1`},
		{"manifest_hash", `UPDATE gate_scripts SET manifest_hash='tampered' WHERE id=$1`},
		{"version", `UPDATE gate_scripts SET version=99 WHERE id=$1`},
		{"tier", `UPDATE gate_scripts SET tier='assemblyscript_in_app' WHERE id=$1`},
		{"attached_by_principal", `UPDATE gate_scripts SET attached_by_principal='attacker' WHERE id=$1`},
	} {
		t.Run(mut.name, func(t *testing.T) {
			_, err := p.Exec(ctx, mut.sql, scriptID)
			require.Error(t, err, "mutating %s must be rejected by the append-only trigger", mut.name)
			require.Contains(t, err.Error(), "append-only")
		})
	}
}

// FR-020 / Q3: audit_messages.task_id may be NULL ONLY for the four owner-scoped
// kinds; every other kind (including the Phase-5 task-scoped ones) requires it.
func TestSchema_AuditTaskIDCheckConstraint(t *testing.T) {
	ctx, p := migratedPool(t)

	// A real task lets us test the non-null path.
	var taskID uuid.UUID
	require.NoError(t, p.QueryRow(ctx,
		`INSERT INTO tasks (global_uri, title) VALUES ($1, 't') RETURNING id`,
		"tendant://tasks/"+uuid.NewString()).Scan(&taskID))

	ins := func(taskID *uuid.UUID, kind string) error {
		_, err := p.Exec(ctx,
			`INSERT INTO audit_messages (task_id, from_principal, kind, payload) VALUES ($1, 'sys', $2, '{}'::jsonb)`,
			taskID, kind)
		return err
	}

	// task_id NULL is allowed for the four owner-scoped kinds.
	for _, k := range []string{"gate_script_rejected", "gate_script_attached", "gate_script_disabled", "owner_rule_set"} {
		require.NoError(t, ins(nil, k), "owner-scoped kind %q must allow NULL task_id", k)
	}

	// task_id NULL is REJECTED for task-scoped / pre-Phase-5 kinds.
	for _, k := range []string{"gate_script_evaluated", "gate_script_skipped", "state_transition", "overseer_evaluated"} {
		err := ins(nil, k)
		require.Error(t, err, "kind %q must reject NULL task_id", k)
		require.Contains(t, err.Error(), "audit_task_required_unless_owner_scope")
	}

	// A real task_id is accepted for a task-scoped kind.
	require.NoError(t, ins(&taskID, "gate_script_evaluated"))
}

// FR-003: the denied_by_script outcome value is usable.
func TestSchema_DeniedByScriptEnumValue(t *testing.T) {
	ctx, p := migratedPool(t)
	toolID, _ := seedToolAndScript(t, ctx, p)
	var taskID uuid.UUID
	require.NoError(t, p.QueryRow(ctx,
		`INSERT INTO tasks (global_uri, title) VALUES ($1, 't') RETURNING id`,
		"tendant://tasks/"+uuid.NewString()).Scan(&taskID))

	_, err := p.Exec(ctx,
		`INSERT INTO tool_outcomes (tool_id, task_id, outcome) VALUES ($1, $2, 'denied_by_script')`,
		toolID, taskID)
	require.NoError(t, err, "denied_by_script must be a valid tool_outcome_kind")
}

// gate_scripts (tool_id, version) is unique; owner_rules PK rejects dup keys.
func TestSchema_UniquenessConstraints(t *testing.T) {
	ctx, p := migratedPool(t)
	toolID, _ := seedToolAndScript(t, ctx, p)

	_, err := p.Exec(ctx,
		`INSERT INTO gate_scripts (tool_id, version, manifest, manifest_hash, wasm, tier, attached_by_principal)
		 VALUES ($1, 1, '{}'::jsonb, 'h', '\x00'::bytea, 'byo_wasm', 'owner')`, toolID)
	require.Error(t, err, "duplicate (tool_id, version) must be rejected")

	owner := "tendant://principals/owner"
	_, err = p.Exec(ctx, `INSERT INTO owner_rules (owner_global_uri, key, value) VALUES ($1,'k','v')`, owner)
	require.NoError(t, err)
	_, err = p.Exec(ctx, `INSERT INTO owner_rules (owner_global_uri, key, value) VALUES ($1,'k','v2')`, owner)
	require.Error(t, err, "duplicate (owner_global_uri, key) must be rejected")
}

// tools.active_script_version exists, is nullable, and accepts an int pointer.
func TestSchema_ActiveScriptVersionColumn(t *testing.T) {
	ctx, p := migratedPool(t)
	toolID, _ := seedToolAndScript(t, ctx, p)

	var v *int
	require.NoError(t, p.QueryRow(ctx,
		`SELECT active_script_version FROM tools WHERE id=$1`, toolID).Scan(&v))
	require.Nil(t, v, "active_script_version defaults to NULL")

	_, err := p.Exec(ctx, `UPDATE tools SET active_script_version=1 WHERE id=$1`, toolID)
	require.NoError(t, err)
}
