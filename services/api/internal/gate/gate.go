// Package gate is the universal gate that every outward tool call passes
// through. Phase 5 ships all four layers actively:
//
//	read-only short-circuit  → AUTO Approve, no grading.
//	HARD-RULE FLOOR          → categorical; trips RequestDecision.
//	gate script              → wired (Phase 5); sandboxed WASM evaluator via
//	                            internal/gatescript.ScriptEvaluator. Nil keeps
//	                            Phase-4 semantics (no script layer).
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
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
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

	// ScriptVerdict (Phase 5), when non-nil, carries the gate-script Layer-3
	// verdict so the resolver writes the gate_script_evaluated audit row
	// chained to gate_verdict. It is set whenever a script ran (including a
	// fail-closed run that fell through to the overseer); nil when no script
	// was attached or the floor tripped before Layer 3.
	ScriptVerdict *gatescript.ScriptVerdict `json:"-"`
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
	Script   gatescript.ScriptEvaluator // Phase 5 Layer 3; nil keeps Phase 4 semantics
	Grants   RoutineGrantLookup         // Phase 8 autonomy layer; nil = never auto-approves
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

	// Layer 3: gate script (Phase 5). Runs after the floor (which did not
	// trip) and before the overseer. Approve/Deny/RequestDecision are
	// terminal here (overseer NOT consulted); AgentHandoff and any
	// fail-closed run fall through to the overseer. Order is unchanged
	// (constitution III) — the script is never asked on a floor-tripping call.
	var scriptVerdict *gatescript.ScriptVerdict
	var scriptEvidence *overseer.ScriptEvidence
	var scriptFailNote string
	if g.Script != nil {
		in := gatescript.EvalContext{
			TaskID:        call.TaskID,
			ToolID:        call.ToolID,
			ToolGlobalURI: tool.GlobalUri,
			Payload:       call.Payload,
			ProposerURI:   ownerOrSystem(tool),
		}
		sv, ran, serr := g.Script.Evaluate(ctx, in, tool)
		switch {
		case serr != nil:
			// Infra/load error: fail open to the overseer with a note, no
			// evidence. Never surfaced as Approve.
			scriptFailNote = "prior script failed: load_error"
		case ran:
			scriptVerdict = &sv
			switch {
			case sv.FailureReason != "":
				scriptFailNote = "prior script failed: " + string(sv.FailureReason)
			case sv.Decision == gatescript.VerdictApprove:
				return Verdict{Decision: DecisionApprove, Context: scriptCtx(sv), ScriptVerdict: scriptVerdict}, nil
			case sv.Decision == gatescript.VerdictDeny:
				return Verdict{Decision: DecisionDeny, Context: scriptCtx(sv), ScriptVerdict: scriptVerdict}, nil
			case sv.Decision == gatescript.VerdictRequestDecision:
				return Verdict{Decision: DecisionRequestDecision, Context: scriptCtx(sv), ScriptVerdict: scriptVerdict}, nil
			case sv.Decision == gatescript.VerdictAgentHandoff:
				scriptEvidence = &overseer.ScriptEvidence{
					Summary:          sv.Evidence.Summary,
					ConsideredFields: sv.Evidence.ConsideredFields,
					HostcallTrace:    sv.Evidence.HostcallTrace,
					ScriptID:         sv.ScriptID,
					ScriptVersion:    sv.ScriptVersion,
				}
			}
		}
	}

	// Phase 8 autonomy layer. Sits AFTER the floor (cleared) and AFTER the
	// script's terminal verdicts, in the overseer's slot (research R7). It can
	// only Approve (tool in EXECUTE_AUTO band AND the call's routine has a live
	// grant) or fall through — never deny. Floor supremacy (III) and
	// no-self-escalation (IV) hold by construction: the floor already cleared,
	// and the only score-raising path is the owner mutation.
	approved, autonomyCtx, aerr := g.autonomyApprove(ctx, call, tool)
	if aerr != nil {
		return Verdict{}, fmt.Errorf("gate: autonomy: %w", aerr)
	}
	if approved {
		return Verdict{Decision: DecisionApprove, Context: autonomyCtx, ScriptVerdict: scriptVerdict}, nil
	}

	// Layer 4: overseer (LLM grader). Phase 4 wires this via the Grader
	// seam. When Overseer == nil (Phase 3 test harness), fall back to the
	// Phase 3 behaviour — escalate to the operator.
	if g.Overseer == nil {
		ctxJSON, _ := json.Marshal(map[string]string{
			"layer":  "no_overseer_wired",
			"reason": "phase3_fallback",
		})
		// Carry the script verdict (if a script ran and handed off / failed)
		// so the resolver still records the gate_script_evaluated audit row.
		return Verdict{Decision: DecisionRequestDecision, Context: ctxJSON, ScriptVerdict: scriptVerdict}, nil
	}

	in := overseer.OverseerInput{
		OwnerInstructions: stringFromNullable(tool.OverseerInstructions),
		ToolName:          tool.Name,
		ToolGlobalURI:     tool.GlobalUri,
		ConcreteCall:      call.Payload,
		Permissions:       tool.Permissions,
		TaskID:            call.TaskID,
		ScriptEvidence:    scriptEvidence, // non-nil only on AgentHandoff
		SystemNote:        scriptFailNote, // names the failure reason on a fail-closed run
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
			ScriptVerdict: scriptVerdict,
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
		ScriptVerdict:   scriptVerdict,
	}, nil
}

// ownerOrSystem returns the proposer URI the script's call.get() reports. Phase
// 5 has a single owner principal; the system actor is the safe default when the
// gate has no richer proposer context.
func ownerOrSystem(_ *db.Tool) string {
	return "tendant://principals/owner"
}

// scriptCtx renders the gate-verdict Context blob for a script-terminal verdict.
func scriptCtx(sv gatescript.ScriptVerdict) json.RawMessage {
	b, _ := json.Marshal(map[string]any{
		"layer":          "gate_script",
		"verdict":        sv.Decision.String(),
		"script_id":      sv.ScriptID.String(),
		"script_version": sv.ScriptVersion,
		"summary":        sv.Evidence.Summary,
	})
	return b
}

// stringFromNullable centralises the *string → string fold so the gate's
// call site doesn't sprinkle dereferences. nil and "" both produce "".
func stringFromNullable(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}
