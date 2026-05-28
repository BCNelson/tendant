package graph_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

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
// shape (typed errors, codes, etc.).
func postGraphQL(t *testing.T, handler http.Handler, body []byte) gqlResponse {
	t.Helper()
	req := httptest.NewRequest(http.MethodPost, "/graphql", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)
	require.Equal(t, http.StatusOK, rr.Code, "graphql status: body=%s", rr.Body.String())
	var resp gqlResponse
	require.NoError(t, json.Unmarshal(rr.Body.Bytes(), &resp), "decode graphql response")
	return resp
}

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

	handler := server.New(pool, nil)

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
