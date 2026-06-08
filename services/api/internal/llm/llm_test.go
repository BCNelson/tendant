package llm

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// fixtureServer returns an httptest server that records the last request body
// and path, and replies with status + responseBody.
func fixtureServer(t *testing.T, status int, responseBody string, seen *string, seenPath *string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		b := make([]byte, 1<<16)
		n, _ := r.Body.Read(b)
		if seen != nil {
			*seen = string(b[:n])
		}
		if seenPath != nil {
			*seenPath = r.URL.Path
		}
		if status != 0 {
			w.WriteHeader(status)
		}
		_, _ = w.Write([]byte(responseBody))
	}))
	t.Cleanup(srv.Close)
	return srv
}

func TestOpenAIClient_ForceTool_RequestAndParse(t *testing.T) {
	t.Parallel()
	var seen, path string
	body := `{"model":"gpt-4.1-mini","choices":[{"message":{"content":"","tool_calls":[{"id":"call_1","type":"function","function":{"name":"verdict_response","arguments":"{\"verdict\":\"approve\"}"}}]}}],"usage":{"prompt_tokens":7,"completion_tokens":3}}`
	srv := fixtureServer(t, 200, body, &seen, &path)

	c, err := NewClient(Connection{Provider: "openai", BaseURL: srv.URL, APIKey: "sk", Model: "gpt-4.1-mini"})
	if err != nil {
		t.Fatal(err)
	}
	resp, err := c.Chat(context.Background(), Request{
		System:    "SYS",
		Messages:  []Message{{Role: "user", Content: "hello"}},
		Tools:     []Tool{{Name: "verdict_response", Schema: map[string]any{"type": "object"}}},
		ForceTool: "verdict_response",
	})
	if err != nil {
		t.Fatalf("chat: %v", err)
	}
	if path != "/v1/chat/completions" {
		t.Fatalf("path=%q", path)
	}
	if len(resp.ToolCalls) != 1 || resp.ToolCalls[0].Name != "verdict_response" {
		t.Fatalf("toolcalls=%+v", resp.ToolCalls)
	}
	if resp.TokensIn != 7 || resp.TokensOut != 3 {
		t.Fatalf("tokens in=%d out=%d", resp.TokensIn, resp.TokensOut)
	}
	var req openaiReq
	if err := json.Unmarshal([]byte(seen), &req); err != nil {
		t.Fatalf("decode seen: %v", err)
	}
	if len(req.Messages) != 2 || req.Messages[0].Role != "system" || req.Messages[1].Role != "user" {
		t.Fatalf("messages=%+v", req.Messages)
	}
	tc, _ := req.ToolChoice.(map[string]any)
	fn, _ := tc["function"].(map[string]any)
	if fn["name"] != "verdict_response" {
		t.Fatalf("tool_choice not forced: %v", req.ToolChoice)
	}
}

func TestOpenAIClient_Status500_Transient(t *testing.T) {
	t.Parallel()
	srv := fixtureServer(t, 500, `{"error":"down"}`, nil, nil)
	c, _ := NewClient(Connection{Provider: "openai", BaseURL: srv.URL, APIKey: "sk"})
	_, err := c.Chat(context.Background(), Request{})
	if !errors.Is(err, ErrTransient) {
		t.Fatalf("want ErrTransient, got %v", err)
	}
}

