package inbox

import (
	"context"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// AssembledItem is the kind-discriminated assembled row returned by Assemble.
// The resolver consults Kind to pick the right gqlgen union member.
//
// Exactly one of {PendingDecision, AgentAssignment} is set per row.
type AssembledItem struct {
	Kind            string
	PendingDecision *db.PendingDecision
	AgentAssignment *db.AgentAssignment
}

// Assemble loads typed rows for each Item. Items whose underlying row has
// vanished (deleted between List and Assemble) are silently skipped so the
// page never includes a half-resolved stub.
func Assemble(ctx context.Context, q *db.Queries, items []Item) ([]AssembledItem, error) {
	out := make([]AssembledItem, 0, len(items))
	for _, it := range items {
		switch it.Kind {
		case "pending_decision":
			row, err := q.GetPendingDecisionByID(ctx, it.ID)
			if err != nil {
				continue
			}
			r := row
			out = append(out, AssembledItem{Kind: it.Kind, PendingDecision: &r})
		case "agent_assignment":
			row, err := q.GetAgentAssignmentByID(ctx, it.ID)
			if err != nil {
				continue
			}
			r := row
			out = append(out, AssembledItem{Kind: it.Kind, AgentAssignment: &r})
		default:
			return nil, fmt.Errorf("inbox.Assemble: unknown kind %q", it.Kind)
		}
	}
	return out, nil
}
