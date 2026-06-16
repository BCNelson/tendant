-- +goose Up
-- Expand the task data model with scheduling + a task↔task relation graph.
--
-- Two new scalar columns on `tasks`:
--   starts_at : optional earliest-start. Gates eligibility — a task cannot leave
--               ACCEPTED for EXECUTING until starts_at has passed (NULL = no gate).
--   rank      : optional manual ordering weight within a priority band. Lower
--               sorts first; nullable so untouched tasks fall back to created_at.
--               (drag-to-reorder writes a midpoint between neighbours).
--
-- One new edge table `task_relations` carrying every directed task↔task relation:
--   blocks       : from_task must reach a terminal state before to_task may
--                  execute (to_task depends-on from_task). Gates eligibility.
--   subtask_of   : from_task is a child of to_task (single parent per child).
--   related      : non-blocking "see also" link (surfaced both directions).
--   duplicate_of : from_task duplicates canonical to_task (single canonical).
--
-- No change to the audit_messages.task_id-NULL CHECK allowlist — relations and
-- scheduling ride the task rows themselves (like priority/due_at in 00014).

ALTER TABLE tasks
  ADD COLUMN starts_at timestamptz,
  ADD COLUMN rank      double precision;

CREATE TYPE task_relation_kind AS ENUM ('blocks', 'subtask_of', 'related', 'duplicate_of');

CREATE TABLE task_relations (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_task  uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  to_task    uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  kind       task_relation_kind NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT task_relation_no_self CHECK (from_task <> to_task),
  CONSTRAINT task_relation_unique  UNIQUE (from_task, to_task, kind)
);

-- Forward (from→) and reverse (→to) traversal, both filtered by kind.
CREATE INDEX idx_task_relations_from ON task_relations (from_task, kind);
CREATE INDEX idx_task_relations_to   ON task_relations (to_task, kind);

-- A task has at most one parent and at most one canonical original.
CREATE UNIQUE INDEX idx_task_relations_one_parent
  ON task_relations (from_task) WHERE kind = 'subtask_of';
CREATE UNIQUE INDEX idx_task_relations_one_canonical
  ON task_relations (from_task) WHERE kind = 'duplicate_of';

-- +goose Down
DROP TABLE IF EXISTS task_relations;
DROP TYPE IF EXISTS task_relation_kind;
ALTER TABLE tasks
  DROP COLUMN IF EXISTS rank,
  DROP COLUMN IF EXISTS starts_at;
