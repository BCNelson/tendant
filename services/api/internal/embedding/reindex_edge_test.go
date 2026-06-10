package embedding_test

import (
	"context"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

// Once a config is active, re-requesting it is a no-op (no new version).
func TestEnsureActiveVersion_AlreadyActiveNoOp(t *testing.T) {
	env := newReindexEnv(t, 4, threeItems())
	ctx := context.Background()
	cfg := embedding.Config{Provider: "stub", Model: "m1", Dimension: 4}

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfg))
	waitActive(t, env.q, embedding.ConfigHash(cfg))

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfg))
	max, err := env.q.MaxEmbeddingVersion(ctx)
	require.NoError(t, err)
	require.EqualValues(t, 1, max, "re-requesting the active config creates no new version")
}

// Requesting the currently-active config while another build is in flight
// cancels that build and keeps the active version — last-writer-wins resolves
// back to A regardless of timing.
func TestEnsureActiveVersion_FlipBackWhileBuilding(t *testing.T) {
	env := newReindexEnv(t, 4, threeItems())
	ctx := context.Background()
	cfgA := embedding.Config{Provider: "stub", Model: "mA", Dimension: 4}
	cfgB := embedding.Config{Provider: "stub", Model: "mB", Dimension: 4}

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgA))
	waitActive(t, env.q, embedding.ConfigHash(cfgA))

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgB)) // start building B
	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgA)) // flip back to A

	v := waitActive(t, env.q, embedding.ConfigHash(cfgA))
	require.Equal(t, embedding.ConfigHash(cfgA), v.ConfigHash)
}

// Rapid A→B→C records supersession (proving the abandon path ran) and settles to
// exactly one active (C) with no lingering build.
func TestReindex_SupersededRecorded(t *testing.T) {
	env := newReindexEnv(t, 4, threeItems())
	ctx := context.Background()
	for _, model := range []string{"mA", "mB", "mC"} {
		require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, embedding.Config{Provider: "stub", Model: model, Dimension: 4}))
	}
	waitActive(t, env.q, embedding.ConfigHash(embedding.Config{Provider: "stub", Model: "mC", Dimension: 4}))

	// Wait for the build to drain.
	deadline := time.Now().Add(5 * time.Second)
	for time.Now().Before(deadline) {
		if _, err := env.q.GetBuildingEmbeddingVersion(ctx); err == pgx.ErrNoRows {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}

	counts := statusCounts(t, env.store.Pool())
	require.Equal(t, 1, counts["active"], "exactly one active")
	require.Equal(t, 0, counts["building"], "no lingering build")
	require.GreaterOrEqual(t, counts["superseded"], 1, "at least one superseded build (B)")
}

func statusCounts(t *testing.T, pool interface {
	Query(context.Context, string, ...any) (pgx.Rows, error)
}) map[string]int {
	t.Helper()
	rows, err := pool.Query(context.Background(), "SELECT status, count(*) FROM embedding_versions GROUP BY status")
	require.NoError(t, err)
	defer rows.Close()
	out := map[string]int{}
	for rows.Next() {
		var s string
		var n int
		require.NoError(t, rows.Scan(&s, &n))
		out[s] = n
	}
	require.NoError(t, rows.Err())
	return out
}
