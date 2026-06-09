-- +goose Up
-- Feedback-authored agent guidance. The feedback workflow distills the owner's
-- free-text answers into short guidance notes; the owner reviews each one and
-- chooses a scope (global, or a specific agent config) before it goes live.
-- Active notes are injected into the matching agent's system prompt under a
-- labeled [OWNER_FEEDBACK] section at run time.
--
-- Lifecycle: status 'proposed' (just distilled) → 'active' (owner scoped +
-- applied) | 'dismissed' (owner rejected). Append-only modulo status/scope.
--
-- No audit_messages CHECK-allowlist change: the two new audit kinds
-- (feedback_guidance_proposed, agent_guidance_applied) are recorded against the
-- source task (source_task_id), so they always carry a non-NULL task_id.

CREATE TABLE agent_guidance (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  note               text NOT NULL,
  status             text NOT NULL DEFAULT 'proposed'
                       CHECK (status IN ('proposed', 'active', 'dismissed')),
  scope              text NOT NULL DEFAULT 'global'
                       CHECK (scope IN ('global', 'agent')),
  -- Required when scope = 'agent'; NULL for global notes.
  agent_config_id    uuid REFERENCES agent_configs(id) ON DELETE CASCADE,
  source_decision_id uuid,
  source_task_id     uuid REFERENCES tasks(id) ON DELETE SET NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  activated_at       timestamptz,
  CHECK (scope = 'global' OR agent_config_id IS NOT NULL)
);

-- Hot path: load active guidance for an agent (global + this agent's).
CREATE INDEX idx_agent_guidance_active
  ON agent_guidance (scope, agent_config_id)
  WHERE status = 'active';

-- Owner review queue: list proposed notes newest-first.
CREATE INDEX idx_agent_guidance_status
  ON agent_guidance (status, created_at DESC);

-- +goose Down
DROP TABLE IF EXISTS agent_guidance;
