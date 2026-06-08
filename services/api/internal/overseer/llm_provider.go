package overseer

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/llm"
)

// verdictResponseToolSchema is the JSON schema for the forced structured-output
// tool. The adapter forces the model to emit a `verdict_response` tool call and
// parses its arguments into RawResponse.
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

// llmProvider adapts an llm.Client to the overseer Provider seam. It maps the
// labeled PromptPayload slots onto a single forced-tool chat call:
//
//	system  = SystemPreamble + [OWNER_INSTRUCTIONS] + [TOOL_METADATA]
//	user    = [CONCRETE_CALL]
//
// — exactly the mapping the previous per-provider HTTP used, now sharing one
// transport implementation across every model API. Transport-transient errors
// (llm.ErrTransient) are re-wrapped as ErrProviderTransient so the gateway's
// audit reasoning is unchanged.
type llmProvider struct {
	name   string
	client llm.Client
}

// NewLLMProvider wraps any llm.Client as an overseer Provider. name is the
// canonical provider string written into audit / used for cost lookups
// (typically client.Provider()).
func NewLLMProvider(name string, client llm.Client) Provider {
	return &llmProvider{name: name, client: client}
}

func (p *llmProvider) Name() string { return p.name }

func (p *llmProvider) Call(ctx context.Context, prompt PromptPayload) (RawResponse, error) {
	systemBlock := prompt.SystemPreamble +
		"\n\n[OWNER_INSTRUCTIONS]\n" + prompt.OwnerInstructions +
		"\n\n[TOOL_METADATA]\n" + prompt.ToolMetadata

	resp, err := p.client.Chat(ctx, llm.Request{
		System:   systemBlock,
		Messages: []llm.Message{{Role: "user", Content: "[CONCRETE_CALL]\n" + prompt.ConcreteCall}},
		Tools: []llm.Tool{{
			Name:        "verdict_response",
			Description: "Return the overseer verdict + evidence for this tool call.",
			Schema:      verdictResponseToolSchema,
		}},
		ForceTool: "verdict_response",
		MaxTokens: 1024,
	})
	if err != nil {
		if errors.Is(err, llm.ErrTransient) {
			return RawResponse{}, fmt.Errorf("%w: %v", ErrProviderTransient, err)
		}
		return RawResponse{}, err
	}

	for _, tc := range resp.ToolCalls {
		if tc.Name != "verdict_response" {
			continue
		}
		var args struct {
			Verdict          string   `json:"verdict"`
			Summary          string   `json:"summary"`
			ConsideredFields []string `json:"considered_fields"`
		}
		if err := json.Unmarshal([]byte(tc.Arguments), &args); err != nil {
			return RawResponse{}, fmt.Errorf("%w: parse verdict args: %v", ErrProviderTransient, err)
		}
		if args.Verdict == "" {
			return RawResponse{}, fmt.Errorf("%w: missing verdict in tool call", ErrProviderTransient)
		}
		considered := args.ConsideredFields
		if considered == nil {
			considered = []string{}
		}
		return RawResponse{
			Verdict:   args.Verdict,
			Evidence:  Evidence{Summary: args.Summary, ConsideredFields: considered},
			ModelID:   firstNonEmpty(resp.Model, p.client.Model()),
			TokensIn:  resp.TokensIn,
			TokensOut: resp.TokensOut,
		}, nil
	}
	return RawResponse{}, fmt.Errorf("%w: no verdict_response tool call in response", ErrProviderTransient)
}

// AnthropicConfig is the constructor input for the Anthropic-backed provider.
// Retained for back-compat with cmd/tendant; it now builds an llm.Client.
type AnthropicConfig struct {
	BaseURL string
	APIKey  string // required
	ModelID string
}

// NewAnthropicProvider builds an Anthropic-backed Provider. Errors on empty
// API key (we'd never produce a verdict, so fail loud at boot).
func NewAnthropicProvider(cfg AnthropicConfig) (Provider, error) {
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("anthropic: APIKey required (TENDANT_OVERSEER_ANTHROPIC_API_KEY)")
	}
	client, err := llm.NewClient(llm.Connection{
		Provider: "anthropic",
		BaseURL:  cfg.BaseURL,
		APIKey:   cfg.APIKey,
		Model:    cfg.ModelID,
	})
	if err != nil {
		return nil, err
	}
	return NewLLMProvider("anthropic", client), nil
}

// OpenAIConfig is the constructor input for the OpenAI-backed provider.
type OpenAIConfig struct {
	BaseURL string
	APIKey  string // required
	ModelID string
}

// NewOpenAIProvider builds an OpenAI-backed Provider. Errors on empty API key.
func NewOpenAIProvider(cfg OpenAIConfig) (Provider, error) {
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("openai: APIKey required (TENDANT_OVERSEER_OPENAI_API_KEY)")
	}
	client, err := llm.NewClient(llm.Connection{
		Provider: "openai",
		BaseURL:  cfg.BaseURL,
		APIKey:   cfg.APIKey,
		Model:    cfg.ModelID,
	})
	if err != nil {
		return nil, err
	}
	return NewLLMProvider("openai", client), nil
}
