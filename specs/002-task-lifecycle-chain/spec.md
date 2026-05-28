# Feature Specification: Phase 1 — Task Lifecycle & Chain Skeleton (Human-Only)

**Feature Branch**: `002-task-lifecycle-chain`
**Created**: 2026-05-27
**Status**: Draft
**Input**: Build-plan entry "Phase 1 — Task Lifecycle & Chain Skeleton (Human-Only)"
(size M, depends on Phase 0). Grounded in `docs/tendant-architecture-spec-v2.md` §3
(stage chain; verbs-vs-nouns), §4 (domain model), §6 (orchestration & the one durable
primitive), §11.3 (assignments), §14.3–14.4 (sequence flows), §15 open Q2 (readiness
conditions), Appendix D (`Router`, `AgentRunner`, chain workflow sketch).

> Phase 0 landed the full data spine (Appendix A) and a read-only GraphQL surface; this
> phase adds **behavior** — the lifecycle state machine, the durable chain workflow, one
> generic wait-on-event primitive, hand-off via `agent_assignments`, and cancel-only
> halting — **with the human routed into every stage slot.** No LLM, no real agents, no
> gate; those land in later phases (6, 3). The headline invariant exercised here is
> *emergent autonomy*: the same chain that will later host agents runs today with zero
> stored autonomy because the router stub always returns the human.

## Clarifications

### Session 2026-05-27

- Q: Should owner-authored tasks enter at `ACCEPTED` (uniform path) or skip to
  `ELIGIBLE` (two entry paths)? → A: Enter at `ACCEPTED`. The normal flow is kept
  unless it actively doesn't make sense; a human creating a task does not by itself
  mean the task is workable right now, so the `ACCEPTED → ELIGIBLE` gate still has
  meaning even for owner-authored tasks.
- Q: When `cancelTask` and `completeTask` race on the same paused slot, which wins?
  → A: Complete wins on the current slot, then cancel halts before the next.
  Completed work should not be discarded — if the human did the work, record it —
  but the cancellation MUST still stop forward progress before the chain advances
  into the next stage. Net outcome: the assignment is resolved with the submitted
  result, the slot's audit row is written, then the task transitions to `HALTED`
  *before* the next stage's router/assignment runs.
- Q: How do lifecycle states pair with stage advances, and is `ELIGIBLE` the
  "ready" state or the "waiting on conditions" state? → A: States change at named
  boundaries (not 1:1 with stages); the post-expansion readiness predicate decides
  `EXECUTING` (conditions met) vs a *waiting* state (conditions not met).
  **Rename**: the Phase 0 enum value `task_state.eligible` is renamed to
  `task_state.waiting` via an additive migration in this phase, because `ELIGIBLE`
  ("ready to go") wrongly names what is actually the holding state for tasks
  whose readiness conditions have not yet been met. The state line becomes:
  `PROPOSED → ACCEPTED → (WAITING when predicate false) → EXECUTING → DONE`, with
  `HALTED` reachable from any non-terminal state. In Phase 1 the predicate is
  trivially true, so `WAITING` is structurally present in the enum and state
  machine but is **not entered** on the happy path — the task moves
  `ACCEPTED → EXECUTING` directly at the execution-stage boundary.
- Q: Is `CREATION` a real processing stage, and can `EXPANSION` loop back to
  `TRIAGE`? → A: `CREATION` is retained in the `chain_stage` enum but is a
  genesis marker only — no occupant, no router call; the chain workflow's first
  real stage is `TRIAGE`. The chain in Phase 1 is strictly linear:
  `CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION`. The
  `EXPANSION → TRIAGE` back-edge is a recognised future need (expansion may
  discover that further categorisation is required) but is **deferred** — it is
  not implemented in Phase 1; the seam will be added when real agents land
  (Phase 6+).
