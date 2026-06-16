package agent

import (
	"context"
	"strings"
	"testing"

	"github.com/google/uuid"
)

// fakeModelClient is a deterministic AgentModelClient. It records every request
// and returns one queued response per Chat call (the last repeats once exhausted).
type fakeModelClient struct {
	resps []ChatResponse
	gots  []ChatRequest
	i     int
}

func (f *fakeModelClient) Chat(_ context.Context, req ChatRequest) (ChatResponse, error) {
	f.gots = append(f.gots, req)
	if len(f.resps) == 0 {
		return ChatResponse{}, nil
	}
	r := f.resps[f.i]
	if f.i < len(f.resps)-1 {
		f.i++
	}
	return r, nil
}

// fakeToolset dispatches read-only context tools from a fixed map.
type fakeToolset struct{ out map[string]string }

func (f fakeToolset) Dispatch(_ context.Context, name string, _ uuid.UUID) (string, bool) {
	v, ok := f.out[name]
	return v, ok
}

var answerTool = ToolDef{Name: "answer", Description: "Speak.", Schema: `{"type":"object"}`}

func TestConverse_GatherThenFinalize(t *testing.T) {
	// Round 1 (gather): the model calls a context tool. Round 2 (gather): plain
	// text, no tool call, ending the gather phase. Round 3 (finalize): the forced
	// output tool produces the structured answer.
	fc := &fakeModelClient{resps: []ChatResponse{
		{ToolCalls: []ToolCall{{Name: "ctx_a", Payload: "{}"}}},
		{Content: "Let me wrap up."},
		{ToolCalls: []ToolCall{{Name: "answer", Payload: `{"reply":"done"}`}}},
	}}
	r := &Runner{Client: fc} // nil Queries ⇒ appendGuidance is a no-op
	res, err := r.Converse(context.Background(), ConverseConfig{
		TaskID:       uuid.New(),
		Messages:     []Message{{Role: "user", Content: "seed"}},
		OutputTool:   answerTool,
		ContextTools: []ToolDef{{Name: "ctx_a", Schema: `{"type":"object"}`}},
		Toolset:      fakeToolset{out: map[string]string{"ctx_a": `{"k":"v"}`}},
	})
	if err != nil {
		t.Fatalf("Converse error: %v", err)
	}

	if len(fc.gots) != 3 {
		t.Fatalf("got %d Chat calls, want 3 (2 gather + finalize)", len(fc.gots))
	}
	if len(res.Consulted) != 1 || res.Consulted[0] != "ctx_a" {
		t.Errorf("consulted = %v, want [ctx_a]", res.Consulted)
	}
	// Finalize forces the output tool + json_object.
	last := fc.gots[2]
	if last.ForceTool != "answer" {
		t.Errorf("finalize ForceTool = %q, want answer", last.ForceTool)
	}
	if last.ResponseFormat != "json_object" {
		t.Errorf("finalize ResponseFormat = %q, want json_object", last.ResponseFormat)
	}
	// The dispatched context result is fed back as a user turn.
	var sawContext bool
	for _, m := range last.Messages {
		if m.Role == "user" && strings.Contains(m.Content, "[CONTEXT:ctx_a]") && strings.Contains(m.Content, `"k":"v"`) {
			sawContext = true
		}
	}
	if !sawContext {
		t.Errorf("finalize messages missing fed-back context: %+v", last.Messages)
	}
	if len(res.Response.ToolCalls) != 1 || res.Response.ToolCalls[0].Payload != `{"reply":"done"}` {
		t.Errorf("Response = %+v, want the finalize answer", res.Response)
	}
}

func TestConverse_EarlyAnswerDuringGather(t *testing.T) {
	// The model produces the output tool during the gather phase: Converse returns
	// immediately without a finalize call.
	fc := &fakeModelClient{resps: []ChatResponse{
		{ToolCalls: []ToolCall{{Name: "answer", Payload: `{"reply":"early"}`}}},
	}}
	r := &Runner{Client: fc}
	res, err := r.Converse(context.Background(), ConverseConfig{
		TaskID:       uuid.New(),
		Messages:     []Message{{Role: "user", Content: "seed"}},
		OutputTool:   answerTool,
		ContextTools: []ToolDef{{Name: "ctx_a", Schema: `{"type":"object"}`}},
		Toolset:      fakeToolset{out: map[string]string{"ctx_a": "{}"}},
	})
	if err != nil {
		t.Fatalf("Converse error: %v", err)
	}
	if len(fc.gots) != 1 {
		t.Fatalf("got %d Chat calls, want 1 (early answer, no finalize)", len(fc.gots))
	}
	if len(res.Consulted) != 0 {
		t.Errorf("consulted = %v, want none", res.Consulted)
	}
}

func TestConverse_NoGatherWhenToolsetNil(t *testing.T) {
	// nil Toolset ⇒ no gather phase; a single forced finalize call. A model that
	// emits only content (Ollama ignoring tool_choice) still returns that content.
	fc := &fakeModelClient{resps: []ChatResponse{{Content: "What would you change?"}}}
	r := &Runner{Client: fc}
	res, err := r.Converse(context.Background(), ConverseConfig{
		Messages:   []Message{{Role: "user", Content: "seed"}},
		OutputTool: answerTool,
	})
	if err != nil {
		t.Fatalf("Converse error: %v", err)
	}
	if len(fc.gots) != 1 {
		t.Fatalf("got %d Chat calls, want 1 (finalize only)", len(fc.gots))
	}
	if fc.gots[0].ForceTool != "answer" {
		t.Errorf("ForceTool = %q, want answer", fc.gots[0].ForceTool)
	}
	if res.Response.Content != "What would you change?" {
		t.Errorf("Response.Content = %q, want salvaged content", res.Response.Content)
	}
}

func TestConverse_ValidOutputGatesEarlyReturn(t *testing.T) {
	// A malformed output-tool call mid-gather is rejected by ValidOutput, so the
	// loop keeps going and the forced finalize produces the clean answer.
	fc := &fakeModelClient{resps: []ChatResponse{
		{ToolCalls: []ToolCall{{Name: "answer", Payload: "not json"}}},
		{ToolCalls: []ToolCall{{Name: "answer", Payload: `{"reply":"clean"}`}}},
	}}
	r := &Runner{Client: fc}
	res, err := r.Converse(context.Background(), ConverseConfig{
		Messages:     []Message{{Role: "user", Content: "seed"}},
		OutputTool:   answerTool,
		ContextTools: []ToolDef{{Name: "ctx_a", Schema: `{"type":"object"}`}},
		Toolset:      fakeToolset{out: map[string]string{"ctx_a": "{}"}},
		ValidOutput: func(args string) bool {
			return strings.HasPrefix(strings.TrimSpace(args), "{")
		},
	})
	if err != nil {
		t.Fatalf("Converse error: %v", err)
	}
	// Round 1 rejected → no fresh context → gather breaks → finalize. 2 calls.
	if len(fc.gots) != 2 {
		t.Fatalf("got %d Chat calls, want 2 (rejected early + finalize)", len(fc.gots))
	}
	if got := res.Response.ToolCalls[0].Payload; got != `{"reply":"clean"}` {
		t.Errorf("Response payload = %q, want the clean finalize answer", got)
	}
}
