# Implementation Plan: The Overseer — Per-Tool LLM Grader (Phase 4)

**Branch**: `005-overseer-tool-grader` · **Date**: 2026-05-28 · **Spec**: [spec.md](spec.md)
**Phase**: 4 · **Size**: S–M · **Depends on**: Phase 3 (universal gate + first tool + ToolCallWorkflow)

## Summary

Phase 4 fills the **Layer-4 slot** that Phase 3 reserved in `internal/gate/gate.go:136-144`. A new `internal/overseer` package adds the gate's judgment layer: an LLM-backed grader, parameterized per tool by **owner-authored** `tools.overseer_instructions`, that judges non-floor-tripping calls and returns either `Approve` (auto-dispatch, still floor-subordinate) or `RequestDecision` (escalate to the existing Phase-3 human-wait). Inference is funneled through a single **platform model gateway** that is the only addressable path to a model — agents cannot reroute. Owner instructions and the concrete call sit in **separate, labeled prompt slots** so an executor's payload field can never pose as an owner instruction.

Cost is bounded by three layers: per-call `tokens_in`/`tokens_out`/`estimated_cost_usd` captured in audit; a deployment-wide rolling `overseer_evaluations_per_minute` counter on `/healthz`; and a per-task fail-closed hard cap (`TENDANT_OVERSEER_MAX_EVAL_PER_TASK`, default `50`). **No verdict cache** — real tool payloads rarely collide byte-for-byte, so it'd carry cost without yielding meaningful hits. **No new tables and no new migration** — the cost fields ride `audit_messages.payload jsonb`; both `setTool*` mutations write to existing columns reserved in Phase 0 (`tools.permissions`, `tools.overseer_instructions`).

## Technical Context

**Language/Version**: Go 1.25 (workspace toolchain auto-tracks; local Go 1.26 OK), Dart/Flutter for the mobile surface.
**Primary Dependencies** (already in stack — no new deps proposed): `chi/v5`, `gqlgen` v0.17.90, `pgx/v5` (≥ 5.9.2), `sqlc` v1.31.1, `goose/v3` v3.27.1, `dbos-transact-golang` v0.15.0, `log/slog`, `google/uuid`. **The Anthropic / OpenAI HTTP calls use the standard library (`net/http` + `encoding/json`) only** — no new SDK dependency is introduced (see Constitution Check §Tech Constraints).
**Storage**: Postgres only (existing tables; no migration). Reuses `audit_messages.payload jsonb`, `tools.permissions jsonb`, `tools.overseer_instructions text`.
**Testing**: `go test -race` per workspace module; `testcontainers-go` v0.39.0 (Docker v28.5.2 coupling per `MEMORY.md`); table-driven unit tests for the gateway prompt-serializer, the owner-only resolver guard, and the `LogProvider`; one integration test against testcontainers Postgres for Story 1's full happy path.
**Target Platform**: Linux server (the Go service) + iOS / Android / desktop / web (Flutter operator client).
**Project Type**: web-service + operator-edge mobile app (already established by Phases 0–3).
**Performance Goals**: overseer eval p95 < 2 s (`LogProvider`) / < 5 s (real provider); per-task cap lookup p99 < 20 ms (existing `idx_audit_task` covers it); rate counter is in-memory and effectively free.
**Constraints**: deterministic CI (`LogProvider` default — no network calls in `just test`); fail-closed semantics on every gateway error path; owner-only mutations enforced *structurally* at the resolver (`Principal.Kind == "user"`), not by `auth.Can()` alone (see Edge Cases in spec).
**Scale/Scope**: single-household deployment (one owner principal). Worst case in Phase 4 is the per-task cap × number of open tasks. Per-task cap defaults to 50, so even a pathologically chatty agent loop is bounded at ~50 LLM calls per task before fail-closed.

## Constitution Check

*GATE: All principles + Technology Constraints pass below. No deviations. Re-checked after Phase 1 design — unchanged.*

