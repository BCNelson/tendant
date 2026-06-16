package feedback

import (
	"context"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/llm"
)

// fakeClient is a deterministic llm.Client. With resps set it returns one queued
// Response per Chat call (and records every Request in gots), driving a
// multi-call gather→finalize sequence; otherwise it returns the single resp.
type fakeClient struct {
	resp  llm.Response
	resps []llm.Response
	err   error
	got   llm.Request
	gots  []llm.Request
	i     int
}

func (f *fakeClient) Provider() string { return "fake" }
func (f *fakeClient) Model() string    { return "fake-model" }
func (f *fakeClient) Chat(_ context.Context, req llm.Request) (llm.Response, error) {
	f.got = req
	f.gots = append(f.gots, req)
	if len(f.resps) > 0 {
		r := f.resps[f.i]
		if f.i < len(f.resps)-1 {
			f.i++
		}
		return r, f.err
	}
	return f.resp, f.err
}

func toolCall(args string) llm.ToolCall {
	return llm.ToolCall{ID: "1", Name: "feedback_turn", Arguments: args}
}

func TestParseTurn(t *testing.T) {
	tests := []struct {
		name      string
		resp      llm.Response
		wantReply string
		wantDraft string
	}{
		{
			name:      "tool call with both fields",
			resp:      llm.Response{ToolCalls: []llm.ToolCall{toolCall(`{"reply":"How did it go?","draft_guidance":"Always cite sources."}`)}},
			wantReply: "How did it go?",
			wantDraft: "Always cite sources.",
		},
		{
			name:      "tool call reply only, empty draft",
			resp:      llm.Response{ToolCalls: []llm.ToolCall{toolCall(`{"reply":"Tell me more.","draft_guidance":""}`)}},
			wantReply: "Tell me more.",
			wantDraft: "",
		},
		{
			// Ollama et al. ignore tool_choice on multi-turn and emit the JSON as
			// plain text content. We must salvage it rather than discard it.
			name:      "json emitted as text content, no tool call",
			resp:      llm.Response{Content: `{"reply":"Got it.","draft_guidance":"Prefer concise replies."}`},
			wantReply: "Got it.",
			wantDraft: "Prefer concise replies.",
		},
		{
			// Plain prose (the most common small-model failure mode) becomes the
			// reply so the conversation stays alive; the caller keeps the prior draft.
			name:      "plain prose content, no tool call",
			resp:      llm.Response{Content: "  Thanks for the detail — what tripped the agent up?  "},
			wantReply: "Thanks for the detail — what tripped the agent up?",
			wantDraft: "",
		},
		{
			// A tool call that decodes but carries neither field falls through to
			// the text content.
			name:      "empty tool call falls back to content",
			resp:      llm.Response{ToolCalls: []llm.ToolCall{toolCall(`{"reply":"","draft_guidance":""}`)}, Content: "Anything else?"},
			wantReply: "Anything else?",
			wantDraft: "",
		},
		{
			name:      "malformed tool args falls back to content",
			resp:      llm.Response{ToolCalls: []llm.ToolCall{toolCall("not json")}, Content: "Recovered reply."},
			wantReply: "Recovered reply.",
			wantDraft: "",
		},
		{
			name:      "nothing usable",
			resp:      llm.Response{},
			wantReply: "",
			wantDraft: "",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			reply, draft := parseTurn(tc.resp)
			if reply != tc.wantReply {
				t.Errorf("reply = %q, want %q", reply, tc.wantReply)
			}
			if draft != tc.wantDraft {
				t.Errorf("draft = %q, want %q", draft, tc.wantDraft)
			}
		})
	}
}

func TestLLMConverser_Reply_SalvagesPlainText(t *testing.T) {
	// Reproduces the observed Ollama multi-turn behavior: no tool call, the
	// model's words arrive only in Content. The converser must surface them
	// (non-empty reply) so the resolver does not substitute its canned fallback.
	fc := &fakeClient{resp: llm.Response{Content: "What would you change next time?"}}
	c := NewLLMConverser(fc, nil)

	reply, draft, _, err := c.Reply(context.Background(), TaskSummary{Title: "Write a poem"}, []Turn{
		{Role: "agent", Content: "How did it go?"},
		{Role: "user", Content: "The agent didn't write the poem itself."},
	})
	if err != nil {
		t.Fatalf("Reply error: %v", err)
	}
	if reply != "What would you change next time?" {
		t.Errorf("reply = %q, want salvaged content", reply)
	}
	if draft != "" {
		t.Errorf("draft = %q, want empty", draft)
	}

	// The request must force the structured tool and carry the full thread:
	// the COMPLETED_TASK seed plus the two conversation turns.
	if fc.got.ForceTool != "feedback_turn" {
		t.Errorf("ForceTool = %q, want feedback_turn", fc.got.ForceTool)
	}
	// It must also request JSON-object output so OpenAI-compatible endpoints
	// (Ollama) that ignore tool_choice still emit a decodable draft.
	if fc.got.ResponseFormat != "json_object" {
		t.Errorf("ResponseFormat = %q, want json_object", fc.got.ResponseFormat)
	}
	if len(fc.got.Messages) != 3 {
		t.Fatalf("got %d messages, want 3 (seed + 2 turns)", len(fc.got.Messages))
	}
	if got := fc.got.Messages[1].Role; got != "assistant" {
		t.Errorf("turn[0] role = %q, want assistant", got)
	}
	if got := fc.got.Messages[2].Role; got != "user" {
		t.Errorf("turn[1] role = %q, want user", got)
	}
}

