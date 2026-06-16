// Package chain owns the DBOS chain workflow that walks a task through the
// fixed linear sequence CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION.
// Phase 6 replaces the HumanOnlyRouter with a real eligibility-prune-then-LLM-pick
// router, and introduces the agent runner for non-human stage occupants.
package chain

import (
	"context"
	"encoding/json"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"

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

// AgentStarter starts the durable agent-stage workflow for an agent-occupied
// stage and blocks until it returns the StageResult JSON. It is called from the
// chain workflow body (it starts a child workflow), so it takes the dbos
// context. Implemented in cmd/tendant (and the test harness) so the chain stays
// decoupled from internal/agent (which imports chain). When nil, the chain runs
// the agent synchronously inline via StageRunner instead (the pre-Phase-B path).
type AgentStarter interface {
	StartStageAndAwait(ctx dbos.DBOSContext, taskID uuid.UUID, stage lifecycle.ChainStage, configID uuid.UUID) (json.RawMessage, error)
}

// HumanOnlyRouter is preserved for backward compatibility in tests. It always
// routes to the human. Phase 6 callers should use the real router instead.
type HumanOnlyRouter struct{}

// Select always returns human.
func (HumanOnlyRouter) Select(_ context.Context, _ lifecycle.ChainStage, _ json.RawMessage) (SlotDecision, error) {
	return SlotDecision{IsHuman: true}, nil
}