- Q: What fills the non-null `AgentAssignment.ask` field when the router routes
  the human into a stage slot in Phase 1? → A: Stage-default text. The chain
  workflow writes a stage-appropriate default `ask` string when creating each
  assignment (e.g., "Triage this task: confirm it's real and categorise it.",
  "Expand this task into actionable sub-tasks.", "Execute this task."). This
  gives Phase 2's operator UI and audit log readers something meaningful to
  display on day one, and previews the Phase 6 shape where real agents will
  author asks the same way (overriding the default). The exact wording of the
  defaults is a `plan.md` detail.
- Q: `cancelTask` on an already-terminal task — no-op or error? → A:
  Clearly-typed error (e.g., `TASK_ALREADY_TERMINAL`). Explicit contract over
  silent success: a no-op `cancelTask` on a `DONE` task would emit a misleading
  "success" signal. Callers who want idempotent behaviour can catch the typed
  error.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An owner-authored task walks the chain to `DONE` (Priority: P1)

The owner creates a bare task. The chain workflow attaches; the task starts in
state `ACCEPTED` and stage `CREATION`, immediately advances past the genesis stage
to `TRIAGE`, walks through `EXPANSION`, evaluates the (trivially-true in Phase 1)
readiness predicate and transitions to `EXECUTING` at the `EXECUTION` stage. At
each stage that needs an occupant the system routes to the human and produces an
`agent_assignments` row. The owner completes each slot in turn; the chain advances
to the next stage; when `COMPLETION` finishes the task reaches `DONE`. The audit
DAG records every transition.

**Why this priority**: This is the phase's headline capability — proves the spine
(state machine + stage tracking + chain workflow + generic durable wait + hand-off)
end-to-end with the lowest-risk occupant (the human), before any agent exists.

**Independent Test**: Create a task via the owner-authored path; observe an
`agent_assignments` row appear for the first chain stage that needs a human;
`completeTask(taskId, result)` on it; observe the next stage's assignment appear;
repeat to the end; assert the task ends `state='DONE'`, `current_stage='COMPLETION'`,
and that the audit DAG contains a contiguous sequence of transition messages.

**Acceptance Scenarios**:
1. **Given** a booted core with the seeded owner, **When** the owner creates a task,
   **Then** the task persists with `state='ACCEPTED'`, `current_stage='CREATION'`,
   and a `chain_workflows` row links it to a live DBOS workflow. The chain workflow
   then advances `current_stage` past `CREATION` (a genesis marker with no occupant)
   to `TRIAGE` while `state` remains `ACCEPTED`.
2. **Given** a task that has just entered the chain, **When** the chain workflow
   reaches a stage that needs a human, **Then** an `agent_assignments` row is inserted
   with `{stage, from_principal=null, ask, gathered_context={}}` and an `audit_messages`
   row records the routing decision.
3. **Given** an open assignment, **When** `completeTask(taskId, result)` is called,
   **Then** the corresponding `wait-on-event` resolves, the assignment is marked
   resolved, `current_stage` advances to the next stage, the task `state` updates
   if a state boundary is crossed (e.g., `ACCEPTED → EXECUTING` at the
   `EXPANSION → EXECUTION` boundary when the readiness predicate is true), and a
   transition `audit_messages` row is written.
4. **Given** the last stage slot is completed, **When** the chain workflow's
   `completion` step finishes, **Then** the task reaches `state='DONE'`, `current_stage`
   ends at `COMPLETION`, the `chain_workflows.ended_at` is set, and the final
   `audit_messages` row records `DONE`.

### User Story 2 - The owner cancels a task mid-chain to `HALTED` (Priority: P1)

While a task is paused on a human slot, the owner cancels it. The DBOS workflow stops
(`dbos.Cancel`), the task transitions to `state='HALTED'`, no further stage advances
or assignments occur, and **nothing already committed is reversed.** The audit DAG up
to the cancellation remains intact.

**Why this priority**: Cancel-only safety (Principle V) is a core invariant: forward
progress halts, nothing rolls back. It must work the first day chains run, before
Phase 3's gate exists — and is safe today precisely because no scary outward effect
has happened yet.

