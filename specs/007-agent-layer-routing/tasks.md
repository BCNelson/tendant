# Tasks: The Agent Layer (Specialists as Config) & Routing

**Input**: Design documents from `specs/007-agent-layer-routing/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Included — the spec mandates testcontainers e2e, injection tests, budget tests, and recovery tests (SC-001–SC-009).

**Organization**: Tasks grouped by user story; each story is independently testable after Phase 2.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Package Scaffolding)

**Purpose**: Create new packages, sqlc queries, env config — no logic yet

- [x] T001 Create `services/api/internal/agent/` package with doc.go (package comment: "the one trusted agent runner")
- [x] T002 [P] Create `services/api/internal/router/` package with doc.go (package comment: "eligibility prune + LLM pick")
- [x] T003 [P] Add sqlc queries for agent_configs in `services/api/internal/db/queries/agent_configs.sql` — ListByStage, GetByID, ListAll
- [x] T004 [P] Add env vars to `services/api/internal/server/config.go` — TENDANT_GATE_CALL_BUDGET (default 100), TENDANT_AGENT_MAX_ITER (default 20)
- [x] T005 Run `just generate` to regenerate sqlc Go code for the new queries

---

## Phase 2: Foundational (Types & Core Abstractions)

**Purpose**: Core types and interfaces that ALL user stories depend on — MUST complete before any story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T006 [P] Define Findings + StructuredFindings + Entity types in `services/api/internal/agent/stage_result.go`
- [x] T007 [P] Define StageResult type (Findings, ContextRefs, FailCloseToHuman, FailReason) in `services/api/internal/agent/stage_result.go`
- [x] T008 [P] Define SlotDecision type (IsHuman, ConfigID, ConfigName, StageResult) in `services/api/internal/chain/slot_decision.go`
- [x] T009 [P] Define Expression + Predicate types for eligibility grammar in `services/api/internal/router/eligibility.go`
- [x] T010 [P] Define AgentModelClient interface (Chat method) + ChatRequest/ChatResponse/Message/ToolDef/ToolCall types in `services/api/internal/agent/model_client.go`
- [x] T011 [P] Implement LogAgentClient (deterministic, returns scripted tool calls from fixtures) in `services/api/internal/agent/log_client.go`
- [x] T012 Implement Anthropic adapter for AgentModelClient (multi-turn tool-use, same HTTP infra as overseer) in `services/api/internal/agent/anthropic_client.go`
- [x] T013 [P] Implement OpenAI adapter for AgentModelClient in `services/api/internal/agent/openai_client.go`
- [x] T014 Add `NewAgentModelClient(provider, apiKey, modelID)` factory selecting adapter by provider name in `services/api/internal/agent/model_client.go`

**Checkpoint**: All foundational types and interfaces exist; CI builds green (`go build ./...`)

---

## Phase 3: User Story 2 — Eligibility-Bound Routing (Priority: P1)

**Goal**: Router prunes catalog deterministically by eligibility, LLM picks among survivors, human always eligible, invalid picks rejected.

**Independent Test**: `go test ./internal/router/ -v` — unit tests: prune produces correct survivor set; LLM pick validated; out-of-set pick falls back to human.

### Implementation

- [x] T015 [US2] Implement boolean expression evaluator (recursive-descent, AND/OR/NOT, subset/threshold/membership) in `services/api/internal/router/eligibility.go`
- [x] T016 [US2] Implement `EligibilityMatch(expr Expression, findings StructuredFindings) bool` — pure function, false on malformed input in `services/api/internal/router/eligibility.go`
- [x] T017 [US2] Implement `PruneEligible(configs []db.AgentConfig, findings StructuredFindings) []db.AgentConfig` in `services/api/internal/router/router.go`
- [x] T018 [US2] Implement LLM picker: build single-shot prompt (eligible set + free_text), call AgentModelClient, parse structured output `{config_id}` in `services/api/internal/router/llm_picker.go`
- [x] T019 [US2] Implement `Router.Select(ctx, stage, findings) (SlotDecision, error)` — prune → synthesize human → LLM pick → validate pick against survivor set → fallback to human on invalid in `services/api/internal/router/router.go`
- [x] T020 [US2] Unit test: eligibility evaluator — subset, threshold, membership, AND/OR/NOT, empty expr = true, malformed = false in `services/api/internal/router/eligibility_test.go`
- [x] T021 [P] [US2] Unit test: PruneEligible with diverse configs + findings — assert correct survivors in `services/api/internal/router/router_test.go`
- [x] T022 [P] [US2] Unit test: Router.Select with LogAgentClient forced to return ineligible config → assert fallback to human in `services/api/internal/router/router_test.go`
- [x] T023 [P] [US2] Unit test: Router.Select with LogAgentClient returning valid pick → assert that config is chosen in `services/api/internal/router/router_test.go`

**Checkpoint**: `go test ./internal/router/` passes — eligibility prune + pick + human fallback proven (SC-002)

---

## Phase 4: User Story 4 — Hostile Prompt Is Contained (Priority: P1)

**Goal**: Runner enforces allowlist before gate; floor still trips on dangerous allowlisted calls.

**Independent Test**: `go test ./internal/agent/ -run TestHostile -v` — hostile prompt tries off-allowlist tool (refused), tries allowlisted dangerous call (floor trips).

### Implementation

- [x] T024 [US4] Implement `Runner.resolveAllowlist(cfg.ToolAllowlist) ([]ToolDef, error)` — loads tool rows, builds ToolDef set exposed to model in `services/api/internal/agent/runner.go`
- [x] T025 [US4] Implement `Runner.validateToolCall(call, allowedIDs) error` — refuses calls outside allowlist before reaching gate, audits refusal in `services/api/internal/agent/runner.go`
- [x] T026 [US4] Implement `Runner.Run(ctx, cfg, task) (StageResult, error)` — plan→act→observe loop: build messages, call AgentModelClient.Chat, process tool calls (validate → gate → dispatch/observe), loop until StageResult or budget/max-iter in `services/api/internal/agent/runner.go`
- [x] T027 [US4] Implement sub-agent inbound query seam (Phase 9 stub — interface + no-op impl) in `services/api/internal/agent/seam.go`
- [x] T028 [US4] Unit test: Runner with hostile prompt naming off-allowlist tool → assert refused before gate, audit written in `services/api/internal/agent/runner_test.go`
- [x] T029 [P] [US4] Unit test: Runner with allowlisted tool that trips floor → assert RequestDecision verdict, FailCloseToHuman returned in `services/api/internal/agent/runner_test.go`
- [x] T030 [P] [US4] Unit test: Runner with benign tool call → assert gate Approve, tool dispatched, outcome observed in `services/api/internal/agent/runner_test.go`

**Checkpoint**: `go test ./internal/agent/` passes — containment + loop mechanics proven (SC-004)

---

## Phase 5: User Story 1 — Autonomous Chain, No Human in the Loop (Priority: P1) 🎯 MVP

**Goal**: Owner-authored task flows through real triage → expansion → execution → completion with specialist configs, every outward call gated, no human assignment opened.

**Independent Test**: `go test ./internal/chain/ -run TestAutonomousChain -v` — testcontainers e2e with LogAgentClient; task reaches DONE.

### Implementation

- [x] T031 [US1] Implement `runRouteAndOccupyStep` in `services/api/internal/chain/workflow.go` — memoized DBOS step: calls router.Select; if agent → runs Runner.Run, writes findings/context_refs; if human → opens assignment. Returns SlotDecision.
- [x] T032 [US1] Refactor ChainWorkflow per-stage loop: replace `runOpenAssignmentStep + WaitForResult + runResolveAndAdvanceStep` with `runRouteAndOccupyStep → (conditional Recv) → runResolveAndAdvanceStep` in `services/api/internal/chain/workflow.go`
- [x] T033 [US1] Update `chain.Register` to accept `AgentRunner` + `AgentModelClient` deps (alongside existing Router) in `services/api/internal/chain/workflow.go`
- [x] T034 [US1] Remove `HumanOnlyRouter` and update Router interface to return `SlotDecision` instead of `Agent` in `services/api/internal/chain/router.go`
- [x] T035 [US1] Create `SeedAgentCatalog(ctx, q)` in `services/api/internal/core/seed_catalog.go` — idempotent upsert of rich base catalog (7+ specialists across triage/expansion/execution with distinct eligibility)
- [x] T036 [US1] Wire boot sequence: `SeedAgentCatalog` after `SeedOwner`; construct real Router + Runner; pass to `chain.Register` in `services/api/cmd/tendant/main.go`
- [x] T037 [US1] Add new audit kinds (agent_run_started, agent_run_finished, router_selected, agent_call_refused, budget_exhausted, max_iterations_reached) to `services/api/internal/lifecycle/kinds.go`
- [x] T038 [US1] E2e test: seed task + catalog, run chain with LogAgentClient scripted to produce findings + tool call + StageResult per stage → assert DONE, findings populated, tool_outcomes row, audit DAG complete, NO agent_assignments rows in `services/api/internal/chain/workflow_test.go`

**Checkpoint**: `go test ./internal/chain/ -run TestAutonomousChain` passes with testcontainers — the phase's reason to exist is proven (SC-001)

---

## Phase 6: User Story 3 — Human as a Routed Candidate (Priority: P1)

**Goal**: When no specialist eligible, router places human in slot over the Phase 1/2 wait-on-event. Proves human is one catalog entry, not a special path.

**Independent Test**: `go test ./internal/chain/ -run TestHumanFallback -v` — task with findings matching no specialist → human assignment opened → external resolve → chain advances.

### Implementation

- [x] T039 [US3] Verify human synthesis in Router.Select (already added in T019) — no additional code needed if T019 was implemented correctly; confirm synthesized human has no ConfigID, IsHuman=true
- [x] T040 [US3] Verify chain wiring: when SlotDecision.IsHuman=true, the chain opens agent_assignments row, sets to_principal, enqueues push, then blocks on Recv in `services/api/internal/chain/workflow.go`
- [x] T041 [US3] E2e test: seed task with findings that match NO specialist eligibility → assert agent_assignments row opened, push enqueued; externally Send result to stage topic → assert chain advances to next stage, assignment resolved in `services/api/internal/chain/workflow_test.go`
- [x] T042 [P] [US3] E2e test: agent stage that emits a tool call floored to RequestDecision → assert pending_decision opened → externally approve → assert tool dispatched, chain continues in `services/api/internal/chain/workflow_test.go`

**Checkpoint**: Human-as-candidate path works identically to Phase 1 (SC-003)

---

## Phase 7: User Story 5 — Autonomy as a Derived Readout (Priority: P2)

**Goal**: `Task.autonomy` computed from execution-slot occupant's tool allowlist rungs; changes when specialist swapped or tool promoted.

**Independent Test**: `go test ./graph/ -run TestAutonomyDerivation -v` — different execution configs → different autonomy levels.

### Implementation

- [x] T043 [US5] Implement `deriveAutonomy(ctx, task, queries) AutonomyLevel` in `services/api/graph/mappers.go` — router-for-execution picks config, inspect highest tool rung: human→NONE, no tools→ENRICH_ONLY, gated→EXECUTE_GATED, auto→EXECUTE_AUTO, else→PROPOSE
- [x] T044 [US5] Replace hardcoded `model.AutonomyLevelNone` with `deriveAutonomy(...)` call in `mapTask()` in `services/api/graph/mappers.go`
- [x] T045 [US5] Unit test: task with human execution → NONE; specialist with gated tool → EXECUTE_GATED; tool promoted to auto → EXECUTE_AUTO; no tools → ENRICH_ONLY in `services/api/graph/mappers_test.go`

**Checkpoint**: Autonomy is genuinely derived (SC-005)

---

## Phase 8: User Story 6 — Cost/Latency Stays Bounded (Priority: P2)

**Goal**: Per-task gate-call budget fail-closes to human on exhaustion; Layer-3 script pre-empts overseer.

**Independent Test**: `go test ./internal/chain/ -run TestBudgetExhaustion -v` — low budget → exhaust → human fallback.

### Implementation

- [x] T046 [US6] Add budget counter to Runner (in-memory per Run call; incremented on each gate.Evaluate call) in `services/api/internal/agent/runner.go`
- [x] T047 [US6] On budget exhaustion: Runner returns StageResult{FailCloseToHuman: true, FailReason: "budget_exhausted"}, audits budget_exhausted in `services/api/internal/agent/runner.go`
- [x] T048 [US6] On max-iteration reached: Runner returns StageResult{FailCloseToHuman: true, FailReason: "max_iterations"}, audits max_iterations_reached in `services/api/internal/agent/runner.go`
- [x] T049 [US6] Chain wiring: when StageResult.FailCloseToHuman=true from agent step, treat as human path (open assignment, Recv) in `services/api/internal/chain/workflow.go`
- [x] T050 [US6] E2e test: set TENDANT_GATE_CALL_BUDGET=3, agent loops with >3 tool calls → assert fail-close, human assignment opened, audit row in `services/api/internal/chain/workflow_test.go`
- [x] T051 [P] [US6] Unit test: verify Layer-3 script terminal verdict skips overseer (existing gate behavior, but verify it's preserved under agent composition) in `services/api/internal/gate/gate_test.go`

**Checkpoint**: Budget and pre-emption proven (SC-006)

---

## Phase 9: GraphQL + Flutter (FR-022, FR-023, SC-009)

**Goal**: Additive GraphQL surface for stage slots + agent configs; Flutter read-only routing views.

**Independent Test**: GraphQL introspection shows new types; Flutter renders routing detail for a completed task.

### GraphQL (Backend)

- [x] T052 Add AgentStage enum, AgentConfigSummary type, RoutingDecision type, StageSlot type to `services/api/graph/schema.graphqls` per `contracts/graphql.v1.graphqls`
- [x] T053 Add `stageSlots: [StageSlot!]!` field to Task type in `services/api/graph/schema.graphqls`
- [x] T054 [P] Add `agentConfigs(stage: AgentStage): [AgentConfigSummary!]!` query in `services/api/graph/schema.graphqls`
- [x] T055 Run `just generate` to regenerate gqlgen code
- [x] T056 Implement `Task.stageSlots` field resolver — reads memoized routing decisions from chain workflow state in `services/api/graph/phase6_resolvers.go`
- [x] T057 [P] Implement `Query.agentConfigs` resolver — reads from agent_configs table via sqlc in `services/api/graph/phase6_resolvers.go`

### Flutter (Client)

- [x] T058 [P] Create routing view models (StageSlotView, RoutingDecisionView, AgentConfigView) in `apps/mobile/lib/features/routing/routing_models.dart`
- [x] T059 [P] Create riverpod provider for task stage slots in `apps/mobile/lib/features/routing/routing_provider.dart`
- [x] T060 Create RoutingDetailPage (read-only: per-stage slot occupant + routing decision + autonomy) in `apps/mobile/lib/features/routing/routing_detail_page.dart`
- [x] T061 Add GoRouter route for routing detail (nested under task or sibling to approval) in `apps/mobile/lib/core/router/routes.dart`

**Checkpoint**: `curl /graphql` returns stageSlots + autonomy; Flutter shows routing view (SC-009)

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Recovery test, regression suite, documentation

- [x] T062 E2e recovery-determinism test: kill-9 mid-autonomous-chain + restart → same terminal state, no duplicated dispatch or findings in `services/api/internal/chain/workflow_test.go` (SC-007)
- [x] T063 [P] Verify no regression: run full `go test ./...` with and without `asc` on PATH — confirm Phase 3/4/5 tests still pass (SC-008)
- [x] T064 [P] Verify `go build ./...` across all workspace modules
- [x] T065 [P] Run `just generate` and confirm no codegen drift (CI gate)
- [x] T066 Run quickstart.md validation — `make up`, seed a task, verify it flows autonomously to DONE with correct stageSlots in GraphQL response
- [x] T067 [P] Update `scripts/dbos-recovery-demo.sh` to cover autonomous-chain recovery scenario

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup (T005) — BLOCKS all user stories
- **US2 Routing (Phase 3)**: Depends on Phase 2 (types + model client)
- **US4 Containment (Phase 4)**: Depends on Phase 2 (types + model client)
- **US1 Autonomous Chain (Phase 5)**: Depends on Phase 3 (router) AND Phase 4 (runner)
- **US3 Human Candidate (Phase 6)**: Depends on Phase 5 (chain wiring exists)
- **US5 Autonomy (Phase 7)**: Depends on Phase 3 (router logic exists)
- **US6 Budget (Phase 8)**: Depends on Phase 4 (runner) AND Phase 5 (chain)
- **GraphQL+Flutter (Phase 9)**: Depends on Phase 5 (chain + router exist)
- **Polish (Phase 10)**: Depends on all prior phases

### User Story Dependencies

- **US2 (Routing)**: Can start after Phase 2 — no dependency on other stories
- **US4 (Containment)**: Can start after Phase 2 — no dependency on other stories (parallel with US2)
- **US1 (Autonomous Chain)**: Depends on US2 + US4 — integration phase
- **US3 (Human Candidate)**: Depends on US1 — tests the fallback path
- **US5 (Autonomy)**: Depends on Phase 2 + US2 — can run parallel with US1
- **US6 (Budget)**: Depends on US1 — extends the runner with budget tracking

### Within Each User Story

- Implementation tasks before integration tests
- Types/interfaces before implementations
- Unit tests alongside or immediately after implementation
- E2e tests last (need full integration)

### Parallel Opportunities

- **Phase 2**: T006–T014 all [P] — different files, independent types
- **Phase 3 + Phase 4**: US2 (router) and US4 (runner) can proceed in parallel after Phase 2
- **Phase 7 (US5)**: Can run in parallel with Phase 5 once router exists
- **Phase 9**: GraphQL (T052–T057) and Flutter (T058–T061) can proceed in parallel

---

## Parallel Example: Phase 2 (Foundational)

```bash
# All these can run in parallel (different files):
Task T006: "Define Findings types in internal/agent/stage_result.go"
Task T007: "Define StageResult type in internal/agent/stage_result.go"  # same file as T006, do together
Task T008: "Define SlotDecision in internal/chain/slot_decision.go"
Task T009: "Define Expression types in internal/router/eligibility.go"
Task T010: "Define AgentModelClient in internal/agent/model_client.go"
Task T011: "Implement LogAgentClient in internal/agent/log_client.go"
```

## Parallel Example: Phase 3 + Phase 4

```bash
# Router and Runner can be built in parallel:
# Agent A: Phase 3 (router)
Task T015-T023: eligibility evaluator + router + tests

