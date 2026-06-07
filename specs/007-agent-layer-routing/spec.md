# Feature Specification: The Agent Layer (Specialists as Config) & Routing

**Feature Branch**: `007-agent-layer-routing`
**Created**: 2026-06-07
**Status**: Draft
**Input**: Phase 6 — The Agent Layer (Specialists as Config) & Routing (v2 arch §3, §8, §7.1, §15 Q3, App. A/D)

## Overview

Phase 6 turns the human-only chain into a real autonomous chain. It rests on three
load-bearing claims, each inherited from the trust spine built in Phases 3–5:

1. **One trusted runner; specialists are config, not code.** There is a single Go
   plan→act→observe loop. A "specialist" is a row in `agent_configs` that parameterizes it
   (`{stage, system_prompt, model, tool_allowlist, eligibility, origin, version, is_human}`).
   Adding a specialist is **data, not a deploy.**

2. **A config-driven agent is contained by exactly two things — no sandbox required.**
   (a) The **per-agent tool allowlist**: the runner exposes *only* the configured tools to
   the model, so the agent cannot even name a tool outside its set. (b) The **universal
   gate**: whatever it does call is independently floored, scripted, and overseen by rules
   the agent's prompt cannot reach. A hostile system prompt can make an agent *try* things;
   every attempt is still gated.

3. **The human is one catalog entry, not a special path.** "Route to the human" is the same
   mechanism as routing to any specialist — the human is always an eligible candidate, and
   selecting them opens an `agent_assignments` row and waits on the existing Phase 1/2
   wait-on-event. This collapses the Phase 1 human-only path, gate `RequestDecision`, and
   mid-flight hand-off into one mechanism: "an agent chose the human for the next slot."

**Emergent autonomy is preserved.** There is still no stored autonomy dial; `Task.autonomy`
remains resolver-computed — now a genuine readout of which specialist holds the execution
slot plus the per-tool rungs it can reach.

## Clarifications

### Session 2026-06-07

- Q: Phase 4 ships no overseer verdict cache. How should Phase 6 control the cost/latency of
  multiplied gate calls? → A: **No cache.** Keep Phase 4's stance verbatim; control cost via
  aggressive Layer-3 script pre-emption and a per-task gate-call budget that fail-closes to
  the human.
- Q: What base specialist catalog should v1 ship? → A: **Rich multi-specialist catalog** —
  several specialists per stage across distinct capability profiles, so eligibility pruning
  and LLM-pick are exercised against real competition. Human always eligible.
- Q: How is the Findings + AgentConfig schema versioned? → A: **Internal schema only** —
  governed by `agent_configs.version` and a documented Findings shape; not promoted to a
  formal `contracts/` artifact.
- Q: When the router selects a non-human specialist, does it run inline or open an
  assignment? → A: **Inline.** A specialist runs synchronously inside a memoized DBOS step;
  only the human path opens an `agent_assignments` row and blocks on the wait-on-event.
- Q: What happens when the LLM router returns a config that is not in the eligible survivor
  set? → A: **Rejected deterministically.** The pick is validated against the survivor set;
  an out-of-set pick is discarded and the router falls back to the human (always eligible).
- Q: What is Phase 6's client-side scope? → A: **Include routing/specialist UI.** Add
  read-only Flutter views surfacing which specialist (or human) holds each slot and the
  routing decision, in addition to the now-real `Task.autonomy` readout.
- Q: How is the always-eligible human candidate represented in the catalog? → A:
  **Synthesized by the router.** No `is_human = true` row is seeded in `agent_configs`; the
  router synthesizes a human candidate in code and always adds it to the survivor set.
- Q: Which structured fields are normative in the v1 `Findings.Structured` contract? → A:
  **Fix the four illustrative fields** — `{category_hints: string[], stakes_score: number,
  entities: [...], required_capabilities: string[]}`. Eligibility may only bind to these;
  extra keys are ignored.
- Q: What matching operators must the deterministic eligibility prune support in v1? → A:
  **Full boolean expression language** — arbitrary AND/OR/NOT over predicates
  (subset, numeric threshold, set-membership) evaluated against `Findings.Structured`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Autonomous chain, no human in the loop (Priority: P1)

An owner-authored task flows through **real** triage → expansion → execution → completion,
each stage occupied by a specialist config running on the one trusted runner, with **no
human assignment opened** — while every outward tool call is gated exactly as in Phase 3.

