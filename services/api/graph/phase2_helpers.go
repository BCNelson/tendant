package graph

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/inbox"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
)

// unauthorizedError shapes the canonical UNAUTHORIZED GraphQL error.
func unauthorizedError(ctx context.Context) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    "unauthorized",
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": "UNAUTHORIZED"},
	}
}

// notYetAvailable shapes the canonical NOT_YET_AVAILABLE error returned by
// the Phase 2 stubbed decision mutations per FR-005.
func notYetAvailable(ctx context.Context, field string) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    fmt.Sprintf("%s is declared in Phase 2 but not yet reachable (lands in Phase 3)", field),
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": "NOT_YET_AVAILABLE"},
	}
}

// devicePlatformGraphToDB converts the GraphQL DevicePlatform enum to its
// database counterpart.
func devicePlatformGraphToDB(p model.DevicePlatform) (db.DevicePlatform, error) {
	switch p {
	case model.DevicePlatformIos:
		return db.DevicePlatformIos, nil
	case model.DevicePlatformAndroid:
		return db.DevicePlatformAndroid, nil
	case model.DevicePlatformWeb:
		return db.DevicePlatformWeb, nil
	}
	return "", gqlerror.Errorf("unsupported platform: %s", p)
}

// phase2PlaceholderTool returns a stub Tool model for Phase 2 — Phase 3
// wires real Tool rows through pending_decisions.tool_id and tools.
func phase2PlaceholderTool() *model.Tool {
	return &model.Tool{
		ID:          "phase2-placeholder",
		GlobalURI:   "local://tool/phase2",
		Name:        "(Phase 3)",
		Rung:        model.AutonomyLevelNone,
		Permissions: map[string]any{},
	}
}

// loadDecisionTask loads the Task associated with a pending_decisions row.
// Used by ApprovalRequest/AgentQuestion/PromotionProposal task resolvers.
func (r *Resolver) loadDecisionTask(ctx context.Context, decisionID string) (*model.Task, error) {
	id, err := uuid.Parse(decisionID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decision id: %s", err)
	}
	row, err := r.Queries.GetPendingDecisionByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("get pending decision: %w", err)
	}
	t, err := r.Queries.GetTask(ctx, row.TaskID)
	if err != nil {
		return nil, fmt.Errorf("get task: %w", err)
	}
	return mapTask(&t)
}

// mapInboxItem turns an inbox.AssembledItem into the matching gqlgen
// InboxItem union member. Returns nil if the row is incomplete. The three
// PendingDecision concrete types implement both PendingDecision and
// InboxItem; we cast through the concrete pointer to satisfy the union.
func mapInboxItem(it inbox.AssembledItem) (model.InboxItem, error) {
	switch it.Kind {
	case "pending_decision":
		if it.PendingDecision == nil {
			return nil, nil
		}
		pd, err := mapPendingDecisionRow(it.PendingDecision)
		if err != nil {
			return nil, err
		}
		return pendingDecisionToInboxItem(pd)
	case "agent_assignment":
		if it.AgentAssignment == nil {
			return nil, nil
		}
		a, err := mapAssignment(it.AgentAssignment)
		if err != nil {
			return nil, err
		}
		if a == nil {
			return nil, nil
		}
		return *a, nil
	}
	return nil, fmt.Errorf("unknown inbox kind: %s", it.Kind)
}

// pendingDecisionToInboxItem dispatches the PendingDecision interface back
// to its concrete *ApprovalRequest / *AgentQuestion / *PromotionProposal
// — each of which implements InboxItem.
func pendingDecisionToInboxItem(pd model.PendingDecision) (model.InboxItem, error) {
	switch v := pd.(type) {
	case *model.ApprovalRequest:
		return v, nil
	case *model.AgentQuestion:
		return v, nil
	case *model.PromotionProposal:
		return v, nil
	case *model.FeedbackRequest:
		return v, nil
	}
	return nil, fmt.Errorf("PendingDecision %T does not implement InboxItem", pd)
}

// mapPendingDecisionRow returns the typed gqlgen union member for the
// underlying decisions row, discriminated by pending_decisions.kind.
func mapPendingDecisionRow(row *db.PendingDecision) (model.PendingDecision, error) {
	id := row.ID.String()
	switch row.Kind {
	case db.DecisionKindApprovalRequest:
		return &model.ApprovalRequest{ID: id, CreatedAt: row.CreatedAt}, nil
	case db.DecisionKindAgentQuestion:
		return &model.AgentQuestion{ID: id, CreatedAt: row.CreatedAt, Question: "(Phase 3)"}, nil
	case db.DecisionKindPromotionProposal:
		// Phase 8: from/to band + frozen evidence come from the row payload.
		from, to, evidence := parsePromotionPayload(row.Payload)
		return &model.PromotionProposal{
			ID:        id,
			CreatedAt: row.CreatedAt,
			FromLevel: from,
			ToLevel:   to,
			Evidence:  evidence,
		}, nil
	case db.DecisionKindFeedbackRequest:
		return &model.FeedbackRequest{
			ID:            id,
			CreatedAt:     row.CreatedAt,
			DraftGuidance: parseDraftGuidance(row.Payload),
		}, nil
	}
	return nil, fmt.Errorf("unknown decision kind: %s", row.Kind)
}

