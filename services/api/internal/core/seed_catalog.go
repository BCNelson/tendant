package core

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"reflect"
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
		Name:  "general-triager",
		Stage: db.AgentStageTriage,
		SystemPrompt: "You are a triage agent. Your job is to assess an incoming task, not to perform it. " +
			"Confirm it is a real, actionable task; score its stakes from 1 (trivial) to 10 (high-risk or " +
			"irreversible); and identify category hints, the capabilities its execution will require, and the " +
			"entities (people, orgs, services) involved. Base every field on what the task actually says — do not " +
			"invent details. Emit structured findings; do not claim any outward action was taken.",
		Eligibility: json.RawMessage(`{}`), // always eligible
	},
	{
		Name:  "high-stakes-triager",
		Stage: db.AgentStageTriage,
		SystemPrompt: "You are a high-stakes triage specialist for tasks with elevated risk, financial impact, or " +
			"irreversibility. Assess only — do not act. Perform extra due diligence on the stakes score and on " +
			"identifying every entity and required capability, and flag anything that should require explicit owner " +
			"approval at execution. Base findings strictly on the task text; do not assume facts you cannot see.",
		Eligibility: json.RawMessage(`{"pred":{"op":"gte","field":"stakes_score","value":7}}`),
	},
	{
		Name:  "communication-triager",
		Stage: db.AgentStageTriage,
		SystemPrompt: "You triage communication tasks (email, messaging, notifications). Assess only — do not send " +
			"anything. Identify the recipients, the urgency, and the communication capabilities execution will " +
			"require (e.g. send-email), and note whether any recipient is a stranger. Emit structured findings " +
			"grounded in the task text.",
		Eligibility: json.RawMessage(`{"pred":{"op":"contains","field":"category_hints","value":"communication"}}`),
	},

	// --- Expansion stage ---
	{
		Name:  "research-expander",
		Stage: db.AgentStageExpansion,
		SystemPrompt: "You are a research agent. Gather context and enrich the task with context_refs and findings. " +
			"You do NOT perform outward actions and you do NOT execute the task. If the task cannot be enriched " +
			"without information or a tool you do not have, call the handoff_to_human tool and explain what is " +
			"missing — never invent sources or facts.",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["web_search","doc_lookup"]}}`),
	},
	{
		Name:  "decomposer",
		Stage: db.AgentStageExpansion,
		SystemPrompt: "You decompose complex multi-step tasks into ordered sub-tasks. Identify the dependencies " +
			"between steps and the capabilities each step requires. You plan only — you do not execute any step. " +
			"Emit findings; if the task is too ambiguous to decompose, call handoff_to_human and say why.",
		Eligibility: json.RawMessage(`{"pred":{"op":"contains","field":"category_hints","value":"multi_step"}}`),
	},
	{
		Name:  "general-expander",
		Stage: db.AgentStageExpansion,
		SystemPrompt: "You are a general expansion agent. Enrich the task with context and identify the tools and " +
			"capabilities its execution will need, then emit findings. You prepare the task for execution — you do " +
			"not execute it. If you cannot enrich it without a missing tool or input, call handoff_to_human.",
		Eligibility: json.RawMessage(`{}`), // always eligible
	},

	// --- Execution stage ---
	{
		Name:  "email-specialist",
		Stage: db.AgentStageExecution,
		SystemPrompt: "You are an email execution agent. You send email ONLY by calling the send-email tool and " +
			"seeing a successful result — composing text is not sending. Follow the task precisely for recipients, " +
			"subject, and body. If the task asks for anything you cannot do with the send-email tool (a phone call, " +
			"a different channel, an attachment you lack), or required details are missing, call the " +
			"handoff_to_human tool with the reason. Never report an email as sent unless the tool actually sent it.",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["send-email"]}}`),
	},
	{
		Name:  "general-executor",
		Stage: db.AgentStageExecution,
		SystemPrompt: "You are a general execution agent. Carry out the task using ONLY the tools available to you, " +
			"and report only actions you actually performed via a tool call that returned success. Many tasks " +
			"require an action you have no tool for (placing a phone call, signing or mailing a document, visiting " +
			"a place) — when that is the case, or when required information is missing, you MUST call the " +
			"handoff_to_human tool with a clear reason instead of claiming the work is done. Never fabricate a " +
			"completion. When in doubt, hand off.",
		Eligibility: json.RawMessage(`{}`), // always eligible
	},
	{
		Name:  "code-executor",
		Stage: db.AgentStageExecution,
		SystemPrompt: "You are a code execution agent for running code, scripts, and technical operations. Execute " +
			"only through the tools available to you and report only results you actually observed. If the task " +
			"needs a capability, credential, or environment you do not have, call the handoff_to_human tool with " +
			"the reason rather than claiming success you cannot verify.",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["run_code"]}}`),
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

		existing, lookupErr := q.GetAgentConfigByNameAndStage(ctx, db.GetAgentConfigByNameAndStageParams{
			Name:  entry.Name,
			Stage: entry.Stage,
		})
		switch {
		case lookupErr == nil:
			if !fileDriven {
				// No file drives the catalog this boot, so the in-code baseCatalog
				// is the source of truth for core-origin rows. Re-sync a core row
				// whose stored content has drifted from the current default (e.g. a
				// deploy improved a system prompt) so code changes actually reach a
				// live DB. Owner/community customizations (origin != core) are left
				// untouched — an owner-edit path must mark its rows non-core to
				// survive this re-sync.
				if existing.Origin != db.ConfigOriginCore ||
					coreRowMatchesDefault(existing, prompt, modelPtr, allowlist, eligibility) {
					continue
				}
				slog.InfoContext(ctx, "resyncing core agent config to in-code default",
					"name", entry.Name, "stage", entry.Stage, "from_version", existing.Version)
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

// coreRowMatchesDefault reports whether an existing core-origin row already
// matches the in-code default for every field the reconciler manages, so the
// boot-time re-sync can skip a no-op update and avoid a pointless version bump.
func coreRowMatchesDefault(existing db.AgentConfig, prompt string, modelPtr *string, allowlist, eligibility json.RawMessage) bool {
	if existing.IsHuman {
		return false
	}
	if existing.SystemPrompt == nil || *existing.SystemPrompt != prompt {
		return false
	}
	if !ptrStrEqual(existing.Model, modelPtr) {
		return false
	}
	return jsonEqual(existing.ToolAllowlist, allowlist) && jsonEqual(existing.Eligibility, eligibility)
}

// ptrStrEqual compares two *string for value equality (both nil ⇒ equal).
func ptrStrEqual(a, b *string) bool {
	if a == nil || b == nil {
		return a == b
	}
	return *a == *b
}

// jsonEqual compares two JSON documents for semantic equality (whitespace- and
// key-order-insensitive), so a re-sync isn't triggered by jsonb's canonical
// reformatting of an unchanged value. Falls back to a raw byte compare when
// either side is not valid JSON.
func jsonEqual(a, b json.RawMessage) bool {
	var av, bv any
	if err := json.Unmarshal(a, &av); err != nil {
		return bytes.Equal(a, b)
	}
	if err := json.Unmarshal(b, &bv); err != nil {
		return bytes.Equal(a, b)
	}
	return reflect.DeepEqual(av, bv)
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
