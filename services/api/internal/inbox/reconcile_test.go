package inbox_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/inbox"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestReconcile_RepairsTriggerBypassedDrift proves the reconcile sweep is real
// defense-in-depth: with the projection trigger disabled, an inserted decision
// gets NO inbox row (drift), and Reconcile both detects (returns a non-zero
// count) and repairs it (the message then surfaces in the feed).
func TestReconcile_RepairsTriggerBypassedDrift(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	taskID := createTask(t, q) // ACCEPTED

	// Simulate a write that bypasses the trigger (e.g. bulk COPY / disabled trigger).
	_, err = pool.Exec(ctx, "ALTER TABLE pending_decisions DISABLE TRIGGER decisions_inbox_project")
	require.NoError(t, err)
	decID, err := q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  taskID,
		Kind:    db.DecisionKindApprovalRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
	_, err = pool.Exec(ctx, "ALTER TABLE pending_decisions ENABLE TRIGGER decisions_inbox_project")
	require.NoError(t, err)

	now := time.Now().UTC()

	// Drift: the decision is absent from the first-class feed (reads inbox_messages).
	items, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Empty(t, items, "the trigger-bypassed decision should be missing pre-reconcile")

	// Reconcile detects + repairs exactly one projection.
	repaired, err := inbox.Reconcile(ctx, q)
	require.NoError(t, err)
	require.Equal(t, int64(1), repaired)

	// The decision now surfaces.
	items, _, err = inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Len(t, items, 1)
	require.Equal(t, decID, items[0].ID)

	// Idempotent: a second pass repairs nothing.
	repaired, err = inbox.Reconcile(ctx, q)
	require.NoError(t, err)
	require.Equal(t, int64(0), repaired)
}
