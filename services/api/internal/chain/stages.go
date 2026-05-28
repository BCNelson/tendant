package chain

import (
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// stageOrder is the canonical chain sequence (FR-004). The workflow advances
// monotonically through this list.
var stageOrder = []lifecycle.ChainStage{
	lifecycle.StageCreation,
	lifecycle.StageTriage,
	lifecycle.StageExpansion,
	lifecycle.StageExecution,
	lifecycle.StageCompletion,
}

// NextStage returns the next stage after `current`. isLast is true when
// `current` is COMPLETION (no further advance — workflow finalises).
//
// Unknown stages return (current, true) so the workflow halts cleanly rather
// than looping forever.
func NextStage(current lifecycle.ChainStage) (next lifecycle.ChainStage, isLast bool) {
	for i, s := range stageOrder {
		if s == current {
			if i == len(stageOrder)-1 {
				return current, true
			}
			return stageOrder[i+1], false
		}
	}
	return current, true
}

// StageNeedsOccupant reports whether a stage requires an assignment to
// resolve. Phase 1 (research R7): TRIAGE / EXPANSION / EXECUTION are occupied;
// CREATION (genesis) and COMPLETION (finalisation) are not.
func StageNeedsOccupant(s lifecycle.ChainStage) bool {
	switch s {
	case lifecycle.StageTriage, lifecycle.StageExpansion, lifecycle.StageExecution:
		return true
	default:
		return false
	}
}

// DefaultAsk returns the stage-default `ask` text persisted on the
// agent_assignments row in Phase 1 (research R7). Phase 6 agents will author
// these per slot.
func DefaultAsk(s lifecycle.ChainStage) string {
	switch s {
	case lifecycle.StageTriage:
		return "Triage this task: confirm it's real and decide on its categories."
	case lifecycle.StageExpansion:
		return "Expand this task into actionable sub-tasks or required inputs."
	case lifecycle.StageExecution:
		return "Execute this task and record the outcome."
	default:
		return ""
	}
}
