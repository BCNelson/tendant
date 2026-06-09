-- +goose Up
-- Hierarchical task categories. A tree of categories (parent_id self-ref) where
-- each node binds, per lifecycle stage, an agent shortlist and/or an eligibility
-- expression. Triage classifies a task into one category; expansion + execution
-- route to that category's bound agents (inherited from ancestors). Mirrors the
-- agent_configs catalog shape: file/DB-reconciled, core/community origin, version.
-- No change to the audit_messages.task_id-NULL CHECK allowlist — categories are
-- config (like agents), not audited per-edit.

CREATE TABLE task_categories (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key            text NOT NULL UNIQUE,        -- canonical path, e.g. "communication/email"
  parent_id      uuid REFERENCES task_categories(id),
  label          text NOT NULL,
  description    text,
  -- per-stage bindings: {"execution":{"agents":["email-specialist"],"eligibility":{...}}}
  -- "agents" = static shortlist (optional); "eligibility" = router.Expression (optional);
  -- the two are ANDed when building the stage candidate set.
  stage_bindings jsonb NOT NULL DEFAULT '{}',
  origin         config_origin NOT NULL DEFAULT 'core',
  version        int NOT NULL DEFAULT 1
);

-- Ancestor-walk lookups during routing resolve by parent_id.
CREATE INDEX idx_task_categories_parent ON task_categories (parent_id);

-- +goose Down
DROP TABLE IF EXISTS task_categories;
