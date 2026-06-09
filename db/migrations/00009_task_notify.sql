-- +goose Up
-- Live Tasks view: notify taskChanged subscribers when a task is created or
-- changes (stage advance, state transition, completion). The Phase-0 spine
-- already notifies on pending_decisions / agent_assignments INSERT but never on
-- the tasks row itself, so the 'task' topic — which taskChanged matches — was
-- never emitted by the DB. notify_event() is defined in 00001.

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_task_notify() RETURNS trigger AS $$
BEGIN PERFORM notify_event('task', NEW.id); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER task_notify AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION trg_task_notify();

-- +goose Down
DROP TRIGGER IF EXISTS task_notify ON tasks;
DROP FUNCTION IF EXISTS trg_task_notify();
