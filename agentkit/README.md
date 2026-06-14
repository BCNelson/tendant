# agentkit

A reusable **agent** framework extracted from tendant: the contained
plan→act→observe runner and the trust-spine that gates everything it does
(floor → script → overseer → earned-autonomy). You bring the orchestration;
agentkit brings the agent and its containment.

**Status:** scaffolding. First package (`tools`) lifted; the rest is sequenced
below.

## Scope: agents, not task management

agentkit is deliberately **just the agent layer**. Task management — what a
unit of work is, how it flows through stages, the human-approval/decision
lifecycle, intake, the operator inbox — is **not portable** and stays in the
consuming application (in tendant: the `tasks` table, the chain workflow, the
lifecycle state machine).

What agentkit owns:

- the **agent runner** (one trusted plan→act→observe loop; a specialist is a
  config over it, never new code)
- the **universal gate** that contains every tool call the agent makes
  (read-only short-circuit → hard-rule floor → gate script → overseer →
  earned-autonomy)
- the **tools** action-edge registry, the **overseer** LLM grader, the
  **gatescript** WASM sandbox, and the **calibration** trust ratchet
- the **model-client** seam (Anthropic/OpenAI/Gemini + a deterministic log
  client for tests)

What the **consumer** owns: when and why an agent runs, the unit of work it runs
against, what happens on a `RequestDecision`/fail-close (open a decision, wait
on a human, …), and how the agent is wrapped for durability.

## Wrap agents in your own DBOS workflow

agentkit is **opinionated about its runtime — Postgres + DBOS** — but it does
**not** own a workflow. The agent runner and the gate are plain, deterministic
Go designed to be invoked inside a **memoized DBOS step** in a workflow *you*
write. tendant wraps agents in its chain workflow; another application wraps the
same agents in its own. agentkit ships the building blocks (and a reference
example) for that wrapping — not a fixed orchestration.

This is why the runner is already seam-driven: it calls `GateEvaluator`,
`ToolDispatcher`, and `AuditWriter` rather than touching a workflow or a task
table directly. Your workflow supplies those implementations.

## The boundary

| agentkit (portable) | Application (e.g. tendant) |
|---|---|
| Agent runner (plan→act→observe) | The DBOS workflow that wraps/sequences agents |
| Universal gate (floor → script → overseer → autonomy) | What to do on RequestDecision / fail-close |
| Tool registry + `Tool` interface | Concrete tools (send-email, …) |
| Overseer LLM grader + provider seam | Provider credentials / config |
| Gate-script WASM sandbox | Authored gate scripts |
| Calibration (earned-autonomy ratchet) | Tuning knobs |
| Agent + trust catalog tables (see below) | tasks, lifecycle, decisions, inbox, intake, auth |
| `agentkit` Postgres schema + its migrations | App schema + migrations |

## Persistence

agentkit owns a small, dedicated **`agentkit` Postgres schema** (precedent:
DBOS's own `dbos` schema) holding only the agent + trust catalog: `agent_configs`,
`tools`, `tool_outcomes`, `tool_routine_grants`, `gate_scripts`, `owner_rules`.
Its trust state is keyed by an **opaque correlation id** the consumer supplies
(in tendant, the task id) — never a foreign key into an app table, so the
framework never depends on the app's schema. Audit flows out through the
`AuditWriter` seam into whatever store the consumer keeps. See
[docs/schema-separation.md](docs/schema-separation.md).

## Roadmap

1. **`tools` core — DONE.** Registry + `Tool` interface + idempotency plumbing
   (zero db dependency). tendant's `internal/tools` re-exports it via aliases,
   so existing importers are unchanged; concrete `send-email` + seed stay
   app-side.
2. **Decouple the runner from tendant.** Make `internal/agent.Runner` portable:
   resolve the tool allowlist via the `tools.Registry` (not `db.GetToolByID`);
   turn the taxonomy/guidance enrichments into optional injected seams (nil =
   skip); and key the run on a generic context + **opaque correlation id**
   instead of `TaskID/TaskTitle/TaskDesc`. Replace `db.AgentConfig` with a
   framework `AgentConfig` domain type. The `GateEvaluator`/`ToolDispatcher`/
   `AuditWriter` seams already isolate the workflow layer — no change needed.
3. **db foundation (agent + trust catalog only).** Stand up `agentkit/db` in the
   `agentkit` schema with its own goose version table: `agent_configs`, `tools`,
   `tool_outcomes`, `tool_routine_grants`, `gate_scripts`, `owner_rules`.
4. **`gate` + `gatescript` + `overseer` + `calibration`.** The decision spine.
   Replace `db.Tool` with a framework `Tool` domain type in `Gate.Evaluate`;
   relocate the WASM runner (with its embedded `asc.wasm`/`quickjs.wasm`) and the
   pure calibration helpers (`Band`, `Fingerprint`). Calibration keyed by the
   correlation id.
5. **DBOS step helpers + reference example.** Thin utilities for running an agent
   as a memoized step and the `Send/Recv` human-wake pattern, plus a minimal app
   that wraps agentkit end-to-end — proving a non-tendant project gets agents
   with little glue.

## Layout

```
agentkit/
├── go.mod
├── tools/            # action-edge registry (step 1 — done)
├── docs/
└── (agent, db, gate, gatescript, overseer, calibration, … to follow)
```

In-repo module first (wired via the root `go.work`), with tendant as the live
consumer that validates every seam against its testcontainers + DBOS-recovery
suite. Extraction to a standalone repo is a cheap `git filter-repo` once the
boundary is proven.
