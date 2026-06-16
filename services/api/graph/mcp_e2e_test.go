package graph_test

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/mcp"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// fakeMCPServer is a minimal Streamable-HTTP MCP server for the e2e: it speaks
// initialize / initialized / tools/list / tools/call. toolNames controls what
// tools/list advertises (so a re-sync can drop a tool); calls records the
// arguments of every tools/call.
type fakeMCPServer struct {
	mu        sync.Mutex
	toolNames []string
	calls     []json.RawMessage
}

func (f *fakeMCPServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	body, _ := io.ReadAll(r.Body)
	var req struct {
		ID     *int           `json:"id"`
		Method string         `json:"method"`
		Params map[string]any `json:"params"`
	}
	_ = json.Unmarshal(body, &req)

	writeResult := func(result any) {
		raw, _ := json.Marshal(result)
		resp := map[string]any{"jsonrpc": "2.0", "result": json.RawMessage(raw)}
		if req.ID != nil {
			resp["id"] = *req.ID
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(resp)
	}

	switch req.Method {
	case "initialize":
		w.Header().Set("Mcp-Session-Id", "sess-1")
		writeResult(map[string]any{"protocolVersion": mcp.ProtocolVersion, "capabilities": map[string]any{}})
	case "notifications/initialized":
		w.WriteHeader(http.StatusAccepted)
	case "tools/list":
		f.mu.Lock()
		names := append([]string(nil), f.toolNames...)
		f.mu.Unlock()
		toolList := make([]map[string]any, 0, len(names))
		for _, n := range names {
			toolList = append(toolList, map[string]any{
				"name":        n,
				"description": "fake " + n,
				"inputSchema": map[string]any{"type": "object"},
			})
		}
		writeResult(map[string]any{"tools": toolList})
	case "tools/call":
		f.mu.Lock()
		if args, ok := req.Params["arguments"]; ok {
			raw, _ := json.Marshal(args)
			f.calls = append(f.calls, raw)
		}
		f.mu.Unlock()
		writeResult(map[string]any{"content": []map[string]any{{"type": "text", "text": "echoed"}}})
	default:
		w.WriteHeader(http.StatusBadRequest)
	}
}

func (f *fakeMCPServer) callCount() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return len(f.calls)
}

func (f *fakeMCPServer) setTools(names ...string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.toolNames = names
}

// mcpTestDeps builds the McpDeps wiring for the e2e, sharing the tool-call
// workflow's registry so dispatched MCP calls reach the adapter.
func mcpTestDeps(q *db.Queries, registry *tools.Registry) graph.McpDeps {
	pool := mcp.NewClientPool(nil, func(ctx context.Context, serverID uuid.UUID) (string, mcp.Auth, error) {
		s, err := q.GetMcpServer(ctx, serverID)
		if err != nil {
			return "", mcp.Auth{}, err
		}
		return s.EndpointUrl, mcp.Auth{}, nil
	})
	svc := mcp.NewService(q, registry, pool)
	return graph.McpDeps{
		SealAuth: func(context.Context, uuid.UUID, map[string]any) error { return nil },
		Sync: func(ctx context.Context, id uuid.UUID) (int, error) {
			r, e := svc.Sync(ctx, id)
			return r.Discovered, e
		},
		Disable:          svc.Forget,
		InvalidateClient: pool.Forget,
	}
}

func registerMcpServerGQL(t *testing.T, env *chainEnv, slug, name, endpoint string) uuid.UUID {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($s: String!, $n: String!, $e: String!) {
		   registerMcpServer(slug: $s, name: $n, endpointUrl: $e) { id slug enabled }
		 }`,
		map[string]any{"s": slug, "n": name, "e": endpoint},
	)
	var data struct {
		RegisterMcpServer struct {
			ID string `json:"id"`
		} `json:"registerMcpServer"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	id, err := uuid.Parse(data.RegisterMcpServer.ID)
	require.NoError(t, err)
	return id
}

func enableMcpServerGQL(t *testing.T, env *chainEnv, id uuid.UUID, enabled bool) json.RawMessage {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $e: Boolean!) {
		   enableMcpServer(serverId: $id, enabled: $e) { id enabled status toolCount }
		 }`,
		map[string]any{"id": id.String(), "e": enabled},
	)
	return resp.Data
}

func syncMcpServerGQL(t *testing.T, env *chainEnv, id uuid.UUID) json.RawMessage {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!) { syncMcpServer(serverId: $id) { id toolCount status } }`,
		map[string]any{"id": id.String()},
	)
	return resp.Data
}

