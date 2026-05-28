-- name: InsertPendingDecision :one
-- Insert into pending_decisions; trg_pending_notify fires IDs-only pg_notify.
INSERT INTO pending_decisions (task_id, tool_id, kind, payload, disclosure_class)
VALUES ($1, $2, $3, $4, $5)
RETURNING id;
