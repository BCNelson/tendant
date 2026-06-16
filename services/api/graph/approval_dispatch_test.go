package graph_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// issueOwnerBearer mints a session for the seeded owner and returns the raw
// bearer. Used by Phase 3 tests that need auth.FromContext to resolve.
func issueOwnerBearer(t *testing.T, env *chainEnv) string {
	t.Helper()
	ctx := context.Background()
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)
	_, raw, err := auth.IssueSession(ctx, env.queries, owner.ID, "phase3_test")
	require.NoError(t, err)
	return raw
}

// proposeToolCallGQL fires the proposeToolCall mutation and returns the
// resulting ApprovalRequest id. Fails the test if the gate returns an
// error.
func proposeToolCallGQL(t *testing.T, env *chainEnv, taskID uuid.UUID, toolURI string, payload map[string]any) uuid.UUID {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $u: String!, $p: JSON!) {
		   proposeToolCall(taskId: $id, toolGlobalUri: $u, payload: $p) { id }
		 }`,
		map[string]any{"id": taskID.String(), "u": toolURI, "p": payload},
	)
	var data struct {
		ProposeToolCall struct {
			ID string `json:"id"`
		} `json:"proposeToolCall"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	id, err := uuid.Parse(data.ProposeToolCall.ID)
	require.NoError(t, err)
	return id
}

// approveArtifactGQL fires the approveArtifact mutation. Returns nothing —
// the test asserts side effects on tool_outcomes etc.
func approveArtifactGQL(t *testing.T, env *chainEnv, decisionID uuid.UUID) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!) { approveArtifact(decisionId: $id) { id } }`,
		map[string]any{"id": decisionID.String()},
	)
	var data struct {
		ApproveArtifact struct {
			ID string `json:"id"`
		} `json:"approveArtifact"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Equal(t, decisionID.String(), data.ApproveArtifact.ID)
}

// rejectApprovalGQL fires the rejectApproval mutation, waking the workflow
// with a no-dispatch resolution. Returns nothing — the test asserts the
// rejection's side effects (decision_resolved audit, no outcome).
func rejectApprovalGQL(t *testing.T, env *chainEnv, decisionID uuid.UUID, reason string) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $r: String) { rejectApproval(decisionId: $id, reason: $r) { id } }`,
		map[string]any{"id": decisionID.String(), "r": reason},
	)
	var data struct {
		RejectApproval struct {
			ID string `json:"id"`
		} `json:"rejectApproval"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Equal(t, decisionID.String(), data.RejectApproval.ID)
}

// pollUntilToolOutcome blocks until a tool_outcomes row lands for taskID.
func pollUntilToolOutcome(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(10 * time.Second)
	for time.Now().Before(deadline) {
		n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
		if err == nil && n > 0 {
			return
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for tool_outcomes row for task %s", taskID)
}

// walkToExecution drives a task through TRIAGE + EXPANSION so subsequent
// proposeToolCall happens against an EXECUTION-stage task.
func walkToExecution(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
}

// TestApprovalDispatch_BenignEmail_HappyPath drives Phase 3's full loop:
// propose a send-email to the owner (a known principal — no floor trip,
// but the no-overseer-yet stub still escalates), approve the artifact,
// observe the tool dispatch + tool_outcomes row land.
//
// Covers User Story 1 acceptance scenarios 1 & 2.
func TestApprovalDispatch_BenignEmail_HappyPath(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "send self a friendly email")
	walkToExecution(t, env, taskID)

	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)

	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{
			"to":      owner.GlobalUri,
			"subject": "hello",
			"body":    "self-greeting",
		},
	)

	// Decision row should be present + open, with frozen_payload populated.
	row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.Equal(t, db.DecisionKindApprovalRequest, row.Kind)
	require.False(t, row.ResolvedAt.Valid, "decision should be open before approval")
	require.NotEmpty(t, row.FrozenPayload, "frozen_payload must be populated")
	require.True(t, row.ToolID.Valid, "tool_id must be set")
	require.NotNil(t, row.WorkflowID, "workflow_id must be set")
	require.NotNil(t, row.DecisionTopic, "decision_topic must be set")

	// Approve the artifact and wait for dispatch.
	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)

	// Decision row should now be resolved.
	resolved, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.True(t, resolved.ResolvedAt.Valid, "decision should be resolved")
	require.NotEmpty(t, resolved.Resolution)

	// Audit DAG should contain the four Phase 3 kinds.
	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)
	kinds := map[string]int{}
	for _, r := range rows {
		kinds[r.Kind]++
	}
	require.Equal(t, 1, kinds[lifecycle.KindToolCallComposed], "exactly one tool_call_composed")
	require.Equal(t, 1, kinds[lifecycle.KindGateVerdict], "exactly one gate_verdict")
	require.Equal(t, 1, kinds[lifecycle.KindDecisionResolved], "exactly one decision_resolved")
	require.Equal(t, 1, kinds[lifecycle.KindToolDispatched], "exactly one tool_dispatched")
	require.Equal(t, 1, kinds[lifecycle.KindToolOutcomeRecorded], "exactly one tool_outcome_recorded")

	// Exactly one tool_outcomes row, outcome=clean.
	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, n, "exactly one tool_outcomes row")
}

