package feedback

import (
	"context"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/agent"
)

// fakeEngine is a deterministic ConverseEngine. It records the ConverseConfig it
// was handed and returns a scripted result, so the converser's seed/history/tool
// wiring + result decoding can be asserted without a model.
type fakeEngine struct {
	got agent.ConverseConfig
	res agent.ConverseResult
	err error
}

func (f *fakeEngine) Converse(_ context.Context, cc agent.ConverseConfig) (agent.ConverseResult, error) {
	f.got = cc
	return f.res, f.err
}

func answerCall(args string) agent.ChatResponse {
	return agent.ChatResponse{ToolCalls: []agent.ToolCall{{ID: "1", Name: feedbackTurnName, Payload: args}}}
}

func TestParseTurn(t *testing.T) {
	tests := []struct {
		name      string
		resp      agent.ChatResponse
		wantReply string
		wantDraft string
	}{
		{
			name:      "tool call with both fields",
			resp:      answerCall(`{"reply":"How did it go?","draft_guidance":"Always cite sources."}`),
			wantReply: "How did it go?",
			wantDraft: "Always cite sources.",
		},
		{
			name:      "tool call reply only, empty draft",
			resp:      answerCall(`{"reply":"Tell me more.","draft_guidance":""}`),
			wantReply: "Tell me more.",
			wantDraft: "",
		},
		{
			// Ollama et al. ignore tool_choice on multi-turn and emit the JSON as
			// plain text content. We must salvage it rather than discard it.
			name:      "json emitted as text content, no tool call",
			resp:      agent.ChatResponse{Content: `{"reply":"Got it.","draft_guidance":"Prefer concise replies."}`},
			wantReply: "Got it.",
			wantDraft: "Prefer concise replies.",
		},
		{
			// Plain prose (the most common small-model failure mode) becomes the
			// reply so the conversation stays alive; the caller keeps the prior draft.
			name:      "plain prose content, no tool call",
			resp:      agent.ChatResponse{Content: "  Thanks for the detail — what tripped the agent up?  "},
			wantReply: "Thanks for the detail — what tripped the agent up?",
			wantDraft: "",
		},
		{
			// A tool call that decodes but carries neither field falls through to
			// the text content.
			name:      "empty tool call falls back to content",
			resp:      agent.ChatResponse{ToolCalls: []agent.ToolCall{{Name: feedbackTurnName, Payload: `{"reply":"","draft_guidance":""}`}}, Content: "Anything else?"},
			wantReply: "Anything else?",
			wantDraft: "",
		},
		{
			name:      "malformed tool args falls back to content",
			resp:      agent.ChatResponse{ToolCalls: []agent.ToolCall{{Name: feedbackTurnName, Payload: "not json"}}, Content: "Recovered reply."},
			wantReply: "Recovered reply.",
			wantDraft: "",
		},
		{
			name:      "nothing usable",
			resp:      agent.ChatResponse{},
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

func TestLLMConverser_Reply_BuildsHistoryAndDecodes(t *testing.T) {
	// A nil retriever ⇒ no gather phase: the converser hands the engine the seed
	// plus the mapped conversation turns and decodes the engine's structured reply.
	fe := &fakeEngine{res: agent.ConverseResult{Response: answerCall(`{"reply":"What would you change?","draft_guidance":"Draft something before handing off."}`)}}
	c := NewLLMConverser(fe, nil, nil, "fake-model")

	reply, draft, _, err := c.Reply(context.Background(), TaskSummary{Title: "Write a poem"}, []Turn{
		{Role: "agent", Content: "How did it go?"},
		{Role: "user", Content: "The agent didn't write the poem itself."},
	})
	if err != nil {
		t.Fatalf("Reply error: %v", err)
	}
	if reply != "What would you change?" {
		t.Errorf("reply = %q", reply)
	}
	if draft != "Draft something before handing off." {
		t.Errorf("draft = %q", draft)
	}

	// The engine must be handed the forced output tool and the full thread: the
	// COMPLETED_TASK seed plus the two conversation turns, roles mapped.
	if fe.got.OutputTool.Name != feedbackTurnName {
		t.Errorf("OutputTool = %q, want %s", fe.got.OutputTool.Name, feedbackTurnName)
	}
	if len(fe.got.Messages) != 3 {
		t.Fatalf("got %d messages, want 3 (seed + 2 turns)", len(fe.got.Messages))
	}
	if !strings.Contains(fe.got.Messages[0].Content, "[COMPLETED_TASK]") {
		t.Errorf("seed missing COMPLETED_TASK: %q", fe.got.Messages[0].Content)
	}
	if got := fe.got.Messages[1].Role; got != "assistant" {
		t.Errorf("turn[0] role = %q, want assistant", got)
	}
	if got := fe.got.Messages[2].Role; got != "user" {
		t.Errorf("turn[1] role = %q, want user", got)
	}
	// No retriever ⇒ the gather phase is disabled (no context tools / toolset).
	if fe.got.Toolset != nil || len(fe.got.ContextTools) != 0 {
		t.Errorf("gather phase should be off with a nil retriever")
	}
}

// fakeRetriever is a deterministic Retriever for the gather-wiring test.
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

func TestLLMConverser_Open_WiresGatherAndDigest(t *testing.T) {
	// With a Retriever wired, Open front-loads the digest into the seed and turns
	// on the gather phase: context tools + a read-only toolset + the early-return
	// validator. The structured result is decoded and consulted is passed through.
	fe := &fakeEngine{res: agent.ConverseResult{
		Response:  answerCall(`{"reply":"I see send-email was flagged.","draft_guidance":"Double-check recipients before sending email."}`),
		Consulted: []string{ToolGetToolOutcomes},
	}}
	ret := &fakeRetriever{
		digest:   TaskContext{ToolsRun: 1, ToolsFlagged: 1, Summary: "1 tool call(s) (1 flagged bad)"},
		outcomes: `{"outcomes":[{"tool":"send-email","outcome":"bad"}]}`,
	}
	c := NewLLMConverser(fe, nil, ret, "fake-model")

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

	// The seed carries the front-loaded digest.
	if seed := fe.got.Messages[0].Content; !strings.Contains(seed, "[TASK_CONTEXT]") || !strings.Contains(seed, "flagged bad") {
		t.Errorf("seed missing digest: %q", seed)
	}
	// The gather phase is wired: all four context tools, a dispatching toolset, and
	// the early-return validator.
	if len(fe.got.ContextTools) != len(contextToolDefs) {
		t.Errorf("ContextTools = %d, want %d", len(fe.got.ContextTools), len(contextToolDefs))
	}
	if fe.got.Toolset == nil {
		t.Errorf("Toolset must be wired when a retriever is present")
	}
	if fe.got.ValidOutput == nil {
		t.Errorf("ValidOutput must be set for the gather-phase early-return gate")
	}
	// The toolset dispatches the retriever's reads (and rejects unknown names).
	if out, ok := fe.got.Toolset.Dispatch(context.Background(), ToolGetToolOutcomes, uuid.New()); !ok || !strings.Contains(out, "send-email") {
		t.Errorf("toolset dispatch = (%q,%v), want the outcomes JSON", out, ok)
	}
	if _, ok := fe.got.Toolset.Dispatch(context.Background(), "not_a_tool", uuid.New()); ok {
		t.Errorf("toolset must reject an unknown tool name")
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

// validFeedbackTurn gates the gather-phase early return.
func TestValidFeedbackTurn(t *testing.T) {
	if !validFeedbackTurn(`{"reply":"hi","draft_guidance":""}`) {
		t.Errorf("a decodable turn must validate")
	}
	if validFeedbackTurn("not json") {
		t.Errorf("malformed args must not validate")
	}
	if validFeedbackTurn(`{"reply":"","draft_guidance":""}`) {
		t.Errorf("an empty turn must not validate")
	}
}
