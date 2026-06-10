package embedding

import (
	"context"
	"strings"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// SourceTypeCategory is the source_type discriminator for task categories — the
// first embeddable source. New source types (tasks, messages) add a Source impl
// + a registry entry and need zero changes to the Store or reindex job.
const SourceTypeCategory = "task_category"

// Item is one embeddable row: a stable id plus the text to embed.
type Item struct {
	ID   uuid.UUID
	Text string
}

// Source enumerates the rows of one kind of data to embed.
type Source interface {
	// Type is the source_type discriminator stored on each embeddings row.
	Type() string
	// List returns every current row that should have an embedding.
	List(ctx context.Context) ([]Item, error)
}

// SourceRegistry holds the Sources the reindex job iterates.
type SourceRegistry struct {
	sources []Source
}

// Register adds a Source. Not safe for concurrent registration; call at boot.
func (r *SourceRegistry) Register(s Source) { r.sources = append(r.sources, s) }

// Sources returns the registered Sources.
func (r *SourceRegistry) Sources() []Source { return r.sources }

// categorySource lists task categories as embeddable items. The embedded text
// is "key — label. description" — rich enough for good semantic matching.
type categorySource struct{ q *db.Queries }

// NewCategorySource builds the task-category Source.
func NewCategorySource(q *db.Queries) Source { return categorySource{q: q} }

func (c categorySource) Type() string { return SourceTypeCategory }

func (c categorySource) List(ctx context.Context) ([]Item, error) {
	cats, err := c.q.ListTaskCategories(ctx)
	if err != nil {
		return nil, err
	}
	items := make([]Item, 0, len(cats))
	for _, cat := range cats {
		items = append(items, Item{ID: cat.ID, Text: CategoryText(cat.Key, cat.Label, cat.Description)})
	}
	return items, nil
}

// CategoryText renders the text embedded for a category (also used by tests).
func CategoryText(key, label string, description *string) string {
	var b strings.Builder
	b.WriteString(key)
	if label != "" {
		b.WriteString(" — ")
		b.WriteString(label)
	}
	if description != nil && *description != "" {
		b.WriteString(". ")
		b.WriteString(*description)
	}
	return b.String()
}
