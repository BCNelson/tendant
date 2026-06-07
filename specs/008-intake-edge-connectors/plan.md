# Implementation Plan: The Intake Edge (Connectors & Dispositions)

**Branch**: `008-intake-edge-connectors` | **Date**: 2026-06-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/008-intake-edge-connectors/spec.md`

## Summary

Phase 7 builds the **in-edge**: trusted Go connectors, steered by `connector_config` rows,
that poll external sources on a DBOS schedule and emit a versioned `PotentialTaskSignal` with a
per-emission **disposition** (`forced_task` / `rich_event` / `llm_judge`). The disposition is the
privacy/cost firewall — raw payloads only reach the triage LLM when a connector genuinely cannot
decide. Signals persist to the Phase-0-reserved `intake_signals` table (deduped by
`UNIQUE(connector_id, idempotency_key)`), become `tasks` (forced/auto-accepted) or `PROPOSED`
records, and ride the **existing** Phase 1–6 chain (creation → triage → …). The intake-autonomy
dial keys on both confidence and stakes: high-confidence **and** low-stakes `rich_event`s
auto-accept as dismissible **enrich-only** tasks (a derived posture, not a stored type); anything
else holds `PROPOSED`.

**Technical approach**: a new trusted `internal/connector` package (interface + registry, mirroring
the `internal/push` / `internal/tools` Provider seam) plus `internal/intake` (signal contract,
disposition router, idempotent persistence, scheduler glue). Polling uses DBOS **dynamic schedules**
(`CreateSchedule`/`DeleteSchedule`, DB-backed and crash-recovered) — one schedule per enabled
connector, cron from `connector_config.schedule`. Credentials seal through the existing
`internal/crypto` AES-256-GCM seam into `source_credentials`. The GraphQL operator edge gains an
additive `Connector` type, a `connectors` query, and two owner-only mutations
(`setConnectorConfig`, `enableConnector`), all guarded by `auth.RequireOwner`. **Zero new
dependencies** (stdlib `net/http`/`encoding/xml`/`net/mail`, per the Phase-4 no-SDK precedent;
`robfig/cron` is already transitive via DBOS). **One migration** (`00006`) — strictly to extend the
Phase-5 `audit_messages.task_id`-NULL CHECK allowlist for the pre-task intake audit kinds.

## Technical Context

**Language/Version**: Go 1.25 (toolchain auto-tracks)
**Primary Dependencies**: chi/v5, gqlgen v0.17.90, pgx/v5, dbos-transact-golang v0.15.0 — all
already adopted. **No new third-party libraries.** Gmail/Calendar reached via stdlib `net/http`
(REST + OAuth token refresh); RSS via `encoding/xml`; email via `net/mail`.
**Storage**: Postgres only. Tables `connector_configs`, `source_credentials`, `intake_signals`,
`tasks` — all reserved in Phase 0 migration `00001`. Realtime via the existing `LISTEN/NOTIFY`.
**Testing**: `go test -race` + testcontainers-go v0.39.0; connector live-call surfaces faked behind
the Provider seam so the suite is green with no external services / no credentials.
**Target Platform**: Linux self-hosted box, frequently behind NAT (⇒ polling is the default trigger;
webhook connectors only where the box has real ingress).
**Project Type**: Go workspace (`services/api` + `db`) + Flutter client (`apps/mobile`).
**Performance Goals**: Poll cadence is per-integration (`connector_config.schedule` cron); the core
imposes no framework-wide default. A poll is a durable DBOS workflow; idempotency makes re-runs free.
**Constraints**: Privacy firewall (NFR-001): raw source content leaves the box only via an
`llm_judge` normalized payload. Per-poll `llm_judge` cap (FR-014a). Fail-closed dial defaults
(NFR-003). Trusted-code-only edge — no sandbox (NFR-004).
**Scale/Scope**: Single household; a handful of enabled connectors; polls measured in items/minute.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after design (see Post-Design Re-Check).*

| Principle | Verdict | Notes |
|---|---|---|
| **I. Capability at the Edges** | ✅ PASS | This phase **is** the canonical in-edge. New sources are new `Connector` impls behind the fixed `PotentialTaskSignal` contract; the core (tasks, chain, gate) gains no source-specific logic. |
| **II. A Task Is Not a Workflow** | ✅ PASS | Signals create durable `tasks` rows first; the chain workflow attaches via the existing `core.AttachChainWorkflow`. `Task.workflow` stays nullable until attach. The *poll* is a separate scheduled workflow that does not own task identity. |
| **III. Hard-Rule Floor Is Immune** | ✅ PASS | Intake never touches the gate. `forced_task`/auto-accept skip only the **is-task** judgment, never the universal tool floor that governs any action a resulting task later takes during execution. |
| **IV. Owner Authors Trust; No Self-Escalation** | ✅ PASS | `setConnectorConfig`/`enableConnector` are owner-only (`auth.RequireOwner`). Auto-accept thresholds are owner-authored (`disposition_rules`). A connector cannot grant a task execution autonomy — auto-accept yields an *enrich-only* posture that still routes execution to the owner. The `llm_judge` payload enters triage as **labeled `[INTAKE_SIGNAL]` evidence**, never as owner instruction (mirrors the Phase-4/5 labeled-slots discipline). |
| **V. Cancel Halts; No Roll Back** | ✅ PASS | No new effects to reverse. Dismissing an intake task records a reason; it does not undo anything. |
| **VI. Every Decision Audited, Message-Shaped** | ✅ PASS (with migration) | Signal/disposition/auto-accept/llm-judge/cap events write `audit_messages` with `from`/`to`. Pre-task events (dedupe, cap) carry NULL `task_id`, which the Phase-5 CHECK restricts — hence migration `00006` extends the allowlist (justified below). |
| **VII. Edge Contracts Versioned & Additive** | ✅ PASS | `PotentialTaskSignal` is the intake contract — versioned `SignalVersion="intake.v1"` ([contracts/signal.v1.md](./contracts/signal.v1.md)). The GraphQL additions are strictly additive ([contracts/graphql.v1.graphqls](./contracts/graphql.v1.graphqls)). **PR template Path 1 (additive).** |
| **VIII. Federation-Shaped From Day One** | ✅ PASS | Tasks already carry `global_uri`; provenance references actors/sources by stable id. `connector_configs`/`source_credentials`/`intake_signals` are **local config + sub-resources**, not addressable top-level resources — post-1.2.0 narrowing means no own-row `globalUri` required. |
| **IX. Untrusted Code Is the Default** | ✅ PASS | Connectors are **trusted, reviewed, in-tree Go** — the brief's explicit non-sandbox edge. Containment is the config allowlist + the universal gate. No WASM, no untrusted execution surface introduced. External signal needed in a decision is read as internal data (the persisted signal), not fetched from inside any sandbox. |

**Technology Constraints**: Postgres-only ✅ (signals + schedules in PG; no broker). DBOS-is-engine
✅ (polling is a DBOS scheduled workflow; durability in the workflow + the unique index, not in any
read evaluator). **No new dependencies** ✅ — see [research.md](./research.md) R1/R2; the one
deferred item (a real IMAP client lacks a stdlib equivalent) is flagged for future dep-approval and
ships as a stub provider this phase.

**Gate result: PASS — no violations, no Complexity Tracking entries required.**

## Project Structure

### Documentation (this feature)

```text
specs/008-intake-edge-connectors/
├── plan.md              # This file
├── spec.md              # Feature spec (clarified)
├── research.md          # Phase 0 — decisions R1–R9
├── data-model.md        # Phase 1 — entities, dispositions, lifecycle
├── quickstart.md        # Phase 1 — demo walkthrough (maps to spec exit criteria)
├── contracts/
│   ├── signal.v1.md          # The PotentialTaskSignal in-edge contract (Principle VII)
│   └── graphql.v1.graphqls   # Additive operator-edge delta (Connector type + 1 query + 2 mutations)
└── checklists/
    └── requirements.md  # Spec quality checklist (from /speckit.specify)
