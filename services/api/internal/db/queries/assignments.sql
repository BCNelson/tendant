-- name: InsertAgentAssignment :one
-- Insert into agent_assignments; trg_assign_notify fires IDs-only pg_notify.
-- Returns the full row so callers (chain workflow / audit) don't need a second
-- SELECT for created_at, etc.
INSERT INTO agent_assignments (task_id, stage, from_principal, ask, gathered_context)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal;

-- name: ResolveAssignment :one
-- Idempotent close: only updates an open row. Returns the closed row, or no
-- row (sql.ErrNoRows) if the assignment was already resolved.
UPDATE agent_assignments
SET resolved_at = sqlc.arg('resolved_at')::timestamptz
WHERE id = sqlc.arg('id')::uuid
  AND resolved_at IS NULL
RETURNING id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal;

-- name: FindOpenAssignmentForTask :one
-- Returns the open assignment for a task (at most one — partial-unique index
-- idx_assign_open enforces uniqueness on open rows). pgx.ErrNoRows if none.
SELECT id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal
FROM agent_assignments
WHERE task_id = $1 AND resolved_at IS NULL
LIMIT 1;

-- name: FindOpenAssignmentForStage :one
-- Deterministic recovery lookup: returns the open assignment for (task, stage),
-- used when the chain workflow needs to find "its" current slot after restart.
SELECT id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal
FROM agent_assignments
WHERE task_id = $1 AND stage = $2 AND resolved_at IS NULL
LIMIT 1;

-- name: FindLatestAssignmentForStage :one
-- Like FindOpenAssignmentForStage but WITHOUT the resolved_at filter — returns
-- the most recent assignment for (task, stage) whether open or closed. The
-- chain workflow's resolve+advance step uses this so it can still write the
-- assignment_resolved audit even when the completeTask resolver already closed
-- the row synchronously (for immediate inbox responsiveness). Each human stage
-- opens exactly one assignment, so "latest" is unambiguous in practice.
SELECT id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal
FROM agent_assignments
WHERE task_id = $1 AND stage = $2
ORDER BY created_at DESC, id DESC
LIMIT 1;

-- name: SetAssignmentRecipient :one
UPDATE agent_assignments
SET to_principal = $2
WHERE id = $1
RETURNING id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal;

-- name: GetAgentAssignmentByID :one
SELECT id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal
FROM agent_assignments
WHERE id = $1
LIMIT 1;

-- name: ListOpenAssignmentsForRecipient :many
SELECT id, task_id, stage, from_principal, ask, gathered_context, created_at, resolved_at, to_principal
FROM agent_assignments
WHERE to_principal = $1 AND resolved_at IS NULL
ORDER BY created_at DESC, id DESC;
