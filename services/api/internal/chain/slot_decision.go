package chain

import (
	"encoding/json"

	"github.com/google/uuid"
)

// SlotDecision is the memoized result of a route-and-occupy DBOS step.
// It captures whether the stage was occupied by an agent or the human,
// and — for the agent path — the StageResult produced by the runner.
// Recovery replays the step and returns this value deterministically.
type SlotDecision struct {
	IsHuman     bool            `json:"is_human"`
	ConfigID    *uuid.UUID      `json:"config_id,omitempty"` // nil for human
	ConfigName  string          `json:"config_name,omitempty"`
	StageResult json.RawMessage `json:"stage_result,omitempty"` // populated only for agent path
}
