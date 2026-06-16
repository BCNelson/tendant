package graph_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// These tests exercise OUR durable workflows (chain + toolflow) across a
// simulated server restart — recovery must replay our memoized step sequences
// deterministically and the task/decision must still progress. They are NOT
// testing DBOS's recovery machinery in the abstract; each asserts a concrete
// behaviour of our workflow code (toolflow dispatch-after-approval, the chain's
// agent-vs-human branch, the terminal-state early return, the cancel sentinel).

// --- 1. toolflow approval workflow survives a restart mid-wait. --------------

// TestRecovery_ToolflowApprovalSurvivesRestart proposes a gated tool call (the
// toolflow workflow blocks on its approval Recv), restarts the server, and
// proves the recovered workflow still dispatches the tool when the owner
// approves — i.e. the approval Send is consumed after recovery and a
// tool_outcomes row lands.
func TestRecovery_ToolflowApprovalSurvivesRestart(t *testing.T) {
	ctx := context.Background()
	env, cfg := newRecoveryEnv(t)

	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)

	taskID := createTaskGQL(t, env, "approval-survives-restart")
	walkToExecution(t, env, taskID)

	decisionID := proposeToolCallGQL(t, env, taskID,
		"tendant://tools/send-email",
		map[string]any{"to": owner.GlobalUri, "subject": "hello", "body": "self"},
	)
	row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.False(t, row.ResolvedAt.Valid, "decision should be open before approval")
	require.NotNil(t, row.WorkflowID, "toolflow workflow id must be set")
	toolflowWfID := *row.WorkflowID

	// Restart while the toolflow workflow waits on its approval Recv.
	env2 := rebootChainEnv(t, env, cfg)
	defer chainShutdown(env2)

	requireWorkflowNeverErrors(t, ctx, env2.pool, toolflowWfID, 5*time.Second)

	// Approve via the rebooted server; the recovered workflow dispatches.
	approveArtifactGQL(t, env2, decisionID)
	pollUntilToolOutcome(t, env2, taskID)

	resolved, err := env2.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.True(t, resolved.ResolvedAt.Valid, "decision should be resolved after recovery+approve")
	n, err := env2.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, n, "exactly one tool_outcomes row after recovery")
}

// --- 2. chain agent-path stages replay deterministically across a restart. ---

// scriptedRouter routes every stage to an agent (never directly to a human).
type scriptedRouter struct{}

func (scriptedRouter) Select(_ context.Context, _ lifecycle.ChainStage, _ json.RawMessage) (chain.SlotDecision, error) {
	id := uuid.New()
	return chain.SlotDecision{IsHuman: false, ConfigID: &id, ConfigName: "stub-agent"}, nil
}

// scriptedRunner succeeds (non-fail-close) for the stages NOT in humanStages,
// and fail-closes to a human for the stages in it. A successful agent stage
// returns its result inside the memoized SlotDecision and the workflow does NOT
// block on Recv — the surface this test guards across recovery.
type scriptedRunner struct{ humanStages map[lifecycle.ChainStage]bool }

func (r scriptedRunner) RunStage(_ context.Context, _ string, stage lifecycle.ChainStage, _ string) (json.RawMessage, error) {
	if r.humanStages[stage] {
		return json.Marshal(map[string]any{
			"fail_close_to_human": true,
			"handoff_reason":      "needs a human at " + string(stage),
		})
	}
	return json.Marshal(map[string]any{"ok": true, "stage": string(stage)})
}

// TestRecovery_AgentStagesReplayThenHumanWaitSurvivesRestart drives a task
// where the agent SUCCEEDS at TRIAGE + EXPANSION (no human, no Recv) and then
// hands EXECUTION off to a human. It restarts while blocked at EXECUTION and
// asserts the recovered workflow does NOT poison to ERROR — proving the memoized
// agent-success decisions replay without the workflow spuriously calling Recv
// where it previously did not — and that completing EXECUTION reaches DONE.
func TestRecovery_AgentStagesReplayThenHumanWaitSurvivesRestart(t *testing.T) {
	ctx := context.Background()
	env, cfg := newRecoveryEnv(t, withAgentChain(
		func(_ *pgxpool.Pool, _ *db.Queries, _ *tools.Registry) (chain.Router, chain.StageRunner, string) {
			return scriptedRouter{}, scriptedRunner{humanStages: map[lifecycle.ChainStage]bool{
				lifecycle.StageExecution: true,
			}}, ""
		},
	))

	taskID := createTaskGQL(t, env, "agent-stages-then-human")
	workflowID := chain.ChainWorkflowID(taskID)

	// Agent auto-runs TRIAGE + EXPANSION; EXECUTION fails closed to a human.
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)

	env2 := rebootChainEnv(t, env, cfg)
	defer chainShutdown(env2)

	requireWorkflowNeverErrors(t, ctx, env2.pool, workflowID, 5*time.Second)

	openAfter := pollUntilAssignmentAt(t, env2, taskID, db.ChainStageExecution)
	require.NotEqual(t, uuid.Nil, openAfter.ID)
	time.Sleep(500 * time.Millisecond)

	completeTaskGQL(t, env2, taskID, map[string]any{"done": true})
	pollUntilTaskState(t, env2, taskID, db.TaskStateDone)
}

// --- 3. recovery of an already-completed workflow is a clean no-op. ----------

