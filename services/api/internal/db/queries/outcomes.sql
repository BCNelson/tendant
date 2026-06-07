-- name: InsertToolOutcome :one
-- Phase 3: written once per dispatch attempt by the ToolCallWorkflow.
-- Phase 8: matured_at (at + window) and routine_fingerprint are now populated by
-- the calibration subsystem on the clean/bad paths. denied_by_script passes NULL
-- for both (it never matures, never counts toward promotion).
INSERT INTO tool_outcomes (tool_id, task_id, outcome, matured_at, routine_fingerprint)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, tool_id, task_id, outcome, at, matured_at, routine_fingerprint;

-- name: CountToolOutcomesForTask :one
-- Used in tests to assert exactly-one-write semantics.
SELECT COUNT(*) AS n
FROM tool_outcomes
WHERE task_id = $1;
