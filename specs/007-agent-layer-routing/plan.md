# Implementation Plan: The Agent Layer (Specialists as Config) & Routing

**Branch**: `007-agent-layer-routing` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/007-agent-layer-routing/spec.md`

## Summary

Phase 6 replaces the human-only chain with a real autonomous chain. One trusted Go agent
runner (plan→act→observe) is parameterized by catalog rows (`agent_configs`); a router
(deterministic eligibility prune + LLM pick) selects occupants per stage. Every agent call
hits the universal gate. The human is a synthesized always-eligible candidate. No new
third-party dependencies are introduced.

## Technical Context

**Language/Version**: Go 1.25 (toolchain auto-tracks)
**Primary Dependencies**: chi/v5, gqlgen v0.17.90, pgx/v5, dbos-transact-golang v0.15.0, wazero (existing)
**Storage**: PostgreSQL 16+pgvector (existing; no new tables — uses Phase 0 `agent_configs`, `tasks.findings`, `tasks.context_refs`)
**Testing**: go test -race + testcontainers-go v0.39.0 (Docker v28.5.2)
**Target Platform**: Linux server (API) + Flutter mobile/desktop/web
**Project Type**: web-service + mobile-app
**Performance Goals**: Per-task gate-call budget (default 100); per-stage max-iteration 20; router LLM call <2s
**Constraints**: DBOS recovery-deterministic workflows; per-task budget fail-closes to human; no new deps
**Scale/Scope**: Single-household; rich catalog (~3–5 specialists per stage)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Edges not Core | ✅ | Agent runner is core orchestration (the "stable middle"). New tool calls go through MCP tool edge. No new data source or outward action added to core. |
| II. Task ≠ Workflow | ✅ | Preserved — task remains a durable Postgres record; workflow attaches (chain workflow continues to be separate). Findings/context_refs are task-level, not workflow-level. |
| III. Floor Immune | ✅ | Agents hit same gate; floor trips regardless of agent prompt/framing. SC-004 proves this. |
| IV. Owner Authors Trust | ✅ | Agent configs are owner-seeded (`origin = core`); agents cannot modify permissions or promote themselves. Labeled-slots discipline preserved (agent system prompt ≠ owner instructions). |
| V. Cancel Halts | ✅ | Cancellation unchanged — cancel sentinel + HALTED (Phase 1 path). |
| VI. Audit Everything | ✅ | New audit kinds (agent_run_started, agent_run_finished, router_selected, agent_call_refused, budget_exhausted) chain into existing DAG. |
| VII. Edge Contracts Versioned+Additive | ✅ | All GraphQL changes are Path 1 additive. No breaking changes. Findings/AgentConfig is internal-only (not a formal versioned contract — per clarification). |
| VIII. Federation-Shaped | ✅ | Task already has globalUri; findings/context_refs are task-level. Agent configs reference tools by UUID (tools have globalUri). |
| IX. Untrusted Code | N/A | No new executable extensions. Agent system prompts are text parameterizing the trusted Go runner — NOT executable/sandboxed code. Containment is structural (allowlist + gate), not sandbox. |

**New Dependencies**: None. The agent model client reuses the same `net/http` stdlib calls as
the overseer providers (Anthropic/OpenAI). The boolean-expression evaluator is hand-written
(~200 LOC). Flutter additions use existing ferry/riverpod/go_router.

## Project Structure

### Documentation (this feature)

```text
specs/007-agent-layer-routing/
├── plan.md              # This file
├── research.md          # Phase 0 output — design decisions
├── data-model.md        # Phase 1 output — entity schemas
├── quickstart.md        # Phase 1 output — demo/run instructions
├── contracts/           # Phase 1 output — GraphQL additive delta
│   └── graphql.v1.graphqls
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
services/api/
├── internal/
│   ├── agent/                      # NEW — the one trusted runner
│   │   ├── runner.go               # AgentRunner impl (plan→act→observe loop)
│   │   ├── runner_test.go          # Unit: loop mechanics, allowlist enforcement
│   │   ├── model_client.go         # AgentModelClient interface + provider adapters
│   │   ├── model_client_test.go    # Prompt assembly, multi-turn conversation
│   │   ├── stage_result.go         # StageResult, Findings types
│   │   └── seam.go                 # Sub-agent inbound query seam (Phase 9 stub)
│   ├── router/                     # NEW — eligibility prune + LLM pick
│   │   ├── router.go               # Router.Select, EligibilityMatcher
│   │   ├── router_test.go          # Prune tests, fallback tests, injection tests
│   │   ├── eligibility.go          # Boolean expression evaluator
│   │   ├── eligibility_test.go     # Expression parsing + evaluation
│   │   └── llm_picker.go           # LLM pick among survivors
│   ├── chain/
│   │   ├── router.go               # MODIFIED — remove HumanOnlyRouter, re-export Router interface
│   │   ├── workflow.go             # MODIFIED — new stage-slot step pattern
│   │   └── workflow_test.go        # MODIFIED — autonomous chain e2e
│   ├── core/
│   │   ├── seed.go                 # MODIFIED — add SeedAgentCatalog
│   │   └── seed_catalog.go         # NEW — rich base catalog seed data
│   ├── db/queries/
│   │   └── agent_configs.sql       # NEW — ListByStage, GetByID
│   └── server/
│       └── config.go               # MODIFIED — new env vars (budget, max-iter)
├── graph/
│   ├── schema.graphqls             # MODIFIED — additive types (Path 1)
│   ├── mappers.go                  # MODIFIED — Task.autonomy derivation
│   └── phase6_resolvers.go         # NEW — agent config queries, routing decision
└── cmd/tendant/
    └── main.go                     # MODIFIED — wire agent runner + real router

