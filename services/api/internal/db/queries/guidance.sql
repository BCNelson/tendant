-- name: InsertActiveAgentGuidance :one
-- Called by acceptFeedbackGuidance: the owner-accepted final text is stored
-- VERBATIM and active immediately (no review/distillation step). scope is
-- 'global' or 'agent' (agent_config_id required for 'agent').
INSERT INTO agent_guidance (
  note, status, scope, agent_config_id, source_decision_id, source_task_id, activated_at
)
VALUES ($1, 'active', $2, $3, $4, $5, now())
RETURNING id, note, status, scope, agent_config_id, source_decision_id,
          source_task_id, created_at, activated_at;

-- name: GetAgentGuidanceByID :one
SELECT id, note, status, scope, agent_config_id, source_decision_id,
       source_task_id, created_at, activated_at
FROM agent_guidance
WHERE id = $1;

-- name: ListAgentGuidanceByStatus :many
-- Owner management list (e.g. an "active guidance" settings screen).
SELECT id, note, status, scope, agent_config_id, source_decision_id,
       source_task_id, created_at, activated_at
FROM agent_guidance
WHERE status = $1
ORDER BY created_at DESC, id DESC;

-- name: DeactivateAgentGuidance :one
-- Owner retires an active guidance note.
UPDATE agent_guidance
   SET status = 'dismissed'
 WHERE id = $1 AND status = 'active'
RETURNING id, note, status, scope, agent_config_id, source_decision_id,
          source_task_id, created_at, activated_at;

-- name: ActiveGuidanceForAgent :many
-- Hot path: the agent runner loads global + this-agent active notes to inject
-- into the system prompt. Oldest-first so guidance reads chronologically.
SELECT note
FROM agent_guidance
WHERE status = 'active'
  AND (scope = 'global' OR agent_config_id = $1)
ORDER BY created_at ASC, id ASC;
