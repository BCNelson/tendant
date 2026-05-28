package db_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestMigratePhase1_StateRenameAndDefault verifies migration 00002:
// task_state.eligible → waiting; tasks.state default → 'accepted'; the pair
// survives a down → up cycle (SC-001 idempotency).
func TestMigratePhase1_StateRenameAndDefault(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, dbpkg.Migrate(ctx, dsn), "initial up should land both migrations")

	assertPhase1State := func() {
		t.Helper()

		// pg_enum should list `waiting`, not `eligible`.
		var hasWaiting, hasEligible bool
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM pg_enum e
				JOIN pg_type t ON t.oid = e.enumtypid
				WHERE t.typname = 'task_state' AND e.enumlabel = 'waiting'
			)`).Scan(&hasWaiting))
		require.True(t, hasWaiting, "task_state should include 'waiting'")
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM pg_enum e
				JOIN pg_type t ON t.oid = e.enumtypid
				WHERE t.typname = 'task_state' AND e.enumlabel = 'eligible'
			)`).Scan(&hasEligible))
		require.False(t, hasEligible, "task_state should no longer include 'eligible'")

		// tasks.state column default should be 'accepted'::task_state.
		var def *string
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT pg_get_expr(d.adbin, d.adrelid)
			FROM pg_attribute a
			JOIN pg_class c ON c.oid = a.attrelid
			LEFT JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = a.attnum
			WHERE c.relname = 'tasks' AND a.attname = 'state'`).Scan(&def))
		require.NotNil(t, def, "tasks.state should carry a default")
		require.Equal(t, "'accepted'::task_state", *def)
	}

	assertPhase1State()

	// Idempotency: a second up should be a no-op.
	require.NoError(t, dbpkg.Migrate(ctx, dsn), "second up should be a no-op")
	assertPhase1State()

	// Round-trip: down → up restores the same end state.
	require.NoError(t, dbpkg.MigrateDown(ctx, dsn), "down to 0")
	require.NoError(t, dbpkg.Migrate(ctx, dsn), "up after down")
	assertPhase1State()
}
