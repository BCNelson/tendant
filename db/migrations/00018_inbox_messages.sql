-- +goose Up
-- Promote the inbox from a derived UNION-ALL view to a first-class table.
--
-- Before this migration the inbox existed only as a query: a UNION ALL over
-- open pending_decisions + open agent_assignments + PROPOSED tasks, re-derived
-- on every read (queries/inbox.sql). That had two costs the product now needs
-- to pay down:
--   1. there was nowhere to store PER-MESSAGE state (read / seen / dismissed /
--      snoozed) — the inbox could only ever reflect the source row's lifecycle;
--   2. adding a new inbox message TYPE meant editing the UNION SQL + the Go
--      assemble path + the resolver, rather than just inserting a row.
--
-- inbox_messages is the spine. Its `id` is the SAME uuid as the source row it
-- projects (a pending_decision / agent_assignment / proposed task), so every
-- existing resolver that fetches an item by its id keeps working unchanged and
-- the GraphQL InboxEntry.item resolution is untouched. `message_type` is the
-- single fine-grained discriminator the UI dispatches a detail page on
-- (approval_request | agent_question | promotion_proposal | feedback_request |
-- agent_assignment | actionable_task | …future pure-notification kinds).
--
-- The table is kept in lock-step with the three source tables by a projection
-- trigger (trg_inbox_project) firing INSIDE the mutating transaction, the same
-- discipline migration 00017 established for pg_notify: every committed change
-- to a watched row projects exactly one inbox_messages row; a rollback projects
-- none. Membership that depends on task.state (the actionable-only terminal
-- guard, the feedback_request post-completion exception, PROPOSED tasks) is left
-- to the read query — the trigger only owns row identity + resolved_at, so a
-- task state change never has to cascade across tables here.

CREATE TABLE inbox_messages (
  -- Mirrors the projected source row's id (1:1) so item resolution is unchanged.
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Provenance — 'pending_decisions' | 'agent_assignments' | 'tasks'. NULL is
  -- reserved for future source-less pure notifications.
  source_table  text,
  -- The UI's dispatch discriminator. Free text (not an enum) so a new message
  -- type is an insert, never a schema migration.
  message_type  text NOT NULL,
  -- Routing: NULL = owner / everyone (decisions, proposed tasks); a principal
  -- global-uri scopes the message to one recipient (agent_assignments).
  recipient     text,
  -- Context the message hangs off. NOT NULL today (every message type is
  -- task-scoped and the feed inner-joins tasks); relax when a task-less
  -- notification type is introduced.
  task_id       uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  created_at    timestamptz NOT NULL DEFAULT now(),
  -- Mirrors the source row's resolved_at: non-NULL ⇒ the action is done and the
  -- message leaves the active inbox.
  resolved_at   timestamptz,
  -- Per-message state — the headline reason this is a table and not a view.
  seen_at       timestamptz,
  read_at       timestamptz,
  dismissed_at  timestamptz,
  snoozed_until timestamptz,
  -- Optional render hints for source-less notification types; existing types
  -- resolve their detail from the source row, so this stays NULL for them.
  payload       jsonb
);

-- Active-inbox scan: chronological keyset over open, undismissed messages.
CREATE INDEX idx_inbox_active ON inbox_messages (created_at DESC, id DESC)
  WHERE resolved_at IS NULL AND dismissed_at IS NULL;
-- Recipient-scoped lookups (assignment fan-out).
CREATE INDEX idx_inbox_recipient ON inbox_messages (recipient)
  WHERE resolved_at IS NULL AND dismissed_at IS NULL;
-- Type filtering / counts ("how many approvals are open?").
CREATE INDEX idx_inbox_type ON inbox_messages (message_type)
  WHERE resolved_at IS NULL AND dismissed_at IS NULL;

-- Generic projection trigger. Derives message_type / recipient / task_id /
-- resolved_at from the firing table, then upserts (keyed on the shared id).
-- ON CONFLICT keeps per-message state (read/seen/dismissed) intact — only the
-- source-derived columns are refreshed.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION trg_inbox_project() RETURNS trigger AS $$
DECLARE
  v_type      text;
  v_recipient text;
  v_task_id   uuid;
  v_resolved  timestamptz;
  v_created   timestamptz;
BEGIN
  IF TG_TABLE_NAME = 'pending_decisions' THEN
    v_type := NEW.kind::text;
    v_recipient := NULL;
    v_task_id := NEW.task_id;
    v_resolved := NEW.resolved_at;
    v_created := NEW.created_at;
  ELSIF TG_TABLE_NAME = 'agent_assignments' THEN
    v_type := 'agent_assignment';
    v_recipient := NEW.to_principal;
    v_task_id := NEW.task_id;
    v_resolved := NEW.resolved_at;
    v_created := NEW.created_at;
  ELSIF TG_TABLE_NAME = 'tasks' THEN
    -- A task is in the inbox only while PROPOSED (the owner accept/dismiss item).
    IF NEW.state = 'proposed' THEN
      v_type := 'actionable_task';
      v_recipient := NULL;
      v_task_id := NEW.id;
      v_resolved := NULL;
      v_created := NEW.created_at;
    ELSE
      -- Left (or never entered) PROPOSED: resolve any projected actionable row.
      UPDATE inbox_messages
         SET resolved_at = COALESCE(resolved_at, now())
       WHERE id = NEW.id AND source_table = 'tasks' AND resolved_at IS NULL;
      RETURN NEW;
    END IF;
  ELSE
    RETURN NEW;
  END IF;

  INSERT INTO inbox_messages
    (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
  VALUES
    (NEW.id, TG_TABLE_NAME, v_type, v_recipient, v_task_id, v_created, v_resolved)
  ON CONFLICT (id) DO UPDATE
    SET message_type = EXCLUDED.message_type,
        recipient    = EXCLUDED.recipient,
        resolved_at  = EXCLUDED.resolved_at;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER decisions_inbox_project AFTER INSERT OR UPDATE ON pending_decisions
  FOR EACH ROW EXECUTE FUNCTION trg_inbox_project();
CREATE TRIGGER assignments_inbox_project AFTER INSERT OR UPDATE ON agent_assignments
  FOR EACH ROW EXECUTE FUNCTION trg_inbox_project();
CREATE TRIGGER tasks_inbox_project AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION trg_inbox_project();

-- Backfill the existing open inbox from the three sources.
INSERT INTO inbox_messages
  (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
SELECT id, 'pending_decisions', kind::text, NULL, task_id, created_at, resolved_at
  FROM pending_decisions
ON CONFLICT (id) DO NOTHING;

INSERT INTO inbox_messages
  (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
SELECT id, 'agent_assignments', 'agent_assignment', to_principal, task_id, created_at, resolved_at
  FROM agent_assignments
ON CONFLICT (id) DO NOTHING;

INSERT INTO inbox_messages
  (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
SELECT id, 'tasks', 'actionable_task', NULL, id, created_at, NULL
  FROM tasks
 WHERE state = 'proposed'
ON CONFLICT (id) DO NOTHING;

-- +goose Down
DROP TRIGGER IF EXISTS decisions_inbox_project ON pending_decisions;
DROP TRIGGER IF EXISTS assignments_inbox_project ON agent_assignments;
DROP TRIGGER IF EXISTS tasks_inbox_project ON tasks;
DROP FUNCTION IF EXISTS trg_inbox_project();
DROP TABLE IF EXISTS inbox_messages;
