package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"

	"github.com/bcnelson/tendant/services/api/internal/slogx"
)

// openaiClient speaks the OpenAI Chat Completions protocol. Because the wire
// format is a de-facto standard, one client serves OpenAI, Azure OpenAI,
// Ollama, vLLM, OpenRouter, Together, Groq, and any other OpenAI-compatible
// endpoint — the operator points BaseURL at the right host.
type openaiClient struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	model      string
	timeout    time.Duration
}

func newOpenAIClient(conn Connection) (*openaiClient, error) {
	base := firstNonEmpty(conn.BaseURL, "https://api.openai.com")
	model := firstNonEmpty(conn.Model, "gpt-4.1-mini")
	timeout := conn.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	hc := conn.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: timeout}
	}
	return &openaiClient{
		httpClient: hc,
		baseURL:    base,
		apiKey:     conn.APIKey,
		model:      model,
		timeout:    timeout,
	}, nil
}

func (c *openaiClient) Provider() string { return "openai" }
func (c *openaiClient) Model() string    { return c.model }

type openaiReq struct {
	Model          string       `json:"model"`
	MaxTokens      int          `json:"max_tokens,omitempty"`
	Messages       []openaiMsg  `json:"messages"`
	Tools          []openaiTool `json:"tools,omitempty"`
	ToolChoice     any          `json:"tool_choice,omitempty"`
	ResponseFormat any          `json:"response_format,omitempty"`
}

type openaiMsg struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type openaiTool struct {
	Type     string         `json:"type"`
	Function openaiFunction `json:"function"`
}

type openaiFunction struct {
	Name        string         `json:"name"`
	Description string         `json:"description,omitempty"`
	Parameters  map[string]any `json:"parameters,omitempty"`
}

type openaiResp struct {
	Model   string `json:"model"`
	Choices []struct {
		Message struct {
			Content   string `json:"content"`
			ToolCalls []struct {
				ID       string `json:"id"`
				Type     string `json:"type"`
				Function struct {
					Name      string `json:"name"`
					Arguments string `json:"arguments"`
				} `json:"function"`
			} `json:"tool_calls"`
		} `json:"message"`
		FinishReason string `json:"finish_reason"`
	} `json:"choices"`
	Usage struct {
		PromptTokens     int `json:"prompt_tokens"`
		CompletionTokens int `json:"completion_tokens"`
	} `json:"usage"`
}

func (c *openaiClient) Chat(ctx context.Context, req Request) (Response, error) {
	model := firstNonEmpty(req.Model, c.model)

	msgs := make([]openaiMsg, 0, len(req.Messages)+1)
	if req.System != "" {
		msgs = append(msgs, openaiMsg{Role: "system", Content: req.System})
	}
	for _, m := range req.Messages {
		msgs = append(msgs, openaiMsg{Role: openaiRole(m.Role), Content: m.Content})
	}

	body := openaiReq{Model: model, MaxTokens: req.MaxTokens, Messages: msgs}

	// JSON-object output mode wins over the forced-tool path: it is the
	// reliable structured-output channel for OpenAI-compatible endpoints
	// (notably Ollama) that drop tool_choice on multi-turn requests. Forcing a
	// tool while also requiring a JSON object content would be contradictory
	// (a tool call leaves content empty), so when ResponseFormat is set we omit
	// the tool declarations and emit the object as content for the caller to
	// decode.
	if req.ResponseFormat == "json_object" {
		body.ResponseFormat = map[string]any{"type": "json_object"}
	} else {
		for _, t := range req.Tools {
			body.Tools = append(body.Tools, openaiTool{
				Type: "function",
				Function: openaiFunction{
					Name:        t.Name,
					Description: t.Description,
					Parameters:  t.Schema,
				},
			})
		}
		if req.ForceTool != "" {
			body.ToolChoice = map[string]any{
				"type":     "function",
				"function": map[string]any{"name": req.ForceTool},
			}
		}
	}

	raw, err := json.Marshal(body)
	if err != nil {
		return Response{}, fmt.Errorf("openai: marshal request: %w", err)
	}

	reqCtx, cancel := context.WithTimeout(ctx, c.timeout)
	defer cancel()
	httpReq, err := http.NewRequestWithContext(reqCtx, http.MethodPost, c.baseURL+"/v1/chat/completions", bytes.NewReader(raw))
	if err != nil {
		return Response{}, fmt.Errorf("openai: build request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	if c.apiKey != "" {
		httpReq.Header.Set("Authorization", "Bearer "+c.apiKey)
	}

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return Response{}, fmt.Errorf("%w: openai POST: %v", ErrTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return Response{}, fmt.Errorf("%w: openai read body: %v", ErrTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Response{}, fmt.Errorf("%w: openai status=%d body=%s", ErrTransient, resp.StatusCode, string(respBody))
	}

	// Trace the raw response verbatim so tool-call argument corruption can be
	// attributed: a value already truncated here (e.g. severed at an
	// apostrophe) is the upstream parser's doing, since we store arguments as-is
	// below; finish_reason=="length" instead points at a token-cap cutoff. Off
	// by default (TRACE) — bodies carry prompt + model output, so keep it dev-only.
	slog.Log(ctx, slogx.LevelTrace, "llm.openai: raw response",
		"model", model,
		"status", resp.StatusCode,
		"body", string(respBody),
	)

	var decoded openaiResp
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return Response{}, fmt.Errorf("%w: openai decode: %v", ErrTransient, err)
	}

	out := Response{
		Model:     firstNonEmpty(decoded.Model, model),
		TokensIn:  decoded.Usage.PromptTokens,
		TokensOut: decoded.Usage.CompletionTokens,
	}
	if len(decoded.Choices) > 0 {
		msg := decoded.Choices[0].Message
		out.Content = msg.Content
		for _, tc := range msg.ToolCalls {
			out.ToolCalls = append(out.ToolCalls, ToolCall{
				ID:        tc.ID,
				Name:      tc.Function.Name,
				Arguments: tc.Function.Arguments,
			})
			slog.Log(ctx, slogx.LevelTrace, "llm.openai: tool call decoded",
				"name", tc.Function.Name,
				"finish_reason", decoded.Choices[0].FinishReason,
				"arguments", tc.Function.Arguments,
			)
		}
	}
	return out, nil
}

// openaiRole maps tendant's neutral roles onto OpenAI roles. "tool_result" is
// folded to "tool"; everything else passes through ("user"/"assistant").
func openaiRole(role string) string {
	if role == "tool_result" {
		return "tool"
	}
	return role
}
