// Package lifecycle owns the task state machine and the audit-write helper.
// Pure functions over pgx.Tx with no DBOS dependency — composes cleanly into
// a DBOS step but unit-testable without spinning up a workflow.
package lifecycle

import (
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TaskState is a thin alias over the sqlc-generated type so callers in this
// package don't have to import db just for the enum constants.
type TaskState = db.TaskState

const (
	StateProposed  = db.TaskStateProposed
	StateAccepted  = db.TaskStateAccepted
	StateWaiting   = db.TaskStateWaiting
	StateExecuting = db.TaskStateExecuting
	StateDone      = db.TaskStateDone
	StateDismissed = db.TaskStateDismissed
	StateHalted    = db.TaskStateHalted
)

// ChainStage is the chain-axis enum (creation → triage → expansion → execution → completion).
type ChainStage = db.ChainStage

const (
	StageCreation   = db.ChainStageCreation
	StageTriage     = db.ChainStageTriage
	StageExpansion  = db.ChainStageExpansion
	StageExecution  = db.ChainStageExecution
	StageCompletion = db.ChainStageCompletion
)

// legalEdges encodes FR-001: the only legal state transitions. Any pair not
// present is rejected by IsLegal.
var legalEdges = map[TaskState]map[TaskState]bool{
	StateProposed: {
		StateAccepted:  true,
		StateDismissed: true,
		StateHalted:    true, // cancel from PROPOSED
	},
	StateAccepted: {
		StateExecuting: true, // EXPANSION→EXECUTION, readiness=true
		StateWaiting:   true, // EXPANSION→EXECUTION, readiness=false
		StateHalted:    true,
	},
	StateWaiting: {
		StateExecuting: true,
		StateHalted:    true,
	},
	StateExecuting: {
		StateDone:   true,
		StateHalted: true,
	},
	// Terminal sinks — no outbound edges (FR-003).
	StateDone:      {},
	StateDismissed: {},
	StateHalted:    {},
}

// IsLegal reports whether (from → to) is a permitted transition.
func IsLegal(from, to TaskState) bool {
	return legalEdges[from][to]
}

// IsLegalIntake extends IsLegal with the one edge permitted only for
// intake-origin tasks: an auto-accepted enrich-only task (accepted) is
// dismissible (research R4 / D5). Owner-authored tasks never gain this edge —
// callers MUST verify intake_signal_id IS NOT NULL before using it.
func IsLegalIntake(from, to TaskState) bool {
	if IsLegal(from, to) {
		return true
	}
	return from == StateAccepted && to == StateDismissed
}

// IsTerminal reports whether s is a terminal sink with no outbound edges.
func IsTerminal(s TaskState) bool {
	return s == StateDone || s == StateDismissed || s == StateHalted
}

// ErrIllegalTransition is returned by Transition when the requested edge is
// not present in the legal-edges table. Callers (resolvers, workflow steps)
// can errors.As to extract From/To for surfacing as a typed GraphQL error.
type ErrIllegalTransition struct {
	From TaskState
	To   TaskState
}

func (e *ErrIllegalTransition) Error() string {
	return fmt.Sprintf("illegal task state transition: %s → %s", e.From, e.To)
}