| # | Principle | Status | Notes |
|---|---|---|---|
| I | Capability Grows at the Edges, Not the Core | ✅ | The overseer is the gate's Layer-4 slot, declared by Phase 3 as the explicit extension point. Tool capability still grows via the `Tool` registry; agent capability still grows via the `Provider` seam. No new core widening. |
| II | A Task Is Not a Workflow | ✅ | Overseer evaluation runs inside `internal/gate.DefaultGate.Evaluate` — a pure step called by Phase 3's `ToolCallWorkflow`. No task/workflow surface change. |
| III | The Hard-Rule Floor Is Immune | ✅ | Gate evaluation order unchanged: floor runs before overseer; overseer is **never asked** on a floor-tripping call (FR-002, SC-005). An overseer `Approve` cannot un-trip the floor by construction. |
| IV | The Owner Authors Trust; Agents Never Self-Escalate | ✅ | `setToolOverseerInstructions` + `setToolPermissions` are owner-only at the resolver (`Principal.Kind == "user"`); separate `[OWNER_INSTRUCTIONS]` and `[CONCRETE_CALL]` prompt slots ensure executor framing is evidence, not instruction (FR-006, FR-007, NFR-002, NFR-003). |
| V | Cancel Halts; It Does Not Roll Back | ✅ | Per-task cap fail-closes to `RequestDecision`; no rollback path introduced. Cancel still halts the ToolCallWorkflow exactly as in Phase 3. |
| VI | Every Decision Is Audited, and the Log Is Message-Shaped | ✅ | Exactly one `overseer_evaluated` audit row per evaluation; new audit kinds `overseer_evaluated`, `overseer_instructions_changed`, `tool_permissions_changed` chain via `in_reply_to` to their predecessors (FR-009, FR-015). |
| VII | Edge Contracts Are Versioned and Additive | ✅ | Operator-edge GraphQL delta is purely additive: two new mutations + one optional nested field on `ApprovalRequest`. No field renamed, removed, or retyped. Contract file: `contracts/graphql.v1.graphqls`. Versioning policy reference (Phase 2): additive default, no version bump. |
| VIII | Federation-Shaped From Day One | ✅ | No new addressable top-level resources. The owner-only resolver check uses `Principal.Kind` — the federation-ready identity dimension. |
| IX | Untrusted Code Is the Default Assumption | ✅ | The overseer is a trusted core component reading owner-authored instructions; model output is **parsed**, never executed. Per-call cost + per-task cap bound runtime cost; gateway error paths are fail-closed (FR-012). Untrusted gate scripts arrive in Phase 5 atop this layer. |

**Technology Constraints**

| Constraint | Status | Notes |
|---|---|---|
| Postgres only | ✅ | No new datastore or transport. Counters are in-memory; cap lookup is a count query on an existing index. |
| DBOS is the execution engine | ✅ | Overseer eval is a step inside the existing `ToolCallWorkflow`. No new workflow or engine. |
| Adopted stack (Go gqlgen/chi/pgx, Flutter, WASM) | ✅ | All Go on the server; Flutter for the small read-only surface update. |
| Language policy | ✅ | All new code is Go (server) or Dart (mobile). |
| **No new dependencies without approval** | ✅ | **Real-provider HTTP calls use `net/http` + `encoding/json` only.** The Anthropic Messages API and the OpenAI Chat Completions API are both straightforward POST-JSON endpoints; a ~150-LOC stdlib client per provider is sufficient and avoids a constitutional approval round-trip. Decision rationale captured in `research.md` R3. |

## Architectural shape

Phase 4 plugs the overseer into Phase 3's already-built gate evaluation pipeline. The chain workflow and the `ToolCallWorkflow` are unchanged; only `internal/gate.DefaultGate` grows an `Overseer Grader` field, and the gate calls it after the (still-stubbed) script slot when the floor did not trip.

