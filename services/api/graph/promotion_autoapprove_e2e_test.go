package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// latestGateVerdict reads the most recent gate_verdict decision for a task
// (written synchronously by the resolver before it returns).
func latestGateVerdict(t *testing.T, env *chainEnv, taskID uuid.UUID) string {
	t.Helper()
	var decision string
	err := env.pool.QueryRow(context.Background(),
		`SELECT payload->>'decision' FROM audit_messages
		 WHERE task_id = $1 AND kind = 'gate_verdict'
		 ORDER BY at DESC LIMIT 1`, taskID).Scan(&decision)
	require.NoError(t, err)
	return decision
}

// promoteSendEmail sets the send-email tool to EXECUTE_AUTO and grants the given
// routine fingerprint — simulating an owner-accepted promotion.
func promoteSendEmail(t *testing.T, env *chainEnv, toolID uuid.UUID, fp string) {
	t.Helper()
	ctx := context.Background()
	_, err := env.queries.SetTrustScore(ctx, db.SetTrustScoreParams{
		ID: toolID, TrustScore: calibration.AutoThreshold, Rung: "execute_auto",
	})
	require.NoError(t, err)
	_, err = env.queries.InsertRoutineGrant(ctx, db.InsertRoutineGrantParams{
		ToolID: toolID, RoutineFingerprint: fp, Evidence: []byte(`{}`), GrantedBy: "owner",
	})
	require.NoError(t, err)
}

// TestAutonomy_PromotedRoutineAutoApproves_FloorStillGates is the US1+US4 e2e:
// a promoted routine's floor-clearing call auto-approves (no human wait, clean
// outcome lands), while a floor-tripping variant of the same tool still creates
// an ApprovalRequest — proving floor supremacy beats any trust score (SC-004).
func TestAutonomy_PromotedRoutineAutoApproves_FloorStillGates(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)
	toolID := sendEmailToolID(t, env)

	// The floor-clearing routine: recipient is the owner (a known principal).
	knownPayload := map[string]any{"to": owner.GlobalUri, "subject": "hi", "body": "x"}
	raw, err := json.Marshal(knownPayload)
	require.NoError(t, err)
	fp := calibration.Fingerprint("tendant://tools/send-email", raw)
	promoteSendEmail(t, env, toolID, fp)

	// --- Auto-approve path (US1): floor-clearing, granted routine. ---
	autoTask := createTaskGQL(t, env, "auto-approve")
	walkToExecution(t, env, autoTask)
	_ = proposeToolCallGQL(t, env, autoTask, "tendant://tools/send-email", knownPayload)

	require.Equal(t, "approve", latestGateVerdict(t, env, autoTask),
		"a promoted+granted floor-clearing routine must auto-approve")
	// The auto-dispatch runs the workflow → a clean outcome lands; no open decision.
	pollUntilToolOutcome(t, env, autoTask)
	open, err := env.queries.ListOpenPendingDecisions(ctx)
	require.NoError(t, err)
	for _, d := range open {
		require.NotEqual(t, autoTask, d.TaskID, "auto-approved call must leave no OPEN decision")
	}

	// --- Floor supremacy (US4): a stranger recipient still gates. ---
	strangerTask := createTaskGQL(t, env, "floor gates")
	walkToExecution(t, env, strangerTask)
	_ = proposeToolCallGQL(t, env, strangerTask, "tendant://tools/send-email",
		map[string]any{"to": "stranger@unknown.example", "subject": "hi", "body": "x"})

	require.Equal(t, "request_decision", latestGateVerdict(t, env, strangerTask),
		"a floor-tripping call must gate despite EXECUTE_AUTO (SC-004)")
	// An OPEN ApprovalRequest exists for the stranger task.
	openAfter, err := env.queries.ListOpenPendingDecisions(ctx)
	require.NoError(t, err)
	found := false
	for _, d := range openAfter {
		if d.TaskID == strangerTask && d.Kind == db.DecisionKindApprovalRequest {
			found = true
		}
	}
	require.True(t, found, "floor-tripping call must create an open ApprovalRequest")
}
