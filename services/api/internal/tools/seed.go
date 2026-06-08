package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
)

// ReconcileTools reconciles the tools catalog from config. When defs is empty it
// falls back to the in-code send-email seeders (preserving prior boot behavior).
// When the file defines tools, each is upserted by global_uri; calibration-owned
// columns (trust_score, active_script_version) are never touched by UpsertTool,
// and an owner-edited overseer_instructions is preserved when the file omits it.
func ReconcileTools(ctx context.Context, q *db.Queries, defs []config.ToolDef) error {
	if len(defs) == 0 {
		if err := SeedSendEmail(ctx, q); err != nil {
			return err
		}
		return SeedSendEmailOverseerInstructions(ctx, q)
	}
	for _, d := range defs {
		if d.GlobalURI == "" {
			return fmt.Errorf("tool definition missing global_uri")
		}
		name := d.Name
		rung := d.Rung
		if rung == "" {
			rung = "execute_gated"
		}

		// Permissions: file value wins; if omitted, preserve the existing row's.
		var perms json.RawMessage
		if len(d.Permissions) > 0 {
			b, err := json.Marshal(d.Permissions)
			if err != nil {
				return fmt.Errorf("tool %q: marshal permissions: %w", d.GlobalURI, err)
			}
			perms = b
		}

		// overseer_instructions: file value wins; if omitted, preserve existing
		// (owner edit) rather than clobbering it to NULL.
		var oi *string
		if d.OverseerInstructions != "" {
			oi = &d.OverseerInstructions
		}

		existing, lookupErr := q.GetToolByGlobalURI(ctx, d.GlobalURI)
		switch {
		case lookupErr == nil:
			if name == "" {
				name = existing.Name
			}
			if perms == nil {
				perms = existing.Permissions
			}
			if oi == nil {
				oi = existing.OverseerInstructions
			}
		case errIsNoRows(lookupErr):
			if perms == nil {
				perms = json.RawMessage(`{}`)
			}
		default:
			return fmt.Errorf("tool %q: lookup: %w", d.GlobalURI, lookupErr)
		}

		if _, err := q.UpsertTool(ctx, db.UpsertToolParams{
			GlobalUri:            d.GlobalURI,
			Name:                 name,
			Rung:                 rung,
			Permissions:          perms,
			OverseerInstructions: oi,
		}); err != nil {
			return fmt.Errorf("tool %q: upsert: %w", d.GlobalURI, err)
		}
	}
	return nil
}

func errIsNoRows(err error) bool { return errors.Is(err, pgx.ErrNoRows) }

// SeedSendEmail upserts the canonical send-email tool row on boot.
// Idempotent — safe to run on every startup (the queries.tools UpsertTool
// is ON CONFLICT (global_uri) DO UPDATE).
//
// Permissions JSON is the Phase 3 v1 shape consumed by internal/gate.Floor:
//
//	read_only                : false   — outbound mail is grade-relevant.
//	spend                    : false   — email is not paid.
//	irreversible_third_party : "stranger_recipient"
//	                                    — trips the floor when payload.to is
//	                                      not a known principal globalUri.
//	secret_classes           : []      — reserved (Phase 9 sub-agents).
//
// overseer_instructions is left null here; SeedSendEmailOverseerInstructions
// fills it on first boot only (idempotent — never clobbers owner edits).
func SeedSendEmail(ctx context.Context, q *db.Queries) error {
	perms, err := json.Marshal(map[string]any{
		"read_only":                false,
		"spend":                    false,
		"irreversible_third_party": "stranger_recipient",
		"secret_classes":           []string{},
	})
	if err != nil {
		return fmt.Errorf("seed send-email: marshal permissions: %w", err)
	}
	if _, err := q.UpsertTool(ctx, db.UpsertToolParams{
		GlobalUri:            SendEmailGlobalURI,
		Name:                 "send-email",
		Rung:                 "execute_gated",
		Permissions:          perms,
		OverseerInstructions: nil,
	}); err != nil {
		return fmt.Errorf("seed send-email: upsert: %w", err)
	}
	return nil
}

