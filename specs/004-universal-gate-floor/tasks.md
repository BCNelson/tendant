# Tasks: Phase 3 — Universal Gate, Hard-Rule Floor & the First Tool

Dependency-ordered. `[P]` = parallel-safe with siblings sharing the same `[P]` block.

## Setup

- [X] **T001** `db/migrations/00004_phase3_gate_and_dispatch.sql` — add `frozen_payload`, `workflow_id`, `decision_topic` columns to `pending_decisions`.

## sqlc

- [X] **T002** `services/api/internal/db/queries/tools.sql` — `GetToolByGlobalURI`, `ListTools`, `UpsertTool`. Regenerate.
- [X] **T003** `services/api/internal/db/queries/inbox.sql` — extend `InsertPendingDecision` to take frozen_payload + workflow_id + decision_topic; add `ResolveDecision(id, resolution, resolved_at)`; add `GetPendingDecisionForResolve(id)` returning workflow_id + decision_topic + frozen_payload + resolved_at.
- [X] **T004** `services/api/internal/db/queries/outcomes.sql` — `InsertToolOutcome(tool_id, task_id, outcome)`.

## Core (parallel block)

- [X] **T005 [P]** `services/api/internal/gate/gate.go` — `Decision`, `Verdict`, `ToolCall`, `Gate`, `DefaultGate` with composition order.
- [X] **T006 [P]** `services/api/internal/gate/floor.go` — pure `Floor.Check(payload, permissions, knownPrincipals)`.
- [X] **T007 [P]** `services/api/internal/tools/tools.go` — `Tool` interface, `Registry`, `Result`.
- [X] **T008 [P]** `services/api/internal/tools/send_email.go` — `SendEmail` + `Provider` + `LogProvider`.

## Wiring

- [X] **T009** `services/api/internal/tools/seed.go` — `SeedSendEmail(ctx, q)` idempotent upsert.
- [X] **T010** `services/api/internal/lifecycle/audit.go` — new kinds `tool_call_composed`, `gate_verdict`, `tool_dispatched`, `tool_outcome_recorded` + payload structs.
- [X] **T011** `services/api/internal/toolflow/workflow.go` — `ToolCallWorkflow`, `Register(dctx, pool, q, registry)`, `ToolCallWorkflowID(callID)`, `ResolveDecision(ctx, decisionID, payload)`.
- [X] **T012** `services/api/internal/durable/dbos.go` — `RegisterToolCallWorkflow(...)` alongside `RegisterChainWorkflow`.
- [X] **T013** `services/api/cmd/tendant/main.go` — call `tools.SeedSendEmail` and register tool-call workflow between migrate and DBOS launch.

## GraphQL

- [X] **T014** `services/api/graph/schema.graphqls` — add `proposeToolCall` mutation per `contracts/graphql.v1.graphqls`.
- [X] **T015** `services/api/graph/schema.resolvers.go` — implement `proposeToolCall`, `approveArtifact`, `rejectApproval`.
- [X] **T016** `services/api/graph/auth_registration.go` — register `proposeToolCall` for `act:propose_tool_call` (owner-only in Phase 3); approveArtifact + rejectApproval are already `act:decide`.

## Tests

- [X] **T017 [P]** `services/api/internal/gate/floor_test.go` — table-driven, every clause + short-circuit.
- [X] **T018** `services/api/graph/approval_dispatch_test.go` — happy path (benign), floor-trip (stranger), cancel-after-dispatch.

## Flutter

- [X] **T019 [P]** `apps/mobile/lib/features/approval/approval_detail_page.dart` — Artifact rendering + approve/reject buttons.
- [X] **T020 [P]** `apps/mobile/lib/features/approval/approval_provider.dart` — Ferry mutation providers flowing through `floor_rail`.
- [X] **T021** `apps/mobile/lib/features/inbox/inbox_page.dart` — navigate to ApprovalDetailPage on tap.
- [X] **T022 [P]** `apps/mobile/test/approval_offline_test.dart` — confirm approval refused offline by `floor_rail` (rail already lists `approveArtifact` / `rejectApproval` as floor-relevant).

## Polish

- [X] **T023** `just generate` — sqlc + gqlgen drift-free.
- [X] **T024** `just test` — full suite green.
- [X] **T025** golangci-lint v2 per module.
- [X] **T026** Update `CLAUDE.md` with the Phase 3 paragraph (matches Phase 0/1/2 style).
- [X] **T027** Commit per established style.
