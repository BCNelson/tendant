# Implementation Plan: Universal Gate, Hard-Rule Floor & the First Tool (Phase 3)

**Branch**: `004-universal-gate-floor` · **Phase**: 3 · **Size**: M

## Architectural shape

Phase 3 introduces a **sibling tool-call workflow** rather than modifying the chain workflow body. This keeps Phase 1's deterministic step sequence (R5) intact and isolates the gate / dispatch / outcome loop into a single new file plus one new package.

```
   ┌──────────────────────────────────────────────────────────────┐
   │ Chain workflow (unchanged from Phase 2)                      │
   │   CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION     │
   └──────────────────────────────────────────────────────────────┘
                            │ (EXECUTION assignment open)
                            ▼
   GraphQL: proposeToolCall(taskId, toolGlobalUri, payload)
                            │
                            ▼
   internal/gate.Evaluate ─── read-only? ─yes─► Approve (dispatch sync)
                                │ no
                                ▼
                            FLOOR (3 clauses)
                                │
                                ▼
                            script-stub ─► overseer-stub ─► RequestDecision
                            │ (Phase 5)     (Phase 4)
                            ▼
   internal/toolflow.ToolCallWorkflow(callID) — DBOS workflow:
     step1: insert pending_decisions(kind=approval_request, frozen_payload, decision_topic, workflow_id)
     wait : dbos.Recv("approval:"+decisionID, 72h)
     step2: on approve  → tools.Registry.Execute(toolID, frozen_payload)
            on reject   → audit only
     step3: insert tool_outcomes(outcome)
   ── ↑ wakes via GraphQL: approveArtifact(decisionId) / rejectApproval(decisionId)
       which dbos.Send to the decision_topic                      ──
```

The chain workflow continues independently. After the tool dispatches, the owner still calls `completeTask` to walk EXECUTION → COMPLETION as before.

## Tech notes

| Concern | Choice | Why |
|---|---|---|
| Gate evaluation | Pure Go function `Gate.Evaluate` | No I/O, fully unit-testable. |
| Floor data feed | `tools.permissions` jsonb | Already in Phase 0 schema; no new shape. |
| Tool dispatch | `Tool.Execute(ctx, payload) (Result, error)` | Symmetric to `internal/push.Provider`; testable. |
| Tool-call durability | New `ToolCallWorkflow` registered with DBOS | Reuses Phase 1 `Recv` wait primitive; survives restart. |
| Approval transport | `dbos.Send("approval:"+decisionID, payload)` | Same primitive as `chain.Resolve`; no new infra. |
| Outcome record | `tool_outcomes` table (Phase 0) | Schema already there; Phase 3 is first writer. |
| Provider seam | `LogProvider` default, real SMTP stub | Mirrors `internal/push` exactly. |

## File-level changes

### New files

- `db/migrations/00004_phase3_gate_and_dispatch.sql` — adds `pending_decisions.frozen_payload`, `pending_decisions.workflow_id`, `pending_decisions.decision_topic` columns (all nullable for backward compatibility).
- `services/api/internal/db/queries/tools.sql` — `GetToolByGlobalURI`, `ListTools`, `UpsertTool`.
- `services/api/internal/db/queries/gate.sql` — `InsertApprovalRequest` (extends inbox queries), `ResolveDecision`, `GetPendingDecisionWithTopic`, `InsertToolOutcome`.
- `services/api/internal/gate/gate.go` — `Decision`, `Verdict`, `ToolCall`, `Gate` interface, `DefaultGate`.
- `services/api/internal/gate/floor.go` — `Floor` evaluator with three clauses; pure function.
- `services/api/internal/gate/floor_test.go` — table-driven unit tests for each clause + short-circuit.
- `services/api/internal/tools/tools.go` — `Tool` interface, `Registry`, `Result`.
- `services/api/internal/tools/send_email.go` — `SendEmail` tool + `Provider` seam + `LogProvider`.
- `services/api/internal/tools/seed.go` — `SeedSendEmail(ctx, q)` idempotent upsert of the row.
- `services/api/internal/toolflow/workflow.go` — `ToolCallWorkflow`, `Register`, `ResolveApproval` helper.
- `specs/004-universal-gate-floor/contracts/graphql.v1.graphqls` — additive schema delta (new mutation `proposeToolCall`).
- `apps/mobile/lib/features/approval/approval_detail_page.dart` — Artifact rendering + approve/reject buttons.
- `apps/mobile/lib/features/approval/approval_provider.dart` — Ferry mutation providers (flow through `floor_rail`).