apps/mobile/lib/
├── features/
│   └── routing/                    # NEW — read-only routing/specialist views
│       ├── routing_detail_page.dart
│       ├── routing_provider.dart
│       └── routing_models.dart
└── core/router/
    └── routes.dart                 # MODIFIED — add routing detail route
```

**Structure Decision**: Feature-based. The agent runner and router are new `internal/` packages
(non-exported). The chain package is modified (not replaced). Flutter follows the established
`features/` pattern (riverpod + ferry + go_router).

## Design Decisions

### D1: Agent Model Client (new abstraction, no new dep)

The existing `overseer.Provider` is single-shot (one system + one user message → verdict).
The agent runner needs **multi-turn tool-use** (conversation accumulates across iterations).

**Design**: A new `AgentModelClient` interface in `internal/agent/` wraps the same Provider
infrastructure (same HTTP clients, credentials, `net/http`):

```go
type AgentModelClient interface {
    Chat(ctx context.Context, req ChatRequest) (ChatResponse, error)
}

type ChatRequest struct {
    Model    string
    System   string      // agent's system prompt (from AgentConfig)
    Messages []Message   // accumulated conversation (user/assistant/tool_result)
    Tools    []ToolDef   // only the allowlisted tools
}

type ChatResponse struct {
    Content    string        // assistant text
    ToolCalls  []ToolCall    // tool_use blocks
    TokensIn   int
    TokensOut  int
}
```

**Provider adapters** (Anthropic, OpenAI, Log) implement `AgentModelClient` by building the
appropriate HTTP request shape — same credentials (`TENDANT_OVERSEER_PROVIDER`,
`TENDANT_ANTHROPIC_KEY`, etc.), same selection logic. The `LogAgentClient` is deterministic
for CI (returns scripted tool calls from a fixture).

### D2: DBOS Recovery-Deterministic Stage Slot

The chain workflow branches on "human vs agent" per stage. This is valid because:
- The router decision is captured in a **memoized DBOS step** (returns `SlotDecision`).
- Branching on a memoized step result is deterministic on replay (the step replays the same
  value, so the same code path executes).
- `WaitForResult` (Recv) is only called for the human path; on replay, if the step says
  "human" then Recv is called (memoized), if "agent" then Recv is skipped (same as original).

**Per-stage step sequence**:
```
slotDecision := runRouteAndOccupyStep(ctx, d, taskID, stage)
  // Internally: router.Select → if human: open assignment; if agent: run loop, write findings

var result json.RawMessage
if slotDecision.IsHuman {
    result = WaitForResult(ctx, TopicForStage(stage), timeout)
    if isCancelSentinel(result) { return }
} else {
    result = slotDecision.StageResult
}

runResolveAndAdvanceStep(ctx, d, taskID, stage, next, result)
```

### D3: Boolean Expression Eligibility Grammar

Hand-written recursive-descent evaluator (~200 LOC). No parser-generator dependency.

**Grammar (v1)**:
```
Expr     := OrExpr
OrExpr   := AndExpr ("OR" AndExpr)*
AndExpr  := NotExpr ("AND" NotExpr)*
NotExpr  := "NOT" Atom | Atom
Atom     := SubsetPred | ThresholdPred | MembershipPred | "(" Expr ")"

SubsetPred      := "capabilities" "SUBSET_OF" findings.required_capabilities
ThresholdPred   := "stakes_score" ("<" | "<=" | ">" | ">=") number
MembershipPred  := "category_hints" "CONTAINS" string
                 | "entities" "CONTAINS" string
