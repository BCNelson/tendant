package db_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestMigratePhase2_SessionsAndAssignmentRecipient verifies migration 00003:
// the sessions table lands with the partial index; agent_assignments gains
// to_principal + its partial index; the pair survives a down → up cycle.
func TestMigratePhase2_SessionsAndAssignmentRecipient(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, dbpkg.Migrate(ctx, dsn), "initial up should land 00001+00002+00003")

	assertPhase2State := func() {
		t.Helper()

		// sessions table exists with the expected columns.
		var sessionsExists bool
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM information_schema.tables
				WHERE table_schema = 'public' AND table_name = 'sessions'
			)`).Scan(&sessionsExists))
		require.True(t, sessionsExists, "sessions table must exist")

		expectedCols := map[string]bool{
			"id": false, "principal_id": false, "token_hash": false,
			"display_name": false, "created_at": false, "last_seen_at": false,
			"revoked_at": false,
		}
		rows, err := pool.Query(ctx, `
			SELECT column_name FROM information_schema.columns
			WHERE table_schema = 'public' AND table_name = 'sessions'`)
		require.NoError(t, err)
		for rows.Next() {
			var c string
			require.NoError(t, rows.Scan(&c))
			if _, ok := expectedCols[c]; ok {
				expectedCols[c] = true
			}
		}
		rows.Close()
		for c, seen := range expectedCols {
			require.True(t, seen, "sessions column missing: %s", c)
		}

		// Partial index on (principal_id) WHERE revoked_at IS NULL.
		var sessionsIdx bool
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM pg_indexes
				WHERE schemaname='public' AND tablename='sessions'
				  AND indexname='idx_sessions_principal'
			)`).Scan(&sessionsIdx))
		require.True(t, sessionsIdx, "idx_sessions_principal must exist")

		// agent_assignments.to_principal column.
		var toPrincipalExists bool
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM information_schema.columns
				WHERE table_schema = 'public'
				  AND table_name = 'agent_assignments'
				  AND column_name = 'to_principal'
			)`).Scan(&toPrincipalExists))
		require.True(t, toPrincipalExists, "agent_assignments.to_principal column must exist")

		// Partial index on (to_principal) WHERE resolved_at IS NULL.
		var assignIdx bool
		require.NoError(t, pool.QueryRow(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM pg_indexes
				WHERE schemaname='public' AND tablename='agent_assignments'
				  AND indexname='idx_assign_to_principal'
			)`).Scan(&assignIdx))
		require.True(t, assignIdx, "idx_assign_to_principal must exist")
	}

	assertPhase2State()

	// Idempotency: second up should be a no-op.
	require.NoError(t, dbpkg.Migrate(ctx, dsn), "second up should be a no-op")
	assertPhase2State()

	// Round-trip: down to 0 then up restores the same state.
	require.NoError(t, dbpkg.MigrateDown(ctx, dsn), "down to 0")
	require.NoError(t, dbpkg.Migrate(ctx, dsn), "up after down")
	assertPhase2State()
}
