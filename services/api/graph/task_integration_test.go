package graph_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// gqlResponse is the minimal envelope returned by the gqlgen handler.
type gqlResponse struct {
	Data   json.RawMessage   `json:"data"`
	Errors []json.RawMessage `json:"errors,omitempty"`
}

func graphqlRequest(t *testing.T, handler http.Handler, query string, vars map[string]any) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query":     query,
		"variables": vars,
	})
	require.NoError(t, err)
	resp := postGraphQL(t, handler, body)
	require.Empty(t, resp.Errors, "graphql errors: %s", resp.Data)
	return resp
}

// postGraphQL is the lower-level POST that returns the response envelope
// without failing on errors. Used by tests that want to inspect the error
// shape (typed errors, codes, etc.). The package-level testBearer (set by
// the integration test's setup) is sent if non-empty so auth-gated
// resolvers see a principal.
func postGraphQL(t *testing.T, handler http.Handler, body []byte) gqlResponse {
	t.Helper()
	req := httptest.NewRequest(http.MethodPost, "/graphql", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	if testBearer != "" {
		req.Header.Set("Authorization", "Bearer "+testBearer)
	}
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)
	require.Equal(t, http.StatusOK, rr.Code, "graphql status: body=%s", rr.Body.String())
	var resp gqlResponse
	require.NoError(t, json.Unmarshal(rr.Body.Bytes(), &resp), "decode graphql response")
	return resp
}

// testBearer is set by individual integration tests (a process-wide global
// is acceptable here — the package's tests run serially by design when
// they share the bearer).
var testBearer string

func TestTaskCreateAndReadOverGraphQL(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))

	_ = q
	created, err := core.CreateTask(ctx, pool, nil, "hello", "")
	require.NoError(t, err)
	require.NotEqual(t, "", created.GlobalURI)

	// Phase 2+ wires the auth middleware on /graphql; viewer requires a
	// principal in context. Issue a session and pass it as a bearer.
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	_, raw, err := auth.IssueSession(ctx, q, owner.ID, "task_integration")
	require.NoError(t, err)
	prevBearer := testBearer
	testBearer = raw
	t.Cleanup(func() { testBearer = prevBearer })

	handler := server.New(pool, nil, server.Options{})

	// 1. viewer — the seeded owner Principal.
	viewerResp := graphqlRequest(t, handler,
		`{ viewer { id globalUri displayName } }`, nil)
	var viewerData struct {
		Viewer *struct {
			ID          string `json:"id"`
			GlobalURI   string `json:"globalUri"`
			DisplayName string `json:"displayName"`
		} `json:"viewer"`
	}
	require.NoError(t, json.Unmarshal(viewerResp.Data, &viewerData))
	require.NotNil(t, viewerData.Viewer)
	require.Equal(t, "local://principal/owner", viewerData.Viewer.GlobalURI)
	require.Equal(t, "Owner", viewerData.Viewer.DisplayName)

	// 2. task(id) — fetch the task we just created.
	taskResp := graphqlRequest(t, handler,
		`query($id: ID!){ task(id:$id){ id globalUri title state currentStage autonomy } }`,
		map[string]any{"id": created.ID.String()},
	)
	var taskData struct {
		Task *struct {
			ID           string `json:"id"`
			GlobalURI    string `json:"globalUri"`
			Title        string `json:"title"`
			State        string `json:"state"`
			CurrentStage string `json:"currentStage"`
			Autonomy     string `json:"autonomy"`
		} `json:"task"`
	}
	require.NoError(t, json.Unmarshal(taskResp.Data, &taskData))
	require.NotNil(t, taskData.Task)
	require.Equal(t, created.ID.String(), taskData.Task.ID)
	require.Equal(t, created.GlobalURI, taskData.Task.GlobalURI)
	require.Equal(t, "hello", taskData.Task.Title)
	require.Equal(t, "ACCEPTED", taskData.Task.State)
	require.Equal(t, "CREATION", taskData.Task.CurrentStage)
	require.Equal(t, "NONE", taskData.Task.Autonomy) // Phase 0 fixed default

	// 3. tasks — keyset connection with one edge.
	tasksResp := graphqlRequest(t, handler,
		`{ tasks(first: 10) { edges { node { id globalUri title state currentStage autonomy } cursor } pageInfo { hasNextPage endCursor } } }`,
		nil,
	)
	var tasksData struct {
		Tasks struct {
			Edges []struct {
				Cursor string `json:"cursor"`
				Node   struct {
					ID           string `json:"id"`
					GlobalURI    string `json:"globalUri"`
					Title        string `json:"title"`
					State        string `json:"state"`
					CurrentStage string `json:"currentStage"`
					Autonomy     string `json:"autonomy"`
				} `json:"node"`
			} `json:"edges"`
			PageInfo struct {
				HasNextPage bool    `json:"hasNextPage"`
				EndCursor   *string `json:"endCursor"`
			} `json:"pageInfo"`
		} `json:"tasks"`
	}
	require.NoError(t, json.Unmarshal(tasksResp.Data, &tasksData))
	require.Len(t, tasksData.Tasks.Edges, 1)
	edge := tasksData.Tasks.Edges[0]
	require.Equal(t, created.ID.String(), edge.Node.ID)
	require.NotEmpty(t, edge.Node.GlobalURI)
	require.Equal(t, "ACCEPTED", edge.Node.State)
	require.Equal(t, "CREATION", edge.Node.CurrentStage)
	require.Equal(t, "NONE", edge.Node.Autonomy)
	require.NotEmpty(t, edge.Cursor)
	require.False(t, tasksData.Tasks.PageInfo.HasNextPage)
	require.NotNil(t, tasksData.Tasks.PageInfo.EndCursor)
	require.Equal(t, edge.Cursor, *tasksData.Tasks.PageInfo.EndCursor)
}

