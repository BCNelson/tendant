package intake

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// ConnectorPrincipalURI is the from_principal for a connector's audit rows
// (data-model §5): connector:<type>:<id>.
func ConnectorPrincipalURI(connectorType string, connectorID uuid.UUID) string {
	return fmt.Sprintf("connector:%s:%s", connectorType, connectorID)
}

// IngestResult reports the outcome of persisting one emitted signal.
type IngestResult struct {
	Signal  db.IntakeSignal
	Deduped bool // true when (connector_id, idempotency_key) already existed
}

// Ingest persists one emitted signal idempotently (research R6 / SC-004): the
// insert is ON CONFLICT (connector_id, idempotency_key) DO NOTHING. On a fresh
// insert it writes a signal_emitted audit; on a collision it writes a
// signal_deduped audit and returns Deduped=true with no row to dispose.
//
// Both the insert and its audit ride one transaction so a crash can never leave
// a persisted signal without its audit (or vice-versa).
func Ingest(ctx context.Context, pool *pgxpool.Pool, sig PotentialTaskSignal, connectorType string, connectorID uuid.UUID) (IngestResult, error) {
	if err := sig.Validate(); err != nil {
		return IngestResult{}, err
	}

	var result IngestResult
	tx, err := pool.Begin(ctx)
	if err != nil {
		return IngestResult{}, fmt.Errorf("begin ingest tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck // best-effort rollback on early return

	q := db.New(tx)
	from := ConnectorPrincipalURI(connectorType, connectorID)

	provJSON, payload, conf, stakes, err := marshalSignalColumns(sig)
	if err != nil {
		return IngestResult{}, err
	}

	row, insErr := q.IdempotentInsertSignal(ctx, db.IdempotentInsertSignalParams{
		SignalVersion:  sig.SignalVersion,
		ConnectorID:    pgtype.UUID{Bytes: connectorID, Valid: true},
		IdempotencyKey: sig.IdempotencyKey,
		Provenance:     provJSON,
		Payload:        payload,
		Disposition:    db.SignalDisposition(sig.Disposition),
		Confidence:     conf,
		StakesHint:     stakes,
	})

	switch {
	case errors.Is(insErr, pgx.ErrNoRows):
		// Dedupe branch: the row already exists.
		result.Deduped = true
		if _, err := lifecycle.WriteAuditMessage(ctx, tx, uuid.Nil, from, lifecycle.KindSignalDeduped,
			lifecycle.SignalDedupedPayload{
				ConnectorID:    connectorID.String(),
				IdempotencyKey: sig.IdempotencyKey,
			}, uuid.Nil); err != nil {
			return IngestResult{}, fmt.Errorf("audit signal_deduped: %w", err)
		}
	case insErr != nil:
		return IngestResult{}, fmt.Errorf("idempotent insert signal: %w", insErr)
	default:
		result.Signal = row
		if _, err := lifecycle.WriteAuditMessage(ctx, tx, uuid.Nil, from, lifecycle.KindSignalEmitted,
			lifecycle.SignalEmittedPayload{
				ConnectorID:    connectorID.String(),
				IdempotencyKey: sig.IdempotencyKey,
				Disposition:    sig.Disposition,
				SignalID:       row.ID.String(),
			}, uuid.Nil); err != nil {
			return IngestResult{}, fmt.Errorf("audit signal_emitted: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return IngestResult{}, fmt.Errorf("commit ingest tx: %w", err)
	}
	return result, nil
}

// marshalSignalColumns prepares the jsonb + nullable-float columns for insert.
func marshalSignalColumns(sig PotentialTaskSignal) (provJSON []byte, payload []byte, conf, stakes *float64, err error) {
	provJSON, err = json.Marshal(sig.Provenance)
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("marshal provenance: %w", err)
	}
	return provJSON, sig.Payload, sig.Confidence, sig.StakesHint, nil
}
