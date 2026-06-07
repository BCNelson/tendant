-- +goose Up
-- Phase 8 (Calibration & the Earned-Autonomy Ratchet). Adds the continuous
-- per-tool trust score, the per-row routine fingerprint, and the one new
-- per-routine grant table. No change to the audit_messages.task_id-NULL CHECK
-- allowlist (all four new audit kinds are task-scoped). No change to the
-- decision_kind enum (promotion_proposal already exists). No new dependency.

-- 1. tools.trust_score — the continuous per-tool autonomy substrate. Baseline
--    0.5 = mid EXECUTE_GATED band. Existing seeded tools migrate to baseline by
--    the default. rung text is retained as a derived cache of the band.
ALTER TABLE tools
  ADD COLUMN trust_score double precision NOT NULL DEFAULT 0.5
    CHECK (trust_score >= 0.0 AND trust_score <= 1.0);

-- 2. tool_outcomes.routine_fingerprint — the per-routine equivalence key,
--    populated going forward. Pre-existing rows stay NULL (never matured).
ALTER TABLE tool_outcomes
  ADD COLUMN routine_fingerprint text;

CREATE INDEX idx_outcomes_routine
  ON tool_outcomes (tool_id, routine_fingerprint, matured_at);

-- 3. tool_routine_grants — per-routine auto-approval eligibility. A live grant
--    = revoked_at IS NULL. Created on respondToPromotion(accept:true); revoked
--    by reflexive demotion. Append-only history (revoked rows retained).
CREATE TABLE tool_routine_grants (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id             uuid NOT NULL REFERENCES tools(id) ON DELETE CASCADE,
  routine_fingerprint text NOT NULL,
  evidence            jsonb NOT NULL DEFAULT '{}',
  granted_by          text NOT NULL,
  granted_at          timestamptz NOT NULL DEFAULT now(),
  revoked_at          timestamptz
);

-- At most one LIVE grant per (tool, routine).
CREATE UNIQUE INDEX uq_grant_live
  ON tool_routine_grants (tool_id, routine_fingerprint)
  WHERE revoked_at IS NULL;

-- +goose Down
DROP TABLE IF EXISTS tool_routine_grants;
DROP INDEX IF EXISTS idx_outcomes_routine;
ALTER TABLE tool_outcomes DROP COLUMN IF EXISTS routine_fingerprint;
ALTER TABLE tools DROP COLUMN IF EXISTS trust_score;
