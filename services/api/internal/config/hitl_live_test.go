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

// TestHITLTimeouts_Defaults proves the boot snapshot carries the documented
// per-flow defaults and that a nil *Live still returns the safe (legacy)
// windows rather than a zero "no timeout" duration. No DB required.
func TestHITLTimeouts_Defaults(t *testing.T) {
	snap := config.DefaultConfig()
	require.Equal(t, 72*time.Hour, snap.HITL.ApprovalTimeout)
	require.Equal(t, 72*time.Hour, snap.HITL.StageTimeout)
	require.Equal(t, 168*time.Hour, snap.HITL.FeedbackTimeout)
	require.Equal(t, 72*time.Hour, snap.HITL.QuestionTimeout)

	// nil *Live → hardcoded safe defaults (never a zero/no-timeout).
	var nilLive *config.Live
	require.Equal(t, 72*time.Hour, nilLive.HITLApprovalTimeout())
	require.Equal(t, 72*time.Hour, nilLive.HITLStageTimeout())
	require.Equal(t, 168*time.Hour, nilLive.HITLFeedbackTimeout())
	require.Equal(t, 72*time.Hour, nilLive.HITLQuestionTimeout())

	// nil overlay → snapshot values.
	bare := config.NewLive(&snap, nil)
	require.Equal(t, snap.HITL.ApprovalTimeout, bare.HITLApprovalTimeout())
}

// TestHITLTimeouts_OverlayAndZero proves the DB overlay wins (hot-reload) and
// that an explicit "0" disables a flow's timeout entirely.
func TestHITLTimeouts_OverlayAndZero(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	q := db.New(pool)

	snap := config.DefaultConfig()

	for k, v := range map[string]string{
		"hitl.approval_timeout": `"10ms"`, // shorten (injectable short timeout for flow tests)
		"hitl.feedback_timeout": `"0"`,    // disable entirely
	} {
		_, err := q.UpsertConfigEntry(ctx, db.UpsertConfigEntryParams{Key: k, Value: json.RawMessage(v)})
		require.NoError(t, err)
	}
	ov := config.NewOverlay(pool, nil)
	require.NoError(t, ov.Load(ctx))

	live := config.NewLive(&snap, ov)
	require.Equal(t, 10*time.Millisecond, live.HITLApprovalTimeout(), "overlay wins")
	require.Equal(t, time.Duration(0), live.HITLFeedbackTimeout(), "0 disables the timeout")
	// A flow with no override falls back to the snapshot default.
	require.Equal(t, snap.HITL.StageTimeout, live.HITLStageTimeout())
}
