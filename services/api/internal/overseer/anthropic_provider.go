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

// AnthropicProvider is the real-LLM Provider for the Anthropic Messages
// API. Stdlib-only — POST JSON to /v1/messages with a forced tool_use
// response of {verdict, summary, considered_fields} so the gateway parses
// structured output rather than free-form text.
type AnthropicProvider struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	modelID    string
	timeout    time.Duration
}

// AnthropicConfig is the constructor input. Zero values fall back to
// sensible defaults (base URL, default model id, 30s timeout).
type AnthropicConfig struct {
	HTTPClient *http.Client
	BaseURL    string        // default: https://api.anthropic.com
	APIKey     string        // required
	ModelID    string        // default: claude-sonnet-4-6
	Timeout    time.Duration // default: 30 s
}

// NewAnthropicProvider constructs a provider; returns an error if the
// API key is empty (we'd never produce a verdict anyway, so fail loud at
// boot rather than producing fail-closed verdicts forever).
func NewAnthropicProvider(cfg AnthropicConfig) (*AnthropicProvider, error) {
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("anthropic: APIKey required (TENDANT_OVERSEER_ANTHROPIC_API_KEY)")
	}
	base := cfg.BaseURL
	if base == "" {
		base = "https://api.anthropic.com"
	}
	model := cfg.ModelID
	if model == "" {
		model = "claude-sonnet-4-6"
	}
	timeout := cfg.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	client := cfg.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: timeout}
	}
	return &AnthropicProvider{
		httpClient: client,
		baseURL:    base,
		apiKey:     cfg.APIKey,
		modelID:    model,
		timeout:    timeout,
	}, nil
}

// NewAnthropicProviderFromEnv reads TENDANT_OVERSEER_ANTHROPIC_API_KEY +
// optional TENDANT_OVERSEER_ANTHROPIC_BASE_URL / TENDANT_OVERSEER_MODEL_ID.
func NewAnthropicProviderFromEnv() (*AnthropicProvider, error) {
	return NewAnthropicProvider(AnthropicConfig{
		APIKey:  secret.Getenv("TENDANT_OVERSEER_ANTHROPIC_API_KEY"),
		BaseURL: os.Getenv("TENDANT_OVERSEER_ANTHROPIC_BASE_URL"),
		ModelID: os.Getenv("TENDANT_OVERSEER_MODEL_ID"),
	})
}

// Name reports the provider identifier written into audit.
func (p *AnthropicProvider) Name() string { return "anthropic" }

// ModelID returns the configured model identifier.
func (p *AnthropicProvider) ModelID() string { return p.modelID }

// verdictResponseToolSchema is the JSON schema for the forced tool_use
// output. The gateway parses the tool_use block into RawResponse.
var verdictResponseToolSchema = map[string]any{
	"type": "object",
	"properties": map[string]any{
		"verdict": map[string]any{
			"type": "string",
			"enum": []string{"approve", "request_decision"},
		},
		"summary":           map[string]any{"type": "string"},
		"considered_fields": map[string]any{"type": "array", "items": map[string]any{"type": "string"}},
	},
	"required": []string{"verdict", "summary"},
}

// anthropicRequest mirrors the subset of the Messages API the gateway
// uses. The system slot carries SystemPreamble + OWNER_INSTRUCTIONS +
// TOOL_METADATA; the user message carries CONCRETE_CALL.
type anthropicRequest struct {
	Model      string             `json:"model"`
	MaxTokens  int                `json:"max_tokens"`
	System     string             `json:"system"`
	Messages   []anthropicMessage `json:"messages"`
	Tools      []anthropicToolDef `json:"tools"`
	ToolChoice map[string]any     `json:"tool_choice"`
}

type anthropicMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type anthropicToolDef struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	InputSchema map[string]any `json:"input_schema"`
}

// anthropicResponse is the minimal shape the parser needs from
// /v1/messages.
type anthropicResponse struct {
	ID         string             `json:"id"`
	Model      string             `json:"model"`
	Content    []anthropicContent `json:"content"`
	StopReason string             `json:"stop_reason"`
	Usage      anthropicUsage     `json:"usage"`
}

