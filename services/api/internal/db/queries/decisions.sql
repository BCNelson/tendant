-- name: GetPendingDecisionByID :one
SELECT id, task_id, tool_id, kind, payload, disclosure_class, created_at, resolved_at, resolution
FROM pending_decisions
WHERE id = $1
LIMIT 1;

-- name: ListOpenPendingDecisions :many
-- Phase 2 owner-only: returns every open pending_decision. Phase 3 will
-- tighten the viewer scope rules.
SELECT id, task_id, tool_id, kind, payload, disclosure_class, created_at, resolved_at, resolution
FROM pending_decisions
WHERE resolved_at IS NULL
ORDER BY created_at DESC, id DESC;
