package config_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestOverlay_LoadRefreshNotify validates the DB overlay end-to-end: Load reads
// existing rows, and a write fires the config_changed trigger so a live Listen
// refreshes the key without a manual Refresh — i.e. LISTEN/NOTIFY hot-reload.
func TestOverlay_LoadRefreshNotify(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	q := db.New(pool)

	// Seed one override, then Load.
	_, err := q.UpsertConfigEntry(ctx, db.UpsertConfigEntryParams{
		Key:   "calibration.ratio",
		Value: json.RawMessage(`0.5`),
	})
	require.NoError(t, err)

	ov := config.NewOverlay(pool, nil)
	require.NoError(t, ov.Load(ctx))
	require.Equal(t, 0.5, ov.Float64Or("calibration.ratio", 0.9))
	require.Equal(t, 0.9, ov.Float64Or("calibration.min_sample.absent", 0.9), "missing key falls through")

	// Live LISTEN: a subsequent write must propagate via NOTIFY (no manual Refresh).
	require.NoError(t, ov.Listen(ctx))
	t.Cleanup(ov.Stop)

	_, err = q.UpsertConfigEntry(ctx, db.UpsertConfigEntryParams{
		Key:   "calibration.ratio",
		Value: json.RawMessage(`0.7`),
	})
	require.NoError(t, err)
	require.Eventually(t, func() bool {
		return ov.Float64Or("calibration.ratio", 0.9) == 0.7
	}, 5*time.Second, 20*time.Millisecond, "NOTIFY should propagate the new value")

	// Delete reverts to the fallback.
	require.NoError(t, q.DeleteConfigEntry(ctx, "calibration.ratio"))
	require.Eventually(t, func() bool {
		return ov.Float64Or("calibration.ratio", 0.9) == 0.9
	}, 5*time.Second, 20*time.Millisecond, "DELETE should drop the override")
}
