package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// authAsOwner mints an owner session and sets it as the package-level test
// bearer so auth-gated read resolvers (e.g. the `task` query) see a principal.
func authAsOwner(t *testing.T, env *chainEnv) {
	t.Helper()
	ctx := context.Background()
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)
	_, raw, err := auth.IssueSession(ctx, env.queries, owner.ID, "task_graph_test")
	require.NoError(t, err)
	prev := testBearer
	testBearer = raw
	t.Cleanup(func() { testBearer = prev })
}

// addRelationGQL runs the addTaskRelation mutation and returns the new
// relation's id.
func addRelationGQL(t *testing.T, env *chainEnv, from, to uuid.UUID, kind string) string {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ addTaskRelation(fromTaskId:$f, toTaskId:$o, kind:$k){ id kind from{id} to{id} } }`,
		map[string]any{"f": from.String(), "o": to.String(), "k": kind})
	var data struct {
		AddTaskRelation struct {
			ID   string              `json:"id"`
			Kind string              `json:"kind"`
			From struct{ ID string } `json:"from"`
			To   struct{ ID string } `json:"to"`
		} `json:"addTaskRelation"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Equal(t, kind, data.AddTaskRelation.Kind)
	require.Equal(t, from.String(), data.AddTaskRelation.From.ID)
	require.Equal(t, to.String(), data.AddTaskRelation.To.ID)
	return data.AddTaskRelation.ID
}

// driveToDone walks an owner-authored task through all three human stages to DONE.
func driveToDone(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilTaskState(t, env, taskID, db.TaskStateDone)
}

// TestDependencyGate_BlocksUntilBlockerDone proves a blocked task parks in
// WAITING at the readiness gate and is woken to EXECUTING only once its blocker
// reaches DONE (FR-019: dependency-gated eligibility).
func TestDependencyGate_BlocksUntilBlockerDone(t *testing.T) {
	ctx := context.Background()
	env := newChainEnv(t)

	blocker := createTaskGQL(t, env, "blocker")
	dependent := createTaskGQL(t, env, "dependent")

	// dependent depends on blocker: blocker --blocks--> dependent.
	addRelationGQL(t, env, blocker, dependent, "BLOCKS")

	// Walk dependent up to the execution boundary.
	pollUntilAssignmentAt(t, env, dependent, db.ChainStageTriage)
	completeTaskGQL(t, env, dependent, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, dependent, db.ChainStageExpansion)
	completeTaskGQL(t, env, dependent, map[string]any{"ok": true})

	// The gate parks it in WAITING — its blocker is not yet done.
	waiting := pollUntilTaskState(t, env, dependent, db.TaskStateWaiting)
	require.Equal(t, db.ChainStageExecution, waiting.CurrentStage)

	// No execution assignment is opened while parked.
	_, err := env.queries.FindOpenAssignmentForTask(ctx, dependent)
	require.Error(t, err, "no open assignment should exist while parked in the gate")

	// Drive the blocker all the way to DONE; this wakes the dependent's gate.
	driveToDone(t, env, blocker)

	// The dependent now becomes eligible: WAITING → EXECUTING, execution slot opens.
	pollUntilAssignmentAt(t, env, dependent, db.ChainStageExecution)
	completeTaskGQL(t, env, dependent, map[string]any{"ok": true})
	pollUntilTaskState(t, env, dependent, db.TaskStateDone)

	// Audit DAG records the readiness gate's two transitions:
	// ACCEPTED→WAITING (predicate false) and WAITING→EXECUTING (predicate true).
	rows, err := env.queries.ListAuditForTask(ctx, dependent)
	require.NoError(t, err)
	var toWaiting, toExecuting int
	for _, r := range rows {
		if r.Kind != "state_transition" {
			continue
		}
		var p struct {
			From string `json:"from"`
			To   string `json:"to"`
		}
		require.NoError(t, json.Unmarshal(r.Payload, &p))
		if p.To == "waiting" {
			toWaiting++
		}
		if p.From == "waiting" && p.To == "executing" {
			toExecuting++
		}
	}
	require.Equal(t, 1, toWaiting, "exactly one ACCEPTED→WAITING gate transition")
	require.Equal(t, 1, toExecuting, "exactly one WAITING→EXECUTING wake transition")
}

