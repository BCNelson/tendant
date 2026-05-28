# Data Model — Phase 1 Task Lifecycle & Chain Skeleton

Phase 0 landed the full Appendix A schema. Phase 1 changes **one enum value** and
**activates** several existing tables; no new tables are introduced.

---

## Schema changes (one additive migration)

### `db/migrations/00002_phase1_state_rename.sql`

```sql
-- +goose Up
-- +goose StatementBegin
ALTER TYPE task_state RENAME VALUE 'eligible' TO 'waiting';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TYPE task_state RENAME VALUE 'waiting' TO 'eligible';
-- +goose StatementEnd
```

PG ≥ 10 supports `ALTER TYPE … RENAME VALUE`; it is a metadata-only operation
(no row rewrite). Existing rows automatically reflect the new value. The down
migration is the exact inverse for repeatable up→down→up testing (Phase 0
SC-001).

---

## State machine

`tasks.state` (now: `proposed | accepted | waiting | executing | done |
dismissed | halted`) is enforced by `internal/lifecycle/machine.go`. Edges
are the only legal transitions; every transition writes one
`audit_messages` row in the same DB transaction (FR-002, R3).

```
                                    (owner-authored entry)
                                            │
                                            ▼
                  PROPOSED ─acceptProposedTask─▶ ACCEPTED
                     │                              │
                     │                              │ readiness predicate at
                     │                              │ end of EXPANSION stage
                     │                              │
              dismissProposedTask                   ├─true──▶ EXECUTING
                     │                              │
                     ▼                              └─false─▶ WAITING ──true──▶ EXECUTING
                 DISMISSED                                          ▲
                                                                    │
                                                              re-evaluate on
                                                              (TBD — Open Q1)
                                            EXECUTING ─completion done─▶ DONE

   Any non-terminal state ──cancelTask──▶ HALTED   (no rollback; Principle V)
```

**Edges (FR-001):**

| From | To | Trigger |
|---|---|---|
| (creation) | `ACCEPTED` | owner-authored `createTask` |
| `PROPOSED` | `ACCEPTED` | `acceptProposedTask` (exercised Phase 7) |
| `PROPOSED` | `DISMISSED` | `dismissProposedTask` (exercised Phase 7) |
| `ACCEPTED` | `EXECUTING` | chain workflow reaches execution-stage boundary, readiness predicate `true` |
| `ACCEPTED` | `WAITING` | chain workflow reaches execution-stage boundary, readiness predicate `false` |
| `WAITING` | `EXECUTING` | readiness predicate later becomes `true` (mechanism TBD — Open Q1) |
| `EXECUTING` | `DONE` | completion-stage finalization succeeds |
| any non-terminal | `HALTED` | `cancelTask` |

Terminal sinks (`DONE`, `DISMISSED`, `HALTED`) have no outbound edges
(FR-003). All other transitions MUST be rejected by
`lifecycle.Transition(...)` with a typed error.

In **Phase 1**, the readiness predicate is trivially `true`, so the happy path
is `(creation) → ACCEPTED → EXECUTING → DONE`. `WAITING` is structurally
present and enforced as a legal edge target but is not entered.

---

## Stage axis

`tasks.current_stage` (existing: `creation | triage | expansion | execution |
completion`) advances independently from `state`. Both are mutated by the chain
workflow; both are audited.

**Stage advances (FR-004):**

```
CREATION ──genesis (no occupant)──▶ TRIAGE
TRIAGE   ──completeTask resolves slot──▶ EXPANSION
EXPANSION──readiness predicate evaluated, completeTask resolves slot──▶ EXECUTION
EXECUTION──completeTask resolves slot──▶ COMPLETION
COMPLETION──finalization (no occupant)──▶ (workflow ends; state → DONE)
```

`CREATION` is a genesis marker with no occupant; the chain workflow advances
past it as its first step. `COMPLETION` is a finalization step with no
occupant; it writes the `DONE` state transition and closes the
`chain_workflows` row.

