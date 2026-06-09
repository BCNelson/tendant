package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/feedback"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// parseDraftGuidance pulls the agent's current draft guidance out of a
// feedback_request decision payload. Returns nil when absent/empty.
func parseDraftGuidance(payload []byte) *string {
	if len(payload) == 0 {
		return nil
	}
	var p feedback.DecisionPayload
	if err := json.Unmarshal(payload, &p); err != nil {
		return nil
	}
	if p.DraftGuidance == "" {
		return nil
	}
	return &p.DraftGuidance
}

// mapAgentGuidance maps a db row to the gqlgen model.
func mapAgentGuidance(row db.AgentGuidance) *model.AgentGuidance {
	g := &model.AgentGuidance{
		ID:        row.ID.String(),
		Note:      row.Note,
		Scope:     model.GuidanceScope(strings.ToUpper(row.Scope)),
		CreatedAt: row.CreatedAt,
	}
	if row.AgentConfigID.Valid {
		id := uuid.UUID(row.AgentConfigID.Bytes).String()
		g.AgentConfigID = &id
	}
	return g
}

// converser returns the resolver's feedback converser, or the deterministic
// stub when none is wired (pre-config tests).
func (r *Resolver) converser() feedback.Converser {
	if r.FeedbackConverser != nil {
		return r.FeedbackConverser
	}
	return feedback.StubConverser{}
}

// loadFeedbackMessages loads a FeedbackRequest's conversation thread.
func (r *Resolver) loadFeedbackMessages(ctx context.Context, decisionIDStr string) ([]*model.FeedbackMessage, error) {
	id, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decisionId: %s", err)
	}
	rows, err := r.Queries.ListFeedbackMessages(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("list feedback messages: %w", err)
	}
	out := make([]*model.FeedbackMessage, 0, len(rows))
	for _, m := range rows {
		out = append(out, &model.FeedbackMessage{
			ID:        m.ID.String(),
			Role:      m.Role,
			Content:   m.Content,
			CreatedAt: m.CreatedAt,
		})
	}
	return out, nil
}

// loadFeedbackDecision loads + validates an open feedback_request decision.
func (r *Resolver) loadFeedbackDecision(ctx context.Context, id uuid.UUID) (db.PendingDecision, error) {
	row, err := r.Queries.GetPendingDecisionByID(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return db.PendingDecision{}, gateError(ctx, "DECISION_NOT_FOUND", "decision not found")
		}
		return db.PendingDecision{}, fmt.Errorf("get decision: %w", err)
	}
	if row.Kind != db.DecisionKindFeedbackRequest {
		return db.PendingDecision{}, gateError(ctx, "DECISION_KIND_MISMATCH", "decision is not a feedback request")
	}
	if row.ResolvedAt.Valid {
		return db.PendingDecision{}, gateError(ctx, "DECISION_ALREADY_RESOLVED", "feedback conversation already closed")
	}
	return row, nil
}