**Independent Test**: Create a task, advance it until an `agent_assignments` row is
open, call `cancelTask(taskId)`; assert the DBOS workflow shows cancelled,
`state='HALTED'`, no new assignments fire, the prior audit messages still exist, and
a cancellation `audit_messages` row is appended.

**Acceptance Scenarios**:
1. **Given** a task paused on a human slot, **When** `cancelTask(taskId)` is called,
   **Then** the underlying DBOS workflow is cancelled and the task transitions to
   `state='HALTED'`.
2. **Given** a halted task, **When** the system is inspected after cancellation,
   **Then** no new stage transitions, assignments, or audit transitions are written
   beyond the cancellation record.
3. **Given** a halted task, **When** the audit DAG is read, **Then** every prior
   transition message is still present (no rewrite, no deletion).
4. **Given** a halted task, **When** `completeTask` is attempted on its open
   assignment, **Then** the call MUST fail with a clear "task is HALTED" error and no
   side effects.

### User Story 3 - The chain workflow survives a forced restart while waiting (Priority: P2)

A task is paused at a stage slot — i.e. the chain workflow is blocked on the durable
wait. The core process is killed (`SIGKILL`/`kill -9`) and restarted. After restart
the same workflow is recovered and is once again blocked on the same wait, addressing
the same assignment. When the owner completes the slot, the chain resumes correctly.

**Why this priority**: The "one durable primitive" property of the system depends on
the wait surviving process death. Phase 0 proved DBOS crash-recovery in the abstract;
Phase 1 proves it for the wait shape the rest of the system will reuse (approvals,
tool results, sub-agent questions).

**Independent Test**: Create a task; let it reach a paused human slot; kill the core
process; restart; assert the chain workflow status is "running" (or DBOS's equivalent
for recovered+waiting), the same `agent_assignments` row is still open, and a
subsequent `completeTask` resolves the wait and advances the chain.

**Acceptance Scenarios**:
1. **Given** a task paused on a human slot, **When** the core process is forcibly
   killed and restarted, **Then** the chain workflow is recovered and is again
   waiting on the same assignment key (no duplicate assignment is created).
2. **Given** the recovered workflow, **When** `completeTask` resolves the open
   assignment, **Then** the chain advances exactly once (the wait is satisfied
   exactly once across the kill/restart boundary).
3. **Given** a halted task, **When** the core process is killed and restarted,
   **Then** the workflow remains cancelled — restart does not revive halted work.

### User Story 4 - The audit DAG records every lifecycle and stage transition (Priority: P2)

Each lifecycle state change (`ACCEPTED→EXECUTING`, `ACCEPTED→WAITING`,
`WAITING→EXECUTING`, `…→DONE`, `…→HALTED`, etc.) and each stage advance writes an
`audit_messages` row. Routing
decisions and assignment resolutions also write audit rows. Reply chains link
related events via `in_reply_to`, so the audit forms a DAG, not a flat log
(Principle VI, CC-1 seam).

**Why this priority**: The audit is non-negotiable (Principle VI). Phase 1 is the
first phase that *generates* transition events, so the audit-writing discipline must
be in place from the very first transition.

**Independent Test**: Drive a task through the full chain to `DONE`. Read the audit
messages for that task; assert there is at least one row for each lifecycle
transition and one for each stage advance; assert that an assignment resolution
message has `in_reply_to` pointing to the assignment-created message it answers.

**Acceptance Scenarios**:
1. **Given** any lifecycle state transition, **When** it commits, **Then** an
   `audit_messages` row is written in the same logical step (Principle VI: this write
   is non-negotiable). If the audit write fails, the transition MUST NOT be considered
   to have happened.
2. **Given** an assignment is created and later resolved by `completeTask`, **When**
   the audit DAG is read, **Then** the resolution row's `in_reply_to` references the
   creation row's id.
3. **Given** a cancellation, **When** the audit is read, **Then** a `HALTED`
   transition row exists with `in_reply_to` pointing at the most recent prior
   transition (the chain it stops).

