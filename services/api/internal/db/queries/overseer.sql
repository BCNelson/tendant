-- name: CountOverseerEvalsForTask :one
-- Returns the count of overseer_evaluated audit rows for a task. Used by the
-- gateway's per-task fail-closed cap (TENDANT_OVERSEER_MAX_EVAL_PER_TASK).
-- Covered by idx_audit_task (task_id, at).
SELECT count(*) AS n
FROM audit_messages
WHERE task_id = $1
  AND kind = 'overseer_evaluated';

-- name: UpdateToolPermissions :one
-- Owner-only update; resolver enforces RequireOwner first.
UPDATE tools
SET permissions = $2
WHERE id = $1
RETURNING id, global_uri, name, rung, permissions, overseer_instructions;

-- name: UpdateToolOverseerInstructions :one
-- Owner-only update; resolver enforces RequireOwner first.
UPDATE tools
SET overseer_instructions = $2
WHERE id = $1
RETURNING id, global_uri, name, rung, permissions, overseer_instructions;

-- name: UpdateToolOverseerInstructionsIfNull :one
-- Idempotent Phase-4 seeder helper for send-email. Writes only if the column
-- is currently NULL (so an owner-tuned value is never clobbered on boot).
UPDATE tools
SET overseer_instructions = $2
WHERE global_uri = $1
  AND overseer_instructions IS NULL
RETURNING id, global_uri, name, rung, permissions, overseer_instructions;

-- name: LatestOverseerInstructionsChangedForTool :one
-- Returns the most recent overseer_instructions_changed audit row for a tool,
-- or pgx.ErrNoRows on first write. Used to chain in_reply_to on subsequent
-- updates so the per-tool change history forms a chain.
SELECT id
FROM audit_messages
WHERE kind = 'overseer_instructions_changed'
  AND payload->>'tool_id' = $1::text
ORDER BY at DESC, id DESC
LIMIT 1;

-- name: LatestToolPermissionsChangedForTool :one
-- Sibling of LatestOverseerInstructionsChangedForTool for permissions edits.
SELECT id
FROM audit_messages
WHERE kind = 'tool_permissions_changed'
  AND payload->>'tool_id' = $1::text
ORDER BY at DESC, id DESC
LIMIT 1;

-- name: OverseerEvaluatedForDecision :one
-- Resolves ApprovalRequest.overseerEvaluation: returns the overseer_evaluated
-- row whose payload was authored as part of escalating this decision. The
-- payload carries the decision id under evidence.decision_id (written by the
-- gateway when it escalates from a per-task cap or model verdict). Returns
-- pgx.ErrNoRows when the decision was floor-raised (no overseer row).
SELECT id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at
FROM audit_messages
WHERE kind = 'overseer_evaluated'
  AND payload->'evidence'->>'decision_id' = $1::text
ORDER BY at DESC, id DESC
LIMIT 1;
