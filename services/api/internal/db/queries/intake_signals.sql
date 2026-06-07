-- name: IdempotentInsertSignal :one
-- The single dedupe point (research R6 / SC-004). ON CONFLICT DO NOTHING means
-- a re-emission of an already-seen (connector_id, idempotency_key) returns no
-- rows (pgx.ErrNoRows) — the ingest layer treats that as the dedupe branch.
INSERT INTO intake_signals (
  signal_version, connector_id, idempotency_key, provenance, payload,
  disposition, confidence, stakes_hint
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (connector_id, idempotency_key) DO NOTHING
RETURNING *;

-- name: MarkSignalProcessed :exec
-- Set processed_at once the disposition router has handled the signal.
UPDATE intake_signals SET processed_at = now() WHERE id = $1;

-- name: GetSignal :one
SELECT * FROM intake_signals WHERE id = $1;

-- name: GetUnprocessedSignals :many
-- Bounded by the partial index idx_intake_signals_unprocessed (migration 00006).
SELECT * FROM intake_signals
WHERE connector_id = $1 AND processed_at IS NULL
ORDER BY created_at;