### User Story 5 - The durable wait primitive is generic, not human-specific (Priority: P3)

The wait-on-event primitive backing the human-slot pause is implemented once,
generically, by `{waitKey, payload}`. Any later caller — an approval pause (Phase 3),
a tool-result pause (Phase 3), a sub-agent question (Phase 9) — can use the **same**
primitive by minting a unique wait key and resolving it from a different mutation,
with no changes to the wait machinery itself.

**Why this priority**: This is the architectural property the whole orchestration
layer depends on. It is verified now, when adding the *second* caller would otherwise
silently fork into a human-specific implementation.

**Independent Test**: Read the implementation surface of the wait/resume primitive
and confirm it has no human, assignment, or stage parameter — only a key and a
payload. Write a synthetic test (not exposed via GraphQL) that creates a wait under
an arbitrary key and resolves it; assert it behaves identically to the assignment
path.

**Acceptance Scenarios**:
1. **Given** the wait/resume primitive's public surface, **When** it is reviewed,
   **Then** it MUST NOT take a stage, assignment id, or principal as a parameter —
   only a key and an arbitrary payload.
2. **Given** an arbitrary wait key, **When** a synthetic caller waits on it and
   another caller resolves it, **Then** the wait resolves exactly once with the
   resolver's payload — independent of any task, assignment, or stage.
3. **Given** the same primitive backs both human-wait (this phase) and the
   placeholder gate/tool-result/sub-agent-question paths, **When** later phases add
   those callers, **Then** they MUST require no new wait machinery.

### Edge Cases

- **Re-entering creation via owner path**: an owner-authored task MUST bypass
  `PROPOSED` and enter at the post-triage entry state; only intake-born tasks (Phase 7)
  reach `PROPOSED`. `acceptProposedTask` / `dismissProposedTask` mutations ship now per
  Principle VII (additive contract) but exercise no live tasks until intake exists.
- **Double-complete**: `completeTask` called twice on the same assignment MUST succeed
  at most once; the second call returns a clear "already resolved" error without
  advancing the chain or writing a duplicate transition.
- **Complete on the wrong task or stage**: `completeTask` whose `taskId` does not
  match an open assignment, or whose task is `HALTED` / `DONE` / `DISMISSED`, MUST
  fail without side effects.
- **Cancel an already-terminal task**: `cancelTask` on a task already `DONE`,
  `DISMISSED`, or `HALTED` MUST return a clearly-typed error
  (e.g., `TASK_ALREADY_TERMINAL`) — never a silent no-op, never a
  re-cancellation that emits a second audit row.
- **Restart between assignment insert and trigger fire**: even if the IDs-only
  `pg_notify` from Phase 0 is missed by an in-process listener, the assignment row
  itself is durable; on restart the workflow is again waiting on its key, and any
  listener that comes up rediscovers the open assignment by query.
- **Workflow recovers but the wait key is unknown**: if a recovered workflow's wait
  key references an assignment that was deleted or corrupted, the workflow MUST fail
  loudly rather than silently advance — Phase 1 has no auto-repair semantics.
- **Race: cancel during complete**: if `cancelTask` and `completeTask` arrive
  concurrently on the same paused slot, **complete wins on the current slot, then
  cancel halts before the next.** Completed work is not discarded — the slot's
  assignment is resolved with the submitted result and its audit row is written —
  but the task MUST transition to `HALTED` before the next stage's router or
  assignment runs. Both mutations succeed; the final state is `HALTED` with the
  resolved slot recorded.
- **Trivial readiness**: the post-expansion readiness predicate is trivially true
  in Phase 1, so `WAITING` is structurally part of the state machine but never
  entered on the happy path — tasks advance `ACCEPTED → EXECUTING` directly at the
  execution-stage boundary. The seam exists so a later predicate (time /
  dependency / data) can plug in before Phase 7 starts auto-accepting intake-born
  tasks; once it does, `ACCEPTED → WAITING → EXECUTING` becomes live.

