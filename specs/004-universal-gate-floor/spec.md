# Feature Specification: Universal Gate, Hard-Rule Floor & the First Tool (Phase 3)

**Feature Branch**: `004-universal-gate-floor`
**Created**: 2026-05-28
**Status**: Draft
**Input**: User description: "Phase 3 — Universal Gate, Hard-Rule Floor & the First Tool. Stand up the trust spine's foundation: the universal gate with its first two layers (read-only short-circuit + categorical hard-rule floor), the first real MCP tool (`send-email`), and the polymorphic approval loop that closes through Phase 2's operator edge."

## Overview

Phase 1 proved the chain. Phase 2 gave the chain somewhere to escalate. Phase 3 wires the **first outward capability** *behind the gate*, so the very first external action the system can ever take is already governed.

The load-bearing claim: **every tool call, from every agent, at every stage, passes through one universal gate; the hard-rule floor is evaluated first and is categorically immune** — nothing downstream (a script `Approve`, earned trust, a forgiving overseer) can lower the gate level the floor set. This is what makes cancel-only safe (the scary things are gated *before* they happen, so halting without rollback exposes nothing) and what will later keep untrusted gate scripts safe.

This phase implements only **two of the four gate layers**: the read-only short-circuit and the floor. The script and overseer are stubs that fall through to a human-wait. The *ordering* is built to the full picture so Phases 4 (overseer LLM) and 5 (gate scripts) slot in without rework.

## Clarifications

### Session 2026-05-28

- Q: Where does the gate live relative to the chain workflow? → A: **Sibling tool-call workflow** — a tool call is composed by a new `proposeToolCall` mutation that starts a `ToolCallWorkflow(callID)` via DBOS. That workflow runs the gate, writes the `ApprovalRequest` row (if RequestDecision), `dbos.Recv`s on a topic derived from the decision id, and on approval dispatches the tool and writes the `tool_outcomes` row. The chain workflow body is not touched — keeping its deterministic step sequence (R5) intact.
- Q: How is a tool call composed in Phase 3 (no LLM yet)? → A: **Human composition via `proposeToolCall`** — at any EXECUTION-stage open assignment the owner may call `proposeToolCall(taskId, toolId, payload)` to compose an outward action. Phase 4's overseer will compose calls on the agent's behalf; the mutation surface is shared.
- Q: Floor verdict on every graded call in Phase 3? → A: **Always `RequestDecision`** — because the script (Phase 5) and overseer (Phase 4) are stubs that fall through. The floor cannot be bypassed; non-floor graded calls also escalate (a temporary annoyance the overseer fixes in Phase 4).
- Q: Approval binding for an Artifact? → A: **Bound to the frozen payload** — the `ApprovalRequest.payload` is the exact composed call (recipient, content, tool args); the operator approves *that*, and on approval the workflow dispatches the frozen payload byte-for-byte. No re-screening on dispatch.
- Q: Mandate authorization in Phase 3? → A: **Type renders, mutation deferred** — `Mandate` and `Artifact` remain a discriminated union on `ApprovalPayload`, and `Mandate` payloads are *rendered* if any appear, but the `authorizeMandate` / `declineMandate` mutations return `NOT_YET_AVAILABLE`; v1 ships Artifact-only approvals. Live guardrail enforcement is a future-tool concern.
- Q: Floor clauses — precise per-tool definitions for `send-email`? → A:
  - **Spend** — `false` (email is not paid). Field reserved for tools like `book-reservation` in later phases.
  - **Irreversible third-party effect** — `true` when `recipient` is not in `principals.global_uri` *or* the recipient domain is not in the deployment's `known_domains` allowlist (empty by default). A known principal is `false`; any stranger trips.
  - **Secret disclosure** — `permissions.secret_classes` is empty for `send-email` in Phase 3 (no class wired). Reserved; the clause's shape is final.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Benign email goes out behind the gate (Priority: P1)

