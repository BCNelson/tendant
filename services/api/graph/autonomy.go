package graph

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/router"
)

// deriveTaskAutonomy computes a task's autonomy, layering the Phase-7 intake
// readout on top of the Phase-6 specialist derivation:
//
//   - An intake-origin task (intake_signal_id set) that is still `accepted` and
//     whose originating signal was an auto-accepted rich_event reports
//     ENRICH_ONLY — it ran expansion but execution still routes to the owner
//     (research R4 / D5). This is the derived posture, no stored dial.
//   - Otherwise the normal findings-based derivation applies.
func deriveTaskAutonomy(ctx context.Context, q *db.Queries, t *db.Task) model.AutonomyLevel {
	if q != nil && t.IntakeSignalID.Valid && t.State == db.TaskStateAccepted {
		if sig, err := q.GetSignal(ctx, t.IntakeSignalID.Bytes); err == nil &&
			sig.Disposition == db.SignalDispositionRichEvent {
			return model.AutonomyLevelEnrichOnly
		}
	}
	return DeriveAutonomy(ctx, q, t.Findings)
}

// DeriveAutonomy computes the autonomy level for a task based on:
// 1. Which specialist (if any) would hold the execution stage given current findings.
// 2. The highest tool rung reachable through that specialist's allowlist.
//
// Returns NONE if the human would hold the slot (no eligible specialist).
// The derivation changes when: the execution specialist is swapped (different
// findings → different eligibility), or a tool's rung is promoted.
func DeriveAutonomy(ctx context.Context, q *db.Queries, findings json.RawMessage) model.AutonomyLevel {
	if q == nil {
		return model.AutonomyLevelNone
	}

	// Parse findings.
	var f agent.Findings
	if len(findings) == 0 || string(findings) == "{}" {
		return model.AutonomyLevelNone
	}
	if err := json.Unmarshal(findings, &f); err != nil {
		return model.AutonomyLevelNone
	}

	// Load execution-stage configs and prune by eligibility.
	configs, err := q.ListAgentConfigsByStage(ctx, db.AgentStageExecution)
	if err != nil || len(configs) == 0 {
		return model.AutonomyLevelNone
	}

	eligible := router.PruneEligible(configs, f.Structured)
	if len(eligible) == 0 {
		return model.AutonomyLevelNone // human would hold the slot
	}

	// Take the first eligible specialist's tool allowlist.
	cfg := eligible[0]
	var toolIDs []uuid.UUID
	if err := json.Unmarshal(cfg.ToolAllowlist, &toolIDs); err != nil || len(toolIDs) == 0 {
		return model.AutonomyLevelEnrichOnly // specialist with no tools
	}

	// Load tools and determine highest rung.
	hasAuto := false
	hasGated := false
	for _, tid := range toolIDs {
		tool, err := q.GetToolByID(ctx, tid)
		if err != nil {
			continue
		}
		switch tool.Rung {
		case "execute_auto":
			hasAuto = true
		case "execute_gated":
			hasGated = true
		}
	}

	switch {
	case hasAuto:
		return model.AutonomyLevelExecuteAuto
	case hasGated:
		return model.AutonomyLevelExecuteGated
	default:
		return model.AutonomyLevelPropose
	}
}
