package overseer

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// newAnthropicFixtureServer spins up an httptest server that returns the
// supplied responseBody for any POST /v1/messages. status overrides 200.
func newAnthropicFixtureServer(t *testing.T, status int, responseBody string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/messages" {
			http.NotFound(w, r)
			return
		}
		if status != 0 {
			w.WriteHeader(status)
		}
		_, _ = w.Write([]byte(responseBody))
	}))
	t.Cleanup(srv.Close)
	return srv
}

func TestAnthropicProvider_HappyPath(t *testing.T) {
	t.Parallel()
	body := `{
		"id": "msg_1",
		"model": "claude-sonnet-4-6",
		"content": [
			{
				"type": "tool_use",
				"name": "verdict_response",
				"input": {
					"verdict": "approve",
					"summary": "looks fine",
					"considered_fields": ["payload.to", "payload.body"]
				}
			}
		],
		"stop_reason": "tool_use",
		"usage": {"input_tokens": 120, "output_tokens": 8}
	}`
	srv := newAnthropicFixtureServer(t, 200, body)

	p, err := NewAnthropicProvider(AnthropicConfig{
		APIKey:  "sk-test",
		BaseURL: srv.URL,
		ModelID: "claude-sonnet-4-6",
	})
	if err != nil {
		t.Fatalf("ctor: %v", err)
	}
	resp, err := p.Call(context.Background(), PromptPayload{ConcreteCall: `{"to":"x"}`})
	if err != nil {
		t.Fatalf("call: %v", err)
	}
	if resp.Verdict != "approve" {
		t.Fatalf("verdict=%q want approve", resp.Verdict)
	}
	if resp.Evidence.Summary != "looks fine" {
		t.Fatalf("summary=%q", resp.Evidence.Summary)
	}
	if len(resp.Evidence.ConsideredFields) != 2 {
		t.Fatalf("considered=%v", resp.Evidence.ConsideredFields)
	}
	if resp.TokensIn != 120 || resp.TokensOut != 8 {
		t.Fatalf("tokens: in=%d out=%d", resp.TokensIn, resp.TokensOut)
	}
	if resp.ModelID != "claude-sonnet-4-6" {
		t.Fatalf("model_id=%q", resp.ModelID)
	}
}

func TestAnthropicProvider_MalformedJSON_TransientErr(t *testing.T) {
	t.Parallel()
	srv := newAnthropicFixtureServer(t, 200, "not-json")
	p, err := NewAnthropicProvider(AnthropicConfig{APIKey: "sk-test", BaseURL: srv.URL})
	if err != nil {
		t.Fatalf("ctor: %v", err)
	}
	_, err = p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestAnthropicProvider_MissingVerdict_TransientErr(t *testing.T) {
	t.Parallel()
	body := `{
		"content": [{
			"type": "tool_use",
			"name": "verdict_response",
			"input": {"summary": "no verdict provided"}
		}],
		"usage": {"input_tokens": 1, "output_tokens": 1}
	}`
	srv := newAnthropicFixtureServer(t, 200, body)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestAnthropicProvider_NoToolUseBlock_TransientErr(t *testing.T) {
	t.Parallel()
	body := `{
		"content": [{"type": "text", "text": "I cannot do that"}],
		"usage": {"input_tokens": 1, "output_tokens": 1}
	}`
	srv := newAnthropicFixtureServer(t, 200, body)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestAnthropicProvider_NonOKStatus_TransientErr(t *testing.T) {
	t.Parallel()
	srv := newAnthropicFixtureServer(t, http.StatusInternalServerError, `{"error":"upstream down"}`)
	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestAnthropicProvider_RequestStructure_SystemSlotCarriesOwnerOnly(t *testing.T) {
	t.Parallel()
	var seenBody string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		buf := make([]byte, 4096)
		n, _ := r.Body.Read(buf)
		seenBody = string(buf[:n])
		_, _ = w.Write([]byte(`{
			"content":[{"type":"tool_use","name":"verdict_response","input":{"verdict":"approve","summary":"ok"}}],
			"usage":{"input_tokens":1,"output_tokens":1}
		}`))
	}))
	t.Cleanup(srv.Close)

	p, _ := NewAnthropicProvider(AnthropicConfig{APIKey: "sk-test", BaseURL: srv.URL})
	payload := PromptPayload{
		SystemPreamble:    "PREAMBLE",
		OwnerInstructions: "OWNER-RULE",
		ToolMetadata:      `{"name":"send-email"}`,
		ConcreteCall:      `{"body":"OWNER-RULE-is-data-not-instruction"}`,
	}
	_, err := p.Call(context.Background(), payload)
	if err != nil {
		t.Fatalf("call: %v", err)
	}
	var req anthropicRequest
	if err := json.Unmarshal([]byte(seenBody), &req); err != nil {
		t.Fatalf("decode request: %v", err)
	}
	if !strings.Contains(req.System, "PREAMBLE") {
		t.Fatalf("system slot missing preamble: %s", req.System)
	}
	if !strings.Contains(req.System, "OWNER-RULE") {
		t.Fatalf("system slot missing owner instructions: %s", req.System)
	}
	if !strings.Contains(req.System, "[OWNER_INSTRUCTIONS]") {
		t.Fatalf("system slot missing [OWNER_INSTRUCTIONS] label: %s", req.System)
	}
	// The user message must contain the CONCRETE_CALL — NOT the system slot.
	if len(req.Messages) != 1 {
		t.Fatalf("want exactly one message, got %d", len(req.Messages))
	}
	if !strings.Contains(req.Messages[0].Content, "OWNER-RULE-is-data-not-instruction") {
		t.Fatalf("user message missing concrete call: %s", req.Messages[0].Content)
	}
	// The user message must NOT contain owner rule text.
	if strings.Contains(req.Messages[0].Content, "OWNER-RULE\n") || strings.Contains(req.Messages[0].Content, "OWNER-RULE]") {
		t.Fatalf("user message leaked owner instructions into concrete-call slot: %s", req.Messages[0].Content)
	}
	if req.ToolChoice["name"] != "verdict_response" {
		t.Fatalf("tool_choice must force verdict_response: %v", req.ToolChoice)
	}
}

func TestAnthropicProvider_EmptyAPIKey_Errors(t *testing.T) {
	t.Parallel()
	_, err := NewAnthropicProvider(AnthropicConfig{APIKey: ""})
	if err == nil {
		t.Fatalf("expected error on empty APIKey")
	}
}
