package graph_test

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

func TestInboxQueryReturnsBothKinds(t *testing.T) {
	t.Parallel()
	h, q := setupGQL(t)
	ctx := context.Background()
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	// Pair a device for the bearer.
	pairBody := `{"query":"mutation { pairDevice(password:\"dev-setup-secret\", displayName:\"D\") { token } }"}`
	pair := postGQL(t, h, pairBody, "")
	require.Empty(t, pair.Errors)
	var pd struct {
		PairDevice struct {
			Token string `json:"token"`
		} `json:"pairDevice"`
	}
	require.NoError(t, json.Unmarshal(pair.Data, &pd))
	bearer := pd.PairDevice.Token

	// Insert one pending_decision + one assignment routed to owner.
	taskID := mustCreateTask(t, q)
	_, err = q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  taskID,
		Kind:    db.DecisionKindApprovalRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)

	taskID2 := mustCreateTask(t, q)
	asn, err := q.InsertAgentAssignment(ctx, db.InsertAgentAssignmentParams{
		TaskID:          taskID2,
		Stage:           db.ChainStageTriage,
		Ask:             "first",
		GatheredContext: json.RawMessage("{}"),
	})
	require.NoError(t, err)
	_, err = q.SetAssignmentRecipient(ctx, db.SetAssignmentRecipientParams{ID: asn.ID, ToPrincipal: &owner.GlobalUri})
	require.NoError(t, err)

	body := `{"query":"{ inbox(first: 25) { __typename ... on AgentAssignment { id ask } ... on ApprovalRequest { id } } }"}`
	resp := postGQL(t, h, body, bearer)
	require.Empty(t, resp.Errors, "expected no errors; got %+v", resp.Errors)

	// Should contain both typenames.
	s := string(resp.Data)
	require.True(t, strings.Contains(s, "ApprovalRequest"))
	require.True(t, strings.Contains(s, "AgentAssignment"))
}

func TestInboxFeedRanksProposedTask(t *testing.T) {
	t.Parallel()
	h, q := setupGQL(t)
	ctx := context.Background()

	pairBody := `{"query":"mutation { pairDevice(password:\"dev-setup-secret\", displayName:\"D\") { token } }"}`
	pair := postGQL(t, h, pairBody, "")
	require.Empty(t, pair.Errors)
	var pd struct {
		PairDevice struct {
			Token string `json:"token"`
		} `json:"pairDevice"`
	}
	require.NoError(t, json.Unmarshal(pair.Data, &pd))
	bearer := pd.PairDevice.Token

	// A low-priority accepted task surfaced via a decision...
	lowTask := mustCreateTask(t, q)
	_, err := q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  lowTask,
		Kind:    db.DecisionKindApprovalRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)

	// ...and an URGENT PROPOSED task, which should join the feed as an
	// ActionableTask AND outrank the decision.
	proposedID := uuid.New()
	_, err = q.CreateTask(ctx, db.CreateTaskParams{
		ID:           proposedID,
		GlobalUri:    "local://task/" + proposedID.String(),
		Title:        "decide me",
		State:        db.TaskStateProposed,
		CurrentStage: db.ChainStageCreation,
		Priority:     db.TaskPriorityUrgent,
	})
	require.NoError(t, err)

	body := `{"query":"{ inboxFeed(first: 25) { nextCursor entries { kind urgency item { __typename ... on ActionableTask { id task { id state priority } } ... on ApprovalRequest { id } } } } }"}`
	resp := postGQL(t, h, body, bearer)
	require.Empty(t, resp.Errors, "expected no errors; got %+v", resp.Errors)

	var data struct {
		InboxFeed struct {
			Entries []struct {
				Kind    string  `json:"kind"`
				Urgency float64 `json:"urgency"`
				Item    struct {
					Typename string `json:"__typename"`
					ID       string `json:"id"`
				} `json:"item"`
			} `json:"entries"`
		} `json:"inboxFeed"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Len(t, data.InboxFeed.Entries, 2)

	// Urgent proposed task ranks first, as a ranked ActionableTask envelope.
	head := data.InboxFeed.Entries[0]
	require.Equal(t, "task", head.Kind)
	require.Equal(t, "ActionableTask", head.Item.Typename)
	require.Equal(t, proposedID.String(), head.Item.ID)
	require.Greater(t, head.Urgency, data.InboxFeed.Entries[1].Urgency)
}

func mustCreateTask(t *testing.T, q *db.Queries) uuid.UUID {
	t.Helper()
	id := uuid.New()
	created, err := q.CreateTask(context.Background(), db.CreateTaskParams{
		ID:           id,
		GlobalUri:    "local://task/" + id.String(),
		Title:        "t",
		State:        db.TaskStateAccepted,
		CurrentStage: db.ChainStageCreation,
		Priority:     db.TaskPriorityNormal,
	})
	require.NoError(t, err)
	return created.ID
}
