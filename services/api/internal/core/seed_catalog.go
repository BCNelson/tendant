package core

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"

	"github.com/jackc/pgx/v5"

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

// SeedAgentCatalog inserts the base agent catalog at boot. Idempotent: skips
// configs that already exist (matched by name + stage).
func SeedAgentCatalog(ctx context.Context, q *db.Queries) error {
	for _, entry := range baseCatalog {
		_, err := q.GetAgentConfigByNameAndStage(ctx, db.GetAgentConfigByNameAndStageParams{
			Name:  entry.Name,
			Stage: entry.Stage,
		})
		if err == nil {
			continue // already exists
		}
		if !errors.Is(err, pgx.ErrNoRows) {
			return err
		}

		prompt := entry.SystemPrompt
		allowlist := entry.ToolAllowlist
		if allowlist == nil {
			allowlist = json.RawMessage(`[]`)
		}

		_, insertErr := q.InsertAgentConfig(ctx, db.InsertAgentConfigParams{
			Name:          entry.Name,
			Stage:         entry.Stage,
			IsHuman:       false,
			SystemPrompt:  &prompt,
			Model:         nil, // uses platform default
			ToolAllowlist: allowlist,
			Eligibility:   entry.Eligibility,
			Origin:        db.ConfigOriginCore,
			Version:       1,
		})
		if insertErr != nil {
			return insertErr
		}
		slog.InfoContext(ctx, "seeded agent config", "name", entry.Name, "stage", entry.Stage)
	}
	return nil
}