// TestTaskRelations_CRUDAndGuards covers the relation mutations and their
// integrity guards: self-link, duplicate, cycle, and single-parent rejection,
// plus the traversal field resolvers.
func TestTaskRelations_CRUDAndGuards(t *testing.T) {
	env := newChainEnv(t)
	authAsOwner(t, env)

	a := createTaskGQL(t, env, "A")
	b := createTaskGQL(t, env, "B")
	c := createTaskGQL(t, env, "C")

	// A blocks B.
	addRelationGQL(t, env, a, b, "BLOCKS")

	// Self-link rejected.
	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ addTaskRelation(fromTaskId:$f,toTaskId:$o,kind:$k){id} }`,
		map[string]any{"f": a.String(), "o": a.String(), "k": "BLOCKS"})
	require.NotEmpty(t, errs)

	// Duplicate rejected.
	errs = graphqlRequestExpectError(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ addTaskRelation(fromTaskId:$f,toTaskId:$o,kind:$k){id} }`,
		map[string]any{"f": a.String(), "o": b.String(), "k": "BLOCKS"})
	require.NotEmpty(t, errs)

	// Cycle rejected: B blocks A would close A→B→A.
	errs = graphqlRequestExpectError(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ addTaskRelation(fromTaskId:$f,toTaskId:$o,kind:$k){id} }`,
		map[string]any{"f": b.String(), "o": a.String(), "k": "BLOCKS"})
	require.NotEmpty(t, errs)

	// Subtree: B subtask_of A. A second parent (B subtask_of C) is rejected.
	addRelationGQL(t, env, b, a, "SUBTASK_OF")
	errs = graphqlRequestExpectError(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ addTaskRelation(fromTaskId:$f,toTaskId:$o,kind:$k){id} }`,
		map[string]any{"f": b.String(), "o": c.String(), "k": "SUBTASK_OF"})
	require.NotEmpty(t, errs)

	// Traversals: A.blocks=[B], B.blockedBy=[A], A.subtasks=[B], B.parent=A.
	var q struct {
		Task struct {
			Blocks    []struct{ ID string } `json:"blocks"`
			Subtasks  []struct{ ID string } `json:"subtasks"`
			BlockedBy []struct{ ID string } `json:"blockedBy"`
			Parent    *struct{ ID string }  `json:"parent"`
		} `json:"task"`
	}
	respA := graphqlRequest(t, env.handler,
		`query($id:ID!){ task(id:$id){ blocks{id} subtasks{id} } }`, map[string]any{"id": a.String()})
	require.NoError(t, json.Unmarshal(respA.Data, &q))
	require.Len(t, q.Task.Blocks, 1)
	require.Equal(t, b.String(), q.Task.Blocks[0].ID)
	require.Len(t, q.Task.Subtasks, 1)
	require.Equal(t, b.String(), q.Task.Subtasks[0].ID)

	respB := graphqlRequest(t, env.handler,
		`query($id:ID!){ task(id:$id){ blockedBy{id} parent{id} } }`, map[string]any{"id": b.String()})
	require.NoError(t, json.Unmarshal(respB.Data, &q))
	require.Len(t, q.Task.BlockedBy, 1)
	require.Equal(t, a.String(), q.Task.BlockedBy[0].ID)
	require.NotNil(t, q.Task.Parent)
	require.Equal(t, a.String(), q.Task.Parent.ID)

	// Remove the blocks edge; B.blockedBy is then empty.
	var rm struct {
		RemoveTaskRelation bool `json:"removeTaskRelation"`
	}
	rmResp := graphqlRequest(t, env.handler,
		`mutation($f:ID!,$o:ID!,$k:TaskRelationKind!){ removeTaskRelation(fromTaskId:$f,toTaskId:$o,kind:$k) }`,
		map[string]any{"f": a.String(), "o": b.String(), "k": "BLOCKS"})
	require.NoError(t, json.Unmarshal(rmResp.Data, &rm))
	require.True(t, rm.RemoveTaskRelation)

	respB2 := graphqlRequest(t, env.handler,
		`query($id:ID!){ task(id:$id){ blockedBy{id} } }`, map[string]any{"id": b.String()})
	require.NoError(t, json.Unmarshal(respB2.Data, &q))
	require.Empty(t, q.Task.BlockedBy)
}
