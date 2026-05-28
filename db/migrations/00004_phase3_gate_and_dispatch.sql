-- +goose Up

-- Phase 3: universal gate, hard-rule floor, first tool.
--
-- Additive columns on pending_decisions so an ApprovalRequest (kind=
-- approval_request) can carry:
--   - frozen_payload : the exact composed ToolCall payload, byte-for-byte.
--                      What the human sees is what dispatches; no re-screen.
--   - workflow_id    : the DBOS ToolCallWorkflow id awaiting resolution.
--   - decision_topic : the dbos.Send topic the approve/reject resolver
--                      writes to so the awaiting workflow wakes.
--
-- All three columns are NULL for Phase 2 rows (agent_question /
-- promotion_proposal) and remain nullable forever — only approval_request
-- rows are required to populate them.

ALTER TABLE pending_decisions
  ADD COLUMN frozen_payload jsonb,
  ADD COLUMN workflow_id    text,
  ADD COLUMN decision_topic text;

-- +goose Down

ALTER TABLE pending_decisions
  DROP COLUMN IF EXISTS decision_topic,
  DROP COLUMN IF EXISTS workflow_id,
  DROP COLUMN IF EXISTS frozen_payload;