**Why this priority**: This is the phase's reason to exist — replacing human-in-every-slot
with routed specialists. Without it, nothing else matters.

**Independent Test**: Seed a task whose findings make specialists eligible at every stage;
run the chain end-to-end against testcontainers Postgres with the deterministic LogProvider;
assert the task reaches `DONE` with `findings`/`context_refs` populated, an audit DAG showing
agent-run steps (not human assignments), and at least one gated `tool_outcomes` row.

**Acceptance Scenarios**:

1. **Given** an owner-authored task and a catalog with eligible specialists for triage,
   expansion, and execution, **When** the chain workflow runs, **Then** each stage is
   occupied by a specialist (no `agent_assignments` row is opened for those stages) and the
   task advances to `COMPLETION`/`DONE`.
2. **Given** an execution-stage agent that proposes an outward tool call, **When** the call
   is composed, **Then** it passes through `gate.Evaluate` (floor → script → overseer) and a
   `tool_outcomes` row plus the Phase 3 audit chain
   (`tool_call_composed → gate_verdict → … → tool_outcome_recorded`) are written.
3. **Given** the workflow is killed mid-run and restarted, **When** DBOS recovers it,
   **Then** the same step sequence replays from memoized results without re-emitting an
   already-dispatched tool call or duplicating findings.

---

### User Story 2 - Eligibility-bound routing (Priority: P1)

The router prunes the catalog deterministically against the findings' **structured** fields,
then an LLM picks among the survivors using the **free text**. An ineligible specialist is
never chosen; non-determinism is fenced inside a vetted candidate set.

**Why this priority**: Routing quality is the safety boundary on autonomy — the LLM must only
ever pick among genuinely-capable specialists.

**Independent Test**: Construct findings whose structured fields satisfy the eligibility of
only a known subset of specialists; run `Router.Select`; assert (a) the chosen config is in
the eligible subset, (b) every ineligible config was pruned before the LLM saw it, and (c)
with a stubbed LLM forced to name an ineligible config, the selection is rejected and falls
back to the human.

**Acceptance Scenarios**:

1. **Given** findings whose `structured` satisfies specialists A and B but not C, **When**
   `Router.Select` runs, **Then** C is pruned deterministically and the LLM is presented only
   {A, B, human}.
2. **Given** the eligible set {A, B, human} and free text favoring B, **When** the LLM picks,
   **Then** B occupies the next stage.
3. **Given** an LLM that returns config C (ineligible), **When** the router validates the
   pick, **Then** C is discarded and the slot falls back to the human (always eligible).

---

### User Story 3 - Human as a routed candidate (Priority: P1)

When no specialist is eligible for a stage (or a config/eligibility rule directs it), the
router places the **human** in the slot, resolving over the **same** assignment + wait-on-event
mechanism from Phase 1/2 — proving the human is one catalog entry, not a special path.

**Why this priority**: This is the unifying invariant; it must hold for autonomy to be a true
readout rather than a separate code path.

**Independent Test**: Construct findings that satisfy no specialist's eligibility at a stage;
run the chain; assert an `agent_assignments` row is opened, a push job is enqueued (Phase 2
seam), and resolving it via the existing mutation advances the chain identically to Phase 1.

**Acceptance Scenarios**:

1. **Given** a stage with no eligible specialist, **When** the router selects, **Then** it
   returns the human and the chain opens an `agent_assignments` row with `to_principal` set.
2. **Given** an open human assignment opened by the router, **When** the owner resolves it,
   **Then** the chain resumes over the same `dbos.Send`/`Recv` topic as Phase 1.
3. **Given** an agent stage that emits a tool call the gate floors to `RequestDecision`,
   **When** the decision is opened, **Then** the human resolves it over the identical
   wait-on-event — i.e. gate `RequestDecision` and router-to-human are the same wake.

---

### User Story 4 - Hostile prompt is contained (Priority: P1)

A deliberately hostile `system_prompt` cannot reach a tool outside its allowlist, and any
outward attempt it does make is still gated and floored.

**Why this priority**: Customizable (eventually community-contributed) prompts are only safe
because containment does not depend on the prompt being benign. This must be proven.