**State × stage joint table** (the spec's "verbs vs nouns" mapping for Phase 1):

| `current_stage` | `state` (happy path) |
|---|---|
| `CREATION` | `ACCEPTED` |
| `TRIAGE` | `ACCEPTED` |
| `EXPANSION` | `ACCEPTED` |
| `EXECUTION` | `EXECUTING` (predicate true) or `WAITING` (predicate false; not in Phase 1 happy path) |
| `COMPLETION` | `EXECUTING` → `DONE` at end |

---

## Activated entities

All from Phase 0; Phase 1 introduces no new tables. Field-level Phase 1
expectations:

### `tasks`
- `state`: now driven by `lifecycle.Transition`; never `eligible` (renamed to
  `waiting`).
- `current_stage`: now driven by the chain workflow; advances as above.
- `edited_at`: updated on every state or stage change.
- All other fields (`provenance`, `context_refs`, `findings`, etc.) remain as
  Phase 0 defined.

### `chain_workflows`
- One live row per task while the workflow runs (partial-unique index on
  `(task_id) WHERE ended_at IS NULL` from Phase 0).
- `dbos_workflow_id` MUST be `"chain:" + tasks.id::text` (deterministic; see
  research R5).
- `started_at` set on insert; `ended_at` set when the workflow reaches
  `DONE`, `HALTED`, or `DISMISSED`.
- `status` ('pending' | 'success' | 'cancelled' | 'error') mirrors DBOS's
  `WorkflowStatusType`.

### `agent_assignments`
- One row per human-occupied stage slot in Phase 1 (`TRIAGE`, `EXPANSION`,
  `EXECUTION`).
- `stage`: the chain stage value the slot is for.
- `from_principal`: NULL in Phase 1 (no upstream agent has handed off).
- `ask`: stage default text (research R7).
- `gathered_context`: `{}` in Phase 1 (no upstream agent context).
- `resolved_at`: set when `completeTask` resolves the slot.

### `audit_messages`
- Written by `lifecycle.Transition` in the same SQL tx as the state or stage
  write (R3).
- `kind`: one of `state_transition`, `stage_advance`, `assignment_created`,
  `assignment_resolved`, `workflow_started`, `workflow_cancelled`.
- `payload` (jsonb): `{"from": "ACCEPTED", "to": "EXECUTING", "stage":
  "EXECUTION", "reason": "readiness predicate true"}` shape — the exact shape
  per kind is detailed in `internal/lifecycle/audit.go`.
- `in_reply_to`:
  - For `assignment_resolved`: the id of the `assignment_created` audit row.
  - For `workflow_cancelled` / state→`HALTED`: the id of the most recent prior
    transition row for this task.
  - Otherwise: NULL on first transition; the prior transition row's id on
    subsequent transitions (forms the per-task spine of the DAG).

---

## GraphQL types (additive amendments to `graphql.v1.graphqls`)

See `contracts/graphql.v1.graphqls` for the full amended SDL. Phase 1 additions:

- `enum TaskState`: rename `ELIGIBLE` → `WAITING`.
- `type AgentAssignment` (new): mirrors the `agent_assignments` row, with a
  `task: Task!` resolver and a `fromAgent: Principal` resolver. Field
  `gatheredContext: JSON`.
- `type Mutation` (new, was absent in Phase 0):
  - `createTask(title: String!, description: String): Task!`
  - `completeTask(taskId: ID!, result: JSON): Task!`
  - `cancelTask(taskId: ID!): Task!`
  - `acceptProposedTask(taskId: ID!): Task!`
  - `dismissProposedTask(taskId: ID!, reason: String): Task!`
- `type Task` (extended additively): `openAssignment: AgentAssignment` — the
  currently-open assignment if the task is paused on a human slot, NULL
  otherwise. Useful for the operator UI in Phase 2.

The `WorkflowRef` type from Phase 0 stays. Once the chain workflow attaches,
`Task.workflow` is non-null.

---

## Validation rules (cross-cutting)

- `createTask`: `title` non-empty; `description` optional.
- `completeTask(taskId, result)`: task MUST have an open `agent_assignments`
  row for its `current_stage`; task state MUST be non-terminal. `result` is
  free-form JSON.
- `cancelTask(taskId)`: task state MUST be non-terminal; otherwise returns
  `TASK_ALREADY_TERMINAL` (Q5).
- `acceptProposedTask(taskId)` / `dismissProposedTask(taskId)`: task state
  MUST be `PROPOSED`; otherwise typed error.
- All mutations write exactly one `audit_messages` row in the same tx as the
  state change they cause (FR-002).
