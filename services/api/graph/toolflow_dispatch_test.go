package graph_test

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// auditKindCount returns how many audit_messages rows of each kind exist for a
// task. Mirrors the assertion style in approval_dispatch_test.go.
func auditKindCount(t *testing.T, env *chainEnv, taskID uuid.UUID) map[string]int {
	t.Helper()
	rows, err := env.queries.ListAuditForTask(context.Background(), taskID)
	require.NoError(t, err)
	kinds := map[string]int{}
	for _, r := range rows {
		kinds[r.Kind]++
	}
	return kinds
}

// findAuditPayload returns the (last) audit payload of the given kind for a
// task, or nil if absent.
func findAuditPayload(t *testing.T, env *chainEnv, taskID uuid.UUID, kind string) json.RawMessage {
	t.Helper()
	rows, err := env.queries.ListAuditForTask(context.Background(), taskID)
	require.NoError(t, err)
	var found json.RawMessage
	for _, r := range rows {
		if r.Kind == kind {
			found = r.Payload
		}
	}
	return found
}

// TestToolflow_RejectionPath confirms that rejecting an ApprovalRequest wakes
// the workflow, records a decision_resolved audit with approved=false, and
// dispatches NOTHING: no tool_dispatched audit, no tool_outcomes row.
func TestToolflow_RejectionPath(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "reject this send")
	walkToExecution(t, env, taskID)

	// A stranger recipient guarantees the floor trips → an open ApprovalRequest.
	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": "stranger@example.com", "subject": "x", "body": "y"},
	)

	rejectApprovalGQL(t, env, decisionID, "not appropriate")

	// The decision resolves with approved=false.
	resolved := pollUntilDecisionResolved(t, env, decisionID)
	require.True(t, resolved.ResolvedAt.Valid, "decision must be resolved after reject")

	// decision_resolved audit must record approved=false; no dispatch must occur.
	payload := pollUntilAuditKind(t, env, taskID, lifecycle.KindDecisionResolved)
	var dr lifecycle.DecisionResolvedPayload
	require.NoError(t, json.Unmarshal(payload, &dr))
	require.False(t, dr.Approved, "rejection must record approved=false")

	kinds := auditKindCount(t, env, taskID)
	require.Zero(t, kinds[lifecycle.KindToolDispatched], "rejection must not dispatch the tool")
	require.Zero(t, kinds[lifecycle.KindToolOutcomeRecorded], "rejection must not record an outcome")

	// Belt-and-suspenders: zero tool_outcomes rows.
	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 0, n, "rejection must leave zero tool_outcomes rows")
}

// failingEmailProvider always errors — drives the dispatch-error / outcome=bad
// path through the real workflow.
type failingEmailProvider struct{}

func (failingEmailProvider) Send(_ context.Context, _ tools.SendEmailPayload) (tools.Result, error) {
	return tools.Result{}, errors.New("smtp: 550 mailbox unavailable")
}

// TestToolflow_BadOutcomeAndDemotion drives a dispatch whose provider fails:
// the workflow must record outcome=bad, a tool_dispatched audit carrying the
// error, and reflexively demote the tool (a tool_demoted audit row).
func TestToolflow_BadOutcomeAndDemotion(t *testing.T) {
	ctx := context.Background()

	// Inject a send-email whose provider always errors.
	registry := tools.NewRegistry()
	registry.Register(&tools.SendEmail{Provider: failingEmailProvider{}})
	env := newChainEnv(t, withToolRegistry(registry))

	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "dispatch that fails")
	walkToExecution(t, env, taskID)
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)

	// Send to the owner (a known principal) so the floor does not trip; the
	// no-overseer stub still escalates to an ApprovalRequest we then approve.
	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": owner.GlobalUri, "subject": "x", "body": "y"},
	)
	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)

	// The single tool_outcomes row must be outcome=bad.
	var outcome string
	require.NoError(t, env.pool.QueryRow(ctx,
		`SELECT outcome::text FROM tool_outcomes WHERE task_id = $1`, taskID).Scan(&outcome))
	require.Equal(t, "bad", outcome, "a failing dispatch must land outcome=bad")

	// tool_dispatched audit must carry the provider error.
	dispatched := findAuditPayload(t, env, taskID, lifecycle.KindToolDispatched)
	require.NotNil(t, dispatched, "tool_dispatched audit must be present even on failure")
	var dp lifecycle.ToolDispatchedPayload
	require.NoError(t, json.Unmarshal(dispatched, &dp))
	require.NotEmpty(t, dp.Error, "tool_dispatched must record the dispatch error")

	// Reflexive demotion must have fired in the same path.
	kinds := auditKindCount(t, env, taskID)
	require.GreaterOrEqual(t, kinds[lifecycle.KindToolDemoted], 1, "a bad outcome must reflexively demote the tool")
}

// TestToolflow_NoDoubleDispatch proves the non-idempotent dispatch guard:
// approving the same decision twice (the resolver is idempotent via
// first-write-wins) still dispatches exactly once.
func TestToolflow_NoDoubleDispatch(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := createTaskGQL(t, env, "approve twice")
	walkToExecution(t, env, taskID)
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)

	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": owner.GlobalUri, "subject": "x", "body": "y"},
	)

	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)
	// Second approval of an already-resolved decision is a no-op at the resolver.
	approveArtifactGQL(t, env, decisionID)

	// Give any errant second dispatch a moment to land, then assert exactly one.
	time.Sleep(200 * time.Millisecond)
	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, n, "double-approve must not double-dispatch")

	kinds := auditKindCount(t, env, taskID)
	require.Equal(t, 1, kinds[lifecycle.KindToolDispatched], "exactly one tool_dispatched")
	require.Equal(t, 1, kinds[lifecycle.KindToolOutcomeRecorded], "exactly one tool_outcome_recorded")
}

// pollUntilDecisionResolved blocks until the decision row's resolved_at is set.
func pollUntilDecisionResolved(t *testing.T, env *chainEnv, decisionID uuid.UUID) db.PendingDecision {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(10 * time.Second)
	for time.Now().Before(deadline) {
		row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
		if err == nil && row.ResolvedAt.Valid {
			return row
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for decision %s to resolve", decisionID)
	return db.PendingDecision{}
}

// pollUntilAuditKind blocks until an audit row of the given kind exists for the
// task, returning its payload.
func pollUntilAuditKind(t *testing.T, env *chainEnv, taskID uuid.UUID, kind string) json.RawMessage {
	t.Helper()
	deadline := time.Now().Add(10 * time.Second)
	for time.Now().Before(deadline) {
		if p := findAuditPayload(t, env, taskID, kind); p != nil {
			return p
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for audit kind %s on task %s", kind, taskID)
	return nil
}
