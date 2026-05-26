<!--
SYNC IMPACT REPORT
Version change: (none) → 1.0.0   [initial ratification]
Modified principles: n/a (initial)
Added sections:
  - Core Principles (I–IX)
  - Technology Constraints
  - Development Workflow & Quality Gates
  - Governance
Removed sections: none
Source docs consolidated:
  - Extensibility & Expansion Review (Stories 1–5, CC-1, CC-2)  [adopted]
  - RFC: Programmable Tool-Gate Evaluators ("Gate Scripts")     [Draft/Proposed]
  - RFC: The Operator Edge — Flutter over GraphQL               [Draft/Proposed]
Note: Principles VII–IX and parts of Technology Constraints consolidate decisions
      from RFCs still in Draft status. If either RFC changes materially, re-version
      this file (MINOR for additive, MAJOR if a principle is redefined/removed).
Templates reviewed (consistency pass — all aligned, no edits required):
  ✅ .specify/templates/plan-template.md — "Constitution Check" is a generic gate
     placeholder ([Gates determined based on constitution file]); gates are derived
     per-feature at runtime, so no hardcoded principles drift. Aligns with Principle VII.
  ✅ .specify/templates/spec-template.md — already technology-agnostic (WHAT/WHY);
     Success Criteria already mandate technology-agnostic, measurable outcomes.
     Aligns with the Development Workflow WHAT/WHY-vs-HOW split.
  ✅ .specify/templates/tasks-template.md — generic task scaffold; no principle-specific
     task categories to add or remove.
  ✅ .specify/templates/constitution-template.md — source scaffold; unchanged.
Follow-up TODOs: none. RATIFICATION_DATE confirmed as 2026-05-25 (initial adoption).
-->

# Tendant Constitution

Tendant is a single-household personal task tracker and agent-orchestration system: a
small, stable core (task records, a three-layer gate, autonomy dials, an audit log,
orchestration) bracketed by pluggable edges. These principles are non-negotiable and
govern every specification, plan, and implementation. When a feature pressures the core
to grow, the default answer is "push it to an edge," not "extend the core."

## Core Principles

### I. Capability Grows at the Edges, Not the Core
The core MUST NOT be extended to accommodate a new data source or a new outward action.
New input sources MUST be added as intake pipelines that emit the normalized
potential-task signal; new outward actions MUST be added as MCP tools. A contributor
either writes an intake pipeline or an MCP tool — two documented edges, one stable middle.
*Rationale: this is the entire extensibility thesis (CC-2); a growing core is the failure
mode the whole architecture exists to prevent.*

### II. A Task Is Not a Workflow
A task MUST be a durable Postgres record that exists independently of any execution. A
DBOS workflow is execution *attached to* a task and MUST be instantiated only when an
agent picks the task up. Code MUST NOT fuse task identity with workflow identity;
`Task.workflow` is nullable until an agent attaches.
*Rationale: decoupling is what makes mid-life hand-off and federation possible — a task
outlives the instance executing it (Story 1).*

### III. The Hard-Rule Floor Is Immune
Categorical gating of spend and irreversible third-party effects MUST sit beneath all
per-tool tuning. No earned-autonomy promotion, no overseer verdict, no gate-script
`Approve`, and no offline-replayed decision MAY lower the floor. A floor-tripping call
MUST require explicit owner approval evaluated *at the moment of effect*, never replayed
from a stale queue.
*Rationale: trust buys up, never below the floor; safety is structural, not earned
(Stories 4 & 5).*

### IV. The Owner Authors Trust; Agents Never Self-Escalate
Tool permissions, overseer instructions, and autonomy promotions MUST originate from the
owner, never from the executor agent. Promotion MUST be owner-gated (agent proposes,
owner approves); demotion MUST be reflexive and automatic on a bad outcome or a
cancellation. Owner-authored rules and any agent- or script-supplied context MUST occupy
separate, labeled slots wherever the overseer is prompted — executor framing is evidence
the overseer weighs, never instruction it obeys.
*Rationale: self-escalation is the one move that breaks the trust model; the executor must
not be able to talk the judge into leniency (Story 5).*

### V. Cancel Halts; It Does Not Roll Back
Cancellation MUST stop forward progress and move the task to `HALTED`. Already-committed
effects MUST NOT be silently reversed, and tools MUST default to "treat as irreversible."
Compensation/undo is out of scope; if ever added, it MUST arrive as a versioned tool-
contract capability with existing tools defaulting to irreversible.
*Rationale: safety comes from the floor refusing to do the scary thing unreviewed, not from
undoing it afterward (Story 4).*