// sendFeedbackMessageImpl appends the owner's message, asks the converser for a
// reply + refreshed draft, persists both, and returns the updated request.
func (r *Resolver) sendFeedbackMessageImpl(ctx context.Context, decisionIDStr string, text string) (*model.FeedbackRequest, error) {
	if _, ok := auth.FromContext(ctx); !ok {
		return nil, unauthorizedError(ctx)
	}
	id, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decisionId: %s", err)
	}
	if strings.TrimSpace(text) == "" {
		return nil, gqlerror.Errorf("message text must not be empty")
	}
	row, err := r.loadFeedbackDecision(ctx, id)
	if err != nil {
		return nil, err
	}
	var payload feedback.DecisionPayload
	_ = json.Unmarshal(row.Payload, &payload)

	// Append the user turn first so it is part of the history handed to Reply.
	if _, err := r.Queries.InsertFeedbackMessage(ctx, db.InsertFeedbackMessageParams{
		DecisionID: id, Role: "user", Content: text,
	}); err != nil {
		return nil, fmt.Errorf("insert user message: %w", err)
	}

	thread, err := r.Queries.ListFeedbackMessages(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("list feedback messages: %w", err)
	}
	history := make([]feedback.Turn, 0, len(thread))
	for _, m := range thread {
		history = append(history, feedback.Turn{Role: m.Role, Content: m.Content})
	}

	reply, draft, cerr := r.converser().Reply(ctx, payload.TaskSummary, history)
	if cerr != nil {
		return nil, fmt.Errorf("feedback reply: %w", cerr)
	}
	if strings.TrimSpace(reply) == "" {
		reply = "Thanks — I've updated the draft guidance below."
	}

	if _, err := r.Queries.InsertFeedbackMessage(ctx, db.InsertFeedbackMessageParams{
		DecisionID: id, Role: "agent", Content: reply,
	}); err != nil {
		return nil, fmt.Errorf("insert agent message: %w", err)
	}

	// Persist the refreshed draft on the decision payload.
	payload.DraftGuidance = draft
	if newPayload, merr := json.Marshal(payload); merr == nil {
		if err := r.Queries.SetFeedbackDecisionPayload(ctx, db.SetFeedbackDecisionPayloadParams{
			ID: id, Payload: newPayload,
		}); err != nil {
			return nil, fmt.Errorf("update draft guidance: %w", err)
		}
	}

	out := &model.FeedbackRequest{ID: id.String(), CreatedAt: row.CreatedAt}
	if draft != "" {
		out.DraftGuidance = &draft
	}
	return out, nil
}

// acceptFeedbackGuidanceImpl (owner-only) stores the guidance verbatim, resolves
// the decision, and wakes the workflow. Empty guidance accepts with no note.
func (r *Resolver) acceptFeedbackGuidanceImpl(ctx context.Context, decisionIDStr, guidance string, scope model.GuidanceScope, agentConfigID *string, rating *int) (*model.AgentGuidance, error) {
	if r.DBOS == nil {
		return nil, fmt.Errorf("feedback workflow not available — DBOS context is nil")
	}
	principal, err := auth.RequireOwner(ctx)
	if err != nil {
		return nil, err
	}
	id, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decisionId: %s", err)
	}

	var agentCfg pgtype.UUID
	if scope == model.GuidanceScopeAgent {
		if agentConfigID == nil {
			return nil, gateError(ctx, "INVALID_SCOPE", "agentConfigId is required when scope is AGENT")
		}
		acID, perr := uuid.Parse(*agentConfigID)
		if perr != nil {
			return nil, gqlerror.Errorf("invalid agentConfigId: %s", perr)
		}
		agentCfg = pgtype.UUID{Bytes: acID, Valid: true}
	}

	row, err := r.loadFeedbackDecision(ctx, id)
	if err != nil {
		return nil, err
	}
	taskID := row.TaskID
	ratingVal := 0
	if rating != nil {
		ratingVal = *rating
	}

	// Insert the verbatim guidance (if any) + audit, in one tx.
	var guidanceModel *model.AgentGuidance
	var guidanceID *uuid.UUID
	if strings.TrimSpace(guidance) != "" {
		if err := pgx.BeginFunc(ctx, r.Pool, func(tx pgx.Tx) error {
			q := db.New(tx)
			gRow, ierr := q.InsertActiveAgentGuidance(ctx, db.InsertActiveAgentGuidanceParams{
				Note:             guidance,
				Scope:            strings.ToLower(string(scope)),
				AgentConfigID:    agentCfg,
				SourceDecisionID: pgtype.UUID{Bytes: id, Valid: true},
				SourceTaskID:     pgtype.UUID{Bytes: taskID, Valid: true},
			})
			if ierr != nil {
				return fmt.Errorf("insert active guidance: %w", ierr)
			}
			guidanceModel = mapAgentGuidance(gRow)
			gid := gRow.ID
			guidanceID = &gid

			var acPtr *uuid.UUID
			if agentCfg.Valid {
				ac := uuid.UUID(agentCfg.Bytes)
				acPtr = &ac
			}
			parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
			if perr != nil {
				return perr
			}
			_, aerr := lifecycle.WriteAuditMessage(ctx, tx, taskID, principal.GlobalURI,
				lifecycle.KindAgentGuidanceApplied,
				lifecycle.AgentGuidanceAppliedPayload{
					GuidanceID:    gRow.ID,
					Scope:         strings.ToLower(string(scope)),
					AgentConfigID: acPtr,
				},
				parent,
			)
			return aerr
		}); err != nil {
			return nil, err
		}
	}

	// Resolve the decision (first-write-wins) + wake the workflow.
	resolution, _ := json.Marshal(map[string]any{
		"accepted": true, "rating": ratingVal, "guidance_id": guidanceID, "resolved_by": principal.GlobalURI,
	})
	if _, err := r.Queries.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
		ID: id, ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true}, Resolution: resolution,
	}); err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("resolve feedback decision: %w", err)
	}
	if err := feedback.ResolveFeedback(r.DBOS, id, true, ratingVal, guidanceID, principal.GlobalURI); err != nil {
		return nil, fmt.Errorf("wake feedback workflow: %w", err)
	}
	return guidanceModel, nil
}