## Requirements *(mandatory)*

### Functional Requirements

**Lifecycle state machine (`tasks.state`)**

- **FR-001**: The set of legal state transitions MUST be enforced as a state machine
  centered on `tasks.state` (enum from Phase 0, with `eligible` renamed to `waiting`
  in Phase 1 — see Dependencies). The legal edges are: owner-authored entry →
  `ACCEPTED`; `ACCEPTED → EXECUTING` (when the readiness predicate is true at the
  execution-stage boundary); `ACCEPTED → WAITING` (when the predicate is false);
  `WAITING → EXECUTING` (when the predicate later becomes true); `EXECUTING →
  DONE`; any non-terminal state → `HALTED` (via cancel); `PROPOSED → ACCEPTED`
  (via `acceptProposedTask`, exercised in Phase 7); `PROPOSED → DISMISSED` (via
  `dismissProposedTask`, exercised in Phase 7). All other transitions MUST be
  rejected. In Phase 1 the readiness predicate is trivially true, so `WAITING` is
  not entered on the happy path; the state and its edges still exist and MUST be
  enforced.
- **FR-002**: Every state transition MUST write one `audit_messages` row in the same
  logical step. If the audit write fails, the transition MUST NOT be considered to
  have happened (Principle VI: the audit write is non-negotiable).
- **FR-003**: Terminal states (`DONE`, `DISMISSED`, `HALTED`) MUST be sinks — no
  outbound transitions are legal from them.

**Stage tracking (`tasks.current_stage`)**

- **FR-004**: `current_stage` MUST advance along the fixed linear chain
  `CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION` in Phase 1. The shape
  MUST be a property of the workflow, not configurable per task. `CREATION` is a
  genesis marker (the default value newly-created rows carry from Phase 0) and
  has no occupant or router call — the workflow advances past it immediately to
  `TRIAGE`. `COMPLETION` is a finalization step that records `DONE` and closes
  the workflow; it likewise has no occupant in Phase 1. The `EXPANSION → TRIAGE`
  back-edge (re-triage) is a recognised future need but is **out of scope** for
  Phase 1 — see *Out of Scope* below.
- **FR-005**: Stage advances MUST be distinct from state transitions — multiple
  stage advances can occur within a single lifecycle state (e.g., `ACCEPTED`
  spans `CREATION → TRIAGE → EXPANSION`; `EXECUTING` spans `EXECUTION →
  COMPLETION`). Both axes MUST update independently and both MUST be audited.

**The DBOS chain workflow**

- **FR-006**: A single DBOS workflow ("chain workflow") MUST drive a task through the
  stage chain. Owner-authored task creation MUST attach exactly one live chain
  workflow to the task (`chain_workflows` row, partial-unique while `ended_at IS NULL`
  from Phase 0).
- **FR-007**: The chain workflow MUST, at each stage that needs an occupant, call a
  router function and dispatch on the result. In Phase 1 the router function MUST be
  a stub that always returns the human; the agent branch MUST exist as a code path
  but MUST behave as "route to human" or "not implemented yet" (Phase 6 replaces this
  with real specialist selection).
- **FR-008**: The chain workflow MUST be cancellable via `dbos.Cancel(workflowID)`
  and MUST tolerate cancellation at any await point without leaving the task in an
  inconsistent two-axis state (lifecycle + stage).

**The one durable wait-on-event primitive**

- **FR-009**: Exactly one durable wait/resume primitive MUST be implemented — keyed
  by an opaque `waitKey`, carrying an opaque `payload`, with no awareness of
  assignments, stages, principals, or task identity. This primitive MUST be the seam
  later used by approvals (Phase 3), tool results (Phase 3), and sub-agent questions
  (Phase 9).
- **FR-010**: A wait key MUST be unique to a single wait instance; resolving a key
  twice MUST resolve the wait exactly once, with the loser receiving a clear
  "already resolved" error.
