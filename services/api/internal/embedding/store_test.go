package embedding_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/embedding"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func newStore(t *testing.T) (*embedding.Store, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	return embedding.NewStore(pool), ctx
}

// TestStore_UpsertTopK proves the round-trip through the unconstrained vector
// column + the expression index: nearest-neighbour ordering is correct, the
// dynamic index drops/rebuilds, content_hash is recorded, and the count tracks.
func TestStore_UpsertTopK(t *testing.T) {
	store, ctx := newStore(t)
	const src = "doc"

	id1, id2, id3 := uuid.New(), uuid.New(), uuid.New()
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, id1, "x-axis", embedding.HashText("x-axis"), []float32{1, 0, 0}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, id2, "y-axis", embedding.HashText("y-axis"), []float32{0, 1, 0}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, id3, "z-axis", embedding.HashText("z-axis"), []float32{0, 0, 1}))

	// Build the expression index at dim 3 (dynamic index lifecycle).
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 3))

	cnt, err := store.CountEmbedded(ctx, embedding.SlotBlue, src)
	require.NoError(t, err)
	require.EqualValues(t, 3, cnt)

	matches, err := store.TopK(ctx, embedding.SlotBlue, 3, src, []float32{0.9, 0.1, 0}, 2)
	require.NoError(t, err)
	require.Len(t, matches, 2)
	require.Equal(t, id1, matches[0].ID, "nearest to [0.9,0.1,0] is the x-axis vector")

	// content_hash recorded.
	h, ok, err := store.ContentHash(ctx, src, id1)
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, embedding.HashText("x-axis"), h)

	// Drop + rebuild the idle index is a no-op for correctness (seq scan still works).
	require.NoError(t, store.DropSlotIndex(ctx, embedding.SlotBlue))
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 3))
}

// TestStore_DifferentDimsCoexist proves the columns are size-free: blue can hold
// 3-dim vectors while green holds 4-dim, each with its own expression index.
func TestStore_DifferentDimsCoexist(t *testing.T) {
	store, ctx := newStore(t)
	const src = "doc"
	id := uuid.New()

	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, id, "t", embedding.HashText("t"), []float32{1, 2, 3}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotGreen, src, id, "t", embedding.HashText("t"), []float32{4, 5, 6, 7}))
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 3))
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotGreen, 4))

	b, err := store.TopK(ctx, embedding.SlotBlue, 3, src, []float32{1, 2, 3}, 1)
	require.NoError(t, err)
	require.Len(t, b, 1)
	g, err := store.TopK(ctx, embedding.SlotGreen, 4, src, []float32{4, 5, 6, 7}, 1)
	require.NoError(t, err)
	require.Len(t, g, 1)
}

func TestStore_SlotAndDimValidation(t *testing.T) {
	store, ctx := newStore(t)
	require.Error(t, store.Upsert(ctx, "purple", "doc", uuid.New(), "t", "h", []float32{1}))
	require.Error(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 0))
	_, err := store.TopK(ctx, embedding.SlotBlue, 99999, "doc", []float32{1}, 1)
	require.Error(t, err)
}
