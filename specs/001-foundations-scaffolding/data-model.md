# Data Model: Phase 0 — Foundations & Scaffolding

Source: v2 spec **Appendix A** (Postgres DDL) and **§5** (ER). The full schema lands now in a
single first migration even though most tables are unused this phase — the FKs and ordering
are easier to get right once.

## Entities & relationships

```
PRINCIPAL ──< AUDIT_MESSAGE (from/to, by global_uri text)
TASK ──o| CHAIN_WORKFLOW            (nullable; ≤1 live per task)
TASK ──< AUDIT_MESSAGE / PENDING_DECISION / AGENT_ASSIGNMENT / TOOL_OUTCOME
TASK }o──|| INTAKE_SIGNAL           (nullable; intake-born tasks)
CONNECTOR_CONFIG ──< INTAKE_SIGNAL ; CONNECTOR_CONFIG ──|| SOURCE_CREDENTIALS
TOOL ──o| GATE_SCRIPT (nullable) ; TOOL ──< TOOL_OUTCOME ; TOOL ──< PENDING_DECISION
AGENT_CONFIG (catalog) ; DEVICE_TOKEN ──>| PRINCIPAL
AUDIT_MESSAGE ──o| AUDIT_MESSAGE   (in_reply_to self-FK → the DAG)
```

### Invariants enforced structurally
- **P1** — `tasks` has **no `autonomy` column** (emergent; resolved on read in GraphQL).
- **P2** — `tasks` and `chain_workflows` are separate; the link is nullable, and a **partial
  unique index** `idx_chainwf_task_live ... WHERE ended_at IS NULL` allows ≤1 live workflow
  per task.
- **VI / CC-1** — `audit_messages.in_reply_to uuid REFERENCES audit_messages(id)` → message-
  shaped DAG from day one.
- **VIII** — `global_uri` on `principals`, `tasks`, `tools`.
- **§7.5** — `tool_outcomes.matured_at` supports the promotion maturation window.
- **§11.5** — IDs-only `pg_notify` on `tendant_events` via triggers (8 KB cap → IDs only).

### FK ordering (migration must create in this order)
`principals` → `connector_configs` → `source_credentials` → `intake_signals` →
`agent_configs` → `tasks` (FK to `intake_signals`) → `chain_workflows` → `tools` →
`gate_scripts` → `pending_decisions` → `agent_assignments` → `audit_messages` →
`tool_outcomes` → `device_tokens`. Down drops in reverse, then functions/triggers, then enums.

### sqlc type overrides (see `sqlc.yaml`)
`uuid → github.com/google/uuid.UUID` · `jsonb → encoding/json.RawMessage` ·
`timestamptz → time.Time`. `global_uri` form: `local://principal/<id>`, `local://task/<id>`, etc.

---

## First migration — `db/migrations/00001_v2_ddl_spine.sql`

> plpgsql function bodies are wrapped in `-- +goose StatementBegin/StatementEnd` (internal
> semicolons). `CREATE TYPE`/`CREATE TRIGGER`/`CREATE TABLE` are not wrapped.

