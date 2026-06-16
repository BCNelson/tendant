package inbox_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/inbox"
)

// TestInboxMessages_TypeAndPerMessageState exercises the first-class
// inbox_messages spine added in migration 00018: the projection trigger stamps
// a fine-grained message_type, MarkInboxRead records read state without removing
// the item, and DismissInboxMessage soft-removes it from the feed while leaving
// the underlying decision untouched.
func TestInboxMessages_TypeAndPerMessageState(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)
	now := time.Now().UTC()

	taskID := createTaskWith(t, q, db.TaskStateAccepted, db.TaskPriorityNormal, nil)
	insertDecision(t, q, taskID) // approval_request

	// 1. Projected with the fine-grained message_type, initially unread.
	items, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Len(t, items, 1)
	msgID := items[0].ID
	require.Equal(t, "pending_decision", items[0].Kind, "legacy kind preserved")
	require.Equal(t, "approval_request", items[0].MessageType, "fine-grained type from inbox_messages")
	require.Nil(t, items[0].ReadAt, "starts unread")

	// 2. Mark read — the item stays in the feed but now carries read_at.
	readRow, err := q.MarkInboxRead(ctx, db.MarkInboxReadParams{ID: msgID, Viewer: owner.GlobalUri})
	require.NoError(t, err)
	require.True(t, readRow.ReadAt.Valid, "read_at stamped")

	items, _, err = inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Len(t, items, 1, "reading does not remove the item")
	require.NotNil(t, items[0].ReadAt, "read state surfaces in the feed")

	// 3. Dismiss — drops from the active feed, leaving the decision unresolved.
	_, err = q.DismissInboxMessage(ctx, db.DismissInboxMessageParams{ID: msgID, Viewer: owner.GlobalUri})
	require.NoError(t, err)

	items, _, err = inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Empty(t, items, "dismissed message leaves the active feed")

	pd, err := q.GetPendingDecisionByID(ctx, msgID)
	require.NoError(t, err)
	require.False(t, pd.ResolvedAt.Valid, "dismiss must not resolve the underlying decision")
}
