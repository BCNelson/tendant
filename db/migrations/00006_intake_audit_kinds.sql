-- +goose Up

-- Phase 7: The Intake Edge (Connectors & Dispositions).
--
-- The ONLY schema change this phase needs. Everything else rides Phase-0
-- reserved tables (connector_configs, source_credentials, intake_signals,
-- tasks.provenance/intake_signal_id, the signal_disposition enum) and
-- audit_messages.payload jsonb.
--
-- Changes:
--   (1) Extend the Phase-5 audit_messages.task_id-NULL CHECK allowlist with
--       the three PRE-TASK intake audit kinds (signal_emitted, signal_deduped,
--       llm_judge_capped). Without this, the Constitution-VI audit writes for
--       pre-task events would violate audit_task_required_unless_owner_scope.
--   (2) Add a partial index to bound the poller's unprocessed-signal scan.

-- ---------------------------------------------------------------
-- (1) audit_messages CHECK allowlist extension.
-- Drop and recreate the Phase-5 constraint adding the three intake pre-task
-- kinds. Task-scoped intake kinds (disposition_applied, intake_auto_accepted,
-- llm_judge_invoked) keep the per-task NOT NULL invariant like every other kind.
-- ---------------------------------------------------------------
ALTER TABLE audit_messages DROP CONSTRAINT IF EXISTS audit_task_required_unless_owner_scope;

ALTER TABLE audit_messages
  ADD CONSTRAINT audit_task_required_unless_owner_scope
  CHECK (
    task_id IS NOT NULL
    OR kind IN (
      'gate_script_rejected','gate_script_attached','gate_script_disabled','owner_rule_set',
      'signal_emitted','signal_deduped','llm_judge_capped'
    )
  );

-- ---------------------------------------------------------------
-- (2) Bound the poller's unprocessed scan.
-- ---------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_intake_signals_unprocessed
  ON intake_signals (connector_id) WHERE processed_at IS NULL;

-- +goose Down

DROP INDEX IF EXISTS idx_intake_signals_unprocessed;

ALTER TABLE audit_messages DROP CONSTRAINT IF EXISTS audit_task_required_unless_owner_scope;

-- Restore the Phase-5 allowlist (without the intake kinds).
ALTER TABLE audit_messages
  ADD CONSTRAINT audit_task_required_unless_owner_scope
  CHECK (
    task_id IS NOT NULL
    OR kind IN ('gate_script_rejected','gate_script_attached','gate_script_disabled','owner_rule_set')
  );
