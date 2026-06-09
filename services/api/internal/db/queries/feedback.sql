-- name: InsertFeedbackMessage :one
-- Append one turn to a feedback conversation. role is 'agent' or 'user'.
INSERT INTO feedback_messages (decision_id, role, content)
VALUES ($1, $2, $3)
RETURNING id, decision_id, role, content, created_at;

-- name: ListFeedbackMessages :many
-- The full thread for a FeedbackRequest, oldest-first.
SELECT id, decision_id, role, content, created_at
FROM feedback_messages
WHERE decision_id = $1
ORDER BY created_at ASC, id ASC;

-- name: SetFeedbackDecisionPayload :exec
-- Overwrite a feedback_request decision's payload (carries draft_guidance +
-- task_summary). Only touches an unresolved feedback decision.
UPDATE pending_decisions
   SET payload = $2
 WHERE id = $1
   AND kind = 'feedback_request'
   AND resolved_at IS NULL;
