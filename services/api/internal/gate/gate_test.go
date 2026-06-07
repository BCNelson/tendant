package gate

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

// fakeScript is a test stub gatescript.ScriptEvaluator. It records whether it
// was consulted and returns a configured verdict.
type fakeScript struct {
	verdict gatescript.ScriptVerdict
	ran     bool
	err     error
	called  bool
}

func (f *fakeScript) Evaluate(_ context.Context, _ gatescript.EvalContext, _ *db.Tool) (gatescript.ScriptVerdict, bool, error) {
	f.called = true
	return f.verdict, f.ran, f.err
}

// capturingGrader records the OverseerInput it was handed so tests can assert
// the script evidence / system note plumbing.
type capturingGrader struct {
	called bool
	in     *overseer.OverseerInput
}

func (g *capturingGrader) Grade(_ context.Context, in *overseer.OverseerInput) (overseer.OverseerVerdict, error) {
	g.called = true
	g.in = in
	return overseer.OverseerVerdict{Decision: overseer.DecisionApprove, Provider: "test", ModelID: "test",
		Evidence: overseer.Evidence{Summary: "stub", ConsideredFields: []string{}}}, nil
}

func gradedTool(t *testing.T) *db.Tool {
	t.Helper()
	return &db.Tool{Permissions: permsJSON(t, Permissions{})} // no floor clauses
}

func gradedCall() *ToolCall {
	return &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: []byte(`{"to":"x"}`)}
}

func TestDefaultGate_ScriptApprove_SkipsOverseer(t *testing.T) {
	t.Parallel()
	grader := &capturingGrader{}
	g := NewDefaultGateWithOverseer(&stubLookup{}, grader)
	g.Script = &fakeScript{ran: true, verdict: gatescript.ScriptVerdict{Decision: gatescript.VerdictApprove, RanToCompletion: true}}

	v, err := g.Evaluate(context.Background(), gradedCall(), gradedTool(t))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionApprove {
		t.Fatalf("want Approve, got %s", v.Decision)
	}
	if grader.called {
		t.Fatalf("overseer must NOT be consulted on a script Approve")
	}
	if v.ScriptVerdict == nil {
		t.Fatalf("gate must carry the ScriptVerdict for audit")
	}
}

func TestDefaultGate_ScriptDenyAndRequest_AreTerminal(t *testing.T) {
	t.Parallel()
	for _, tc := range []struct {
		name string
		sv   gatescript.Verdict
		want Decision
	}{
		{"deny", gatescript.VerdictDeny, DecisionDeny},
		{"request", gatescript.VerdictRequestDecision, DecisionRequestDecision},
	} {
		t.Run(tc.name, func(t *testing.T) {
			grader := &capturingGrader{}
			g := NewDefaultGateWithOverseer(&stubLookup{}, grader)
			g.Script = &fakeScript{ran: true, verdict: gatescript.ScriptVerdict{Decision: tc.sv, RanToCompletion: true}}
			v, err := g.Evaluate(context.Background(), gradedCall(), gradedTool(t))
			if err != nil {
				t.Fatalf("evaluate: %v", err)
			}
			if v.Decision != tc.want {
				t.Fatalf("want %s got %s", tc.want, v.Decision)
			}
			if grader.called {
				t.Fatalf("overseer must NOT be consulted on a terminal script verdict")
			}
		})
	}
}

func TestDefaultGate_ScriptAgentHandoff_PopulatesScriptEvidence(t *testing.T) {
	t.Parallel()
	grader := &capturingGrader{}
	g := NewDefaultGateWithOverseer(&stubLookup{}, grader)
	g.Script = &fakeScript{ran: true, verdict: gatescript.ScriptVerdict{
		Decision:        gatescript.VerdictAgentHandoff,
		RanToCompletion: true,
		ScriptID:        uuid.New(),
		ScriptVersion:   3,
		Evidence:        gatescript.Evidence{Summary: "mentions money", ConsideredFields: []string{"payload.body"}},
	}}
	v, err := g.Evaluate(context.Background(), gradedCall(), gradedTool(t))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if !grader.called {
		t.Fatalf("overseer must be consulted on AgentHandoff")
	}
	if grader.in.ScriptEvidence == nil || grader.in.ScriptEvidence.Summary != "mentions money" {
		t.Fatalf("ScriptEvidence not plumbed into OverseerInput: %+v", grader.in.ScriptEvidence)
	}
	if v.ScriptVerdict == nil || v.OverseerVerdict == nil {
		t.Fatalf("gate must carry BOTH script and overseer verdicts after hand-off")
	}
}

func TestDefaultGate_ScriptFailClosed_FallsThroughWithNote(t *testing.T) {
	t.Parallel()
	grader := &capturingGrader{}
	g := NewDefaultGateWithOverseer(&stubLookup{}, grader)
	g.Script = &fakeScript{ran: true, verdict: gatescript.ScriptVerdict{
		Decision:      gatescript.VerdictAgentHandoff,
		FailureReason: gatescript.FailureTimeout,
	}}
	_, err := g.Evaluate(context.Background(), gradedCall(), gradedTool(t))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if !grader.called {
		t.Fatalf("overseer must be consulted on a fail-closed run")
	}
	if grader.in.ScriptEvidence != nil {
		t.Fatalf("ScriptEvidence MUST be nil on a fail-closed run (FR-033)")
	}
	if grader.in.SystemNote == "" {
		t.Fatalf("SystemNote must name the failure reason on a fail-closed run")
	}
}