// TestApprovalDispatch_FloorTrips_StrangerRecipient confirms the
// categorical floor: a stranger recipient always produces an
// ApprovalRequest, regardless of any downstream stub.
//
// Covers User Story 2 acceptance scenario 1.
func TestApprovalDispatch_FloorTrips_StrangerRecipient(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "email a stranger")
	walkToExecution(t, env, taskID)

	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{
			"to":      "stranger@example.com", // NOT in principals.global_uri
			"subject": "hello",
			"body":    "from tendant",
		},
	)

	row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.Equal(t, db.DecisionKindApprovalRequest, row.Kind)
	require.False(t, row.ResolvedAt.Valid)

	// Gate verdict audit row should record clause=irreversible_third_party.
	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)
	var verdictRow *db.AuditMessage
	for i := range rows {
		if rows[i].Kind == lifecycle.KindGateVerdict {
			verdictRow = &rows[i]
			break
		}
	}
	require.NotNil(t, verdictRow, "gate_verdict audit row must be present")
	var v lifecycle.GateVerdictPayload
	require.NoError(t, json.Unmarshal(verdictRow.Payload, &v))
	require.Equal(t, "request_decision", v.Decision, "stranger recipient must trip floor → RequestDecision")

	var ctxMap map[string]any
	require.NoError(t, json.Unmarshal(v.Context, &ctxMap))
	// The floor context is wrapped in the gate-layer envelope.
	require.Equal(t, "floor", ctxMap["layer"])
	require.Equal(t, "irreversible_third_party", ctxMap["clause"])
}

// TestApprovalDispatch_CancelAfterDispatch confirms cancel-only is fully
// safe with Phase 3 in place: a dispatched + completed tool call's
// outcome row persists across cancelTask, and the task transitions to
// HALTED without rolling back the outcome.
//
// Covers User Story 4 acceptance scenario 1.
func TestApprovalDispatch_CancelAfterDispatch(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "fire-and-cancel")
	walkToExecution(t, env, taskID)
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)

	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": owner.GlobalUri, "subject": "x", "body": "y"},
	)
	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)

	// Confirm exactly one tool_outcomes row exists pre-cancel.
	nBefore, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, nBefore)

	// Cancel.
	cancelTaskGQL(t, env, taskID)
	pollUntilTaskState(t, env, taskID, db.TaskStateHalted)

	// tool_outcomes row should still be present (append-only, no rollback).
	nAfter, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, nAfter, "tool_outcomes row must survive cancel")

	// No new pending_decisions opened by the cancel.
	all, err := env.queries.ListOpenPendingDecisions(ctx)
	require.NoError(t, err)
	for _, d := range all {
		require.NotEqual(t, taskID, d.TaskID, "no open pending_decisions for the cancelled task")
	}
}

// TestApprovalDispatch_RejectsUnknownTool confirms the resolver surfaces
// TOOL_UNKNOWN when the global URI isn't registered. No row is written,
// no workflow is started.
func TestApprovalDispatch_RejectsUnknownTool(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "unknown tool path")
	walkToExecution(t, env, taskID)

	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($id: ID!, $u: String!, $p: JSON!) {
		   proposeToolCall(taskId: $id, toolGlobalUri: $u, payload: $p) { id }
		 }`,
		map[string]any{"id": taskID.String(), "u": "tendant://tools/does-not-exist", "p": map[string]any{}},
	)
	require.Len(t, errs, 1)
	var raw map[string]any
	require.NoError(t, json.Unmarshal(errs[0], &raw))
	ext, _ := raw["extensions"].(map[string]any)
	require.Equal(t, "TOOL_UNKNOWN", ext["code"])

	// No ApprovalRequest written for this task.
	open, err := env.queries.ListOpenPendingDecisions(ctx)
	require.NoError(t, err)
	for _, d := range open {
		require.NotEqual(t, taskID, d.TaskID, "no decision should have been written for the unknown-tool task")
	}
}
