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
	"math"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Item is the discriminated reference returned by List / ListFeed. Concrete
// entities are loaded by Assemble.
type Item struct {
	Kind      string // "pending_decision" | "agent_assignment" | "task"
	ID        uuid.UUID
	TaskID    uuid.UUID
	CreatedAt time.Time
	// Score is the blended urgency the feed is ranked by (ListFeed only; zero
	// for the legacy chronological List path).
	Score float64
	// MessageType is the fine-grained discriminator from the first-class
	// inbox_messages row (ListFeed only; empty for the legacy List path).
	MessageType string
	// ReadAt / DismissedAt are the per-message state from inbox_messages
	// (ListFeed only; nil when unset or on the legacy List path).
	ReadAt      *time.Time
	DismissedAt *time.Time
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

// ----- Ranked feed (ListFeed) ------------------------------------------

// feedCursor is the opaque pagination handle for the ranked feed. It carries
// the PINNED clock so every page of one scroll session ranks against a single
// fixed `now`, keeping the (score, id) keyset stable. Score is always a real,
// finite value here — the first-page +Inf sentinel is in-memory only and never
// serialized (encoding/json cannot marshal Inf).
type feedCursor struct {
	Now   time.Time `json:"now"`
	Score float64   `json:"score"`
	ID    uuid.UUID `json:"id"`
}

// encodeFeedCursor turns the pinned clock + the last row's (score, id) into the
// opaque wire value. Score must be finite.
func encodeFeedCursor(now time.Time, score float64, id uuid.UUID) string {
	b, _ := json.Marshal(feedCursor{Now: now, Score: score, ID: id})
	return base64.RawURLEncoding.EncodeToString(b)
}

// decodeFeedCursor reverses encodeFeedCursor. An empty cursor opens a fresh
// session: the passed fallbackNow becomes the pinned clock and the keyset
// starts above every real row (+Inf score, max id).
func decodeFeedCursor(s string, fallbackNow time.Time) (now time.Time, score float64, id uuid.UUID, err error) {
	if s == "" {
		return fallbackNow.UTC(), math.Inf(1), uuid.Max, nil
	}
	raw, derr := base64.RawURLEncoding.DecodeString(s)
	if derr != nil {
		return time.Time{}, 0, uuid.Nil, fmt.Errorf("decode feed cursor: %w", derr)
	}
	var p feedCursor
	if uerr := json.Unmarshal(raw, &p); uerr != nil {
		return time.Time{}, 0, uuid.Nil, fmt.Errorf("unmarshal feed cursor: %w", uerr)
	}
	return p.Now, p.Score, p.ID, nil
}

// ListFeed fetches the next page of the viewer-scoped ranked action feed. On
// the first page (empty cursor) `now` is pinned as the ranking clock and echoed
// into the next cursor; later pages reuse the pinned clock decoded from the
// cursor (the passed `now` is then ignored). The next-page cursor is built from
// the SQL-returned score of the last row — never recomputed — so the keyset
// comparison is bit-identical. Returns "" for the last page.
func ListFeed(ctx context.Context, q *db.Queries, viewerGlobalURI, cursor string, limit int32, now time.Time) ([]Item, string, error) {
	if limit <= 0 {
		limit = DefaultLimit
	}
	if limit > MaxLimit {
		limit = MaxLimit
	}
	pinnedNow, curScore, curID, err := decodeFeedCursor(cursor, now)
	if err != nil {
		return nil, "", err
	}
	rows, err := q.ListInboxFeed(ctx, db.ListInboxFeedParams{
		Viewer:      viewerGlobalURI,
		Now:         pinnedNow,
		CursorScore: curScore,
		CursorID:    curID,
		PageLimit:   limit,
	})
	if err != nil {
		return nil, "", fmt.Errorf("list inbox feed: %w", err)
	}
	items := make([]Item, 0, len(rows))
	for _, r := range rows {
		items = append(items, Item{
			Kind:        r.Kind,
			ID:          r.ID,
			TaskID:      r.TaskID,
			CreatedAt:   r.CreatedAt,
			Score:       r.Score,
			MessageType: r.MessageType,
			ReadAt:      tsPtr(r.ReadAt),
			DismissedAt: tsPtr(r.DismissedAt),
		})
	}
	next := ""
	if int32(len(items)) == limit && len(items) > 0 {
		last := items[len(items)-1]
		next = encodeFeedCursor(pinnedNow, last.Score, last.ID)
	}
	return items, next, nil
}

// BlendedUrgency computes the same blended score as the ListInboxFeed SQL
// expression. It exists so the inboxEntryArrived subscription can stamp an
// approximate urgency on a live-arrived item without a round-trip through the
// ranked query. Keep the weights here in lockstep with the CASE arithmetic in
// queries/inbox.sql (a divergence test guards against drift). `priority` is the
// lowercase task_priority value; `stakes` is intake stakes_hint (0 if none).
func BlendedUrgency(priority string, dueAt *time.Time, stakes float64, createdAt, now time.Time) float64 {
	var s float64
	switch priority {
	case "urgent":
		s += 400
	case "high":
		s += 300
	case "low":
		s += 100
	default: // "normal" and anything unexpected
		s += 200
	}
	if dueAt != nil {
		switch {
		case dueAt.Before(now):
			s += 250
		case dueAt.Before(now.Add(24 * time.Hour)):
			s += 150
		case dueAt.Before(now.Add(7 * 24 * time.Hour)):
			s += 75
		}
	}
	s += stakes * 100
	age := now.Sub(createdAt).Hours()
	if age < 0 {
		age = 0
	}
	if age > 48 {
		age = 48
	}
	s += age
	return s
}

// tsPtr maps a pgtype.Timestamptz (read_at / dismissed_at from ListInboxFeed) to
// a *time.Time — nil when SQL NULL — so the resolver emits a null GraphQL field
// for "unread" / "not dismissed".
func tsPtr(ts pgtype.Timestamptz) *time.Time {
	if !ts.Valid {
		return nil
	}
	t := ts.Time
	return &t
}

// ErrNotFound is returned by Assemble when a row referenced by an Item is
// gone (deleted between List and Assemble — a race).
var ErrNotFound = errors.New("inbox: item not found")
