package core

import (
	"bytes"
	"context"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"path"
	"reflect"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/knadh/koanf/parsers/toml"
	"github.com/knadh/koanf/providers/confmap"
	"github.com/knadh/koanf/v2"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// catalogEntry is the in-memory shape the reconciler consumes. It is built from
// the embedded default agents (default_agents/) when no file drives the catalog,
// or from file/community-provided config.AgentDef otherwise.
type catalogEntry struct {
	Name          string
	Stage         db.AgentStage
	SystemPrompt  string
	Model         string
	ToolAllowlist json.RawMessage
	Eligibility   json.RawMessage
	Origin        db.ConfigOrigin
}

// defaultAgentsFS holds the built-in (core-origin) agent specialists, one TOML
// file per agent. Each file uses the same per-file format future community
// agents will use; see catalogEntriesFor / defaultAgentDefs.
//
//go:embed default_agents
var defaultAgentsFS embed.FS

// defaultAgentDefs reads every default_agents/*.toml file (one agent each) into
// the same AgentDef shape the config file uses, so built-in and file/community
// agents share one format and one conversion path. fs.ReadDir returns entries
// sorted by name → deterministic ordering. Intentionally skips config.Load's
// ${env:...} interpolation; defaults must be env-independent.
func defaultAgentDefs() ([]config.AgentDef, error) {
	entries, err := fs.ReadDir(defaultAgentsFS, "default_agents")
	if err != nil {
		return nil, fmt.Errorf("read embedded default_agents: %w", err)
	}
	defs := make([]config.AgentDef, 0, len(entries))
	for _, e := range entries {
		if e.IsDir() || path.Ext(e.Name()) != ".toml" {
			continue
		}
		b, err := defaultAgentsFS.ReadFile(path.Join("default_agents", e.Name()))
		if err != nil {
			return nil, fmt.Errorf("read default agent %s: %w", e.Name(), err)
		}
		def, err := parseAgentFile(b)
		if err != nil {
			return nil, fmt.Errorf("parse default agent %s: %w", e.Name(), err)
		}
		defs = append(defs, def)
	}
	return defs, nil
}

// parseAgentFile decodes a single-agent TOML file into a config.AgentDef using
// the same koanf tag semantics as cfg.Agents, so the embedded defaults can never
// diverge from how file-provided agents are parsed.
func parseAgentFile(b []byte) (config.AgentDef, error) {
	m, err := toml.Parser().Unmarshal(b)
	if err != nil {
		return config.AgentDef{}, err
	}
	k := koanf.New(".")
	if err := k.Load(confmap.Provider(m, "."), nil); err != nil {
		return config.AgentDef{}, err
	}
	var def config.AgentDef
	if err := k.Unmarshal("", &def); err != nil {
		return config.AgentDef{}, err
	}
	return def, nil
}

// SeedAgentCatalog inserts the embedded default agent catalog at boot. Idempotent:
// skips configs that already exist (matched by name + stage). Equivalent to
// ReconcileAgentCatalog with no file-provided definitions.
func SeedAgentCatalog(ctx context.Context, q *db.Queries) error {
	return ReconcileAgentCatalog(ctx, q, nil)
}

// ReconcileAgentCatalog reconciles the agent catalog from config. When defs is
// empty it falls back to the embedded default agents (default_agents/),
// preserving prior boot behavior. When the config file defines agents, those are
// authoritative: each
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
				// No file drives the catalog this boot, so the embedded default
				// agents are the source of truth for core-origin rows. Re-sync a core row
				// whose stored content has drifted from the current default (e.g. a
				// deploy improved a system prompt) so code changes actually reach a
				// live DB. Owner/community customizations (origin != core) are left
				// untouched — an owner-edit path must mark its rows non-core to
				// survive this re-sync.
				if existing.Origin != db.ConfigOriginCore ||
					coreRowMatchesDefault(existing, prompt, modelPtr, allowlist, eligibility) {
					continue
				}
				slog.InfoContext(ctx, "resyncing core agent config to embedded default",
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
				Origin:        entry.Origin,
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
// matches the embedded default for every field the reconciler manages, so the
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

// catalogEntriesFor returns the embedded default agents (default_agents/) when
// defs is empty, else converts the file-provided definitions into catalog
// entries. Both paths run the identical conversion, so the built-in defaults and
// file/community agents share one format. Validates stage, eligibility JSON, and
// origin.
func catalogEntriesFor(defs []config.AgentDef) ([]catalogEntry, error) {
	if len(defs) == 0 {
		d, err := defaultAgentDefs()
		if err != nil {
			return nil, err
		}
		defs = d
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
		origin, err := parseConfigOrigin(d.Origin)
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
		elig := json.RawMessage(`{}`)
		if len(d.Eligibility) > 0 {
			b, err := json.Marshal(d.Eligibility)
			if err != nil {
				return nil, fmt.Errorf("agent %q: marshal eligibility: %w", d.Name, err)
			}
			elig = b
		}
		out = append(out, catalogEntry{
			Name:          d.Name,
			Stage:         stage,
			SystemPrompt:  d.SystemPrompt,
			Model:         d.Model,
			ToolAllowlist: allow,
			Eligibility:   elig,
			Origin:        origin,
		})
	}
	return out, nil
}

// parseConfigOrigin maps a file/def origin to the DB enum. Empty defaults to
// core (the built-in defaults omit it); "community" marks an owner/community
// customization that the boot-time re-sync leaves untouched.
func parseConfigOrigin(s string) (db.ConfigOrigin, error) {
	switch strings.ToLower(strings.TrimSpace(s)) {
	case "", "core":
		return db.ConfigOriginCore, nil
	case "community":
		return db.ConfigOriginCommunity, nil
	default:
		return "", fmt.Errorf("invalid origin %q (want core|community)", s)
	}
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
