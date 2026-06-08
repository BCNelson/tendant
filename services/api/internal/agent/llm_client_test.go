package agent

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/bcnelson/tendant/services/api/internal/llm"
)

func TestLLMAgentClient_MapsRequestAndResponse(t *testing.T) {
	t.Parallel()
	var seen string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		b := make([]byte, 1<<16)
		n, _ := r.Body.Read(b)
		seen = string(b[:n])
		_, _ = w.Write([]byte(`{"choices":[{"message":{"content":"hi","tool_calls":[{"id":"c1","type":"function","function":{"name":"send","arguments":"{\"to\":\"x\"}"}}]}}],"usage":{"prompt_tokens":4,"completion_tokens":2}}`))
	}))
	t.Cleanup(srv.Close)

	client, err := llm.NewClient(llm.Connection{Provider: "openai", BaseURL: srv.URL, APIKey: "k"})
	if err != nil {
		t.Fatal(err)
	}
	ac := NewLLMAgentClient(client)
	resp, err := ac.Chat(context.Background(), ChatRequest{
		System:   "SYS",
		Messages: []Message{{Role: "user", Content: "do it"}},
		Tools:    []ToolDef{{Name: "send", Description: "send", Schema: `{"type":"object"}`}},
	})
	if err != nil {
		t.Fatal(err)
	}
	if resp.Content != "hi" || len(resp.ToolCalls) != 1 {
		t.Fatalf("resp=%+v", resp)
	}
	if resp.ToolCalls[0].Name != "send" || resp.ToolCalls[0].Payload != `{"to":"x"}` {
		t.Fatalf("toolcall=%+v", resp.ToolCalls[0])
	}
	if resp.TokensIn != 4 || resp.TokensOut != 2 {
		t.Fatalf("tokens in=%d out=%d", resp.TokensIn, resp.TokensOut)
	}
	if !strings.Contains(seen, "SYS") || !strings.Contains(seen, "do it") {
		t.Fatalf("request body missing fields: %s", seen)
	}
}

func TestNewAgentModelClient_DefaultsToLog(t *testing.T) {
	t.Parallel()
	if _, ok := NewAgentModelClient("log", "", "").(*LogAgentClient); !ok {
		t.Fatal("log provider should yield LogAgentClient")
	}
	if _, ok := NewAgentModelClient("mystery", "", "").(*LogAgentClient); !ok {
		t.Fatal("unknown provider should yield LogAgentClient")
	}
	if _, ok := NewAgentModelClient("openai", "k", "gpt").(*llmAgentClient); !ok {
		t.Fatal("openai should yield llm-backed client")
	}
}
