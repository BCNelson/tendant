package graph

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// ownerCtx / agentCtx inject a principal directly (no HTTP/session machinery) so
// the config admin resolvers can be exercised against a real DB pool.
func ownerCtx(ctx context.Context) context.Context {
	return auth.WithPrincipal(ctx, &auth.Principal{ID: uuid.New(), Kind: "user", GlobalURI: "local://principal/owner"})
}
func agentCtx(ctx context.Context) context.Context {
	return auth.WithPrincipal(ctx, &auth.Principal{ID: uuid.New(), Kind: "bot", GlobalURI: "local://principal/bot"})
}

func newConfigResolver(t *testing.T) (*Resolver, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	ov := config.NewOverlay(pool, nil)
	require.NoError(t, ov.Load(ctx))
	snap := config.DefaultConfig()
	return &Resolver{Pool: pool, Queries: db.New(pool), ConfigOverlay: ov, ConfigSnapshot: &snap}, ctx
}

func TestConfigKeys_OwnerOnly(t *testing.T) {
	r, ctx := newConfigResolver(t)

	// Agent is denied before any work.
	_, err := r.configKeysImpl(agentCtx(ctx))
	require.Error(t, err)

	keys, err := r.configKeysImpl(ownerCtx(ctx))
	require.NoError(t, err)
	require.NotEmpty(t, keys)

	// Sensitive keys are redacted; non-sensitive expose their default.
	byKey := map[string]bool{}
	for _, k := range keys {
		byKey[k.Key] = true
		if k.Sensitive {
			require.Nil(t, k.EffectiveValue, "sensitive %s must be redacted", k.Key)
		}
	}
	require.True(t, byKey["calibration.ratio"])
	require.True(t, byKey["database.url"])
}

func TestSetConfigEntry_RoundTripAndValidation(t *testing.T) {
	r, ctx := newConfigResolver(t)
	owner := ownerCtx(ctx)

	// Agent cannot set.
	_, err := r.setConfigEntryImpl(agentCtx(ctx), "calibration.ratio", "0.5")
	require.Error(t, err)

	// Non-DB-configurable key is rejected.
	_, err = r.setConfigEntryImpl(owner, "overseer.provider", "anthropic")
	require.Error(t, err)

	// Unknown key is rejected.
	_, err = r.setConfigEntryImpl(owner, "does.not.exist", "x")
	require.Error(t, err)

	// Type mismatch is rejected.
	_, err = r.setConfigEntryImpl(owner, "calibration.ratio", "notafloat")
	require.Error(t, err)

	// Valid set round-trips and the overlay reflects it.
	ck, err := r.setConfigEntryImpl(owner, "calibration.ratio", "0.42")
	require.NoError(t, err)
	require.True(t, ck.Overridden)
	require.NotNil(t, ck.EffectiveValue)
	require.Equal(t, "0.42", *ck.EffectiveValue)
	require.Equal(t, 0.42, r.ConfigOverlay.Float64Or("calibration.ratio", 0.9))

	// Delete reverts.
	ok, err := r.deleteConfigEntryImpl(owner, "calibration.ratio")
	require.NoError(t, err)
	require.True(t, ok)
	require.Equal(t, 0.9, r.ConfigOverlay.Float64Or("calibration.ratio", 0.9))

	// Agent cannot delete.
	_, err = r.deleteConfigEntryImpl(agentCtx(ctx), "calibration.ratio")
	require.Error(t, err)
}