```sql
-- +goose Up

-- Enums -------------------------------------------------------------------
CREATE TYPE task_state       AS ENUM ('proposed','accepted','eligible','executing','done','dismissed','halted');
CREATE TYPE chain_stage      AS ENUM ('creation','triage','expansion','execution','completion');
CREATE TYPE device_platform  AS ENUM ('ios','android','web');
CREATE TYPE decision_kind    AS ENUM ('approval_request','agent_question','promotion_proposal');
CREATE TYPE tool_outcome_kind AS ENUM ('clean','bad');
CREATE TYPE signal_disposition AS ENUM ('forced_task','rich_event','llm_judge');
CREATE TYPE agent_stage      AS ENUM ('triage','expansion','execution');
CREATE TYPE config_origin    AS ENUM ('core','community');

-- Principals --------------------------------------------------------------
CREATE TABLE principals (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  global_uri   text NOT NULL UNIQUE,
  kind         text NOT NULL CHECK (kind IN ('user','bot')),
  display_name text NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- Intake: connectors, credentials, signals --------------------------------
CREATE TABLE connector_configs (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  connector_type    text NOT NULL,
  filter            jsonb NOT NULL DEFAULT '{}',
  schedule          text,
  disposition_rules jsonb NOT NULL DEFAULT '{}',
  enabled           boolean NOT NULL DEFAULT true,
  created_at        timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE source_credentials (
  connector_id uuid PRIMARY KEY REFERENCES connector_configs(id) ON DELETE CASCADE,
  encrypted    bytea NOT NULL,                    -- app-encrypted at rest (AES-256-GCM, research §7)
  expires_at   timestamptz
);
CREATE TABLE intake_signals (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  signal_version  text NOT NULL,
  connector_id    uuid REFERENCES connector_configs(id),
  idempotency_key text NOT NULL,
  provenance      jsonb NOT NULL,
  payload         jsonb NOT NULL,
  disposition     signal_disposition NOT NULL,
  confidence      double precision,
  stakes_hint     double precision,
  created_at      timestamptz NOT NULL DEFAULT now(),
  processed_at    timestamptz,
  UNIQUE (connector_id, idempotency_key)
);

-- Agent catalog -----------------------------------------------------------
CREATE TABLE agent_configs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  stage         agent_stage NOT NULL,
  is_human      boolean NOT NULL DEFAULT false,
  system_prompt text,
  model         text,
  tool_allowlist jsonb NOT NULL DEFAULT '[]',
  eligibility   jsonb NOT NULL DEFAULT '{}',
  origin        config_origin NOT NULL DEFAULT 'core',
  version       int NOT NULL DEFAULT 1
);

-- Tasks: durable record, decoupled from any workflow (P2) -----------------
CREATE TABLE tasks (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  global_uri    text NOT NULL UNIQUE,
  title         text NOT NULL,
  description   text,
  state         task_state NOT NULL DEFAULT 'eligible',
  current_stage chain_stage NOT NULL DEFAULT 'creation',
  provenance    jsonb,
  context_refs  jsonb NOT NULL DEFAULT '{}',
  findings      jsonb NOT NULL DEFAULT '{}',
  intake_signal_id uuid REFERENCES intake_signals(id),
  created_at    timestamptz NOT NULL DEFAULT now(),
  edited_at     timestamptz
  -- NOTE: no stored autonomy column — emergent (P1)
);
CREATE INDEX idx_tasks_state ON tasks(state);

CREATE TABLE chain_workflows (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id          uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  dbos_workflow_id text NOT NULL,
  status           text NOT NULL DEFAULT 'running',
  started_at       timestamptz NOT NULL DEFAULT now(),
  ended_at         timestamptz
);
CREATE UNIQUE INDEX idx_chainwf_task_live ON chain_workflows(task_id) WHERE ended_at IS NULL;

-- Action edge: tools + scripts --------------------------------------------
CREATE TABLE tools (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  global_uri            text NOT NULL UNIQUE,
  name                  text NOT NULL,
  rung                  text NOT NULL DEFAULT 'execute_gated',
  permissions           jsonb NOT NULL DEFAULT '{}',
  overseer_instructions text                                    -- owner-authored ONLY
);
CREATE TABLE gate_scripts (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id    uuid NOT NULL REFERENCES tools(id) ON DELETE CASCADE,
  version    int  NOT NULL,
  wasm       bytea NOT NULL,
  source     text,
  manifest   jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tool_id, version)
);

-- Inbox: decisions + assignments ------------------------------------------
CREATE TABLE pending_decisions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id     uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  tool_id     uuid REFERENCES tools(id),
  kind        decision_kind NOT NULL,
  payload     jsonb NOT NULL,
  disclosure_class text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  resolution  jsonb
);
CREATE INDEX idx_pending_open ON pending_decisions(task_id) WHERE resolved_at IS NULL;

CREATE TABLE agent_assignments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id          uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  stage            chain_stage NOT NULL,
  from_principal   text,                            -- null = owner-authored
  ask              text NOT NULL,
  gathered_context jsonb NOT NULL DEFAULT '{}',
  created_at       timestamptz NOT NULL DEFAULT now(),
  resolved_at      timestamptz
);
CREATE INDEX idx_assign_open ON agent_assignments(task_id) WHERE resolved_at IS NULL;

-- Audit DAG (CC-1) --------------------------------------------------------
CREATE TABLE audit_messages (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id        uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  from_principal text NOT NULL,
  to_principal   text,
  in_reply_to    uuid REFERENCES audit_messages(id),
  kind           text NOT NULL,
  payload        jsonb NOT NULL,
  at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_task ON audit_messages(task_id, at);
CREATE INDEX idx_audit_parent ON audit_messages(in_reply_to);

-- Calibration ledger (maturation window, §7.5) ----------------------------
CREATE TABLE tool_outcomes (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id    uuid NOT NULL REFERENCES tools(id) ON DELETE CASCADE,
  task_id    uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  outcome    tool_outcome_kind NOT NULL DEFAULT 'clean',
  at         timestamptz NOT NULL DEFAULT now(),
  matured_at timestamptz
);
CREATE INDEX idx_outcomes_tool ON tool_outcomes(tool_id, matured_at);

CREATE TABLE device_tokens (
  token      text PRIMARY KEY,
  owner_id   uuid NOT NULL REFERENCES principals(id) ON DELETE CASCADE,
  platform   device_platform NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Transition notify (IDs-only) for the operator edge ----------------------
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION notify_event(topic text, id uuid) RETURNS void AS $$
BEGIN
  PERFORM pg_notify('tendant_events',
    json_build_object('topic', topic, 'data', json_build_object('id', id))::text);
END; $$ LANGUAGE plpgsql;
-- +goose StatementEnd

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

-- +goose Down
DROP TRIGGER IF EXISTS assign_notify ON agent_assignments;
DROP TRIGGER IF EXISTS pending_notify ON pending_decisions;
DROP FUNCTION IF EXISTS trg_assign_notify();
DROP FUNCTION IF EXISTS trg_pending_notify();
DROP FUNCTION IF EXISTS notify_event(text, uuid);

DROP TABLE IF EXISTS device_tokens;
DROP TABLE IF EXISTS tool_outcomes;
DROP TABLE IF EXISTS audit_messages;
DROP TABLE IF EXISTS agent_assignments;
DROP TABLE IF EXISTS pending_decisions;
DROP TABLE IF EXISTS gate_scripts;
DROP TABLE IF EXISTS tools;
DROP TABLE IF EXISTS chain_workflows;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS agent_configs;
DROP TABLE IF EXISTS intake_signals;
DROP TABLE IF EXISTS source_credentials;
DROP TABLE IF EXISTS connector_configs;
DROP TABLE IF EXISTS principals;

DROP TYPE IF EXISTS config_origin;
DROP TYPE IF EXISTS agent_stage;
DROP TYPE IF EXISTS signal_disposition;
DROP TYPE IF EXISTS tool_outcome_kind;
DROP TYPE IF EXISTS decision_kind;
DROP TYPE IF EXISTS device_platform;
DROP TYPE IF EXISTS chain_stage;
DROP TYPE IF EXISTS task_state;
```

## Seed (idempotent, on startup)

One owner `Principal` returned by `viewer`:

```sql
INSERT INTO principals (global_uri, kind, display_name)
VALUES ('local://principal/owner', 'user', 'Owner')
ON CONFLICT (global_uri) DO NOTHING;
```

`global_uri` for a created task: `local://task/<uuid>` (set at insert time in `internal/core`).

## State / stage values (for GraphQL enum mapping)

- `task_state` → `TaskState { PROPOSED ACCEPTED ELIGIBLE EXECUTING DONE DISMISSED HALTED }`
- `chain_stage` → `ChainStage { CREATION TRIAGE EXPANSION EXECUTION COMPLETION }`
- `AutonomyLevel { NONE ENRICH_ONLY PROPOSE EXECUTE_GATED EXECUTE_AUTO }` — **computed** in
  the `Task.autonomy` resolver (Phase 0: return the fixed default `NONE`;
  the real readout is P1, Phase 1+). No DB column.