```

**Evaluation**: Pure function `Evaluate(expr Expression, findings Findings) bool`. No side
effects, no model call. Returns false on malformed input (conservative → human).

### D4: Autonomy Derivation (no migration)

`Task.autonomy` is computed in `graph/mappers.go`:
1. Determine execution-slot occupant: query the router for the execution stage with current
   findings (or, if a live workflow exists, read the memoized routing decision from the
   chain_workflows state).
2. If human → `NONE`.
3. If specialist → look up its `tool_allowlist`, resolve to tools, find the highest `rung`:
   - No tools → `ENRICH_ONLY`
   - All tools `execute_gated` → `EXECUTE_GATED`
   - Any tool `execute_auto` → `EXECUTE_AUTO`
   - Else → `PROPOSE`

### D5: Agent Runner Loop

```
func (r *Runner) Run(ctx, cfg, task) (StageResult, error):
    messages := []Message{userMessage(task context + findings prompt)}
    tools := resolveAllowlist(cfg.ToolAllowlist)
    
    for iteration := 0; iteration < r.maxIterations; iteration++:
        resp := r.client.Chat(ctx, {Model: cfg.Model, System: cfg.SystemPrompt, Messages, Tools: tools})
        
        if resp has no tool calls:
            // Agent is done — extract StageResult from response
            return parseStageResult(resp.Content)
        
        for each toolCall in resp.ToolCalls:
            if toolCall.ToolID not in allowlist:
                auditRefusal(toolCall)
                messages = append(messages, toolResultError("tool not in allowlist"))
                continue
            
            // Route through universal gate
            verdict := gate.Evaluate(ctx, toolCall, tool)
            switch verdict.Decision:
                case Approve:
                    outcome := dispatch(toolCall) // existing toolflow
                    messages = append(messages, toolResult(outcome))
                case RequestDecision:
                    return StageResult{FailCloseToHuman: true, PendingDecisionID: ...}
                case Deny:
                    messages = append(messages, toolResultError("denied by gate"))
                case AgentHandoff:
                    // Fall to overseer (Phase 5 behavior)
                    ...
            
            if budgetExhausted(task):
                audit("budget_exhausted")
                return StageResult{FailCloseToHuman: true}
    
    // Max iterations reached
    audit("max_iterations_reached")
    return StageResult{FailCloseToHuman: true}
```

### D6: Router LLM Pick

The LLM picker builds a single-shot prompt:
- System: "You are a routing assistant. Pick the best specialist for this stage."
- User: the task's `findings.free_text` + a structured list of eligible specialists (name,
  description/system_prompt summary, stage).
- Forced structured output: `{"config_id": "<uuid>"}`

Uses the same `AgentModelClient.Chat` (single turn, no tools). The `LogAgentClient` returns a
deterministic pick for tests.

### D7: Base Catalog Seed (Rich)

Seeded via `SeedAgentCatalog(ctx, q)` at boot (idempotent upsert by name+stage). Example:

| Stage | Name | Eligibility | Notes |
|-------|------|-------------|-------|
| triage | general-triager | `true` (always eligible) | Default; scores stakes, emits category_hints |
| triage | high-stakes-triager | `stakes_score >= 7` | Activated only on re-triage after expansion raises stakes |
| expansion | research-expander | `capabilities SUBSET_OF ["web_search", "doc_lookup"]` | Gathers context |
| expansion | decomposer | `category_hints CONTAINS "multi_step"` | Breaks task into sub-tasks |
| execution | email-specialist | `required_capabilities SUBSET_OF ["send-email"]` | Focused on email tool |
| execution | general-executor | `true` (always eligible) | Default execution agent |
| execution | code-executor | `required_capabilities SUBSET_OF ["run_code"]` | Code tool specialist |

Human is synthesized (always eligible, never in `agent_configs`).

### D8: Per-Task Gate-Call Budget

- Env var: `TENDANT_GATE_CALL_BUDGET` (default 100).
- Tracked in-memory per workflow run (not persisted — reset on recovery, which is safe because
  recovered workflows replay memoized steps and don't re-call the gate).
- On exhaustion: the runner returns `StageResult{FailCloseToHuman: true}`, triggering the
  human-wait path. Audit kind: `budget_exhausted`.

## Complexity Tracking

No constitution violations to justify.

## Post-Design Constitution Re-Check

| Principle | Post-Design Status |
|-----------|-------------------|
| I | ✅ Runner is core orchestration; tools stay at edges |
| II | ✅ Findings/context_refs on task record; workflow attaches separately |
| III | ✅ Floor trips identically for agent-composed calls (SC-004) |
| IV | ✅ Configs are owner-seeded; labeled-slots: system_prompt ≠ owner instructions |
| V | ✅ Cancel sentinel path unchanged |
| VI | ✅ Six new audit kinds chain into DAG |
| VII | ✅ GraphQL is additive (Path 1); Findings internal-only |
| VIII | ✅ Tasks have globalUri; agent configs reference tools by UUID |
| IX | N/A No executable extensions; prompts are text, not code |
