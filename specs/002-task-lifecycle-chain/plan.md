# Implementation Plan: Phase 1 — Task Lifecycle & Chain Skeleton (Human-Only)

**Branch**: `002-task-lifecycle-chain` | **Date**: 2026-05-27 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/002-task-lifecycle-chain/spec.md`

## Summary

Phase 1 adds **behavior** on top of Phase 0's data spine. The DBOS chain workflow
walks a task through the fixed linear chain `CREATION → TRIAGE → EXPANSION →
EXECUTION → COMPLETION`, routing every stage that needs an occupant to the human
(the router is a stub that always returns the human in this phase). One generic
durable wait primitive — implemented as DBOS `Send` / `Recv` keyed by
`{chainWorkflowID, topic}` — backs the human-slot pause; later phases (3, 9) reuse
it without new machinery. Four additive GraphQL mutations land
(`completeTask`, `cancelTask`, `acceptProposedTask`, `dismissProposedTask`) plus
the owner-authored task creation path which attaches a chain workflow on
creation. Cancellation calls `dbos.CancelWorkflow` and marks the task `HALTED`;
forward progress halts at the next-step boundary, completed work is recorded,
nothing is rolled back. Every lifecycle state transition and stage advance writes
one `audit_messages` row in the same DB transaction, building the message-shaped
audit DAG (`in_reply_to` links resolutions back to their assignments).

Two Phase 0 amendments ride with this phase, both additive: the `task_state`
enum value `eligible` is renamed to `waiting` (the holding state when readiness
conditions are not yet met), and a new migration `00002_phase1_state_rename.sql`
ships it. The GraphQL `TaskState` enum is correspondingly renamed in
`graphql.v1.graphqls` — permitted under Principle VII because no client has
consumed `ELIGIBLE` yet; once a client has, future renames MUST be
deprecation-shaped.

## Technical Context

**Language/Version**: Go 1.25 (unchanged from Phase 0).
**Primary Dependencies** (all already on the approved list from Phase 0):
- HTTP / GraphQL: `chi/v5`, `gqlgen` v0.17.90 (committed generated code).
- DB: `pgx/v5` v5.9.2; `sqlc` v1.31.1; `goose/v3` v3.27.1.
- Durable engine: `dbos-transact-golang` v0.15.0 — Phase 1 leans on:
  - `dbos.RegisterWorkflow` / `dbos.RunWorkflow` / `dbos.RunAsStep` (already used in `cmd/dbosdemo`).
  - `dbos.Send[P](ctx, destinationID, msg, topic)` — callable from the GraphQL handler; resolves the chain workflow's wait.
  - `dbos.Recv[R](ctx, topic, timeout)` — workflow-only; blocks the chain workflow on the next human slot. Survives `kill -9` via DBOS recovery.
  - `dbos.CancelWorkflow(ctx, workflowID)` — callable from the GraphQL handler; the running step finishes, next step won't start (matches the Q2 "complete-wins-on-current, halt-before-next" decision).
  - `dbos.RetrieveWorkflow[R](ctx, workflowID)` — to read status from the GraphQL surface.
- UUID: `google/uuid` (already a Phase 0 dep).

**No new third-party libraries.** All Phase 1 mechanics use Phase 0's stack.

**Storage**: Same Postgres 16 + pgvector container as Phase 0; no schema change
beyond the additive migration that renames the `task_state.eligible` enum value
to `waiting`. The Phase 0 `agent_assignments` and `audit_messages` tables are
used unchanged (the IDs-only `notify_event` triggers already fire on insert).

**Testing**: `go test -race` with `testcontainers-go` v0.39.0 (Phase 0 helper
`internal/testutil`). New test surface: state-machine unit tests, chain-workflow
integration tests against a real Postgres + DBOS, and a `kill -9` restart test
that reuses the Phase 0 `scripts/dbos-recovery-demo.sh` pattern. The wait
primitive gets a synthetic unit test that exercises `Send`/`Recv` outside the
assignment path (SC-004).

**Target Platform**: Linux server, self-hosted single-box, single-household
(unchanged).

**Project Type**: Web service (Go core + GraphQL operator edge) in the existing
`go.work` monorepo. No frontend changes — Phase 2 picks up the operator UI.

**Performance Goals**: No latency / throughput targets this phase. The chain
workflow is paced by human action; the durable wait sleeps until `Send` arrives.
Restart-to-recovered-blocking SHOULD be under a few seconds locally
(observation, not a hard target).

**Constraints**:
- IDs-only `pg_notify` cap (8 KB) — unchanged; triggers shipped in Phase 0.
- One live DBOS workflow per task — enforced by the partial-unique index on
  `chain_workflows (task_id) WHERE ended_at IS NULL` (Phase 0).
- Audit write atomic with state transition (FR-002) — implemented by a single
  SQL transaction per DBOS step that does both UPDATE and INSERT.
- Generated code (gqlgen, sqlc) committed; CI drift gate stays green.

**Scale/Scope**: One owner; a handful of in-flight tasks for testing. New code
under `services/api/internal/` (`chain/`, `lifecycle/`), one new migration, four
new GraphQL mutations, one new GraphQL type (`AgentAssignment`), one extension
to `core.CreateTask` (chain workflow attaches on creation).

## Constitution Check

*GATE: evaluated against constitution v1.2.0. Re-checked post-design — still passing.*

| Principle | Phase 1 status |
|---|---|
| I. Capability at the edges | ✅ Only the chain spine and lifecycle plumbing land — no new data source, no new outward action. Router is a stub that returns the human; agent branch is a noop seam. |
| II. Task ≠ workflow | ✅ Chain workflow attaches via `chain_workflows.dbos_workflow_id`; `tasks` record is untouched by workflow lifecycle. On cancel, the workflow ends (`ended_at` set, status `CANCELLED`) and the task persists with `state='HALTED'`. |
| III. Hard-rule floor immune | ✅ N/A — no tools fire this phase; no floor to bypass. |
| IV. Owner authors trust | ✅ No autonomy stored anywhere; no promotion logic. Mutations are owner-only by virtue of the single-owner assumption (Phase 0). |
| V. Cancel halts | ✅ Central to this phase. `cancelTask` → `dbos.CancelWorkflow` → next `Recv` returns the DBOS-cancelled error → workflow writes `state='HALTED'` and the `ended_at` on its `chain_workflows` row. Already-completed slots stay recorded. The Q2 "complete-wins-on-current, halt-before-next" semantics fall out naturally from DBOS's step-boundary cancellation. |
| VI. Audit message-shaped | ✅ FR-002 / FR-020: every transition writes an `audit_messages` row in the same SQL tx; resolutions set `in_reply_to` to the row that opened the slot. Cancellation row's `in_reply_to` points at the most recent prior transition. |
| VII. Edge contracts versioned / additive | ✅ Four mutations land **additively** in `graphql.v1.graphqls`; one new type (`AgentAssignment`) added **additively**. **Enum value rename** (`TaskState.ELIGIBLE → WAITING`) is on a strict reading of Principle VII *not* additive — it modifies an existing contract symbol. Owner-confirmed (2026-05-27): **no consumer has pulled the v1 contract** (Phase 0 shipped read-only with no operator UI, no published client, no third-party integrator). The rename is therefore safe at this precise point in the contract's life. **Future** renames — once a consumer exists — MUST follow the additive deprecation path (keep old value, add new value, deprecate, remove later); this one-time pre-consumer rename does not establish a precedent. |
| VIII. Federation-shaped | ✅ `AgentAssignment` is a sub-resource addressed via its parent `Task`; per v1.2.0 it does not need its own `globalUri`. `from_principal` and `to_principal` (when populated by Phase 6 agents) reference actors by `globalUri`. |
| IX. Untrusted code sandboxed | ✅ N/A — no gate-script execution this phase; sandbox machinery lands in Phase 3. |

**Technology Constraints**: Postgres-only ✅; DBOS engine ✅; adopted stack
(Go `gqlgen`/`chi`/`pgx`) ✅; no new dependencies ✅; no new datastore or
transport ✅.

**Dependency / deviation flags:**
- **No new dependencies.** All DBOS primitives used (`Send`, `Recv`,
  `CancelWorkflow`, `RetrieveWorkflow`) are part of the already-pinned
  `dbos-transact-golang` v0.15.0.
- **`task_state.eligible` → `task_state.waiting` (Phase 0 amendment).** Justified
  by the Q3 clarification: the original name misnamed what is actually the
  holding state for tasks whose readiness predicate has not yet been met. The
  GraphQL enum rename is permitted under Principle VII because no client has
  consumed it; this would be deprecation-shaped if a client had. Recorded here
  so the analyze pass can verify.
- **`AgentAssignment` GraphQL type lands now.** Phase 0 deferred this to Phase 2;
  Phase 1 brings it forward because the four new mutations need a return shape
  for the assignment surface. Still additive — no existing field is changed.

→ **Constitution Check: PASS.** No unjustified complexity; Complexity Tracking
left empty.

## Project Structure

### Documentation (this feature)

```text
specs/002-task-lifecycle-chain/
├── plan.md              # This file
├── research.md          # Phase 0 of plan: DBOS Send/Recv mapping, audit-tx pattern, enum-rename strategy
├── data-model.md        # State machine + stage advance table; new GraphQL types; enum-rename migration
├── quickstart.md        # Create a task, walk it, cancel mid-chain, kill -9 + restart, verify audit DAG
├── contracts/
│   └── graphql.v1.graphqls   # Phase 0 contract amended additively: AgentAssignment, 4 mutations, enum rename
└── checklists/
    └── requirements.md  # (from /speckit-specify, updated by /speckit-clarify)