// TestRecovery_CompletedWorkflowEarlyReturns drives a task to DONE, then forces
// its (SUCCESS) chain workflow back to PENDING and restarts. Recovery re-runs
// the workflow body, which must hit the IsTerminal early return and exit cleanly
// without redoing any completion work (no second state_transition to DONE, no
// new assignment), leaving the task DONE.
func TestRecovery_CompletedWorkflowEarlyReturns(t *testing.T) {
	ctx := context.Background()
	env, cfg := newRecoveryEnv(t)

	taskID := createTaskGQL(t, env, "completed-early-return")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilTaskState(t, env, taskID, db.TaskStateDone)

	workflowID := chain.ChainWorkflowID(taskID)
	doneTransitionsBefore := countDoneTransitions(t, ctx, env, taskID)
	require.EqualValues(t, 1, doneTransitionsBefore, "exactly one EXECUTING→DONE before recovery")

	// Force the completed workflow back to PENDING so the next Launch re-runs it,
	// exercising the IsTerminal early-return branch.
	_, err := env.pool.Exec(ctx,
		`UPDATE dbos.workflow_status SET status = 'PENDING' WHERE workflow_uuid = $1`, workflowID)
	require.NoError(t, err)

	env2 := rebootChainEnv(t, env, cfg)
	defer chainShutdown(env2)

	// The re-run must settle the workflow back to SUCCESS and change nothing else.
	requireWorkflowReachesStatus(t, ctx, env2.pool, workflowID, "SUCCESS", 10*time.Second)
	task, err := env2.queries.GetTask(ctx, taskID)
	require.NoError(t, err)
	require.Equal(t, db.TaskStateDone, task.State, "task stays DONE after re-running a completed workflow")
	require.EqualValues(t, 1, countDoneTransitions(t, ctx, env2, taskID),
		"recovery of a completed workflow must NOT write a second EXECUTING→DONE transition")
}

// --- 4. cancel after a restart still halts cleanly via the sentinel. ---------

// TestRecovery_CancelAfterRestartHaltsCleanly restarts a task blocked in the
// EXECUTION human slot, then cancels it. The cancel sentinel must reach the
// recovered workflow's Recv, the task must transition to HALTED, and the
// workflow must exit cleanly (never ERROR).
func TestRecovery_CancelAfterRestartHaltsCleanly(t *testing.T) {
	ctx := context.Background()
	env, cfg := newRecoveryEnv(t)

	taskID := createTaskGQL(t, env, "cancel-after-restart")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)

	workflowID := chain.ChainWorkflowID(taskID)

	env2 := rebootChainEnv(t, env, cfg)
	defer chainShutdown(env2)

	requireWorkflowNeverErrors(t, ctx, env2.pool, workflowID, 5*time.Second)
	pollUntilAssignmentAt(t, env2, taskID, db.ChainStageExecution)
	time.Sleep(500 * time.Millisecond)

	cancelTaskGQL(t, env2, taskID)
	pollUntilTaskState(t, env2, taskID, db.TaskStateHalted)

	// The recovered workflow consumes the cancel sentinel and exits PENDING —
	// it must not linger blocked in Recv, and must not poison to ERROR. (DBOS
	// records the terminal state as SUCCESS or CANCELLED depending on the
	// CancelWorkflow/sentinel race; both are clean exits.)
	requireWorkflowTerminates(t, ctx, env2.pool, workflowID, 10*time.Second)
}

// --- shared helpers for the scenario tests. ---------------------------------

// chainShutdown gracefully tears down a rebooted env's DBOS context.
func chainShutdown(env *chainEnv) {
	durable.Shutdown(env.dctx, 5*time.Second)
}

// countDoneTransitions counts state_transition audit rows whose payload records
// a transition INTO the DONE state for the task.
func countDoneTransitions(t *testing.T, ctx context.Context, env *chainEnv, taskID uuid.UUID) int {
	t.Helper()
	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)
	n := 0
	for _, r := range rows {
		if r.Kind != lifecycle.KindStateTransition {
			continue
		}
		var p lifecycle.StateTransitionPayload
		if err := json.Unmarshal(r.Payload, &p); err == nil && p.To == lifecycle.StateDone {
			n++
		}
	}
	return n
}

// requireWorkflowReachesStatus polls until the workflow reaches wantStatus,
// failing fast (and loud) if it reaches terminal ERROR first.
func requireWorkflowReachesStatus(t *testing.T, ctx context.Context, pool *pgxpool.Pool, wfID, wantStatus string, window time.Duration) {
	t.Helper()
	deadline := time.Now().Add(window)
	var last, errMsg string
	for time.Now().Before(deadline) {
		require.NoError(t, pool.QueryRow(ctx,
			`SELECT status, COALESCE(error, '') FROM dbos.workflow_status WHERE workflow_uuid = $1`,
			wfID).Scan(&last, &errMsg))
		require.NotEqualf(t, "ERROR", last,
			"workflow reached terminal ERROR while awaiting %s: %s", wantStatus, errMsg)
		if last == wantStatus {
			return
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("workflow %s did not reach %s within %s (last=%s)", wfID, wantStatus, window, last)
}

// requireWorkflowTerminates polls until the workflow leaves the non-terminal
// PENDING/ENQUEUED states, failing fast if it reaches terminal ERROR. Returns
// the terminal status reached (SUCCESS or CANCELLED).
func requireWorkflowTerminates(t *testing.T, ctx context.Context, pool *pgxpool.Pool, wfID string, window time.Duration) string {
	t.Helper()
	deadline := time.Now().Add(window)
	var last, errMsg string
	for time.Now().Before(deadline) {
		require.NoError(t, pool.QueryRow(ctx,
			`SELECT status, COALESCE(error, '') FROM dbos.workflow_status WHERE workflow_uuid = $1`,
			wfID).Scan(&last, &errMsg))
		require.NotEqualf(t, "ERROR", last, "workflow poisoned to terminal ERROR: %s", errMsg)
		if last != "PENDING" && last != "ENQUEUED" {
			return last
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("workflow %s did not terminate within %s (stuck at %s)", wfID, window, last)
	return ""
}
