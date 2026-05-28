package db_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// Full Appendix A schema landed in the first migration.
var (
	expectedEnums = []string{
		"task_state", "chain_stage", "device_platform", "decision_kind",
		"tool_outcome_kind", "signal_disposition", "agent_stage", "config_origin",
	}
	expectedTables = []string{
		"principals", "connector_configs", "source_credentials", "intake_signals",
		"agent_configs", "tasks", "chain_workflows", "tools", "gate_scripts",
		"pending_decisions", "agent_assignments", "audit_messages",
		"tool_outcomes", "device_tokens",
	}
)

func TestMigrate_LandsFullSchemaAndIsIdempotent(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, dbpkg.Migrate(ctx, dsn), "first migrate should succeed")

	// 8 enums present.
	for _, e := range expectedEnums {
		var n int
		err := pool.QueryRow(ctx,
			`SELECT count(*) FROM pg_type WHERE typname = $1 AND typtype = 'e'`,
			e).Scan(&n)
		require.NoError(t, err, "enum %q lookup", e)
		require.Equal(t, 1, n, "enum %q should exist exactly once", e)
	}

	// 14 tables present in the public schema.
	for _, table := range expectedTables {
		var n int
		err := pool.QueryRow(ctx,
			`SELECT count(*) FROM pg_tables WHERE schemaname = 'public' AND tablename = $1`,
			table).Scan(&n)
		require.NoError(t, err, "table %q lookup", table)
		require.Equal(t, 1, n, "table %q should exist", table)
	}

	// notify_event function present.
	var hasNotifyEvent bool
	err := pool.QueryRow(ctx,
		`SELECT EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON n.oid = p.pronamespace
            WHERE n.nspname = 'public' AND p.proname = 'notify_event'
        )`).Scan(&hasNotifyEvent)
	require.NoError(t, err)
	require.True(t, hasNotifyEvent, "notify_event function should exist")

	// Restart no-op / idempotency: running Migrate again must not error.
	require.NoError(t, dbpkg.Migrate(ctx, dsn), "second migrate should be a no-op")
}