```

### Source Code (repository root) — target layout

Phase 1 fits inside the existing layout. New / changed paths:

```text
db/migrations/
├── 00001_v2_ddl_spine.sql        # (Phase 0, unchanged)
└── 00002_phase1_state_rename.sql # NEW: ALTER TYPE task_state RENAME VALUE 'eligible' TO 'waiting'

services/api/
├── graph/
│   ├── schema.graphqls            # +AgentAssignment, +completeTask/cancelTask/acceptProposedTask/dismissProposedTask, rename TaskState.ELIGIBLE→WAITING
│   ├── generated.go               # regenerated (committed)
│   ├── model/                     # regenerated
│   └── *.resolvers.go             # NEW resolvers for the 4 mutations + AgentAssignment field resolver
└── internal/
    ├── chain/                     # NEW: chain workflow + router stub
    │   ├── workflow.go            # ChainWorkflow(ctx, taskID) — walks the stages
    │   ├── router.go              # Router{Select(ctx, stage, t) -> Agent}; Phase 1 stub returns human
    │   ├── stages.go              # nextStage(stage) + stage default `ask` text
    │   └── *_test.go              # integration tests against real PG + DBOS
    ├── lifecycle/                 # NEW: state-machine + audit helpers
    │   ├── edges.go               # legalEdges table + IsLegal / IsTerminal + ErrIllegalTransition
    │   ├── audit.go               # payload-shape helpers + WriteAuditMessage(tx, kind, payload, in_reply_to)
    │   ├── machine.go             # Transition(...) AND AdvanceStage(...) — both write audit row in same tx
    │   └── *_test.go              # state-machine unit tests
    ├── core/
    │   └── task.go                # CHANGED: CreateTask now also RegisterWorkflow + RunWorkflow (chain) + writes chain_workflows row
    ├── db/
    │   ├── queries/
    │   │   ├── assignments.sql    # NEW: InsertAssignment, ResolveAssignment, FindOpenAssignmentForTask
    │   │   ├── audit.sql          # NEW: InsertAuditMessage (used inside lifecycle.Transition)
    │   │   └── chains.sql         # NEW: InsertChainWorkflow, EndChainWorkflow, GetLiveWorkflowForTask
    │   ├── assignments.sql.go     # regenerated
    │   ├── audit.sql.go           # regenerated
    │   └── chains.sql.go          # regenerated
    └── durable/
        └── dbos.go                # CHANGED: chain workflow registered on Launch via durable.Register(chain.ChainWorkflow)