// TestTaskMetadataOverGraphQL exercises the owner-set priority + due-date
// metadata: create a task carrying both (via core, since the createTask
// mutation needs a live DBOS), read them back, then updateTaskMetadata to
// change priority and clear the deadline.
//
// Not parallel: it shares the package-level testBearer with the other
// integration test, so it runs in the sequential phase to avoid a race.
func TestTaskMetadataOverGraphQL(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()

	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))

	due := time.Date(2030, 1, 2, 15, 4, 5, 0, time.UTC)
	created, err := core.CreateTaskWithMeta(ctx, pool, nil, "with-meta", "", db.TaskPriorityHigh, &due)
	require.NoError(t, err)
	id := created.ID.String()

	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	_, raw, err := auth.IssueSession(ctx, q, owner.ID, "task_metadata_integration")
	require.NoError(t, err)
	prevBearer := testBearer
	testBearer = raw
	t.Cleanup(func() { testBearer = prevBearer })

	handler := server.New(pool, nil, server.Options{})

	type taskMeta struct {
		ID       string  `json:"id"`
		Priority string  `json:"priority"`
		DueAt    *string `json:"dueAt"`
	}

	// 1. Read back the created metadata: HIGH priority + a deadline.
	initResp := graphqlRequest(t, handler,
		`query($id:ID!){ task(id:$id){ id priority dueAt } }`,
		map[string]any{"id": id},
	)
	var initData struct {
		Task taskMeta `json:"task"`
	}
	require.NoError(t, json.Unmarshal(initResp.Data, &initData))
	require.Equal(t, "HIGH", initData.Task.Priority)
	require.NotNil(t, initData.Task.DueAt, "deadline should be set")

	// 2. updateTaskMetadata → LOW, clear the deadline (dueAt omitted = null).
	updateResp := graphqlRequest(t, handler,
		`mutation($id:ID!,$p:TaskPriority!){ updateTaskMetadata(taskId:$id, priority:$p){ id priority dueAt } }`,
		map[string]any{"id": id, "p": "LOW"},
	)
	var updateData struct {
		UpdateTaskMetadata taskMeta `json:"updateTaskMetadata"`
	}
	require.NoError(t, json.Unmarshal(updateResp.Data, &updateData))
	require.Equal(t, id, updateData.UpdateTaskMetadata.ID)
	require.Equal(t, "LOW", updateData.UpdateTaskMetadata.Priority)
	require.Nil(t, updateData.UpdateTaskMetadata.DueAt, "deadline should be cleared")

	// 3. Read it back to confirm the update persisted.
	readResp := graphqlRequest(t, handler,
		`query($id:ID!){ task(id:$id){ id priority dueAt } }`,
		map[string]any{"id": id},
	)
	var readData struct {
		Task taskMeta `json:"task"`
	}
	require.NoError(t, json.Unmarshal(readResp.Data, &readData))
	require.Equal(t, "LOW", readData.Task.Priority)
	require.Nil(t, readData.Task.DueAt)
}
