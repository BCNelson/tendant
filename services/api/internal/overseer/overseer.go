// Package overseer is Phase 4's gate Layer-4: an LLM-backed grader,
// parameterized per tool by owner-authored tools.overseer_instructions,
// that judges non-floor-tripping calls and returns either Approve
// (auto-dispatch, still floor-subordinate) or RequestDecision (escalate
// to the existing Phase-3 human-wait).
//
// The package's structure is the safety property: payload data and owner
// instructions never share a string surface. OverseerInput is the struct
// boundary; prompt.Serialize hands off into separately-labeled slots that
// providers map onto their native APIs.
//
// The Grader interface keeps internal/gate pure of model-call mechanics;
// Gateway is the only addressable Grader implementation, so an agent
// cannot reroute inference at runtime.
package overseer

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
)

// Decision is the two-valued verdict shape Phase 4 returns to the gate.
// Phase 4 deliberately does NOT include Deny — the gate's policy contract
// remains "Approve or escalate"; Deny lives only at the floor.
type Decision int

const (
	DecisionApprove Decision = iota
	DecisionRequestDecision
)

// String renders the decision for audit / log lines.
func (d Decision) String() string {
	switch d {
	case DecisionApprove:
		return "approve"
	case DecisionRequestDecision:
		return "request_decision"
	default:
		return "unknown"
	}
}

// OverseerInput is the struct boundary that prevents payload fields from
// posing as owner instructions. NEVER replace this with a single string
// concatenation surface.
type OverseerInput struct {
	OwnerInstructions string
	ToolName          string
	ToolGlobalURI     string
	ConcreteCall      json.RawMessage // the frozen ToolCall.Payload
	Permissions       json.RawMessage // tools.permissions, for [TOOL_METADATA]
	TaskID            uuid.UUID       // for the per-task cap query
}

// Evidence is the structured reasoning the overseer attaches to its
// verdict. ConsideredFields enumerates the top-level payload keys that
// drove the verdict (e.g. ["payload.body", "payload.to"]); Summary is a
// 1-2 sentence rationale.
type Evidence struct {
	Summary          string   `json:"summary"`
	ConsideredFields []string `json:"considered_fields"`
}

// OverseerVerdict is the result of one evaluation. Reason is populated
// only on fail-closed paths ("per_task_eval_cap_exceeded",
// "malformed_model_response", "gateway_error").
type OverseerVerdict struct {
	Decision         Decision
	Evidence         Evidence
	ModelID          string
	Provider         string // "log" | "anthropic" | "openai"
	TokensIn         int
	TokensOut        int
	EstimatedCostUSD float64
	Reason           string
}

// Grader is the seam the gate consults at Layer 4. Phase 4 ships exactly
// one implementation: Gateway. Takes a pointer because OverseerInput is
// large (~112 bytes) and the gate constructs it once per call.
type Grader interface {
	Grade(ctx context.Context, in *OverseerInput) (OverseerVerdict, error)
}
