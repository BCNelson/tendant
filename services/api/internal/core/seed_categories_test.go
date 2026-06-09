package core

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TestDefaultCategoryDefs_ParseAndShape guards that the embedded
// default_categories/ files all parse, carry a valid stage in every binding, and
// resolve their parent keys. A mistyped TOML key or an unknown binding stage is
// caught here without a DB.
func TestDefaultCategoryDefs_ParseAndShape(t *testing.T) {
	entries, err := categoryEntriesFor(nil) // nil ⇒ embedded defaults
	require.NoError(t, err)
	require.NotEmpty(t, entries)

	byKey := map[string]categoryEntry{}
	for _, e := range entries {
		require.NotEmpty(t, e.Key)
		require.NotEmpty(t, e.Label)
		require.Equal(t, db.ConfigOriginCore, e.Origin, "default categories are core-origin")
		require.True(t, len(e.StageBindings) > 0)
		byKey[e.Key] = e
	}

	// communication/email derives parent "communication" from its key prefix.
	email, ok := byKey["communication/email"]
	require.True(t, ok)
	require.Equal(t, "communication", email.ParentKey)

	// A root category has no parent.
	require.Equal(t, "", byKey["communication"].ParentKey)
}

// TestReconcileCategoryCatalog_SeedsTreeIdempotently proves the boot seed inserts
// the default tree (with parent linkage resolved) and that a second run is a
// no-op (no version churn).
func TestReconcileCategoryCatalog_SeedsTreeIdempotently(t *testing.T) {
	q, ctx := setupCatalogDB(t)

	require.NoError(t, SeedCategoryCatalog(ctx, q))

	rows, err := q.ListTaskCategories(ctx)
	require.NoError(t, err)
	require.NotEmpty(t, rows)

	byKey := map[string]db.TaskCategory{}
	byID := map[uuid.UUID]db.TaskCategory{}
	for _, r := range rows {
		byKey[r.Key] = r
		byID[r.ID] = r
		require.Equal(t, int32(1), r.Version, "first seed inserts at version 1")
	}

	// communication/email's parent_id resolves to the communication row.
	email, ok := byKey["communication/email"]
	require.True(t, ok)
	require.True(t, email.ParentID.Valid, "child has a parent")
	parent := byID[uuid.UUID(email.ParentID.Bytes)]
	require.Equal(t, "communication", parent.Key)

	// Second seed is a no-op: core rows already match the embedded default, so no
	// version bump.
	require.NoError(t, SeedCategoryCatalog(ctx, q))
	after, err := q.GetTaskCategoryByKey(ctx, "communication/email")
	require.NoError(t, err)
	require.Equal(t, int32(1), after.Version, "idempotent re-seed does not bump version")
}
