-- name: GetPendingDecisionByID :one
SELECT id, task_id, tool_id, kind, payload, disclosure_class, created_at,
       resolved_at, resolution, frozen_payload, workflow_id, decision_topic,
       notify_workflow_id
FROM pending_decisions
WHERE id = $1
LIMIT 1;

-- name: ListOpenPendingDecisions :many
-- Phase 2 owner-only: returns every open pending_decision. Phase 3 will
-- tighten the viewer scope rules.
SELECT id, task_id, tool_id, kind, payload, disclosure_class, created_at,
       resolved_at, resolution, frozen_payload, workflow_id, decision_topic,
       notify_workflow_id
FROM pending_decisions
WHERE resolved_at IS NULL
ORDER BY created_at DESC, id DESC;

-- name: InsertApprovalDecision :exec
-- Compose an agent-initiated approval_request with a deterministic id and the
-- back-channel target (notify_workflow_id) the tool-call workflow Sends its
-- outcome to. frozen_payload is the byte-for-byte call that will dispatch.
INSERT INTO pending_decisions
  (id, task_id, tool_id, kind, payload, frozen_payload, workflow_id, decision_topic, notify_workflow_id)
VALUES ($1, $2, $3, 'approval_request', $4, $4, $5, $6, $7);

-- name: ResolvePendingDecision :one
-- Phase 3: called by approveArtifact / rejectApproval. First-write-wins on
-- resolved_at — the row is only updated if it hasn't already been resolved.
-- Returns the row regardless (the caller compares pre-state to detect a
-- no-op).
UPDATE pending_decisions
   SET resolved_at = $2,
       resolution  = $3
 WHERE id = $1
   AND resolved_at IS NULL
RETURNING id, task_id, tool_id, kind, payload, disclosure_class, created_at,
          resolved_at, resolution, frozen_payload, workflow_id, decision_topic,
          notify_workflow_id;