func TestAnthropicClient_SlotMapping_SystemVsUser(t *testing.T) {
	t.Parallel()
	var seen string
	body := `{"model":"claude-sonnet-4-6","content":[{"type":"tool_use","name":"verdict_response","id":"t1","input":{"verdict":"approve"}}],"usage":{"input_tokens":11,"output_tokens":2}}`
	srv := fixtureServer(t, 200, body, &seen, nil)

	c, _ := NewClient(Connection{Provider: "anthropic", BaseURL: srv.URL, APIKey: "sk"})
	resp, err := c.Chat(context.Background(), Request{
		System:    "PREAMBLE",
		Messages:  []Message{{Role: "user", Content: "CONCRETE"}},
		Tools:     []Tool{{Name: "verdict_response"}},
		ForceTool: "verdict_response",
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(resp.ToolCalls) != 1 || resp.ToolCalls[0].Arguments != `{"verdict":"approve"}` {
		t.Fatalf("toolcall=%+v", resp.ToolCalls)
	}
	var req anthropicReq
	if err := json.Unmarshal([]byte(seen), &req); err != nil {
		t.Fatal(err)
	}
	if req.System != "PREAMBLE" {
		t.Fatalf("system=%q", req.System)
	}
	if len(req.Messages) != 1 || !strings.Contains(req.Messages[0].Content, "CONCRETE") {
		t.Fatalf("messages=%+v", req.Messages)
	}
	if req.ToolChoice["name"] != "verdict_response" {
		t.Fatalf("tool_choice=%v", req.ToolChoice)
	}
	// A no-parameter tool must still carry a valid object schema.
	if req.Tools[0].InputSchema["type"] != "object" {
		t.Fatalf("tool schema=%v", req.Tools[0].InputSchema)
	}
}

func TestAnthropicClient_MalformedBody_Transient(t *testing.T) {
	t.Parallel()
	srv := fixtureServer(t, 200, "not-json", nil, nil)
	c, _ := NewClient(Connection{Provider: "anthropic", BaseURL: srv.URL, APIKey: "sk"})
	_, err := c.Chat(context.Background(), Request{})
	if !errors.Is(err, ErrTransient) {
		t.Fatalf("want ErrTransient, got %v", err)
	}
}

func TestGeminiClient_ForceTool_PathAndParse(t *testing.T) {
	t.Parallel()
	var seen, path string
	body := `{"candidates":[{"content":{"parts":[{"functionCall":{"name":"verdict_response","args":{"verdict":"approve"}}}]}}],"usageMetadata":{"promptTokenCount":9,"candidatesTokenCount":4}}`
	srv := fixtureServer(t, 200, body, &seen, &path)

	c, _ := NewClient(Connection{Provider: "gemini", BaseURL: srv.URL, APIKey: "k", Model: "gemini-2.0-flash"})
	resp, err := c.Chat(context.Background(), Request{
		System:    "SYS",
		Messages:  []Message{{Role: "user", Content: "hi"}},
		Tools:     []Tool{{Name: "verdict_response"}},
		ForceTool: "verdict_response",
	})
	if err != nil {
		t.Fatal(err)
	}
	if path != "/v1beta/models/gemini-2.0-flash:generateContent" {
		t.Fatalf("path=%q", path)
	}
	if len(resp.ToolCalls) != 1 || resp.ToolCalls[0].Name != "verdict_response" {
		t.Fatalf("toolcalls=%+v", resp.ToolCalls)
	}
	if !strings.Contains(resp.ToolCalls[0].Arguments, "approve") {
		t.Fatalf("args=%q", resp.ToolCalls[0].Arguments)
	}
	if resp.TokensIn != 9 || resp.TokensOut != 4 {
		t.Fatalf("tokens in=%d out=%d", resp.TokensIn, resp.TokensOut)
	}
	var req geminiReq
	if err := json.Unmarshal([]byte(seen), &req); err != nil {
		t.Fatal(err)
	}
	if req.SystemInstruction == nil || req.ToolConfig == nil || req.ToolConfig.FunctionCallingConfig.Mode != "ANY" {
		t.Fatalf("req shape: sys=%v toolcfg=%v", req.SystemInstruction, req.ToolConfig)
	}
	if req.Contents[0].Role != "user" {
		t.Fatalf("role=%q", req.Contents[0].Role)
	}
}

func TestBedrockClient_SignsAndParses(t *testing.T) {
	t.Parallel()
	var auth, path, amzDate string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		auth = r.Header.Get("Authorization")
		amzDate = r.Header.Get("X-Amz-Date")
		path = r.URL.Path
		_, _ = w.Write([]byte(`{"content":[{"type":"tool_use","name":"verdict_response","id":"t","input":{"verdict":"approve"}}],"usage":{"input_tokens":5,"output_tokens":1}}`))
	}))
	t.Cleanup(srv.Close)

	bc, err := newBedrockClient(Connection{
		Provider: "bedrock", BaseURL: srv.URL, Region: "us-east-1",
		Model:           "anthropic.claude-3-5-sonnet-20241022-v2:0",
		AccessKeyID:     "AKIDEXAMPLE",
		SecretAccessKey: "secret",
	})
	if err != nil {
		t.Fatal(err)
	}
	bc.nowFn = func() time.Time { return time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC) }

	resp, err := bc.Chat(context.Background(), Request{
		Messages:  []Message{{Role: "user", Content: "x"}},
		Tools:     []Tool{{Name: "verdict_response"}},
		ForceTool: "verdict_response",
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(resp.ToolCalls) != 1 {
		t.Fatalf("toolcalls=%+v", resp.ToolCalls)
	}
	if !strings.HasPrefix(auth, "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20260102/us-east-1/bedrock/aws4_request") {
		t.Fatalf("auth=%q", auth)
	}
	if !strings.Contains(auth, "SignedHeaders=host;x-amz-content-sha256;x-amz-date") {
		t.Fatalf("signed headers wrong: %q", auth)
	}
	if amzDate != "20260102T030405Z" {
		t.Fatalf("amzDate=%q", amzDate)
	}
	if path != "/model/anthropic.claude-3-5-sonnet-20241022-v2:0/invoke" {
		t.Fatalf("path=%q", path)
	}
}

func TestSigV4_Deterministic(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC)
	mk := func() string {
		req, _ := http.NewRequest(http.MethodPost, "https://bedrock-runtime.us-east-1.amazonaws.com/model/m/invoke", nil)
		signV4(req, []byte(`{"a":1}`), sigv4Creds{AccessKeyID: "AKID", SecretAccessKey: "sk"}, "bedrock", "us-east-1", now)
		return req.Header.Get("Authorization")
	}
	if a, b := mk(), mk(); a != b {
		t.Fatalf("non-deterministic signature:\n%s\n%s", a, b)
	}
}

