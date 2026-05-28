# Quickstart — Phase 1 Task Lifecycle & Chain Skeleton

Prerequisite: Phase 0 boot path works (`make up` → `localhost:8080/healthz` is
green). This quickstart drives the new Phase 1 behaviour through GraphQL.

```sh
direnv allow                # devenv shell (Go 1.25, Postgres+pgvector, sqlc, goose, just)
make up                     # Postgres + tendant core; migrations 00001 + 00002 apply
curl -fsS localhost:8080/healthz
```

A GraphQL client (any) is needed for the walkthrough below; the examples use
`curl` over the `/graphql` endpoint.

---

## 1. Owner-authored task walks the chain to `DONE` (US1)

```graphql
mutation Create {
  createTask(title: "Plan Saturday errands") {
    id  state  currentStage  workflow { id startedAt }
    openAssignment { id stage ask }
  }
}
```

Expected response: a task in `state: ACCEPTED`, `currentStage: TRIAGE` (the
chain workflow already advanced past `CREATION`), with `workflow` non-null
(`id` = `"chain:<task-uuid>"`) and an `openAssignment` of stage `TRIAGE` whose
`ask` is the stage-default text.

```graphql
mutation TriageDone {
  completeTask(taskId: "<task-id>", result: { categorized: true, kind: "personal" }) {
    id state currentStage
    openAssignment { id stage ask }
  }
}
```

Expected: `currentStage: EXPANSION`, a fresh `openAssignment` of stage
`EXPANSION`. The previous assignment row has `resolvedAt` set.

Repeat for `EXPANSION` and `EXECUTION`:

```graphql
mutation ExpansionDone {
  completeTask(taskId: "<task-id>", result: { subtasks: ["buy milk", "fix shelf"] }) {
    state currentStage openAssignment { stage }
  }
}
mutation ExecutionDone {
  completeTask(taskId: "<task-id>", result: { done: true }) {
    state currentStage openAssignment { stage }
  }
}
```

After `ExecutionDone`: `state: EXECUTING` → `state: DONE`,
`currentStage: COMPLETION`, `openAssignment: null`, `workflow` still present
(but the underlying `chain_workflows.ended_at` is now set).

**Audit DAG check (psql)**:

```sql
SELECT id, kind, payload->>'from' AS s_from, payload->>'to' AS s_to,
       in_reply_to FROM audit_messages
WHERE task_id = '<task-id>' ORDER BY at;
```

Expected: a contiguous sequence of `state_transition` and `stage_advance`
rows, plus `assignment_created` / `assignment_resolved` pairs whose
`in_reply_to` links resolutions to their creations.

---

## 2. Cancel mid-chain → `HALTED` (US2)

Create a task, advance it to (say) `EXPANSION`, then cancel:

```graphql
mutation Cancel { cancelTask(taskId: "<task-id>") { id state currentStage } }
```

Expected: `state: HALTED`. The `currentStage` is whatever stage was last
audited before the cancel — `EXPANSION` in this example. The `chain_workflows`
row has `status: 'cancelled'`, `ended_at` set. A `workflow_cancelled` audit
row exists with `in_reply_to` pointing at the most recent prior transition.

```graphql
# This MUST fail with "task is HALTED" (or similar typed error):
mutation TooLate {
  completeTask(taskId: "<task-id>", result: {}) { id }
}
```

```graphql
# This MUST fail with TASK_ALREADY_TERMINAL:
mutation CancelTwice { cancelTask(taskId: "<task-id>") { id } }
```

---

## 3. Complete-vs-cancel race (US2 + Q2)

In two terminals: paste `completeTask` and `cancelTask` and submit
simultaneously (or use `xargs -P 2` against `curl`). Expected outcome:

- The current-slot `completeTask` succeeds; its audit row is recorded.
- The next stage does **not** open a new assignment.
- The task ends in `state: HALTED` with the completed slot recorded.

This is the Phase 1 Q2 policy (complete-wins-on-current-slot,
halt-before-next-stage) falling out naturally from DBOS's step-boundary
cancellation.

---

## 4. Kill the core mid-wait, restart, chain resumes (US3 / SC-003)

```sh
# Terminal 1: start the core. Create a task; let it pause at TRIAGE.
make up

# (Use the GraphQL client to call createTask, then verify openAssignment is non-null.)

# Terminal 2: forcibly kill the core process.
pkill -9 tendant   # or: kill -9 <pid-of-tendant>

# Terminal 1: bring it back up.
make up

# In psql or via GraphQL, query the task — it MUST still be paused on the same
# assignment (same id), and chain_workflows.status MUST still be 'pending'.
```

Now resolve the slot:

```graphql
mutation TriageAfterRestart {
  completeTask(taskId: "<task-id>", result: { categorized: true }) {
    state currentStage openAssignment { stage }
  }
}
```

Expected: the chain advances exactly once across the kill/restart boundary;
the assignment is resolved with the submitted result; no duplicate
assignment or audit row exists.

There is also a shell scenario for CI under `scripts/dbos-recovery-demo.sh`
(extended from Phase 0) that automates a similar kill-and-restart sequence
against the chain workflow.

---

## 5. The wait primitive is generic (US5 / SC-004)

Run the dedicated unit test:

```sh
go test ./services/api/internal/chain/... -run TestWaitPrimitive_IsGeneric -v
```

This test creates a DBOS workflow with an arbitrary key (not a stage, not a
task) that calls `Recv(topic="synthetic")`, then resolves it with `Send`. The
test asserts the wait resolves exactly once with the resolver's payload —
proof that the same primitive that backs `agent_assignments` works for any
caller (later: approvals, tool results, sub-agent questions).

---

## 6. PROPOSED-task surface lands but isn't exercised (FR-017)

```graphql
# These mutations exist and the schema validates, but Phase 1 has no PROPOSED tasks.
# They become exercisable when Phase 7 intake produces PROPOSED tasks.
mutation Accept { acceptProposedTask(taskId: "<id>") { state } }
mutation Dismiss { dismissProposedTask(taskId: "<id>", reason: "spam") { state } }
```

`tendant seed -title=…` from Phase 0 still works for tests that need a
task without going through GraphQL; its behaviour is unchanged.
