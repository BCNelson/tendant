package graph_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// chainEnv holds the boot products of a single test: pool, dbos context,
// HTTP handler. Tests own teardown via testing.T cleanup hooks.
type chainEnv struct {
	pool    *pgxpool.Pool
	dctx    dbos.DBOSContext
	handler http.Handler
	queries *db.Queries
}

// newChainEnv boots a fresh testcontainers Postgres + DBOS context for a
// test. The executor ID is randomized so parallel/sequential tests don't
// share recovery state.
func newChainEnv(t *testing.T) *chainEnv {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))

	executorID := "test-" + uuid.New().String()
	dctx, err := durable.Init(ctx, pool, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, "", nil)
	// Phase 3 tool-call workflow + send-email tool row. Idempotent on every
	// test boot; harmless for Phase 1 tests that don't exercise the path.
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(nil))
	durable.RegisterToolCallWorkflow(dctx, pool, q, registry)
	require.NoError(t, tools.SeedSendEmail(ctx, q))
	require.NoError(t, durable.Launch(dctx))
	t.Cleanup(func() {
		durable.Shutdown(dctx, 5*time.Second)
	})

	handler := server.New(pool, dctx, server.Options{})
	return &chainEnv{pool: pool, dctx: dctx, handler: handler, queries: q}
}

// pollUntilAssignmentAt blocks until the task has an open assignment at the
// given stage (lowercase enum value as stored in DB). Fails the test on timeout.
func pollUntilAssignmentAt(t *testing.T, env *chainEnv, taskID uuid.UUID, wantStage db.ChainStage) db.AgentAssignment {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		row, err := env.queries.FindOpenAssignmentForTask(ctx, taskID)
		if err == nil && row.Stage == wantStage {
			return row
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for open assignment at stage %s", wantStage)
	return db.AgentAssignment{}
}

// pollUntilTaskState blocks until the task reaches the given DB state.
func pollUntilTaskState(t *testing.T, env *chainEnv, taskID uuid.UUID, wantState db.TaskState) db.Task {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		row, err := env.queries.GetTask(ctx, taskID)
		if err == nil && row.State == wantState {
			return row
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for task state %s", wantState)
	return db.Task{}
}

// createTaskGQL runs the createTask mutation and returns the created task id.
func createTaskGQL(t *testing.T, env *chainEnv, title string) uuid.UUID {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($title: String!) { createTask(title: $title) { id } }`,
		map[string]any{"title": title})
	var data struct {
		CreateTask struct {
			ID string `json:"id"`
		} `json:"createTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	tid, err := uuid.Parse(data.CreateTask.ID)
	require.NoError(t, err)
	return tid
}

// completeTaskGQL runs the completeTask mutation. result may be nil → {}.
func completeTaskGQL(t *testing.T, env *chainEnv, taskID uuid.UUID, result map[string]any) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $r: JSON) { completeTask(taskId: $id, result: $r) { id } }`,
		map[string]any{"id": taskID.String(), "r": result})
	var data struct {
		CompleteTask struct {
			ID string `json:"id"`
		} `json:"completeTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Equal(t, taskID.String(), data.CompleteTask.ID)
}

// cancelTaskGQL runs the cancelTask mutation.
func cancelTaskGQL(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!) { cancelTask(taskId: $id) { id } }`,
		map[string]any{"id": taskID.String()})
	var data struct {
		CancelTask struct {
			ID string `json:"id"`
		} `json:"cancelTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
}

// graphqlRequestExpectError runs a GraphQL request and returns the errors
// array (does not fail on errors — the test asserts the shape).
func graphqlRequestExpectError(t *testing.T, handler http.Handler, query string, vars map[string]any) []json.RawMessage {
	t.Helper()
	body := mustJSON(map[string]any{"query": query, "variables": vars})
	resp := postGraphQL(t, handler, body)
	if len(resp.Errors) == 0 {
		t.Fatalf("expected errors but got: %s", resp.Data)
	}
	return resp.Errors
}

func mustJSON(v any) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		panic(fmt.Sprintf("marshal: %v", err))
	}
	return b
}
