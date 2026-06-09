package graph

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/google/uuid"
)

// agentStageOrder is the fixed set of agent-occupiable chain stages, in order.
// CREATION and COMPLETION are never agent-occupied, so they have no slot.
var agentStageOrder = []model.AgentStage{
	model.AgentStageTriage,
	model.AgentStageExpansion,
	model.AgentStageExecution,
}

// agentRunAuditPayload mirrors the agent_run_started audit payload written by
// internal/agent.Runner (config_id / config_name / stage).
type agentRunAuditPayload struct {
	ConfigID   uuid.UUID `json:"config_id"`
	ConfigName string    `json:"config_name"`
	Stage      string    `json:"stage"`
}

// stageOccupancy is the per-stage tri-state derived from the audit DAG.
type stageOccupancy struct {
	configID uuid.UUID
	hasAgent bool // an agent_run_started landed for this stage
	hasHuman bool // an assignment_created landed for this stage
}

// buildStageSlots derives per-stage occupancy for a task from its audit DAG.
//
// The chain workflow memoises routing as a DBOS step rather than a queryable
// table, so the audit trail is the canonical record of who actually occupied
// each stage: agent_run_started identifies an agent (config in the payload),
// assignment_created identifies the human owner. Stages not yet reached return
// an empty slot (occupant nil, isHuman false). Combined with Task.currentStage,
// a viewer can see which agent is working a task right now.
func buildStageSlots(ctx context.Context, q *db.Queries, taskID uuid.UUID) ([]*model.StageSlot, error) {
	audits, err := q.ListAuditForTask(ctx, taskID)
	if err != nil {
		return nil, err
	}

	byStage := map[string]*stageOccupancy{}
	get := func(stage string) *stageOccupancy {
		o := byStage[stage]
		if o == nil {
			o = &stageOccupancy{}
			byStage[stage] = o
		}
		return o
	}

	for _, m := range audits {
		switch m.Kind {
		case lifecycle.KindAgentRunStarted:
			var p agentRunAuditPayload
			if json.Unmarshal(m.Payload, &p) == nil && p.Stage != "" {
				o := get(strings.ToLower(p.Stage))
				o.hasAgent = true
				o.configID = p.ConfigID
			}
		case lifecycle.KindAssignmentCreated:
			var p lifecycle.AssignmentCreatedPayload
			if json.Unmarshal(m.Payload, &p) == nil {
				get(strings.ToLower(string(p.Stage))).hasHuman = true
			}
		}
	}

	slots := make([]*model.StageSlot, 0, len(agentStageOrder))
	for _, stage := range agentStageOrder {
		slot := &model.StageSlot{Stage: stage}
		switch o := byStage[strings.ToLower(string(stage))]; {
		case o != nil && o.hasAgent:
			// Agent ran (or is running) this stage — name the specialist.
			if cfg, cerr := q.GetAgentConfigByID(ctx, o.configID); cerr == nil {
				slot.Occupant = mapAgentConfigSummary(cfg)
			}
		case o != nil && o.hasHuman:
			slot.IsHuman = true
		}
		slots = append(slots, slot)
	}
	return slots, nil
}