```

### Source Code (repository root)

```text
services/api/
├── internal/
│   ├── connector/                 # NEW — trusted connector seam (mirrors internal/push)
│   │   ├── connector.go           #   Connector interface, ConnectorConfig, Registry
│   │   ├── registry.go            #   type→factory lookup; base-set registration
│   │   ├── webhook.go             #   webhook-in (zero-credential; fully implemented + E2E)
│   │   ├── rss.go                 #   RSS via encoding/xml (zero-credential; fully implemented + E2E)
│   │   ├── gmail.go               #   Gmail OAuth exemplar over net/http; live calls behind a fetcher seam
│   │   ├── calendar.go            #   Calendar — stub provider (LogProvider-style), completable w/o core change
│   │   ├── imap.go                #   IMAP — stub provider; real client deferred (needs dep approval)
│   │   └── *_test.go
│   ├── intake/                    # NEW — the in-edge core (trusted)
│   │   ├── signal.go              #   PotentialTaskSignal, Provenance, SignalVersion const
│   │   ├── disposition.go         #   dial: forced_task / rich_event (confidence×stakes) / llm_judge
│   │   ├── ingest.go              #   idempotent persist → task/PROPOSED creation → chain attach
│   │   ├── poll.go                #   the per-connector scheduled workflow body (durable steps)
│   │   ├── scheduler.go           #   CreateSchedule/DeleteSchedule glue keyed on connector id
│   │   ├── credentials.go         #   seal/open source_credentials via internal/crypto; refresh
│   │   └── *_test.go
│   ├── db/queries/
│   │   ├── connectors.sql         # NEW — connector_configs + source_credentials CRUD
│   │   └── intake_signals.sql     # NEW — idempotent insert (ON CONFLICT DO NOTHING), mark processed
│   ├── lifecycle/
│   │   ├── audit.go               # EDIT — add 6 intake audit kinds
│   │   └── edges.go               # EDIT — allow dismiss of intake auto-accepted (enrich-only) tasks
│   └── core/task.go               # EDIT — CreateTaskFromSignal (provenance + intake_signal_id)
├── graph/
│   ├── schema.graphqls            # EDIT — additive: Connector, connectors query, 2 owner mutations
│   ├── connector.resolvers.go     # NEW — resolvers (owner-guarded)
│   └── model/ (gqlgen-generated)  # regen via just generate
├── cmd/tendant/main.go            # EDIT — register intake scheduled-workflow + rehydrate schedules on boot
db/migrations/
└── 00006_intake_audit_kinds.sql   # NEW — extend audit_messages task_id-NULL CHECK allowlist

