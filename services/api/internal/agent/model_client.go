package agent

import (
	"context"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/llm"
)

// AgentModelClient is the multi-turn tool-use interface for the agent runner.
// Implementations wrap the same Provider HTTP infrastructure (Anthropic, OpenAI)
// with conversation-aware message handling. The LogAgentClient provides
// deterministic scripted responses for CI tests.
type AgentModelClient interface {
	Chat(ctx context.Context, req ChatRequest) (ChatResponse, error)
}

// ChatRequest is a single inference turn sent to the model.
type ChatRequest struct {
	Model    string    // model ID (e.g. "claude-sonnet-4-20250514")
	System   string    // agent's system prompt from AgentConfig
	Messages []Message // accumulated conversation history
	Tools    []ToolDef // only the allowlisted tools
	// ForceTool, when set, names a tool the model MUST call this turn (tool_choice).
	// Used by the conversational structured-output path (Runner.Converse) to force
	// a single structured answer; empty for the autonomous plan→act→observe loop.
	ForceTool string
	// ResponseFormat, when "json_object", asks the provider for a JSON object reply
	// so OpenAI-compatible endpoints that ignore tool_choice still emit decodable
	// structured output. Empty for the free-form loop.
	ResponseFormat string
	// MaxTokens caps the reply length; 0 ⇒ the provider/connection default.
	MaxTokens int
}

// ChatResponse is the model's reply to a ChatRequest.
type ChatResponse struct {
	Content   string     // assistant text output
	ToolCalls []ToolCall // tool_use blocks proposed by the model
	TokensIn  int
	TokensOut int
}

// Message represents one turn in the conversation.
type Message struct {
	Role    string // "user", "assistant", "tool_result"
	Content string // text content (or JSON for tool results)
}

// ToolDef describes a tool exposed to the model.
type ToolDef struct {
	Name        string // tool name (from tools.name)
	GlobalURI   string // tool global URI
	Description string // human-readable description
	Schema      string // JSON schema for the tool's input parameters
}

// ToolCall is a tool invocation proposed by the model.
type ToolCall struct {
	ID      string // model-assigned call ID
	Name    string // tool name
	Payload string // JSON payload for the tool
}

// NewAgentModelClient creates a client for a simple (provider, apiKey, model)
// triple. Real providers ("anthropic", "openai", "gemini") delegate transport
// to internal/llm; anything else (including "log" and the empty string) returns
// the deterministic LogAgentClient. Providers that need more than an API key
// (e.g. bedrock) are only reachable via NewAgentClientFromConnection.
func NewAgentModelClient(provider, apiKey, modelID string) AgentModelClient {
	switch provider {
	case "anthropic", "openai", "gemini":
		client, err := llm.NewClient(llm.Connection{Provider: provider, APIKey: apiKey, Model: modelID})
		if err != nil {
			return &LogAgentClient{}
		}
		return NewLLMAgentClient(client)
	default:
		return &LogAgentClient{}
	}
}

// NewAgentClientFromConnection builds an AgentModelClient from a fully-specified
// llm.Connection (the registry path), supporting every provider including
// bedrock. An unknown provider falls back to the deterministic LogAgentClient.
func NewAgentClientFromConnection(conn llm.Connection) (AgentModelClient, error) {
	if conn.Provider == "log" || conn.Provider == "" {
		return &LogAgentClient{}, nil
	}
	client, err := llm.NewClient(conn)
	if err != nil {
		return nil, fmt.Errorf("agent: build model client for %q: %w", conn.Name, err)
	}
	return NewLLMAgentClient(client), nil
}
