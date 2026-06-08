package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const anthropicVersion = "2023-06-01"

// anthropicClient speaks the Anthropic Messages protocol (POST /v1/messages).
type anthropicClient struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	model      string
	timeout    time.Duration
}

func newAnthropicClient(conn Connection) (*anthropicClient, error) {
	base := firstNonEmpty(conn.BaseURL, "https://api.anthropic.com")
	model := firstNonEmpty(conn.Model, "claude-sonnet-4-6")
	timeout := conn.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	hc := conn.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: timeout}
	}
	return &anthropicClient{
		httpClient: hc,
		baseURL:    base,
		apiKey:     conn.APIKey,
		model:      model,
		timeout:    timeout,
	}, nil
}

func (c *anthropicClient) Provider() string { return "anthropic" }
func (c *anthropicClient) Model() string    { return c.model }

// anthropicReq mirrors the subset of the Messages API tendant uses. It is
// exported-field-shaped so transport tests can decode an observed request.
type anthropicReq struct {
	Model      string          `json:"model"`
	MaxTokens  int             `json:"max_tokens"`
	System     string          `json:"system,omitempty"`
	Messages   []anthropicMsg  `json:"messages"`
	Tools      []anthropicTool `json:"tools,omitempty"`
	ToolChoice map[string]any  `json:"tool_choice,omitempty"`
}

type anthropicMsg struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type anthropicTool struct {
	Name        string         `json:"name"`
	Description string         `json:"description,omitempty"`
	InputSchema map[string]any `json:"input_schema"`
}

type anthropicResp struct {
	Model   string `json:"model"`
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

func (c *anthropicClient) Chat(ctx context.Context, req Request) (Response, error) {
	body := buildAnthropicBody(req, c.model)
	raw, err := json.Marshal(body)
	if err != nil {
		return Response{}, fmt.Errorf("anthropic: marshal request: %w", err)
	}

	reqCtx, cancel := context.WithTimeout(ctx, c.timeout)
	defer cancel()
	httpReq, err := http.NewRequestWithContext(reqCtx, http.MethodPost, c.baseURL+"/v1/messages", bytes.NewReader(raw))
	if err != nil {
		return Response{}, fmt.Errorf("anthropic: build request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("x-api-key", c.apiKey)
	httpReq.Header.Set("anthropic-version", anthropicVersion)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return Response{}, fmt.Errorf("%w: anthropic POST: %v", ErrTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return Response{}, fmt.Errorf("%w: anthropic read body: %v", ErrTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Response{}, fmt.Errorf("%w: anthropic status=%d body=%s", ErrTransient, resp.StatusCode, string(respBody))
	}
	return parseAnthropicBody(respBody, c.model)
}

// buildAnthropicBody assembles the Messages request. Shared with the Bedrock
// client, which uses the identical body shape minus the model field.
func buildAnthropicBody(req Request, defaultModel string) anthropicReq {
	maxTokens := req.MaxTokens
	if maxTokens == 0 {
		maxTokens = 1024
	}
	msgs := make([]anthropicMsg, 0, len(req.Messages))
	for _, m := range req.Messages {
		msgs = append(msgs, anthropicMsg{Role: anthropicRole(m.Role), Content: m.Content})
	}
	body := anthropicReq{
		Model:     firstNonEmpty(req.Model, defaultModel),
		MaxTokens: maxTokens,
		System:    req.System,
		Messages:  msgs,
	}
	for _, t := range req.Tools {
		schema := t.Schema
		if schema == nil {
			schema = map[string]any{"type": "object"}
		}
		body.Tools = append(body.Tools, anthropicTool{
			Name:        t.Name,
			Description: t.Description,
			InputSchema: schema,
		})
	}
	if req.ForceTool != "" {
		body.ToolChoice = map[string]any{"type": "tool", "name": req.ForceTool}
	}
	return body
}

// parseAnthropicBody decodes a Messages response into the neutral Response.
// Shared with the Bedrock client.
func parseAnthropicBody(respBody []byte, defaultModel string) (Response, error) {
	var decoded anthropicResp
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return Response{}, fmt.Errorf("%w: anthropic decode: %v", ErrTransient, err)
	}
	out := Response{
		Model:     firstNonEmpty(decoded.Model, defaultModel),
		TokensIn:  decoded.Usage.InputTokens,
		TokensOut: decoded.Usage.OutputTokens,
	}
	for _, b := range decoded.Content {
		switch b.Type {
		case "text":
			out.Content += b.Text
		case "tool_use":
			out.ToolCalls = append(out.ToolCalls, ToolCall{
				ID:        b.ID,
				Name:      b.Name,
				Arguments: string(b.Input),
			})
		}
	}
	return out, nil
}

// anthropicRole maps neutral roles onto Anthropic roles. Anthropic has only
// "user"/"assistant"; "tool_result" content is delivered as a user turn.
func anthropicRole(role string) string {
	if role == "assistant" {
		return "assistant"
	}
	return "user"
}
