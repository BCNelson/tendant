package router

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// SlotDecision mirrors chain.SlotDecision without importing chain (avoids cycle).
type SlotDecision struct {
	IsHuman    bool       `json:"is_human"`
	ConfigID   *uuid.UUID `json:"config_id,omitempty"`
	ConfigName string     `json:"config_name,omitempty"`
}

// Router implements the eligibility-prune-then-LLM-pick pattern.
type Router struct {
	queries *db.Queries
	picker  Picker
}

// Picker is the LLM-powered selection among eligible survivors.
type Picker interface {
	Pick(ctx context.Context, eligible []db.AgentConfig, freeText string) (*db.AgentConfig, error)
}

// New creates a Router with the given queries and LLM picker.
func New(queries *db.Queries, picker Picker) *Router {
	return &Router{queries: queries, picker: picker}
}

// Select performs the full routing: prune by eligibility, LLM pick, validate,
// fallback to human. The human is always an eligible candidate (synthesized,
// not a DB row).
func (r *Router) Select(ctx context.Context, stage db.AgentStage, findingsRaw json.RawMessage) (SlotDecision, error) {
	// Parse findings.
	var findings agent.Findings
	if len(findingsRaw) > 0 && string(findingsRaw) != "{}" {
		if err := json.Unmarshal(findingsRaw, &findings); err != nil {
			slog.WarnContext(ctx, "router: malformed findings, defaulting to human", "err", err)
			return humanDecision(), nil
		}
	}

	// Load configs for this stage.
	configs, err := r.queries.ListAgentConfigsByStage(ctx, stage)
	if err != nil {
		return SlotDecision{}, fmt.Errorf("list configs for stage %s: %w", stage, err)
	}

	// Prune by eligibility.
	eligible := PruneEligible(configs, findings.Structured)

	if len(eligible) == 0 {
		// No specialist eligible — human only.
		slog.InfoContext(ctx, "router: no eligible specialists, routing to human", "stage", stage)
		return humanDecision(), nil
	}

	// LLM pick among eligible.
	picked, err := r.picker.Pick(ctx, eligible, findings.FreeText)
	if err != nil {
		slog.WarnContext(ctx, "router: picker error, falling back to human", "err", err)
		return humanDecision(), nil
	}

	// Validate pick is in eligible set.
	if picked == nil || !isInEligibleSet(picked.ID, eligible) {
		slog.WarnContext(ctx, "router: pick not in eligible set, falling back to human",
			"picked_id", picked)
		return humanDecision(), nil
	}

	id := picked.ID
	return SlotDecision{
		IsHuman:    false,
		ConfigID:   &id,
		ConfigName: picked.Name,
	}, nil
}

// PruneEligible filters configs by evaluating each config's eligibility
// expression against the findings' structured fields. Only configs whose
// expression evaluates to true are returned.
func PruneEligible(configs []db.AgentConfig, findings agent.StructuredFindings) []db.AgentConfig {
	var eligible []db.AgentConfig
	for _, cfg := range configs {
		expr := ParseExpression(cfg.Eligibility)
		if Evaluate(expr, findings) {
			eligible = append(eligible, cfg)
		}
	}
	return eligible
}

func humanDecision() SlotDecision {
	return SlotDecision{IsHuman: true}
}

func isInEligibleSet(id uuid.UUID, eligible []db.AgentConfig) bool {
	for _, cfg := range eligible {
		if cfg.ID == id {
			return true
		}
	}
	return false
}
