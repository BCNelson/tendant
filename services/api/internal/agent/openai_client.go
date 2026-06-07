package agent

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// OpenAIClient implements AgentModelClient using the OpenAI Chat Completions API
// with multi-turn tool-use support.
type OpenAIClient struct {
	APIKey       string
	DefaultModel string
	BaseURL      string // defaults to "https://api.openai.com"
	client       http.Client
}

func (c *OpenAIClient) baseURL() string {
	if c.BaseURL != "" {
		return c.BaseURL
	}
	return "https://api.openai.com"
}

// Chat sends a multi-turn conversation to the OpenAI Chat Completions API.
func (c *OpenAIClient) Chat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	model := req.Model
	if model == "" {
		model = c.DefaultModel
	}

	// Build messages array.
	messages := make([]map[string]any, 0, len(req.Messages)+1)
	messages = append(messages, map[string]any{
		"role":    "system",
		"content": req.System,
	})
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
			"type": "function",
			"function": map[string]any{
				"name":        t.Name,
				"description": t.Description,
			},
		}
		if t.Schema != "" {
			fn := tool["function"].(map[string]any)
			var schema any
			if err := json.Unmarshal([]byte(t.Schema), &schema); err == nil {
				fn["parameters"] = schema
			}
		}
		tools = append(tools, tool)
	}

	body := map[string]any{
		"model":    model,
		"messages": messages,
	}
	if len(tools) > 0 {
		body["tools"] = tools
	}

	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return ChatResponse{}, fmt.Errorf("marshal request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL()+"/v1/chat/completions", bytes.NewReader(bodyBytes))
	if err != nil {
		return ChatResponse{}, fmt.Errorf("create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Authorization", "Bearer "+c.APIKey)

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
		return ChatResponse{}, fmt.Errorf("openai API %d: %s", resp.StatusCode, string(respBody))
	}

	return parseOpenAIResponse(respBody)
}

func parseOpenAIResponse(data []byte) (ChatResponse, error) {
	var raw struct {
		Choices []struct {
			Message struct {
				Content   string `json:"content"`
				ToolCalls []struct {
					ID       string `json:"id"`
					Function struct {
						Name      string `json:"name"`
						Arguments string `json:"arguments"`
					} `json:"function"`
				} `json:"tool_calls"`
			} `json:"message"`
		} `json:"choices"`
		Usage struct {
			PromptTokens     int `json:"prompt_tokens"`
			CompletionTokens int `json:"completion_tokens"`
		} `json:"usage"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return ChatResponse{}, fmt.Errorf("parse response: %w", err)
	}

	var result ChatResponse
	result.TokensIn = raw.Usage.PromptTokens
	result.TokensOut = raw.Usage.CompletionTokens

	if len(raw.Choices) > 0 {
		msg := raw.Choices[0].Message
		result.Content = msg.Content
		for _, tc := range msg.ToolCalls {
			result.ToolCalls = append(result.ToolCalls, ToolCall{
				ID:      tc.ID,
				Name:    tc.Function.Name,
				Payload: tc.Function.Arguments,
			})
		}
	}
	return result, nil
}
