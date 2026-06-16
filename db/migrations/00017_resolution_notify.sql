-- +goose Up
-- Make realtime event emission a DATABASE INVARIANT rather than a per-code-path
-- responsibility. Before this migration, `tasks` emitted on INSERT+UPDATE (00009)
-- but `pending_decisions` and `agent_assignments` emitted on INSERT ONLY (00001),
-- so resolving a decision / resolving an assignment / reassigning to_principal —
-- all UPDATEs — fired no event, leaving acted-on items stuck in the client inbox.
--
-- Replace the three bespoke INSERT-only/partial trigger functions with ONE generic
-- function parameterised by topic, fired AFTER INSERT OR UPDATE OR DELETE on every
-- UI-relevant table. Triggers run inside the mutating transaction, so pg_notify is
-- delivered atomically at COMMIT: every committed change emits exactly one event,
-- a rolled-back one emits none, and no code path can mutate a watched row without
-- emitting. notify_event() is defined in 00001.

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_notify_change() RETURNS trigger AS $$
BEGIN
  PERFORM notify_event(TG_ARGV[0], COALESCE(NEW.id, OLD.id));
  RETURN COALESCE(NEW, OLD);
END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- Drop the legacy triggers + their single-purpose functions.
DROP TRIGGER IF EXISTS task_notify ON tasks;
DROP TRIGGER IF EXISTS pending_notify ON pending_decisions;
DROP TRIGGER IF EXISTS assign_notify ON agent_assignments;
DROP FUNCTION IF EXISTS trg_task_notify();
DROP FUNCTION IF EXISTS trg_pending_notify();
DROP FUNCTION IF EXISTS trg_assign_notify();

-- One uniform trigger per watched table.
CREATE TRIGGER tasks_change AFTER INSERT OR UPDATE OR DELETE ON tasks
  FOR EACH ROW EXECUTE FUNCTION trg_notify_change('task');
CREATE TRIGGER decisions_change AFTER INSERT OR UPDATE OR DELETE ON pending_decisions
  FOR EACH ROW EXECUTE FUNCTION trg_notify_change('decision');
CREATE TRIGGER assignments_change AFTER INSERT OR UPDATE OR DELETE ON agent_assignments
  FOR EACH ROW EXECUTE FUNCTION trg_notify_change('assignment');

-- +goose Down
DROP TRIGGER IF EXISTS tasks_change ON tasks;
DROP TRIGGER IF EXISTS decisions_change ON pending_decisions;
DROP TRIGGER IF EXISTS assignments_change ON agent_assignments;
DROP FUNCTION IF EXISTS trg_notify_change();

-- Restore the legacy trigger functions + triggers (00001 + 00009 shape).
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_task_notify() RETURNS trigger AS $$
BEGIN PERFORM notify_event('task', NEW.id); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER task_notify AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION trg_task_notify();

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_pending_notify() RETURNS trigger AS $$
BEGIN PERFORM notify_event('decision', NEW.id); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER pending_notify AFTER INSERT ON pending_decisions
  FOR EACH ROW EXECUTE FUNCTION trg_pending_notify();

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_assign_notify() RETURNS trigger AS $$
BEGIN PERFORM notify_event('assignment', NEW.id); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd
CREATE TRIGGER assign_notify AFTER INSERT ON agent_assignments
  FOR EACH ROW EXECUTE FUNCTION trg_assign_notify();
