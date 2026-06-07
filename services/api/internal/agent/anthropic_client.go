package agent

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// AnthropicClient implements AgentModelClient using the Anthropic Messages API
// with multi-turn tool-use support.
type AnthropicClient struct {
	APIKey       string
	DefaultModel string
	BaseURL      string // defaults to "https://api.anthropic.com"
	client       http.Client
}

func (c *AnthropicClient) baseURL() string {
	if c.BaseURL != "" {
		return c.BaseURL
	}
	return "https://api.anthropic.com"
}

// Chat sends a multi-turn conversation to the Anthropic Messages API.
func (c *AnthropicClient) Chat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	model := req.Model
	if model == "" {
		model = c.DefaultModel
	}

	// Build messages array.
	messages := make([]map[string]any, 0, len(req.Messages))
	for _, m := range req.Messages {
		messages = append(messages, map[string]any{
			"role":    m.Role,
			"content": m.Content,
		})
	}

	// Build tools array.
	tools := make([]map[string]any, 0, len(req.Tools))
	for _, t := range req.Tools {
		tool := map[string]any{
			"name":        t.Name,
			"description": t.Description,
		}
		if t.Schema != "" {
			var schema any
			if err := json.Unmarshal([]byte(t.Schema), &schema); err == nil {
				tool["input_schema"] = schema
			}
		}
		tools = append(tools, tool)
	}

	body := map[string]any{
		"model":      model,
		"max_tokens": 4096,
		"system":     req.System,
		"messages":   messages,
	}
	if len(tools) > 0 {
		body["tools"] = tools
	}

	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return ChatResponse{}, fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL()+"/v1/messages", bytes.NewReader(bodyBytes))
	if err != nil {
		return ChatResponse{}, fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("x-api-key", c.APIKey)
	httpReq.Header.Set("anthropic-version", "2023-06-01")

	resp, err := c.client.Do(httpReq)
	if err != nil {
		return ChatResponse{}, fmt.Errorf("http call: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return ChatResponse{}, fmt.Errorf("read response: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		return ChatResponse{}, fmt.Errorf("anthropic API %d: %s", resp.StatusCode, string(respBody))
	}

	return parseAnthropicResponse(respBody)
}

func parseAnthropicResponse(data []byte) (ChatResponse, error) {
	var raw struct {
		Content []struct {
			Type  string          `json:"type"`
			Text  string          `json:"text"`
			ID    string          `json:"id"`
			Name  string          `json:"name"`
			Input json.RawMessage `json:"input"`
		} `json:"content"`
		Usage struct {
			InputTokens  int `json:"input_tokens"`
			OutputTokens int `json:"output_tokens"`
		} `json:"usage"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return ChatResponse{}, fmt.Errorf("parse response: %w", err)
	}

	var result ChatResponse
	result.TokensIn = raw.Usage.InputTokens
	result.TokensOut = raw.Usage.OutputTokens

	for _, block := range raw.Content {
		switch block.Type {
		case "text":
			result.Content += block.Text
		case "tool_use":
			result.ToolCalls = append(result.ToolCalls, ToolCall{
				ID:      block.ID,
				Name:    block.Name,
				Payload: string(block.Input),
			})
		}
	}
	return result, nil
}