```

**Structure Decision**: Keep the existing `go.work` workspace and module
layout. Two new packages under `internal/`:

- **`internal/chain`** — owns the chain workflow + router stub + stage transitions.
  Imports `internal/lifecycle` for state writes and `internal/db` for SQL access.
- **`internal/lifecycle`** — owns the state machine, transition validation, and the
  audit-write helper. Pure functions over `pgx.Tx`; no DBOS dependency, so it's
  unit-testable without spinning up a workflow.

The split keeps the state machine independently testable (no DBOS in
`lifecycle`) while letting `chain` orchestrate it through a workflow. The chain
workflow registration moves into `internal/durable` (alongside the existing
`Init` / `Launch`) so `cmd/tendant/main.go` doesn't have to know about
workflows by name — it just calls `durable.Register(dctx)` and
`durable.Launch(dctx)`.

### Startup order (extends Phase 0 — additions in **bold**)

1. Open `pgxpool.Pool` from `DATABASE_URL`. *(unchanged)*
2. `goose.Up` — now runs **both** migrations (00001 + 00002). *(extended)*
3. Seed the single owner `Principal`. *(unchanged)*
4. `durable.Init` → **`durable.RegisterChainWorkflow(dctx)`** → `dbos.Launch`. *(extended)*
5. Build chi router (`/graphql`, `/healthz`). *(unchanged)*
6. `http.ListenAndServe`; graceful shutdown. *(unchanged)*

DBOS `Launch` recovers any PENDING chain workflows from the previous boot —
this is what makes US3 ("the chain workflow survives a forced restart while
waiting") work. Recovered workflows resume at their last `Recv` call,
listening on the same `{taskID, stage}` topic.

## Wait-key derivation (load-bearing)

Per FR-012 and the Q3 disambiguation, the wait MUST resolve to the same key on
recovery. The chosen derivation:

- **DBOS workflow ID** for a task's chain workflow is `chain:<task_uuid>`
  (deterministic from the task ID; no DB lookup needed in the GraphQL mutation
  to find the workflow to send to).
- **DBOS Send topic** is `stage:<chain_stage_value>` (e.g., `stage:triage`,
  `stage:expansion`, `stage:execution`).
- This makes the workflow ID and the topic both reconstructible from
  `(task_id, current_stage)` alone — the recovered workflow's `Recv` and the
  mutation handler's `Send` agree by construction. No additional wait-key
  column is needed on `agent_assignments`; the `(task_id, stage)` pair already
  uniquely identifies the open slot.

`chain_workflows.dbos_workflow_id` is still written on insert (kept for
operability — `GetLiveWorkflowForTask` returns it; useful for the `cancelTask`
mutation, which calls `dbos.CancelWorkflow(ctx, id)` and benefits from a
single DB read rather than rebuilding the string).

## Complexity Tracking

> No Constitution Check violations. Section intentionally empty.
