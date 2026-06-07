-- Phase 8 calibration queries. The trust-score + grant mutations are serialized
-- via GetToolForUpdate (row lock) so concurrent outcomes near a band boundary
-- never lose an update.

-- name: GetToolForUpdate :one
-- Row-lock a tool for a serialized read-modify-write of trust_score / grants.
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score
FROM tools
WHERE id = $1
FOR UPDATE;

-- name: GetTrustScore :one
SELECT trust_score FROM tools WHERE id = $1;

-- name: SetTrustScore :one
-- Set the continuous score and keep the rung text cache in sync (band string).
UPDATE tools
   SET trust_score = $2,
       rung        = $3
 WHERE id = $1
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score;

-- name: MaturedCleanRatioByRoutine :one
-- Over the last N matured outcomes for a (tool, fingerprint): clean and total.
WITH recent AS (
  SELECT outcome
  FROM tool_outcomes
  WHERE tool_id = $1
    AND routine_fingerprint = $2
    AND matured_at IS NOT NULL
    AND matured_at <= now()
  ORDER BY at DESC
  LIMIT sqlc.arg('window_n')::int
)
SELECT
  COUNT(*)::int AS total,
  COUNT(*) FILTER (WHERE outcome = 'clean')::int AS clean
FROM recent;

-- name: LatestMaturedOutcomeForRoutine :one
-- The representative task (most-recent matured-clean outcome's task) + its
-- maturation timestamp (used for the decline-cooldown check).
SELECT task_id, at, matured_at
FROM tool_outcomes
WHERE tool_id = $1
  AND routine_fingerprint = $2
  AND matured_at IS NOT NULL
  AND matured_at <= now()
  AND outcome = 'clean'
ORDER BY at DESC
LIMIT 1;

-- name: CandidateRoutinesForSweep :many
-- Distinct (tool, fingerprint) groups with at least one matured outcome — the
-- sweep's work-list. Bounded by O(tools × routines).
SELECT tool_id, routine_fingerprint
FROM tool_outcomes
WHERE routine_fingerprint IS NOT NULL
  AND matured_at IS NOT NULL
  AND matured_at <= now()
GROUP BY tool_id, routine_fingerprint;

-- name: InsertRoutineGrant :one
INSERT INTO tool_routine_grants (tool_id, routine_fingerprint, evidence, granted_by)
VALUES ($1, $2, $3, $4)
RETURNING id, tool_id, routine_fingerprint, evidence, granted_by, granted_at, revoked_at;

-- name: RevokeRoutineGrant :exec
UPDATE tool_routine_grants
   SET revoked_at = now()
 WHERE tool_id = $1
   AND routine_fingerprint = $2
   AND revoked_at IS NULL;

-- name: RevokeAllGrantsForTool :exec
UPDATE tool_routine_grants
   SET revoked_at = now()
 WHERE tool_id = $1
   AND revoked_at IS NULL;

-- name: LiveGrantExists :one
SELECT EXISTS (
  SELECT 1 FROM tool_routine_grants
  WHERE tool_id = $1
    AND routine_fingerprint = $2
    AND revoked_at IS NULL
) AS exists;

-- name: OpenPromotionProposal :one
-- The open (unresolved) promotion_proposal for a (tool, fingerprint), if any.
-- The fingerprint is matched against the frozen payload's routine_fingerprint.
SELECT id, task_id, tool_id, kind, payload, created_at
FROM pending_decisions
WHERE tool_id = $1
  AND kind = 'promotion_proposal'
  AND resolved_at IS NULL
  AND payload->>'routine_fingerprint' = sqlc.arg('routine_fingerprint')::text
ORDER BY created_at DESC
LIMIT 1;

-- name: OpenPromotionProposalsForTool :many
-- All open promotion proposals for a tool — withdrawn on demotion (FR-014).
SELECT id, task_id, tool_id, kind, payload, created_at
FROM pending_decisions
WHERE tool_id = $1
  AND kind = 'promotion_proposal'
  AND resolved_at IS NULL;

-- name: InsertPromotionProposal :one
-- The sweep writes a promotion_proposal pending_decisions row at a caller-
-- supplied id (so the audit can reference it). The AFTER INSERT trigger
-- pg_notify's tendant_events so the inbox surfaces it.
INSERT INTO pending_decisions (id, task_id, tool_id, kind, payload)
VALUES ($1, $2, $3, 'promotion_proposal', $4)
RETURNING id, task_id, tool_id, kind, payload, created_at;

-- name: LatestDeclinedPromotionAt :one
-- The most-recent declined proposal's resolution time for a (tool, fingerprint)
-- — backs the decline-cooldown (no re-propose until a NEW matured outcome).
SELECT resolved_at
FROM pending_decisions
WHERE tool_id = $1
  AND kind = 'promotion_proposal'
  AND resolved_at IS NOT NULL
  AND resolution->>'accepted' = 'false'
  AND payload->>'routine_fingerprint' = sqlc.arg('routine_fingerprint')::text
ORDER BY resolved_at DESC
LIMIT 1;

-- name: LatestOutcomeForToolTask :one
-- The routine fingerprint of the most-recent outcome a tool recorded under a
-- task — the "affected routine" for owner flagOutcome.
SELECT routine_fingerprint
FROM tool_outcomes
WHERE tool_id = $1 AND task_id = $2
ORDER BY at DESC
LIMIT 1;

-- name: CountOpenPromotionProposals :one
SELECT COUNT(*)::int AS n
FROM pending_decisions
WHERE kind = 'promotion_proposal' AND resolved_at IS NULL;

-- name: ToolsActedUnderTask :many
-- Distinct tools that recorded an outcome under a task — the cancel-demotion
-- work-list.
SELECT DISTINCT tool_id
FROM tool_outcomes
WHERE task_id = $1;

-- name: DismissalsByConnector :many
-- Dismissed intake-origin tasks attributable to a connector, newest first, with
-- the owner-supplied dismissal reason (from the state_transition audit). Backs
-- intake threshold-tightening + the [DISMISSAL_HISTORY] triage section.
SELECT t.id AS task_id,
       am.payload->>'reason' AS reason,
       am.at AS dismissed_at
FROM tasks t
JOIN intake_signals s ON t.intake_signal_id = s.id
JOIN audit_messages am ON am.task_id = t.id
  AND am.kind = 'state_transition'
  AND am.payload->>'to' = 'dismissed'
WHERE s.connector_id = $1
  AND am.at >= $2
ORDER BY am.at DESC;
