package intake_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

func newSignal(disposition string, conf, stakes *float64) intake.PotentialTaskSignal {
	return intake.PotentialTaskSignal{
		SignalVersion:  intake.SignalVersion,
		SourceID:       "test:src",
		IdempotencyKey: "k-" + disposition,
		Provenance:     intake.Provenance{RawRef: "test:ref", Reason: "test reason"},
		Payload:        json.RawMessage(`{"title":"Hello"}`),
		Disposition:    disposition,
		Confidence:     conf,
		StakesHint:     stakes,
	}
}

// T027 — forced_task: accepted task, no model call, provenance set.
func TestDispose_ForcedTask(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "rss")
	sig := ingestSignal(t, pool, "rss", cid, newSignal(intake.DispositionForcedTask, nil, nil))

	judge := &intake.LogTriageJudge{}
	d := &intake.Disposer{Pool: pool, Queries: q, Triage: judge} // DBOS nil ⇒ no chain attach
	res, err := d.Dispose(ctx, sig, "rss", intake.ParseDispositionRules(nil), nil)
	require.NoError(t, err)
	require.Equal(t, intake.OutcomeForced, res.Outcome)

	task, err := q.GetTask(ctx, res.TaskID)
	require.NoError(t, err)
	require.Equal(t, lifecycle.StateAccepted, task.State)
	require.NotEmpty(t, task.Provenance)
	require.Equal(t, 0, judge.CallCount(), "forced_task must invoke no model (NFR-001)")

	// processed_at set.
	stored, err := q.GetSignal(ctx, sig.ID)
	require.NoError(t, err)
	require.True(t, stored.ProcessedAt.Valid)
}

// T036 — rich_event dial truth table + fail-closed.
func TestDispose_RichEventDial(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "rss")
	rules := intake.DispositionRules{ConfidenceFloor: 0.85, StakesCeiling: 0.30, LLMJudgePerPoll: 5}

	cases := []struct {
		name        string
		conf, stake *float64
		wantState   db.TaskState
		wantOutcome string
	}{
		{"clear/clear ⇒ auto-accept", floatPtr(0.92), floatPtr(0.10), lifecycle.StateAccepted, intake.OutcomeAutoAccept},
		{"clear/fail ⇒ proposed", floatPtr(0.92), floatPtr(0.55), lifecycle.StateProposed, intake.OutcomeProposed},
		{"fail/clear ⇒ proposed", floatPtr(0.50), floatPtr(0.10), lifecycle.StateProposed, intake.OutcomeProposed},
		{"fail/fail ⇒ proposed", floatPtr(0.50), floatPtr(0.55), lifecycle.StateProposed, intake.OutcomeProposed},
		{"missing axes ⇒ fail-closed proposed", nil, nil, lifecycle.StateProposed, intake.OutcomeProposed},
		{"out-of-range ⇒ fail-closed proposed", floatPtr(1.5), floatPtr(0.10), lifecycle.StateProposed, intake.OutcomeProposed},
	}
	for i, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			sig := newSignal(intake.DispositionRichEvent, tc.conf, tc.stake)
			sig.IdempotencyKey = "rich-" + string(rune('a'+i))
			stored := ingestSignal(t, pool, "rss", cid, sig)
			d := &intake.Disposer{Pool: pool, Queries: q}
			res, err := d.Dispose(ctx, stored, "rss", rules, nil)
			require.NoError(t, err)
			require.Equal(t, tc.wantOutcome, res.Outcome)
			task, err := q.GetTask(ctx, res.TaskID)
			require.NoError(t, err)
			require.Equal(t, tc.wantState, task.State)
		})
	}
}

// T042/T043 — llm_judge invokes the model exactly once and lands PROPOSED;
// forced_task/rich_event invoke none (the privacy invariant).
func TestDispose_LLMJudge(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "rss")
	judge := &intake.LogTriageJudge{}
	d := &intake.Disposer{Pool: pool, Queries: q, Triage: judge}
	rules := intake.ParseDispositionRules(nil)

	// llm_judge ⇒ one model call, PROPOSED.
	ljSig := ingestSignal(t, pool, "rss", cid, newSignal(intake.DispositionLLMJudge, nil, nil))
	res, err := d.Dispose(ctx, ljSig, "rss", rules, intake.NewCapCounter(5))
	require.NoError(t, err)
	require.True(t, res.ModelInvoked)
	task, err := q.GetTask(ctx, res.TaskID)
	require.NoError(t, err)
	require.Equal(t, lifecycle.StateProposed, task.State)
	require.Equal(t, 1, judge.CallCount())

	// forced + rich invoke no further model call.
	forced := newSignal(intake.DispositionForcedTask, nil, nil)
	forced.IdempotencyKey = "forced-2"
	fs := ingestSignal(t, pool, "rss", cid, forced)
	_, err = d.Dispose(ctx, fs, "rss", rules, intake.NewCapCounter(5))
	require.NoError(t, err)

	rich := newSignal(intake.DispositionRichEvent, floatPtr(0.9), floatPtr(0.1))
	rich.IdempotencyKey = "rich-2"
	rs := ingestSignal(t, pool, "rss", cid, rich)
	_, err = d.Dispose(ctx, rs, "rss", rules, intake.NewCapCounter(5))
	require.NoError(t, err)

	require.Equal(t, 1, judge.CallCount(), "only llm_judge invokes the model (SC-003)")
}

// T044-ish (cap at the Disposer level) — over-cap llm_judge holds PROPOSED with
// no model call and writes llm_judge_capped.
func TestDispose_LLMJudgeCap(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "rss")
	judge := &intake.LogTriageJudge{}
	d := &intake.Disposer{Pool: pool, Queries: q, Triage: judge}
	rules := intake.ParseDispositionRules(nil)
	capState := intake.NewCapCounter(1) // only one model call allowed this poll

	for i := 0; i < 3; i++ {
		sig := newSignal(intake.DispositionLLMJudge, nil, nil)
		sig.IdempotencyKey = "lj-cap-" + string(rune('a'+i))
		stored := ingestSignal(t, pool, "rss", cid, sig)
		_, err := d.Dispose(ctx, stored, "rss", rules, capState)
		require.NoError(t, err)
	}
	require.Equal(t, 1, judge.CallCount(), "cap bounds model fan-out to 1")

	var capped int
	require.NoError(t, pool.QueryRow(ctx,
		`SELECT count(*) FROM audit_messages WHERE kind=$1`, lifecycle.KindLLMJudgeCapped).Scan(&capped))
	require.Equal(t, 2, capped, "two over-cap items audit llm_judge_capped")
}
