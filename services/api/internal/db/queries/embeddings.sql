-- Embedding subsystem queries. The registry (embedding_versions) and the
-- dimension-agnostic vector writes live here as sqlc; only the KNN similarity
-- search is hand-written pgx (its ::vector(dim) cast puts a runtime dimension in
-- the type, which sqlc cannot parameterize). See internal/embedding/store.go.

-- name: AcquireEmbeddingTransitionLock :exec
-- Serializes every version transition (a fixed advisory-lock key) so the
-- single-active / single-building invariants can't race under rapid changes.
SELECT pg_advisory_xact_lock(7180294615);

-- name: GetActiveEmbeddingVersion :one
SELECT * FROM embedding_versions WHERE status = 'active';

-- name: GetBuildingEmbeddingVersion :one
SELECT * FROM embedding_versions WHERE status = 'building';

-- name: GetEmbeddingVersion :one
SELECT * FROM embedding_versions WHERE version = @version;

-- name: GetEmbeddingVersionForUpdate :one
-- Re-read at flip time to confirm the build is still 'building' before going live.
SELECT * FROM embedding_versions WHERE version = @version FOR UPDATE;

-- name: MaxEmbeddingVersion :one
SELECT COALESCE(MAX(version), 0)::int AS max FROM embedding_versions;

-- name: InsertEmbeddingVersion :one
INSERT INTO embedding_versions (version, slot, provider, model, dimension, config_hash, status)
VALUES (@version, @slot, @provider, @model, @dimension, @config_hash, 'building')
RETURNING *;

-- name: SetEmbeddingVersionWorkflowID :exec
UPDATE embedding_versions SET workflow_id = @workflow_id WHERE version = @version;

-- name: SetEmbeddingVersionDimension :exec
-- The actual vector length is known only after the first embed call.
UPDATE embedding_versions SET dimension = @dimension WHERE version = @version;

-- name: SetEmbeddingVersionStatus :exec
UPDATE embedding_versions SET status = @status WHERE version = @version;

-- name: ActivateEmbeddingVersion :exec
UPDATE embedding_versions
SET status = 'active', activated_at = now()
WHERE version = @version;

-- name: RetireActiveEmbeddingVersionExcept :exec
-- Demote the current active version (other than @keep) to retired during a flip.
UPDATE embedding_versions
SET status = 'retired'
WHERE status = 'active' AND version <> @keep;

-- name: ListRetiredEmbeddingVersionsForSlot :many
SELECT * FROM embedding_versions WHERE status = 'retired' AND slot = @slot;

-- Dimension-agnostic vector writes. Blue/green are a fixed pair (sqlc cannot
-- parameterize a column identifier); the Store dispatches by active/idle slot.

-- name: UpsertEmbeddingBlue :exec
INSERT INTO embeddings (source_type, source_id, source_text, content_hash, embedding_blue, updated_at)
VALUES (@source_type, @source_id, @source_text, @content_hash, @embedding, now())
ON CONFLICT (source_type, source_id) DO UPDATE
  SET source_text    = EXCLUDED.source_text,
      content_hash   = EXCLUDED.content_hash,
      embedding_blue = EXCLUDED.embedding_blue,
      updated_at     = now();

-- name: UpsertEmbeddingGreen :exec
INSERT INTO embeddings (source_type, source_id, source_text, content_hash, embedding_green, updated_at)
VALUES (@source_type, @source_id, @source_text, @content_hash, @embedding, now())
ON CONFLICT (source_type, source_id) DO UPDATE
  SET source_text     = EXCLUDED.source_text,
      content_hash    = EXCLUDED.content_hash,
      embedding_green = EXCLUDED.embedding_green,
      updated_at      = now();

-- name: ClearEmbeddingBlue :exec
UPDATE embeddings SET embedding_blue = NULL WHERE embedding_blue IS NOT NULL;

-- name: ClearEmbeddingGreen :exec
UPDATE embeddings SET embedding_green = NULL WHERE embedding_green IS NOT NULL;

-- name: CountEmbeddedBlue :one
SELECT count(*) FROM embeddings
WHERE source_type = @source_type AND embedding_blue IS NOT NULL;

-- name: CountEmbeddedGreen :one
SELECT count(*) FROM embeddings
WHERE source_type = @source_type AND embedding_green IS NOT NULL;

-- name: GetEmbeddingContentHash :one
-- Used to skip recompute when the source text hasn't changed.
SELECT content_hash FROM embeddings
WHERE source_type = @source_type AND source_id = @source_id;
