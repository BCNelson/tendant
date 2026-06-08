// Package llm is tendant's single transport seam to model APIs. It collapses
// the previously-duplicated per-provider HTTP (one copy in internal/overseer,
// another in internal/agent) into one Client interface with one implementation
// per upstream protocol: OpenAI-compatible, Anthropic Messages, Google Gemini,
// and AWS Bedrock (Anthropic-family models, signed with stdlib SigV4).
//
// The package is deliberately stdlib-only (net/http + crypto for SigV4): the
// overseer providers were written without an SDK on purpose, and consolidating
// here preserves that "no model SDK" property.
//
// Higher layers do NOT speak HTTP. internal/overseer wraps a Client to produce
// its structured Provider verdicts; internal/agent wraps a Client to drive its
// multi-turn AgentModelClient. A Registry holds many named Connections so an
// operator can configure several endpoints of the same protocol (e.g. two
// OpenAI-compatible backends) and reference each by name.
package llm

import (
	"context"
	"errors"
)

// ErrTransient is the sentinel wrapped by Client implementations for errors a
// caller should treat as a transient outage (network failure, 5xx, timeout,
// malformed body). Callers fail-closed on any error; this sentinel lets them
// distinguish transient from structural problems in their own audit reasoning.
// internal/overseer re-wraps it as overseer.ErrProviderTransient.
var ErrTransient = errors.New("llm: transient provider error")

// Client is one configured connection to a model API. Implementations are
// safe for concurrent use. A Client is bound to a provider + default model at
// construction; Request.Model overrides the default per call.
type Client interface {
	// Provider returns the canonical protocol name ("openai" | "anthropic" |
	// "gemini" | "bedrock" | "log"), written into audit and used for cost
	// lookups by callers.
	Provider() string

	// Model returns the default model identifier for this connection.
	Model() string

	// Chat dispatches one inference turn. When Request.ForceTool is set,
	// implementations force the model to emit a tool call with that name
	// (the structured-output path the overseer relies on). Errors that
	// should be treated as transient MUST wrap ErrTransient.
	Chat(ctx context.Context, req Request) (Response, error)
}

// Request is a single inference turn. It is protocol-neutral; each Client maps
// the fields onto its upstream wire format.
type Request struct {
	// Model overrides the connection's default model when non-empty.
	Model string
	// System is the system prompt / preamble.
	System string
	// Messages is the conversation so far (oldest first).
	Messages []Message
	// Tools are the tool/function declarations exposed to the model.
	Tools []Tool
	// ForceTool, when non-empty, forces the model to call exactly that tool
	// (used for structured output). Empty ⇒ tool use is optional.
	ForceTool string
	// MaxTokens caps the response; 0 ⇒ the Client's per-provider default.
	MaxTokens int
}

// Message is one turn in the conversation. Role is "user", "assistant", or
// "tool_result"; Clients map these onto provider-native roles.
type Message struct {
	Role    string
	Content string
}

// Tool describes one tool/function the model may call.
type Tool struct {
	Name        string
	Description string
	// Schema is the JSON-Schema object for the tool's parameters. nil is
	// allowed (declares a no-parameter tool).
	Schema map[string]any
}

// ToolCall is a tool invocation the model emitted.
type ToolCall struct {
	ID        string
	Name      string
	Arguments string // raw JSON object as produced by the model
}

// Response is the model's reply to a Request.
type Response struct {
	Content   string
	ToolCalls []ToolCall
	Model     string
	TokensIn  int
	TokensOut int
}

// firstNonEmpty returns a if non-empty, else b. Shared helper across Clients.
func firstNonEmpty(a, b string) string {
	if a != "" {
		return a
	}
	return b
}
