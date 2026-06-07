package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// decisionError shapes a typed GraphQL error for the promotion mutations.
func decisionError(ctx context.Context, code, msg string) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    msg,
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": code},
	}
}

// respondToPromotionImpl is the body behind RespondToPromotion. OWNER-ONLY:
// auth.RequireOwner is the FIRST statement, before any DB access (Constitution
// IV; NFR-004). On accept the trust score jumps into the proposed band and a
// live per-routine grant is created, in one tx; on decline the proposal is
// withdrawn with no score change.
func (r *Resolver) respondToPromotionImpl(ctx context.Context, proposalID string, accept bool) (*model.Tool, error) {
	owner, err := auth.RequireOwner(ctx)
	if err != nil {
		return nil, permissionDeniedError(ctx)
	}

	id, err := uuid.Parse(proposalID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid proposalId: %s", err)
	}

	row, err := r.Queries.GetPendingDecisionByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, decisionError(ctx, "DECISION_UNKNOWN", "promotion proposal not found")
		}
		return nil, fmt.Errorf("get proposal: %w", err)
	}
	if row.Kind != db.DecisionKindPromotionProposal {
		return nil, decisionError(ctx, "DECISION_UNKNOWN", "decision is not a promotion proposal")
	}
	if row.ResolvedAt.Valid {
		return nil, decisionError(ctx, "DECISION_ALREADY_RESOLVED", "promotion proposal already resolved")
	}
	if !row.ToolID.Valid {
		return nil, decisionError(ctx, "DECISION_UNKNOWN", "proposal has no tool")
	}
	toolID := uuid.UUID(row.ToolID.Bytes)

	var payload struct {
		RoutineFingerprint string          `json:"routine_fingerprint"`
		Evidence           json.RawMessage `json:"evidence"`
	}
	_ = json.Unmarshal(row.Payload, &payload)

	var updated db.Tool
	if txErr := pgx.BeginFunc(ctx, r.Pool, func(tx pgx.Tx) error {
		q := db.New(tx)

		// First-write-wins resolution.
		resolution, merr := json.Marshal(map[string]any{"accepted": accept, "resolved_by": owner.GlobalURI})
		if merr != nil {
			return merr
		}
		if _, rerr := q.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
			ID:         id,
			ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
			Resolution: resolution,
		}); rerr != nil {
			if errors.Is(rerr, pgx.ErrNoRows) {
				return decisionError(ctx, "DECISION_ALREADY_RESOLVED", "promotion proposal already resolved")
			}
			return fmt.Errorf("resolve proposal: %w", rerr)
		}

		newScore := 0.0
		if accept {
			tool, gerr := q.GetToolForUpdate(ctx, toolID)
			if gerr != nil {
				return fmt.Errorf("lock tool: %w", gerr)
			}
			newScore = calibration.PromoteTo(tool.TrustScore)
			t, serr := q.SetTrustScore(ctx, db.SetTrustScoreParams{
				ID:         toolID,
				TrustScore: newScore,
				Rung:       string(calibration.Band(newScore)),
			})
			if serr != nil {
				return fmt.Errorf("set trust score: %w", serr)
			}
			updated = t

			evidence := payload.Evidence
			if len(evidence) == 0 {
				evidence = json.RawMessage(`{}`)
			}
			if _, ierr := q.InsertRoutineGrant(ctx, db.InsertRoutineGrantParams{
				ToolID:             toolID,
				RoutineFingerprint: payload.RoutineFingerprint,
				Evidence:           evidence,
				GrantedBy:          owner.GlobalURI,
			}); ierr != nil {
				return fmt.Errorf("insert routine grant: %w", ierr)
			}
		} else {
			t, gerr := q.GetToolByID(ctx, toolID)
			if gerr != nil {
				return fmt.Errorf("get tool: %w", gerr)
			}
			updated = t
		}

		// promotion_responded audit on the representative task.
		parent, perr := latestTransitionIDInTx(ctx, tx, row.TaskID)
		if perr != nil {
			return perr
		}
		if _, aerr := lifecycle.WriteAuditMessage(ctx, tx, row.TaskID, owner.GlobalURI,
			lifecycle.KindPromotionResponded,
			lifecycle.PromotionRespondedPayload{
				ToolID:     toolID,
				DecisionID: id,
				Accepted:   accept,
				NewScore:   newScore,
			},
			parent,
		); aerr != nil {
			return aerr
		}
		return nil
	}); txErr != nil {
		return nil, txErr
	}

	return mapToolRow(&updated), nil
}

// flagOutcomeImpl is the body behind FlagOutcome. OWNER-ONLY: auth.RequireOwner
// FIRST. Delegates the record-bad + reflexive-demote to the Calibrator.
func (r *Resolver) flagOutcomeImpl(ctx context.Context, taskID, toolID string, reason *string) (*model.Tool, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}
	if r.Calibrator == nil {
		return nil, fmt.Errorf("calibration not available — Calibrator is nil")
	}
	tid, err := uuid.Parse(taskID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid taskId: %s", err)
	}
	toid, err := uuid.Parse(toolID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid toolId: %s", err)
	}

	// Validate referents up front for typed errors.
	if _, err := r.Queries.GetTask(ctx, tid); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, decisionError(ctx, "TASK_UNKNOWN", "task not found")
		}
		return nil, fmt.Errorf("get task: %w", err)
	}
	if _, err := r.Queries.GetToolByID(ctx, toid); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, decisionError(ctx, "TOOL_UNKNOWN", "tool not found")
		}
		return nil, fmt.Errorf("get tool: %w", err)
	}

	reasonStr := ""
	if reason != nil {
		reasonStr = *reason
	}
	tool, err := r.Calibrator.FlagBad(ctx, tid, toid, reasonStr)
	if err != nil {
		return nil, fmt.Errorf("flag outcome: %w", err)
	}
	return mapToolRow(&tool), nil
}