// fakeRetriever is a deterministic Retriever for the gather-loop test.
type fakeRetriever struct {
	digest   TaskContext
	outcomes string
}

func (f *fakeRetriever) Digest(context.Context, uuid.UUID) (TaskContext, error) {
	return f.digest, nil
}
func (f *fakeRetriever) ToolOutcomes(context.Context, uuid.UUID) (string, error) {
	return f.outcomes, nil
}
func (f *fakeRetriever) AgentTranscript(context.Context, uuid.UUID) (string, error) {
	return `{"runs":[]}`, nil
}
func (f *fakeRetriever) AuditTrail(context.Context, uuid.UUID) (string, error) {
	return `{"audit":[]}`, nil
}
func (f *fakeRetriever) ExistingGuidance(context.Context) (string, error) {
	return `{"guidance":[]}`, nil
}

func TestLLMConverser_GatherThenFinalize(t *testing.T) {
	// Round 1 (gather): the model asks for tool outcomes. Round 2 (gather): it
	// emits plain text and no tool call, ending the gather phase. Round 3
	// (finalize): the forced feedback_turn yields the structured result.
	sc := &fakeClient{resps: []llm.Response{
		{ToolCalls: []llm.ToolCall{{Name: ToolGetToolOutcomes, Arguments: "{}"}}},
		{Content: "Let me wrap up."},
		{ToolCalls: []llm.ToolCall{toolCall(`{"reply":"I see send-email was flagged.","draft_guidance":"Double-check recipients before sending email."}`)}},
	}}
	ret := &fakeRetriever{
		digest:   TaskContext{ToolsRun: 1, ToolsFlagged: 1, Summary: "1 tool call(s) (1 flagged bad)"},
		outcomes: `{"outcomes":[{"tool":"send-email","outcome":"bad"}]}`,
	}
	c := NewLLMConverser(sc, ret)

	reply, draft, consulted, err := c.Open(context.Background(), TaskSummary{TaskID: uuid.New(), Title: "Email the team"})
	if err != nil {
		t.Fatalf("Open error: %v", err)
	}
	if reply != "I see send-email was flagged." {
		t.Errorf("reply = %q", reply)
	}
	if draft != "Double-check recipients before sending email." {
		t.Errorf("draft = %q", draft)
	}
	if len(consulted) != 1 || consulted[0] != ToolGetToolOutcomes {
		t.Errorf("consulted = %v, want [%s]", consulted, ToolGetToolOutcomes)
	}

	// Three Chat calls: two gather rounds + finalize.
	if len(sc.gots) != 3 {
		t.Fatalf("got %d Chat calls, want 3 (2 gather + finalize)", len(sc.gots))
	}
	// The seed must carry the front-loaded digest.
	if seed := sc.gots[0].Messages[0].Content; !strings.Contains(seed, "[TASK_CONTEXT]") || !strings.Contains(seed, "flagged bad") {
		t.Errorf("seed missing digest: %q", seed)
	}
	// The finalize request must include the tool result fed back as a user turn.
	last := sc.gots[2].Messages
	var sawResult bool
	for _, m := range last {
		if strings.Contains(m.Content, "[CONTEXT:"+ToolGetToolOutcomes+"]") && strings.Contains(m.Content, "send-email") {
			sawResult = true
		}
	}
	if !sawResult {
		t.Errorf("finalize messages missing fed-back context result: %+v", last)
	}
	// Finalize forces the structured tool.
	if sc.gots[2].ForceTool != "feedback_turn" {
		t.Errorf("finalize ForceTool = %q, want feedback_turn", sc.gots[2].ForceTool)
	}
}

func TestStubConverser(t *testing.T) {
	var s StubConverser
	if s.Label() != "stub" {
		t.Errorf("Label = %q, want stub", s.Label())
	}

	open, draft, consulted, err := s.Open(context.Background(), TaskSummary{})
	if err != nil || open == "" {
		t.Fatalf("Open = (%q, %q, %v)", open, draft, err)
	}
	if draft != "" {
		t.Errorf("Open draft = %q, want empty", draft)
	}
	if consulted != nil {
		t.Errorf("Open consulted = %v, want nil (stub uses no tools)", consulted)
	}

	// Reply echoes the most recent user message as the draft.
	reply, draft, _, err := s.Reply(context.Background(), TaskSummary{}, []Turn{
		{Role: "agent", Content: "opening"},
		{Role: "user", Content: "be more concise"},
	})
	if err != nil || reply == "" {
		t.Fatalf("Reply = (%q, %q, %v)", reply, draft, err)
	}
	if draft != "be more concise" {
		t.Errorf("Reply draft = %q, want echo of last user message", draft)
	}
}
