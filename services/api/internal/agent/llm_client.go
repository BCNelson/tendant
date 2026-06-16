package agent

import (
	"context"
	"encoding/json"

	"github.com/bcnelson/tendant/services/api/internal/llm"
)

// llmAgentClient adapts an llm.Client to the multi-turn AgentModelClient seam.
// All provider HTTP lives in internal/llm; this adapter only translates the
// agent's ChatRequest/ChatResponse to and from the neutral llm types.
type llmAgentClient struct {
	client llm.Client
}

// NewLLMAgentClient wraps an llm.Client as an AgentModelClient.
func NewLLMAgentClient(client llm.Client) AgentModelClient {
	return &llmAgentClient{client: client}
}

func (c *llmAgentClient) Chat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	lreq := llm.Request{
		Model:          req.Model,
		System:         req.System,
		Messages:       make([]llm.Message, 0, len(req.Messages)),
		ForceTool:      req.ForceTool,
		ResponseFormat: req.ResponseFormat,
		MaxTokens:      req.MaxTokens,
	}
	for _, m := range req.Messages {
		lreq.Messages = append(lreq.Messages, llm.Message{Role: m.Role, Content: m.Content})
	}
	for _, t := range req.Tools {
		var schema map[string]any
		if t.Schema != "" {
			_ = json.Unmarshal([]byte(t.Schema), &schema)
		}
		lreq.Tools = append(lreq.Tools, llm.Tool{
			Name:        t.Name,
			Description: t.Description,
			Schema:      schema,
		})
	}

	resp, err := c.client.Chat(ctx, lreq)
	if err != nil {
		return ChatResponse{}, err
	}

	out := ChatResponse{
		Content:   resp.Content,
		TokensIn:  resp.TokensIn,
		TokensOut: resp.TokensOut,
	}
	for _, tc := range resp.ToolCalls {
		out.ToolCalls = append(out.ToolCalls, ToolCall{
			ID:      tc.ID,
			Name:    tc.Name,
			Payload: tc.Arguments,
		})
	}
	return out, nil
}