**Independent Test**: Seed a specialist whose `system_prompt` instructs the model to call a
tool outside its `tool_allowlist` and to exfiltrate a secret; run the runner; assert (a) the
runner never exposes the off-allowlist tool to the model and refuses any reference to it, and
(b) any allowlisted-but-dangerous call still trips the floor / overseer.

**Acceptance Scenarios**:

1. **Given** a hostile prompt naming an off-allowlist tool, **When** the runner builds the
   model's tool set, **Then** only allowlisted tools are exposed and an off-allowlist call is
   refused before reaching the gate.
2. **Given** a hostile prompt that frames a spend/secret-disclosure call as authorized,
   **When** the call is composed, **Then** the categorical floor trips `RequestDecision`
   regardless of the prompt's framing (the overseer reads the concrete call, never the
   framing).

---

### User Story 5 - Autonomy as a derived readout (Priority: P2)

`Task.autonomy` returns a sensible derived value that **changes when the execution specialist
is swapped or a tool is promoted** — with no migration and no stored dial.

**Why this priority**: It demonstrates the "emergent autonomy" invariant concretely and gives
the operator a truthful view of what the task can do.

**Independent Test**: Compute `Task.autonomy` for a task whose execution slot is held by a
read-only specialist, then by an execution specialist with a gated tool; assert the readout
changes (e.g. `ENRICH_ONLY` → `EXECUTE_GATED`) with no schema change.

**Acceptance Scenarios**:

1. **Given** a task whose execution slot is human-only, **When** `autonomy` is resolved,
   **Then** it returns a conservative level (no autonomous execution).
2. **Given** the execution slot held by a specialist whose allowlist contains a gated tool,
   **When** `autonomy` is resolved, **Then** it returns `EXECUTE_GATED`.
3. **Given** a tool is promoted to auto, **When** `autonomy` is re-resolved, **Then** the
   readout rises accordingly — with no migration.

---

### User Story 6 - Cost/latency stays bounded (Priority: P2)

A multi-stage, multi-call task cannot run away on LLM round-trips. A per-task gate-call budget
bounds total agent activity and **fail-closes to the human** when exhausted; Layer-3 scripts
pre-empt the overseer wherever possible.

**Why this priority**: Cost/latency peaks here (router + agents + overseer per call); without a
budget the UX and bill suffer. (No verdict cache by design — per clarification.)

**Independent Test**: Configure a low per-task gate-call budget; drive a task that would
exceed it; assert that on exhaustion the chain opens a human assignment rather than continuing
to call the model, and that an audit row records the budget trip.

**Acceptance Scenarios**:

1. **Given** a per-task gate-call budget of N, **When** an agent attempts the N+1th gated
   call, **Then** the call is not sent to the overseer; the slot fail-closes to the human and
   an audit row records `budget_exhausted`.
2. **Given** a Layer-3 script that returns a terminal verdict, **When** a gated call matches,
   **Then** the overseer is not invoked (script pre-emption), conserving budget.

---

### Edge Cases

- **No eligible specialist anywhere** → every stage routes to the human; the chain degrades
  gracefully to Phase 1 behavior.
- **LLM router names an ineligible/unknown config** → pick rejected, fall back to human.
- **Agent loop never converges** → a max-iteration bound per stage terminates the loop and
  fail-closes to the human with an audit row.
- **Agent emits malformed findings** (unparseable `structured`) → treated as empty structured
  findings for eligibility (prunes to the most conservative survivor set, typically human).
