package embedding_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

// insertEmbeddingVersion seeds an embedding_versions row directly (for store
// unit tests that don't run the full reindex workflow).
func insertActiveVersion(t *testing.T, q *db.Queries, version int, slot string, dim int) {
	t.Helper()
	ctx := context.Background()
	_, err := q.InsertEmbeddingVersion(ctx, db.InsertEmbeddingVersionParams{
		Version: int32(version), Slot: slot, Provider: "stub", Model: "m", Dimension: int32(dim), ConfigHash: "h",
	})
	require.NoError(t, err)
	require.NoError(t, q.ActivateEmbeddingVersion(ctx, int32(version)))
}

func TestStore_ActiveSlotDim(t *testing.T) {
	store, ctx := newStore(t)

	// No active version yet ⇒ ok=false, no error (caller falls back).
	_, _, ok, err := store.ActiveSlotDim(ctx)
	require.NoError(t, err)
	require.False(t, ok)

	insertActiveVersion(t, store.Queries(), 1, embedding.SlotGreen, 384)
	slot, dim, ok, err := store.ActiveSlotDim(ctx)
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, embedding.SlotGreen, slot)
	require.Equal(t, 384, dim)
}

func TestStore_ContentHash(t *testing.T) {
	store, ctx := newStore(t)
	const src = "doc"
	id := uuid.New()

	// Absent row ⇒ ok=false.
	_, ok, err := store.ContentHash(ctx, src, id)
	require.NoError(t, err)
	require.False(t, ok)

	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, id, "hello", embedding.HashText("hello"), []float32{1, 2}))
	h, ok, err := store.ContentHash(ctx, src, id)
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, embedding.HashText("hello"), h)
}

func TestStore_ClearSlot(t *testing.T) {
	store, ctx := newStore(t)
	const src = "doc"
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, uuid.New(), "a", "h", []float32{1, 0}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, src, uuid.New(), "b", "h", []float32{0, 1}))

	cnt, err := store.CountEmbedded(ctx, embedding.SlotBlue, src)
	require.NoError(t, err)
	require.EqualValues(t, 2, cnt)

	require.NoError(t, store.ClearSlot(ctx, embedding.SlotBlue))
	cnt, err = store.CountEmbedded(ctx, embedding.SlotBlue, src)
	require.NoError(t, err)
	require.EqualValues(t, 0, cnt)

	require.Error(t, store.ClearSlot(ctx, "bogus"))
}

// TopK must isolate by source_type and exclude rows whose slot vector is NULL.
func TestStore_TopK_IsolationAndNullExclusion(t *testing.T) {
	store, ctx := newStore(t)

	docID := uuid.New()
	otherID := uuid.New()
	nullID := uuid.New()
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, "doc", docID, "d", "h", []float32{1, 0, 0}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, "other", otherID, "o", "h", []float32{1, 0, 0}))
	// A row embedded only in green ⇒ its blue column is NULL.
	require.NoError(t, store.Upsert(ctx, embedding.SlotGreen, "doc", nullID, "n", "h", []float32{1, 0, 0}))
	require.NoError(t, store.BuildSlotIndex(ctx, embedding.SlotBlue, 3))

	got, err := store.TopK(ctx, embedding.SlotBlue, 3, "doc", []float32{1, 0, 0}, 10)
	require.NoError(t, err)
	require.Len(t, got, 1, "only the doc row with a non-NULL blue vector")
	require.Equal(t, docID, got[0].ID)

	// k limit is honoured.
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, "doc", uuid.New(), "d2", "h", []float32{0, 1, 0}))
	require.NoError(t, store.Upsert(ctx, embedding.SlotBlue, "doc", uuid.New(), "d3", "h", []float32{0, 0, 1}))
	limited, err := store.TopK(ctx, embedding.SlotBlue, 3, "doc", []float32{1, 0, 0}, 2)
	require.NoError(t, err)
	require.Len(t, limited, 2)
}
