// Package gate is the universal gate that every outward tool call passes
// through. Phase 4 ships three of the four layers actively:
//
//	read-only short-circuit  → AUTO Approve, no grading.
//	HARD-RULE FLOOR          → categorical; trips RequestDecision.
//	gate script              → stub; falls through (Phase 5).
//	overseer (LLM grader)    → wired (Phase 4); evaluates non-floor-tripping
//	                            calls via internal/overseer.Grader.
//
// Order is immutable (constitution III): the floor is consulted before the
// overseer, and the overseer can never un-trip the floor. When no Grader is
// wired (Overseer == nil), the gate falls through to RequestDecision exactly
// as in Phase 3, which keeps Phase 3 tests deterministic without an overseer
// in the test harness.
//
// The package is intentionally pure (no I/O, no DB) so the floor is
// trivially unit-testable from JSON fixtures. The overseer-call branch
// delegates all I/O to the Grader behind the seam.
package gate

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

// Decision is the four-valued verdict shape from the architecture spec.
type Decision int

const (
	DecisionApprove Decision = iota
	DecisionDeny
	DecisionRequestDecision
	DecisionAgentHandoff
)

// String renders the decision for audit / log lines.
func (d Decision) String() string {
	switch d {
	case DecisionApprove:
		return "approve"
	case DecisionDeny:
		return "deny"
	case DecisionRequestDecision:
		return "request_decision"
	case DecisionAgentHandoff:
		return "agent_handoff"
	default:
		return fmt.Sprintf("unknown(%d)", int(d))
	}
}

// Verdict matches Appendix D of the v2 architecture spec.
type Verdict struct {
	Decision Decision        `json:"decision"`
	Context  json.RawMessage `json:"context,omitempty"`
	// OverseerVerdict, when non-nil, carries the overseer's verdict
	// alongside the gate's overall decision. Phase 4 callers (the
	// resolver) use it to write the overseer_evaluated audit row chained
	// to gate_verdict. Phase 3 callers — and Phase 4 calls that never
	// reached Layer 4 (read-only, floor-trip) — leave this nil.
	OverseerVerdict *overseer.OverseerVerdict `json:"-"`
}

// ToolCall is the composed tool invocation handed to the gate. The Payload
// is opaque to the gate except where the floor predicates read documented
// fields (e.g. `recipient`, `disclosure_class`).
type ToolCall struct {
	TaskID  uuid.UUID
	ToolID  uuid.UUID
	Payload json.RawMessage
}

// PrincipalLookup is the seam the floor uses to check whether a recipient
// global URI belongs to a known principal. Implementations should be cheap
// (a single query or an in-memory cache); the floor will call this once per
// graded call.
type PrincipalLookup interface {
	IsKnownPrincipal(ctx context.Context, globalURI string) (bool, error)
}

// Gate is the one gate every tool call passes through. Implementations
// MUST evaluate in the order: read-only short-circuit → floor → script →
// overseer.
type Gate interface {
	Evaluate(ctx context.Context, call *ToolCall, tool *db.Tool) (Verdict, error)
}

// DefaultGate is the Phase 4 implementation. Overseer is optional: nil
// keeps Phase 3 semantics (non-floor-tripping calls escalate); non-nil
// activates the Layer-4 evaluation.
type DefaultGate struct {
	Floor    *Floor
	Overseer overseer.Grader
}

// NewDefaultGate constructs a gate wired to the given principal lookup, no
// overseer. Phase 3 behaviour. Tests use this form to drive the unchanged
// floor-trip + escalate paths.
func NewDefaultGate(lookup PrincipalLookup) *DefaultGate {
	return &DefaultGate{Floor: NewFloor(lookup)}
}

// NewDefaultGateWithOverseer is the Phase 4 form: same Floor, plus the
// Grader to consult at Layer 4. Pass nil to ovs to behave like
// NewDefaultGate.
func NewDefaultGateWithOverseer(lookup PrincipalLookup, ovs overseer.Grader) *DefaultGate {
	return &DefaultGate{Floor: NewFloor(lookup), Overseer: ovs}
}

