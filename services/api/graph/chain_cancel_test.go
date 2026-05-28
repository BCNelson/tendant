package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// TestChainCancel_MidChain halts forward progress at TRIAGE; asserts state
// = HALTED, chain workflow closed, audit row present with in_reply_to set
// (US2 / Q2 / FR-016).
func TestChainCancel_MidChain(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)

	taskID := createTaskGQL(t, env, "cancel mid-chain")
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)

	cancelTaskGQL(t, env, taskID)

	final := pollUntilTaskState(t, env, taskID, db.TaskStateHalted)
	_ = final

	// chain_workflows.status == 'cancelled', ended_at set.
	var (
		status  string
		endedAt *string
	)
	require.NoError(t, env.pool.QueryRow(ctx,
		`SELECT status, ended_at::text FROM chain_workflows WHERE task_id = $1`,
		taskID).Scan(&status, &endedAt))
	require.Equal(t, "cancelled", status)
	require.NotNil(t, endedAt)

	// A workflow_cancelled audit row exists with in_reply_to set to the most
	// recent prior transition.
	rows, err := env.queries.ListAuditForTask(ctx, taskID)
	require.NoError(t, err)
	var cancelRow *db.AuditMessage
	for i := range rows {
		if rows[i].Kind == lifecycle.KindWorkflowCancelled {
			cancelRow = &rows[i]
			break
		}
	}
	require.NotNil(t, cancelRow, "workflow_cancelled audit row expected")
	require.True(t, cancelRow.InReplyTo.Valid, "workflow_cancelled should have in_reply_to")

	// Subsequent completeTask returns a typed error.
	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($id: ID!) { completeTask(taskId: $id, result: {}) { id } }`,
		map[string]any{"id": taskID.String()})
	require.NotEmpty(t, errs)
	codeFound := errorCodeFromErrors(t, errs) == TaskAlreadyTerminalCodeExposed
	require.True(t, codeFound, "expected TASK_ALREADY_TERMINAL code in errors: %s", errs)

	// Subsequent cancelTask returns TASK_ALREADY_TERMINAL.
	errs2 := graphqlRequestExpectError(t, env.handler,
		`mutation($id: ID!) { cancelTask(taskId: $id) { id } }`,
		map[string]any{"id": taskID.String()})
	require.Equal(t, TaskAlreadyTerminalCodeExposed, errorCodeFromErrors(t, errs2))
}

// TaskAlreadyTerminalCodeExposed mirrors graph.TaskAlreadyTerminalCode to
// keep this test self-contained without importing the production constant
// across the test boundary.
const TaskAlreadyTerminalCodeExposed = "TASK_ALREADY_TERMINAL"

func errorCodeFromErrors(t *testing.T, errs []json.RawMessage) string {
	t.Helper()
	for _, raw := range errs {
		var e struct {
			Extensions map[string]any `json:"extensions"`
		}
		if err := json.Unmarshal(raw, &e); err == nil {
			if v, ok := e.Extensions["code"].(string); ok {
				return v
			}
		}
	}
	return ""
}
