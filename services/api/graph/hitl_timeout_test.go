package graph_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// TestToolflow_ApprovalTimeoutExpires drives the headline HITL behavior: an
// ApprovalRequest that the human never answers must NOT poison the workflow to
// ERROR. With a short hitl.approval_timeout the tool-call workflow expires the
// decision explicitly — resolving the row (so the inbox drops it), writing a
// decision_expired audit, and dispatching nothing.
func TestToolflow_ApprovalTimeoutExpires(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t, withTimeouts(fixedTimeouts{approval: 50 * time.Millisecond}))
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "let this approval expire")
	walkToExecution(t, env, taskID)

	// A stranger recipient trips the floor → an open ApprovalRequest. We then do
	// nothing and let the 50ms timeout fire.
	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": "stranger@example.com", "subject": "x", "body": "y"},
	)

	// The workflow resolves the decision as expired on its own.
	resolved := pollUntilDecisionResolved(t, env, decisionID)
	require.True(t, resolved.ResolvedAt.Valid, "an expired decision must be resolved (so the inbox drops it)")
	var res map[string]any
	require.NoError(t, json.Unmarshal(resolved.Resolution, &res))
	require.Equal(t, true, res["expired"], "resolution must mark the decision expired")

	// A decision_expired audit must record the timeout for the operator.
	payload := pollUntilAuditKind(t, env, taskID, lifecycle.KindDecisionExpired)
	var dx lifecycle.DecisionExpiredPayload
	require.NoError(t, json.Unmarshal(payload, &dx))
	require.Equal(t, decisionID, dx.DecisionID)
	require.Equal(t, string(db.DecisionKindApprovalRequest), dx.Flow)

	// Nothing dispatched: no tool_dispatched / tool_outcome_recorded audit, zero
	// tool_outcomes rows.
	kinds := auditKindCount(t, env, taskID)
	require.Zero(t, kinds[lifecycle.KindToolDispatched], "an expired approval must not dispatch the tool")
	require.Zero(t, kinds[lifecycle.KindToolOutcomeRecorded], "an expired approval must not record an outcome")
	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 0, n, "an expired approval must leave zero tool_outcomes rows")

	// The inbox no longer surfaces the decision (resolved_at is set).
	require.False(t, decisionIsOpen(t, env, decisionID), "expired decision must drop from the open-decision set")
}

// TestChainStage_TimeoutReroutes proves a human stage slot that times out is
// re-armed and escalated (a stage_timeout_rerouted audit) rather than left to
// die as ERROR. The assignment stays open throughout; after MaxStageTimeouts the
// wait falls back to no-timeout, so completeTask still resolves it.
func TestChainStage_TimeoutReroutes(t *testing.T) {
	env := newChainEnv(t, withTimeouts(fixedTimeouts{stage: 60 * time.Millisecond}))
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "let a stage time out")
	// Drive to the EXECUTION human slot (human-only routing).
	walkToExecution(t, env, taskID)
	assignment := pollUntilAssignmentAt(t, env, taskID, "execution")

	// The 60ms stage timeout fires repeatedly → eventually an escalated
	// stage_timeout_rerouted (Attempt == MaxStageTimeouts, Escalated true).
	esc := pollUntilStageTimeoutEscalated(t, env, taskID)
	require.True(t, esc.Escalated, "the final timeout must be marked escalated")
	require.GreaterOrEqual(t, esc.Attempt, 1, "attempt is 1-based")

	// The assignment must still be open (never abandoned).
	stillOpen, err := env.queries.FindOpenAssignmentForTask(context.Background(), taskID)
	require.NoError(t, err)
	require.Equal(t, assignment.ID, stillOpen.ID, "the timed-out slot stays open for the human")

	// After escalation the wait is no-timeout: completeTask still resolves it.
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilTaskState(t, env, taskID, "done")
}

// decisionIsOpen reports whether the decision is still in the open
// (resolved_at IS NULL) set — the membership condition the inbox keys on.
func decisionIsOpen(t *testing.T, env *chainEnv, decisionID uuid.UUID) bool {
	t.Helper()
	rows, err := env.queries.ListOpenPendingDecisions(context.Background())
	require.NoError(t, err)
	for _, r := range rows {
		if r.ID == decisionID {
			return true
		}
	}
	return false
}

// pollUntilStageTimeoutEscalated blocks until an escalated stage_timeout_rerouted
// audit exists for the task, returning its decoded payload.
func pollUntilStageTimeoutEscalated(t *testing.T, env *chainEnv, taskID uuid.UUID) lifecycle.StageTimeoutReroutedPayload {
	t.Helper()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		rows, err := env.queries.ListAuditForTask(context.Background(), taskID)
		require.NoError(t, err)
		for _, r := range rows {
			if r.Kind == lifecycle.KindStageTimeoutRerouted {
				var p lifecycle.StageTimeoutReroutedPayload
				require.NoError(t, json.Unmarshal(r.Payload, &p))
				if p.Escalated {
					return p
				}
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for an escalated stage_timeout_rerouted on task %s", taskID)
	return lifecycle.StageTimeoutReroutedPayload{}
}