The owner is on an EXECUTION-stage assignment. They compose a `send-email` to a known principal (themselves) via `proposeToolCall`. The gate runs: read-only? no. Floor? no trip (recipient is a principal, no spend, no secrets). Script? not yet, falls through. Overseer? not yet, falls through. Verdict: `RequestDecision`. An `ApprovalRequest` lands in the inbox carrying the exact frozen email. The owner taps Approve. The workflow wakes, dispatches the tool, the `LogProvider` records the intended send, and a `tool_outcomes` row lands with `outcome=clean`. The owner finishes the assignment via the usual `completeTask`.

**Why this priority**: This is the entire reason Phase 3 exists. The full loop — compose → gate → durable human-wait → approve → dispatch → outcome — must work end-to-end before any optimisation (overseer, script).

**Independent Test**: Drive a task to EXECUTION. Call `proposeToolCall` with a benign email payload (recipient is the owner). Subscribe to `inboxItemArrived`. Expect an `ApprovalRequest`. Call `approveArtifact`. Inspect `tool_outcomes` for a `clean` row tied to the call. Inspect the `LogProvider` for the intended send.

**Acceptance Scenarios**:

1. **Given** an EXECUTION-stage task and a benign payload, **When** `proposeToolCall` is invoked, **Then** an `ApprovalRequest` is created and surfaced on the inbox subscription (Phase 2 wake-channel inheritance).
2. **Given** an open `ApprovalRequest`, **When** the owner calls `approveArtifact(decisionId)`, **Then** the `ToolCallWorkflow` wakes, dispatches the frozen payload to the tool, and writes one `tool_outcomes` row with `outcome=clean`.
3. **Given** the same `ApprovalRequest`, **When** the owner calls `rejectApproval(decisionId, reason)`, **Then** the `ToolCallWorkflow` wakes, records the rejection in audit, does **not** dispatch, and writes no `tool_outcomes` row.

---

### User Story 2 - Floor categorically traps the scary cases (Priority: P1)

The owner composes a `send-email` whose recipient is **not** a known principal (a stranger). Or composes a tool whose `permissions.spend` is true. Regardless of what the (stubbed) downstream verdict would say, the floor trips first and the verdict is `RequestDecision`. The owner is forced to look at the frozen call before it leaves the perimeter.

**Why this priority**: The floor *is* the safety story. If it can be bypassed by any future layer — script, overseer, trust — every other layer becomes unsafe. Categorical immunity is tested by construction in Phase 3 so Phases 4/5 inherit it for free.

**Independent Test**: Compose a `send-email` with a stranger recipient. Confirm an `ApprovalRequest` is created. Repeat with the recipient set to a principal but the tool's `permissions.spend` artificially flipped on. Confirm the floor still trips. In neither case does any code path skip the `ApprovalRequest`.

**Acceptance Scenarios**:

1. **Given** a tool call whose recipient is not in `principals.global_uri`, **When** `proposeToolCall` runs the gate, **Then** the floor returns `RequestDecision` and an `ApprovalRequest` is written.
2. **Given** a tool whose `permissions.spend` is `true` for any composed amount, **When** the gate runs, **Then** the floor returns `RequestDecision`.
3. **Given** a tool whose `permissions.secret_classes` lists the disclosure class of any argument, **When** the gate runs, **Then** the floor returns `RequestDecision`. (Wired now; sub-agents — Phase 9 — will exercise it.)
4. **Given** any composed call that does **not** trip the floor, **When** the gate runs in Phase 3, **Then** the verdict is still `RequestDecision` because the script (Phase 5) and overseer (Phase 4) are stubs.

---

### User Story 3 - Read-only short-circuit (Priority: P2)

A tool marked `permissions.read_only=true` is composed. The gate short-circuits before the floor (read-only calls are ungraded by construction) and returns `Approve`. The workflow dispatches without an `ApprovalRequest`.

**Why this priority**: Read-only calls are the bulk of agent work later; they cannot live behind the floor or the user is interrupted constantly. Building the short-circuit now (even with no read-only tool yet seeded) ensures the gate's evaluation order is correct.

**Independent Test**: Seed a synthetic `noop-read` tool with `permissions.read_only=true`. Compose a call. Confirm the gate returns `Approve` with no `ApprovalRequest` written and no human in the loop.

