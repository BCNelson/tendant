-- +goose Up
-- Short, human-facing task numbers (#1, #2, …) distinct from the uuid primary
-- key. The uuid stays the stable, globally-unique identity used by every FK and
-- the global_uri; short_id is a per-instance monotonic counter for display and
-- quick reference (e.g. "task 42"). Backed by an owned sequence so new inserts
-- get the next number automatically via the column DEFAULT.

ALTER TABLE tasks ADD COLUMN short_id bigint;

-- Backfill existing rows in creation order so the oldest task is #1.
-- +goose StatementBegin
WITH ordered AS (
  SELECT id, row_number() OVER (ORDER BY created_at, id) AS rn
  FROM tasks
)
UPDATE tasks t
   SET short_id = ordered.rn
  FROM ordered
 WHERE t.id = ordered.id;
-- +goose StatementEnd

-- Sequence drives new inserts; start it just above the backfilled maximum.
CREATE SEQUENCE tasks_short_id_seq OWNED BY tasks.short_id;
SELECT setval('tasks_short_id_seq', COALESCE((SELECT max(short_id) FROM tasks), 0) + 1, false);

ALTER TABLE tasks ALTER COLUMN short_id SET DEFAULT nextval('tasks_short_id_seq');
ALTER TABLE tasks ALTER COLUMN short_id SET NOT NULL;
ALTER TABLE tasks ADD CONSTRAINT tasks_short_id_key UNIQUE (short_id);

-- +goose Down
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_short_id_key;
ALTER TABLE tasks DROP COLUMN IF EXISTS short_id;
DROP SEQUENCE IF EXISTS tasks_short_id_seq;