- **FR-011**: A wait MUST survive a forced restart of the core process — on recovery
  the workflow is re-blocked on the same key with no duplicate assignment, decision,
  or transition emitted.

**Hand-off via `agent_assignments`**

- **FR-012**: When the router returns the human for a stage, the chain workflow MUST
  insert an `agent_assignments` row with `{stage, from_principal=null,
  ask=<stage-default text>, gathered_context={}}` (the row's `AFTER INSERT` trigger
  from Phase 0 fires the IDs-only `pg_notify`). The `ask` MUST be the stage's
  default prompt — a short, action-oriented sentence appropriate to the stage
  (`TRIAGE` / `EXPANSION` / `EXECUTION`). Exact default wording is a `plan.md`
  detail; the requirement is that the field is non-empty and stage-specific.
  The workflow MUST then block on a wait whose key derives deterministically from
  `{taskId, stage}` (or the assignment id) so recovery finds the same wait.
- **FR-013**: Exactly one assignment per stage slot MUST be live at any moment for a
  given task. An open assignment that has not been resolved or cancelled MUST be
  rediscoverable by query on restart.
- **FR-014**: For owner-authored tasks in Phase 1, every stage assignment MUST carry
  `from_principal=null` and `gathered_context={}` (no upstream agent has provided
  context yet); Phase 6 will populate these.

**Mutations (additive GraphQL surface)**

- **FR-015**: A `completeTask(taskId: ID!, result: JSON): Task!` mutation MUST
  resolve the open `agent_assignments` row for the given task by resolving the
  underlying wait with `result` as the payload, allowing the chain workflow to
  advance. Mismatched / missing / already-resolved assignments MUST error without
  side effects.
- **FR-016**: A `cancelTask(taskId: ID!): Task!` mutation MUST call
  `dbos.Cancel(workflowID)` on the live chain workflow and mark the task `HALTED`.
  There MUST be no rollback of prior effects (Principle V). The mutation MUST be
  safe to call on any non-terminal state and MUST return a clearly-typed error
  (e.g., `TASK_ALREADY_TERMINAL`) on terminal states (`DONE`, `DISMISSED`,
  `HALTED`) — never a silent no-op. When a `cancelTask` races a `completeTask`
  on the same paused slot, the in-flight `completeTask` MUST still resolve the
  slot (its result and audit row are recorded), then the workflow MUST halt
  *before* dispatching the next stage — the cancellation takes effect at the
  next-stage boundary, not by discarding completed work.
- **FR-017**: `acceptProposedTask(taskId: ID!): Task!` and
  `dismissProposedTask(taskId: ID!, reason: String): Task!` mutations MUST land in
  the GraphQL contract additively (Principle VII), even though no `PROPOSED` task
  exists yet — they will be exercised once intake (Phase 7) creates `PROPOSED` tasks.
  `acceptProposedTask` MUST transition `PROPOSED → ACCEPTED` and start a chain
  workflow; `dismissProposedTask` MUST transition `PROPOSED → DISMISSED` without
  starting one.
- **FR-018**: An owner-authored task creation path MUST exist that creates the task
  in a non-`PROPOSED` entry state, attaches a chain workflow, and writes the initial
  audit row. Whether this is exposed as a new GraphQL `createTask` mutation or
  extends the Phase 0 seed/Go-core path is a `plan.md` decision; the *behavior* —
  chain attaches on owner-authored creation — is required here.

**Eligibility seam**

- **FR-019**: The post-expansion **readiness predicate** MUST be evaluated for
  every task — including owner-authored tasks — via a clearly-named seam
  (function / hook / strategy slot) where a real predicate (time / dependency /
  data) can later be plugged in. On `true`, the task transitions
  `ACCEPTED → EXECUTING` and the chain advances into `EXECUTION`. On `false`, the
  task transitions `ACCEPTED → WAITING` and holds; when the predicate later
  becomes true, the task transitions `WAITING → EXECUTING` and the chain
  resumes. In Phase 1 the predicate evaluates to true unconditionally — the gate
  still runs but always passes. The shape and admissible inputs of the predicate
  (and the re-evaluation trigger for `WAITING → EXECUTING`) are an open question
  (Q1 below) to be settled before Phase 7 begins auto-accepting intake-born
  tasks.

