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
-- Ranked, keyset-paginated action feed. Three actionable sources are unioned:
--   * open pending_decisions whose task is non-terminal
--   * open agent_assignments routed to the viewer whose task is non-terminal
--   * PROPOSED tasks (the owner accept/dismiss action item itself)
-- Each row carries a blended urgency `score` over the PINNED clock @now
-- (owner priority + deadline proximity + intake stakes + age). The clock is
-- pinned in the cursor so a whole scroll session ranks against one fixed @now,
-- keeping the (score, id) keyset stable; the next page passes the last row's
-- SQL-returned score as @cursor_score. Weights are first-guess constants — a
-- candidate to move into config_entries later. Visibility filtering (the
-- actionable-only NOT IN (terminal) clause + to_principal scope) is SQL-side.
WITH feed AS (
  SELECT pd.id, 'pending_decision'::text AS kind, pd.task_id, pd.created_at,
         t.priority, t.due_at, t.intake_signal_id
    FROM pending_decisions pd
    JOIN tasks t ON t.id = pd.task_id
   WHERE pd.resolved_at IS NULL
     AND t.state NOT IN ('done', 'dismissed', 'halted')
  UNION ALL
  SELECT aa.id, 'agent_assignment'::text AS kind, aa.task_id, aa.created_at,
         t.priority, t.due_at, t.intake_signal_id
    FROM agent_assignments aa
    JOIN tasks t ON t.id = aa.task_id
   WHERE aa.resolved_at IS NULL
     AND aa.to_principal = sqlc.arg('viewer')::text
     AND t.state NOT IN ('done', 'dismissed', 'halted')
  UNION ALL
  SELECT t.id, 'task'::text AS kind, t.id AS task_id, t.created_at,
         t.priority, t.due_at, t.intake_signal_id
    FROM tasks t
   WHERE t.state = 'proposed'
),
scored AS (
  SELECT f.id, f.kind, f.task_id, f.created_at,
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
SELECT id, kind, task_id, created_at, score
  FROM scored
 WHERE (score, id) < (sqlc.arg('cursor_score')::double precision, sqlc.arg('cursor_id')::uuid)
 ORDER BY score DESC, id DESC
 LIMIT sqlc.arg('page_limit')::int;