// TestDefaultGate_ThreeLayerFloorSupremacy is NFR-004 / SC-009: a floor-tripping
// call produces RequestDecision regardless of BOTH a script Approve and an
// overseer Approve, and neither layer is consulted.
func TestDefaultGate_ThreeLayerFloorSupremacy(t *testing.T) {
	t.Parallel()
	for _, clause := range []Permissions{
		{Spend: true},
		{Irreversible: "always"},
		{SecretClasses: []string{"ssn"}},
	} {
		script := &fakeScript{ran: true, verdict: gatescript.ScriptVerdict{Decision: gatescript.VerdictApprove, RanToCompletion: true}}
		grader := &alwaysApproveGrader{}
		g := NewDefaultGateWithOverseer(&stubLookup{}, grader)
		g.Script = script

		tool := &db.Tool{Permissions: permsJSON(t, clause)}
		call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(),
			Payload: payloadJSON(t, map[string]any{"to": "tendant://principals/owner", "disclosure_class": "ssn", "amount": 5})}
		v, err := g.Evaluate(context.Background(), call, tool)
		if err != nil {
			t.Fatalf("evaluate: %v", err)
		}
		if v.Decision != DecisionRequestDecision {
			t.Fatalf("floor must win: want RequestDecision got %s", v.Decision)
		}
		if script.called {
			t.Fatalf("script must NOT run on a floor-tripping call")
		}
		if grader.called {
			t.Fatalf("overseer must NOT run on a floor-tripping call")
		}
		if v.ScriptVerdict != nil {
			t.Fatalf("no script verdict on a floor-trip")
		}
	}
}

// alwaysApproveGrader is a test stub for SC-005: even if the overseer
// returns Approve, a floor trip MUST still produce RequestDecision and
// the grader MUST NOT have been consulted.
type alwaysApproveGrader struct{ called bool }

func (g *alwaysApproveGrader) Grade(_ context.Context, _ *overseer.OverseerInput) (overseer.OverseerVerdict, error) {
	g.called = true
	return overseer.OverseerVerdict{
		Decision: overseer.DecisionApprove,
		Provider: "test",
		ModelID:  "test",
		Evidence: overseer.Evidence{Summary: "stub", ConsideredFields: []string{}},
	}, nil
}

// TestDefaultGate_FloorWinsOverOverseer is the SC-005 regression: the
// floor is consulted before the overseer; an overseer Approve cannot
// un-trip the floor. The grader is registered but must never be called.
func TestDefaultGate_FloorWinsOverOverseer(t *testing.T) {
	t.Parallel()
	grader := &alwaysApproveGrader{}
	g := NewDefaultGateWithOverseer(&stubLookup{}, grader)

	// Spend trips the floor — overseer must NOT be consulted.
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{Spend: true})}
	call := &ToolCall{
		TaskID:  uuid.New(),
		ToolID:  uuid.New(),
		Payload: payloadJSON(t, map[string]any{"to": "tendant://principals/owner"}),
	}
	v, err := g.Evaluate(context.Background(), call, tool)
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("floor must win: want RequestDecision, got %s", v.Decision)
	}
	if grader.called {
		t.Fatalf("overseer must NOT be consulted on a floor-tripping call (SC-005)")
	}
	if v.OverseerVerdict != nil {
		t.Fatalf("OverseerVerdict must be nil on floor-trip path")
	}

	var ctxMap map[string]any
	if err := json.Unmarshal(v.Context, &ctxMap); err != nil {
		t.Fatalf("decode context: %v", err)
	}
	if got := ctxMap["layer"]; got != "floor" {
		t.Fatalf("expected layer=floor, got %v", got)
	}
}

// TestDefaultGate_OverseerConsulted_NonFloor exercises the happy path:
// no floor trip → overseer Approve → gate Decision=Approve, verdict carried.
func TestDefaultGate_OverseerConsulted_NonFloor(t *testing.T) {
	t.Parallel()
	knownOwner := "tendant://principals/owner"
	lookup := &stubLookup{known: map[string]bool{knownOwner: true}}
	grader := &alwaysApproveGrader{}
	g := NewDefaultGateWithOverseer(lookup, grader)
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{Irreversible: "stranger_recipient"})}
	call := &ToolCall{
		TaskID:  uuid.New(),
		ToolID:  uuid.New(),
		Payload: payloadJSON(t, map[string]any{"to": knownOwner}),
	}
	v, err := g.Evaluate(context.Background(), call, tool)
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionApprove {
		t.Fatalf("want Approve, got %s", v.Decision)
	}
	if !grader.called {
		t.Fatalf("overseer should be consulted when floor does not trip")
	}
	if v.OverseerVerdict == nil {
		t.Fatalf("OverseerVerdict must be carried back on overseer-consulted path")
	}
	if v.OverseerVerdict.Decision != overseer.DecisionApprove {
		t.Fatalf("verdict decision = %s, want Approve", v.OverseerVerdict.Decision)
	}
}

// TestDefaultGate_OverseerNotWired_FallsThrough confirms the Phase-3
// behaviour persists when the gate has no overseer wired (Overseer == nil).
// Phase 3 tests rely on this — they should remain unbroken by Phase 4.
func TestDefaultGate_OverseerNotWired_FallsThrough(t *testing.T) {
	t.Parallel()
	knownOwner := "tendant://principals/owner"
	lookup := &stubLookup{known: map[string]bool{knownOwner: true}}
	g := NewDefaultGate(lookup) // no overseer
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{Irreversible: "stranger_recipient"})}
	call := &ToolCall{
		TaskID:  uuid.New(),
		ToolID:  uuid.New(),
		Payload: payloadJSON(t, map[string]any{"to": knownOwner}),
	}
	v, err := g.Evaluate(context.Background(), call, tool)
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("no-overseer path must still escalate, got %s", v.Decision)
	}
	if v.OverseerVerdict != nil {
		t.Fatalf("no-overseer path must not synthesize an OverseerVerdict")
	}
}
