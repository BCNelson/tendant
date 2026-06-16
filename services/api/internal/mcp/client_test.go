package mcp

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
)

// fakeMCP is a minimal in-memory Streamable-HTTP MCP server for tests. It speaks
// just enough of the protocol: initialize (assigns a session id), tools/list
// (optionally paginated), and tools/call. Behaviour is tweakable per-test.
type fakeMCP struct {
	t *testing.T

	mu         sync.Mutex
	sessionID  string
	initCount  int
	pages      [][]ToolDescriptor // tools/list pages; cursor walks the slice
	sse        bool               // answer requests with text/event-stream
	expireOnce bool               // 404 the next session-bearing request once
	expired    bool

	callResult CallResult
	callErr    *rpcError
	lastCall   struct {
		name string
		args json.RawMessage
		meta map[string]any
	}
}

func (f *fakeMCP) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	body, _ := io.ReadAll(r.Body)
	var req rpcRequest
	if err := json.Unmarshal(body, &req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	f.mu.Lock()
	defer f.mu.Unlock()

	// Session expiry simulation: 404 the first real operation after the
	// handshake, forcing the client to re-initialize and retry.
	if req.Method == "tools/call" && f.expireOnce && !f.expired {
		f.expired = true
		w.WriteHeader(http.StatusNotFound)
		return
	}

	switch req.Method {
	case "initialize":
		f.initCount++
		f.sessionID = "sess-" + itoa(f.initCount)
		w.Header().Set("Mcp-Session-Id", f.sessionID)
		f.writeResult(w, req, map[string]any{
			"protocolVersion": ProtocolVersion,
			"capabilities":    map[string]any{"tools": map[string]any{}},
			"serverInfo":      map[string]any{"name": "fake", "version": "1"},
		})
	case "notifications/initialized":
		w.WriteHeader(http.StatusAccepted)
	case "tools/list":
		idx := 0
		if req.Params != nil {
			if m, ok := req.Params.(map[string]any); ok {
				if c, ok := m["cursor"].(string); ok {
					idx = atoi(c)
				}
			}
		}
		var page []ToolDescriptor
		if idx < len(f.pages) {
			page = f.pages[idx]
		}
		result := map[string]any{"tools": page}
		if idx+1 < len(f.pages) {
			result["nextCursor"] = itoa(idx + 1)
		}
		f.writeResult(w, req, result)
	case "tools/call":
		m, _ := req.Params.(map[string]any)
		f.lastCall.name, _ = m["name"].(string)
		if a, ok := m["arguments"]; ok {
			f.lastCall.args, _ = json.Marshal(a)
		}
		if meta, ok := m["_meta"].(map[string]any); ok {
			f.lastCall.meta = meta
		}
		if f.callErr != nil {
			f.writeError(w, req, f.callErr)
			return
		}
		f.writeResult(w, req, f.callResult)
	default:
		f.writeError(w, req, &rpcError{Code: -32601, Message: "method not found"})
	}
}

func (f *fakeMCP) writeResult(w http.ResponseWriter, req rpcRequest, result any) {
	raw, _ := json.Marshal(result)
	resp := rpcResponse{JSONRPC: "2.0", Result: raw}
	if req.ID != nil {
		resp.ID = json.RawMessage(itoa(*req.ID))
	}
	f.write(w, resp)
}

func (f *fakeMCP) writeError(w http.ResponseWriter, req rpcRequest, e *rpcError) {
	resp := rpcResponse{JSONRPC: "2.0", Error: e}
	if req.ID != nil {
		resp.ID = json.RawMessage(itoa(*req.ID))
	}
	f.write(w, resp)
}

