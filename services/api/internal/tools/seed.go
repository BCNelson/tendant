package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

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