### VI. Every Decision Is Audited, and the Log Is Message-Shaped
Every gate verdict, state transition, and inter-agent message MUST be written to the audit
log; this write is non-negotiable. The audit schema MUST be a DAG of who-said-what-to-whom
(`from` / `to` / `inReplyTo`) from day one — not a linear sequence.
*Rationale: the audit log is the trust backbone and feeds the calibration loop; retrofitting
tree shape later is expensive (CC-1).*

### VII. Edge Contracts Are Versioned and Additive
The three edge contracts — the intake potential-task signal (in), the MCP tool contract +
gate-script ABI/manifest (out), and the GraphQL operator-edge schema (human) — MUST be
explicitly versioned. Evolution MUST be additive (a new manifest capability, a new union
member, a new optional field), never a silent break. Detailed schemas live in feature
specs and `contracts/`, NOT in this constitution.
*Rationale: third-party and alternative clients target these for years; contract stability
is a first-order concern (CC-2).*

### VIII. Federation-Shaped From Day One
Every persisted entity MUST carry a `globalUri`; every actor MUST be modeled as a
`Principal`. These MUST NOT be stripped because the system is currently single-household.
The sub-agent message protocol is the federation substrate: a local sub-agent and a remote
household MUST be the same shape on the wire.
*Rationale: cheap to keep now, expensive to retrofit (CC-1; operator-edge RFC §10).*

### IX. Untrusted Code Is the Default Assumption
Gate scripts and any executable extension MUST run sandboxed (WebAssembly), read-only,
bounded by an execution timeout and a memory cap, with no outbound network egress.
Capabilities MUST be deny-by-default and statically validated against a versioned manifest
*before* execution; the server-side compile from source is the artifact of record. External
signal needed in a decision MUST be routed through the trusted enrichment plane and read as
internal data — never fetched from inside the sandbox.
*Rationale: the design center is hostile third-party code; the sandbox plus floor supremacy
are the controls (Gate-Scripts RFC §§8, 13).*

## Technology Constraints

**Postgres only.** Postgres MUST be the single datastore AND the realtime transport
(`LISTEN`/`NOTIFY`). No message brokers, no secondary stores, no external cache as a source
of truth. Introducing any new persistence or transport infrastructure requires a
constitutional amendment.

**DBOS is the execution engine.** Durability MUST live in workflows and the gate, never in
read-only evaluators. The operator edge depends on exactly one thing from the engine: a
transition notify emitted on every state change and durable human-wait.

**Adopted stack.** Go (`gqlgen`, `chi`, `pgx`) serves the core and the GraphQL operator
edge; the client is a single Flutter codebase for mobile, desktop, and web; gate scripts
compile to WASM (AssemblyScript for the in-app path, Rust for bring-your-own). Generated
code (gqlgen, Ferry) is committed.

**Language policy.** New first-party code MUST be written in Go, Rust, or TypeScript
(including TypeScript-shaped AssemblyScript for gate scripts). Any other language requires
an amendment.

**No new dependencies without approval.** Adding a new third-party library, service, or
infrastructure component MUST be raised and approved *before* it lands. Prefer the standard
library and the already-adopted stack. Every new dependency MUST be justified against this
constitution in the relevant `plan.md`.

## Development Workflow & Quality Gates

- `spec.md` stays technology-agnostic (WHAT / WHY). All technical decisions live in
  `plan.md` (HOW). An agent MUST NOT leak implementation detail into a spec.
- Every plan MUST pass a constitutional check before tasks are generated. Any deviation
  MUST be documented with rationale and explicitly approved.
- Any change touching an edge contract (Principle VII) MUST state the version bump and
  confirm the change is additive.
- Any new dependency, datastore, transport, or language (Technology Constraints) MUST be
  flagged for approval in the plan; absent approval it is a blocking violation.
- Detailed contracts and schemas belong in feature specs / `contracts/`, not here.

## Governance

This constitution supersedes all other project documents (Vision, Decision Record,
Extensibility Review, and the RFCs) wherever they conflict. Amendments require a documented
rationale, owner approval, and a migration note. Versioning is semantic: **MAJOR** for
removing or redefining a principle in a backward-incompatible way, **MINOR** for adding a
principle or a materially new section, **PATCH** for clarifications and wording. All PRs and
reviews MUST verify compliance; complexity MUST be justified against these principles, and
unjustifiable complexity MUST be simplified or rejected.

**Version**: 1.0.0 | **Ratified**: 2026-05-25 | **Last Amended**: 2026-05-25
