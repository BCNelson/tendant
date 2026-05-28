-- name: InsertPendingDecision :one
-- Insert into pending_decisions; trg_pending_notify fires IDs-only pg_notify.
INSERT INTO pending_decisions (task_id, tool_id, kind, payload, disclosure_class)
VALUES ($1, $2, $3, $4, $5)
RETURNING id;

-- name: InsertAgentAssignment :one
-- Insert into agent_assignments; trg_assign_notify fires IDs-only pg_notify.
INSERT INTO agent_assignments (task_id, stage, from_principal, ask, gathered_context)
VALUES ($1, $2, $3, $4, $5)
RETURNING id;
