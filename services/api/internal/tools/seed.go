package tools

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

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
