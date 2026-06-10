-- +goose Up
-- Generic, swappable embedding subsystem. One `embeddings` row per
-- (source_type, source_id) joins back to any source data (categories first;
-- tasks/messages later) and stores the embedded text once. Vectors live in two
-- UNCONSTRAINED `vector` columns (blue/green) so a model swap — even to a
-- different dimension — is just different-length vectors in the idle column: no
-- ALTER TABLE, no migration for a dimension change. The per-slot HNSW indexes
-- are EXPRESSION indexes carrying the dimension and are built/rebuilt at reindex
-- time (see internal/embedding store.BuildSlotIndex), so they are not declared
-- here — an unconstrained column has no single dimension until a version loads.
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE embeddings (
  source_type     text NOT NULL,         -- e.g. "task_category"
  source_id       uuid NOT NULL,
  source_text     text NOT NULL,         -- the exact text that was embedded
  content_hash    text NOT NULL,         -- hash(source_text); skip recompute when unchanged
  embedding_blue  vector,                -- size-free; holds any dimension
  embedding_green vector,                -- size-free; holds any dimension
  updated_at      timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (source_type, source_id)
);
CREATE INDEX idx_embeddings_source_type ON embeddings (source_type);

-- Registry: one row per embedding version (swap). Tracks the owner-visible
-- monotonic version number, which slot column holds it, the model/dimension, a
-- config hash for change-detection, lifecycle status, and the DBOS reindex
-- workflow id (so a superseded build can be cancelled).
CREATE TABLE embedding_versions (
  version      int  PRIMARY KEY,                 -- monotonic; owner-visible version no.
  slot         text NOT NULL,                    -- 'blue' | 'green'
  provider     text NOT NULL,
  model        text NOT NULL,
  dimension    int  NOT NULL,                    -- actual vector length for this version
  config_hash  text NOT NULL,                    -- hash(provider|model|dimension|base_url)
  status       text NOT NULL DEFAULT 'building', -- building | active | retired | superseded
  workflow_id  text,                             -- DBOS reindex workflow id (for cancel)
  created_at   timestamptz NOT NULL DEFAULT now(),
  activated_at timestamptz
);

-- Invariants enforced structurally: at most one active and at most one building
-- version at any time (single-flight reindex). The auto-trigger serializes
-- transitions under a pg_advisory_xact_lock so these can't race.
CREATE UNIQUE INDEX idx_embedding_versions_active
  ON embedding_versions (status) WHERE status = 'active';
CREATE UNIQUE INDEX idx_embedding_versions_building
  ON embedding_versions (status) WHERE status = 'building';

-- +goose Down
DROP TABLE IF EXISTS embeddings;
DROP TABLE IF EXISTS embedding_versions;