**Acceptance Scenarios**:

1. **Given** a tool with `permissions.read_only=true`, **When** the gate is asked to evaluate any call, **Then** the verdict is `Approve` without consulting the floor.

---

### User Story 4 - Cancel-after-dispatch is safe (Priority: P2)

The owner approves a tool call. The workflow dispatches. Before `completeTask` is invoked, the owner calls `cancelTask`. The already-sent mail stays sent (no rollback). The task transitions to HALTED. No further outward actions occur.

**Why this priority**: This validates the *full safety* of cancel-only — the floor's whole purpose was to gate the scary things *before* they happen so halting without rollback exposes nothing. With Phase 3, that becomes literally true.

**Independent Test**: Walk a task through approval + dispatch. Before `completeTask`, call `cancelTask`. Confirm the `tool_outcomes` row from the dispatch persists, the task is HALTED, and no new `pending_decisions` or `agent_assignments` are open.

**Acceptance Scenarios**:

1. **Given** a dispatched, completed tool call (outcome recorded), **When** the owner cancels the task, **Then** the task is HALTED and the outcome row is untouched.

---

### User Story 5 - Offline floor integrity (Priority: P3)

The owner is offline. They compose an `approveArtifact` action in the app. The floor rail (installed in Phase 2) refuses to commit the approval; the action is queued only as a *draft*, never as an outbox entry that flushes blindly. When connectivity returns, the client submits and the gate evaluates the floor at submit time — not at compose time — so a stale "approve" cannot bypass an updated floor.

**Why this priority**: This is the one rail that exists only because of Phase 3 and was pre-installed in Phase 2. Phase 3 makes the rail observable end-to-end.

**Independent Test**: Put the device offline. Attempt `approveArtifact` — the client refuses to enqueue. Reconnect. Submit — the approval proceeds.

**Acceptance Scenarios**:

1. **Given** the device is offline, **When** the owner attempts `approveArtifact`, **Then** the client surfaces "requires connectivity" and does **not** enqueue.
2. **Given** the device reconnects, **When** the owner submits the previously composed approval, **Then** the server evaluates the gate fresh; if the underlying `ApprovalRequest` is still open, it resolves.

---

### Edge Cases

