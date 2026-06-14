# agentkit

The reusable agent framework extracted from tendant — the trust-spine that
turns "a config row" into a contained autonomous specialist, packaged so other
projects can adopt it wholesale.

**Status:** scaffolding. First package (`tools`) lifted; the rest is sequenced
below.

## What this is (and isn't)

`agentkit` is an **opinionated** framework. It does not try to abstract away its
runtime: **Postgres + DBOS are hard requirements**, not pluggable seams. A
consuming project gets the framework's schema (migrations), its sqlc-generated
queries, its DBOS workflows, and the trust-spine packages that ride on top.
This is a deliberate trade: by keeping the stack fixed we avoid abstracting the
two hardest dependencies (durable execution + persistence) and keep the
crash-recovery guarantees that make the agent loop safe.

What it is **not**: a storage-agnostic or orchestrator-agnostic SDK. If you
don't want DBOS+Postgres, this isn't your library.

## The framework/app boundary

The line is "generic agent machinery" vs "this product's domain":

| Framework (`agentkit`) | Application (e.g. tendant) |
|---|---|
| Tool registry + `Tool` interface | Concrete tools (send-email, …) |
| Universal gate (floor → script → overseer) | Tool permissions / owner rules data |
| Overseer LLM grader + provider seam | Provider credentials / config |
| Gate-script WASM sandbox | Authored gate scripts |
| Agent runner (plan→act→observe) | Agent catalog rows, prompts |
| Calibration (earned-autonomy ratchet) | Tuning knobs |
| DBOS chain + tool-call workflows | GraphQL surface, Flutter app, intake/connectors |
| Framework-owned schema + migrations | App-owned schema + migrations |

Model transport already lives behind a clean seam (`Provider` / `AgentModelClient`,
backed by `internal/llm`) with a deterministic log provider for tests — that
part is reuse-ready as-is.

## Why the trust-spine is the easy part

The tendant trust-spine is already exceptionally well-seamed: nearly every
domain component sits behind an interface (`Gate`, `Grader`, `Provider`,
`ScriptEvaluator`, `Tool`, `Router`, `StageRunner`, `Calibrator`,
`AgentModelClient`, `GateEvaluator`, `ToolDispatcher`, `AuditWriter`, …). The
loop logic ports almost verbatim.

**The real work is the schema split.** Every trust-spine package depends on
`*db.Queries`, and today that's one sqlc package
(`services/api/internal/db`, ~130 importers) mixing framework-schema queries
(tools, gate_scripts, agent_configs, pending_decisions, tool_outcomes, tasks,
audit_messages, transitions, agent_assignments, calibration, owner_rules) with
app-schema queries (connectors, intake_signals, embeddings, feedback, inbox,
sessions, …). agentkit must own the framework half (queries + migrations);
the app keeps its half. That split — not the agent logic — is the critical
path.

## Extraction roadmap

1. **`tools` core — DONE.** Registry + `Tool` interface + idempotency plumbing
   (zero db dependency). tendant's `internal/tools` re-exports it via aliases,
   so existing importers are unchanged; concrete `send-email` + seed stay
   app-side.
2. **db foundation.** Split the sqlc package + migrations into framework-owned
   (`agentkit/db`, in a dedicated **`agentkit` Postgres schema** with its own
   goose version table) and app-owned. Re-point importers. This is the wide,
   mechanical unlock for everything below. See
   [docs/schema-separation.md](docs/schema-separation.md) for the table
   partition and the dependency rule (no FK from `agentkit.*` → an app table).
3. **`gate` + `gatescript` + `overseer` + `calibration`.** The decision spine.
   Introduce a framework-owned `Tool` domain type to replace `db.Tool` in the
   `Gate.Evaluate` signature; relocate the WASM runner (with its embedded
   `asc.wasm`/`quickjs.wasm`) and the pure calibration helpers (`Band`,
   `Fingerprint`).
4. **`agent` runner + `lifecycle` + `chain` + `toolflow` + `durable`.** The
   autonomous loop and the DBOS workflows. Generalize the stage/state machine
   so the five tendant stages become configuration the framework reads, not a
   hardcoded enum.
5. **Reference example.** A minimal app wiring agentkit end-to-end, proving a
   new project gets the whole loop with little glue.

## Layout

```
agentkit/
├── go.mod
├── tools/            # action-edge registry (step 1 — done)
└── (db, gate, gatescript, overseer, calibration, agent, chain, … to follow)
```

In-repo module first (wired via the root `go.work`), with tendant as the live
consumer that validates every seam against its testcontainers + DBOS-recovery
suite. Extraction to a standalone repo is a cheap `git filter-repo` once the
boundary is proven.
