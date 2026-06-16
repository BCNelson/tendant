-- +goose Up

-- HITL timeout overhaul: explicit, per-flow handling of an expired human wait.
--
-- One additive nullable column on pending_decisions:
--   notify_workflow_id : the DBOS workflow id (e.g. an AgentStageWorkflow,
--                        "agentstage:<taskID>:<stage>") that is durably waiting
--                        for this decision's outcome on a back-channel topic
--                        ("tooloutcome:<decisionID>"). When set, the tool-call
--                        workflow's dispatch step dbos.Sends the final outcome
--                        (clean | bad | rejected | expired) here so the waiting
--                        agent loop can react inline. NULL for human-initiated
--                        approvals (proposeToolCall) where no agent is waiting,
--                        and for all non-approval decision kinds.
--
-- No decision_kind enum change. No audit_messages.task_id-NULL CHECK-allowlist
-- change: the two new audit kinds (decision_expired, stage_timeout_rerouted)
-- are task-scoped — every human wait belongs to a task — so they satisfy the
-- migration-00006 CHECK like every other task-scoped kind.

ALTER TABLE pending_decisions
  ADD COLUMN notify_workflow_id text;

-- +goose Down

ALTER TABLE pending_decisions
  DROP COLUMN IF EXISTS notify_workflow_id;