// dismissFeedbackImpl (owner-only) closes the conversation with no guidance.
func (r *Resolver) dismissFeedbackImpl(ctx context.Context, decisionIDStr string, rating *int) (model.PendingDecision, error) {
	if r.DBOS == nil {
		return nil, fmt.Errorf("feedback workflow not available — DBOS context is nil")
	}
	principal, err := auth.RequireOwner(ctx)
	if err != nil {
		return nil, err
	}
	id, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decisionId: %s", err)
	}
	if _, err := r.loadFeedbackDecision(ctx, id); err != nil {
		return nil, err
	}
	ratingVal := 0
	if rating != nil {
		ratingVal = *rating
	}
	resolution, _ := json.Marshal(map[string]any{
		"accepted": false, "rating": ratingVal, "resolved_by": principal.GlobalURI,
	})
	row, err := r.Queries.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
		ID: id, ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true}, Resolution: resolution,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			existing, gerr := r.Queries.GetPendingDecisionByID(ctx, id)
			if gerr != nil {
				return nil, fmt.Errorf("get decision: %w", gerr)
			}
			return mapPendingDecisionRow(&existing)
		}
		return nil, fmt.Errorf("resolve feedback decision: %w", err)
	}
	if err := feedback.ResolveFeedback(r.DBOS, id, false, ratingVal, nil, principal.GlobalURI); err != nil {
		return nil, fmt.Errorf("wake feedback workflow: %w", err)
	}
	return mapPendingDecisionRow(&row)
}

// deactivateAgentGuidanceImpl (owner-only) retires an active guidance note.
func (r *Resolver) deactivateAgentGuidanceImpl(ctx context.Context, guidanceIDStr string) (*model.AgentGuidance, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, err
	}
	id, err := uuid.Parse(guidanceIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid guidanceId: %s", err)
	}
	row, err := r.Queries.DeactivateAgentGuidance(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, gateError(ctx, "GUIDANCE_NOT_FOUND", "active guidance not found")
		}
		return nil, fmt.Errorf("deactivate guidance: %w", err)
	}
	return mapAgentGuidance(row), nil
}

// agentGuidanceImpl (owner-only) lists guidance notes by status (default active).
func (r *Resolver) agentGuidanceImpl(ctx context.Context, status *string) ([]*model.AgentGuidance, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, err
	}
	st := "active"
	if status != nil && *status != "" {
		st = *status
	}
	rows, err := r.Queries.ListAgentGuidanceByStatus(ctx, st)
	if err != nil {
		return nil, fmt.Errorf("list guidance: %w", err)
	}
	out := make([]*model.AgentGuidance, 0, len(rows))
	for _, row := range rows {
		out = append(out, mapAgentGuidance(row))
	}
	return out, nil
}
