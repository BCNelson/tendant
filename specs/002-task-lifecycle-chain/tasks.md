---
description: "Task list — Phase 1: Task Lifecycle & Chain Skeleton (Human-Only)"
---

# Tasks: Phase 1 — Task Lifecycle & Chain Skeleton (Human-Only)

**Input**: Design documents from `specs/002-task-lifecycle-chain/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/graphql.v1.graphqls, quickstart.md

**Tests**: INCLUDED — the spec's success criteria (SC-001…SC-005) require verifiable behaviour, and each user story carries an Independent Test in the spec.

**Organization**: tasks grouped by user story. P1 stories (US1 chain-to-DONE, US2 cancel-to-HALTED) are the MVP. Most of the plumbing lives in Foundational; user stories add the mutation + integration test that verifies the slice.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no incomplete-task deps)
- **[Story]**: US1–US5 (user-story phases only)
- Module roots: `db/` = `github.com/bcnelson/tendant/db`; `services/api/` = `github.com/bcnelson/tendant/services/api`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: very light — Phase 0 already established the monorepo, toolchain, and tooling. Phase 1 reuses everything.

- [X] T001 [P] Confirm `go.work` resolves the existing `services/api` + `db` modules and `go env GOMODCACHE` resolves `github.com/dbos-inc/dbos-transact-golang@v0.15.0` (no version bump). Record the API surfaces used (`dbos.Send`, `dbos.Recv`, `dbos.CancelWorkflow`, `dbos.RetrieveWorkflow`, `dbos.RunAsStep`) in a one-line note in `research.md` if any drift from v0.15.0 is observed.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: the state machine, the chain workflow, the durable wait, the GraphQL surface additions, and the sqlc queries — everything every user story needs to exist before the story-specific test can run. **⚠️ Blocks all user stories.**

### Migration (enum rename + default)

- [X] T002 Author `/db/migrations/00002_phase1_state_rename.sql`: `-- +goose Up` runs `ALTER TYPE task_state RENAME VALUE 'eligible' TO 'waiting';` followed by `ALTER TABLE tasks ALTER COLUMN state SET DEFAULT 'accepted';` (each in their own `StatementBegin/StatementEnd` block); `-- +goose Down` reverses both in the inverse order (`SET DEFAULT 'eligible'`, then `RENAME VALUE 'waiting' TO 'eligible'`).

- [X] T003 [P] Add `/services/api/internal/db/migrate_phase1_test.go` (testcontainers Postgres, reuses `internal/testutil`): apply 00001 + 00002; assert `pg_enum` lists `waiting` and not `eligible` for type `task_state`; assert `tasks.state` column default is `'accepted'::task_state`; run down then up; assert idempotency (no errors).

### sqlc queries (assignments / audit / chains)

- [X] T004 Add `/services/api/internal/db/queries/assignments.sql`: `InsertAgentAssignment` (now returning all columns, taking `task_id`, `stage`, `from_principal` nullable, `ask`, `gathered_context` jsonb); `ResolveAssignment(id, resolved_at)` (`UPDATE … RETURNING *` only if `resolved_at IS NULL`); `FindOpenAssignmentForTask(task_id)` (returns the row where `resolved_at IS NULL`, `LIMIT 1`); `FindOpenAssignmentForStage(task_id, stage)` (deterministic recovery lookup).

- [X] T005 [P] Add `/services/api/internal/db/queries/audit.sql`: `InsertAuditMessage` (takes `id`, `task_id`, `from_principal`, `to_principal` nullable, `in_reply_to` nullable, `kind`, `payload` jsonb, `at` defaulting to `now()`); `LatestTransitionForTask(task_id)` (returns the most recent row whose `kind IN ('state_transition','stage_advance','workflow_started','workflow_cancelled','assignment_created','assignment_resolved')` for `in_reply_to` chaining); `ListAuditForTask(task_id)` (ORDER BY `at`, used by tests asserting the DAG).

- [X] T006 [P] Add `/services/api/internal/db/queries/chains.sql`: `InsertChainWorkflow(task_id, dbos_workflow_id, status='pending', started_at=now())` returning the row; `EndChainWorkflow(task_id, status, ended_at)` (`UPDATE … WHERE task_id=$1 AND ended_at IS NULL`); `GetLiveWorkflowForTask(task_id)` (returns the row where `ended_at IS NULL`).

- [X] T007 Update `/services/api/internal/db/queries/tasks.sql` `CreateTask` to take `state` (typed `task_state`) and `current_stage` (typed `chain_stage`) parameters, so the owner-authored path can pass `'accepted','creation'` explicitly. Add `GetTaskForUpdate(id)` (`SELECT … FOR UPDATE`) for the transition path. Add `UpdateTaskState(id, new_state)` and `UpdateTaskStage(id, new_stage)` returning the updated row.

- [X] T008 Run `sqlc generate` (from `/services/api/`) and commit the regenerated `/services/api/internal/db/assignments.sql.go`, `audit.sql.go`, `chains.sql.go`, and the updated `tasks.sql.go` and `models.go`. Verify `go build ./...` from repo root.

### Lifecycle package (state machine + audit helpers; no DBOS dep)

- [X] T009 Add `/services/api/internal/lifecycle/edges.go`: typed constants and a `legalEdges` map (`map[TaskState]map[TaskState]bool`) implementing FR-001's transition table; export `IsLegal(from, to TaskState) bool` and `IsTerminal(s TaskState) bool`. Plus a typed error type `ErrIllegalTransition` exposing `From`, `To`.

- [X] T010 [P] Add `/services/api/internal/lifecycle/audit.go`: payload shape helpers (`StateTransitionPayload`, `StageAdvancePayload`, `AssignmentCreatedPayload`, `AssignmentResolvedPayload`, `WorkflowStartedPayload`, `WorkflowCancelledPayload`); `WriteAuditMessage(ctx, tx, taskID, kind, payload, inReplyTo)` that inserts one row via the sqlc query in T005; on success returns the new row's id (so callers can chain `in_reply_to`).

- [X] T011 Add `/services/api/internal/lifecycle/machine.go`: `Transition(ctx, tx pgx.Tx, q *db.Queries, taskID, from, to TaskState, reason string) (auditID uuid.UUID, err error)` — verifies `IsLegal`, calls `UpdateTaskState`, looks up `LatestTransitionForTask` for `in_reply_to`, writes the audit row in the same tx via T010. `AdvanceStage(ctx, tx, q, taskID, fromStage, toStage ChainStage) (auditID uuid.UUID, err error)` — analogous for stage. Both pure functions over a single `pgx.Tx`; the caller controls commit.

- [X] T012 [P] Add `/services/api/internal/lifecycle/machine_test.go`: table-driven unit tests against a testcontainer pool — legal edges succeed, illegal edges return `ErrIllegalTransition`, every successful call writes exactly one audit row, `in_reply_to` of the second transition equals the id of the first, terminal-state outbound edges are rejected.

### Chain package (router stub + workflow + stages)

- [X] T013 Add `/services/api/internal/chain/router.go`: `type Agent struct { IsHuman bool; PrincipalID *uuid.UUID }`; `type Router interface { Select(ctx context.Context, stage ChainStage, findings json.RawMessage) Agent }`; `type HumanOnlyRouter struct{}` implementing `Select` and returning `Agent{IsHuman: true}` unconditionally — the Phase 1 stub. Phase 6 swaps the implementation.

- [X] T014 [P] Add `/services/api/internal/chain/stages.go`: `var stageOrder = []ChainStage{CREATION, TRIAGE, EXPANSION, EXECUTION, COMPLETION}`; `NextStage(current ChainStage) (next ChainStage, isLast bool)`; `StageNeedsOccupant(s ChainStage) bool` (true for TRIAGE/EXPANSION/EXECUTION, false for CREATION/COMPLETION); `DefaultAsk(s ChainStage) string` returning the strings from research R7.

- [X] T015 Add `/services/api/internal/chain/wait.go`: thin wrappers over the DBOS Send/Recv primitive that keep the *generic* property (FR-009 / SC-004). `func WaitForResult(ctx dbos.DBOSContext, topic string, timeout time.Duration) (json.RawMessage, error)` calls `dbos.Recv[json.RawMessage](ctx, topic, timeout)`. `func Resolve(client dbos.Client, workflowID, topic string, payload json.RawMessage) error` calls `dbos.Send`. Export `const HumanSlotTimeout = 72 * time.Hour` (long enough that ordinary human latency never trips it; if a slot truly sits three days, the workflow errors and the operator decides next step). **Critical**: the signature MUST NOT name a stage, assignment, principal, or task — only an opaque `topic`. (Verified in US5.)

- [X] T016a Add `/services/api/internal/chain/workflow.go` skeleton: `ChainWorkflow(ctx dbos.DBOSContext, taskID string) (string, error)`. Load task on entry; if `current_stage == COMPLETION` return immediately (recovered terminal state). Implement the stage-walk loop driver — for each `current_stage`, call `Router.Select`; if the agent is the human and `StageNeedsOccupant(stage)`, call `WaitForResult(ctx, "stage:"+stage, HumanSlotTimeout)`. The bodies of each step (insert/resolve assignment, audit, advance) are stubbed via TODO and implemented in T016b. (Depends T013, T014, T015.)

- [X] T016b Inside `ChainWorkflow`, implement the assignment lifecycle: (i) one DBOS step opens a tx, calls `InsertAgentAssignment`, writes the `assignment_created` audit row (capture the row id for `in_reply_to`), commits; (ii) on `WaitForResult` return, one DBOS step opens a tx, calls `ResolveAssignment`, writes the `assignment_resolved` audit row with `in_reply_to` set to (i)'s id, advances stage via `lifecycle.AdvanceStage`, and at the EXPANSION→EXECUTION boundary calls `chain.EvaluateReadiness` and `lifecycle.Transition(ACCEPTED → EXECUTING | WAITING)`. (Depends T016a, T010, T011, T017.)

- [X] T016c Inside `ChainWorkflow`, implement cancel and completion exit paths: (i) outer `defer` detects the DBOS-cancelled error class from `Recv`; in one DBOS step writes `lifecycle.Transition(currentState → HALTED, reason="cancelled by owner")`, writes a `workflow_cancelled` audit row with `in_reply_to` = most recent prior transition row id, calls `EndChainWorkflow(task_id, 'cancelled', now())`. (ii) on reaching `COMPLETION`, one final DBOS step does `lifecycle.Transition(EXECUTING → DONE, reason="completion finished")` and `EndChainWorkflow(task_id, 'success', now())`. (Depends T016b.)

- [X] T017 Add `/services/api/internal/chain/readiness.go`: `EvaluateReadiness(ctx context.Context, q *db.Queries, taskID uuid.UUID) (bool, error)` — the seam from FR-019 / data-model.md. Phase 1 implementation returns `true` unconditionally; a comment names Open Question Q1 and the future signature shape. Called inside the EXPANSION→EXECUTION boundary step of T016b to choose `state='executing'` vs `state='waiting'`.

### Durable wiring (registration + main)

- [X] T018 Update `/services/api/internal/durable/dbos.go` — add `RegisterChainWorkflow(dctx dbos.DBOSContext, q *db.Queries, pool *pgxpool.Pool, router chain.Router)`: closes over its deps and calls `dbos.RegisterWorkflow(dctx, chain.ChainWorkflow, dbos.WithWorkflowName("tendant.chain"))`. Keep `Init`/`Launch`/`Shutdown` unchanged. (Depends T013, T016a.)

- [X] T019 Update `/services/api/cmd/tendant/main.go` boot sequence — between `durable.Init` and `durable.Launch`, call `durable.RegisterChainWorkflow(dctx, q, pool, &chain.HumanOnlyRouter{})`. Verify the launcher logs "dbos launched (recovery, if any, completed)" still appears (recovery of pending chain workflows is what makes US3 work). (Depends T013, T016a, T018.)

### Core: owner-authored creation attaches a chain workflow

- [X] T020 Update `/services/api/internal/core/task.go`:
  1. **Extract a shared helper** `func AttachChainWorkflow(ctx context.Context, pool *pgxpool.Pool, dctx dbos.DBOSContext, taskID uuid.UUID) error` that opens a tx, calls sqlc `InsertChainWorkflow` with `dbos_workflow_id = "chain:" + taskID.String()`, writes the initial `workflow_started` audit row, commits, then calls `dbos.RunWorkflow(dctx, chain.ChainWorkflow, taskID.String(), dbos.WithWorkflowID("chain:" + taskID.String()))`.
  2. **Update `CreateTask`** to take a `pgxpool.Pool` and `dbos.DBOSContext`. Open a tx; call sqlc `CreateTask` with `state='accepted', current_stage='creation'` (parameters added in T007); commit. Then call `AttachChainWorkflow`. Return `CreatedTask{ID, GlobalURI, Title}` unchanged. (Depends T007, T008, T010, T013, T016c.)

- [X] T021 [P] Update `/services/api/internal/core/task_test.go` (or add it if missing): unit test that CreateTask inserts the task with state='accepted', inserts a chain_workflows row with `dbos_workflow_id="chain:<uuid>"`, writes one `workflow_started` audit row, and (with DBOS launched) the workflow is observable in `dbos.RetrieveWorkflow` with status PENDING. (Depends T020.)

- [X] T021a [P] Update `/services/api/graph/task_integration_test.go` for the new Phase 1 surface: (i) replace the direct `core.CreateTask(ctx, q, "hello", "")` call (line 53) with the new signature (which now needs a `pgxpool.Pool` and `dbos.DBOSContext`) **or** rewrite the test to drive a task via the `createTask` GraphQL mutation; (ii) change the two `require.Equal(t, "ELIGIBLE", …)` assertions (lines 94, 127) to `"ACCEPTED"` — Phase 1's `tasks.state` default after migration 00002 is `'accepted'` and the value `'eligible'` no longer exists (renamed to `'waiting'`); (iii) leave the rest of the test (globalUri, autonomy non-null, pagination) unchanged. (Depends T020, T002.)

### GraphQL surface (schema, mutations, AgentAssignment, openAssignment)

- [X] T022 Update `/services/api/graph/schema.graphqls` to match `specs/002-task-lifecycle-chain/contracts/graphql.v1.graphqls`: rename `TaskState.ELIGIBLE` → `WAITING`; add `type AgentAssignment { id task stage fromAgent ask gatheredContext createdAt resolvedAt }`; add `Task.openAssignment: AgentAssignment`; add the `type Mutation { createTask, completeTask, cancelTask, acceptProposedTask, dismissProposedTask }` block. Then run `gqlgen generate` and commit `/services/api/graph/generated.go`, `graph/model/*`, and resolver stubs. (Depends T002, T008.)

- [X] T023 Implement `/services/api/graph/mutation_create_task.resolvers.go` `CreateTask` resolver: call `core.CreateTask` (which now attaches the chain workflow); fetch the resulting task via `GetTask`; return the Task model. (Depends T020, T022.)

- [X] T024 [P] Implement `/services/api/graph/mutation_proposed.resolvers.go`: `AcceptProposedTask` resolver — verify task is in `PROPOSED`, transition `PROPOSED → ACCEPTED` via `lifecycle.Transition` in a tx, then call `core.AttachChainWorkflow(ctx, pool, dctx, taskID)` (the helper extracted in T020). `DismissProposedTask` resolver — verify `PROPOSED`, transition to `DISMISSED` via `lifecycle.Transition` with `reason` included in the audit payload. Both error if task is not in `PROPOSED`. (Depends T011, T020, T022.)

- [X] T025 [P] Implement `/services/api/graph/task_open_assignment.resolvers.go` `Task.openAssignment` field resolver — calls `FindOpenAssignmentForTask`; returns nil if no open row, otherwise maps to the GraphQL `AgentAssignment` model. Also implement `AgentAssignment.task` and `AgentAssignment.fromAgent` field resolvers. (Depends T022.)

### Mutations needed by US1 / US2 (live here in Foundational because both stories share the wait surface)

- [X] T026 Implement `/services/api/graph/mutation_complete_task.resolvers.go` `CompleteTask` resolver: load the task; reject if terminal (`Q5` typed error `TASK_ALREADY_TERMINAL`); call `FindOpenAssignmentForTask` — error if none; resolve the chain workflow's wait by calling `chain.Resolve(client, "chain:"+taskID, "stage:"+stage, result)`. **Do not** update the assignment or write the resolution audit row from the resolver — those happen inside the workflow's next step (T016b) so the same code path runs on recovery. Return the (now-paused-on-next-stage) task by fetching it again post-`Send`. (Depends T015, T022.)

- [X] T027 Implement `/services/api/graph/mutation_cancel_task.resolvers.go` `CancelTask` resolver: load the task; if terminal, return `TASK_ALREADY_TERMINAL`; call `GetLiveWorkflowForTask` to get the `dbos_workflow_id`; call `dbos.CancelWorkflow(ctx, id)`. Return the task (the workflow's own deferred handler in T016c writes `state='HALTED'` and ended_at; the resolver does NOT pre-empt that write — Principle V / Q2 require that the in-flight step finish first). (Depends T015, T022, T016c.)

**Checkpoint**: `go run ./services/api/cmd/tendant` boots; `createTask` mutation persists a task with `state=ACCEPTED`, attaches a chain workflow, opens a TRIAGE `agent_assignments` row; the workflow is recoverable across restart.

---

## Phase 3: User Story 1 — Owner-authored task walks chain to `DONE` (Priority: P1) 🎯 MVP

**Goal**: end-to-end happy-path: `createTask` → three `completeTask` calls → `state='DONE'`, `current_stage='COMPLETION'`, audit DAG present.

**Independent Test**: see spec US1 Independent Test — create a task, observe an `agent_assignments` row appear for each human-occupied stage in turn (`TRIAGE → EXPANSION → EXECUTION`), `completeTask` each one, assert final state.

- [X] T028 [P] [US1] Add `/services/api/graph/chain_happy_path_test.go` (testcontainers Postgres, DBOS launched): create a task via the `createTask` GraphQL mutation; poll until `openAssignment.stage == TRIAGE`; resolve via `completeTask`; poll until `openAssignment.stage == EXPANSION`; resolve; same for `EXECUTION`; assert final task `state='DONE'`, `currentStage='COMPLETION'`, `openAssignment=null`. Assert `chain_workflows.ended_at` is set.

- [X] T029 [US1] Add an audit-completeness assertion inside the same test (or a sibling test `chain_happy_path_audit_test.go`): read `ListAuditForTask`; assert one audit row per state transition (`workflow_started`, `ACCEPTED→EXECUTING` at the EXPANSION→EXECUTION boundary with readiness predicate true, `EXECUTING→DONE` at COMPLETION); one row per stage advance (`CREATION→TRIAGE`, `TRIAGE→EXPANSION`, `EXPANSION→EXECUTION`, `EXECUTION→COMPLETION`); one `assignment_created` + one `assignment_resolved` per human-occupied stage; verify the `in_reply_to` of every `assignment_resolved` points at its `assignment_created`.

**Checkpoint**: MVP-A — a task created via GraphQL walks the chain to `DONE` with the operator (the test) acting as the human in every slot.

---

## Phase 4: User Story 2 — Cancel mid-chain → `HALTED` (Priority: P1)

**Goal**: `cancelTask` halts forward progress without rollback; complete-vs-cancel race resolves per Q2 (complete wins on current slot, halt before next stage).

**Independent Test**: see spec US2 Independent Test — pause a task mid-chain, cancel it, assert `state='HALTED'`, audit DAG intact, subsequent `completeTask` fails cleanly.

- [X] T030 [P] [US2] Add `/services/api/graph/chain_cancel_test.go` (testcontainers Postgres, DBOS launched): create a task; let it pause at TRIAGE; call `cancelTask`; assert `state='HALTED'`, `chain_workflows.status='cancelled'`, `chain_workflows.ended_at` set; a `workflow_cancelled` audit row exists with `in_reply_to` pointing at the most recent prior transition; subsequent `completeTask` returns a typed "task is HALTED" error; subsequent `cancelTask` returns `TASK_ALREADY_TERMINAL`.

- [X] T031 [US2] Add `/services/api/graph/chain_cancel_race_test.go`: create a task; let it pause at TRIAGE; launch `completeTask` and `cancelTask` concurrently (separate goroutines, same request lifecycle); after both return, assert the final state is `HALTED`, the TRIAGE assignment is resolved (`resolved_at` set, `assignment_resolved` audit row present), but **no EXPANSION assignment was created** (the cancel halted before the next stage dispatch). This is the Q2 / FR-016 semantics test.

**Checkpoint**: MVP-B — cancel halts forward progress, races resolve per Q2, principle V holds.

---

## Phase 5: User Story 3 — The chain workflow survives a forced restart while waiting (Priority: P2)

**Goal**: kill -9 mid-wait, restart, the same chain workflow is re-blocked on the same wait; the next `completeTask` advances exactly once.

**Independent Test**: see spec US3 Independent Test — create a task, pause on a slot, kill the core, restart, verify the workflow recovers.

- [X] T032 [P] [US3] Add `/scripts/chain-recovery-demo.sh` modelled on `/scripts/dbos-recovery-demo.sh`: starts `cmd/tendant`, creates a task via curl-to-GraphQL, polls until the TRIAGE assignment is open, `kill -9`s the process, restarts it, polls until the same `agent_assignments` row is still the open one, calls `completeTask`, asserts the chain advances to EXPANSION. Exit code 0 on success.

- [X] T033 [US3] Add `/services/api/graph/chain_recovery_test.go` (testcontainers Postgres + a sub-process running `cmd/tendant` against it, or in-process equivalent that exercises DBOS recovery): mirror the script in Go for CI. Specifically: drive the task to pause on TRIAGE; call `dbos.Shutdown(ctx, 0)` (forces an abrupt shutdown); re-init DBOS over the same pool; re-`RegisterChainWorkflow`; `dbos.Launch` (recovery runs); query for the open assignment — assert it is the same row id as before. Then call the `completeTask` resolver and assert the chain advances.

**Checkpoint**: durability holds — the wait survives process death exactly as Phase 0 SC-004 promised for DBOS in general; FR-011 / SC-003 verified.

---

## Phase 6: User Story 4 — The audit DAG records every lifecycle and stage transition (Priority: P2)

**Goal**: every transition writes one `audit_messages` row in the same SQL tx; the DAG shape is correct (in_reply_to wired).

**Independent Test**: spec US4 Independent Test — drive a chain to DONE, read audit, assert per-transition rows and `in_reply_to` linkage.

- [X] T034 [P] [US4] Add `/services/api/graph/audit_dag_test.go`: drive multiple shaped paths and assert audit invariants. Three sub-tests: (a) happy path: every transition has an audit row, `assignment_resolved.in_reply_to == assignment_created.id` for each slot, no gaps; (b) cancelled mid-chain: `workflow_cancelled.in_reply_to == latest_prior_transition.id`, no transitions appear after `workflow_cancelled`; (c) atomicity: inject a forced failure into `WriteAuditMessage` (via a hook or by directly calling `lifecycle.Transition` with a tx that's later rolled back); assert that neither the state nor the audit row are present after rollback (FR-002 invariant).

**Checkpoint**: the audit invariant (Principle VI / FR-002 / FR-020) is verified, and the DAG shape is the foundation Phase 8's calibration loop will read.

---

## Phase 7: User Story 5 — The durable wait primitive is generic, not human-specific (Priority: P3)

**Goal**: the wait/resume primitive has no human, stage, or assignment parameter; a synthetic non-assignment caller can use it identically.

**Independent Test**: spec US5 Independent Test — inspect the primitive surface; run a synthetic test against an arbitrary key.

- [X] T035 [P] [US5] Add `/services/api/internal/chain/wait_test.go`: a Go unit test `TestWaitPrimitive_IsGeneric` that registers a small synthetic DBOS workflow whose body is `chain.WaitForResult(ctx, "synthetic-key", longTimeout)` and immediately returns the result; from outside the workflow call `chain.Resolve(client, syntheticWorkflowID, "synthetic-key", []byte(`{"hello":"world"}`))`; assert the workflow result equals the resolver payload exactly. Additionally, a `TestWaitPrimitive_SurfaceHasNoHumanParams` static test (build-tag or reflection-based) that asserts the signatures of `chain.WaitForResult` and `chain.Resolve` have **only** `(ctx/client, topic/workflowID+topic, payload, timeout)` — no `stage`, `assignment`, `principal`, `task` parameter (SC-004).

**Checkpoint**: the "one primitive" property is structurally verified; later phases (3 approvals, 9 sub-agent questions) can add callers without new wait machinery.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T036 [P] Confirm `Task.openAssignment` is resolved lazily via the field resolver in T025 (gqlgen-idiomatic, no extra JOIN). `GetTask` keeps Phase 0's columns only — no SQL change. Verify `just generate` is clean (no drift between `services/api/graph/schema.graphqls` and `generated.go`).

- [X] T037 [P] Update `/.github/workflows/ci.yml` if needed: ensure the new tests under `internal/chain`, `internal/lifecycle`, and `graph/` are picked up by the existing `go test ./...` invocation; ensure docker-compose / testcontainers still have `pgvector/pgvector:pg16`. No new CI jobs.

- [X] T038 Run the quickstart end-to-end (`specs/002-task-lifecycle-chain/quickstart.md` §1–§6) against a clean checkout: `make down && make up`, walk a task to DONE, cancel a task, run the recovery script, run the audit-DAG psql query, run the generic-wait test. Record any deviations from spec in a follow-up note.

- [X] T039 [P] Update `/CLAUDE.md` SPECKIT block to note that Phase 1 is **complete** (matching the Phase 0 wording) once all stories have landed and CI is green.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** — trivial; can complete immediately.
- **Foundational (Phase 2)** — depends on Setup; ALL user stories depend on this.
- **User Stories (Phases 3–7)** — all depend on Foundational. After Foundational completes, the five stories can proceed in any order (each is its own test file; the test scaffolds and the tested behaviour are both in Foundational).
- **Polish (Phase 8)** — depends on the user stories that are in scope. T038 (quickstart end-to-end) is best run after all stories land.

### Within Foundational (Phase 2)

- Migration first: T002 → T003 (test).
- sqlc queries: T004–T007 in parallel (different files); T008 (generate + commit) depends on all of them.
- Lifecycle: T009 → T010 (parallel after T009) → T011 → T012 (test).
- Chain: T013 (router), T014 (stages, parallel), T015 (wait) — all three before T016a (workflow skeleton). T016a → T016b (assignment lifecycle) → T016c (cancel + completion).
- Wiring: T018 (durable) depends on T013, T016a (registration needs the function declared). T019 (main wiring) depends on T013, T016a, T018.
- Core: T020 (CreateTask + AttachChainWorkflow helper) depends on T007, T008, T010, T013, T016c (RunWorkflow expects the full body to be in place for end-to-end testing). T021 (unit test) depends on T020. T021a (Phase 0 test update) depends on T020, T002.
- GraphQL: T022 (schema + generate) depends on T002, T008. T023 (createTask resolver) depends on T020, T022. T024–T027 (other resolvers) depend on T022 + various lifecycle/chain tasks as noted.

### Within Each User Story

- The test in the story phase is itself the deliverable — it consumes the Foundational surfaces. No story-internal ordering except "test passes."

### Parallel Opportunities

- T004, T005, T006 (sqlc queries — different files) can run in parallel.
- T009 then T010 in parallel after T009 (audit.go uses edges.go types? — review at write time).
- T013, T014, T015 in parallel inside Chain (different files).
- T024, T025, T026, T027 in parallel inside GraphQL resolvers (different files).
- All user-story phases (US1 through US5) can run in parallel once Foundational lands.
- Polish T036, T037, T039 in parallel.

---

## Parallel Example: User Story phases after Foundational

```bash
# Once Phase 2 (Foundational) is green, the five story tests can be run in parallel:
go test ./services/api/graph -run TestChainHappyPath      # US1: T028, T029
go test ./services/api/graph -run TestChainCancel         # US2: T030, T031
bash scripts/chain-recovery-demo.sh                       # US3: T032
go test ./services/api/graph -run TestAuditDAG            # US4: T034
go test ./services/api/internal/chain -run TestWaitPrim   # US5: T035
```

If different developers tackle different stories, the only shared edit
window is `/services/api/graph/schema.graphqls` (touched by T022 only), and
all four resolver files are distinct.

---

## Implementation Strategy

### MVP First (US1 + US2 only)

1. Complete Phase 1: Setup (trivial).
2. Complete Phase 2: Foundational — the chain skeleton, state machine, durable wait, mutations.
3. Complete Phase 3: US1 happy-path test.
4. Complete Phase 4: US2 cancel test (also covers the cancel-vs-complete race per Q2).
5. **STOP and VALIDATE**: the spine works end-to-end with the human in every slot.

### Incremental Delivery

1. Foundational lands → all five user stories are now testable.
2. US1 lands → MVP-A: chain walks to DONE.
3. US2 lands → MVP-B: cancel halts cleanly.
4. US3 lands → durability proven for the chain workflow specifically (Phase 0 proved it for DBOS in general).
5. US4 lands → audit DAG invariant verified.
6. US5 lands → wait primitive's genericity locked in before Phase 3 adds the second caller (approvals).
7. Polish: quickstart end-to-end + CI green + CLAUDE.md update.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps task to specific user story for traceability.
- Each user story is implemented entirely in its own test file under `services/api/graph` or `services/api/internal/chain` — the production code that the tests exercise lives in Foundational.
- Audit invariants are central to Phase 1: every transition writes one row; `in_reply_to` is wired; failing audit fails the whole tx. T034 verifies all three.
- The wait primitive's *genericity* is a structural property the rest of the system depends on. T015 + T035 enforce it: if a future change adds a stage parameter to `chain.WaitForResult` or `chain.Resolve`, T035's surface assertion fails.
- `acceptProposedTask` / `dismissProposedTask` land in Foundational (T024) because they're additive contract surface (FR-017 / Principle VII) and don't tie to any P1/P2 story. They exercise once Phase 7 starts producing `PROPOSED` tasks.
- Commit after each logical group (e.g., "all sqlc queries + generate" = one commit; "lifecycle package + tests" = another).