```
   ┌──────────────────────────────────────────────────────────────┐
   │ ToolCallWorkflow (Phase 3; unchanged)                        │
   │   compose → gate → wait → dispatch → outcome                 │
   └──────────────────────────────────────────────────────────────┘
                            │
                            ▼
   internal/gate.DefaultGate.Evaluate(ctx, *ToolCall, *Tool)
       │
       ├── read-only?      ─yes─► Approve (sync dispatch)
       │
       ├── FLOOR (3 clauses) ─trip─► RequestDecision (immune; SC-005)
       │
       ├── script-stub (Phase 5) ─► falls through
       │
       └── overseer (NEW: Phase 4)
            │
            ▼
       internal/overseer.Gateway.Grade(ctx, OverseerInput)
            │ ┌──────────────────────────────────────────────┐
            │ │ Per-task cap check (count audit rows for     │
            │ │   kind='overseer_evaluated' AND task=X)      │
            │ │ if N >= cap → fail-closed RequestDecision    │
            │ └──────────────────────────────────────────────┘
            │
            ▼
       internal/overseer.Provider (LogProvider | Anthropic | OpenAI)
            │
            │  serialize OverseerInput into labeled prompt slots:
            │     [SYSTEM] (authoritative slot declaration)
            │     [OWNER_INSTRUCTIONS]  ← tools.overseer_instructions
            │     [TOOL_METADATA]       ← name, global_uri, permissions
            │     [CONCRETE_CALL]       ← frozen payload JSON
            │
            ▼
       OverseerVerdict{Decision, Evidence, ModelID, Provider, TokensIn, TokensOut, EstimatedCostUSD, Reason}
            │
            ▼
       audit_messages(kind='overseer_evaluated',
                      payload={verdict, model_id, provider,
                               owner_instructions_hash,
                               evidence: {summary, considered_fields},
                               tokens_in, tokens_out, estimated_cost_usd})
            │
            ▼
   gate.Verdict: Approve → sync dispatch
                 RequestDecision → existing Phase 3 ApprovalRequest path
```

The owner-only tuning surface lands as two new mutations on the operator-edge GraphQL contract; each writes the column and an audit row.

```
GraphQL (owner-only resolver):
   setToolPermissions(toolId, permissions)            ─► tools.permissions   + audit:tool_permissions_changed
   setToolOverseerInstructions(toolId, instructions)  ─► tools.overseer_instructions + audit:overseer_instructions_changed
```

## Tech notes

| Concern | Choice | Why |
|---|---|---|
| Overseer evaluation | `internal/overseer.Grader` interface; `Gateway` is the only impl | Single choke point; agents cannot bypass (FR-004, principle IV). |
| Provider seam | `Provider` interface + `LogProvider` default | Mirrors `internal/push.Provider` exactly; deterministic CI. |
| Provider env switch | `TENDANT_OVERSEER_PROVIDER ∈ {log, anthropic, openai}`, default `log` | Owner-controlled at deploy time; not addressable at runtime. |
| Real-provider HTTP | Stdlib `net/http` + `encoding/json` | Avoids new dep (constitution); the two APIs are simple POST-JSON. |
| Model response shape | Structured JSON (`{"verdict","summary","considered_fields"}`) using Anthropic *tool use* or OpenAI *function calling* | Robust against free-form drift; falls back to JSON-in-text + lenient parse if provider lacks tool-use. |
| Labeled prompt slots | Struct boundary (`OverseerInput`), not string concat | Compile-time guarantee that payload fields cannot reach the instructions slot. |
| Audit | `audit_messages` jsonb payload; new `kind` constants in `internal/lifecycle/audit.go` | Reuses Phase 0 DAG; no new audit table. |
| Per-task cap counter | `SELECT count(*) FROM audit_messages WHERE kind='overseer_evaluated' AND task_id = $1` (cache hit on `idx_audit_task`) | Cheap, indexed, transactional with the eval write. |
| Rate counter | In-memory rolling 60s window in `Gateway` (mutex-protected slice of timestamps) | Observability-only; no enforcement. Lost on restart by design — counter is a window, not a ledger. |
| Owner-only resolver | New `auth.RequireOwner(ctx) (*Principal, error)` helper returning `PERMISSION_DENIED` for `Kind != "user"` | Compile-time documented invariant; testable in isolation (NFR-003). |
| `setToolPermissions` validation | Phase 4 schema validator on the same shape the floor reads (`read_only`, `spend`, `irreversible_third_party`, `secret_classes`) | Same canonical shape as Phase 3 `R5`; invalid input returns `INVALID_PERMISSIONS`. |
| Flutter surface | Read-only `Tool.overseerInstructions` rendering + `ApprovalRequest.overseerEvaluation` summary | No editor in Phase 4 (owner tunes via GraphQL); approval card now shows *why* an LLM escalated. |

## File-level changes

### New files

