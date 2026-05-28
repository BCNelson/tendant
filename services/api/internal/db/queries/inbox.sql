-- name: InsertPendingDecision :one
-- Insert into pending_decisions; trg_pending_notify fires IDs-only pg_notify.
INSERT INTO pending_decisions (task_id, tool_id, kind, payload, disclosure_class)
VALUES ($1, $2, $3, $4, $5)
RETURNING id;

-- name: ListInbox :many
-- Phase 2 viewer-scoped unified inbox over open pending_decisions and open
-- agent_assignments routed to the viewer. Keyset-paginated by
-- (created_at DESC, id DESC). $1 = viewer globalUri, $2/$3 = cursor
-- (timestamp + uuid), $4 = limit. For an unset cursor pass max-timestamp.
SELECT id, kind, task_id, created_at FROM (
  SELECT id, 'pending_decision'::text AS kind, task_id, created_at
    FROM pending_decisions
    WHERE resolved_at IS NULL
  UNION ALL
  SELECT id, 'agent_assignment'::text AS kind, task_id, created_at
    FROM agent_assignments
    WHERE resolved_at IS NULL AND to_principal = $1
) AS i
WHERE (i.created_at, i.id) < ($2::timestamptz, $3::uuid)
ORDER BY i.created_at DESC, i.id DESC
LIMIT $4;
