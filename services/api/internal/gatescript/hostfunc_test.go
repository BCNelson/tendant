package gatescript

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/ownerrule"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// hostfunc_test.go asserts the no-leakage invariant of the host-function
// projection (the one place "the owner's data" is exposed to a script): a
// script bound to task A cannot see task B's context, and the host functions are
// scoped to the in-flight owner. Built via raw SQL to avoid an import cycle
// (internal/core imports gate → gatescript).

const ownerURI = "tendant://principals/owner"

func seedHostEnv(t *testing.T) (*pgxpool.Pool, *db.Queries, *Service) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))

	// Owner principal (kind=user) so contacts.isKnown(owner) is true.
	_, err := pool.Exec(ctx, `INSERT INTO principals (id, global_uri, kind, display_name)
		VALUES (gen_random_uuid(), $1, 'user', 'owner')`, ownerURI)
	require.NoError(t, err)

	q := db.New(pool)
	svc := NewService(NewLogRunner(), q, DefaultCeilings(), ownerURI)
	return pool, q, svc
}

func insertTask(t *testing.T, pool *pgxpool.Pool, contextRefs string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	if contextRefs == "" {
		contextRefs = "{}"
	}
	_, err := pool.Exec(context.Background(), `INSERT INTO tasks (id, global_uri, title, state, current_stage, context_refs)
		VALUES ($1, $2, 't', 'accepted', 'creation', $3)`, id, "local://task/"+id.String(), contextRefs)
	require.NoError(t, err)
	return id
}

func TestHostCallbacks_TaskContextScopedToInFlightTask(t *testing.T) {
	pool, _, svc := seedHostEnv(t)
	ctx := context.Background()

	taskA := insertTask(t, pool, `{"k":"A-secret"}`)
	taskB := insertTask(t, pool, `{"k":"B-secret"}`)

	manifest := Manifest{Reads: []string{"task.context", "contacts", "owner.rule"}}

	hcA := svc.buildHostCallbacks(EvalContext{TaskID: taskA}, manifest)
	got, ok, err := hcA.TaskContext(ctx, "k")
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, "A-secret", string(got), "task A must see only its own context")

	hcB := svc.buildHostCallbacks(EvalContext{TaskID: taskB}, manifest)
	got, ok, err = hcB.TaskContext(ctx, "k")
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, "B-secret", string(got), "task B must see only its own context")

	// Unknown key → not found (FR-017).
	_, ok, err = hcA.TaskContext(ctx, "missing")
	require.NoError(t, err)
	require.False(t, ok)
}

func TestHostCallbacks_ContactsAndOwnerRuleScoping(t *testing.T) {
	pool, q, svc := seedHostEnv(t)
	ctx := context.Background()
	task := insertTask(t, pool, "")

	_, err := ownerrule.New(q).Set(ctx, ownerURI, "rkey", "rval")
	require.NoError(t, err)
	// A rule owned by a DIFFERENT principal must not be visible.
	_, err = ownerrule.New(q).Set(ctx, "tendant://principals/other", "rkey", "other-val")
	require.NoError(t, err)

	hc := svc.buildHostCallbacks(EvalContext{TaskID: task}, Manifest{Reads: []string{"contacts", "owner.rule"}})

	// contacts.isKnown: owner principal known; a stranger is not.
	known, err := hc.ContactKnown(ctx, ownerURI)
	require.NoError(t, err)
	require.True(t, known)
	known, err = hc.ContactKnown(ctx, "stranger@external.example")
	require.NoError(t, err)
	require.False(t, known)
	// Empty address is the safe-default false (FR-015).
	known, err = hc.ContactKnown(ctx, "")
	require.NoError(t, err)
	require.False(t, known)

	// owner.rule scoped to the in-flight owner — sees "rval", never "other-val".
	val, ok, err := hc.OwnerRule(ctx, "rkey")
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, "rval", string(val))
	_, ok, err = hc.OwnerRule(ctx, "missing")
	require.NoError(t, err)
	require.False(t, ok)
}