- `services/api/internal/overseer/overseer.go` — `Grader` interface, `OverseerInput`, `OverseerVerdict`, `Decision`-translation helpers.
- `services/api/internal/overseer/gateway.go` — `Gateway` struct (the impl of `Grader`); owns the rate window + per-task cap check; calls the active `Provider`.
- `services/api/internal/overseer/provider.go` — `Provider` interface, `ErrProviderTransient` sentinel.
- `services/api/internal/overseer/log_provider.go` — `LogProvider` (default). Deterministic verdict from a `TENDANT_OVERSEER_LOG_DENY_PATTERN` env regex against the *concrete-call* JSON; synthetic `tokens_in=10, tokens_out=5, estimated_cost_usd=0`.
- `services/api/internal/overseer/anthropic_provider.go` — `AnthropicProvider` (stdlib HTTP to `/v1/messages` with tool-use API; parses structured `verdict_response` tool_use block).
- `services/api/internal/overseer/openai_provider.go` — `OpenAIProvider` (stdlib HTTP to `/v1/chat/completions` with function-calling).
- `services/api/internal/overseer/prompt.go` — `Serialize(in OverseerInput) PromptPayload` — pure function building the labeled-slot prompt. Returns a struct, not a string, so providers can map slots onto their native API (Anthropic system + user, OpenAI roles).
- `services/api/internal/overseer/prompt_test.go` — Story 2 / NFR-002: asserts payload fields never leak into the `[OWNER_INSTRUCTIONS]` slot; table-driven over injection cases.
- `services/api/internal/overseer/gateway_test.go` — unit tests for cap counting, fail-closed paths, provider plumbing (`LogProvider` only).
- `services/api/internal/overseer/integration_test.go` — testcontainers Story-1 happy path: configure overseer_instructions → benign call auto-approves → audit row populated.
- `services/api/internal/auth/owner.go` — `RequireOwner(ctx) (*Principal, error)` helper.
- `services/api/internal/auth/owner_test.go` — table-driven NFR-003: `Kind ∈ {"user","bot","service",""}`; only `"user"` succeeds.
- `services/api/internal/db/queries/overseer.sql` — `CountOverseerEvalsForTask`, `GetToolByID` (if absent), `UpdateToolPermissions`, `UpdateToolOverseerInstructions`. Regenerated through sqlc.
- `services/api/graph/tool_mutations_test.go` — integration tests for `setToolPermissions` / `setToolOverseerInstructions` happy/refuse/invalid-permissions paths.
- `specs/005-overseer-tool-grader/contracts/graphql.v1.graphqls` — additive schema delta (two new mutations + one optional `ApprovalRequest.overseerEvaluation` field). Versioning policy reference: additive, no bump.
- `apps/mobile/lib/features/tool_detail/tool_detail_page.dart` — read-only display of `Tool.overseerInstructions` (no editor; spec defers UI tuning).
- `apps/mobile/lib/features/approval/overseer_evaluation_card.dart` — small card rendered on `ApprovalDetailPage` when `ApprovalRequest.overseerEvaluation` is non-null; shows verdict + summary + considered_fields.

### Modified files

- `services/api/internal/gate/gate.go` — add `Overseer overseer.Grader` field to `DefaultGate`; call it after the script-stub slot when the floor did not trip; translate `OverseerVerdict.Decision` into `gate.Verdict`. **Order unchanged** (constitution III).
- `services/api/internal/gate/gate_test.go` — add SC-005 regression: a floor-tripping call still returns `RequestDecision` even when a mock `Grader` returns `Approve`.
- `services/api/internal/durable/dbos.go` — construct the `Gateway` at boot and inject it into `DefaultGate`.
- `services/api/cmd/tendant/main.go` — read `TENDANT_OVERSEER_PROVIDER`, `TENDANT_OVERSEER_MAX_EVAL_PER_TASK`, provider-specific creds; construct the chosen `Provider`; wire into `Gateway`.
- `services/api/internal/server/healthz.go` — include `overseer.evaluations_per_minute` in the JSON response (FR-010).
- `services/api/internal/lifecycle/audit.go` — three new `Kind*` constants: `KindOverseerEvaluated`, `KindOverseerInstructionsChanged`, `KindToolPermissionsChanged`.
- `services/api/internal/tools/seed.go` — Phase 4 seeder updates `send-email` row to populate `overseer_instructions` if NULL (FR-013); idempotent.
- `services/api/graph/schema.graphqls` — add the two new mutations and the optional `ApprovalRequest.overseerEvaluation` field. **Additive per Phase 2 versioning policy.**
- `services/api/graph/schema.resolvers.go` — implement the two mutations: call `auth.RequireOwner` first, validate (for permissions), update the row, write audit, return updated `Tool`. Implement the `ApprovalRequest.overseerEvaluation` resolver (joins on the related `overseer_evaluated` audit row).
- `services/api/internal/toolflow/workflow.go` — pass the per-task ID into the gate context so the overseer can scope the cap query (already available via `ToolCall.TaskID`; thread it through to `Gate.Evaluate`).
- `apps/mobile/lib/features/approval/approval_detail_page.dart` — render the new `OverseerEvaluationCard` when present.

