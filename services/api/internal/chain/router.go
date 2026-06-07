// Package chain owns the DBOS chain workflow that walks a task through the
// fixed linear sequence CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION.
// Phase 6 replaces the HumanOnlyRouter with a real eligibility-prune-then-LLM-pick
// router, and introduces the agent runner for non-human stage occupants.
package chain

import (
	"context"
	"encoding/json"

	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// Router picks an agent for a given stage. The findings argument is the
// current tasks.findings JSON blob. Returns a SlotDecision indicating whether
// the stage should be occupied by a human (wait-on-event) or a specialist
// (run agent inline).
type Router interface {
	Select(ctx context.Context, stage lifecycle.ChainStage, findings json.RawMessage) (SlotDecision, error)
}

// StageRunner executes an agent's plan→act→observe loop for a stage.
// Returns the raw StageResult JSON. The chain workflow memoizes this as a DBOS step.
type StageRunner interface {
	RunStage(ctx context.Context, taskID string, stage lifecycle.ChainStage, configID string) (json.RawMessage, error)
}

// HumanOnlyRouter is preserved for backward compatibility in tests. It always
// routes to the human. Phase 6 callers should use the real router instead.
type HumanOnlyRouter struct{}

// Select always returns human.
func (HumanOnlyRouter) Select(_ context.Context, _ lifecycle.ChainStage, _ json.RawMessage) (SlotDecision, error) {
	return SlotDecision{IsHuman: true}, nil
}