### Modified files

- `services/api/graph/schema.graphqls` — add `proposeToolCall` mutation (additive per Phase 2 versioning policy).
- `services/api/graph/schema.resolvers.go` — implement `approveArtifact`, `rejectApproval`, `proposeToolCall`. Leave `answerQuestion` / `decidePromotion` / `authorizeMandate` / `declineMandate` at `NOT_YET_AVAILABLE`.
- `services/api/graph/auth_registration.go` — register the new mutation under `act:propose_tool_call`.
- `services/api/internal/durable/dbos.go` — register `ToolCallWorkflow` alongside `ChainWorkflow`.
- `services/api/cmd/tendant/main.go` — call `tools.SeedSendEmail(ctx, q)` between migrate and DBOS launch.
- `apps/mobile/lib/features/inbox/inbox_page.dart` — when tapping an `ApprovalRequest`, navigate to `ApprovalDetailPage`.

## Reuse map

| Need | Use existing |
|---|---|
| Wait primitive | `chain.WaitForResult(ctx, topic, timeout)` |
| Resolver-side wake | `dbos.Send(ctx, workflowID, payload, topic)` — copy chain.Resolve pattern |
| Audit messages | `lifecycle.WriteAuditMessage` (new kinds: `tool_call_composed`, `gate_verdict`, `tool_dispatched`, `tool_outcome_recorded`) |
| Push notify | inherits automatically (pending_decisions INSERT trigger from Phase 0; per-event auth re-check from Phase 2) |
| Realtime subscription | `realtime.Dispatcher` already routes `decision` topic |
| sqlc machinery | `services/api/internal/db/` patterns |
| Provider stub pattern | `internal/push.LogProvider` |

## Verification

1. `just generate` — sqlc + gqlgen drift-free.
2. `just test` — all module tests green; specifically `internal/gate/...` (pure unit) and `services/api/graph/...` (integration via testcontainers).
3. New e2e: `services/api/graph/approval_dispatch_test.go` walks the four scenarios from User Stories 1, 2, 4.
4. Manual: `just up` → graphiql:
   - `mutation { createTask(title:"send email") { id } }` — walk to EXECUTION via existing test helpers
   - `mutation { proposeToolCall(taskId:"...", toolGlobalUri:"tendant://tools/send-email", payload:{to:"owner@local",subject:"hi",body:"x"}) { id } }`
   - `subscription { inboxItemArrived { __typename ... on ApprovalRequest { id payload { ... on Artifact { recipient } } } } }` — observe arrival.
   - `mutation { approveArtifact(decisionId:"...") { id } }` — observe LogProvider line.
5. Flutter: `flutter run` → open approval, approve → backend log shows dispatch.

## Risks

- **DBOS workflow registration order.** `ToolCallWorkflow` must be registered before `Launch` like `ChainWorkflow` is (R5 / FR-012 from Phase 1). Mirror the `chain.Register` pattern exactly.
- **Floor clause precision drift.** The "stranger recipient" predicate is a simple set lookup against `principals.global_uri`. Add a future `known_domains` allowlist column when the second tool lands; not in scope for Phase 3.
- **Idempotent approve.** `approveArtifact` called twice on a resolved decision must be a no-op. Achieved by checking `resolved_at` before sending.