## Reuse map

| Need | Use existing |
|---|---|
| Provider seam pattern | `internal/push.Provider` (LogProvider + APNs/FCM stubs) — same shape |
| Audit writer | `lifecycle.WriteAuditMessage` (new kinds added; existing helper unchanged) |
| Owner identity | `auth.Principal.Kind` (already `"user"` for seeded owner) |
| Resolver auth context | `auth.MustViewer(ctx)` (Phase 2) |
| Per-task index | `idx_audit_task (task_id, at)` (Phase 0) — covers cap count query |
| sqlc machinery | `services/api/internal/db/queries/*.sql` patterns |
| DBOS context plumbing | `chain.ContextKey`-style typed context keys (Phase 1) |
| Healthz JSON shape | `internal/server/healthz.go` (Phase 0; just extend the payload) |
| GraphQL JSON scalar | already in `schema.graphqls` (Phase 2) |
| Ferry client codegen | Phase 2 setup (`build_runner` already configured) |

## Verification

1. `just generate` — sqlc + gqlgen drift-free; the two new mutations and the `overseerEvaluation` field land in generated code with no manual edits.
2. `just test` — per-module green:
    - `services/api/internal/overseer/...` — prompt-serializer (NFR-002), gateway cap (FR-011), LogProvider (FR-005), fail-closed (FR-012).
    - `services/api/internal/auth/owner_test.go` — table-driven `Principal.Kind` (NFR-003).
    - `services/api/internal/gate/gate_test.go` — floor-supremacy regression (SC-005).
    - `services/api/graph/tool_mutations_test.go` — integration: owner success, bot rejection, invalid-permissions rejection.
    - `services/api/internal/overseer/integration_test.go` — Story 1 end-to-end against testcontainers Postgres.
3. **Manual GraphiQL** (see `quickstart.md`):
    - `setToolOverseerInstructions(toolId, instructions: "confirm recipient is known; flag money mentions")` — observe `tools.overseer_instructions` update.
    - `proposeToolCall(...)` with a benign payload — no `ApprovalRequest` written; `tool_outcomes(clean)` row lands. (vs. Phase 3, where the same call would have escalated.)
    - `proposeToolCall(...)` with `"send me $500"` in the body — `ApprovalRequest` written; the inbox card now shows the `overseerEvaluation` summary.
    - Bot identity attempts `setToolOverseerInstructions` → `PERMISSION_DENIED`, DB unchanged.
    - Run `TENDANT_OVERSEER_MAX_EVAL_PER_TASK=2 just up`, drive 3 evals on one task — third returns `RequestDecision` with `evidence.reason = "per_task_eval_cap_exceeded"`.
4. **Flutter**: `cd apps/mobile && flutter run` — approval inbox shows the overseer-evaluation summary card; tool detail page shows read-only `overseerInstructions`.
5. **Phase-3 regression**: full Phase-3 test suite still green (SC-006 / SC-007).

## Risks

