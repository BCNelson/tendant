package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// TestChainHappyPath_OwnerAuthored_WalksToDone drives a task end-to-end via
// the GraphQL mutations and asserts the chain advances to DONE with the
// expected audit DAG (US1 / SC-001 + SC-002).
func TestChainHappyPath_OwnerAuthored_WalksToDone(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)

	taskID := createTaskGQL(t, env, "happy path task")

	// 1. TRIAGE
	triage := pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"categorized": true, "kind": "personal"})

	// 2. EXPANSION
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"subtasks": []string{"buy milk", "fix shelf"}})

	// 3. EXECUTION
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
	completeTaskGQL(t, env, taskID, map[string]any{"done": true})

	// 4. Final state: DONE / COMPLETION / chain workflow ended.
	final := pollUntilTaskState(t, env, taskID, db.TaskStateDone)
	require.Equal(t, db.ChainStageCompletion, final.CurrentStage)

	open, err := env.queries.FindOpenAssignmentForTask(ctx, taskID)
	require.Error(t, err, "no open assignment expected; got %v", open)

	// chain_workflows.ended_at set.
	var endedAt *string
	require.NoError(t, env.pool.QueryRow(ctx,
		`SELECT ended_at::text FROM chain_workflows WHERE task_id = $1`,
		taskID).Scan(&endedAt))
	require.NotNil(t, endedAt, "chain_workflows.ended_at should be set")

	// First TRIAGE assignment is closed.
	require.NotZero(t, triage.ID)

	// US4-style audit DAG checks: kinds present, in_reply_to wired.
	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)

	kinds := map[string]int{}
	for _, r := range rows {
		kinds[r.Kind]++
	}
	require.Equal(t, 1, kinds[lifecycle.KindWorkflowStarted], "exactly one workflow_started")
	require.Equal(t, 3, kinds[lifecycle.KindAssignmentCreated], "three assignments created (TRIAGE, EXPANSION, EXECUTION)")
	require.Equal(t, 3, kinds[lifecycle.KindAssignmentResolved], "three assignments resolved")
	require.GreaterOrEqual(t, kinds[lifecycle.KindStageAdvance], 4, "at least four stage advances (CREATION→TRIAGE→EXPANSION→EXECUTION→COMPLETION)")
	// State transitions: ACCEPTED→EXECUTING + EXECUTING→DONE.
	require.Equal(t, 2, kinds[lifecycle.KindStateTransition])

	// in_reply_to wiring: every assignment_resolved points at the matching assignment_created.
	resolvedByAssignment := map[uuid.UUID]db.AuditMessage{}
	createdByAssignment := map[uuid.UUID]db.AuditMessage{}
	for _, r := range rows {
		switch r.Kind {
		case lifecycle.KindAssignmentResolved:
			var p lifecycle.AssignmentResolvedPayload
			require.NoError(t, json.Unmarshal(r.Payload, &p))
			resolvedByAssignment[p.AssignmentID] = r
		case lifecycle.KindAssignmentCreated:
			var p lifecycle.AssignmentCreatedPayload
			require.NoError(t, json.Unmarshal(r.Payload, &p))
			createdByAssignment[p.AssignmentID] = r
		}
	}
	require.Len(t, resolvedByAssignment, 3)
	for aid, resolved := range resolvedByAssignment {
		created, ok := createdByAssignment[aid]
		require.True(t, ok, "assignment %s has resolved but no created row", aid)
		require.True(t, resolved.InReplyTo.Valid, "resolved row in_reply_to must be set")
		require.Equal(t, created.ID, uuid.UUID(resolved.InReplyTo.Bytes), "in_reply_to should point at assignment_created row")
	}
}
