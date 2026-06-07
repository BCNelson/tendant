package intake_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/jackc/pgx/v5/pgxpool"
)

// testEnv boots a migrated, owner-seeded Postgres for an intake test.
func testEnv(t *testing.T) (*pgxpool.Pool, *db.Queries) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	return pool, q
}

// seedConnector inserts a connector_configs row (intake_signals FK requires it)
// and returns its id.
func seedConnector(t *testing.T, q *db.Queries, connectorType string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	_, err := q.UpsertConnectorConfig(context.Background(), db.UpsertConnectorConfigParams{
		ID:               id,
		ConnectorType:    connectorType,
		Filter:           json.RawMessage(`{}`),
		DispositionRules: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
	return id
}

// ingestSignal persists one synthetic signal and returns the stored row.
func ingestSignal(t *testing.T, pool *pgxpool.Pool, connectorType string, connectorID uuid.UUID, sig intake.PotentialTaskSignal) db.IntakeSignal {
	t.Helper()
	res, err := intake.Ingest(context.Background(), pool, sig, connectorType, connectorID)
	require.NoError(t, err)
	require.False(t, res.Deduped)
	return res.Signal
}

// floatPtr is a test helper for the optional rich_event axes.
func floatPtr(f float64) *float64 { return &f }
