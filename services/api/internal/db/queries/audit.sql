-- name: InsertAuditMessage :one
-- Write one audit row. The caller passes id (generated client-side so it can
-- be referenced by later in_reply_to chains without a round trip) and `at`
-- (defaults to now() if zero/null — but we pass it explicitly to keep
-- timestamps deterministic when needed).
INSERT INTO audit_messages (id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at)
VALUES (
    sqlc.arg('id')::uuid,
    sqlc.narg('task_id')::uuid,
    sqlc.arg('from_principal')::text,
    sqlc.narg('to_principal')::text,
    sqlc.narg('in_reply_to')::uuid,
    sqlc.arg('kind')::text,
    sqlc.arg('payload')::jsonb,
    COALESCE(sqlc.narg('at')::timestamptz, now())
)
RETURNING id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at;

-- name: LatestTransitionForTask :one
-- Returns the most recent audit row for a task whose kind is one of the
-- "transition" classes; used to wire in_reply_to on the next transition.
SELECT id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at
FROM audit_messages
WHERE task_id = sqlc.arg('task_id')::uuid
  AND kind IN ('state_transition','stage_advance','workflow_started','workflow_cancelled','assignment_created','assignment_resolved')
ORDER BY at DESC, id DESC
LIMIT 1;

-- name: ListAuditForTask :many
-- Full audit DAG for a task, in chronological order. Used by tests that
-- assert per-transition rows and in_reply_to wiring.
SELECT id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at
FROM audit_messages
WHERE task_id = sqlc.arg('task_id')::uuid
ORDER BY at ASC, id ASC;