**Audit DAG**

- **FR-020**: An assignment-resolution audit row MUST set `in_reply_to` to the id of
  the audit row that recorded the assignment creation. A cancellation audit row MUST
  set `in_reply_to` to the most recent prior transition row in that task's chain.
  This makes the per-task audit a DAG, not a flat log (Principle VI).

### Key Entities

The data spine landed in Phase 0; this phase activates these entities:

- **Task** (existing): now advances through the lifecycle state machine and the
  stage chain. Both `state` and `current_stage` are mutated by the chain workflow.
- **Chain Workflow** (existing): one live row per task while the workflow runs;
  closed (`ended_at` set) on `DONE`, `HALTED`, or `DISMISSED`.
- **Agent Assignment** (existing): one row per human-occupied stage slot in Phase 1;
  for owner-authored tasks, `from_principal=null` and `gathered_context={}`. Resolved
  by `completeTask`.
- **Audit Message** (existing): the message-shaped DAG of transitions, routing
  decisions, and resolutions. `in_reply_to` is used to link resolutions to the
  creations they answer (CC-1 seam).
- **Durable Wait** (new, internal): the single keyed wait/resume primitive backing
  every pause in the system. Not exposed via GraphQL; the assignment row is its
  external face this phase.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Across repeated trials, 100% of owner-authored tasks driven through
  the chain by completing each slot reach `state='DONE'`, `current_stage='COMPLETION'`,
  with `chain_workflows.ended_at` set and a complete audit DAG (every transition
  represented, no gaps).
- **SC-002**: Across repeated trials, 100% of `cancelTask` calls on non-terminal
  tasks land the task in `state='HALTED'` with no further transitions emitted, and 0
  prior audit messages mutated or deleted.
- **SC-003**: Across repeated forced-restart trials with a task paused on a human
  slot, the chain workflow is recovered and re-blocked on the same wait 100% of the
  time, with 0 duplicate assignments, decisions, or transitions emitted. The first
  subsequent `completeTask` advances the chain exactly once.
- **SC-004**: The wait/resume primitive's public signature contains only an opaque
  key and an opaque payload — no stage, assignment, principal, or task parameters
  (0 human-specific parameters). A synthetic test against an arbitrary key passes
  using the same primitive that backs `agent_assignments`.
- **SC-005**: For every successful state transition or stage advance in the system,
  exactly one `audit_messages` row exists; for every assignment created and resolved,
  the resolution row's `in_reply_to` points at the creation row. (Spot-checkable as
  a database invariant on any non-empty run.)

## Assumptions

- **Human in every slot**: the router is a stub that always returns the human. The
  agent branch in the chain workflow exists as a code path but is not exercised this
  phase — Phase 6 replaces the stub with real specialist selection (constitution
  Principle I, capability at the edges).
- **Owner-authored entry only**: `PROPOSED` is unreachable this phase because intake
  is Phase 7. `acceptProposedTask` / `dismissProposedTask` ship for additive contract
  reasons (Principle VII) but exercise no live tasks.
- **No outward effects yet**: no tools fire, no third-party APIs are called. Cancel
  is safe with zero rollback (Principle V) precisely because the hard-rule floor
  (Phase 3) has nothing to gate yet.
