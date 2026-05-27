# Feature Specification: Phase 0 — Foundations & Scaffolding

**Feature Branch**: `001-foundations-scaffolding`
**Created**: 2026-05-25
**Status**: Draft
**Input**: Build-plan entry "Phase 0 — Foundations & Scaffolding" (size M, depends on
nothing). Grounded in `docs/tendant-architecture-spec-v2.md` §2, §5, §11.5, §13, §15 Q4,
Appendix A (DDL), Appendix B (GraphQL SDL), Appendix D (core Go interfaces).

> Stack named here (Postgres, DBOS, GraphQL, Go `gqlgen`/`chi`/`pgx`, embedded Goose,
> Flutter, `go.work`) is the constitution's ratified Technology Constraints, not a choice
> made in this spec. Detailed wiring and any un-ratified decisions belong in `plan.md`
> (constitution §Development Workflow, v1.2.0).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Boot the core with the full schema applied (Priority: P1)

A developer on a clean checkout runs one command and gets a healthy core API process plus a
local Postgres carrying the complete v2 data model — every enum, table, index, function,
and trigger from Appendix A — applied automatically. Tearing down and bringing it back up
yields the same state with no manual fix-ups.

**Why this priority**: Everything downstream hangs off a system that boots and migrates.
Without this, nothing else in any later phase can be built or tested.

**Independent Test**: From a clean working tree, run the boot command; assert the core
reports healthy and that all Appendix A objects exist (enums, the priority tables, the
`notify_event` function, both `AFTER INSERT` triggers). Run teardown, then boot again;
assert success and identical schema.

**Acceptance Scenarios**:
1. **Given** a clean checkout, **When** the boot command runs, **Then** Postgres starts,
   embedded Goose migrations apply the full v2 DDL spine, and the core serves `/graphql`
   and reports healthy.
2. **Given** a booted system, **When** teardown then boot run again, **Then** the sequence
   completes idempotently with the schema in the same state (repeatable up/down).
3. **Given** migrations have already applied, **When** the core restarts, **Then** Goose is
   a no-op (no duplicate/failed migration) and the core comes up healthy.

### User Story 2 - Create and read a Task over GraphQL (Priority: P1)

