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

func mustCreateTask(t *testing.T, q *db.Queries) uuid.UUID {
	t.Helper()
	id := uuid.New()
	created, err := q.CreateTask(context.Background(), db.CreateTaskParams{
		ID:           id,
		GlobalUri:    "local://task/" + id.String(),
		Title:        "t",
		State:        db.TaskStateAccepted,
		CurrentStage: db.ChainStageCreation,
	})
	require.NoError(t, err)
	return created.ID
}
