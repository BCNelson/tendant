package graph

import (
	"context"
	"encoding/json"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/google/uuid"
)

// buildActivity maps a task's audit DAG into the GraphQL ActivityEvent timeline.
//
// ListAuditForTask returns the rows chronologically (at ASC, id ASC) — the same
// order the UI renders. Each row's typed payload is surfaced as `detail` (an
// opaque JSON map) so the client can format per-kind without the schema having
// to enumerate every payload shape. `inReplyTo` carries the in_reply_to spine so
// a tool-call chain (composed → verdict → decision → dispatched → outcome) can
// be threaded under its parent.
//
// The full payload is exposed to the authenticated viewer (the owner), who
// already sees frozen tool payloads in the approval flow; there is no separate
// redaction layer.
func buildActivity(ctx context.Context, q *db.Queries, taskID uuid.UUID) ([]*model.ActivityEvent, error) {
	rows, err := q.ListAuditForTask(ctx, taskID)
	if err != nil {
		return nil, err
	}
	out := make([]*model.ActivityEvent, 0, len(rows))
	for i := range rows {
		m := &rows[i]
		var detail map[string]any
		if len(m.Payload) > 0 {
			// A malformed payload shouldn't drop the event from the timeline.
			_ = json.Unmarshal(m.Payload, &detail)
		}
		ev := &model.ActivityEvent{
			ID:     m.ID.String(),
			Kind:   m.Kind,
			At:     m.At,
			Actor:  m.FromPrincipal,
			Detail: detail,
		}
		if m.InReplyTo.Valid {
			parent := uuid.UUID(m.InReplyTo.Bytes).String()
			ev.InReplyTo = &parent
		}
		out = append(out, ev)
	}
	return out, nil
}
