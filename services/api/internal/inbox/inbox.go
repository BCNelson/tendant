// Package inbox builds the unified `Query.inbox` surface — keyset-paginated
// union of open pending_decisions + open agent_assignments routed to the
// viewer. Visibility filtering happens at the SQL layer (FR-031 / SC-006).
package inbox

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Item is the discriminated reference returned by List. Concrete entities are
// loaded by Assemble.
type Item struct {
	Kind      string // "pending_decision" | "agent_assignment"
	ID        uuid.UUID
	TaskID    uuid.UUID
	CreatedAt time.Time
}

// MaxLimit caps the per-page size at the value spec'd in data-model § rules.
const MaxLimit = 50

// DefaultLimit is the per-page size when first is unset.
const DefaultLimit = 25

// Cursor is the opaque pagination handle on the wire. We encode it as the
// base64-RawURL of the JSON {ts, id} pair.
type cursorPayload struct {
	TS time.Time `json:"ts"`
	ID uuid.UUID `json:"id"`
}

// EncodeCursor turns a (createdAt, id) pair into the opaque wire value.
func EncodeCursor(ts time.Time, id uuid.UUID) string {
	b, _ := json.Marshal(cursorPayload{TS: ts, ID: id})
	return base64.RawURLEncoding.EncodeToString(b)
}

// DecodeCursor reverses EncodeCursor. Returns the zero value + nil if cursor
// is empty (signals "from the start").
func DecodeCursor(s string) (time.Time, uuid.UUID, error) {
	if s == "" {
		return maxTimestamp(), uuid.Max, nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(s)
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("decode cursor: %w", err)
	}
	var p cursorPayload
	if err := json.Unmarshal(raw, &p); err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("unmarshal cursor: %w", err)
	}
	return p.TS, p.ID, nil
}

// maxTimestamp is the sentinel "from the start" cursor — Postgres's max
// timestamptz comfortably exceeds any real value.
func maxTimestamp() time.Time {
	return time.Date(9999, 12, 31, 0, 0, 0, 0, time.UTC)
}

// List fetches the next page of viewer-scoped inbox items. The next-page
// cursor is the (createdAt, id) of the last returned item, or "" if the page
// is the last page.
func List(ctx context.Context, q *db.Queries, viewerGlobalURI string, cursor string, limit int32) ([]Item, string, error) {
	if limit <= 0 {
		limit = DefaultLimit
	}
	if limit > MaxLimit {
		limit = MaxLimit
	}
	curTS, curID, err := DecodeCursor(cursor)
	if err != nil {
		return nil, "", err
	}
	rows, err := q.ListInbox(ctx, db.ListInboxParams{
		ToPrincipal: &viewerGlobalURI,
		Column2:     curTS,
		Column3:     curID,
		Limit:       limit,
	})
	if err != nil {
		return nil, "", fmt.Errorf("list inbox: %w", err)
	}
	items := make([]Item, 0, len(rows))
	for _, r := range rows {
		items = append(items, Item{
			Kind:      r.Kind,
			ID:        r.ID,
			TaskID:    r.TaskID,
			CreatedAt: r.CreatedAt,
		})
	}
	next := ""
	if int32(len(items)) == limit && len(items) > 0 {
		last := items[len(items)-1]
		next = EncodeCursor(last.CreatedAt, last.ID)
	}
	return items, next, nil
}

// ErrNotFound is returned by Assemble when a row referenced by an Item is
// gone (deleted between List and Assemble — a race).
var ErrNotFound = errors.New("inbox: item not found")
