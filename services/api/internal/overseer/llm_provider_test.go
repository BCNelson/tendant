package overseer

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// fixtureServer replies with status + body for any request, recording the body.
func overseerFixture(t *testing.T, status int, body string, seen *string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		b := make([]byte, 1<<16)
		n, _ := r.Body.Read(b)
		if seen != nil {
			*seen = string(b[:n])
		}
		if status != 0 {
			w.WriteHeader(status)
		}
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(srv.Close)
	return srv
}

func TestLLMProvider_Anthropic_HappyPath(t *testing.T) {
	t.Parallel()
	body := `{"model":"claude-sonnet-4-6","content":[{"type":"tool_use","name":"verdict_response","input":{"verdict":"approve","summary":"looks fine","considered_fields":["payload.to"]}}],"usage":{"input_tokens":120,"output_tokens":8}}`
	srv := overseerFixture(t, 200, body, nil)
	p, err := NewAnthropicProvider(AnthropicConfig{APIKey: "sk", BaseURL: srv.URL, ModelID: "claude-sonnet-4-6"})
	if err != nil {
		t.Fatal(err)
	}
	resp, err := p.Call(context.Background(), PromptPayload{ConcreteCall: `{"to":"x"}`})
	if err != nil {
		t.Fatalf("call: %v", err)
	}
	if resp.Verdict != "approve" || resp.Evidence.Summary != "looks fine" {
		t.Fatalf("resp=%+v", resp)
	}
	if len(resp.Evidence.ConsideredFields) != 1 || resp.TokensIn != 120 || resp.TokensOut != 8 {
		t.Fatalf("resp=%+v", resp)
	}
	if resp.ModelID != "claude-sonnet-4-6" {
		t.Fatalf("model=%q", resp.ModelID)
	}
	if p.Name() != "anthropic" {
		t.Fatalf("name=%q", p.Name())
	}
}

func TestLLMProvider_SlotMapping_OwnerInSystemConcreteInUser(t *testing.T) {
	t.Parallel()
	var seen string
	body := `{"content":[{"type":"tool_use","name":"verdict_response","input":{"verdict":"approve","summary":"ok"}}],"usage":{"input_tokens":1,"output_tokens":1}}`
	srv := overseerFixture(t, 200, body, &seen)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{
		SystemPreamble:    "PREAMBLE",
		OwnerInstructions: "OWNER-RULE",
		ToolMetadata:      `{"name":"send-email"}`,
		ConcreteCall:      `{"body":"OWNER-RULE-is-data"}`,
	})
	if err != nil {
		t.Fatal(err)
	}
	// System slot must carry preamble + owner label + owner text; the concrete
	// call (with the lookalike directive) must be in the user message, never the
	// system slot.
	if !strings.Contains(seen, "PREAMBLE") || !strings.Contains(seen, "[OWNER_INSTRUCTIONS]") {
		t.Fatalf("system slot missing labels: %s", seen)
	}
	if !strings.Contains(seen, "[CONCRETE_CALL]") || !strings.Contains(seen, "OWNER-RULE-is-data") {
		t.Fatalf("concrete call not in user message: %s", seen)
	}
}

func TestLLMProvider_OpenAI_HappyPath(t *testing.T) {
	t.Parallel()
	body := `{"model":"gpt-4.1-mini","choices":[{"message":{"tool_calls":[{"type":"function","function":{"name":"verdict_response","arguments":"{\"verdict\":\"request_decision\",\"summary\":\"risky\"}"}}]}}],"usage":{"prompt_tokens":10,"completion_tokens":2}}`
	srv := overseerFixture(t, 200, body, nil)
	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk", BaseURL: srv.URL})
	resp, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if err != nil {
		t.Fatal(err)
	}
	if resp.Verdict != "request_decision" || resp.Evidence.Summary != "risky" {
		t.Fatalf("resp=%+v", resp)
	}
}

func TestLLMProvider_Status500_Transient(t *testing.T) {
	t.Parallel()
	srv := overseerFixture(t, 500, `{"error":"down"}`, nil)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestLLMProvider_MissingVerdict_Transient(t *testing.T) {
	t.Parallel()
	body := `{"content":[{"type":"tool_use","name":"verdict_response","input":{"summary":"no verdict"}}],"usage":{"input_tokens":1,"output_tokens":1}}`
	srv := overseerFixture(t, 200, body, nil)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestLLMProvider_NoToolCall_Transient(t *testing.T) {
	t.Parallel()
	body := `{"content":[{"type":"text","text":"I cannot do that"}],"usage":{"input_tokens":1,"output_tokens":1}}`
	srv := overseerFixture(t, 200, body, nil)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestLLMProvider_EmptyAPIKey_Errors(t *testing.T) {
	t.Parallel()
	if _, err := NewAnthropicProvider(AnthropicConfig{APIKey: ""}); err == nil {
		t.Fatal("expected error on empty Anthropic API key")
	}
	if _, err := NewOpenAIProvider(OpenAIConfig{APIKey: ""}); err == nil {
		t.Fatal("expected error on empty OpenAI API key")
	}
}