// Evaluate runs the gate layers in order. Any error from a layer aborts
// evaluation and surfaces the error to the caller — gate failures are
// fail-closed (the caller treats an error like a Deny). The overseer is
// the exception: it fail-closes inside the Grader (returns
// RequestDecision with a reason), so an overseer outage doesn't surface
// as an error from Evaluate.
func (g *DefaultGate) Evaluate(ctx context.Context, call *ToolCall, tool *db.Tool) (Verdict, error) {
	if g == nil || g.Floor == nil {
		return Verdict{}, fmt.Errorf("gate: not initialised")
	}
	if call == nil || tool == nil {
		return Verdict{}, fmt.Errorf("gate: nil call or tool")
	}

	perms, err := parsePermissions(tool.Permissions)
	if err != nil {
		return Verdict{}, fmt.Errorf("gate: parse permissions: %w", err)
	}

	// Layer 1: read-only short-circuit. Ungraded calls bypass the floor by
	// construction — a read does not change the world.
	if perms.ReadOnly {
		ctxJSON, _ := json.Marshal(map[string]string{"layer": "read_only_short_circuit"})
		return Verdict{Decision: DecisionApprove, Context: ctxJSON}, nil
	}

	// Layer 2: HARD-RULE FLOOR. Categorical; trips RequestDecision regardless
	// of any downstream layer. Constitution III: the overseer is NEVER
	// consulted on a floor-tripping call.
	floorTripped, floorCtx, err := g.Floor.Check(ctx, call, perms)
	if err != nil {
		return Verdict{}, fmt.Errorf("gate: floor: %w", err)
	}
	if floorTripped {
		ctxJSON, _ := json.Marshal(map[string]any{
			"layer":  "floor",
			"clause": floorCtx.Clause,
			"detail": floorCtx.Detail,
		})
		return Verdict{Decision: DecisionRequestDecision, Context: ctxJSON}, nil
	}

	// Layer 3: gate script. Phase 5 will plug a WASM evaluator here.
	// Phase 4 stub: no script ⇒ fall through.

	// Layer 4: overseer (LLM grader). Phase 4 wires this via the Grader
	// seam. When Overseer == nil (Phase 3 test harness), fall back to the
	// Phase 3 behaviour — escalate to the operator.
	if g.Overseer == nil {
		ctxJSON, _ := json.Marshal(map[string]string{
			"layer":  "no_overseer_wired",
			"reason": "phase3_fallback",
		})
		return Verdict{Decision: DecisionRequestDecision, Context: ctxJSON}, nil
	}

	in := overseer.OverseerInput{
		OwnerInstructions: stringFromNullable(tool.OverseerInstructions),
		ToolName:          tool.Name,
		ToolGlobalURI:     tool.GlobalUri,
		ConcreteCall:      call.Payload,
		Permissions:       tool.Permissions,
		TaskID:            call.TaskID,
	}
	verdict, gerr := g.Overseer.Grade(ctx, &in)
	if gerr != nil {
		// The Gateway already fail-closes; treat any returned error as a
		// belt-and-suspenders fail-closed path too. Don't surface — write
		// a synthetic RequestDecision with a generic reason.
		ctxJSON, _ := json.Marshal(map[string]any{
			"layer":  "overseer",
			"reason": "grader_error",
			"err":    gerr.Error(),
		})
		return Verdict{
			Decision: DecisionRequestDecision,
			Context:  ctxJSON,
			OverseerVerdict: &overseer.OverseerVerdict{
				Decision: overseer.DecisionRequestDecision,
				Reason:   "gateway_error",
				Evidence: overseer.Evidence{
					Summary:          fmt.Sprintf("grader returned error: %v", gerr),
					ConsideredFields: []string{},
				},
			},
		}, nil
	}

	var gateDec Decision
	switch verdict.Decision {
	case overseer.DecisionApprove:
		gateDec = DecisionApprove
	default:
		gateDec = DecisionRequestDecision
	}
	ctxJSON, _ := json.Marshal(map[string]any{
		"layer":    "overseer",
		"provider": verdict.Provider,
		"model_id": verdict.ModelID,
		"verdict":  verdict.Decision.String(),
		"reason":   verdict.Reason,
	})
	return Verdict{
		Decision:        gateDec,
		Context:         ctxJSON,
		OverseerVerdict: &verdict,
	}, nil
}

// stringFromNullable centralises the *string → string fold so the gate's
// call site doesn't sprinkle dereferences. nil and "" both produce "".
func stringFromNullable(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}
