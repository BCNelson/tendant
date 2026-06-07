package agent

import "context"

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

// NewAgentModelClient creates the appropriate client based on provider name.
// Supported: "log" (deterministic), "anthropic", "openai".
func NewAgentModelClient(provider, apiKey, modelID string) AgentModelClient {
	switch provider {
	case "anthropic":
		return &AnthropicClient{APIKey: apiKey, DefaultModel: modelID}
	case "openai":
		return &OpenAIClient{APIKey: apiKey, DefaultModel: modelID}
	default:
		return &LogAgentClient{}
	}
}
