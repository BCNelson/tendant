-- +goose Up
-- Post-Completion Task Feedback. Adds a fourth decision_kind so a completed
-- task's feedback questions ride the existing pending_decisions surface (and
-- thus the unified inbox + realtime LISTEN/NOTIFY) with no new table. Questions
-- live in pending_decisions.payload; submitted answers land in .resolution.
--
-- No audit_messages.task_id-NULL CHECK allowlist change: both new audit kinds
-- (feedback_questions_generated, feedback_submitted) are task-scoped.
--
-- ADD VALUE ... IF NOT EXISTS is transaction-safe on PostgreSQL 12+ (the value
-- is simply not usable in the SAME transaction; we only declare it here).

ALTER TYPE decision_kind ADD VALUE IF NOT EXISTS 'feedback_request';

-- +goose Down
-- PostgreSQL has no DROP VALUE for an enum; leaving 'feedback_request' in place
-- is harmless (no rows reference it once feedback decisions are removed).
