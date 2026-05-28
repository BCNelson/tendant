package db_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	dbpkg "github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestPgNotify_IDsOnlyOnInboxInserts verifies that AFTER INSERT triggers on
// pending_decisions and agent_assignments fire exactly one IDs-only
// pg_notify on `tendant_events` (8KB cap → no row content).
func TestPgNotify_IDsOnlyOnInboxInserts(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, dbpkg.Migrate(ctx, dsn))
	q := dbpkg.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))

	created, err := core.CreateTask(ctx, q, "notify-test", "")
	require.NoError(t, err)

	// Dedicated listener conn — the shared pool can rotate connections, and
	// LISTEN is per-connection state.
	listener, err := pgx.Connect(ctx, dsn)
	require.NoError(t, err)
	defer func() { _ = listener.Close(ctx) }()
	_, err = listener.Exec(ctx, "LISTEN tendant_events")
	require.NoError(t, err)

	// 1. pending_decisions → topic="decision"
	_, err = pool.Exec(ctx,
		`INSERT INTO pending_decisions (task_id, kind, payload) VALUES ($1, $2, $3)`,
		created.ID, "approval_request", "{}")
	require.NoError(t, err)

	waitCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	n, err := listener.WaitForNotification(waitCtx)
	require.NoError(t, err, "expected pg_notify within 5s")
	require.Equal(t, "tendant_events", n.Channel)
	assertIDsOnlyPayload(t, n.Payload, "decision")

	// 2. agent_assignments → topic="assignment"
	_, err = pool.Exec(ctx,
		`INSERT INTO agent_assignments (task_id, stage, ask) VALUES ($1, $2, $3)`,
		created.ID, "execution", "do x")
	require.NoError(t, err)

	waitCtx2, cancel2 := context.WithTimeout(ctx, 5*time.Second)
	defer cancel2()
	n2, err := listener.WaitForNotification(waitCtx2)
	require.NoError(t, err, "expected pg_notify within 5s")
	require.Equal(t, "tendant_events", n2.Channel)
	assertIDsOnlyPayload(t, n2.Payload, "assignment")
}

func assertIDsOnlyPayload(t *testing.T, raw, expectedTopic string) {
	t.Helper()
	// Parse top-level: must contain exactly {topic, data}.
	var payload map[string]json.RawMessage
	require.NoError(t, json.Unmarshal([]byte(raw), &payload), "payload JSON: %s", raw)
	require.Len(t, payload, 2, "payload must have only {topic, data}; got %s", raw)
	require.Contains(t, payload, "topic")
	require.Contains(t, payload, "data")

	var topic string
	require.NoError(t, json.Unmarshal(payload["topic"], &topic))
	require.Equal(t, expectedTopic, topic)

	// data must be exactly {id: <uuid>}.
	var data map[string]json.RawMessage
	require.NoError(t, json.Unmarshal(payload["data"], &data), "data JSON: %s", payload["data"])
	require.Len(t, data, 1, "data must contain only id; got %s", payload["data"])
	require.Contains(t, data, "id")

	var idStr string
	require.NoError(t, json.Unmarshal(data["id"], &idStr))
	require.NotEmpty(t, idStr)
}
