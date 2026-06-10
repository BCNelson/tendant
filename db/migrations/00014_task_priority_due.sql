-- +goose Up
-- Owner-set task metadata: a coarse priority dial and an optional deadline.
-- Both are plain scalar columns on `tasks` (not derived like autonomy/category):
-- priority is owner-authored at compose time and defaults to 'normal' for every
-- existing and intake-origin row; due_at is a nullable deadline. No change to the
-- audit_messages.task_id-NULL CHECK allowlist — these ride the task row itself.

CREATE TYPE task_priority AS ENUM ('low', 'normal', 'high', 'urgent');

ALTER TABLE tasks
  ADD COLUMN priority task_priority NOT NULL DEFAULT 'normal',
  ADD COLUMN due_at   timestamptz;

-- +goose Down
ALTER TABLE tasks
  DROP COLUMN due_at,
  DROP COLUMN priority;

DROP TYPE task_priority;
