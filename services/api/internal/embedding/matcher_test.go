package embedding_test

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/embedding"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// keywordEmbedder maps text to a vector by keyword presence (+ a constant bias
// dimension so no vector is all-zero, keeping cosine distance well-defined). It
// makes nearest-neighbour results semantically meaningful and deterministic.
type keywordEmbedder struct{}

var kwKeywords = []string{"email", "code", "meeting"}

func (keywordEmbedder) Provider() string { return "stub" }
func (keywordEmbedder) Model() string    { return "kw" }
func (keywordEmbedder) Dimension() int   { return len(kwKeywords) + 1 }
func (keywordEmbedder) Embed(_ context.Context, texts []string) ([][]float32, error) {
	out := make([][]float32, len(texts))
	for i, t := range texts {
		lt := strings.ToLower(t)
		v := make([]float32, len(kwKeywords)+1)
		for j, kw := range kwKeywords {
			if strings.Contains(lt, kw) {
				v[j] = 1
			}
		}
		v[len(kwKeywords)] = 0.1 // bias
		out[i] = v
	}
	return out, nil
}

type errEmbedder struct{}

func (errEmbedder) Provider() string { return "stub" }
func (errEmbedder) Model() string    { return "err" }
func (errEmbedder) Dimension() int   { return 4 }
func (errEmbedder) Embed(context.Context, []string) ([][]float32, error) {
	return nil, errors.New("embed down")
}

func TestNewMatcher_NilCases(t *testing.T) {
	store, _ := newStore(t)
	require.Nil(t, embedding.NewMatcher(store, nil, store.Queries()), "nil embedder ⇒ nil matcher")
	require.Nil(t, embedding.NewMatcher(nil, keywordEmbedder{}, store.Queries()), "nil store ⇒ nil matcher")
}

func TestMatcher_NilReceiverIsSafe(t *testing.T) {
	var m *embedding.Matcher // a disabled subsystem yields nil
	got, err := m.TopCategories(context.Background(), "anything", 5)
	require.NoError(t, err)
	require.Nil(t, got)
}

func TestMatcher_NoActiveVersionFallsBack(t *testing.T) {
	store, ctx := newStore(t)
	m := embedding.NewMatcher(store, keywordEmbedder{}, store.Queries())
	require.NotNil(t, m)
	got, err := m.TopCategories(ctx, "reply to the email", 5)
	require.NoError(t, err)
	require.Nil(t, got, "no active version ⇒ (nil,nil) so triage uses the full taxonomy")
}

func TestMatcher_EmbedErrorPropagates(t *testing.T) {
	store, ctx := newStore(t)
	insertActiveVersion(t, store.Queries(), 1, embedding.SlotBlue, 4)
	m := embedding.NewMatcher(store, errEmbedder{}, store.Queries())
	_, err := m.TopCategories(ctx, "x", 5)
	require.Error(t, err)
}

// TestMatcher_DeletedCategorySkipped: a matched embedding row whose category no
// longer exists in task_categories is skipped (not returned).
func TestMatcher_DeletedCategorySkipped(t *testing.T) {
	store, ctx := newStore(t)
	insertActiveVersion(t, store.Queries(), 1, embedding.SlotBlue, 4)
	// An orphan embedding (no matching task_categories row) nearest to the query.
	orphan := uuid.New()
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, embedding.SourceTypeCategory, orphan, "email", "h", []float32{1, 0, 0, 0.1}))
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 4))

	m := embedding.NewMatcher(store, keywordEmbedder{}, store.Queries())
	got, err := m.TopCategories(ctx, "reply to the email", 5)
	require.NoError(t, err)
	require.Empty(t, got, "orphan category id skipped")
}

func seedCategory(t *testing.T, q *db.Queries, key, label, desc string) uuid.UUID {
	t.Helper()
	row, err := q.InsertTaskCategory(context.Background(), db.InsertTaskCategoryParams{
		Key:           key,
		ParentID:      pgtype.UUID{},
		Label:         label,
		Description:   &desc,
		StageBindings: []byte(`{}`),
		Origin:        db.ConfigOriginCore,
		Version:       1,
	})
	require.NoError(t, err)
	return row.ID
}

// TestMatcher_EndToEnd is the headline feature path: seed real categories, run
// the reindex through the production categorySource + an embedder, then assert
// TopCategories returns the semantically-correct category for a task.
func TestMatcher_EndToEnd(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	store := embedding.NewStore(pool)
	q := store.Queries()

	seedCategory(t, q, "communication/email", "Email", "Email correspondence and replies")
	seedCategory(t, q, "engineering/code", "Code", "Software code changes and reviews")
	seedCategory(t, q, "calendar/meeting", "Meeting", "Meetings and scheduling")

	dctx, err := durable.Init(ctx, pool, "matchere2e-"+uuid.NewString())
	require.NoError(t, err)
	sources := &embedding.SourceRegistry{}
	sources.Register(embedding.NewCategorySource(q)) // the production source
	embedding.RegisterReindex(dctx, store, keywordEmbedder{}, sources)
	require.NoError(t, durable.Launch(dctx))
	t.Cleanup(func() { durable.Shutdown(dctx, 5*time.Second) })

	cfg := embedding.Config{Provider: "stub", Model: "kw", Dimension: 4}
	require.NoError(t, embedding.EnsureActiveVersion(ctx, dctx, store, cfg))
	waitActive(t, q, embedding.ConfigHash(cfg))

	m := embedding.NewMatcher(store, keywordEmbedder{}, q)
	got, err := m.TopCategories(ctx, "please reply to the email from bob", 3)
	require.NoError(t, err)
	require.NotEmpty(t, got)
	require.Equal(t, "communication/email", got[0].Key, "the email task matches the email category")
	require.Equal(t, "Email", got[0].Label)

	// All three categories were embedded.
	cnt, err := store.CountEmbedded(ctx, embedding.SlotBlue, embedding.SourceTypeCategory)
	require.NoError(t, err)
	require.EqualValues(t, 3, cnt)
}
