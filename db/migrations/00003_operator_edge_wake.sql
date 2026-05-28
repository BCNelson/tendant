-- +goose Up

-- Sessions: owner-scoped, per-device bearer tokens (Clarification Q4).
-- token_hash is sha256(raw token); we never store the raw token.
CREATE TABLE sessions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  principal_id  uuid NOT NULL REFERENCES principals(id) ON DELETE CASCADE,
  token_hash    bytea NOT NULL,
  display_name  text NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  last_seen_at  timestamptz NOT NULL DEFAULT now(),
  revoked_at    timestamptz,
  UNIQUE (token_hash)
);
CREATE INDEX idx_sessions_principal ON sessions(principal_id) WHERE revoked_at IS NULL;

-- agent_assignments: add to_principal so the push fan-out worker knows who to
-- wake. Existing Phase 1 rows stay null; the chain workflow populates this
-- column from Phase 2 onward.
ALTER TABLE agent_assignments
  ADD COLUMN to_principal text;
CREATE INDEX idx_assign_to_principal ON agent_assignments(to_principal) WHERE resolved_at IS NULL;

-- +goose Down

DROP INDEX IF EXISTS idx_assign_to_principal;
ALTER TABLE agent_assignments DROP COLUMN IF EXISTS to_principal;

DROP INDEX IF EXISTS idx_sessions_principal;
DROP TABLE IF EXISTS sessions;