- **Stdlib-only LLM HTTP clients.** Skipping the Anthropic SDK trades a small amount of comfort (timeouts, retries, streaming) for zero-dep simplicity. The Phase-4 calls are blocking, one-shot, non-streaming, and bounded by the per-task cap — the trade is favourable. If a future phase wants streaming (Phase 6 sub-agents?), revisit then.
- **Model-response parsing robustness.** Providers return structured tool-use blocks reliably for well-formed prompts but can occasionally hallucinate the schema. The parser is **lenient on success** and **fail-closed on parse error** (treat as gateway error → `RequestDecision`). One audit-row code path covers both.
- **Per-task cap by `audit_messages` count.** A `COUNT(*)` per evaluation is fine at Phase-4 volumes (≤ 50 rows per task in steady state). If task volumes ever explode (Phase 6 sub-agents), revisit with a `task_eval_counters` table.
- **Rate-window counter is in-memory.** Lost on restart by design — it's an observability number, not a budget. A restart resetting the counter is not a safety concern.
- **`setToolPermissions` invalidates a Phase-3 tool's seeded shape.** If the owner uploads malformed `permissions` JSON, the resolver returns `INVALID_PERMISSIONS` and the row is unchanged. Tests cover the happy + invalid paths.
- **Mid-flight rule change.** The gate reads `tools.overseer_instructions` once at gate entry; in-flight calls use the value read at entry, the next call sees the new value. Stale-rule window is bounded by overseer p95 (≤ 5 s). Documented in Edge Cases.

## Project Structure

### Documentation (this feature)

```text
specs/005-overseer-tool-grader/
├── plan.md                         # This file
├── research.md                     # Phase 0 output
├── data-model.md                   # Phase 1 output
├── quickstart.md                   # Phase 1 output
├── contracts/
│   └── graphql.v1.graphqls         # additive operator-edge delta
├── checklists/
│   └── requirements.md             # /speckit-specify checklist
└── tasks.md                        # /speckit-tasks output (not created here)
```

### Source Code (repository root)

```text
services/api/                       # Go module: github.com/bcnelson/tendant/services/api
├── cmd/tendant/main.go             # MODIFIED: wires Gateway from env
├── graph/
│   ├── schema.graphqls             # MODIFIED: additive Phase-4 delta
│   ├── schema.resolvers.go         # MODIFIED: two new mutations + overseerEvaluation resolver
│   └── tool_mutations_test.go      # NEW: owner-only + invalid-permissions tests
└── internal/
    ├── auth/
    │   ├── owner.go                # NEW: RequireOwner helper
    │   └── owner_test.go           # NEW: table-driven Kind test
    ├── db/queries/overseer.sql     # NEW: cap-count + tool tuning queries
    ├── durable/dbos.go             # MODIFIED: construct Gateway, wire into DefaultGate
    ├── gate/
    │   ├── gate.go                 # MODIFIED: Overseer field + call
    │   └── gate_test.go            # MODIFIED: floor-supremacy regression
    ├── lifecycle/audit.go          # MODIFIED: three new Kind* constants
    ├── overseer/                   # NEW PACKAGE
    │   ├── overseer.go             # Grader, OverseerInput, OverseerVerdict
    │   ├── gateway.go              # Gateway impl: cap, rate window, provider dispatch
    │   ├── provider.go             # Provider interface
    │   ├── log_provider.go         # LogProvider (default)
    │   ├── anthropic_provider.go   # Anthropic Messages API (stdlib HTTP)
    │   ├── openai_provider.go      # OpenAI Chat API (stdlib HTTP)
    │   ├── prompt.go               # Pure labeled-slot serializer
    │   ├── prompt_test.go          # NFR-002 injection-leak coverage
    │   ├── gateway_test.go         # cap + fail-closed unit tests
    │   └── integration_test.go     # Story 1 end-to-end
    ├── server/healthz.go           # MODIFIED: overseer.evaluations_per_minute
    ├── toolflow/workflow.go        # MODIFIED: thread TaskID into Gate.Evaluate
    └── tools/seed.go               # MODIFIED: Phase-4 overseer_instructions seeder

apps/mobile/                        # Flutter app
└── lib/features/
    ├── approval/
    │   ├── approval_detail_page.dart      # MODIFIED: render OverseerEvaluationCard
    │   └── overseer_evaluation_card.dart  # NEW
    └── tool_detail/
        └── tool_detail_page.dart          # NEW: read-only overseer_instructions

db/                                 # NO MIGRATION in Phase 4 (no schema change)
```

**Structure Decision**: Phase 4 is a tightly scoped feature add inside the existing `services/api/` + `apps/mobile/` two-tree layout already established by Phases 0–3. One new internal Go package (`internal/overseer`) and one new Flutter feature folder (`tool_detail`); everything else is additive into existing files. **No new modules, no new migrations.**

## Complexity Tracking

*All Constitution Check rows pass. No deviations to justify.*

No table needed.