apps/mobile/                       # Flutter — additive
└── lib/.../intake/                # NEW — ProvenanceCard on task detail; (owner) Connectors settings list
```

**Structure Decision**: Two new trusted Go packages — `internal/connector` (the source adapters,
seam-shaped exactly like `internal/push`) and `internal/intake` (the contract + disposition router +
idempotent persistence + scheduler). This keeps the **adapter** concern (talk to Gmail) separate from
the **edge** concern (normalize, dispose, dedupe, hand to the chain), so a new source is one file in
`connector/` and zero changes to `intake/` — Principle I by construction. Everything else is edits to
existing packages (lifecycle, core, graph, main) plus one additive migration.

## Design Decisions

### D1: Connector seam mirrors `internal/push` (trusted, registry-dispatched)

`Connector` is `Type() string` + `Run(ctx, cfg ConnectorConfig, emit func(PotentialTaskSignal) error) error`
(verbatim from the spec's inline artifact). A `Registry` maps `connector_type` → factory, populated at
boot with the base set. The base set ships in **two tiers**, following the `push` APNs/FCM precedent
("stubs ready for real credentials"):
- **Fully implemented + E2E-tested, zero credentials**: `webhook-in` and `rss` (RSS via stdlib
  `encoding/xml`). These prove the entire edge in CI without external services.
- **OAuth exemplar**: `gmail` — token refresh + message list/get over stdlib `net/http`, with the live
  HTTP call behind a `messageFetcher` seam so tests inject a fake (mirrors how the Phase-4 overseer
  hand-rolled Anthropic/OpenAI over `net/http`).
- **Stub providers** (`LogProvider`-style): `calendar`, `imap` — registered connector types whose live
  fetch is a logged stub. Completable without core changes when credentials/real clients land. IMAP's
  lack of a stdlib client is the one future **dep-approval** flag (deferred this phase).

### D2: Polling = DBOS dynamic schedule, one per enabled connector

DBOS Go exposes `CreateSchedule(ctx, fn ScheduledWorkflowFunc, CreateScheduleRequest{ScheduleName, Schedule})`
with `DeleteSchedule`/`PauseSchedule` by name; schedules are **DB-backed and recovered on `Launch`**
(crash-safe by construction — SC-005). One schedule per enabled connector, `ScheduleName = "intake:<connectorID>"`,
cron = `connector_config.schedule`, `WithScheduleContext(connectorID)`. `enableConnector(true)` creates the
schedule; `enableConnector(false)` deletes it. On boot, `main.go` rehydrates a schedule for every enabled
connector. **No framework-wide default cadence** (clarification): enabling a connector with a null/blank
`schedule` is rejected. The scheduled fn body lives in `intake/poll.go` and is a durable workflow whose
steps (fetch page → for-each emit) are DBOS-memoized, so a `kill -9` mid-poll resumes without re-emitting.

### D3: The disposition router (the firewall)

`intake/disposition.go` is a pure function over a `PotentialTaskSignal` + the connector's
`disposition_rules`:
- `forced_task` → persist signal, `CreateTaskFromSignal(state=accepted)`, **skip is-task**, attach chain.
- `rich_event` → persist signal; apply the **dial**: auto-accept iff `confidence ≥ confidence_floor`
  **AND** `stakes_hint ≤ stakes_ceiling` (both floats `0.0–1.0`, thresholds from `disposition_rules`,
  conservative defaults). Auto-accept ⇒ enrich-only task (D5). Fail either axis ⇒ `PROPOSED`. Missing/out-of-range
  axis ⇒ **fail-closed to PROPOSED** (FR-015/NFR-003).
- `llm_judge` → subject to the per-poll cap (D6); within cap ⇒ create `PROPOSED` task carrying the
  normalized payload as `[INTAKE_SIGNAL]` evidence for triage's is-task/shape/stakes; over cap ⇒
  `PROPOSED` **without** invoking the model.

**No model is invoked** for `forced_task`/`rich_event` (FR-014). Only the normalized `payload` ever
reaches the model (NFR-001) — the connector chose what it contains.

### D4: Idempotency via the unique index + `ON CONFLICT DO NOTHING`

`intake_signals` already has `UNIQUE(connector_id, idempotency_key)`. The ingest insert is
`INSERT ... ON CONFLICT (connector_id, idempotency_key) DO NOTHING RETURNING id`; an empty return means
"already seen" → no task, write a `signal_deduped` audit, done (SC-004). This is the single dedupe point;
combined with DBOS memoized poll steps it gives the crash-safety in SC-005 with no extra bookkeeping.

### D5: "enrich-only" is a derived posture; dismiss reuses the Phase-2 calibration path

An auto-accepted `rich_event` is created `accepted` with `intake_signal_id` set, runs the chain through
**triage + expansion** (so it arrives enriched), then **routes EXECUTION to the owner** rather than
auto-executing — because it was never explicitly signed off. "enrich-only" is therefore the
resolver-computed `Task.autonomy` readout (consistent with Phase 6's no-stored-dial stance), not a column.
To honor "dismissible," `lifecycle/edges.go` is relaxed to permit `accepted → dismissed` **for intake-origin
tasks** (`intake_signal_id IS NOT NULL`), so the existing `dismissProposedTask(taskId, reason)` records the
reason via the same calibration path Phase 8 reads. No schema change (the `dismissed` state already exists).

### D6: Per-poll `llm_judge` cap (FR-014a)

The poll workflow counts `llm_judge` dispositions it has forwarded to the model this tick; once the
configured cap (`disposition_rules.llm_judge_per_poll`, conservative default e.g. 5) is reached, remaining
`llm_judge` items fail closed — persisted + `PROPOSED` + a `llm_judge_capped` audit, **no model call**
(SC-009). This mirrors the Phase-4 per-task overseer cap discipline; the cap lives in config, no new column.

### D7: OAuth dance + sealed credentials (the deferred-from-clarify item)

Owner-initiated, once per source: a `connectorAuthUrl(connectorId)`-style flow returns the provider
consent URL; the provider redirects to a `/oauth/callback/<connectorType>` chi route on the operator edge;
the handler exchanges the code over stdlib `net/http`, seals the token bundle with `crypto.Seal`, and
upserts `source_credentials(connector_id, encrypted, expires_at)`. The connector refreshes on demand
(token-endpoint POST over `net/http`) when `expires_at` is near, re-sealing. On a self-hosted/NAT box the
callback requires the box reachable for the consent round-trip only; steady-state polling needs no ingress.
*(Detailed redirect/callback wiring is implementation detail captured here, not a spec requirement.)*

### D8: Audit kinds + the one migration

Six intake audit kinds: `signal_emitted`, `signal_deduped`, `disposition_applied`, `intake_auto_accepted`,
`llm_judge_invoked`, `llm_judge_capped`. Task-scoped ones (`disposition_applied`, `intake_auto_accepted`,
`llm_judge_invoked`) carry `task_id`; pre-task ones (`signal_emitted`, `signal_deduped`, `llm_judge_capped`)
carry NULL `task_id`. Phase 5's CHECK admits NULL only for four owner-scoped kinds, so **migration `00006`**
extends that allowlist with the three pre-task intake kinds. This is the *only* migration — every other piece
of state rides Phase-0-reserved columns and `audit_messages.payload jsonb`.

## Complexity Tracking

> No constitutional violations. No entries required.

## Post-Design Constitution Re-Check

Re-evaluated after Phase 1 design — **still PASS on all nine principles**. The design adds no new
dependency, no new datastore/transport, no untrusted-code surface, and keeps the core source-agnostic
(a new connector is one file in `internal/connector`). The single migration is additive and justified
(extends a CHECK allowlist; no table/column/enum redefinition). Edge-contract changes are additive
(Path 1): `intake.v1` signal contract introduced, GraphQL operator edge extended with one type, one query,
two owner-only mutations. The one acknowledged deferral (real IMAP client → future dep approval) ships as a
stub and changes nothing in the core when later filled.
