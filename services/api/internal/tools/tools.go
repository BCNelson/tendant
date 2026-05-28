// Package tools is the MCP-style action edge: every outward capability the
// system has lives behind a Tool implementation. Core never speaks SMTP,
// HTTP, or any provider protocol directly — that hygiene is what lets the
// gate (internal/gate) be the sole policy point.
//
// Phase 3 ships one tool (send-email) and a tiny registry. Phase 4+ will
// add more tools and the overseer layer that composes calls on the agent's
// behalf; the Tool interface won't change.
package tools

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
)

// Result is what a Tool returns to the gate / workflow after a successful
// dispatch. Provider identifies which backend handled the call (so the
// audit row can name it); Detail is provider-specific metadata.
type Result struct {
	Provider string          `json:"provider"`
	Detail   json.RawMessage `json:"detail,omitempty"`
}

// Tool is the action-edge abstraction. Implementations are responsible for
// validating their own payload shape — the gate is policy, not parsing.
type Tool interface {
	// GlobalURI is the stable key used in the `tools.global_uri` column and
	// in the `proposeToolCall(toolGlobalUri:)` mutation argument.
	GlobalURI() string

	// Execute dispatches the call. The payload is the frozen ApprovalRequest
	// payload — byte-for-byte identical to what the human approved.
	Execute(ctx context.Context, payload json.RawMessage) (Result, error)
}

// Registry maps global_uri → Tool. Tools register at boot; lookups are
// read-only thereafter. Thread-safe.
type Registry struct {
	mu sync.RWMutex
	m  map[string]Tool
}

// NewRegistry returns an empty registry.
func NewRegistry() *Registry {
	return &Registry{m: make(map[string]Tool)}
}

// Register adds a tool. Subsequent registrations under the same URI replace
// the prior one (idempotent for restart).
func (r *Registry) Register(t Tool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.m[t.GlobalURI()] = t
}

// ByGlobalURI returns the registered tool, or (nil, false) if the URI is
// unknown. Callers should surface a TOOL_UNKNOWN error to clients.
func (r *Registry) ByGlobalURI(uri string) (Tool, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	t, ok := r.m[uri]
	return t, ok
}

// Execute is a convenience wrapper that looks up + dispatches in one call.
// Returns ErrUnknownTool if the registry doesn't have the URI.
func (r *Registry) Execute(ctx context.Context, uri string, payload json.RawMessage) (Result, error) {
	t, ok := r.ByGlobalURI(uri)
	if !ok {
		return Result{}, fmt.Errorf("%w: %s", ErrUnknownTool, uri)
	}
	return t.Execute(ctx, payload)
}

// ErrUnknownTool is returned when a global_uri does not match any
// registered tool. Resolvers should map this to a TOOL_UNKNOWN GraphQL
// error code.
var ErrUnknownTool = fmt.Errorf("tools: unknown tool")
