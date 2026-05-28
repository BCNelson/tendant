// Package gate is the universal gate that every outward tool call passes
// through. Phase 3 ships two of the four layers:
//
//	read-only short-circuit  → AUTO Approve, no grading.
//	HARD-RULE FLOOR          → categorical; trips RequestDecision.
//	gate script              → stub; falls through (Phase 5).
//	overseer (LLM grader)    → stub; falls through (Phase 4).
//
// Any graded call that does not trip the floor still returns
// RequestDecision in Phase 3, because the script and overseer are not yet
// wired. Phases 4 and 5 will replace the stubs in-place without changing
// this file's surface.
//
// The package is intentionally pure (no I/O, no DB) so the floor is
// trivially unit-testable from JSON fixtures.
package gate

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
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

// DefaultGate is the Phase 3 implementation. Script and overseer are nil
// stubs that fall through to RequestDecision.
type DefaultGate struct {
	Floor *Floor
}

// NewDefaultGate constructs a gate wired to the given principal lookup.
func NewDefaultGate(lookup PrincipalLookup) *DefaultGate {
	return &DefaultGate{Floor: NewFloor(lookup)}
}

// Evaluate runs the gate layers in order. Any error from a layer aborts
// evaluation and surfaces the error to the caller — gate failures are
// fail-closed (the caller treats an error like a Deny).
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
	// of any downstream layer.
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
	// Phase 3 stub: no script ⇒ fall through.

	// Layer 4: overseer (LLM grader). Phase 4 will plug the model here.
	// Phase 3 stub: no overseer ⇒ a graded call that did not trip the floor
	// still escalates. The spec is explicit: non-floor graded calls escalate
	// to the operator until the overseer lands.
	ctxJSON, _ := json.Marshal(map[string]string{
		"layer":  "no_overseer_yet",
		"reason": "phase3_fallback",
	})
	return Verdict{Decision: DecisionRequestDecision, Context: ctxJSON}, nil
}
