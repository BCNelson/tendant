-- +goose Up
-- Inbox ranked feed (Phase: inbox-ranked-feed). The feed now absorbs PROPOSED
-- tasks as first-class actionable items (accept/dismiss), so the union scans
-- tasks WHERE state = 'proposed' on every page. A partial index keeps that
-- branch cheap. The open-decision / routed-assignment branches are already
-- covered by idx_pending_open, idx_assign_open, idx_assign_to_principal
-- (00001 / 00003); no columns are added — priority/due_at (00014) and
-- intake_signals.stakes_hint (00001) already exist.

CREATE INDEX idx_tasks_proposed ON tasks(created_at, id) WHERE state = 'proposed';

-- +goose Down
DROP INDEX idx_tasks_proposed;