- **No autonomy promotion logic**: autonomy stays emergent and unsettable on `Task`
  (Phase 0's invariant). Phase 1 does not introduce stored autonomy in any form.
- **`gathered_context` empty for owner-authored**: human-only operation produces
  no upstream agent context; the field is `{}` until Phase 6 introduces agents that
  populate it.
- **Readiness predicate is trivially true**: gating is deferred; the seam is
  required, the predicate is not. `WAITING` exists in the enum and state machine
  but is not entered on the Phase 1 happy path. Open question Q1 below is
  settled before Phase 7.
- **No retries**: a workflow that fails non-cancellably for unexpected reasons (DB
  error, corrupt wait key) MUST fail loudly. There is no auto-retry, auto-skip, or
  auto-repair semantics in Phase 1.

## Dependencies & Out of Scope

**Dependencies / known constraints (for `plan.md`)**

- DBOS Go SDK: this phase first leans on `dbos.WaitForEvent`/equivalent and
  `dbos.Cancel`. The exact API names and the registration of the chain workflow on
  startup are settled in `plan.md`.
- **`task_state` enum rename (Phase 0 amendment)**: this phase ships an additive
  migration that renames the Phase 0 enum value `task_state.eligible` to
  `task_state.waiting` so the state name matches its meaning (the holding state
  for tasks whose readiness predicate has not yet been met). The rename touches
  the migration set, any sqlc/gqlgen output that mentioned `ELIGIBLE`, and the
  GraphQL `TaskState` enum. Per Principle VII (additive evolution), the GraphQL
  enum value is renamed in the v1 contract because no client has consumed the
  prior value yet; later, post-client, renames MUST be deprecation-shaped instead.
- Phase 0's `agent_assignments` and `audit_messages` tables and the IDs-only
  `notify_event` plumbing are reused without schema change. If any narrow addition is
  required (e.g., a resolved-at timestamp predicate, a deterministic wait-key column),
  it MUST be additive only.
- The contract-versioning discipline (Principle VII) becomes load-bearing this phase:
  the four new mutations (`completeTask`, `cancelTask`, `acceptProposedTask`,
  `dismissProposedTask`) and the existing read surface MUST evolve additively in the
  versioned `graphql.v1.graphqls` contract.
- Codegen drift: any new mutation widens both `gqlgen` output and the Go core
  surface; CI's drift check (FR-017 from Phase 0) MUST stay green.

**Out of scope (deferred)**

- **Real agents and the router** (Phase 6) — the stub returning the human is the
  contract this phase.
- **The hard-rule floor / gate** (Phase 3) — no tool calls happen yet; nothing to
  gate.
- **Operator UI / live inbox** (Phase 2) — drive this phase via GraphQL calls and
  tests; assignments are not yet *displayed* in any client. The `LISTEN`er and push
  worker that turn the Phase 0 triggers into UI/device wake-ups are still Phase 2.
- **Intake-born `PROPOSED` tasks** (Phase 7) — only owner-authored entry is live;
  the accept/dismiss mutations land additively but exercise nothing until intake.
- **Readiness predicate body** — the seam exists; the real predicate (time /
  dependency / data) and the `WAITING → EXECUTING` re-evaluation trigger are
  decided and added before Phase 7.
- **`EXPANSION → TRIAGE` back-edge (re-triage)** — recognised as a future need
  (expansion may discover that further categorisation is required) but **not
  built in Phase 1**. The chain is strictly linear this phase; the back-edge
  seam will be added when real agents land (Phase 6+).
- **Sub-agent question protocol** (Phase 9) — the wait-on-event primitive is built
  generically now so this can land later with no new machinery; the question shape
  itself is out of scope.
- **Calibration and tool-outcome maturation** (Phase 8) — `tool_outcomes` rows are
  Phase 3+; calibration reads them in Phase 8. No part of this phase emits them.

## Open Questions

- **Q1: Readiness predicate body and `WAITING → EXECUTING` trigger.** What gates
  readiness — time (don't start before X), dependency (waiting on another task),
  data (a missing input), or some combination? When the task is `WAITING`, what
  event causes the predicate to be re-evaluated (event-driven on some external
  signal, polled on an interval, or both)? The seam is required in Phase 1; the
  body and trigger MUST be decided and implemented before Phase 7 starts
  auto-accepting tasks. A predicate that reads task state may interact with the
  audit invariant (every transition writes a row), so its evaluation cadence
  belongs to that decision.
