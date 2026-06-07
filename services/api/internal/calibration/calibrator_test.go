package calibration_test

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

func testEnv(t *testing.T) (*pgxpool.Pool, *db.Queries, db.Tool, uuid.UUID) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	require.NoError(t, tools.SeedSendEmail(ctx, q))
	tool, err := q.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	task, err := core.CreateTask(ctx, pool, nil, "calibration test task", "")
	require.NoError(t, err)
	return pool, q, tool, task.ID
}

func testCfg() calibration.Config {
	return calibration.Config{
		Maturation:        time.Hour,
		WindowN:           10,
		Ratio:             0.9,
		MinSample:         5,
		DemotionDecrement: 0.25,
		SweepCron:         "* * * * *",
		IntakeTightenK:    0.02,
	}
}

// insertMatured inserts an already-matured outcome (matured_at in the past) with
// the given fingerprint — bypassing the maturation wait for deterministic tests.
func insertMatured(t *testing.T, q *db.Queries, toolID, taskID uuid.UUID, fp string, outcome db.ToolOutcomeKind) {
	t.Helper()
	fpCopy := fp
	_, err := q.InsertToolOutcome(context.Background(), db.InsertToolOutcomeParams{
		ToolID:             toolID,
		TaskID:             taskID,
		Outcome:            outcome,
		MaturedAt:          pgtype.Timestamptz{Time: time.Now().Add(-time.Minute), Valid: true},
		RoutineFingerprint: &fpCopy,
	})
	require.NoError(t, err)
}

func setScore(t *testing.T, q *db.Queries, toolID uuid.UUID, score float64) {
	t.Helper()
	_, err := q.SetTrustScore(context.Background(), db.SetTrustScoreParams{
		ID: toolID, TrustScore: score, Rung: string(calibration.Band(score)),
	})
	require.NoError(t, err)
}

func TestRecordOutcomeStampsMaturationAndFingerprint(t *testing.T) {
	pool, _, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)

	var out db.ToolOutcome
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		var err error
		out, err = eng.RecordOutcome(ctx, tx, calibration.OutcomeInput{
			ToolID:        tool.ID,
			TaskID:        taskID,
			ToolGlobalURI: tool.GlobalUri,
			Payload:       []byte(`{"to":"known@friend.example"}`),
			At:            time.Now(),
		})
		return err
	}))
	require.True(t, out.MaturedAt.Valid, "matured_at must be stamped at insert")
	require.NotNil(t, out.RoutineFingerprint)
	require.Equal(t, db.ToolOutcomeKindClean, out.Outcome)
}

func TestMaybeProposePromotionEligibility(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)
	fp := calibration.Fingerprint(tool.GlobalUri, []byte(`{"to":"known@friend.example"}`))

	// Below min sample (4 < 5) → no proposal.
	for i := 0; i < 4; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindClean)
	}
	prop, err := eng.MaybeProposePromotion(ctx, tool.ID, fp)
	require.NoError(t, err)
	require.Nil(t, prop, "below min sample must not propose")

	// Now 6 clean (≥5) and ratio 1.0 ≥ 0.9 → eligible.
	for i := 0; i < 2; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindClean)
	}
	prop, err = eng.MaybeProposePromotion(ctx, tool.ID, fp)
	require.NoError(t, err)
	require.NotNil(t, prop, "≥ min sample at high ratio must propose")
	require.Equal(t, calibration.LevelExecuteAuto, prop.ToLevel)
	require.Equal(t, fp, prop.Fingerprint)
	require.Equal(t, taskID, prop.ReprTaskID)
	require.GreaterOrEqual(t, prop.Evidence.Ratio, 0.9)
}

func TestMaybeProposePromotionRatioGate(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)
	fp := calibration.Fingerprint(tool.GlobalUri, []byte(`{"to":"a@b.example"}`))

	// 6 outcomes, 2 bad → ratio 0.66 < 0.9.
	for i := 0; i < 4; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindClean)
	}
	for i := 0; i < 2; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindBad)
	}
	prop, err := eng.MaybeProposePromotion(ctx, tool.ID, fp)
	require.NoError(t, err)
	require.Nil(t, prop, "below ratio must not propose")
}

