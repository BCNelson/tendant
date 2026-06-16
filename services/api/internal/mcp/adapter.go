package mcp

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// ServerLoader resolves the connection details for a server id: its endpoint URL
// and the (decrypted) auth to present. The pool calls it lazily on first use and
// after a Forget. Implemented over the DB + sealed credential store (see
// credentials.go); injected so this package has no direct DB dependency in the
// adapter path.
type ServerLoader func(ctx context.Context, serverID uuid.UUID) (endpoint string, auth Auth, err error)

// ClientPool memoizes one *Client per server id. Clients are cheap (a struct +
// shared *http.Client) but hold a live MCP session, so reusing them avoids a
// fresh initialize handshake on every tool call. Safe for concurrent use.
type ClientPool struct {
	http *http.Client
	load ServerLoader

	mu    sync.Mutex
	cache map[uuid.UUID]*Client
}

// NewClientPool builds a pool. A nil httpClient uses http.DefaultClient.
func NewClientPool(httpClient *http.Client, load ServerLoader) *ClientPool {
	if httpClient == nil {
		httpClient = http.DefaultClient
	}
	return &ClientPool{http: httpClient, load: load, cache: make(map[uuid.UUID]*Client)}
}

// Get returns the cached client for a server, building it (endpoint + auth via
// the loader) on first use.
func (p *ClientPool) Get(ctx context.Context, serverID uuid.UUID) (*Client, error) {
	p.mu.Lock()
	if c, ok := p.cache[serverID]; ok {
		p.mu.Unlock()
		return c, nil
	}
	p.mu.Unlock()

	endpoint, auth, err := p.load(ctx, serverID)
	if err != nil {
		return nil, fmt.Errorf("mcp: load server %s: %w", serverID, err)
	}
	c := NewClient(endpoint, auth, p.http)

	p.mu.Lock()
	defer p.mu.Unlock()
	// Re-check: another goroutine may have built it while we loaded.
	if existing, ok := p.cache[serverID]; ok {
		return existing, nil
	}
	p.cache[serverID] = c
	return c, nil
}

// Forget drops the cached client for a server (on reconfigure / disable / remove)
// so the next Get rebuilds it with fresh endpoint + auth.
func (p *ClientPool) Forget(serverID uuid.UUID) {
	p.mu.Lock()
	defer p.mu.Unlock()
	delete(p.cache, serverID)
}

// MCPTool adapts one upstream MCP tool to the tools.Tool interface. Execute
// dispatches a tools/call to the server; the frozen tendant payload is forwarded
// verbatim as the call arguments.
type MCPTool struct {
	globalURI    string
	serverID     uuid.UUID
	upstreamName string
	provider     string // audit label, e.g. "mcp:my-server"
	pool         *ClientPool
}

// NewMCPTool builds an adapter. provider is the audit-row label (Result.Provider).
func NewMCPTool(globalURI string, serverID uuid.UUID, upstreamName, provider string, pool *ClientPool) *MCPTool {
	return &MCPTool{globalURI: globalURI, serverID: serverID, upstreamName: upstreamName, provider: provider, pool: pool}
}

// GlobalURI satisfies tools.Tool.
func (t *MCPTool) GlobalURI() string { return t.globalURI }

// Idempotent always reports false: an upstream tools/call is a real side effect
// and the server's idempotentHint annotation is untrusted, so the call must
// route through the tool-call workflow's at-most-once dispatch guard
// (DecisionAlreadyDispatched). The decision-id idempotency key is still forwarded
// upstream as _meta so a server that honors it can dedup on its side.
func (t *MCPTool) Idempotent(_ context.Context, _ json.RawMessage) bool { return false }

// Execute dispatches the frozen payload to the upstream tool. A transport or
// protocol failure, or an upstream isError result, surfaces as an error → the
// workflow records a bad outcome (feeding the Phase-8 calibration ratchet).
func (t *MCPTool) Execute(ctx context.Context, payload json.RawMessage) (tools.Result, error) {
	client, err := t.pool.Get(ctx, t.serverID)
	if err != nil {
		return tools.Result{}, err
	}
	meta := map[string]any{}
	if key := tools.IdempotencyKey(ctx); key != "" {
		meta["tendant/idempotency_key"] = key
	}
	res, err := client.CallTool(ctx, t.upstreamName, payload, meta)
	if err != nil {
		return tools.Result{}, err
	}
	detail := res.Content
	if len(res.StructuredContent) > 0 {
		detail = res.StructuredContent
	}
	if res.IsError {
		return tools.Result{Provider: t.provider, Detail: detail},
			fmt.Errorf("mcp tool %q returned an error result", t.upstreamName)
	}
	return tools.Result{Provider: t.provider, Detail: detail}, nil
}

// Compile-time assertion that MCPTool satisfies the action-edge interface.
var _ tools.Tool = (*MCPTool)(nil)