# Agent B: Phase 4 (runner)
Task T024-T030: runner + allowlist + containment tests
```

---

## Implementation Strategy

### MVP First (User Story 1 — Autonomous Chain)

1. Complete Phase 1: Setup (T001–T005)
2. Complete Phase 2: Foundational (T006–T014) — CRITICAL
3. Complete Phase 3: Router (T015–T023) + Phase 4: Runner (T024–T030) — in parallel
4. Complete Phase 5: Chain wiring + e2e (T031–T038)
5. **STOP and VALIDATE**: `go test ./internal/chain/ -run TestAutonomousChain` passes ✅
6. This alone proves the phase's reason to exist (SC-001)

### Incremental Delivery

1. Setup + Foundational → build compiles
2. Router + Runner → unit tests pass (SC-002, SC-004)
3. Chain integration → autonomous e2e passes (SC-001) — **MVP!**
4. Human fallback → human path proven (SC-003)
5. Autonomy → readout works (SC-005)
6. Budget → cost bounded (SC-006)
7. GraphQL + Flutter → client surfaces it (SC-009)
8. Polish → recovery + regression (SC-007, SC-008)

### Parallel Team Strategy

With two agents working in parallel:
1. Both complete Phase 1 + Phase 2 together
2. Agent A: Phase 3 (Router) → Phase 5 (Chain) → Phase 6 (Human)
3. Agent B: Phase 4 (Runner) → Phase 7 (Autonomy) → Phase 8 (Budget)
4. Rejoin: Phase 9 (GraphQL+Flutter) → Phase 10 (Polish)

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks in same phase
- [Story] label maps task to specific user story for traceability
- LogAgentClient is essential — all CI tests use it (no live model dependency, NFR-003)
- Existing Phase 3/4/5 tests MUST NOT break (NFR-002) — run `go test ./...` after each phase
- The chain workflow refactor (T031–T034) is the highest-risk work — test recovery immediately (T062)
- `just generate` must be run after sqlc query changes (T005) and schema changes (T055)
