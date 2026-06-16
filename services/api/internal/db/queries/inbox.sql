-- name: InsertPendingDecision :one
-- Insert into pending_decisions; trg_pending_notify fires IDs-only pg_notify.
-- Phase 3 adds frozen_payload / workflow_id / decision_topic — populated for
-- kind=approval_request, left null for agent_question / promotion_proposal.
INSERT INTO pending_decisions (
  task_id, tool_id, kind, payload, disclosure_class,
  frozen_payload, workflow_id, decision_topic
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING id;

-- name: ListInbox :many
-- Phase 2 viewer-scoped unified inbox over open pending_decisions and open
-- agent_assignments routed to the viewer. Keyset-paginated by
-- (created_at DESC, id DESC). $1 = viewer globalUri, $2/$3 = cursor
-- (timestamp + uuid), $4 = limit. For an unset cursor pass max-timestamp.
SELECT id, kind, task_id, created_at FROM (
  SELECT id, 'pending_decision'::text AS kind, task_id, created_at
    FROM pending_decisions
    WHERE resolved_at IS NULL
  UNION ALL
  SELECT id, 'agent_assignment'::text AS kind, task_id, created_at
    FROM agent_assignments
    WHERE resolved_at IS NULL AND to_principal = $1
) AS i
WHERE (i.created_at, i.id) < ($2::timestamptz, $3::uuid)
ORDER BY i.created_at DESC, i.id DESC
LIMIT $4;

-- name: ListInboxFeed :many
-- Ranked, keyset-paginated action feed over the first-class inbox_messages
-- spine (migration 00018) — no longer a UNION of the three source tables.
-- inbox_messages.id mirrors the source row id, message_type is the UI's dispatch
-- discriminator, and the per-message read/dismissed state lives on the row.
-- Membership rules that depend on task.state are still applied here (the
-- projection trigger owns only identity + resolved_at):
--   * pending_decisions are shown while their task is non-terminal, with the
--     feedback_request post-completion exception;
--   * agent_assignments are scoped to the viewer + non-terminal task;
--   * actionable_task rows are shown only while the task is PROPOSED.
-- Each row carries a blended urgency `score` over the PINNED clock @now
-- (owner priority + deadline proximity + intake stakes + age). The clock is
-- pinned in the cursor so a whole scroll session ranks against one fixed @now,
-- keeping the (score, id) keyset stable; the next page passes the last row's
-- SQL-returned score as @cursor_score. `kind` is derived from source_table to
-- preserve the legacy assemble vocabulary.
WITH feed AS (
  SELECT m.id,
         CASE m.source_table
           WHEN 'pending_decisions'  THEN 'pending_decision'
           WHEN 'agent_assignments'  THEN 'agent_assignment'
           WHEN 'tasks'              THEN 'task'
           ELSE m.source_table
         END::text AS kind,
         m.message_type, m.task_id, m.created_at, m.read_at, m.dismissed_at,
         t.priority, t.due_at, t.intake_signal_id
    FROM inbox_messages m
    JOIN tasks t ON t.id = m.task_id
   WHERE m.resolved_at IS NULL
     AND m.dismissed_at IS NULL
     AND (m.recipient IS NULL OR m.recipient = sqlc.arg('viewer')::text)
     AND (
          (m.source_table = 'pending_decisions'
             AND (t.state NOT IN ('done', 'dismissed', 'halted')
                  -- feedback_request decisions are post-completion by design, so
                  -- the actionable-only terminal-state guard must not hide them.
                  OR m.message_type = 'feedback_request'))
       OR (m.source_table = 'agent_assignments'
             AND t.state NOT IN ('done', 'dismissed', 'halted'))
       OR (m.source_table = 'tasks' AND t.state = 'proposed')
     )
),
scored AS (
  SELECT f.id, f.kind, f.message_type, f.task_id, f.created_at, f.read_at, f.dismissed_at,
         (
           CASE f.priority
             WHEN 'urgent' THEN 400.0
             WHEN 'high'   THEN 300.0
             WHEN 'normal' THEN 200.0
             WHEN 'low'    THEN 100.0
             ELSE 200.0
           END
           + CASE
               WHEN f.due_at IS NULL THEN 0.0
               WHEN f.due_at <  sqlc.arg('now')::timestamptz THEN 250.0
               WHEN f.due_at <  sqlc.arg('now')::timestamptz + interval '24 hours' THEN 150.0
               WHEN f.due_at <  sqlc.arg('now')::timestamptz + interval '7 days'   THEN 75.0
               ELSE 0.0
             END
           + COALESCE(s.stakes_hint, 0.0) * 100.0
           + LEAST(GREATEST(EXTRACT(EPOCH FROM (sqlc.arg('now')::timestamptz - f.created_at)) / 3600.0, 0.0), 48.0)
         )::double precision AS score
    FROM feed f
    LEFT JOIN intake_signals s ON s.id = f.intake_signal_id
)
-- read_at / dismissed_at surface as pgtype.Timestamptz (sqlc loses the override
-- tracing a nullable column through two CTE hops); the Go layer maps .Valid to a
-- *time.Time. task_id is NOT NULL so it resolves to uuid.UUID.
SELECT id, kind, message_type, task_id, created_at, read_at, dismissed_at, score
  FROM scored
 WHERE (score, id) < (sqlc.arg('cursor_score')::double precision, sqlc.arg('cursor_id')::uuid)
 ORDER BY score DESC, id DESC
 LIMIT sqlc.arg('page_limit')::int;

-- name: ReconcileInboxMessages :one
-- Defense-in-depth drift repair for the first-class inbox_messages projection.
-- The trg_inbox_project triggers keep inbox_messages in lock-step with the three
-- source tables inside each mutating transaction, so this normally repairs 0
-- rows; a non-zero result means a write bypassed the trigger (trigger disabled,
-- bulk COPY/restore, logic regression) and is itself the alarm. Idempotent —
-- inserts only the projections that are missing, mirroring the trigger's own
-- derivation (all decisions + all assignments + PROPOSED tasks). Returns the
-- number of rows repaired this pass.
WITH ins_pd AS (
  INSERT INTO inbox_messages
    (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
  SELECT pd.id, 'pending_decisions', pd.kind::text, NULL, pd.task_id, pd.created_at, pd.resolved_at
    FROM pending_decisions pd
   WHERE NOT EXISTS (SELECT 1 FROM inbox_messages m WHERE m.id = pd.id)
  ON CONFLICT (id) DO NOTHING
  RETURNING 1
),
ins_aa AS (
  INSERT INTO inbox_messages
    (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
  SELECT aa.id, 'agent_assignments', 'agent_assignment', aa.to_principal, aa.task_id, aa.created_at, aa.resolved_at
    FROM agent_assignments aa
   WHERE NOT EXISTS (SELECT 1 FROM inbox_messages m WHERE m.id = aa.id)
  ON CONFLICT (id) DO NOTHING
  RETURNING 1
),
ins_t AS (
  INSERT INTO inbox_messages
    (id, source_table, message_type, recipient, task_id, created_at, resolved_at)
  SELECT t.id, 'tasks', 'actionable_task', NULL, t.id, t.created_at, NULL
    FROM tasks t
   WHERE t.state = 'proposed'
     AND NOT EXISTS (SELECT 1 FROM inbox_messages m WHERE m.id = t.id)
  ON CONFLICT (id) DO NOTHING
  RETURNING 1
)
SELECT (
  (SELECT count(*) FROM ins_pd)
  + (SELECT count(*) FROM ins_aa)
  + (SELECT count(*) FROM ins_t)
)::bigint AS repaired;

-- name: MarkInboxRead :one
-- Stamp read_at (and seen_at) on a viewer's inbox message. Idempotent: a
-- second call keeps the original read_at. Recipient-scoped: a NULL recipient
-- (owner/everyone) is readable by anyone, an assignment only by its recipient.
UPDATE inbox_messages
   SET read_at = COALESCE(read_at, now()),
       seen_at = COALESCE(seen_at, now())
 WHERE id = sqlc.arg('id')
   AND (recipient IS NULL OR recipient = sqlc.arg('viewer')::text)
RETURNING id, seen_at, read_at, dismissed_at;

-- name: DismissInboxMessage :one
-- Soft-dismiss a message from the active inbox without touching the source
-- row's lifecycle. Recipient-scoped like MarkInboxRead.
UPDATE inbox_messages
   SET dismissed_at = COALESCE(dismissed_at, now())
 WHERE id = sqlc.arg('id')
   AND (recipient IS NULL OR recipient = sqlc.arg('viewer')::text)
RETURNING id, seen_at, read_at, dismissed_at;
