package gate

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// grantStub implements RoutineGrantLookup with a static fingerprint set.
type grantStub struct {
	live   map[string]bool
	called bool
}

func (g *grantStub) HasLiveGrant(_ context.Context, _ uuid.UUID, fp string) (bool, error) {
	g.called = true
	if g.live == nil {
		return false, nil
	}
	return g.live[fp], nil
}

// autoTool builds a floor-clearing tool at a given trust score.
func autoTool(t *testing.T, score float64) *db.Tool {
	t.Helper()
	return &db.Tool{
		GlobalUri:   tools.SendEmailGlobalURI,
		Permissions: permsJSON(t, Permissions{}), // no floor clauses
		TrustScore:  score,
	}
}

func knownCall() *ToolCall {
	return &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: []byte(`{"to":"known@friend.example"}`)}
}

func TestAutonomy_ExecuteAutoWithLiveGrant_Approves(t *testing.T) {
	t.Parallel()
	call := knownCall()
	fp := calibration.Fingerprint(tools.SendEmailGlobalURI, call.Payload)
	g := NewDefaultGate(&stubLookup{}) // no overseer: fall-through would RequestDecision
	g.Grants = &grantStub{live: map[string]bool{fp: true}}

	v, err := g.Evaluate(context.Background(), call, autoTool(t, calibration.AutoThreshold))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionApprove {
		t.Fatalf("want Approve (autonomy), got %s", v.Decision)
	}
}

func TestAutonomy_UnfamiliarFingerprint_FallsThrough(t *testing.T) {
	t.Parallel()
	g := NewDefaultGate(&stubLookup{})
	g.Grants = &grantStub{live: map[string]bool{"some-other-routine": true}}

	v, err := g.Evaluate(context.Background(), knownCall(), autoTool(t, calibration.AutoThreshold))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("an unfamiliar routine must gate, got %s", v.Decision)
	}
}

func TestAutonomy_ExecuteGatedBand_FallsThrough(t *testing.T) {
	t.Parallel()
	call := knownCall()
	fp := calibration.Fingerprint(tools.SendEmailGlobalURI, call.Payload)
	g := NewDefaultGate(&stubLookup{})
	// Even with a live grant, a tool below the auto band must gate.
	g.Grants = &grantStub{live: map[string]bool{fp: true}}

	v, err := g.Evaluate(context.Background(), call, autoTool(t, calibration.Baseline))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("EXECUTE_GATED must gate, got %s", v.Decision)
	}
}

func TestAutonomy_NilGrants_NeverApproves(t *testing.T) {
	t.Parallel()
	g := NewDefaultGate(&stubLookup{}) // Grants nil
	v, err := g.Evaluate(context.Background(), knownCall(), autoTool(t, calibration.AutoThreshold))
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("no grant lookup wired ⇒ must gate, got %s", v.Decision)
	}
}
