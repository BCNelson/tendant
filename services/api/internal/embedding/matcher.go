package embedding

import (
	"context"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// CategoryMatch is one nearest category for triage (key + label to inject).
type CategoryMatch struct {
	Key      string
	Label    string
	Distance float64
}

// Matcher embeds a task's text and returns the nearest task categories from the
// active embedding version. It is the implementation behind the agent layer's
// CategoryMatcher seam (adapted in cmd/tendant). A nil Matcher, no active
// version, or any embed error makes triage fall back to the full taxonomy.
type Matcher struct {
	store    *Store
	embedder Embedder
	q        *db.Queries
}

// NewMatcher builds a Matcher. Returns nil when embedder is nil (subsystem off).
func NewMatcher(store *Store, embedder Embedder, q *db.Queries) *Matcher {
	if embedder == nil || store == nil {
		return nil
	}
	return &Matcher{store: store, embedder: embedder, q: q}
}

// TopCategories returns up to k nearest categories to taskText. It returns
// (nil, nil) — not an error — when there is no active version yet, so the caller
// degrades to the full-taxonomy fallback rather than failing.
func (m *Matcher) TopCategories(ctx context.Context, taskText string, k int) ([]CategoryMatch, error) {
	if m == nil || k <= 0 {
		return nil, nil
	}
	slot, dim, ok, err := m.store.ActiveSlotDim(ctx)
	if err != nil || !ok {
		return nil, err
	}
	vecs, err := m.embedder.Embed(ctx, []string{taskText})
	if err != nil {
		return nil, err
	}
	if len(vecs) == 0 {
		return nil, nil
	}
	matches, err := m.store.TopK(ctx, slot, dim, SourceTypeCategory, vecs[0], k)
	if err != nil {
		return nil, err
	}
	if len(matches) == 0 {
		return nil, nil
	}
	// Map category id → key/label (small taxonomy; one list query).
	cats, err := m.q.ListTaskCategories(ctx)
	if err != nil {
		return nil, err
	}
	byID := make(map[uuid.UUID]db.TaskCategory, len(cats))
	for _, c := range cats {
		byID[c.ID] = c
	}
	out := make([]CategoryMatch, 0, len(matches))
	for _, mt := range matches {
		c, ok := byID[mt.ID]
		if !ok {
			continue // category deleted since last reindex; skip
		}
		out = append(out, CategoryMatch{Key: c.Key, Label: c.Label, Distance: mt.Distance})
	}
	return out, nil
}
