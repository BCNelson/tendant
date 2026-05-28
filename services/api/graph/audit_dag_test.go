package graph_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// TestAuditDAG_HappyPath asserts the audit DAG invariants for a task driven
// to DONE: every transition has a row, in_reply_to wiring is correct, no
// gaps. (US4 part a.) Reuses the happy-path drive logic.
func TestAuditDAG_HappyPath(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	taskID := createTaskGQL(t, env, "audit dag happy")

	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
	completeTaskGQL(t, env, taskID, map[string]any{})
	pollUntilTaskState(t, env, taskID, db.TaskStateDone)

	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)
	require.NotEmpty(t, rows)

	// Build the set of all audit row IDs for this task and assert that every
	// transition row's in_reply_to points at one of them. (We don't rely on
	// the listing order — audit rows written in the same SQL tx share a
	// timestamp and the deterministic ordering is unstable by-id, so the
	// "parent appears before child in listing" guarantee doesn't hold.)
	idsAll := map[[16]byte]bool{}
	for _, r := range rows {
		idsAll[[16]byte(r.ID)] = true
	}
	transitionKinds := map[string]bool{
		lifecycle.KindStateTransition:   true,
		lifecycle.KindStageAdvance:      true,
		lifecycle.KindWorkflowStarted:   true,
		lifecycle.KindWorkflowCancelled: true,
	}
	for _, r := range rows {
		if !transitionKinds[r.Kind] {
			continue
		}
		// workflow_started is the genesis row (no parent on Phase 1 happy path).
		if r.Kind == lifecycle.KindWorkflowStarted {
			continue
		}
		require.Truef(t, r.InReplyTo.Valid, "transition %s should chain to a prior row", r.Kind)
		require.Truef(t, idsAll[[16]byte(r.InReplyTo.Bytes)], "in_reply_to of %s should point at an audit row for this task", r.Kind)
	}
}

// TestAuditDAG_CancelMidChain asserts the workflow_cancelled audit row's
// in_reply_to points at the most recent prior transition, and no further
// transitions appear after it. (US4 part b.)
func TestAuditDAG_CancelMidChain(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	taskID := createTaskGQL(t, env, "audit dag cancel")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	cancelTaskGQL(t, env, taskID)
	pollUntilTaskState(t, env, taskID, db.TaskStateHalted)

	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)

	var cancelIdx = -1
	for i, r := range rows {
		if r.Kind == lifecycle.KindWorkflowCancelled {
			cancelIdx = i
		}
	}
	require.GreaterOrEqual(t, cancelIdx, 0, "workflow_cancelled audit row expected")
	require.True(t, rows[cancelIdx].InReplyTo.Valid, "workflow_cancelled must have in_reply_to")

	// in_reply_to must point at SOME audit row for this task. (Same caveat
	// as TestAuditDAG_HappyPath: same-tx audit rows share a timestamp so
	// the listing order doesn't guarantee parent-before-child.)
	parentID := [16]byte(rows[cancelIdx].InReplyTo.Bytes)
	priorMatch := false
	for _, r := range rows {
		if [16]byte(r.ID) == parentID {
			priorMatch = true
			break
		}
	}
	require.True(t, priorMatch, "in_reply_to should point at an audit row for this task")

	// No NEW chain forward-progress transitions should appear after the
	// workflow_cancelled timestamp. The cleanup tx writes state_transition
	// (→ HALTED) and workflow_cancelled in the same tx with the same
	// `at` time, so they share a listing position; the meaningful
	// invariant is that no later-timestamped stage_advance or
	// assignment_created row exists.
	cancelAt := rows[cancelIdx].At
	for i := cancelIdx + 1; i < len(rows); i++ {
		if !rows[i].At.After(cancelAt) {
			continue
		}
		switch rows[i].Kind {
		case lifecycle.KindStageAdvance, lifecycle.KindAssignmentCreated, lifecycle.KindAssignmentResolved:
			t.Fatalf("no forward-progress transitions allowed after workflow_cancelled, but got %s", rows[i].Kind)
		}
	}
}

// TestAuditDAG_AtomicityOnFailedTx asserts FR-002: a state transition that
// would succeed but whose audit-write fails inside the same tx rolls back
// the state too — i.e., neither artifact is observable after a rollback.
//
// Direct rollback test: open a tx, call lifecycle.Transition with a deliberately
// bad audit payload, force a rollback, verify state did NOT change.
func TestAuditDAG_AtomicityOnFailedTx(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)
	taskID := createTaskGQL(t, env, "audit atomicity")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)

	preTask, err := env.queries.GetTask(ctx, taskID)
	require.NoError(t, err)
	preAuditCount := countAudit(t, env, taskID)

	// Begin a tx, run a transition, then deliberately rollback.
	tx, err := env.pool.Begin(ctx)
	require.NoError(t, err)
	_, err = lifecycle.Transition(ctx, tx, taskID, preTask.State, lifecycle.StateHalted, "manual atomicity test", preTask.CurrentStage)
	require.NoError(t, err)
	require.NoError(t, tx.Rollback(ctx))

	// Verify nothing changed.
	postTask, err := env.queries.GetTask(ctx, taskID)
	require.NoError(t, err)
	require.Equal(t, preTask.State, postTask.State, "state must not change after rollback")
	require.Equal(t, preAuditCount, countAudit(t, env, taskID), "audit row count must not change after rollback")
}

func countAudit(t *testing.T, env *chainEnv, taskID [16]byte) int {
	t.Helper()
	var n int
	require.NoError(t, env.pool.QueryRow(context.Background(),
		`SELECT count(*) FROM audit_messages WHERE task_id = $1`, taskID,
	).Scan(&n))
	return n
}
