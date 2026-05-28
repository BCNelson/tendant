# Phase 0 (of plan) — Research: Phase 1 Task Lifecycle & Chain Skeleton

Decisions reached before implementation, with the rationale and the alternatives
considered. The spec settled five contract / UX questions during
`/speckit.clarify`; this document settles the **technical** unknowns that
remained.

---

## R1. Durable wait primitive — DBOS `Send` / `Recv`, not `SetEvent` / `GetEvent`

**Decision**: Implement the spec's "one durable wait-on-event primitive"
(FR-009) using DBOS `Send[P](ctx, destinationID, msg, topic)` from the
GraphQL mutation handler and `Recv[R](ctx, topic, timeout)` from the chain
workflow.

**Rationale**:
- `Recv` is the only one of the two DBOS primitives that is *workflow-only and
  blocks*. The chain workflow needs to durably block on a human slot; that's
  exactly what `Recv` does, including across `kill -9` recovery (FR-011 / US3).
- `Send` is callable from a regular HTTP handler (the `completeTask` resolver),
  not only from within another workflow. That fits the GraphQL surface
  precisely.
- The payload is generic (`P any`), so the spec's `result: JSON` from
  `completeTask` flows through to the chain workflow without a separate
  schema-per-stage type.
- The `{destinationWorkflowID, topic}` pair is the spec's
  *deterministic wait-key from `(taskId, stage)`* (FR-012) — the workflow ID
  is `chain:<task_uuid>` and the topic is `stage:<chain_stage>`. Both are
  reconstructible from `(task_id, current_stage)` without a DB lookup, which
  matters for the cancel path that needs to address the wait before fully
  trusting `chain_workflows` state.

**Alternatives considered**:
- **`SetEvent` / `GetEvent`** — keyed value events. Rejected for the wait
  semantics because `SetEvent` is workflow-only and `GetEvent` polls with a
  timeout; the natural shape is "the mutation pushes an event and the
  workflow picks it up," which is `Send`/`Recv`. Also: events are
  publish-once, retain-forever; the wait should consume the payload, which
  `Recv` does naturally.
- **Application-managed wait** (a custom Postgres `LISTEN` + condition column).
  Rejected: would re-invent what DBOS provides, would not survive process
  death the same way, and would make later phases (approvals, tool results,
  sub-agent questions) build their own waits instead of reusing one
  primitive — the exact failure mode FR-009 forbids.

**Wait-key shape (load-bearing)**:
- **Workflow ID**: `chain:<task_uuid>` (UUID string). Deterministic from
  `task_id` — `chain_workflows.dbos_workflow_id` is written on insert and is
  the authoritative reference, but the deterministic form makes the
  reconstruction unambiguous.
- **Topic**: `stage:<chain_stage>`, e.g., `stage:triage`, `stage:expansion`,
  `stage:execution`. Lowercase enum values.
- The wait *primitive's* public surface (FR-009 / SC-004) takes only an opaque
  key and an opaque payload — internally `(workflowID, topic)` + `any`. The
  assignment-row machinery on top of this primitive supplies the
  `(taskID, stage)` translation.

---

## R2. Cancellation — `dbos.CancelWorkflow` lines up with "complete wins, halt before next"

**Decision**: `cancelTask(taskId)` resolves to
`dbos.CancelWorkflow(ctx, chainWorkflowID)`, where `chainWorkflowID` is read
from `chain_workflows` for the task. The chain workflow detects the
cancellation when its **next** DBOS step starts — DBOS surfaces the cancel as
an error from the next `Recv` / `RunAsStep` call (`AwaitedWorkflowCancelled`
or `context.Cause` revealing the cancellation cause). The workflow's
deferred / on-exit handler writes `state='HALTED'`, the audit row, and the
`chain_workflows.ended_at`.

