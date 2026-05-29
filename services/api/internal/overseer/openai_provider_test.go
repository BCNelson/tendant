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

func newOpenAIFixtureServer(t *testing.T, status int, responseBody string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/chat/completions" {
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

func TestOpenAIProvider_HappyPath(t *testing.T) {
	t.Parallel()
	body := `{
		"id": "chatcmpl-1",
		"model": "gpt-4.1-mini",
		"choices": [{
			"message": {
				"role": "assistant",
				"content": "",
				"tool_calls": [{
					"id": "call_1",
					"type": "function",
					"function": {
						"name": "verdict_response",
						"arguments": "{\"verdict\":\"approve\",\"summary\":\"benign\",\"considered_fields\":[\"payload.body\"]}"
					}
				}]
			}
		}],
		"usage": {"prompt_tokens": 100, "completion_tokens": 12}
	}`
	srv := newOpenAIFixtureServer(t, 200, body)

	p, err := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL, ModelID: "gpt-4.1-mini"})
	if err != nil {
		t.Fatalf("ctor: %v", err)
	}
	resp, err := p.Call(context.Background(), PromptPayload{ConcreteCall: `{"to":"x"}`})
	if err != nil {
		t.Fatalf("call: %v", err)
	}
	if resp.Verdict != "approve" {
		t.Fatalf("verdict=%q", resp.Verdict)
	}
	if resp.Evidence.Summary != "benign" {
		t.Fatalf("summary=%q", resp.Evidence.Summary)
	}
	if len(resp.Evidence.ConsideredFields) != 1 || resp.Evidence.ConsideredFields[0] != "payload.body" {
		t.Fatalf("considered=%v", resp.Evidence.ConsideredFields)
	}
	if resp.TokensIn != 100 || resp.TokensOut != 12 {
		t.Fatalf("tokens: in=%d out=%d", resp.TokensIn, resp.TokensOut)
	}
}

func TestOpenAIProvider_MalformedArguments_TransientErr(t *testing.T) {
	t.Parallel()
	body := `{
		"choices": [{"message": {"tool_calls": [{
			"type": "function",
			"function": {"name": "verdict_response", "arguments": "not-json"}
		}]}}],
		"usage": {"prompt_tokens": 1, "completion_tokens": 1}
	}`
	srv := newOpenAIFixtureServer(t, 200, body)
	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestOpenAIProvider_MissingVerdict_TransientErr(t *testing.T) {
	t.Parallel()
	body := `{
		"choices": [{"message": {"tool_calls": [{
			"type": "function",
			"function": {"name": "verdict_response", "arguments": "{\"summary\":\"no verdict\"}"}
		}]}}],
		"usage": {"prompt_tokens": 1, "completion_tokens": 1}
	}`
	srv := newOpenAIFixtureServer(t, 200, body)
	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestOpenAIProvider_NoToolCall_TransientErr(t *testing.T) {
	t.Parallel()
	body := `{
		"choices": [{"message": {"content": "I cannot do that"}}],
		"usage": {"prompt_tokens": 1, "completion_tokens": 1}
	}`
	srv := newOpenAIFixtureServer(t, 200, body)
	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestOpenAIProvider_NonOKStatus_TransientErr(t *testing.T) {
	t.Parallel()
	srv := newOpenAIFixtureServer(t, http.StatusBadGateway, `{"error":"upstream"}`)
	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{ConcreteCall: "{}"})
	if !errors.Is(err, ErrProviderTransient) {
		t.Fatalf("want ErrProviderTransient, got %v", err)
	}
}

func TestOpenAIProvider_RequestStructure_TwoMessagesAndToolChoice(t *testing.T) {
	t.Parallel()
	var seenBody string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		buf := make([]byte, 4096)
		n, _ := r.Body.Read(buf)
		seenBody = string(buf[:n])
		_, _ = w.Write([]byte(`{
			"choices":[{"message":{"tool_calls":[{
				"type":"function",
				"function":{"name":"verdict_response","arguments":"{\"verdict\":\"approve\",\"summary\":\"ok\"}"}
			}]}}],
			"usage":{"prompt_tokens":1,"completion_tokens":1}
		}`))
	}))
	t.Cleanup(srv.Close)

	p, _ := NewOpenAIProvider(OpenAIConfig{APIKey: "sk-test", BaseURL: srv.URL})
	_, err := p.Call(context.Background(), PromptPayload{
		SystemPreamble:    "PREAMBLE",
		OwnerInstructions: "OWNER-RULE",
		ToolMetadata:      `{"name":"send-email"}`,
		ConcreteCall:      `{"body":"hi"}`,
	})
	if err != nil {
		t.Fatalf("call: %v", err)
	}
	var req openaiRequest
	if err := json.Unmarshal([]byte(seenBody), &req); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if len(req.Messages) != 2 {
		t.Fatalf("want exactly 2 messages (system + user), got %d", len(req.Messages))
	}
	if req.Messages[0].Role != "system" {
		t.Fatalf("first message must be system, got %s", req.Messages[0].Role)
	}
	if req.Messages[1].Role != "user" {
		t.Fatalf("second message must be user, got %s", req.Messages[1].Role)
	}
	if !strings.Contains(req.Messages[0].Content, "OWNER-RULE") {
		t.Fatalf("system slot missing OWNER-RULE")
	}
	if !strings.Contains(req.Messages[1].Content, "hi") {
		t.Fatalf("user slot missing concrete call")
	}
	fn, _ := req.ToolChoice["function"].(map[string]any)
	if fn["name"] != "verdict_response" {
		t.Fatalf("tool_choice must force verdict_response: %v", req.ToolChoice)
	}
}

func TestOpenAIProvider_EmptyAPIKey_Errors(t *testing.T) {
	t.Parallel()
	_, err := NewOpenAIProvider(OpenAIConfig{APIKey: ""})
	if err == nil {
		t.Fatalf("expected error on empty APIKey")
	}
}