func (f *fakeMCP) write(w http.ResponseWriter, resp rpcResponse) {
	payload, _ := json.Marshal(resp)
	if f.sse {
		w.Header().Set("Content-Type", "text/event-stream")
		w.WriteHeader(http.StatusOK)
		// Interleave an unrelated server notification before the real response to
		// exercise the SSE skip path.
		_, _ = fmt.Fprintf(w, "event: message\ndata: {\"jsonrpc\":\"2.0\",\"method\":\"notifications/progress\",\"params\":{}}\n\n")
		_, _ = fmt.Fprintf(w, "data: %s\n\n", payload)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(payload)
}

func itoa(i int) string { return fmt.Sprintf("%d", i) }
func atoi(s string) int {
	n := 0
	for _, c := range s {
		if c < '0' || c > '9' {
			return 0
		}
		n = n*10 + int(c-'0')
	}
	return n
}

func newFakeServer(t *testing.T, f *fakeMCP) *Client {
	t.Helper()
	f.t = t
	srv := httptest.NewServer(f)
	t.Cleanup(srv.Close)
	return NewClient(srv.URL, Auth{Header: "Authorization", Value: "Bearer test"}, srv.Client())
}

func TestClientListTools_Paginated(t *testing.T) {
	f := &fakeMCP{
		pages: [][]ToolDescriptor{
			{{Name: "send_email", Description: "send an email"}},
			{{Name: "create_event"}},
		},
	}
	c := newFakeServer(t, f)
	tools, err := c.ListTools(context.Background())
	if err != nil {
		t.Fatalf("ListTools: %v", err)
	}
	if len(tools) != 2 {
		t.Fatalf("want 2 tools across 2 pages, got %d", len(tools))
	}
	if tools[0].Name != "send_email" || tools[1].Name != "create_event" {
		t.Fatalf("unexpected tools: %+v", tools)
	}
	if f.initCount != 1 {
		t.Fatalf("want exactly one initialize handshake, got %d", f.initCount)
	}
	if got := c.NegotiatedVersion(); got != ProtocolVersion {
		t.Fatalf("negotiated version = %q, want %q", got, ProtocolVersion)
	}
}

func TestClientCallTool_SuccessForwardsArgsAndMeta(t *testing.T) {
	f := &fakeMCP{callResult: CallResult{Content: json.RawMessage(`[{"type":"text","text":"ok"}]`)}}
	c := newFakeServer(t, f)
	args := json.RawMessage(`{"to":"a@b.com"}`)
	res, err := c.CallTool(context.Background(), "send_email", args, map[string]any{"tendant/idempotency_key": "dec-1"})
	if err != nil {
		t.Fatalf("CallTool: %v", err)
	}
	if res.IsError {
		t.Fatalf("unexpected isError")
	}
	if f.lastCall.name != "send_email" {
		t.Fatalf("upstream name = %q", f.lastCall.name)
	}
	if !strings.Contains(string(f.lastCall.args), "a@b.com") {
		t.Fatalf("args not forwarded: %s", f.lastCall.args)
	}
	if f.lastCall.meta["tendant/idempotency_key"] != "dec-1" {
		t.Fatalf("idempotency key not forwarded as _meta: %+v", f.lastCall.meta)
	}
}

func TestClientCallTool_IsErrorResult(t *testing.T) {
	f := &fakeMCP{callResult: CallResult{IsError: true, Content: json.RawMessage(`[{"type":"text","text":"boom"}]`)}}
	c := newFakeServer(t, f)
	res, err := c.CallTool(context.Background(), "send_email", json.RawMessage(`{}`), nil)
	if err != nil {
		t.Fatalf("CallTool transport error: %v", err)
	}
	if !res.IsError {
		t.Fatalf("want isError=true result")
	}
}

func TestClientCallTool_RPCError(t *testing.T) {
	f := &fakeMCP{callErr: &rpcError{Code: -32000, Message: "nope"}}
	c := newFakeServer(t, f)
	if _, err := c.CallTool(context.Background(), "x", json.RawMessage(`{}`), nil); err == nil {
		t.Fatalf("want an error for a JSON-RPC error response")
	}
}

func TestClientSSEResponse(t *testing.T) {
	f := &fakeMCP{sse: true, pages: [][]ToolDescriptor{{{Name: "t1"}}}}
	c := newFakeServer(t, f)
	tools, err := c.ListTools(context.Background())
	if err != nil {
		t.Fatalf("ListTools over SSE: %v", err)
	}
	if len(tools) != 1 || tools[0].Name != "t1" {
		t.Fatalf("unexpected tools over SSE: %+v", tools)
	}
}

func TestClientSessionExpiryReinitializes(t *testing.T) {
	f := &fakeMCP{expireOnce: true, callResult: CallResult{Content: json.RawMessage(`[]`)}}
	c := newFakeServer(t, f)
	// First call: initialize (1) → tools/call 404s once → re-initialize (2) → retry succeeds.
	if _, err := c.CallTool(context.Background(), "x", json.RawMessage(`{}`), nil); err != nil {
		t.Fatalf("CallTool after expiry: %v", err)
	}
	if f.initCount != 2 {
		t.Fatalf("want 2 initialize handshakes (initial + re-init), got %d", f.initCount)
	}
}
