package llm

import (
	"context"
	"log/slog"
	"sync/atomic"
)

// logClient is the deterministic, no-network Client used as the default for a
// connection whose provider is "log" (and as a generic test seam). It echoes a
// forced tool call when one is requested (empty-args), otherwise returns empty
// content. Consumer-specific deterministic stubs (overseer.LogProvider,
// agent.LogAgentClient) remain in their own packages — they encode
// consumer-shaped output that a transport-level stub cannot know.
type logClient struct {
	model string
	calls atomic.Int64
}

func newLogClient(conn Connection) *logClient {
	return &logClient{model: firstNonEmpty(conn.Model, "log")}
}

func (c *logClient) Provider() string { return "log" }
func (c *logClient) Model() string    { return c.model }

func (c *logClient) Chat(ctx context.Context, req Request) (Response, error) {
	n := c.calls.Add(1)
	slog.DebugContext(ctx, "llm.logClient.Chat",
		"model", firstNonEmpty(req.Model, c.model),
		"messages", len(req.Messages),
		"tools", len(req.Tools),
		"force_tool", req.ForceTool,
		"call", n,
	)
	out := Response{Model: firstNonEmpty(req.Model, c.model), TokensIn: 10, TokensOut: 5}
	if req.ForceTool != "" {
		out.ToolCalls = []ToolCall{{Name: req.ForceTool, Arguments: "{}"}}
	}
	return out, nil
}
