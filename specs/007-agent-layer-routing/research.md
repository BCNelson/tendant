# Research: The Agent Layer (Specialists as Config) & Routing

**Date**: 2026-06-07 | **Branch**: `007-agent-layer-routing`

## R1: Agent Model-Call Shape (Multi-Turn vs Single-Shot)

**Decision**: New `AgentModelClient` interface in `internal/agent/` — multi-turn tool-use
conversation over the same Provider HTTP infrastructure.

**Rationale**: The existing `overseer.Provider.Call(ctx, PromptPayload) (RawResponse, error)` is
single-shot with a fixed labeled-slots prompt structure (`[OWNER_INSTRUCTIONS]`,
`[TOOL_METADATA]`, `[CONCRETE_CALL]`, `[SCRIPT_EVIDENCE]`). The agent runner needs iterative
tool-use: send conversation → receive assistant response with tool_use blocks → send
tool_result → repeat. These are fundamentally different call patterns that cannot share a
prompt shape.

The new interface accumulates messages and exposes only the allowlisted tool definitions.
Provider adapters (Anthropic, OpenAI, Log) implement it by building the appropriate HTTP
request (same `net/http`, same credentials, same env-var selection). No new third-party dep.

**Alternatives considered**:
- Extending `overseer.Provider` with a `Chat` method → breaks single-responsibility; overseer
  and agent runner have different safety invariants (labeled slots vs conversation accumulation).
- Using the overseer's single-shot Provider per iteration (rebuild full context each time as a
  single user message) → works mechanically but loses proper tool_use/tool_result message
  structure that models expect for multi-turn tool interactions.

## R2: DBOS Recovery Determinism Under Human/Agent Branching

**Decision**: Branch on a memoized step result (`SlotDecision`). Recv is called only for
human paths — deterministic on replay because the step replays the same value.

**Rationale**: DBOS requires the exact same step/Recv call sequence on every replay. The
workflow comment (chain/workflow.go:155) warns against branching on "observed state." However,
a memoized step result IS deterministic on replay — DBOS replays it byte-for-byte. Branching
on it produces the same code path every time.

The per-stage pattern: one memoized step (route + occupy) returns `SlotDecision{IsHuman bool,
StageResult json.RawMessage}`. If human: Recv is called (blocks → memoized). If agent: Recv
is skipped, result is in SlotDecision. On replay: step returns same; Recv is called/skipped
identically.

**Alternatives considered**:
- Always call Recv, pre-Send for agents → Send inside a step is not supported by the DBOS
  Go library (it's a workflow-level operation); external Send before Recv is racy.
- One step per decision point (route step → occupy step → Recv → resolve step) with fixed
  sequence → doubles step count; the route step's return determines what the occupy step does
  internally, which is equivalent but more steps to memoize.

## R3: Boolean Expression Eligibility Grammar

**Decision**: Hand-written recursive-descent evaluator in Go (~200 LOC). No external
parser library.

**Rationale**: The expression grammar is small and fixed (AND/OR/NOT over three predicate
types: subset, numeric threshold, set-membership). A hand-written evaluator is trivially
testable, has no dependency, compiles instantly, and is easy to extend for v2. The grammar
binds only to the four normative `Findings.Structured` fields.

**Alternatives considered**:
- `expr-lang/expr` (Go expression evaluator) → new dependency; requires approval per
  constitution; overkill for a fixed-field grammar.
- JSON-based filter DSL (like MongoDB queries) → less readable for owners authoring eligibility
  rules; harder to express NOT/OR nesting.
- CEL (Common Expression Language) → large dep; designed for policy engines at Google scale;
  overkill for single-household.

## R4: Autonomy Derivation Formula

**Decision**: Computed in the GraphQL resolver from the execution-slot occupant's tool
allowlist rungs.

**Rationale**: `Task.autonomy` exists in the schema (hardcoded `NONE` since Phase 0). Making
it a real derived value requires no migration — just replacing the constant in
`graph/mappers.go`. The derivation reads the router's would-be execution-stage pick (or the
live workflow's memoized decision) and inspects the highest tool rung reachable.

**Formula**:
- Human occupies execution → `NONE`
- Specialist, no tools in allowlist → `ENRICH_ONLY`
- Specialist, all tools at `execute_gated` rung → `EXECUTE_GATED`
- Specialist, any tool at `execute_auto` rung → `EXECUTE_AUTO`
- Otherwise → `PROPOSE`

This changes dynamically when: the execution specialist is swapped (different allowlist),
a tool is promoted to a higher rung, or findings change routing.

## R5: Per-Task Gate-Call Budget & Max-Iteration

**Decision**: Per-task budget default 100, per-stage max-iteration 20. Both configurable via
env vars. Fail-close to human on exhaustion.

**Rationale**:
- Budget of 100: a three-stage autonomous chain (triage + expansion + execution) with ~30
  agent iterations total and 1–3 tool calls per iteration = ~30–90 gate calls. Budget of 100
  gives comfortable headroom while preventing runaway loops.
- Max-iteration of 20 per stage: an agent that hasn't converged in 20 iterations is likely
  stuck. Fail-close is safe (human takes over).
- Budget is tracked in-memory per workflow run (not persisted). On recovery, memoized steps
  replay without re-invoking the gate, so the budget doesn't need persistence.

**Env vars**: `TENDANT_GATE_CALL_BUDGET` (default 100), `TENDANT_AGENT_MAX_ITER` (default 20).

## R6: Human Candidate Synthesis

**Decision**: The router synthesizes a human candidate in code; no `agent_configs` row.

**Rationale**: The `is_human` column exists in the Phase 0 schema but seeding it creates an
asymmetry — the human row would need to exist at every stage and would be the only row with
a null system_prompt. Synthesizing is simpler: the router unconditionally adds a `{IsHuman:
true}` candidate to the survivor set after eligibility pruning. This ensures the human is
always eligible without special-casing the query or seed.

**Alternatives considered**:
- Seeded `is_human = true` rows per stage → uniform catalog, but adds 3 rows that exist only
  to be "always eligible" with no real config content; complicates catalog listing UIs.

## R7: Flutter Client — Routing Views

**Decision**: New `features/routing/` module following existing riverpod + ferry + go_router
pattern. Read-only views backed by additive GraphQL fields.

**Rationale**: Every prior phase (2–5) added Flutter widgets. The clarification confirmed
Phase 6 includes routing/specialist UI. The established pattern is:
- Feature module under `apps/mobile/lib/features/`
- Riverpod FutureProvider for data fetching
- View models separate from ferry-generated types
- GoRouter nested route

New views: `RoutingDetailPage` showing per-stage slot occupant + routing decision + autonomy.
No new write mutations on the client.