An API consumer creates a `Task` (and the system's single owner `Principal`), then reads it
back by id and in the task list. Each `Task` and `Principal` carries a stable `globalUri`,
and `Task.autonomy` is a resolved readout rather than a stored field.

**Why this priority**: This round-trip is the phase's headline capability ("create + query
a Task over GraphQL") and proves the core read/write path end-to-end.

**Independent Test**: Seed/create a Task and the owner Principal; query `task(id)` and
`tasks(...)`; assert the task is returned both ways, `globalUri` is non-empty, `state` and
`currentStage` carry their schema defaults, and `viewer` returns the owner `User`.

**Acceptance Scenarios**:
1. **Given** a booted system with the owner Principal seeded, **When** a Task is created via
   the seed/minimal-create path, **Then** the row persists with a `global_uri`,
   `state='eligible'` (or schema default), and `current_stage='creation'`.
2. **Given** a created Task, **When** `task(id)` is queried, **Then** the Task is returned
   with `globalUri`, `state`, `currentStage`, and `autonomy` (resolved, not stored).
3. **Given** one or more created Tasks, **When** `tasks(first, after, state)` is queried,
   **Then** a Relay `TaskConnection` is returned with `edges`, `cursor`s, and `PageInfo`.
4. **Given** the seeded owner, **When** `viewer` is queried, **Then** it returns the owner
   `User` implementing `Principal` with a `globalUri`.

### User Story 3 - Inbox-row inserts fire an IDs-only event (Priority: P2)

When a `pending_decisions` or `agent_assignments` row is inserted, the database emits a
single `pg_notify` on the `tendant_events` channel carrying only `{topic, data:{id}}` — no
record content. This is the transition-notify seam later phases (subscriptions, push) wake
on; only the *triggers* ship now, not the listener.

**Why this priority**: A cheap-now/expensive-later seam the build plan is emphatic about.
The IDs-only shape is forced by the 8 KB NOTIFY cap and is the safer default.

**Independent Test**: `LISTEN tendant_events` from `psql`; `INSERT` a row into
`pending_decisions`; observe exactly one notification whose payload is `{topic:'decision',
data:{id:<uuid>}}` and contains no row content. Repeat for `agent_assignments` →
`topic:'assignment'`.

**Acceptance Scenarios**:
1. **Given** a `LISTEN`er on `tendant_events`, **When** a `pending_decisions` row is
   inserted, **Then** one notification fires with `topic='decision'` carrying only the id.
2. **Given** a `LISTEN`er on `tendant_events`, **When** an `agent_assignments` row is
   inserted, **Then** one notification fires with `topic='assignment'` carrying only the id.
3. **Given** any such insert, **When** the notification is inspected, **Then** the payload
   contains no column values beyond the id (no content leak; within the NOTIFY size cap).

### User Story 4 - Durable execution survives a forced restart (Priority: P2)

A throwaway durable workflow (DBOS over the same Postgres) that checkpoints mid-run resumes
and completes exactly once after the core process is forcibly killed and restarted.

**Why this priority**: Proves crash-recovery semantics on the target box before Phase 1's
chain workflow leans on them. Front-loads the DBOS learning curve.

**Independent Test**: Start a workflow that durably checkpoints, then blocks/pauses; kill
the process; restart; assert the workflow resumes from its last checkpoint and completes
with no lost or duplicated effect.

**Acceptance Scenarios**:
1. **Given** DBOS initialized over Postgres, **When** the core starts, **Then** the engine
   is health-checked and reports ready.
2. **Given** a throwaway workflow checkpointed mid-run, **When** the process is killed and
   restarted, **Then** the workflow resumes and completes exactly once.

### User Story 5 - The foundation cannot regress silently (Priority: P3)

CI catches regressions in the foundation: linting, stale generated code, broken migration
up/down, and a failing create-and-read integration test all fail the build.

**Why this priority**: Guards the invariants the later phases assume. Lower priority than
the runtime capabilities, but part of "done" for foundations.

**Independent Test**: Introduce (in a scratch branch) stale generated code, a broken
down-migration, and a broken create-read test in turn; assert CI fails on each.

**Acceptance Scenarios**:
1. **Given** committed generated code (gqlgen, sqlc; Ferry deferred to Phase 2+), **When** CI regenerates,
   **Then** any drift from committed output fails the build.
2. **Given** the migration set, **When** CI runs up then down then up, **Then** all steps
   succeed or the build fails.
3. **Given** the integration suite, **When** CI runs it, **Then** a test that creates and
   reads a Task (against a real Postgres) must pass.

### Edge Cases

- **Re-run / partial migration**: a restart with migrations already applied is a Goose
  no-op; a partially-applied migration set must not leave the schema half-built.
- **Down→up idempotency**: enums, functions, and triggers must drop and recreate cleanly
  (no "type already exists" / "trigger already exists" on the second up).
- **FK ordering**: `connector_configs` / `intake_signals` must exist before `tasks`
  (the `intake_signal_id` FK), per Appendix A's ordering note.
- **NOTIFY cap**: inserts must never emit more than the id; an oversized payload would
  exceed the 8 KB cap — the IDs-only shape structurally prevents this.
- **Crash between checkpoint and commit**: the workflow resumes from the last durable step
  with exactly-once completion (no double effect).
- **Task with no owner column**: the schema has no `tasks.owner` FK; the single owner is a
  seeded `Principal` surfaced via `viewer` (auth/ownership linkage is Phase 2).

## Requirements *(mandatory)*

### Functional Requirements

**Monorepo & boot**
- **FR-001**: The repository MUST be a `go.work` monorepo with members `services/api`,
  `apps/mobile` (stub for now), and `db/migrations`.
- **FR-002**: A single documented command MUST boot the core API process together with a
  local Postgres, apply all migrations, and report healthy; a teardown command MUST return
  to a clean state; the up→down→up cycle MUST be idempotent. (Build-plan reference:
  `make up` / `make down`; exact runner reconciled with the repo's existing `just`/devenv
  setup in `plan.md`.)

**Core process & migrations**
- **FR-003**: The core API process MUST serve GraphQL at `/graphql` (Go + `chi` + `gqlgen`
  + `pgx`). Generated GraphQL and sqlc code MUST be committed to the repo.
- **FR-004**: Goose migrations MUST be embedded and applied automatically on core startup;
  the first migration MUST contain the full v2 DDL spine (Appendix A).

**Data model (Appendix A)**
- **FR-005**: The schema MUST land the full Appendix A model now — all enums and all tables,
  even those unused this phase. Priority objects: `principals` (`global_uri`, `kind`);
  `tasks` (`state`, `current_stage`, `provenance`, `context_refs`, `findings`,
  `global_uri`); `chain_workflows`; `audit_messages`; `pending_decisions`;
  `agent_assignments`; `tools`; `gate_scripts`; `tool_outcomes` (incl. `matured_at`);
  `device_tokens`; and the intake/agent/connector tables (`connector_configs`,
  `source_credentials`, `intake_signals`, `agent_configs`).
- **FR-006**: `tasks` MUST NOT carry a stored `autonomy` column (P1 — autonomy is emergent).
- **FR-007**: `chain_workflows` MUST link to a task nullably and MUST enforce at most one
  live workflow per task via a partial unique index where `ended_at IS NULL` (P2).
- **FR-008**: `audit_messages` MUST carry a self-referential `in_reply_to` FK so the audit
  log is message-shaped (a DAG) from day one (CC-1 seam, Principle VI).
- **FR-009**: `source_credentials` MUST store credentials encrypted at rest. The exact
  encryption mechanism is deferred to `plan.md`.

**Transition-notify plumbing**
- **FR-010**: A `notify_event(topic, id)` function MUST emit an IDs-only JSON payload
  (`{topic, data:{id}}`) on the `tendant_events` channel.
- **FR-011**: `AFTER INSERT` triggers on `pending_decisions` (topic `decision`) and
  `agent_assignments` (topic `assignment`) MUST call `notify_event` with only the row id —
  never row content — respecting the 8 KB NOTIFY cap and the safer IDs-only default.

**Durable engine**
- **FR-012**: DBOS MUST be initialized over the same Postgres and health-checked at startup.
- **FR-013**: A throwaway DBOS workflow MUST demonstrate crash-recovery — resuming and
  completing exactly once after a forced process restart mid-execution. It is a temporary
  verification artifact and may be removed once proven.

**GraphQL surface (read-only subset)**
- **FR-014**: The GraphQL schema MUST expose the Appendix B read-only subset: `viewer:
  User`; `task(id): Task`; `tasks(first, after, state): TaskConnection` (Relay); the
  `Principal` interface with `User` and `Bot`; `Time` and `JSON` scalars; `PageInfo`;
  `TaskEdge`/`TaskConnection`. Intent-named mutations are deferred (Phase 2).
- **FR-015**: Every `Task` and `Principal` returned MUST carry a `globalUri` (Principle
  VIII, federation-shaped). `Task.autonomy` MUST be a resolved readout, never a
  stored/settable field (P1).
- **FR-016**: A means to create a `Task` and seed the single owner `Principal` MUST exist
  (seed and/or a minimal create path) — enough to satisfy the create→read demo. A single
  hard-coded owner `Principal` MUST be seeded and returned by `viewer`.

**Dev / CI baseline**
- **FR-017**: CI MUST run Go lint, a codegen-drift check (gqlgen / sqlc — fail if
  committed generated code is stale; Ferry/Flutter codegen-drift deferred until the client
  generates code, Phase 2+), a migration up/down test, and at least one
  integration test that creates and reads a `Task` against a real Postgres.

### Key Entities

The full Appendix A model lands; most tables are unused this phase. The load-bearing ones:

- **Principal**: an actor (`User | Bot`), `global_uri` + `kind`. The single owner is seeded.
- **Task**: the durable unit — `state`, `current_stage`, `provenance`, `context_refs`,
  `findings`, `global_uri`. No stored autonomy. Outlives any workflow (P2).
- **Chain Workflow**: DBOS execution attached to a task (nullable); one live per task.
- **Audit Message**: node in the message-shaped audit DAG via `in_reply_to` self-FK.
- **Pending Decision** / **Agent Assignment**: the two inbox families; each insert fires the
  IDs-only notify.
- **Tool** / **Gate Script** / **Tool Outcome** (`matured_at`) / **Device Token**: action
  edge + calibration + wake addressing — landed, unused this phase.
- **Connector Config** / **Source Credentials** (encrypted) / **Intake Signal** / **Agent
  Config**: intake + agent catalog — landed, unused this phase.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From a clean checkout, a single command brings up a healthy, fully-migrated
  system with zero manual steps, and up→down→up is idempotent across repeated cycles
  (0 fix-ups required).
- **SC-002**: 100% of created tasks are retrievable both by id and in the task list within
  the same session, each carrying a non-empty `globalUri`.
- **SC-003**: Recording a decision or assignment produces exactly one event notification
  carrying only an identifier — 0 bytes of record content disclosed, payload within the
  size cap.
- **SC-004**: Across repeated forced-restart trials, the durable workflow completes exactly
  once every time — no lost or duplicated execution.
- **SC-005**: CI fails on any of: stale generated code, a broken migration up/down, or a
  failing create-and-read integration test — the foundation cannot regress unnoticed.

## Assumptions

- **Single owner, no auth yet**: self-hosted, single-household; one hard-coded owner
  `Principal` surfaced by `viewer`. The `Can(...)` permission service and richer auth are
  Phase 2.
- **Stack is ratified, not chosen here**: Postgres-only, DBOS, GraphQL operator edge, Go
  `gqlgen`/`chi`/`pgx`, embedded Goose, Flutter, `go.work` — fixed by the constitution's
  Technology Constraints; naming them is permitted under constitution v1.2.0.
- **Encryption deferred**: `source_credentials` are encrypted at rest; the mechanism is
  chosen in `plan.md` (intake is Phase 7, but the column lands now).
- **Boot interface**: the build plan references `make up`/`make down`; the concrete runner
  (Make vs the repo's existing `just` + devenv Postgres service) is finalized in `plan.md`.
- **Full schema now**: the entire Appendix A model is created even though only `principals`,
  `tasks`, `pending_decisions`, `agent_assignments`, and the notify plumbing are exercised.
- **Throwaway DBOS workflow** is a temporary verification artifact, not a product surface.

## Dependencies & Out of Scope

**Dependencies / known constraints (for `plan.md`)**
- DBOS Go SDK; its learning curve is front-loaded into this phase.
- Adding DBOS pulls docker `v28.5.2` transitively, which requires bumping `testcontainers-go`
  to ≥ v0.38 (repo currently pins v0.34.0) — keep them coupled.
- Contract-versioning discipline (Principle VII, §15 Q4) begins *in spirit* here; it becomes
  concrete when the GraphQL contract ships in Phase 2.

**Out of scope (deferred)**
- All behavior: no chain execution (Phase 1), no gate (Phase 3), no agents (Phase 6), no
  intake (Phase 7).
- The `LISTEN`er / subscription fan-out and the APNs/FCM push worker — triggers ship now,
  the listener and worker are Phase 2.
- Intent-named mutations beyond the minimal create/seed path.
- Auth beyond the single hard-coded owner; the `Can(...)` service is Phase 2.
