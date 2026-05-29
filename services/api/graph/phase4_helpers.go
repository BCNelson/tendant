package graph

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

// loadOverseerEvaluation hydrates the OverseerEvaluation GraphQL type
// from the audit_messages row written by the gateway. The lookup is
// payload->'evidence'->>'decision_id' = decisionID — exact-match against
// the decision the overseer escalated. Returns nil if no row matches
// (floor-raised approvals carry no overseer row).
func (r *Resolver) loadOverseerEvaluation(ctx context.Context, decisionID string) (*model.OverseerEvaluation, error) {
	row, err := r.Queries.OverseerEvaluatedForDecision(ctx, decisionID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("load overseer evaluation: %w", err)
	}
	var p map[string]any
	if err := json.Unmarshal(row.Payload, &p); err != nil {
		return nil, fmt.Errorf("decode overseer evaluation payload: %w", err)
	}

	verdict, _ := p["verdict"].(string)
	modelID, _ := p["model_id"].(string)
	provider, _ := p["provider"].(string)
	tokensIn := intFromAny(p["tokens_in"])
	tokensOut := intFromAny(p["tokens_out"])
	cost := floatFromAny(p["estimated_cost_usd"])

	summary := ""
	considered := []string{}
	if ev, ok := p["evidence"].(map[string]any); ok {
		summary, _ = ev["summary"].(string)
		if rawFields, ok := ev["considered_fields"].([]any); ok {
			considered = make([]string, 0, len(rawFields))
			for _, f := range rawFields {
				if s, ok := f.(string); ok {
					considered = append(considered, s)
				}
			}
		}
	}

	return &model.OverseerEvaluation{
		Verdict:          verdict,
		Summary:          summary,
		ConsideredFields: considered,
		ModelID:          modelID,
		Provider:         provider,
		TokensIn:         tokensIn,
		TokensOut:        tokensOut,
		EstimatedCostUsd: cost,
		At:               row.At,
	}, nil
}

// intFromAny narrows a JSON-decoded number-or-int to int. JSON numbers
// land as float64 from encoding/json; sqlc-rendered counts may already
// be int.
func intFromAny(v any) int {
	switch x := v.(type) {
	case float64:
		return int(x)
	case int:
		return x
	case int32:
		return int(x)
	case int64:
		return int(x)
	}
	return 0
}

// floatFromAny narrows a JSON-decoded number to float64.
func floatFromAny(v any) float64 {
	switch x := v.(type) {
	case float64:
		return x
	case int:
		return float64(x)
	case int32:
		return float64(x)
	case int64:
		return float64(x)
	}
	return 0
}

// permissionDeniedError shapes the canonical PERMISSION_DENIED GraphQL
// error returned by owner-only mutations.
func permissionDeniedError(ctx context.Context) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    "permission denied",
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": "PERMISSION_DENIED"},
	}
}

// invalidPermissionsError shapes the typed error returned by
// setToolPermissions when the JSON fails the schema.
func invalidPermissionsError(ctx context.Context, detail string) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    "invalid permissions: " + detail,
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": "INVALID_PERMISSIONS"},
	}
}

// toolUnknownError shapes the typed error returned by setTool* when the
// toolId doesn't match any tool row.
func toolUnknownError(ctx context.Context, id uuid.UUID) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    fmt.Sprintf("unknown tool: %s", id),
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": "TOOL_UNKNOWN"},
	}
}

// setToolPermissionsImpl is the resolver body. Owner-only via
// auth.RequireOwner; validates the JSON shape via
// overseer.ValidatePermissions; updates the row; logs the change.
//
// Phase 4 does not persist a tool_permissions_changed row in
// audit_messages because audit_messages.task_id is NOT NULL by design
// (state-machine-anchored). Tool tuning is a configuration event, not a
// task event. A dedicated config-events log surface is reserved for
// Phase 5 along with the other gate-script tooling. Until then the
// change is loud in slog.
func (r *Resolver) setToolPermissionsImpl(ctx context.Context, toolID string, permissions map[string]any) (*model.Tool, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}
	id, err := uuid.Parse(toolID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid toolId: %s", err)
	}

	raw, err := json.Marshal(permissions)
	if err != nil {
		return nil, invalidPermissionsError(ctx, fmt.Sprintf("marshal: %v", err))
	}
	if err := overseer.ValidatePermissions(raw); err != nil {
		return nil, invalidPermissionsError(ctx, err.Error())
	}

	// Read previous for the audit log.
	prev, err := r.Queries.GetToolByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, toolUnknownError(ctx, id)
		}
		return nil, fmt.Errorf("get tool: %w", err)
	}

	updated, err := r.Queries.UpdateToolPermissions(ctx, db.UpdateToolPermissionsParams{
		ID:          id,
		Permissions: raw,
	})
	if err != nil {
		return nil, fmt.Errorf("update tool permissions: %w", err)
	}

	slog.Info("graph.set_tool_permissions",
		"tool_id", id,
		"tool_global_uri", updated.GlobalUri,
		"previous_permissions", string(prev.Permissions),
		"new_permissions", string(updated.Permissions),
	)

	return mapToolRow(&updated), nil
}

// setToolOverseerInstructionsImpl is the resolver body for owner-only
// instruction edits. Empty string is allowed (treated as "no owner
// guidance"). The audit log records the SHA-256 hash + length; the
// canonical text lives in tools.overseer_instructions.
func (r *Resolver) setToolOverseerInstructionsImpl(ctx context.Context, toolID, instructions string) (*model.Tool, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}
	id, err := uuid.Parse(toolID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid toolId: %s", err)
	}

	prev, err := r.Queries.GetToolByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, toolUnknownError(ctx, id)
		}
		return nil, fmt.Errorf("get tool: %w", err)
	}

	// sqlc's emit_pointers_for_null_types maps nullable text → *string;
	// empty string is a legal value, so wrap it directly.
	param := &instructions
	updated, err := r.Queries.UpdateToolOverseerInstructions(ctx, db.UpdateToolOverseerInstructionsParams{
		ID:                   id,
		OverseerInstructions: param,
	})
	if err != nil {
		return nil, fmt.Errorf("update tool overseer instructions: %w", err)
	}

	prevHash := sha256Hex(prev.OverseerInstructions)
	newHash := sha256Hex(updated.OverseerInstructions)
	slog.Info("graph.set_tool_overseer_instructions",
		"tool_id", id,
		"tool_global_uri", updated.GlobalUri,
		"previous_hash", prevHash,
		"new_hash", newHash,
		"length_chars", len(instructions),
	)

	return mapToolRow(&updated), nil
}

func sha256Hex(p *string) string {
	if p == nil {
		return ""
	}
	sum := sha256.Sum256([]byte(*p))
	return hex.EncodeToString(sum[:])
}