// DefaultSendEmailOverseerInstructions is the FR-013 default. Surfaced as
// a package-level constant so tests can pin the exact text.
const DefaultSendEmailOverseerInstructions = "Approve sends to known principals whose body does not mention money. Flag anything else for owner review."

// SeedSendEmailOverseerInstructions sets tools.overseer_instructions for
// the send-email row to the FR-013 default IFF the column is currently
// NULL. Idempotent across boots and respectful of owner edits — once an
// owner has tuned the value via setToolOverseerInstructions, subsequent
// boots leave it alone.
func SeedSendEmailOverseerInstructions(ctx context.Context, q *db.Queries) error {
	_, err := q.UpdateToolOverseerInstructionsIfNull(ctx, db.UpdateToolOverseerInstructionsIfNullParams{
		GlobalUri:            SendEmailGlobalURI,
		OverseerInstructions: stringPtr(DefaultSendEmailOverseerInstructions),
	})
	if err != nil {
		// pgx.ErrNoRows happens when overseer_instructions is already set —
		// the WHERE clause filters that row out. Silently treat as success.
		if errIsNoRows(err) {
			return nil
		}
		return fmt.Errorf("seed send-email overseer instructions: %w", err)
	}
	return nil
}

func stringPtr(s string) *string { return &s }

// SeedExampleGateScript optionally attaches the runnable "approve-everything"
// example gate script to send-email when TENDANT_SEED_EXAMPLE_GATE_SCRIPT=true
// (off by default; powers the quickstart demo). Idempotent: it no-ops when the
// tool already has an active script. The module imports nothing, so it passes
// static validation with an empty `reads` set.
func SeedExampleGateScript(ctx context.Context, q *db.Queries) error {
	return SeedExampleGateScriptIf(ctx, q, os.Getenv("TENDANT_SEED_EXAMPLE_GATE_SCRIPT") == "true", gatescript.CeilingsFromEnv())
}

// SeedExampleGateScriptIf is the config-driven form: it attaches the example
// gate script only when enabled, validating against the supplied ceilings. The
// boot path passes cfg.Seed.ExampleGateScript so the toggle is file/env/DB driven.
func SeedExampleGateScriptIf(ctx context.Context, q *db.Queries, enabled bool, ceilings gatescript.Ceilings) error {
	if !enabled {
		return nil
	}
	tool, err := q.GetToolByGlobalURI(ctx, SendEmailGlobalURI)
	if err != nil {
		if errIsNoRows(err) {
			return nil
		}
		return fmt.Errorf("seed example gate script: load tool: %w", err)
	}
	if tool.ActiveScriptVersion != nil {
		return nil // already attached
	}

	wasm := gatescript.ExampleApproveModule()
	manifest := gatescript.ExampleManifest(SendEmailGlobalURI)
	if verr := gatescript.ValidateModule(wasm, manifest, SendEmailGlobalURI, ceilings); verr != nil {
		return fmt.Errorf("seed example gate script: validate: %w", verr)
	}
	rawManifest, _ := json.Marshal(manifest)
	hash, _ := gatescript.ManifestHash(manifest)

	ver, err := q.NextGateScriptVersion(ctx, tool.ID)
	if err != nil {
		return fmt.Errorf("seed example gate script: next version: %w", err)
	}
	if _, err := q.CreateGateScript(ctx, db.CreateGateScriptParams{
		ToolID:              tool.ID,
		Version:             ver,
		Manifest:            rawManifest,
		ManifestHash:        hash,
		Wasm:                wasm,
		Tier:                "byo_wasm",
		AttachedByPrincipal: lifecycleSystemActor,
	}); err != nil {
		return fmt.Errorf("seed example gate script: create: %w", err)
	}
	if _, err := q.UpdateActiveScriptVersion(ctx, db.UpdateActiveScriptVersionParams{
		ID: tool.ID, ActiveScriptVersion: &ver,
	}); err != nil {
		return fmt.Errorf("seed example gate script: advance pointer: %w", err)
	}
	return nil
}

// lifecycleSystemActor mirrors lifecycle.SystemActorURI without importing the
// package (avoids a wider import for a single constant in the seed path).
const lifecycleSystemActor = "local://principal/system"