type anthropicContent struct {
	Type  string         `json:"type"`
	Text  string         `json:"text,omitempty"`
	Name  string         `json:"name,omitempty"`
	Input map[string]any `json:"input,omitempty"`
}

type anthropicUsage struct {
	InputTokens  int `json:"input_tokens"`
	OutputTokens int `json:"output_tokens"`
}

// Call dispatches one structured-output request and parses the tool_use
// block into RawResponse.
func (p *AnthropicProvider) Call(ctx context.Context, prompt PromptPayload) (RawResponse, error) {
	// Assemble system text: SystemPreamble + OWNER_INSTRUCTIONS + TOOL_METADATA.
	systemBlock := prompt.SystemPreamble +
		"\n\n[OWNER_INSTRUCTIONS]\n" + prompt.OwnerInstructions +
		"\n\n[TOOL_METADATA]\n" + prompt.ToolMetadata

	body := anthropicRequest{
		Model:     p.modelID,
		MaxTokens: 1024,
		System:    systemBlock,
		Messages: []anthropicMessage{{
			Role:    "user",
			Content: "[CONCRETE_CALL]\n" + prompt.ConcreteCall,
		}},
		Tools: []anthropicToolDef{{
			Name:        "verdict_response",
			Description: "Return the overseer verdict + evidence for this tool call.",
			InputSchema: verdictResponseToolSchema,
		}},
		ToolChoice: map[string]any{"type": "tool", "name": "verdict_response"},
	}
	raw, err := json.Marshal(body)
	if err != nil {
		return RawResponse{}, fmt.Errorf("anthropic: marshal request: %w", err)
	}

	reqCtx, cancel := context.WithTimeout(ctx, p.timeout)
	defer cancel()
	req, err := http.NewRequestWithContext(reqCtx, http.MethodPost, p.baseURL+"/v1/messages", bytes.NewReader(raw))
	if err != nil {
		return RawResponse{}, fmt.Errorf("anthropic: build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", p.apiKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return RawResponse{}, fmt.Errorf("%w: anthropic POST: %v", ErrProviderTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return RawResponse{}, fmt.Errorf("%w: anthropic read body: %v", ErrProviderTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return RawResponse{}, fmt.Errorf("%w: anthropic status=%d body=%s", ErrProviderTransient, resp.StatusCode, string(respBody))
	}

	var decoded anthropicResponse
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return RawResponse{}, fmt.Errorf("%w: anthropic decode: %v", ErrProviderTransient, err)
	}

	return parseAnthropicResponse(&decoded, p.modelID)
}

// parseAnthropicResponse extracts the first tool_use block named
// verdict_response and renders RawResponse. Any structural drift returns
// an error wrapping ErrProviderTransient so the Gateway fail-closes.
func parseAnthropicResponse(resp *anthropicResponse, defaultModelID string) (RawResponse, error) {
	for _, c := range resp.Content {
		if c.Type != "tool_use" || c.Name != "verdict_response" {
			continue
		}
		verdict, _ := c.Input["verdict"].(string)
		summary, _ := c.Input["summary"].(string)
		if verdict == "" {
			return RawResponse{}, fmt.Errorf("%w: missing verdict in tool_use input", ErrProviderTransient)
		}
		considered := []string{}
		if raw, ok := c.Input["considered_fields"].([]any); ok {
			for _, v := range raw {
				if s, ok := v.(string); ok {
					considered = append(considered, s)
				}
			}
		}
		modelID := resp.Model
		if modelID == "" {
			modelID = defaultModelID
		}
		return RawResponse{
			Verdict: verdict,
			Evidence: Evidence{
				Summary:          summary,
				ConsideredFields: considered,
			},
			ModelID:   modelID,
			TokensIn:  resp.Usage.InputTokens,
			TokensOut: resp.Usage.OutputTokens,
		}, nil
	}
	return RawResponse{}, fmt.Errorf("%w: no verdict_response tool_use block in response", ErrProviderTransient)
}
