-- +goose Up
-- Unify the post-completion feedback agent into the same agent_configs surface
-- the Phase-6 specialists use. The feedback agent is a real agent_configs row
-- (name='feedback', stage='feedback'), reconciled from default_agents/feedback.toml
-- like every other built-in agent, so its system prompt + model are config — not
-- a hardcoded Go constant. The feedback stage is never selected by the chain
-- router (it queries only triage/expansion/execution); the row is consumed solely
-- by the post-completion feedback workflow.
--
-- ADD VALUE ... IF NOT EXISTS is transaction-safe on PostgreSQL 12+ (the value is
-- simply not usable in the SAME transaction; we only declare it here — the seed
-- row is inserted at runtime by ReconcileAgentCatalog, not in this migration).

ALTER TYPE agent_stage ADD VALUE IF NOT EXISTS 'feedback';

-- +goose Down
-- PostgreSQL has no DROP VALUE for an enum; leaving 'feedback' in place is
-- harmless (no rows reference it once any feedback agent_configs row is removed).