func TestSigV4_SessionTokenSignedAndSent(t *testing.T) {
	t.Parallel()
	req, _ := http.NewRequest(http.MethodPost, "https://x.example.com/p", nil)
	signV4(req, []byte("{}"), sigv4Creds{AccessKeyID: "A", SecretAccessKey: "s", SessionToken: "tok"}, "bedrock", "us-west-2", time.Unix(0, 0))
	if req.Header.Get("X-Amz-Security-Token") != "tok" {
		t.Fatal("missing session token header")
	}
	if !strings.Contains(req.Header.Get("Authorization"), "x-amz-security-token") {
		t.Fatalf("session token not in signed headers: %q", req.Header.Get("Authorization"))
	}
}

func TestRegistry_NamedConnections(t *testing.T) {
	t.Parallel()
	r := NewRegistry()
	if err := r.Register(Connection{Name: "a", Provider: "openai", BaseURL: "http://a", Model: "m1"}); err != nil {
		t.Fatal(err)
	}
	if err := r.Register(Connection{Name: "b", Provider: "openai", BaseURL: "http://b", Model: "m2"}); err != nil {
		t.Fatal(err)
	}
	if err := r.Register(Connection{Name: "a", Provider: "openai"}); err == nil {
		t.Fatal("expected duplicate error")
	}
	if err := r.Register(Connection{Name: "", Provider: "openai"}); err == nil {
		t.Fatal("expected blank-name error")
	}
	ca, ok := r.Get("a")
	if !ok || ca.Model() != "m1" {
		t.Fatalf("get a: ok=%v model=%v", ok, ca)
	}
	cb, _ := r.Get("b")
	if cb.Model() != "m2" {
		t.Fatalf("two same-provider connections must differ: %v", cb.Model())
	}
	if got := r.Names(); len(got) != 2 || got[0] != "a" || got[1] != "b" {
		t.Fatalf("names=%v", got)
	}
}

func TestNewClient_UnknownProvider(t *testing.T) {
	t.Parallel()
	if _, err := NewClient(Connection{Name: "x", Provider: "mystery"}); err == nil {
		t.Fatal("expected unknown-provider error")
	}
}

func TestLogClient_EchoesForcedTool(t *testing.T) {
	t.Parallel()
	c, _ := NewClient(Connection{Provider: "log"})
	resp, err := c.Chat(context.Background(), Request{ForceTool: "verdict_response"})
	if err != nil {
		t.Fatal(err)
	}
	if len(resp.ToolCalls) != 1 || resp.ToolCalls[0].Name != "verdict_response" {
		t.Fatalf("toolcalls=%+v", resp.ToolCalls)
	}
}
