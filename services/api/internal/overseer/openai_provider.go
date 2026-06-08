package overseer

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/bcnelson/tendant/services/api/internal/secret"
)

// OpenAIProvider is the real-LLM Provider for the OpenAI Chat Completions
// API. Same shape as AnthropicProvider but uses function-calling with
// tool_choice forced to "verdict_response" so the gateway parses
// structured arguments rather than free-form text.
type OpenAIProvider struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	modelID    string
	timeout    time.Duration
}

// OpenAIConfig is the constructor input.
type OpenAIConfig struct {
	HTTPClient *http.Client
	BaseURL    string        // default: https://api.openai.com
	APIKey     string        // required
	ModelID    string        // default: gpt-4.1-mini
	Timeout    time.Duration // default: 30 s
}

// NewOpenAIProvider constructs a provider; errors on empty API key.
func NewOpenAIProvider(cfg OpenAIConfig) (*OpenAIProvider, error) {
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("openai: APIKey required (TENDANT_OVERSEER_OPENAI_API_KEY)")
	}
	base := cfg.BaseURL
	if base == "" {
		base = "https://api.openai.com"
	}
	model := cfg.ModelID
	if model == "" {
		model = "gpt-4.1-mini"
	}
	timeout := cfg.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	client := cfg.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: timeout}
	}
	return &OpenAIProvider{
		httpClient: client,
		baseURL:    base,
		apiKey:     cfg.APIKey,
		modelID:    model,
		timeout:    timeout,
	}, nil
}

// NewOpenAIProviderFromEnv reads TENDANT_OVERSEER_OPENAI_API_KEY +
// optional TENDANT_OVERSEER_OPENAI_BASE_URL / TENDANT_OVERSEER_MODEL_ID.
func NewOpenAIProviderFromEnv() (*OpenAIProvider, error) {
	return NewOpenAIProvider(OpenAIConfig{
		APIKey:  secret.Getenv("TENDANT_OVERSEER_OPENAI_API_KEY"),
		BaseURL: os.Getenv("TENDANT_OVERSEER_OPENAI_BASE_URL"),
		ModelID: os.Getenv("TENDANT_OVERSEER_MODEL_ID"),
	})
}

// Name reports the provider identifier written into audit.
func (p *OpenAIProvider) Name() string { return "openai" }

// ModelID returns the configured model identifier.
func (p *OpenAIProvider) ModelID() string { return p.modelID }

// openaiRequest mirrors the subset of /v1/chat/completions the gateway uses.
type openaiRequest struct {
	Model      string         `json:"model"`
	Messages   []openaiMsg    `json:"messages"`
	Tools      []openaiTool   `json:"tools"`
	ToolChoice map[string]any `json:"tool_choice"`
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
	Description string         `json:"description"`
	Parameters  map[string]any `json:"parameters"`
}

type openaiResponse struct {
	ID      string         `json:"id"`
	Model   string         `json:"model"`
	Choices []openaiChoice `json:"choices"`
	Usage   openaiUsage    `json:"usage"`
}

type openaiChoice struct {
	Message openaiMessageOut `json:"message"`
}

type openaiMessageOut struct {
	Role      string              `json:"role"`
	Content   string              `json:"content"`
	ToolCalls []openaiToolCallOut `json:"tool_calls"`
}

type openaiToolCallOut struct {
	ID       string          `json:"id"`
	Type     string          `json:"type"`
	Function openaiToolFnOut `json:"function"`
}

type openaiToolFnOut struct {
	Name      string `json:"name"`
	Arguments string `json:"arguments"`
}

type openaiUsage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
}

// Call dispatches one structured-output request and parses the verdict_response
// tool call's arguments JSON into RawResponse.
func (p *OpenAIProvider) Call(ctx context.Context, prompt PromptPayload) (RawResponse, error) {
	systemBlock := prompt.SystemPreamble +
		"\n\n[OWNER_INSTRUCTIONS]\n" + prompt.OwnerInstructions +
		"\n\n[TOOL_METADATA]\n" + prompt.ToolMetadata

	body := openaiRequest{
		Model: p.modelID,
		Messages: []openaiMsg{
			{Role: "system", Content: systemBlock},
			{Role: "user", Content: "[CONCRETE_CALL]\n" + prompt.ConcreteCall},
		},
		Tools: []openaiTool{{
			Type: "function",
			Function: openaiFunction{
				Name:        "verdict_response",
				Description: "Return the overseer verdict + evidence for this tool call.",
				Parameters:  verdictResponseToolSchema,
			},
		}},
		ToolChoice: map[string]any{
			"type":     "function",
			"function": map[string]any{"name": "verdict_response"},
		},
	}
	raw, err := json.Marshal(body)
	if err != nil {
		return RawResponse{}, fmt.Errorf("openai: marshal request: %w", err)
	}

	reqCtx, cancel := context.WithTimeout(ctx, p.timeout)
	defer cancel()
	req, err := http.NewRequestWithContext(reqCtx, http.MethodPost, p.baseURL+"/v1/chat/completions", bytes.NewReader(raw))
	if err != nil {
		return RawResponse{}, fmt.Errorf("openai: build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return RawResponse{}, fmt.Errorf("%w: openai POST: %v", ErrProviderTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return RawResponse{}, fmt.Errorf("%w: openai read body: %v", ErrProviderTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return RawResponse{}, fmt.Errorf("%w: openai status=%d body=%s", ErrProviderTransient, resp.StatusCode, string(respBody))
	}

	var decoded openaiResponse
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return RawResponse{}, fmt.Errorf("%w: openai decode: %v", ErrProviderTransient, err)
	}

	return parseOpenAIResponse(decoded, p.modelID)
}

// parseOpenAIResponse extracts the first verdict_response tool call from
// the first choice and parses its arguments JSON into RawResponse.
func parseOpenAIResponse(resp openaiResponse, defaultModelID string) (RawResponse, error) {
	if len(resp.Choices) == 0 {
		return RawResponse{}, fmt.Errorf("%w: no choices in openai response", ErrProviderTransient)
	}
	choice := resp.Choices[0]
	for _, tc := range choice.Message.ToolCalls {
		if tc.Type != "function" || tc.Function.Name != "verdict_response" {
			continue
		}
		var args struct {
			Verdict          string   `json:"verdict"`
			Summary          string   `json:"summary"`
			ConsideredFields []string `json:"considered_fields"`
		}
		if err := json.Unmarshal([]byte(tc.Function.Arguments), &args); err != nil {
			return RawResponse{}, fmt.Errorf("%w: openai parse arguments: %v", ErrProviderTransient, err)
		}
		if args.Verdict == "" {
			return RawResponse{}, fmt.Errorf("%w: missing verdict in tool_call arguments", ErrProviderTransient)
		}
		modelID := resp.Model
		if modelID == "" {
			modelID = defaultModelID
		}
		considered := args.ConsideredFields
		if considered == nil {
			considered = []string{}
		}
		return RawResponse{
			Verdict: args.Verdict,
			Evidence: Evidence{
				Summary:          args.Summary,
				ConsideredFields: considered,
			},
			ModelID:   modelID,
			TokensIn:  resp.Usage.PromptTokens,
			TokensOut: resp.Usage.CompletionTokens,
		}, nil
	}
	return RawResponse{}, fmt.Errorf("%w: no verdict_response tool_call in openai response", ErrProviderTransient)
}
