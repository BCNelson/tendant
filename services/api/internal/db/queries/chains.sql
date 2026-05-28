-- name: InsertChainWorkflow :one
-- Pre-creates the chain_workflows row before dbos.RunWorkflow attaches. The
-- partial-unique index idx_chainwf_task_live keeps one live row per task.
INSERT INTO chain_workflows (task_id, dbos_workflow_id, status, started_at)
VALUES ($1, $2, 'pending', now())
RETURNING id, task_id, dbos_workflow_id, status, started_at, ended_at;

-- name: EndChainWorkflow :exec
-- Close the live chain workflow row for a task. Idempotent against an
-- already-closed row — UPDATE simply matches no rows on retry.
UPDATE chain_workflows
SET status = sqlc.arg('status')::text,
    ended_at = sqlc.arg('ended_at')::timestamptz
WHERE task_id = sqlc.arg('task_id')::uuid
  AND ended_at IS NULL;

-- name: GetLiveWorkflowForTask :one
-- Returns the still-live chain workflow row for a task. pgx.ErrNoRows when
-- nothing is live (task hasn't been kicked off yet or already terminated).
SELECT id, task_id, dbos_workflow_id, status, started_at, ended_at
FROM chain_workflows
WHERE task_id = $1 AND ended_at IS NULL
LIMIT 1;
