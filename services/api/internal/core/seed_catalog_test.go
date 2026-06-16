package core

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/router"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestDefaultAgentDefs_ParseAndShape guards that the embedded default_agents/
// files all parse, yield the expected core specialists, and that every entry
// carries a valid stage, valid-JSON eligibility, and core origin. A mistyped
// TOML key (silently dropped by koanf) or a malformed eligibility is caught here
// without needing a DB.
func TestDefaultAgentDefs_ParseAndShape(t *testing.T) {
	entries, err := catalogEntriesFor(nil) // nil ⇒ embedded defaults
	require.NoError(t, err)

	wantStages := map[string]db.AgentStage{
		"general-triager":       db.AgentStageTriage,
		"high-stakes-triager":   db.AgentStageTriage,
		"communication-triager": db.AgentStageTriage,
		"research-expander":     db.AgentStageExpansion,
		"decomposer":            db.AgentStageExpansion,
		"general-expander":      db.AgentStageExpansion,
		"email-specialist":      db.AgentStageExecution,
		"general-executor":      db.AgentStageExecution,
		"code-executor":         db.AgentStageExecution,
		"feedback":              db.AgentStageFeedback,
	}
	require.Len(t, entries, len(wantStages))

	byName := map[string]catalogEntry{}
	for _, e := range entries {
		stage, ok := wantStages[e.Name]
		require.True(t, ok, "unexpected default agent %q", e.Name)
		require.Equal(t, stage, e.Stage, "agent %q stage", e.Name)
		require.NotEmpty(t, e.SystemPrompt, "agent %q system_prompt", e.Name)
		require.Equal(t, db.ConfigOriginCore, e.Origin, "default agents are core-origin")
		require.True(t, json.Valid(e.Eligibility), "agent %q eligibility is valid JSON", e.Name)
		byName[e.Name] = e
	}
	require.Len(t, byName, len(wantStages), "every expected default agent present")

	// The native-table eligibility must round-trip through the router grammar:
	// high-stakes-triager is `gte stakes_score 7`, so it prunes a low-stakes task
	// and survives a high-stakes one. This proves the TOML-table → JSON → Expression
	// path (not just valid JSON), guarding the field/op/value shape.
	hs := router.ParseExpression(byName["high-stakes-triager"].Eligibility)
	require.False(t, router.Evaluate(hs, agent.StructuredFindings{StakesScore: 3}))
	require.True(t, router.Evaluate(hs, agent.StructuredFindings{StakesScore: 8}))

	// {} eligibility is always-true.
	gt := router.ParseExpression(byName["general-triager"].Eligibility)
	require.True(t, router.Evaluate(gt, agent.StructuredFindings{}))
}

func setupCatalogDB(t *testing.T) (*db.Queries, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	return db.New(pool), ctx
}

// defaultEntry returns the embedded default-catalog entry for a (name, stage).
func defaultEntry(t *testing.T, name string, stage db.AgentStage) catalogEntry {
	t.Helper()
	entries, err := catalogEntriesFor(nil) // nil ⇒ embedded defaults
	require.NoError(t, err)
	for _, e := range entries {
		if e.Name == name && e.Stage == stage {
			return e
		}
	}
	t.Fatalf("no default-catalog entry for %s/%s", name, stage)
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