- **Approve twice (idempotency).** Re-calling `approveArtifact` on an already-resolved decision is a no-op that returns the resolved decision (does not double-dispatch).
- **Approve after task cancelled.** The `ToolCallWorkflow` returns from `Recv` if the task is HALTED; if a late approval arrives, the workflow records the late resolution in audit and does not dispatch.
- **Tool dispatch fails (provider error).** The workflow records an `outcome=bad` `tool_outcomes` row with the error context; the calibration ratchet (Phase 8) consumes this later.
- **Tool registry unknown id.** `proposeToolCall` returns a `TOOL_UNKNOWN` error before any gate evaluation; nothing is written.
- **Concurrent approve + reject.** First-write-wins on `pending_decisions.resolved_at`; the loser receives the resolved-state response.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new `internal/gate` package MUST expose `Gate.Evaluate(ctx, *ToolCall, *Tool) (Verdict, error)` with `Verdict.Decision ∈ {Approve, Deny, RequestDecision, AgentHandoff}` and the order: **read-only short-circuit → floor → script (stub) → overseer (stub)**.
- **FR-002**: The floor MUST evaluate three clauses in order — spend, irreversible-third-party, secret-disclosure — and return `RequestDecision` if **any** clause trips. Floor clauses MUST be fed per-tool by `tools.permissions`.
- **FR-003**: A `Tool` interface and `Registry` keyed by `global_uri` MUST live in `internal/tools`; tools execute behind the interface. Core MUST NOT speak SMTP / HTTP / any provider protocol directly.
- **FR-004**: `send-email` MUST be the first tool, with a `Provider` seam mirroring `internal/push` — a `LogProvider` stub for dev/CI; real SMTP/HTTP behind a `Provider`. The `LogProvider` is wired by default when no real provider credentials are configured.
- **FR-005**: A new `internal/toolflow` package MUST expose `ToolCallWorkflow(callID)` — a DBOS-registered workflow that: writes the `pending_decisions` row, `dbos.Recv`s on `topic = "approval:" + decisionID`, dispatches via the tool registry, and writes a `tool_outcomes` row.
- **FR-006**: A new GraphQL mutation `proposeToolCall(taskId: ID!, toolGlobalUri: String!, payload: JSON!): ApprovalRequest!` MUST run the gate and start the `ToolCallWorkflow` (or, for read-only short-circuit, dispatch synchronously and return a resolved decision).
- **FR-007**: The Phase 2 stub mutations `approveArtifact(decisionId: ID!)` and `rejectApproval(decisionId: ID!, reason: String)` MUST be implemented: persist resolution to `pending_decisions`, `dbos.Send` the decision payload to the workflow's topic, and return the now-resolved `ApprovalRequest`. `answerQuestion` and `decidePromotion` MUST remain `NOT_YET_AVAILABLE`.
- **FR-008**: A `send-email` tool row MUST be seeded on boot (idempotent upsert) with `permissions = {"read_only": false, "spend": false, "irreversible_third_party": "stranger_recipient", "secret_classes": []}`.
- **FR-009**: Every successful tool dispatch MUST write exactly one `tool_outcomes` row with `outcome='clean'` (default; Phase 8 will introduce the ratchet that reads it).
- **FR-010**: A failed tool dispatch MUST write exactly one `tool_outcomes` row with `outcome='bad'` and an audit message capturing the provider error.
- **FR-011**: The Flutter app MUST render `ApprovalRequest` items with the frozen `Artifact` content (recipient, kind, content preview) and expose `Approve` / `Reject` buttons that call the Phase 3 mutations via Ferry. The buttons MUST flow through the existing `floor_rail` (Phase 2) so they are refused offline.
- **FR-012**: A new migration `00004_*.sql` MUST add `pending_decisions.frozen_payload jsonb`, `pending_decisions.workflow_id text`, and `pending_decisions.decision_topic text` columns, all nullable for backward compatibility with Phase 2 rows.

### Non-Functional Requirements

- **NFR-001**: Floor evaluation MUST be a pure function of `(ToolCall, Tool, principals)` — no side effects, fully unit-testable without DBOS or testcontainers.
- **NFR-002**: The full happy path (`proposeToolCall` → `approveArtifact` → tool dispatched) MUST be covered by a single integration test against testcontainers Postgres.

### Key Entities

- **Tool**: row in `tools` (id, global_uri, name, rung, permissions, overseer_instructions). Permissions feeds the floor.
- **ToolCall**: in-memory composition `{TaskID, ToolID, Payload}`. Frozen on entering the gate.
- **Verdict**: `{Decision, Context}`. Returned by `Gate.Evaluate`.
- **ApprovalRequest**: existing `pending_decisions` row with `kind=approval_request`; Phase 3 populates `frozen_payload`, `workflow_id`, `decision_topic`.
- **ToolOutcome**: existing `tool_outcomes` row, written once per dispatch attempt.

## Out of Scope (deferred)

- Overseer LLM grader (Phase 4).
- Gate scripts / WASM execution (Phase 5).
- Calibration ratchet that promotes/demotes rungs (Phase 8).
- Mandate live-guardrail enforcement (waits on real-time tool design).
- Multi-recipient / templating in `send-email` (only `to: string`, `subject: string`, `body: string` in v1).
- `Mandate` authorization mutations (`authorizeMandate`, `declineMandate` declared in Phase 2 schema, remain `NOT_YET_AVAILABLE`).

## Success Criteria

- **SC-001**: All four happy-path scenarios under User Story 1 pass against testcontainers Postgres.
- **SC-002**: All three floor clauses are unit-tested with a table-driven test.
- **SC-003**: A `proposeToolCall` for a stranger recipient ALWAYS produces an `ApprovalRequest`; no path bypasses the floor.
- **SC-004**: `cancelTask` after dispatch leaves `tool_outcomes` intact and the task HALTED.
- **SC-005**: `approveArtifact` from offline is refused by the Flutter client; from online it resolves the decision.
