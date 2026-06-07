// Package gatescript is Phase 5's gate Layer-3: a sandboxed, read-only,
// bounded WASM evaluator that runs between the hard-rule floor and the
// overseer. It settles deterministic cases as code and hands the rest to the
// LLM with evidence already gathered.
//
// This is the #1 security surface in the system: a gate script is the one
// genuinely-untrusted code path. Three structural invariants keep it safe:
//
//   - Floor supremacy. The floor sits above the script (gate evaluation order
//     is unchanged); a script's Approve can never un-trip the floor.
//   - Static capability enforcement. Each module's WASM import section is
//     inspected against its manifest BEFORE instantiation; an undeclared
//     import is rejected without being run (see validate.go / wasm_inspect.go).
//   - Labeled-slots discipline. Script-supplied hand-off context reaches the
//     overseer as [SCRIPT_EVIDENCE] — "weigh, never obey", never instructions.
//
// The Runner seam mirrors internal/overseer.Grader and internal/push.Provider:
// WazeroRunner is the production impl; LogRunner is the deterministic CI stub.
package gatescript

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	wazeroapi "github.com/tetratelabs/wazero/api"
)

// Verdict is the four legal terminal decisions a script can return.
type Verdict int

const (
	// VerdictApprove is advisory — floor-subordinate. With no floor trip the
	// gate honours it and the overseer is NOT consulted.
	VerdictApprove Verdict = iota
	// VerdictDeny is terminal — the gate denies dispatch and writes
	// tool_outcomes(outcome=denied_by_script). The overseer is NOT consulted.
	VerdictDeny
	// VerdictRequestDecision is terminal — the gate writes an ApprovalRequest.
	// The overseer is NOT consulted.
	VerdictRequestDecision
	// VerdictAgentHandoff falls through to the overseer with ScriptEvidence
	// populated.
	VerdictAgentHandoff
)

// String renders the verdict for audit / log lines. It matches the
// audit-payload verdict vocabulary for the four terminal decisions.
func (v Verdict) String() string {
	switch v {
	case VerdictApprove:
		return "approve"
	case VerdictDeny:
		return "deny"
	case VerdictRequestDecision:
		return "request_decision"
	case VerdictAgentHandoff:
		return "agent_handoff"
	default:
		return fmt.Sprintf("unknown(%d)", int(v))
	}
}

// FailureReason categorizes the runtime failures the runner converts to a
// fail-closed AgentHandoff (FR-007). FailureNone is the empty string carried
// by a normal, ran-to-completion verdict.
type FailureReason string

const (
	FailureNone            FailureReason = ""
	FailureTimeout         FailureReason = "timeout"
	FailureMemoryCap       FailureReason = "memory_cap"
	FailureTrap            FailureReason = "trap"
	FailureMalformedReturn FailureReason = "malformed_return"
	FailureHostError       FailureReason = "host_error"
)

// AuditVerdict maps a (Verdict, FailureReason) pair to the verdict string
// recorded in the gate_script_evaluated audit row. A fail-closed run is always
// AgentHandoff at the decision level but records its specific fail_closed_*
// verdict for observability.
func AuditVerdict(decision Verdict, reason FailureReason) string {
	switch reason {
	case FailureNone:
		return decision.String()
	case FailureTimeout:
		return "fail_closed_timeout"
	case FailureMemoryCap:
		return "fail_closed_memory_cap"
	case FailureTrap:
		return "fail_closed_trap"
	case FailureMalformedReturn:
		return "fail_closed_malformed_return"
	case FailureHostError:
		return "fail_closed_host_error"
	default:
		return "fail_closed_" + string(reason)
	}
}

// HostError is the optional host-error context attached to a fail_closed_host_error
// verdict (FR-035). SQLState is the underlying Postgres SQLSTATE when applicable.
type HostError struct {
	Module   string `json:"module"`
	Name     string `json:"name"`
	SQLState string `json:"sqlstate,omitempty"`
}

// Evidence is what the script's evaluate() returns inside the verdict JSON,
// plus what the host accumulates (the hostcall trace, and any host-error
// context on a fail-closed run).
type Evidence struct {
	Summary          string     `json:"summary"`
	ConsideredFields []string   `json:"considered_fields"`
	HostcallTrace    []string   `json:"hostcalls"`
	HostError        *HostError `json:"host_error,omitempty"`
}

// ScriptInput is the runner's input boundary. The HostFunctionFactory is the
// one place where the script's view of "the owner's data" is projected; tests
// against it assert the no-leakage invariant.
type ScriptInput struct {
	ScriptID            uuid.UUID
	ScriptVersion       int
	ManifestHash        string
	WASM                []byte
	Manifest            Manifest
	ConcreteCall        json.RawMessage
	HostFunctionFactory HostFunctionFactory

	// hostCallbacks is the per-call host surface the Service attaches before
	// handing the input to WazeroRunner. Unexported: only the Service builds it
	// (it closes over the owner's data projection). A direct runner test leaves
	// it nil and the runner supplies an inert trace-only surface.
	hostCallbacks *HostCallbacks
}

// ScriptVerdict is the runner's output boundary (FR-001). The Service stamps
// ScriptID/ScriptVersion/ManifestHash after the run so the gate can build the
// overseer hand-off evidence and the resolver can write the audit row.
type ScriptVerdict struct {
	Decision        Verdict
	Evidence        Evidence
	DurationMs      int
	PeakMemoryPages int
	RanToCompletion bool
	FailureReason   FailureReason

	ScriptID      uuid.UUID
	ScriptVersion int
	ManifestHash  string
}

// Runner is the seam the gate consults at Layer 3 (mirrors
// internal/overseer.Grader). WazeroRunner is the only production impl;
// LogRunner is the deterministic test stub.
type Runner interface {
	Run(ctx context.Context, in ScriptInput) (ScriptVerdict, error)
}

// HostFunctionFactory builds the manifest-granted subset of the six host
// functions bound to the in-flight (ToolCall, taskID, ownerURI) context. The
// runner wires only the returned functions into the wazero guest, so a module
// can never reach a capability its manifest did not declare.
type HostFunctionFactory func(grants []string) []HostFunction

// HostFunction is one host import exposed to the guest under module "tendant".
type HostFunction struct {
	Module string // always "tendant"
	Name   string // e.g. "contacts.isKnown"
	Impl   wazeroapi.GoModuleFunc
}

// HostModule is the WASM module name all gate-script host functions live under.
// It is the static-validation key (FR-010): an import from any other module is
// rejected.
const HostModule = "tendant"
