-- name: CreateTask :one
-- The app generates id + global_uri (local://task/<uuid>) and passes both.
INSERT INTO tasks (id, global_uri, title, description)
VALUES ($1, $2, $3, $4)
RETURNING id, global_uri, title, description, state, current_stage,
          provenance, context_refs, findings, intake_signal_id,
          created_at, edited_at;

-- name: GetTask :one
SELECT id, global_uri, title, description, state, current_stage,
       provenance, context_refs, findings, intake_signal_id,
       created_at, edited_at
FROM tasks
WHERE id = $1;

-- name: ListTasks :many
-- Keyset pagination, ordered by created_at DESC, id DESC. Caller fetches
-- limit+1 to detect hasNextPage; optional state filter; optional cursor
-- (after_created_at, after_id) encoded by the resolver.
SELECT id, global_uri, title, description, state, current_stage,
       provenance, context_refs, findings, intake_signal_id,
       created_at, edited_at
FROM tasks
WHERE (sqlc.narg('state_filter')::task_state IS NULL OR state = sqlc.narg('state_filter')::task_state)
  AND (
    sqlc.narg('after_created_at')::timestamptz IS NULL
    OR (created_at, id) < (sqlc.narg('after_created_at')::timestamptz, sqlc.narg('after_id')::uuid)
  )
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg('lim')::int;
