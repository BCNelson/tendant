package config_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestLive_OverlayWinsOverSnapshot proves Live reads the DB overlay when present
// and falls back to the boot snapshot otherwise (and is nil-overlay safe).
func TestLive_OverlayWinsOverSnapshot(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	q := db.New(pool)

	snap := config.DefaultConfig()

	// nil overlay → snapshot values.
	bare := config.NewLive(&snap, nil)
	require.Equal(t, snap.Calibration.Ratio, bare.CalibrationRatio())
	require.Equal(t, "info", bare.LogLevel())

	// Seed overrides, load overlay.
	for k, v := range map[string]string{
		"calibration.ratio":          `0.5`,
		"overseer.max_eval_per_task": `7`,
		"log.level":                  `"debug"`,
	} {
		_, err := q.UpsertConfigEntry(ctx, db.UpsertConfigEntryParams{Key: k, Value: json.RawMessage(v)})
		require.NoError(t, err)
	}
	ov := config.NewOverlay(pool, nil)
	require.NoError(t, ov.Load(ctx))

	live := config.NewLive(&snap, ov)
	require.Equal(t, 0.5, live.CalibrationRatio(), "overlay wins")
	require.Equal(t, 7, live.OverseerMaxEvalPerTask(), "overlay wins")
	require.Equal(t, "debug", live.LogLevel(), "overlay wins")
	// A key with no override falls back to the snapshot.
	require.Equal(t, snap.Calibration.MinSample, live.CalibrationMinSample())
}
