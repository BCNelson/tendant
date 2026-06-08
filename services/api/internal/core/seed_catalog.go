package core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"strings"

	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// catalogEntry defines a base agent config to seed.
type catalogEntry struct {
	Name          string
	Stage         db.AgentStage
	SystemPrompt  string
	Model         string
	ToolAllowlist json.RawMessage
	Eligibility   json.RawMessage
}

// baseCatalog is the rich set of core specialists seeded at boot.
var baseCatalog = []catalogEntry{
	// --- Triage stage ---
	{
		Name:         "general-triager",
		Stage:        db.AgentStageTriage,
		SystemPrompt: "You are a triage agent. Analyze the incoming task, confirm it is actionable, score its stakes (1-10), identify category hints, required capabilities, and entities. Emit structured findings.",
		Eligibility:  json.RawMessage(`{}`), // always eligible
	},
	{
		Name:         "high-stakes-triager",
		Stage:        db.AgentStageTriage,
		SystemPrompt: "You are a high-stakes triage specialist. You handle tasks with elevated risk or financial impact. Perform extra due diligence on stakes scoring and entity identification.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"gte","field":"stakes_score","value":7}}`),
	},
	{
		Name:         "communication-triager",
		Stage:        db.AgentStageTriage,
		SystemPrompt: "You specialize in triaging communication tasks (email, messaging, notifications). Identify recipients, urgency, and required communication capabilities.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"contains","field":"category_hints","value":"communication"}}`),
	},

	// --- Expansion stage ---
	{
		Name:         "research-expander",
		Stage:        db.AgentStageExpansion,
		SystemPrompt: "You are a research agent. Gather context, look up relevant information, and enrich the task with context_refs. Do not perform outward actions.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["web_search","doc_lookup"]}}`),
	},
	{
		Name:         "decomposer",
		Stage:        db.AgentStageExpansion,
		SystemPrompt: "You decompose complex multi-step tasks into sub-tasks. Identify dependencies between steps and required capabilities for each.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"contains","field":"category_hints","value":"multi_step"}}`),
	},
	{
		Name:         "general-expander",
		Stage:        db.AgentStageExpansion,
		SystemPrompt: "You are a general expansion agent. Enrich the task with context, identify what tools and capabilities are needed for execution, and emit findings.",
		Eligibility:  json.RawMessage(`{}`), // always eligible
	},

	// --- Execution stage ---
	{
		Name:         "email-specialist",
		Stage:        db.AgentStageExecution,
		SystemPrompt: "You are an email execution agent. You compose and send emails using the send-email tool. Follow the task description precisely for recipients, subject, and body.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["send-email"]}}`),
	},
	{
		Name:         "general-executor",
		Stage:        db.AgentStageExecution,
		SystemPrompt: "You are a general execution agent. Carry out the task using your available tools. Report results clearly.",
		Eligibility:  json.RawMessage(`{}`), // always eligible
	},
	{
		Name:         "code-executor",
		Stage:        db.AgentStageExecution,
		SystemPrompt: "You are a code execution agent specializing in running code, scripts, and technical operations.",
		Eligibility:  json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["run_code"]}}`),
	},
}

// SeedAgentCatalog inserts the in-code base agent catalog at boot. Idempotent:
// skips configs that already exist (matched by name + stage). Equivalent to
// ReconcileAgentCatalog with no file-provided definitions.
func SeedAgentCatalog(ctx context.Context, q *db.Queries) error {
	return ReconcileAgentCatalog(ctx, q, nil)
}

// ReconcileAgentCatalog reconciles the agent catalog from config. When defs is
// empty it falls back to the in-code baseCatalog (preserving prior boot
// behavior). When the config file defines agents, those are authoritative: each
// (name, stage) is upserted — inserted if new, updated if present. The reconcile
// is non-destructive: DB rows the file omits are left untouched (and logged).
func ReconcileAgentCatalog(ctx context.Context, q *db.Queries, defs []config.AgentDef) error {
	entries, err := catalogEntriesFor(defs)
	if err != nil {
		return err
	}
	fileDriven := len(defs) > 0

	for _, entry := range entries {
		prompt := entry.SystemPrompt
		allowlist := entry.ToolAllowlist
		if allowlist == nil {
			allowlist = json.RawMessage(`[]`)
		}
		eligibility := entry.Eligibility
		if len(eligibility) == 0 {
			eligibility = json.RawMessage(`{}`)
		}
		var modelPtr *string
		if entry.Model != "" {
			m := entry.Model
			modelPtr = &m
		}

		_, lookupErr := q.GetAgentConfigByNameAndStage(ctx, db.GetAgentConfigByNameAndStageParams{
			Name:  entry.Name,
			Stage: entry.Stage,
		})
		switch {
		case lookupErr == nil:
			if !fileDriven {
				continue // in-code default already present — idempotent skip
			}
			if _, err := q.UpdateAgentConfigByNameAndStage(ctx, db.UpdateAgentConfigByNameAndStageParams{
				Name:          entry.Name,
				Stage:         entry.Stage,
				IsHuman:       false,
				SystemPrompt:  &prompt,
				Model:         modelPtr,
				ToolAllowlist: allowlist,
				Eligibility:   eligibility,
			}); err != nil {
				return fmt.Errorf("reconcile agent %q/%s: update: %w", entry.Name, entry.Stage, err)
			}
			slog.InfoContext(ctx, "reconciled agent config (updated)", "name", entry.Name, "stage", entry.Stage)
		case errors.Is(lookupErr, pgx.ErrNoRows):
			if _, err := q.InsertAgentConfig(ctx, db.InsertAgentConfigParams{
				Name:          entry.Name,
				Stage:         entry.Stage,
				IsHuman:       false,
				SystemPrompt:  &prompt,
				Model:         modelPtr,
				ToolAllowlist: allowlist,
				Eligibility:   eligibility,
				Origin:        db.ConfigOriginCore,
				Version:       1,
			}); err != nil {
				return fmt.Errorf("reconcile agent %q/%s: insert: %w", entry.Name, entry.Stage, err)
			}
			slog.InfoContext(ctx, "reconciled agent config (inserted)", "name", entry.Name, "stage", entry.Stage)
		default:
			return lookupErr
		}
	}
	return nil
}

// catalogEntriesFor returns the in-code baseCatalog when defs is empty, else
// converts the file-provided definitions into catalog entries (validating stage).
func catalogEntriesFor(defs []config.AgentDef) ([]catalogEntry, error) {
	if len(defs) == 0 {
		return baseCatalog, nil
	}
	out := make([]catalogEntry, 0, len(defs))
	for _, d := range defs {
		if strings.TrimSpace(d.Name) == "" {
			return nil, fmt.Errorf("agent definition missing name")
		}
		stage, err := parseAgentStage(d.Stage)
		if err != nil {
			return nil, fmt.Errorf("agent %q: %w", d.Name, err)
		}
		var allow json.RawMessage
		if len(d.ToolAllowlist) > 0 {
			b, err := json.Marshal(d.ToolAllowlist)
			if err != nil {
				return nil, fmt.Errorf("agent %q: marshal tool_allowlist: %w", d.Name, err)
			}
			allow = b
		}
		var elig json.RawMessage
		if s := strings.TrimSpace(d.Eligibility); s != "" {
			if !json.Valid([]byte(s)) {
				return nil, fmt.Errorf("agent %q: eligibility is not valid JSON", d.Name)
			}
			elig = json.RawMessage(s)
		}
		out = append(out, catalogEntry{
			Name:          d.Name,
			Stage:         stage,
			SystemPrompt:  d.SystemPrompt,
			Model:         d.Model,
			ToolAllowlist: allow,
			Eligibility:   elig,
		})
	}
	return out, nil
}

func parseAgentStage(s string) (db.AgentStage, error) {
	switch strings.ToLower(strings.TrimSpace(s)) {
	case "triage":
		return db.AgentStageTriage, nil
	case "expansion":
		return db.AgentStageExpansion, nil
	case "execution":
		return db.AgentStageExecution, nil
	default:
		return "", fmt.Errorf("invalid stage %q (want triage|expansion|execution)", s)
	}
}
