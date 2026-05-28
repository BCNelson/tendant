package inbox_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/inbox"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupInboxDB(t *testing.T) (*db.Queries, db.Principal) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	return q, owner
}

func createTask(t *testing.T, q *db.Queries) uuid.UUID {
	t.Helper()
	id := uuid.New()
	gURI := "local://task/" + id.String()
	_, err := q.CreateTask(context.Background(), db.CreateTaskParams{
		ID:           id,
		GlobalUri:    gURI,
		Title:        "t",
		State:        db.TaskStateAccepted,
		CurrentStage: db.ChainStageCreation,
	})
	require.NoError(t, err)
	return id
}

func TestListAndAssemble_MixedKinds(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	t1 := createTask(t, q)
	t2 := createTask(t, q)
	t3 := createTask(t, q)
	t4 := createTask(t, q)

	// Two pending_decisions.
	_, err := q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  t1,
		Kind:    db.DecisionKindApprovalRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
	_, err = q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  t2,
		Kind:    db.DecisionKindAgentQuestion,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)

	// Two assignments routed to the owner.
	asn1, err := q.InsertAgentAssignment(ctx, db.InsertAgentAssignmentParams{
		TaskID:          t3,
		Stage:           db.ChainStageTriage,
		Ask:             "a3",
		GatheredContext: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
	_, err = q.SetAssignmentRecipient(ctx, db.SetAssignmentRecipientParams{ID: asn1.ID, ToPrincipal: &owner.GlobalUri})
	require.NoError(t, err)

	asn2, err := q.InsertAgentAssignment(ctx, db.InsertAgentAssignmentParams{
		TaskID:          t4,
		Stage:           db.ChainStageExpansion,
		Ask:             "a4",
		GatheredContext: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
	_, err = q.SetAssignmentRecipient(ctx, db.SetAssignmentRecipientParams{ID: asn2.ID, ToPrincipal: &owner.GlobalUri})
	require.NoError(t, err)

	items, next, err := inbox.List(ctx, q, owner.GlobalUri, "", 50)
	require.NoError(t, err)
	require.Len(t, items, 4)
	// Ordering: created_at DESC; the most recent row is at the head.
	for i := 1; i < len(items); i++ {
		require.True(t, !items[i].CreatedAt.After(items[i-1].CreatedAt), "items must be ordered by created_at DESC")
	}
	require.Equal(t, "", next, "last page should not return a next cursor")

	assembled, err := inbox.Assemble(ctx, q, items)
	require.NoError(t, err)
	require.Len(t, assembled, 4)
	// At least one of each kind landed.
	var hasDecision, hasAssignment bool
	for _, a := range assembled {
		switch a.Kind {
		case "pending_decision":
			hasDecision = true
			require.NotNil(t, a.PendingDecision)
		case "agent_assignment":
			hasAssignment = true
			require.NotNil(t, a.AgentAssignment)
		}
	}
	require.True(t, hasDecision)
	require.True(t, hasAssignment)
}

func TestListKeysetPagination(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	for i := 0; i < 4; i++ {
		taskID := createTask(t, q)
		asn, err := q.InsertAgentAssignment(ctx, db.InsertAgentAssignmentParams{
			TaskID:          taskID,
			Stage:           db.ChainStageTriage,
			Ask:             "test",
			GatheredContext: json.RawMessage("{}"),
		})
		require.NoError(t, err)
		_, err = q.SetAssignmentRecipient(ctx, db.SetAssignmentRecipientParams{ID: asn.ID, ToPrincipal: &owner.GlobalUri})
		require.NoError(t, err)
		// Stagger creation timestamps so ordering is deterministic.
		time.Sleep(5 * time.Millisecond)
	}

	page1, next, err := inbox.List(ctx, q, owner.GlobalUri, "", 2)
	require.NoError(t, err)
	require.Len(t, page1, 2)
	require.NotEmpty(t, next)

	page2, next2, err := inbox.List(ctx, q, owner.GlobalUri, next, 2)
	require.NoError(t, err)
	require.Len(t, page2, 2)
	// Final page: returned exactly limit items, but no more rows exist so
	// the *next* call would be empty. The cursor field is still set after
	// a full page; that's acceptable — the caller learns "empty" on the
	// next List.
	page3, _, err := inbox.List(ctx, q, owner.GlobalUri, next2, 2)
	require.NoError(t, err)
	require.Empty(t, page3)

	// Page contents must not overlap.
	for _, a := range page1 {
		for _, b := range page2 {
			require.NotEqual(t, a.ID, b.ID, "page1 and page2 should not overlap")
		}
	}
}

func TestCursorEncodeDecodeRoundTrip(t *testing.T) {
	t.Parallel()
	now := time.Now().UTC().Truncate(time.Microsecond)
	id := uuid.New()
	cur := inbox.EncodeCursor(now, id)
	ts, gotID, err := inbox.DecodeCursor(cur)
	require.NoError(t, err)
	require.Equal(t, now, ts.UTC())
	require.Equal(t, id, gotID)
}
