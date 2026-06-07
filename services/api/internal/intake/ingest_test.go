package intake_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// T046 — ON CONFLICT DO NOTHING: a re-emitted (connector_id, idempotency_key)
// returns Deduped=true and writes one signal row + a signal_deduped audit.
func TestIngest_Idempotent(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "webhook-in")

	sig := intake.PotentialTaskSignal{
		SignalVersion:  intake.SignalVersion,
		SourceID:       "webhook-in:src",
		IdempotencyKey: "dup-key",
		Provenance:     intake.Provenance{RawRef: "ref", Reason: "why"},
		Payload:        json.RawMessage(`{"title":"x"}`),
		Disposition:    intake.DispositionForcedTask,
	}

	first, err := intake.Ingest(ctx, pool, sig, "webhook-in", cid)
	require.NoError(t, err)
	require.False(t, first.Deduped)

	second, err := intake.Ingest(ctx, pool, sig, "webhook-in", cid)
	require.NoError(t, err)
	require.True(t, second.Deduped, "second emission must dedupe (SC-004)")

	var signals int
	require.NoError(t, pool.QueryRow(ctx,
		`SELECT count(*) FROM intake_signals WHERE connector_id=$1 AND idempotency_key=$2`,
		cid, "dup-key").Scan(&signals))
	require.Equal(t, 1, signals)

	var emitted, deduped int
	require.NoError(t, pool.QueryRow(ctx, `SELECT count(*) FROM audit_messages WHERE kind=$1`, lifecycle.KindSignalEmitted).Scan(&emitted))
	require.NoError(t, pool.QueryRow(ctx, `SELECT count(*) FROM audit_messages WHERE kind=$1`, lifecycle.KindSignalDeduped).Scan(&deduped))
	require.Equal(t, 1, emitted)
	require.Equal(t, 1, deduped)
}

// T045 — same item twice across two "polls" (ingest + dispose) yields one task.
func TestIngest_OneTaskAcrossPolls(t *testing.T) {
	ctx := context.Background()
	pool, q := testEnv(t)
	cid := seedConnector(t, q, "webhook-in")

	sig := intake.PotentialTaskSignal{
		SignalVersion:  intake.SignalVersion,
		SourceID:       "webhook-in:src",
		IdempotencyKey: "same-item",
		Provenance:     intake.Provenance{RawRef: "ref", Reason: "why"},
		Payload:        json.RawMessage(`{"title":"once"}`),
		Disposition:    intake.DispositionForcedTask,
	}

	d := &intake.Disposer{Pool: pool, Queries: q}
	rules := intake.ParseDispositionRules(nil)

	// Poll 1: ingest + dispose.
	r1, err := intake.Ingest(ctx, pool, sig, "webhook-in", cid)
	require.NoError(t, err)
	require.False(t, r1.Deduped)
	_, err = d.Dispose(ctx, r1.Signal, "webhook-in", rules, nil)
	require.NoError(t, err)

	// Poll 2: re-emit → dedupe → no new task.
	r2, err := intake.Ingest(ctx, pool, sig, "webhook-in", cid)
	require.NoError(t, err)
	require.True(t, r2.Deduped)

	var tasks int
	require.NoError(t, pool.QueryRow(ctx, `
		SELECT count(*) FROM tasks WHERE intake_signal_id IN
		  (SELECT id FROM intake_signals WHERE connector_id=$1 AND idempotency_key=$2)`,
		cid, "same-item").Scan(&tasks))
	require.Equal(t, 1, tasks, "same item twice ⇒ exactly one task (SC-004)")
}
