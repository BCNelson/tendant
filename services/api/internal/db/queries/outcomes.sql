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

-- name: ListToolOutcomesForTask :many
-- All tool outcomes recorded under a task, oldest-first. Read by the
-- post-completion feedback agent (internal/feedback) to summarize what tools
-- ran and whether any were flagged bad.
SELECT id, tool_id, task_id, outcome, at, matured_at, routine_fingerprint
FROM tool_outcomes
WHERE task_id = $1
ORDER BY at ASC, id ASC;

-- name: DecisionAlreadyDispatched :one
-- Idempotency guard for non-idempotent tool dispatch. Reports whether an
-- approved decision_resolved audit already exists for this decision — it is
-- written in the SAME transaction as the tool outcome, after Execute, so a true
-- result means a prior attempt already dispatched and recorded. On a recovery
-- re-run the workflow consults this before Execute and skips the dispatch,
-- closing the at-least-once window between the outcome commit and the DBOS step
-- checkpoint. (The narrower Execute-succeeded-but-tx-uncommitted window is
-- irreducible without a provider-side idempotency key.)
SELECT EXISTS (
  SELECT 1 FROM audit_messages
  WHERE kind = 'decision_resolved'
    AND payload->>'decision_id' = @decision_id::text
    AND payload->>'approved' = 'true'
) AS dispatched;
