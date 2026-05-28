package graph_test

import (
	"context"
	"sync"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TestChainCancel_RaceVsComplete fires completeTask and cancelTask
// concurrently. Phase 1's chosen Q2 semantics: the resolver-driven cleanup
// produces a terminal HALTED task regardless of which Send wins. The next
// stage (EXPANSION) MUST NOT have a fresh assignment created.
//
// Note: Phase 1's simplified design has the cancelTask resolver perform the
// HALTED cleanup directly; if completeTask wins the Recv, the workflow's
// resolve step will then see the cancelled status and abort. Either way,
// the operator-visible outcome is HALTED with no EXPANSION slot opened.
func TestChainCancel_RaceVsComplete(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)

	taskID := createTaskGQL(t, env, "race test")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		// completeTask may succeed OR fail (depending on race ordering); the
		// test asserts on the post-race state, not on this call's outcome.
		_ = postGraphQL(t, env.handler, mustJSON(map[string]any{
			"query":     "mutation($id: ID!) { completeTask(taskId: $id, result: {}) { id } }",
			"variables": map[string]any{"id": taskID.String()},
		}))
	}()
	go func() {
		defer wg.Done()
		_ = postGraphQL(t, env.handler, mustJSON(map[string]any{
			"query":     "mutation($id: ID!) { cancelTask(taskId: $id) { id } }",
			"variables": map[string]any{"id": taskID.String()},
		}))
	}()
	wg.Wait()

	// Final state must be HALTED.
	final := pollUntilTaskState(t, env, taskID, db.TaskStateHalted)
	_ = final

	// No EXPANSION assignment should have been created — only the TRIAGE
	// row should exist.
	var stageCount int
	require.NoError(t, env.pool.QueryRow(ctx,
		`SELECT count(*) FROM agent_assignments WHERE task_id = $1 AND stage = $2`,
		taskID, db.ChainStageExpansion,
	).Scan(&stageCount))
	require.Equal(t, 0, stageCount, "no EXPANSION assignment expected after cancel-race")
}
