-- name: InsertToolOutcome :one
-- Phase 3: written once per dispatch attempt by the ToolCallWorkflow.
-- matured_at stays NULL — Phase 8's calibration ratchet sets it.
INSERT INTO tool_outcomes (tool_id, task_id, outcome)
VALUES ($1, $2, $3)
RETURNING id, tool_id, task_id, outcome, at, matured_at;

-- name: CountToolOutcomesForTask :one
-- Used in tests to assert exactly-one-write semantics.
SELECT COUNT(*) AS n
FROM tool_outcomes
WHERE task_id = $1;
