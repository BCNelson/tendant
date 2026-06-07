-- +goose Up

-- Phase 5: Gate Scripts (the untrusted-code surface) + owner rules.
--
-- NOTE: migration 00001 already created a *partial* gate_scripts table
-- (id, tool_id, version, wasm, source, manifest, created_at). Phase 5 is the
-- first writer of that table, so it is empty in every deployment; this
-- migration ALTERs it to add the Phase-5 columns (manifest_hash, tier, status,
-- attached_by_principal, attached_at) rather than recreating it. Adding NOT
-- NULL columns without a default is safe precisely because the table is empty.
--
-- Changes:
--   (1) gate_scripts gains manifest_hash/tier/status/attached_by_principal/
--       attached_at + two indexes + an append-only BEFORE UPDATE trigger.
--   (2) tools.active_script_version — the pointer at the currently-active row.
--   (3) owner_rules — key/value owner preferences read by owner.rule(key).
--   (4) audit_messages.task_id relaxed to nullable + CHECK admitting NULL only
--       for the four owner-scoped Phase-5 kinds (Q3).
--   (5) tool_outcome_kind gains 'denied_by_script' (FR-003).

-- ---------------------------------------------------------------
-- (0) tool_outcome_kind gains denied_by_script (FR-003).
-- PG16 permits ADD VALUE inside a transaction as long as the new value is not
-- used in the same transaction (it is not — dispatch happens at runtime).
-- ---------------------------------------------------------------
ALTER TYPE tool_outcome_kind ADD VALUE IF NOT EXISTS 'denied_by_script';

-- ---------------------------------------------------------------
-- (1) gate_scripts — extend the Phase-0 spine table
-- ---------------------------------------------------------------
ALTER TABLE gate_scripts
  ADD COLUMN manifest_hash         text NOT NULL,
  ADD COLUMN tier                  text NOT NULL CHECK (tier IN ('assemblyscript_in_app','byo_wasm')),
  ADD COLUMN status                text NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled')),
  ADD COLUMN attached_by_principal text NOT NULL,
  ADD COLUMN attached_at           timestamptz NOT NULL DEFAULT now();

CREATE INDEX idx_gate_scripts_tool ON gate_scripts (tool_id, version DESC);
CREATE INDEX idx_gate_scripts_active ON gate_scripts (tool_id) WHERE status = 'active';

-- Append-only modulo status (FR-025): a BEFORE UPDATE trigger rejects any
-- column change other than `status`. See research.md R11.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION gate_scripts_block_immutable_columns()
RETURNS trigger AS $$
BEGIN
  IF NEW.id           IS DISTINCT FROM OLD.id           OR
     NEW.tool_id      IS DISTINCT FROM OLD.tool_id      OR
     NEW.version      IS DISTINCT FROM OLD.version      OR
     NEW.manifest     IS DISTINCT FROM OLD.manifest     OR
     NEW.manifest_hash IS DISTINCT FROM OLD.manifest_hash OR
     NEW.wasm         IS DISTINCT FROM OLD.wasm         OR
     NEW.source       IS DISTINCT FROM OLD.source       OR
     NEW.tier         IS DISTINCT FROM OLD.tier         OR
     NEW.created_at   IS DISTINCT FROM OLD.created_at   OR
     NEW.attached_by_principal IS DISTINCT FROM OLD.attached_by_principal OR
     NEW.attached_at  IS DISTINCT FROM OLD.attached_at
  THEN
    RAISE EXCEPTION 'gate_scripts rows are append-only modulo status; column update rejected';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER gate_scripts_block_immutable_columns_trg
  BEFORE UPDATE ON gate_scripts
  FOR EACH ROW EXECUTE FUNCTION gate_scripts_block_immutable_columns();

-- ---------------------------------------------------------------
-- (2) tools.active_script_version — the pointer
-- ---------------------------------------------------------------
ALTER TABLE tools ADD COLUMN active_script_version int NULL;
-- No FK to gate_scripts (the version is opaque per (tool_id, version)).

-- ---------------------------------------------------------------
-- (3) owner_rules — key/value owner preferences (Q2)
-- ---------------------------------------------------------------
CREATE TABLE owner_rules (
  owner_global_uri text NOT NULL,
  key              text NOT NULL,
  value            text NOT NULL,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (owner_global_uri, key)
);
CREATE INDEX idx_owner_rules_owner ON owner_rules (owner_global_uri);

-- ---------------------------------------------------------------
-- (4) audit_messages.task_id relaxation (Q3)
-- ---------------------------------------------------------------
ALTER TABLE audit_messages ALTER COLUMN task_id DROP NOT NULL;

-- Admit NULL only for owner-scoped kinds. The CHECK keeps the per-task
-- NOT NULL invariant for all prior kinds and all Phase-5 *task-scoped* kinds
-- (gate_script_evaluated, gate_script_skipped).
ALTER TABLE audit_messages
  ADD CONSTRAINT audit_task_required_unless_owner_scope
  CHECK (
    task_id IS NOT NULL
    OR kind IN ('gate_script_rejected','gate_script_attached','gate_script_disabled','owner_rule_set')
  );

-- +goose Down

ALTER TABLE audit_messages DROP CONSTRAINT IF EXISTS audit_task_required_unless_owner_scope;
-- Note: cannot blindly restore NOT NULL if owner-scoped rows exist.
-- For dev/test: TRUNCATE audit_messages first, then ALTER COLUMN SET NOT NULL.

DROP TABLE IF EXISTS owner_rules;

DROP TRIGGER IF EXISTS gate_scripts_block_immutable_columns_trg ON gate_scripts;
DROP FUNCTION IF EXISTS gate_scripts_block_immutable_columns();

ALTER TABLE tools DROP COLUMN IF EXISTS active_script_version;

ALTER TABLE gate_scripts
  DROP COLUMN IF EXISTS attached_at,
  DROP COLUMN IF EXISTS attached_by_principal,
  DROP COLUMN IF EXISTS status,
  DROP COLUMN IF EXISTS tier,
  DROP COLUMN IF EXISTS manifest_hash;

-- Note: tool_outcome_kind cannot drop the added 'denied_by_script' value
-- (Postgres has no ALTER TYPE ... DROP VALUE). The relaxed enum is harmless.
