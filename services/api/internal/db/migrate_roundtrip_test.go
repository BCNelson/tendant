package db_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestMigrate_RoundTrip proves goose Up → Down → Up succeeds end-to-end —
// the guard against a broken `-- +goose Down` slipping through (SC-005 / US5).
func TestMigrate_RoundTrip(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, dbpkg.Migrate(ctx, dsn), "first up")

	// Confirm at least one app table landed.
	var ok bool
	require.NoError(t, pool.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='tasks')`).Scan(&ok))
	require.True(t, ok, "tasks should exist after first up")

	require.NoError(t, dbpkg.MigrateDown(ctx, dsn), "down to 0")

	// All app tables should be gone.
	require.NoError(t, pool.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='tasks')`).Scan(&ok))
	require.False(t, ok, "tasks should be dropped after down")

	require.NoError(t, dbpkg.Migrate(ctx, dsn), "second up")
	require.NoError(t, pool.QueryRow(ctx,
		`SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='tasks')`).Scan(&ok))
	require.True(t, ok, "tasks should reappear after second up")
}