// parsePromotionPayload extracts the from/to AutonomyLevel bands and the frozen
// evidence map from a promotion_proposal pending_decisions.payload. Missing /
// malformed fields degrade to NONE + empty evidence (the proposal still renders).
func parsePromotionPayload(payload []byte) (from, to model.AutonomyLevel, evidence map[string]any) {
	from, to, evidence = model.AutonomyLevelNone, model.AutonomyLevelNone, map[string]any{}
	if len(payload) == 0 {
		return from, to, evidence
	}
	var p struct {
		FromLevel string         `json:"from_level"`
		ToLevel   string         `json:"to_level"`
		Evidence  map[string]any `json:"evidence"`
	}
	if err := json.Unmarshal(payload, &p); err != nil {
		return from, to, evidence
	}
	if p.FromLevel != "" {
		from = mapRung(p.FromLevel)
	}
	if p.ToLevel != "" {
		to = mapRung(p.ToLevel)
	}
	if p.Evidence != nil {
		evidence = p.Evidence
	}
	return from, to, evidence
}

// streamInboxEvents pumps the dispatcher channel into the resolver-returned
// channel until ctx is cancelled. Each envelope is refetched + assembled
// before being emitted.
func (r *Resolver) streamInboxEvents(ctx context.Context, sub *realtime.Subscriber, out chan<- model.InboxItem, dereg func()) {
	defer func() {
		dereg()
		close(out)
	}()
	for {
		select {
		case <-ctx.Done():
			return
		case env, ok := <-sub.Out:
			if !ok {
				return
			}
			item, err := r.loadInboxItemForEnvelope(ctx, env)
			if err != nil || item == nil {
				continue
			}
			select {
			case out <- item:
			case <-ctx.Done():
				return
			}
		}
	}
}

func (r *Resolver) streamTaskEvents(ctx context.Context, sub *realtime.Subscriber, out chan<- *model.Task, dereg func()) {
	defer func() {
		dereg()
		close(out)
	}()
	for {
		select {
		case <-ctx.Done():
			return
		case env, ok := <-sub.Out:
			if !ok {
				return
			}
			task, err := r.loadTaskForEnvelope(ctx, env)
			if err != nil || task == nil {
				continue
			}
			select {
			case out <- task:
			case <-ctx.Done():
				return
			}
		}
	}
}

func (r *Resolver) streamNotificationEvents(ctx context.Context, sub *realtime.Subscriber, out chan<- *model.Notification, dereg func()) {
	defer func() {
		dereg()
		close(out)
	}()
	for {
		select {
		case <-ctx.Done():
			return
		case _, ok := <-sub.Out:
			if !ok {
				return
			}
			// Phase 2 emits no real notifications; the channel stays
			// open so the WS subscription itself is healthy.
		}
	}
}

func (r *Resolver) loadInboxItemForEnvelope(ctx context.Context, env realtime.EventEnvelope) (model.InboxItem, error) {
	id, perr := uuid.Parse(env.ID)
	if perr != nil {
		return nil, perr
	}
	switch env.Topic {
	case "assignment":
		row, err := r.Queries.GetAgentAssignmentByID(ctx, id)
		if err != nil {
			return nil, err
		}
		a, err := mapAssignment(&row)
		if err != nil {
			return nil, err
		}
		if a == nil {
			return nil, nil
		}
		return *a, nil
	case "decision":
		row, err := r.Queries.GetPendingDecisionByID(ctx, id)
		if err != nil {
			return nil, err
		}
		pd, err := mapPendingDecisionRow(&row)
		if err != nil {
			return nil, err
		}
		return pendingDecisionToInboxItem(pd)
	}
	return nil, nil
}

func (r *Resolver) loadTaskForEnvelope(ctx context.Context, env realtime.EventEnvelope) (*model.Task, error) {
	id, perr := uuid.Parse(env.ID)
	if perr != nil {
		return nil, perr
	}
	var taskID uuid.UUID
	switch env.Topic {
	case "task":
		taskID = id
	case "assignment":
		row, err := r.Queries.GetAgentAssignmentByID(ctx, id)
		if err != nil {
			return nil, err
		}
		taskID = row.TaskID
	case "decision":
		row, err := r.Queries.GetPendingDecisionByID(ctx, id)
		if err != nil {
			return nil, err
		}
		taskID = row.TaskID
	default:
		return nil, nil
	}
	t, err := r.Queries.GetTask(ctx, taskID)
	if err != nil {
		return nil, err
	}
	return mapTask(&t)
}

// silence the unused auth import in the rare case nothing in this file
// reads it after future refactors.
var _ = auth.ErrUnauthorized