func TestMaybeProposePromotionDedupeOnGrant(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)
	fp := calibration.Fingerprint(tool.GlobalUri, []byte(`{"to":"a@b.example"}`))
	for i := 0; i < 6; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindClean)
	}
	// A live grant for this routine ⇒ no re-proposal.
	_, err := q.InsertRoutineGrant(ctx, db.InsertRoutineGrantParams{
		ToolID: tool.ID, RoutineFingerprint: fp, Evidence: []byte(`{}`), GrantedBy: "owner",
	})
	require.NoError(t, err)
	prop, err := eng.MaybeProposePromotion(ctx, tool.ID, fp)
	require.NoError(t, err)
	require.Nil(t, prop, "an already-granted routine must not re-propose")
}

func TestMaturationVetoExcludesUnmaturedFromRatio(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)
	fp := calibration.Fingerprint(tool.GlobalUri, []byte(`{"to":"a@b.example"}`))

	// 4 matured clean + 1 UNMATURED clean (future matured_at) = 4 matured < 5.
	for i := 0; i < 4; i++ {
		insertMatured(t, q, tool.ID, taskID, fp, db.ToolOutcomeKindClean)
	}
	fpCopy := fp
	_, err := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
		ToolID: tool.ID, TaskID: taskID, Outcome: db.ToolOutcomeKindClean,
		MaturedAt:          pgtype.Timestamptz{Time: time.Now().Add(time.Hour), Valid: true}, // not yet matured
		RoutineFingerprint: &fpCopy,
	})
	require.NoError(t, err)

	prop, err := eng.MaybeProposePromotion(ctx, tool.ID, fp)
	require.NoError(t, err)
	require.Nil(t, prop, "an un-matured outcome must not count toward the ratio (FR-004)")
}

func TestFlagBadDemotesAndRevokes(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	eng := calibration.New(pool, testCfg(), nil)
	payload := []byte(`{"to":"known@friend.example"}`)
	fp := calibration.Fingerprint(tool.GlobalUri, payload)

	// Promote: score in auto band + a live grant.
	setScore(t, q, tool.ID, calibration.AutoThreshold)
	_, err := q.InsertRoutineGrant(ctx, db.InsertRoutineGrantParams{
		ToolID: tool.ID, RoutineFingerprint: fp, Evidence: []byte(`{}`), GrantedBy: "owner",
	})
	require.NoError(t, err)
	// Record a clean outcome so FlagBad can find the affected routine.
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		_, e := eng.RecordOutcome(ctx, tx, calibration.OutcomeInput{
			ToolID: tool.ID, TaskID: taskID, ToolGlobalURI: tool.GlobalUri, Payload: payload, At: time.Now(),
		})
		return e
	}))

	updated, err := eng.FlagBad(ctx, taskID, tool.ID, "wrong recipient")
	require.NoError(t, err)
	require.Less(t, updated.TrustScore, calibration.AutoThreshold, "must drop out of auto band")
	require.GreaterOrEqual(t, updated.TrustScore, calibration.Baseline, "must clamp at baseline")

	live, err := q.LiveGrantExists(ctx, db.LiveGrantExistsParams{ToolID: tool.ID, RoutineFingerprint: fp})
	require.NoError(t, err)
	require.False(t, live, "the routine's grant must be revoked")
}

// TestConcurrentDemotionSerializes proves GetToolForUpdate serializes two
// near-simultaneous demotions (no lost update) — spec edge case / T044.
func TestConcurrentDemotionSerializes(t *testing.T) {
	pool, q, tool, taskID := testEnv(t)
	ctx := context.Background()
	cfg := testCfg()
	cfg.DemotionDecrement = 0.1
	eng := calibration.New(pool, cfg, nil)
	setScore(t, q, tool.ID, 0.95)

	// Two distinct routines so each FlagBad has an outcome to target.
	for _, addr := range []string{`{"to":"a@x.example"}`, `{"to":"b@y.example"}`} {
		payload := []byte(addr)
		require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
			_, e := eng.RecordOutcome(ctx, tx, calibration.OutcomeInput{
				ToolID: tool.ID, TaskID: taskID, ToolGlobalURI: tool.GlobalUri, Payload: payload, At: time.Now(),
			})
			return e
		}))
	}

	var wg sync.WaitGroup
	for i := 0; i < 2; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			_, _ = eng.FlagBad(ctx, taskID, tool.ID, "concurrent")
		}()
	}
	wg.Wait()

	score, err := q.GetTrustScore(ctx, tool.ID)
	require.NoError(t, err)
	// 0.95 - 0.1 - 0.1 = 0.75 if serialized; 0.85 if a write was lost.
	require.InDelta(t, 0.75, score, 0.0001, "concurrent demotions must serialize (no lost update)")
}
