-- +goose Up
-- Conversational feedback. Each post-completion FeedbackRequest is a chat
-- thread between the agent and the owner, stored here keyed by the decision id
-- (pending_decisions.id). The agent opens; the owner and agent exchange turns;
-- the owner accepts a final guidance text (stored verbatim in agent_guidance).
-- The current agent-proposed draft rides pending_decisions.payload.draft_guidance.

CREATE TABLE feedback_messages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  decision_id uuid NOT NULL REFERENCES pending_decisions(id) ON DELETE CASCADE,
  role        text NOT NULL CHECK (role IN ('agent', 'user')),
  content     text NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_feedback_messages_thread
  ON feedback_messages (decision_id, created_at, id);

-- +goose Down
DROP TABLE IF EXISTS feedback_messages;
