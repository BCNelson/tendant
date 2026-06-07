package agent

import (
	"context"
	"encoding/json"
	"log/slog"
)

// LogAgentClient is the deterministic test/dev client. It returns scripted
// responses from Fixtures. When Fixtures is empty, it returns a StageResult
// immediately (no tool calls). This is the default when TENDANT_OVERSEER_PROVIDER=log.
type LogAgentClient struct {
	// Fixtures is a queue of scripted responses. Each Chat call pops the next.
	// When empty, a default "done" response is returned.
	Fixtures []ChatResponse
	calls    int
}

// Chat returns the next scripted fixture or a default completion response.
func (c *LogAgentClient) Chat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	slog.DebugContext(ctx, "LogAgentClient.Chat",
		"model", req.Model,
		"messages", len(req.Messages),
		"tools", len(req.Tools),
		"call_num", c.calls,
	)
	c.calls++

	if len(c.Fixtures) > 0 {
		resp := c.Fixtures[0]
		c.Fixtures = c.Fixtures[1:]
		return resp, nil
	}

	// Default: return a StageResult with minimal findings, no tool calls.
	findings := Findings{
		Structured: StructuredFindings{
			CategoryHints:        []string{"general"},
			StakesScore:          1,
			RequiredCapabilities: []string{},
		},
		FreeText: "Task processed by LogAgentClient (deterministic).",
	}
	findingsJSON, _ := json.Marshal(findings)

	return ChatResponse{
		Content:   `{"findings":` + string(findingsJSON) + `}`,
		ToolCalls: nil,
		TokensIn:  100,
		TokensOut: 50,
	}, nil
}

// CallCount returns the number of Chat calls made.
func (c *LogAgentClient) CallCount() int {
	return c.calls
}
