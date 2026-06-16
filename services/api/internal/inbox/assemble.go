package inbox

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// AssembledItem is the kind-discriminated assembled row returned by Assemble.
// The resolver consults Kind to pick the right gqlgen union member.
//
// Exactly one of {PendingDecision, AgentAssignment, Task} is set per row.
// ID / CreatedAt / Score are carried from the source Item so the resolver can
// build the ranked InboxEntry envelope without re-deriving them.
type AssembledItem struct {
	Kind            string
	ID              uuid.UUID
	CreatedAt       time.Time
	Score           float64
	MessageType     string // fine-grained inbox_messages discriminator
	ReadAt          *time.Time
	DismissedAt     *time.Time
	PendingDecision *db.PendingDecision
	AgentAssignment *db.AgentAssignment
	Task            *db.Task // kind == "task" (ActionableTask)
}

// Assemble loads typed rows for each Item. Items whose underlying row has
// vanished (deleted between List and Assemble) are silently skipped so the
// page never includes a half-resolved stub.
func Assemble(ctx context.Context, q *db.Queries, items []Item) ([]AssembledItem, error) {
	out := make([]AssembledItem, 0, len(items))
	for _, it := range items {
		base := AssembledItem{
			Kind:        it.Kind,
			ID:          it.ID,
			CreatedAt:   it.CreatedAt,
			Score:       it.Score,
			MessageType: it.MessageType,
			ReadAt:      it.ReadAt,
			DismissedAt: it.DismissedAt,
		}
		switch it.Kind {
		case "pending_decision":
			row, err := q.GetPendingDecisionByID(ctx, it.ID)
			if err != nil {
				continue
			}
			r := row
			base.PendingDecision = &r
			out = append(out, base)
		case "agent_assignment":
			row, err := q.GetAgentAssignmentByID(ctx, it.ID)
			if err != nil {
				continue
			}
			r := row
			base.AgentAssignment = &r
			out = append(out, base)
		case "task":
			row, err := q.GetTask(ctx, it.ID)
			if err != nil {
				continue
			}
			r := row
			base.Task = &r
			out = append(out, base)
		default:
			return nil, fmt.Errorf("inbox.Assemble: unknown kind %q", it.Kind)
		}
	}
	return out, nil
}