- **Agent references an off-allowlist tool** → refused by the runner before gate; recorded.
- **Model gateway unavailable / errors** → fail-closed: the slot routes to the human (mirrors
  the overseer's fail-closed posture).
- **Recovery mid-agent-run** → the agent run is a memoized DBOS step; replay returns the
  recorded `StageResult` without re-calling the model or re-dispatching tools.
- **Budget exhausted mid-stage** → fail-close to human (US6).
- **`origin = community` config present** → registration/install flow is deferred (Phase 10);
  v1 only consumes `origin = core` configs from the seeded catalog, but the schema admits
  community rows.
- **Human resolves an agent-opened `RequestDecision`** → identical wake path as a
  router-placed human slot (US3 scenario 3).

## Requirements *(mandatory)*

### Functional Requirements

**Agent runner**

- **FR-001**: A new `internal/agent` (runner) package MUST expose an `AgentRunner` whose
  `Run(ctx, cfg *AgentConfig, t *Task) (StageResult, error)` executes one plan→act→observe
  loop parameterized entirely by `cfg`. The same Go type MUST serve every specialist; a
  specialist is data, never a new code path.
- **FR-002**: The runner MUST expose to the model **only** the tools whose IDs appear in
  `cfg.ToolAllowlist`, resolved to concrete `tools` rows. A model-proposed call naming any
  tool outside the allowlist MUST be refused by the runner before it reaches the gate, and the
  refusal MUST be audited.
- **FR-003**: Every outward tool call the runner emits MUST be composed and evaluated through
  the **existing** universal gate path (`gate.Evaluate` → `proposeToolCall`/`toolflow`), with
  no privileged bypass. The agent path and the human-composed path MUST share the same gate.
- **FR-004**: On a gate verdict of `Approve`, the runner MUST dispatch via the existing
  toolflow and observe the `tool_outcomes` result; on `RequestDecision`, it MUST open the
  decision and route to the human over the wait-on-event (FR-014); on `Deny`, it MUST observe
  the denial and continue/terminate per the loop policy.
- **FR-005**: The runner MUST terminate each stage with a `StageResult` carrying
  `Findings{Structured, FreeText}` and (for expansion) `context_refs`, OR fail-close to the
  human on budget exhaustion / max-iteration / gateway error.
- **FR-006**: The runner MUST gain a **seam** to "receive + answer inbound queries as events"
  for the future sub-agent protocol (Phase 9). v1 only stubs the seam; no inbound protocol
  ships.

**Agent config catalog**

- **FR-007**: The catalog MUST be read from the existing `agent_configs` table
  (`{id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin,
  version}`). New sqlc queries MUST list configs by stage and load by id. No new table or
  migration is required for the catalog.
- **FR-008**: Core MUST seed a **rich base catalog**: several `origin = core` specialists per
  occupied stage (triage, expansion, execution) with **distinct eligibility constraints**, so
  routing exercises real competition. The human candidate MUST be **synthesized by the
  router** in code (not seeded as an `agent_configs` row); no `is_human = true` row is
  required in v1 (the column remains in the Phase 0 schema, unused by the seeded catalog).
- **FR-009**: `Model` on a config MUST resolve through the platform model gateway (the
  Phase 4 overseer Provider seam / a shared model-call seam), not a per-config HTTP client.
  Provider selection and credentials remain process-level.

**Findings & enrichment**

- **FR-010**: Triage and expansion agents MUST write `tasks.findings` as
  `{structured: <json>, free_text: <string>}`; the `structured` fields are the
  machine-checkable surface that hard eligibility binds to, and `free_text` is the narrative
  the LLM router reads. The v1 **normative** `structured` schema is exactly
  `{category_hints: string[], stakes_score: number, entities: [...], required_capabilities:
  string[]}`; eligibility MAY only bind to these fields and any extra keys MUST be ignored.
  Expansion MUST additionally write `tasks.context_refs` (read-only enrichment).
- **FR-011**: The Findings shape (FR-010) and the `AgentConfig.eligibility` grammar (FR-012)
  MUST be documented and versioned **internally** (via `agent_configs.version` + the
  spec-documented shape above). They are NOT promoted to a formal `contracts/` artifact in v1.

**Router**

- **FR-012**: A `Router.Select(ctx, stage, findings) (*AgentConfig, error)` MUST replace
  `HumanOnlyRouter`. It MUST (a) **deterministically prune** the stage's configs by
  evaluating each config's `eligibility` against `findings.structured`, then (b) have the LLM
  **pick among survivors** using `findings.free_text`. The synthesized human candidate (FR-008)
  MUST always be in the survivor set. The `eligibility` grammar MUST be a **boolean expression
  language** — arbitrary AND/OR/NOT composition over predicates (capability subset
  `required_capabilities ⊆ findings`, numeric thresholds on `stakes_score`, and set-membership
  on `category_hints`/`entities`) — evaluated deterministically with no model call.
- **FR-013**: The router MUST validate the LLM's pick against the eligible survivor set; a
  pick outside the set (or an unparseable/empty response) MUST be discarded and the slot MUST
  fall back to the human. Eligibility pruning MUST be pure/deterministic (no model call).

**Stage wiring & determinism**

- **FR-014**: When the router selects the **human**, the chain MUST open an
  `agent_assignments` row (with `to_principal`, push enqueue) and block on the existing
  per-stage wait-on-event — i.e. the exact Phase 1/2 path. When it selects a **specialist**,
  the chain MUST run the runner **inline** within a memoized DBOS step and advance without
  opening a human assignment.
- **FR-015**: The chain workflow MUST preserve DBOS **recovery determinism**: the router
  decision and the agent run MUST be captured as memoized DBOS steps so that the sequence of
  step calls — and their outcomes — replay identically on recovery. No branch may depend on
  un-memoized observed state.
- **FR-016**: The triage, expansion, and execution stages MUST be wired as configs over the
  runner; creation and completion remain automatic (no occupant), as in Phase 1.

**Containment & cost**

- **FR-017**: Containment MUST rest solely on (a) the per-agent allowlist (FR-002) and (b) the
  universal gate (FR-003) — no per-agent sandbox. A hostile `system_prompt` MUST NOT be able
  to reach an off-allowlist tool nor bypass the categorical floor.
- **FR-018**: A **per-task gate-call budget** MUST bound total gated calls across all stage
  agents for a task. On exhaustion, the next gated call MUST NOT invoke the overseer; the slot
  MUST fail-close to the human and the trip MUST be audited (`budget_exhausted`). The budget
  MUST be configurable (env), analogous to `TENDANT_OVERSEER_MAX_EVAL_PER_TASK`.
- **FR-019**: There MUST be **no overseer verdict cache** (per clarification). Cost control is
  the per-task budget plus Layer-3 script pre-emption (a terminal script verdict MUST skip the
  overseer).

**Autonomy readout**

- **FR-020**: `Task.autonomy` MUST be computed (no stored column, no migration) from the
  execution-slot occupant and the per-tool rungs reachable through its allowlist. The readout
  MUST change when the execution specialist is swapped or a tool is promoted.

**Audit**

- **FR-021**: New audit kinds MUST record the agent layer's activity, chained into the
  existing DAG: at minimum agent-run start/finish, router selection (with eligible set +
  pick), agent tool-call refusal (off-allowlist), and budget/fail-close trips. Existing
  Phase 3–5 audit kinds for gated calls MUST be reused unchanged.

**GraphQL surface (additive only)**

- **FR-022**: Any GraphQL change MUST be **additive** under the operator-edge contract's
  Path-1 policy. `Task.autonomy` becomes a real computed value (no schema change — the field
  already exists). A read-only surface exposing the per-stage **slot occupant** (the chosen
  specialist or the human) and the **routing decision** MUST be added additively (it backs
  FR-023); read-only exposure of the agent config catalog MAY also be added. No breaking
  change is permitted.

**Client (Flutter)**

- **FR-023**: The Flutter app MUST add **read-only** views that surface, per task: which
  specialist (or the human) holds each occupied stage's slot, the routing decision for that
  slot, and the now-real `Task.autonomy` readout. No new write surface is added on the client.

### Non-Functional Requirements

- **NFR-001**: Recovery determinism — a kill-9 + restart at any point in an autonomous chain
  MUST resume to the same terminal state with no duplicated tool dispatch or findings
  (testcontainers + DBOS, mirroring the Phase 1 chain tests).
- **NFR-002**: No regression — the Phase 3 happy path (Phase 3 SC-001), the Phase 4 overseer
  path, and the Phase 5 gate-script paths MUST all still pass. `go build` + `go test ./...`
  green across all API packages, with and without `asc` on PATH.
- **NFR-003**: Determinism in test — the autonomous-chain e2e MUST be deterministic against
  the LogProvider (no live model dependency in CI).
- **NFR-004**: Floor supremacy preserved — the categorical floor MUST trip regardless of any
  agent prompt or router decision (Constitution III), proven by an injection test.

### Key Entities

- **AgentConfig**: a catalog row parameterizing the one runner —
  `{ID, Stage, IsHuman, SystemPrompt, Model, ToolAllowlist []uuid, Eligibility json,
  Origin, Version}`. `Stage` spans the three occupied stages (triage/expansion/execution).
- **Findings**: `{Structured json.RawMessage, FreeText string}` written to `tasks.findings`.
  The v1 normative `Structured` schema is `{category_hints: string[], stakes_score: number,
  entities: [...], required_capabilities: string[]}` and binds hard eligibility; `FreeText`
  feeds the router's LLM pick.
- **Router**: prunes configs by eligibility (deterministic boolean-expression evaluation over
  `Structured`), then LLM-picks among survivors (on `FreeText`); the synthesized human
  candidate is always in the survivor set; out-of-set picks rejected.
- **AgentRunner**: the one trusted plan→act→observe loop; emits gated tool calls; returns a
  `StageResult`.
- **StageResult**: the runner's output for a stage — `{Findings, ContextRefs, NextRoute}` or a
  fail-close-to-human signal.
- **Eligibility**: a deterministic **boolean expression language** (AND/OR/NOT over predicates
  — capability subset, numeric thresholds, set-membership) evaluated against the normative
  `Findings.Structured` fields.

## Out of Scope (deferred)

- **Community agent registration** (open contribution, surface-and-confirm install, BYO-model)
  — Phase 10. v1 ships only the `origin = core` base catalog; the `AgentConfig` schema is
  fixed now.
- **Full sub-agent protocol** (inbound query/answer over events) — Phase 9. v1 adds only the
  runner seam (FR-006).
- **Auto-refining prompts/instructions** — owner-authored only in v1.
- **Overseer verdict cache** — explicitly not built (clarification).
- **Promoting Findings/AgentConfig to a formal versioned contract** — internal versioning
  only in v1 (clarification).

## Success Criteria *(mandatory)*

- **SC-001**: An owner-authored task flows through real triage → expansion → execution →
  completion with specialist configs and **no human assignment opened**, reaching `DONE`, with
  every outward call gated exactly as Phase 3 — verified against testcontainers + LogProvider.
- **SC-002**: For findings that make only a subset eligible, `Router.Select` presents the LLM
  only that subset (plus human); an ineligible specialist is provably never chosen, and an
  LLM pick outside the survivor set falls back to the human.
- **SC-003**: For a stage with no eligible specialist, the router opens a human
  `agent_assignments` row and the chain resumes over the identical Phase 1/2 wait-on-event.
- **SC-004**: A hostile `system_prompt` cannot reach an off-allowlist tool (refused before
  the gate) and its allowlisted dangerous attempts still trip the floor — proven by an
  injection test.
- **SC-005**: `Task.autonomy` returns a derived readout that changes when the execution
  specialist is swapped or a tool is promoted, with no migration.
- **SC-006**: A per-task gate-call budget fail-closes an over-budget task to the human without
  invoking the overseer past the cap, recorded in audit; a terminal Layer-3 script verdict
  skips the overseer.
- **SC-007**: A kill-9 + restart mid-chain resumes to the same terminal state with no
  duplicated tool dispatch or findings (NFR-001).
- **SC-008**: No regression — Phase 3/4/5 paths still pass; `go test ./...` green with and
  without `asc` on PATH.
- **SC-009**: The Flutter app shows, per task, the slot occupant (specialist vs human) and the
  routing decision for each occupied stage, plus the derived `Task.autonomy` — all read-only,
  driven by the additive GraphQL surface (FR-022/FR-023).

## Assumptions

- The base catalog is seeded by core at boot (mirroring `SeedOwner`); each specialist is an
  `origin = core` row in `agent_configs`. The human is **not** a seeded row — it is
  synthesized by the router as an always-eligible candidate at every stage.
- The platform model gateway is the Phase 4 overseer Provider seam (LogProvider default;
  Anthropic/OpenAI when credentialed); the agent runner reuses it rather than introducing a
  new HTTP client.
- Eligibility is evaluated against the normative `Findings.Structured` fields using a
  deterministic boolean-expression grammar (AND/OR/NOT over capability-subset, threshold, and
  set-membership predicates); absent/malformed structured findings prune conservatively
  (toward the human).
- The existing `agent_assignments` + `dbos.Recv`/`Send` + realtime `LISTEN tendant_events` +
  push seam back the human slot unchanged; routing to the human reuses them verbatim.
- `Task.autonomy` is computed in the GraphQL resolver layer (currently hardcoded `NONE` in
  `graph/mappers.go`); Phase 6 replaces that constant with a derivation, no schema change.
- All GraphQL changes are additive (Path 1); no breaking change to the operator-edge contract.
