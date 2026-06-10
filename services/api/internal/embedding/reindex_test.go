package embedding_test

import (
	"context"
	"hash/fnv"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/embedding"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// stubEmbedder produces deterministic dim-D vectors from text (no network).
type stubEmbedder struct{ dim int }

func (s stubEmbedder) Provider() string { return "stub" }
func (s stubEmbedder) Model() string    { return "stub" }
func (s stubEmbedder) Dimension() int   { return s.dim }
func (s stubEmbedder) Embed(_ context.Context, texts []string) ([][]float32, error) {
	out := make([][]float32, len(texts))
	for i, t := range texts {
		h := fnv.New32a()
		_, _ = h.Write([]byte(t))
		seed := h.Sum32()
		v := make([]float32, s.dim)
		for j := range v {
			v[j] = float32((seed>>(j%16))&0xff) / 255.0
		}
		out[i] = v
	}
	return out, nil
}

// memorySource lists a fixed set of items.
type memorySource struct {
	typ   string
	items []embedding.Item
}

func (m memorySource) Type() string { return m.typ }
func (m memorySource) List(context.Context) ([]embedding.Item, error) {
	return m.items, nil
}

type reindexEnv struct {
	store *embedding.Store
	dctx  dbos.DBOSContext
	q     *db.Queries
}

func newReindexEnv(t *testing.T, dim int, items []embedding.Item) *reindexEnv {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	store := embedding.NewStore(pool)

	dctx, err := durable.Init(ctx, pool, "embtest-"+uuid.NewString())
	require.NoError(t, err)
	sources := &embedding.SourceRegistry{}
	sources.Register(memorySource{typ: "doc", items: items})
	embedding.RegisterReindex(dctx, store, stubEmbedder{dim: dim}, sources)
	require.NoError(t, durable.Launch(dctx))
	t.Cleanup(func() { durable.Shutdown(dctx, 5*time.Second) })

	return &reindexEnv{store: store, dctx: dctx, q: store.Queries()}
}

func threeItems() []embedding.Item {
	return []embedding.Item{
		{ID: uuid.New(), Text: "alpha"},
		{ID: uuid.New(), Text: "beta"},
		{ID: uuid.New(), Text: "gamma"},
	}
}

// waitActive polls until the active version has the wanted config_hash.
func waitActive(t *testing.T, q *db.Queries, wantHash string) db.EmbeddingVersion {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(8 * time.Second)
	for time.Now().Before(deadline) {
		v, err := q.GetActiveEmbeddingVersion(ctx)
		if err == nil && v.ConfigHash == wantHash {
			return v
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("no active version with hash %s within deadline", wantHash)
	return db.EmbeddingVersion{}
}

func TestReindex_FirstBuild(t *testing.T) {
	items := threeItems()
	env := newReindexEnv(t, 4, items)
	cfg := embedding.Config{Provider: "stub", Model: "m1", Dimension: 4}

	require.NoError(t, embedding.EnsureActiveVersion(context.Background(), env.dctx, env.store, cfg))

	v := waitActive(t, env.q, embedding.ConfigHash(cfg))
	require.Equal(t, embedding.SlotBlue, v.Slot, "first version lands on blue")
	require.EqualValues(t, 4, v.Dimension, "actual dimension recorded")

	cnt, err := env.store.CountEmbedded(context.Background(), v.Slot, "doc")
	require.NoError(t, err)
	require.EqualValues(t, len(items), cnt, "every item embedded (completion tracker)")
}

func TestReindex_Swap(t *testing.T) {
	items := threeItems()
	env := newReindexEnv(t, 4, items)

	cfgA := embedding.Config{Provider: "stub", Model: "m1", Dimension: 4}
	require.NoError(t, embedding.EnsureActiveVersion(context.Background(), env.dctx, env.store, cfgA))
	vA := waitActive(t, env.q, embedding.ConfigHash(cfgA))
	require.Equal(t, embedding.SlotBlue, vA.Slot)

	// Swap the model → new version on the green slot, blue cleared after flip.
	cfgB := embedding.Config{Provider: "stub", Model: "m2", Dimension: 4}
	require.NoError(t, embedding.EnsureActiveVersion(context.Background(), env.dctx, env.store, cfgB))
	vB := waitActive(t, env.q, embedding.ConfigHash(cfgB))
	require.Equal(t, embedding.SlotGreen, vB.Slot, "swap lands on the idle slot")

	ctx := context.Background()
	greenCnt, err := env.store.CountEmbedded(ctx, embedding.SlotGreen, "doc")
	require.NoError(t, err)
	require.EqualValues(t, len(items), greenCnt)
	blueCnt, err := env.store.CountEmbedded(ctx, embedding.SlotBlue, "doc")
	require.NoError(t, err)
	require.EqualValues(t, 0, blueCnt, "retired blue slot cleared after flip")

	// Exactly one active, zero building.
	_, err = env.q.GetBuildingEmbeddingVersion(ctx)
	require.ErrorIs(t, err, pgx.ErrNoRows)
}

// TestReindex_RapidChanges fires A→B→C back-to-back. Last-writer-wins: the final
// active version is C, with exactly one active and zero building remaining.
func TestReindex_RapidChanges(t *testing.T) {
	env := newReindexEnv(t, 4, threeItems())
	ctx := context.Background()

	cfgA := embedding.Config{Provider: "stub", Model: "mA", Dimension: 4}
	cfgB := embedding.Config{Provider: "stub", Model: "mB", Dimension: 4}
	cfgC := embedding.Config{Provider: "stub", Model: "mC", Dimension: 4}

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgA))
	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgB))
	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfgC))

	v := waitActive(t, env.q, embedding.ConfigHash(cfgC))
	require.Equal(t, embedding.ConfigHash(cfgC), v.ConfigHash, "last writer wins")

	// No building remains; the superseded A/B never overwrite the active C.
	deadline := time.Now().Add(5 * time.Second)
	for time.Now().Before(deadline) {
		if _, err := env.q.GetBuildingEmbeddingVersion(ctx); err == pgx.ErrNoRows {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
	_, err := env.q.GetBuildingEmbeddingVersion(ctx)
	require.ErrorIs(t, err, pgx.ErrNoRows, "no building version lingers")

	// Active is still C (a superseded late build did not flip over it).
	active, err := env.q.GetActiveEmbeddingVersion(ctx)
	require.NoError(t, err)
	require.Equal(t, embedding.ConfigHash(cfgC), active.ConfigHash)
}

// TestEnsureActiveVersion_Dedupe: an identical repeated call does not create a
// second building version.
func TestEnsureActiveVersion_Dedupe(t *testing.T) {
	env := newReindexEnv(t, 4, threeItems())
	ctx := context.Background()
	cfg := embedding.Config{Provider: "stub", Model: "m1", Dimension: 4}

	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfg))
	// Immediately call again with the same config — must be a no-op (dedupe),
	// never a second building row (the unique building index would also reject it).
	require.NoError(t, embedding.EnsureActiveVersion(ctx, env.dctx, env.store, cfg))

	waitActive(t, env.q, embedding.ConfigHash(cfg))
	max, err := env.q.MaxEmbeddingVersion(ctx)
	require.NoError(t, err)
	require.EqualValues(t, 1, max, "only one version ever created for the same config")
}