**Rationale**:
- The "DBOS finishes the current step then halts at the next step boundary"
  behaviour exactly matches the Q2 clarification: if a `completeTask`
  `Send` arrives before the cancel is processed, the workflow's in-flight
  `Recv` returns with the resolved payload, the slot is closed, the audit row
  is written, and **then** the workflow halts at the next `Recv` (the next
  stage's wait), which is where the cancellation surfaces. The current slot's
  work is recorded; the next stage does not dispatch.
- `CancelWorkflow` returns `error` (`NonExistentWorkflowError` if the workflow
  isn't found). The mutation handler maps this to `TASK_ALREADY_TERMINAL`
  when the task is in a terminal state, per Q5.

**Alternatives considered**:
- **Custom `cancel_requested` flag** on `tasks` polled by the workflow.
  Rejected — would duplicate DBOS's existing cancel machinery, and the
  polling cadence would be either too aggressive (wasted DB load) or too lazy
  (cancel takes seconds to land).
- **Force-kill the DBOS workflow** via `context.Cancel`. Rejected — DBOS's
  `CancelWorkflow` already plumbs cancellation through correctly, and the
  step-boundary semantics are *desirable* (they're what gives us the Q2
  policy for free).

---

## R3. Audit-write atomicity — same SQL transaction, not separate DBOS step

**Decision**: Every lifecycle state transition or stage advance is implemented
as a single DBOS step (`dbos.RunAsStep`) whose body opens one `pgx.Tx`,
executes the `UPDATE tasks SET state = …` (or `current_stage = …`) and the
`INSERT INTO audit_messages …` in the same transaction, then commits. If the
audit insert fails, the transaction rolls back and DBOS reports the step as
failed — the workflow retries the step per DBOS's at-least-once semantics
until it succeeds. State writes that succeed without a matching audit row are
**structurally impossible** under this pattern (FR-002).

**Rationale**:
- Phase 0 already has `audit_messages` and the IDs-only `notify_event` trigger;
  the trigger fires on insert regardless of how the row arrives, so the
  single-tx pattern composes cleanly with the realtime seam.
- DBOS at-least-once step semantics + the `in_reply_to` uniqueness (a
  retransmitted audit row carries an idempotent `audit_messages.id` generated
  before the tx starts) make the retry safe.

**Alternatives considered**:
- **Two-step pattern** (state UPDATE → audit INSERT in separate DBOS steps).
  Rejected — opens a window where state has advanced but audit has not, which
  the spec explicitly forbids ("the transition MUST NOT be considered to have
  happened" if the audit write fails).
- **Outbox table + drain worker**. Rejected — adds machinery the spec doesn't
  need at this scale (single household, single owner, low volume), and the
  audit DAG is a first-class artifact, not eventual data.

---

## R4. Task-state enum rename — `ALTER TYPE … RENAME VALUE`, additive migration

**Decision**: A new migration `db/migrations/00002_phase1_state_rename.sql`
runs `ALTER TYPE task_state RENAME VALUE 'eligible' TO 'waiting'`. Postgres
≥ 10 supports this; the change is **additive** in the contract-versioning
sense because no client has consumed `ELIGIBLE` from the GraphQL surface yet
(Phase 0 shipped read-only). Existing rows carrying the old value are
automatically renamed — `RENAME VALUE` is a metadata-only operation in PG;
no row rewrite, no downtime risk on a single-household DB.

**Column default change**: migration 00002 *also* sets the `tasks.state`
column default to `'accepted'` (was `'eligible'`, which after the rename
would become `'waiting'`). Owner-authored entry — the dominant Phase 1
path — should land in `'accepted'`, not the holding state. The intake path
(Phase 7) will explicitly insert with `state='proposed'`, so the default
never silently routes intake-born tasks to the wrong state. Recorded here
so the migration's intent is clear at audit time.

**Down migration** runs the inverse (`RENAME VALUE 'waiting' TO 'eligible'`).
This requires Phase 1 code to *not* be running at the time of down-migrate
(reasonable for a self-hosted single-box deployment) — if any task happens
to be sitting in `WAITING` it'd be renamed to `ELIGIBLE` on down-migrate,
which is acceptable for Phase 1's testing flows.

**Rationale**:
- The Q3 clarification settled the semantic mismatch: `ELIGIBLE` ("ready") was
  the wrong name for "waiting on conditions." Renaming now, while no client
  consumes the value, costs nothing; renaming later requires a deprecation
  cycle.
- `ALTER TYPE … RENAME VALUE` is single-statement, idempotent in spirit
  (guarded by `DO $$ BEGIN … EXCEPTION WHEN duplicate_object THEN NULL; END
  $$;`), and Goose-friendly.

**Alternatives considered**:
- **Add a new value `waiting`, keep `eligible` as deprecated**. Rejected —
  the Phase 0 audit log has no production-shaped consumers, so there's
  nothing to deprecate-against. Carrying two values would just be dead code.
- **Wait for Phase 7 to do the rename**. Rejected — Phase 7 starts the
  predicate's real life; the enum needs the right name *before* that, and
  Phase 1 is the natural place because it's the first phase that operates the
  state machine.

---

## R5. Chain workflow registration & owner-authored creation

**Decision**: A new function `durable.RegisterChainWorkflow(dctx, deps …)`
registers the chain workflow with DBOS during startup, between `Init` and
`Launch`. Owner-authored task creation (`core.CreateTask`) runs in a single
DB transaction that (a) inserts the `tasks` row at `state='ACCEPTED'`,
`current_stage='CREATION'`, (b) inserts the `chain_workflows` row with the
deterministic `dbos_workflow_id = "chain:<task_uuid>"`, (c) writes the
initial `audit_messages` row, then commits. After commit, `core.CreateTask`
calls `dbos.RunWorkflow(dctx, chain.ChainWorkflow, taskID,
dbos.WithWorkflowID("chain:" + taskID.String()))` to kick the workflow off.

**Rationale**:
- Pre-creating the `chain_workflows` row before `RunWorkflow` means the
  partial-unique index (Phase 0: one live per task) is honoured atomically.
- Using a *deterministic* workflow ID lets the `cancelTask` mutation address
  the workflow without needing a row lookup if the table is missing (defensive
  fallback) — but the row lookup is still the authoritative path.
- DBOS's `RunWorkflow` is idempotent against a given workflow ID; if the row
  insert succeeds but the `RunWorkflow` call gets retried due to client retry,
  DBOS returns a handle to the existing workflow rather than starting a
  second.

**Alternatives considered**:
- **Run the chain workflow *as* the create operation** (no separate insert
  of `chain_workflows`). Rejected — the workflow's first step would have to
  write its own `chain_workflows` row, which complicates recovery
  semantics; explicit pre-creation is simpler.
- **Lazy attachment** (workflow attaches on first stage advance, not on
  create). Rejected — would make the spec's "owner-authored creation
  attaches a chain workflow" (FR-006) probabilistic depending on whether the
  workflow has started, which interacts badly with `cancelTask` immediately
  after `createTask`.

---

## R6. Mutation surface — `createTask` lands now (additive to `graphql.v1`)

**Decision**: Add `createTask(title: String!, description: String): Task!` as
the owner-authored creation mutation (FR-018). The Phase 0 spec deferred
"intent-named mutations beyond the minimal create/seed path" to Phase 2,
but Phase 1 needs a GraphQL entry point that *attaches the chain workflow on
creation* — that's a behaviour change from Phase 0's CLI-only `tendant seed`,
which still works for tests and scripts but does not attach a chain
workflow.

**Rationale**:
- The four mutations the spec calls out (`completeTask`, `cancelTask`,
  `acceptProposedTask`, `dismissProposedTask`) all assume a task already
  exists. Without `createTask`, the only way to get a task into the chain is
  via the seed CLI — that's fine for tests but blocks the spec's US1
  scenarios that drive the chain *over GraphQL*.
- Adding one mutation is additive (Principle VII). It is "intent-named" in the
  Phase 2 sense (one verb, one outcome).

**Alternatives considered**:
- **Defer `createTask` to Phase 2 and drive Phase 1 entirely from the seed
  CLI**. Rejected — the spec's user stories are written in terms of
  "the owner creates a task via … then `completeTask(taskId, result)` …" and
  pivoting the create step to a different surface than the completion step
  would make the demo lopsided.
- **Extend the `tendant seed` CLI to attach a workflow**. Rejected — moves
  GraphQL-equivalent behaviour out of GraphQL; obscures the operator-edge
  contract.

---

## R7. Stage default `ask` text — concrete strings

**Decision**: Per Q4, each stage carries a baked-in default `ask` string. The
specific Phase 1 wording is:

| Stage | Default `ask` |
|---|---|
| `TRIAGE` | "Triage this task: confirm it's real and decide on its categories." |
| `EXPANSION` | "Expand this task into actionable sub-tasks or required inputs." |
| `EXECUTION` | "Execute this task and record the outcome." |

`CREATION` and `COMPLETION` have no `ask` because they have no occupant in
Phase 1 (genesis and finalization respectively).

**Rationale**:
- Short, action-oriented, and stage-appropriate (Q4 said "stage-default
  text").
- Phase 6 agents will override these with authored asks; until then, the
  default is what's persisted and what an operator-UI consumer would
  display.

**Alternatives considered**:
- Longer multi-sentence prompts. Rejected as premature — agents will own the
  ask wording later, and operator-UI surface is Phase 2 so the precise
  wording is low-stakes.

---

## Open items (carried to plan.md / tasks.md, not blocking)

- **Stage-default ask wording** (R7) is a knob that can be tuned without contract
  churn — kept in `internal/chain/stages.go`, not in `data-model.md`.
- **Readiness predicate body** — spec Open Question Q1; deferred to before
  Phase 7. The seam lands in `chain.evaluateReadiness(taskID) bool` returning
  `true` unconditionally in Phase 1.