// TestMCP_RegisterSyncProposeApproveDispatch is the full client-edge loop: an
// owner registers + enables a fake MCP server; its tool is discovered fail-closed
// (the floor gates every call); a proposeToolCall on it requests a decision;
// approving it dispatches an upstream tools/call and records a clean outcome.
func TestMCP_RegisterSyncProposeApproveDispatch(t *testing.T) {
	ctx := context.Background()
	fake := &fakeMCPServer{toolNames: []string{"echo"}}
	srv := httptest.NewServer(fake)
	t.Cleanup(srv.Close)

	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(nil))
	env := newChainEnv(t, withToolRegistry(registry), withMcp(mcpTestDeps))

	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	// Register + enable (enable runs the first sync).
	serverID := registerMcpServerGQL(t, env, "fakemcp", "Fake MCP", srv.URL)
	data := enableMcpServerGQL(t, env, serverID, true)
	require.Contains(t, string(data), `"toolCount":1`)
	require.Contains(t, string(data), `"status":"ok"`)

	// The discovered tool exists, fail-closed (irreversible_third_party=always).
	globalURI := "tendant://mcp/fakemcp/echo"
	toolRow, err := env.queries.GetToolByGlobalURI(ctx, globalURI)
	require.NoError(t, err)
	require.True(t, toolRow.McpServerID.Valid, "tool must be linked to its server")
	var perms map[string]any
	require.NoError(t, json.Unmarshal(toolRow.Permissions, &perms))
	require.Equal(t, "always", perms["irreversible_third_party"], "discovered MCP tools must land fail-closed")

	// The adapter is registered in the shared registry.
	require.True(t, registry.Has(globalURI), "adapter must be registered after sync")

	// Drive a task to EXECUTION and propose the MCP tool. The floor trips → a
	// decision is requested (nothing auto-dispatches).
	taskID := createTaskGQL(t, env, "use the echo mcp tool")
	walkToExecution(t, env, taskID)
	decisionID := proposeToolCallGQL(t, env, taskID, globalURI, map[string]any{"message": "hi"})

	row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.Equal(t, db.DecisionKindApprovalRequest, row.Kind)
	require.False(t, row.ResolvedAt.Valid, "MCP tool call must gate before dispatch")

	// Approve → the upstream tools/call fires exactly once, clean outcome.
	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)

	require.Equal(t, 1, fake.callCount(), "exactly one upstream tools/call")
	require.Contains(t, string(fake.calls[0]), "hi", "frozen payload forwarded as call arguments")

	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, n)
}

// TestMCP_OwnerGuard confirms every MCP mutation/query is owner-only, rejected
// before any DB write.
func TestMCP_OwnerGuard(t *testing.T) {
	env := newChainEnv(t, withMcp(mcpTestDeps))
	bearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($s: String!, $n: String!, $e: String!) {
		   registerMcpServer(slug: $s, name: $n, endpointUrl: $e) { id }
		 }`,
		map[string]any{"s": "x", "n": "x", "e": "http://localhost"},
	)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, errs))

	errs = graphqlRequestExpectError(t, env.handler, `query { mcpServers { id } }`, nil)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, errs))

	// No server row was created (rejected before any DB write).
	var count int
	require.NoError(t, env.pool.QueryRow(context.Background(), `SELECT count(*) FROM mcp_servers`).Scan(&count))
	require.Equal(t, 0, count)
}

// TestMCP_ResyncRetiresVanishedTool confirms a tool the server no longer
// advertises is retired + deregistered, and a later propose returns TOOL_RETIRED.
func TestMCP_ResyncRetiresVanishedTool(t *testing.T) {
	ctx := context.Background()
	fake := &fakeMCPServer{toolNames: []string{"echo"}}
	srv := httptest.NewServer(fake)
	t.Cleanup(srv.Close)

	registry := tools.NewRegistry()
	env := newChainEnv(t, withToolRegistry(registry), withMcp(mcpTestDeps))
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	serverID := registerMcpServerGQL(t, env, "fakemcp", "Fake MCP", srv.URL)
	enableMcpServerGQL(t, env, serverID, true)
	globalURI := "tendant://mcp/fakemcp/echo"
	require.True(t, registry.Has(globalURI))

	// Upstream drops the tool; re-sync retires it.
	fake.setTools()
	data := syncMcpServerGQL(t, env, serverID)
	require.Contains(t, string(data), `"toolCount":0`)
	require.False(t, registry.Has(globalURI), "adapter must be deregistered after retirement")

	retired, err := env.queries.GetToolByGlobalURI(ctx, globalURI)
	require.NoError(t, err)
	require.True(t, retired.RetiredAt.Valid, "vanished tool must be retired")

	// A propose against the retired tool is rejected up front.
	taskID := createTaskGQL(t, env, "use a retired tool")
	walkToExecution(t, env, taskID)
	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($id: ID!, $u: String!, $p: JSON!) {
		   proposeToolCall(taskId: $id, toolGlobalUri: $u, payload: $p) { id }
		 }`,
		map[string]any{"id": taskID.String(), "u": globalURI, "p": map[string]any{}},
	)
	require.Equal(t, "TOOL_RETIRED", errorCode(t, errs))
}
