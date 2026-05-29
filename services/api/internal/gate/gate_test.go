package gate

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

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
