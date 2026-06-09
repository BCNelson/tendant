package core

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupCatalogDB(t *testing.T) (*db.Queries, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	return db.New(pool), ctx
}

// defaultEntry returns the in-code baseCatalog entry for a (name, stage).
func defaultEntry(t *testing.T, name string, stage db.AgentStage) catalogEntry {
	t.Helper()
	for _, e := range baseCatalog {
		if e.Name == name && e.Stage == stage {
			return e
		}
	}
	t.Fatalf("no baseCatalog entry for %s/%s", name, stage)
	return catalogEntry{}
}

func getConfig(t *testing.T, ctx context.Context, q *db.Queries, name string, stage db.AgentStage) db.AgentConfig {
	t.Helper()
	got, err := q.GetAgentConfigByNameAndStage(ctx, db.GetAgentConfigByNameAndStageParams{Name: name, Stage: stage})
	require.NoError(t, err)
	return got
}

// TestReconcile_ResyncsCoreRowToInCodeDefault proves the boot-time re-sync: a
// stale core-origin row is updated to the current in-code default (so a deploy
// that improves a prompt reaches a live DB), with a version bump.
func TestReconcile_ResyncsCoreRowToInCodeDefault(t *testing.T) {
	q, ctx := setupCatalogDB(t)
	want := defaultEntry(t, "general-executor", db.AgentStageExecution)

	stale := "OLD executor prompt — predates the deploy"
	_, err := q.InsertAgentConfig(ctx, db.InsertAgentConfigParams{
		Name:          want.Name,
		Stage:         want.Stage,
		IsHuman:       false,
		SystemPrompt:  &stale,
		ToolAllowlist: json.RawMessage(`[]`),
		Eligibility:   want.Eligibility,
		Origin:        db.ConfigOriginCore,
		Version:       1,
	})
	require.NoError(t, err)

	require.NoError(t, SeedAgentCatalog(ctx, q))

	got := getConfig(t, ctx, q, want.Name, want.Stage)
	require.NotNil(t, got.SystemPrompt)
	require.Equal(t, want.SystemPrompt, *got.SystemPrompt, "core row should re-sync to in-code default")
	require.Equal(t, int32(2), got.Version, "re-sync should bump version")
}

// TestReconcile_PreservesNonCoreCustomization proves a non-core row (an owner /
// community customization) is left untouched by the boot-time re-sync.
func TestReconcile_PreservesNonCoreCustomization(t *testing.T) {
	q, ctx := setupCatalogDB(t)
	want := defaultEntry(t, "general-executor", db.AgentStageExecution)

	custom := "OWNER CUSTOM executor prompt — keep me"
	_, err := q.InsertAgentConfig(ctx, db.InsertAgentConfigParams{
		Name:          want.Name,
		Stage:         want.Stage,
		IsHuman:       false,
		SystemPrompt:  &custom,
		ToolAllowlist: json.RawMessage(`[]`),
		Eligibility:   want.Eligibility,
		Origin:        db.ConfigOriginCommunity,
		Version:       1,
	})
	require.NoError(t, err)

	require.NoError(t, SeedAgentCatalog(ctx, q))

	got := getConfig(t, ctx, q, want.Name, want.Stage)
	require.NotNil(t, got.SystemPrompt)
	require.Equal(t, custom, *got.SystemPrompt, "non-core customization must be preserved")
	require.Equal(t, int32(1), got.Version, "non-core row must not be re-synced")
}

// TestReconcile_NoChurnWhenCoreRowMatches proves an already-current core row is
// not re-synced on a second boot — guarding jsonEqual against false drift from
// jsonb's canonical reformatting of eligibility/allowlist.
func TestReconcile_NoChurnWhenCoreRowMatches(t *testing.T) {
	q, ctx := setupCatalogDB(t)

	require.NoError(t, SeedAgentCatalog(ctx, q)) // first boot: inserts all at v1
	first := getConfig(t, ctx, q, "high-stakes-triager", db.AgentStageTriage)
	require.Equal(t, int32(1), first.Version)

	require.NoError(t, SeedAgentCatalog(ctx, q)) // second boot: nothing drifted
	second := getConfig(t, ctx, q, "high-stakes-triager", db.AgentStageTriage)
	require.Equal(t, int32(1), second.Version, "matching core row must not bump version")
}
