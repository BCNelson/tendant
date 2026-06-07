# Phase 0 Research: The Intake Edge (Connectors & Dispositions)

All decisions below resolve unknowns surfaced in Technical Context. No `NEEDS CLARIFICATION`
markers remain. Each entry: **Decision / Rationale / Alternatives considered**.

---

## R1 — Polling trigger: DBOS dynamic schedules

**Decision**: Use DBOS Go's **dynamic schedule API** — `CreateSchedule(ctx, fn ScheduledWorkflowFunc,
CreateScheduleRequest{ScheduleName, Schedule})` with `DeleteSchedule`/`PauseSchedule`/`ResumeSchedule`
by name (`workflow.go:4195/4452/4496/4525`, `scheduler.go`). One schedule per enabled connector:
`ScheduleName = "intake:<connectorID>"`, `Schedule = connector_config.schedule` (cron),
`WithScheduleContext(connectorID)`. The scheduled fn signature is
`func(ctx DBOSContext, input ScheduledWorkflowInput) (any, error)` where `input.Context` carries the
connector id and `input.ScheduledTime` is the tick.

**Rationale**: Schedules are **DB-backed and recovered on `dbos.Launch`** — exactly the crash-safety
SC-005/exit-criterion-4 demands, with no bespoke scheduler. Cron parsing is `robfig/cron/v3`
(`cron.WithSeconds()`), **already a transitive dependency via DBOS** — zero new deps. Dynamic (not
static `WithSchedule`) is required because connectors are created/toggled at runtime via owner
mutations, not known at registration time.

**Alternatives considered**:
- *Static `RegisterWorkflow(..., WithSchedule(cron))`* — rejected: cron is fixed at compile time;
  can't bind per-connector configs created later.
- *A single DBOS workflow looping with `dbos.Sleep`* — rejected: one giant poll loop couples all
  connectors' cadences and complicates per-connector enable/disable; the schedule API models this
  natively.
- *External cron / systemd timer* — rejected: violates "DBOS is the execution engine" and loses
  durability + recovery.

---

## R2 — Source clients without new dependencies

**Decision**: Reach external sources via the **standard library**, following the Phase-4 overseer
precedent (Anthropic/OpenAI hand-rolled over `net/http`, "no new SDK dep"):
- **Gmail / Calendar**: REST over `net/http`; OAuth token refresh = a POST to the provider token
  endpoint over `net/http` (no `golang.org/x/oauth2`, no `google.golang.org/api`).
- **RSS**: `encoding/xml`.
- **Email parsing**: `net/mail`.
- **webhook-in**: a chi route → `net/http` handler.

**Rationale**: The constitution forbids new dependencies without prior approval and prefers the
stdlib + adopted stack. Every source on the base set except IMAP is reachable with stdlib alone.

**Alternatives considered**:
- *`google.golang.org/api` + `golang.org/x/oauth2`* — rejected this phase: new deps requiring
  approval; the overseer already proved stdlib `net/http` is sufficient for token + REST flows.
- *A third-party RSS/atom library* — rejected: `encoding/xml` parses both with a small struct.

**Acknowledged deferral**: **IMAP has no stdlib client.** A full IMAP connector needs a library
(e.g., `github.com/emersion/go-imap`), which is a **new dependency requiring owner approval**. This
phase registers `imap` as a connector type with a **stub provider** (logs intent, emits nothing),
and flags the dep for a future phase. Gmail (the OAuth exemplar) covers the "real mailbox" demo path.

---

## R3 — Two-tier connector base set (what's real vs. stub this phase)

**Decision**: Ship all five connector *types* registered, in two implementation tiers (the `internal/push`
APNs/FCM precedent — "stubs ready for real credentials"):

| Connector | Tier | Credentials | Tested |
|---|---|---|---|
| `webhook-in` | **Full** | none | E2E (ingress route → signal → task) |
| `rss` | **Full** | none | E2E (fixture feed → signal → task) |
| `gmail` | **Full (OAuth exemplar)** | OAuth (sealed) | unit + E2E with faked `messageFetcher` |
| `calendar` | **Stub** | OAuth (seam ready) | unit (stub emits nothing) |
| `imap` | **Stub** | password (seam ready) | unit (stub emits nothing) |

**Rationale**: The whole edge — contract, disposition dial, idempotency, scheduling, auto-accept,
provenance, owner mutations — is provable end-to-end in CI with the two zero-credential connectors,
with no external services. Gmail proves the OAuth + sealed-credential + refresh path. Calendar/IMAP
are completable later with **zero core changes** (the Principle-I promise made concrete). This bounds
scope to M–L while satisfying every spec exit criterion.

**Alternatives considered**:
- *Fully implement all five now* — rejected: IMAP needs a new dep; live Gmail/Calendar E2E needs real
  Google credentials in CI; scope balloons past M–L for no additional invariant coverage.

---

## R4 — "enrich-only" auto-accept lifecycle

**Decision**: An auto-accepted `rich_event` is created in state `accepted` with `intake_signal_id`
set, runs the chain through **triage + expansion** (arrives enriched), then the chain **routes
EXECUTION to the owner** (the existing human slot) instead of auto-executing. `Task.autonomy` is the
resolver-computed readout that reports **`enrich-only`** for such a task (no stored dial — the Phase-6
stance). "Dismissible" is honored by relaxing `lifecycle/edges.go` to permit `accepted → dismissed`
**for intake-origin tasks** (`intake_signal_id IS NOT NULL`); `dismissProposedTask(taskId, reason)`
then records the reason on the same calibration path Phase 8 will read.

**Rationale**: Satisfies all three US2 acceptance scenarios literally — not held `PROPOSED`, already
past expansion, freely dismissible — using existing mechanisms (chain routing, autonomy derivation,
dismissal-reason capture). It keeps auto-accept from granting *execution* autonomy (Principle IV): the
owner still authorizes the act. No new column, no new state.

**Alternatives considered**:
- *Keep it `PROPOSED` but pre-run expansion* — rejected: contradicts "not held PROPOSED" (US2-AC1) and
  fights the state machine (expansion advances `current_stage`).
- *Auto-execute through to completion* — rejected: violates Principle IV (a connector would be granting
  execution autonomy the owner never authored) and the spec's "dismissible because never explicitly
  approved."
- *A new `enrich_only` task state/column* — rejected: autonomy is emergent/derived by constitution and
  Phase-6 precedent; a stored rung is exactly what the invariant forbids.

---

## R5 — `llm_judge` semantics, evidence framing, and the per-poll cap

**Decision**: `llm_judge` (within the per-poll cap) creates a `PROPOSED` task carrying the
connector-normalized `payload` as a **labeled `[INTAKE_SIGNAL]` evidence** slot for the triage agent's
is-task / shape / stakes pass; the result stays `PROPOSED` for owner sign-off. Only the normalized
`payload` is sent (NFR-001). The per-poll cap (`disposition_rules.llm_judge_per_poll`, conservative
default 5) bounds model fan-out: overflow items are persisted + `PROPOSED` **without** a model call
(`llm_judge_capped` audit). If triage's is-task verdict is **false**, the signal is marked processed and
**no task surfaces** (recorded via audit); if **true/uncertain**, the `PROPOSED` task carries the
enriched shape/stakes.

**Rationale**: Keeps `llm_judge` the bounded exception (the cost/privacy lever), reuses the Phase-6
triage agent rather than a second judge, and preserves Principle IV by framing connector output as
evidence the agent weighs — never instruction. The cap mirrors the Phase-4 per-task overseer cap.

**Alternatives considered**:
- *A dedicated intake-judge agent* — rejected: the brief is explicit that Stage 2 **is** triage; a
  second component duplicates Phase 6.
- *No cap (rely on connector discipline)* — rejected at clarify: a misconfigured connector could ship a
  backlog out in one poll; the cap bounds the firewall by construction.
- *Surface a task even when is-task=false* — rejected: pollutes the inbox; the false verdict is still
  audited for calibration.

---

## R6 — Idempotency & crash-safety mechanism

**Decision**: Dedup at the single `intake_signals` insert:
`INSERT ... ON CONFLICT (connector_id, idempotency_key) DO NOTHING RETURNING id`. Empty return ⇒ already
seen ⇒ no task, `signal_deduped` audit. The poll workflow's per-item emit is a DBOS-memoized step, so a
restart re-runs only un-memoized steps and the unique index absorbs any duplicate that slips through.

**Rationale**: One dedupe point, backed by the Phase-0 `UNIQUE(connector_id, idempotency_key)` already in
the schema. DBOS memoization + the constraint together deliver SC-004 (twice ⇒ one) and SC-005 (kill mid
-poll ⇒ same set) with no extra bookkeeping table.

**Alternatives considered**:
- *Application-level "seen" cache* — rejected: not durable, defeats the point on restart.
- *Dedup in the connector* — rejected: the contract puts the idempotency key on the signal so the core
  enforces it uniformly across all connectors (Principle I).

---

## R7 — OAuth dance + credential sealing on a self-hosted box

**Decision**: Owner-initiated, once per source. A consent URL is produced for the connector; the provider
redirects to a `/oauth/callback/<connectorType>` chi route; the handler exchanges the code over
`net/http`, seals the token bundle (`access` + `refresh` + scopes) with `crypto.Seal`, and upserts
`source_credentials(connector_id, encrypted, expires_at)`. Refresh is connector-managed: when `expires_at`
is near, POST the refresh token to the provider token endpoint over `net/http`, re-seal, update the row.

**Rationale**: Uses the existing AES-256-GCM seam (`TENDANT_CREDENTIALS_KEY`) and stdlib HTTP — no new
deps. The box needs inbound reachability only for the one-time consent round-trip; steady-state polling is
outbound-only, so NAT is fine (consistent with "polling is the default trigger").

**Alternatives considered**:
- *Device-code / out-of-band paste flow* — viable fallback for a fully headless NAT box; noted as a future
  refinement, not required for the demo.
- *Storing tokens unsealed* — rejected outright (FR-019, privacy).

---

## R8 — Migration footprint (minimize churn)

**Decision**: **One migration, `00006_intake_audit_kinds.sql`**, that extends the Phase-5
`audit_messages.task_id`-NULL CHECK allowlist to admit the three **pre-task** intake audit kinds
(`signal_emitted`, `signal_deduped`, `llm_judge_capped`). Optionally add a partial index
`intake_signals(connector_id) WHERE processed_at IS NULL` to bound the poller's unprocessed scan.
**No other schema changes** — `connector_configs`, `source_credentials`, `intake_signals`,
`tasks.provenance`, `tasks.intake_signal_id`, and the `signal_disposition` enum are all Phase-0 reserved.

**Rationale**: Honors NFR-005 (reuse reserved schema) and the project's "ALTER, don't recreate" habit.
The CHECK extension is the *only* genuinely required DDL: without it, the constitution-VI audit writes for
pre-task events would violate the existing constraint.

**Alternatives considered**:
- *Log pre-task events to slog/metrics instead of `audit_messages`* — rejected: weakens the audit DAG
  (Principle VI) and the calibration signal; the CHECK extension is cheap and consistent with the Phase-5
  precedent that already carved out NULL-task owner-scoped kinds.
- *A new `intake_events` table* — rejected: duplicates the audit log; sub-resource events belong in
  `audit_messages` per Principle VIII.

---

## R9 — GraphQL surface & owner-guard pattern

**Decision**: Strictly additive (PR Path 1): `type Connector { id, connectorType, enabled, config: JSON }`,
`extend type Query { connectors: [Connector!]! }`, and `extend type Mutation { setConnectorConfig(...),
enableConnector(...) }`. All three resolvers call `auth.RequireOwner(ctx)` **first** (the Phase-4 pattern in
`phase4_helpers.go` — reject `Principal.Kind != "user"` with `PERMISSION_DENIED` before any DB read/write).
`config: JSON` carries `connector_type`, `filter`, `schedule`, `disposition_rules`, `enabled`. Provenance is
surfaced via the existing `Task.provenance: JSON` field (no schema change) plus a Flutter `ProvenanceCard`.

**Rationale**: Matches the established operator-edge versioning policy and the owner-only structural-guard
discipline used for `setToolPermissions` / gate-script mutations. Reusing `Task.provenance` means SC-006 needs
no contract change beyond rendering.

**Alternatives considered**:
- *Typed `Provenance`/`DispositionRules` GraphQL objects* — deferred: `JSON` keeps the surface additive and
  flexible while the rule shape settles; can be promoted to typed fields additively later.
- *Exposing `source_credentials` over GraphQL* — rejected: credentials never leave the box over the read
  surface; only connection *status* (enabled / has-credentials / expires_at) is safe to surface (future).
