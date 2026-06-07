# Feature Specification: The Intake Edge (Connectors & Dispositions)

**Feature Branch**: `008-intake-edge-connectors`
**Created**: 2026-06-07
**Status**: Draft
**Input**: Phase 7 — The Intake Edge (Connectors & Dispositions) (v2 arch §9, §11.4, §14.1, App. A/D, §16)

## Overview

Phase 7 turns a tracker the owner feeds by hand into one that fills itself. It rests on
four load-bearing claims, each inherited from the spine built in Phases 0–6:

1. **The intake edge is trusted Go + config — not untrusted code.** Core ships a fixed base
   set of trusted connectors (Gmail, Calendar, IMAP, webhook-in, RSS). An *integration* is a
   `connector_config` row binding one connector to credentials + a coarse filter + a schedule
   + disposition rules. Unlike gate scripts, **there is no untrusted code on this edge** —
   containment is the config allowlist plus the universal gate. The core never grows to
   accommodate a new source; a new source is a connector behind the same versioned signal
   contract.

2. **The disposition is the privacy/cost firewall, placed where the most context lives.**
   Triage is an LLM stage (real since Phase 6), and inference may go to an external model — so
   "judge every raw item" would mean shipping the owner's whole inbox out and paying per item.
   The connector therefore chooses, **per emission**, how to surface an item:
   `forced_task` (this *is* a task — no model), `rich_event{confidence, stakes_hint}` (a
   structured candidate the core's autonomy dial resolves — no model), or `llm_judge` (I
   can't decide — hand the raw payload to triage's LLM). The raw payload only leaves the box
   when a connector genuinely cannot decide.

3. **Stage 2 *is* triage — there is no separate intake-gate component.** A connector emits a
   signal → it becomes a `PROPOSED` (or auto-accepted) record (the existing **creation**
   stage) → the existing **triage** stage does is-task / shape / stakes / routing. The v1
   "two-stage intake" collapses into "one connector + the existing chain."

4. **Auto-accept is an emergent rung, not a new stored type.** A high-confidence **and**
   low-stakes `rich_event` auto-accepts as a *dismissible enrich-only* task, so it arrives
   already-enriched via the expansion stage. "enrich-only" is a derived posture (consistent
   with the Phase 6 emergent-autonomy stance), not a column.

**Self-hosted defaults are first-class.** OAuth tokens are encrypted at rest in Postgres; the
owner does the OAuth dance once per source; the connector manages its own refresh. **Polling
is the default trigger** — a box behind NAT cannot receive webhooks, so each enabled connector
runs as a DBOS scheduled workflow. Durability plus the idempotency key means killing the box
mid-poll resumes without double-emitting.

## Clarifications

### Session 2026-06-07

- Q: What exactly makes a `rich_event` auto-accept versus hold `PROPOSED`? →
  A: **Both axes must clear owner-configured thresholds.** Auto-accept requires
  `confidence ≥ confidence_floor` **AND** `stakes_hint ≤ stakes_ceiling`, both drawn from the
  connector_config's `disposition_rules`. Failing *either* axis holds the record `PROPOSED`
  for owner sign-off (the connector may instead have routed it to `llm_judge` upstream). Floors
  default conservatively (high confidence required, low stakes required) so the secure default
  is "hold for sign-off."
- Q: The idempotency key kills self-duplication — scoped to what? →
  A: **`UNIQUE(connector_id, idempotency_key)`.** The key is unique per integration, not
  globally. The same underlying item seen by two different connectors (email + calendar invite)
  is cross-source duplication, explicitly **deferred to Phase 10**. A re-emission with a
  key already present for that connector is a no-op (no new signal row, no new task).
- Q: How much of the raw payload does `llm_judge` ship to the external model? →
  A: **Whatever the connector chose to put in the normalized `payload`, nothing more.** The
  connector is the firewall: it decides what a `llm_judge` emission carries. The spec requires
  connectors to be conservative (the privacy risk concentrates here), but the boundary is the
  connector's normalization, not a separate redaction stage (deferred refinement, Phase 10
  source-scoping).
- Q: Are `setConnectorConfig` / `enableConnector` owner-only like the Phase 4/5 owner
  mutations? → A: **Yes — structurally guarded by `auth.RequireOwner(ctx)`** (Principal.Kind
  == "user") before any DB write, same discipline as `setToolPermissions`.
- Q: What is the numeric scale of `confidence` and `stakes_hint`? → A: **Both are floats in
  `0.0–1.0`** (confidence: 0 = no confidence it is a task, 1 = certain; stakes_hint: 0 = no
  stakes, 1 = maximal stakes). "Out of range" means outside `[0.0, 1.0]`. Thresholds
  (`confidence_floor`, `stakes_ceiling`) are expressed on the same scale.
- Q: Does provenance store a reference to the source item or a snapshot copy of its content? →
  A: **Reference only** — a source-stable identifier (e.g., message/event ID) plus the
  human-readable flag reason. No copy of raw source content is stored as provenance; the
  operator edge re-fetches detail on demand via the connector. This keeps the privacy firewall
  tight (no inbox content at rest beyond what a connector normalized into `payload`).
- Q: What is the default poll cadence for a connector? → A: **Per-integration — there is no
  framework-wide default cadence.** Each connector_config's `schedule` determines its own poll
  interval; the cadence is an integration-level setting the owner tunes per config, not a
  global constant the core imposes.
- Q: Is there a bound on how many `llm_judge` emissions a single poll can send to the model? →
  A: **Yes — a per-poll cap on `llm_judge` emissions** (configurable, conservative default).
  Once the cap is reached, remaining `llm_judge` items for that poll fail closed: they are held
  `PROPOSED` without invoking the model. Mirrors the Phase 4 per-task overseer cap discipline
  and bounds the cost/privacy lever by construction.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A flagged email becomes a task with no typing (Priority: P1)

The owner connects their Gmail account once (the OAuth dance). From then on, an email that a
connector flags `forced_task` becomes a task directly — the record is created, the chain runs,
and it appears on the operator edge carrying its provenance (which message, why it was flagged).
The owner typed nothing.

**Why this priority**: This is the headline capability — "tasks find you." Without it, the
phase delivers nothing observable. It exercises the full path: credential → poll → connector →
signal → creation → operator edge.

**Independent Test**: With a Gmail integration enabled and a connector rule that flags a known
message `forced_task`, run the connector's scheduled poll and confirm exactly one task is
created, its provenance points at the source message, and it surfaces on the inbox.

**Acceptance Scenarios**:

1. **Given** an enabled Gmail connector_config and an inbox message matching the connector's
   `forced_task` rule, **When** the scheduled poll runs, **Then** one task is created in the
   creation stage and carries provenance (raw ref + why flagged).
2. **Given** that task, **When** the owner opens it on the operator edge, **Then** the
   provenance (source message reference and flag reason) is visible.
3. **Given** a `forced_task` emission, **When** it is processed, **Then** the is-task judgment
   is skipped (no model invoked for that decision).

---

### User Story 2 - A confident, low-stakes event arrives already-enriched (Priority: P1)

A connector emits a `rich_event` with high self-assessed confidence that it is a task and a low
stakes hint (e.g., a calendar event the owner clearly needs to prepare for). The intake-autonomy
dial sees both thresholds cleared and **auto-accepts** it as a *dismissible enrich-only* task.
It runs through expansion, so when the owner sees it, it is already enriched — and it is freely
dismissible because it was never explicitly approved.

**Why this priority**: This is the "no sign-off for the obvious" half of the value. It proves
the dial keys on *both* axes and that auto-accept produces an emergent enrich-only posture, not
a stored type.

**Independent Test**: Emit a `rich_event` with confidence above the floor and stakes below the
ceiling; confirm the task auto-accepts, is enrich-only/dismissible, and has run expansion before
the owner sees it.

**Acceptance Scenarios**:

1. **Given** a `rich_event` with `confidence ≥ floor` AND `stakes_hint ≤ ceiling`, **When** the
   dial resolves it, **Then** the task auto-accepts (not held `PROPOSED`) as a dismissible
   enrich-only task.
2. **Given** that auto-accepted task, **When** the owner views it, **Then** it has already
   passed the expansion stage (arrives enriched).
3. **Given** a `rich_event` that clears confidence but **not** stakes (or vice-versa), **When**
   the dial resolves it, **Then** it is held `PROPOSED` for owner sign-off rather than
   auto-accepted.

---

### User Story 3 - An ambiguous item is judged by the LLM, then held for sign-off (Priority: P1)

A connector cannot decide whether an item is a task. It emits `llm_judge`, handing the
normalized payload to the triage stage's LLM for the is-task / shape / stakes call. The item
lands `PROPOSED` for the owner, with its provenance, and the model was invoked only because the
connector genuinely could not decide.

**Why this priority**: This proves the firewall's escape hatch works and is the exception path,
not the default — the cost/privacy lever the whole disposition model exists to control.

**Independent Test**: Emit an `llm_judge` signal; confirm the triage LLM is invoked exactly
once for the is-task judgment, the result lands `PROPOSED`, and `forced_task`/`rich_event`
emissions in the same run did **not** invoke the model.

**Acceptance Scenarios**:

1. **Given** an `llm_judge` emission, **When** triage runs, **Then** the LLM is invoked for the
   is-task / shape / stakes judgment and the result lands `PROPOSED`.
2. **Given** a mixed batch of `forced_task`, `rich_event`, and `llm_judge` emissions, **When**
   the poll completes, **Then** the model is invoked only for the `llm_judge` items.
3. **Given** an `llm_judge` emission, **When** it is shipped to the model, **Then** only the
   connector-normalized `payload` is sent (no broader source content).

---

### User Story 4 - The same item twice produces one task (Priority: P1)

An item the connector already emitted appears again on a later poll (a re-sent email, an
unchanged calendar entry, a duplicate webhook delivery). Because every emission carries an
idempotency key unique per connector, the second arrival is a no-op: no second signal row, no
second task.

**Why this priority**: Self-duplication would make a self-filling tracker unusable within a
day. Idempotency is the property that makes polling safe to repeat.

**Independent Test**: Emit the same item (same `connector_id` + `idempotency_key`) twice across
two polls; confirm exactly one signal row and one task exist.

**Acceptance Scenarios**:

1. **Given** an emission with idempotency key K from connector C, **When** a later poll emits
   the same K from C, **Then** no new signal row and no new task are created.
2. **Given** the second arrival, **When** it is processed, **Then** the system records it as a
   duplicate (observably a no-op) without error.

---

### User Story 5 - Killing the box mid-poll resumes cleanly (Priority: P2)

The self-hosted box is killed (`kill -9`) while a connector's scheduled poll is mid-flight.
On restart, the DBOS scheduled workflow resumes; combined with the idempotency key, the
interrupted poll completes without emitting any item twice.

**Why this priority**: Self-hosted durability is a core promise. It is P2 only because it
builds on US1/US4 already working; without those, there is nothing to resume.

**Independent Test**: Start a poll that emits several items, kill the process partway, restart,
and confirm the resumed workflow yields the same total set of tasks as an uninterrupted run
(no duplicates, no drops).

**Acceptance Scenarios**:

1. **Given** a scheduled connector poll mid-emission, **When** the process is killed and
   restarted, **Then** the workflow resumes and completes.
2. **Given** the resumed poll, **When** it finishes, **Then** each source item produced exactly
   one task (idempotency held across the restart).

---

### User Story 6 - The owner configures and toggles a connector (Priority: P2)

The owner sets a connector's config (filter, schedule, disposition rules, thresholds) and
enables or disables it. These are owner-only operations — no non-owner principal can change an
integration's behavior or read which sources are connected.

**Why this priority**: The integration is meaningless without owner control over it, but it is
P2 because a seeded/default config can demonstrate US1–US3 before the mutations exist.

**Independent Test**: As the owner, set a connector_config and toggle enabled; confirm the
change persists and a non-owner principal is refused both the mutation and the connector listing.

**Acceptance Scenarios**:

1. **Given** the owner principal, **When** they call `setConnectorConfig`, **Then** the config
   persists and takes effect on the next scheduled poll.
2. **Given** the owner principal, **When** they call `enableConnector(enabled: false)`, **Then**
   the connector's scheduled poll stops emitting.
3. **Given** a non-owner principal, **When** they attempt either mutation or the `connectors`
   query, **Then** the request is refused before any DB write or read of integration state.

---

### Edge Cases

- **Expired / revoked credentials**: When a source's OAuth token cannot be refreshed, the
  connector must fail its poll without crashing the box, surface the credential problem to the
  owner, and not emit partial/garbage signals.
- **Disabled mid-flight**: A connector disabled while a poll is in-flight must not start new
  emissions; in-flight idempotent emissions are harmless if completed.
- **Malformed disposition / missing fields**: A `rich_event` missing `confidence` or
  `stakes_hint`, or an unknown disposition string, must be rejected (fail-closed: treat as
  needing sign-off, never as auto-accept).
- **Confidence/stakes out of range**: Values outside `[0.0, 1.0]` must be rejected (fail-closed
  to hold-for-sign-off), never silently treated as clearing a threshold.
- **Filter matches nothing**: A poll that matches no items is a successful no-op, not an error.
- **Webhook connector on a NAT box**: A webhook-triggered connector configured where the box
  has no real ingress must degrade gracefully (documented as unsupported in that topology;
  polling is the default).
- **Dismissed auto-accepted task**: Dismissing an auto-accepted enrich-only task records the
  reason (the Phase 2 `dismissProposedTask` path) so Phase 8 can read it as calibration signal.
- **Idempotency-key collision across genuinely different items**: A connector that reuses a key
  for distinct items would suppress real tasks; the contract requires the key derive from a
  stable source identity so distinct items get distinct keys.

## Requirements *(mandatory)*

### Functional Requirements

#### The intake-signal contract

- **FR-001**: The system MUST define a versioned `PotentialTaskSignal` contract carrying at
  minimum: signal version, source identity, an idempotency key, provenance (raw reference + why
  flagged), a normalized payload, a disposition, and — for `rich_event` — a confidence and a
  stakes hint.
- **FR-002**: The signal contract MUST be treated as one of the long-lived versioned contracts
  and MUST follow the hybrid additive-+-deprecation versioning policy; any change MUST pick a
  policy path (1/2/3).
- **FR-003**: The system MUST persist every accepted emission as an intake-signal record
  capturing its version, idempotency key, provenance, payload, disposition, and (where present)
  confidence and stakes hint.
- **FR-004**: The system MUST enforce idempotency scoped to `(connector, idempotency_key)`: a
  re-emission of an already-seen key for the same connector MUST NOT create a second signal
  record or a second task.

#### Connectors & integrations

- **FR-005**: The system MUST ship a fixed base set of trusted connectors — Gmail, Calendar,
  IMAP, webhook-in, and RSS — implemented as core Go code behind a single connector interface.
- **FR-006**: An integration MUST be expressed as a connector_config binding one connector to
  credentials, a coarse filter, a schedule, and disposition rules — adding an integration is
  data, not a deploy.
- **FR-007**: Each enabled connector MUST run on a polling trigger by default, implemented as a
  durable scheduled workflow (one per enabled connector), surviving process restart without
  double-emitting. The poll cadence MUST be driven by the connector_config's `schedule` (an
  integration-level setting); the core MUST NOT impose a single framework-wide default cadence.
- **FR-008**: The connector interface MUST expose only the configured behavior to the rest of
  the core; the core MUST NOT grow source-specific logic — a new source is a new connector
  behind the same contract.

#### Disposition handling & the intake-autonomy dial

- **FR-009**: For a `forced_task` emission, the system MUST create the task record directly and
  MUST skip the is-task judgment (no model invoked for that decision).
- **FR-010**: For a `rich_event` emission, the system MUST apply the intake-autonomy dial keyed
  on **both** confidence and stakes: auto-accept only when `confidence ≥ confidence_floor`
  **AND** `stakes_hint ≤ stakes_ceiling`, with thresholds drawn from the connector_config's
  disposition rules. `confidence`, `stakes_hint`, and both thresholds are floats on the
  `0.0–1.0` scale.
- **FR-011**: An auto-accepted `rich_event` MUST become a dismissible enrich-only task that
  passes through the expansion stage before the owner sees it (arrives already-enriched).
  "enrich-only" MUST be a derived posture, not a stored task type.
- **FR-012**: A `rich_event` that fails **either** threshold MUST be held `PROPOSED` for owner
  sign-off (never auto-accepted on a single axis).
- **FR-013**: For an `llm_judge` emission, the system MUST hand the connector-normalized payload
  — and only that payload — to the triage stage's LLM for the is-task / shape / stakes judgment,
  and the result MUST land `PROPOSED`.
- **FR-014**: The system MUST invoke the triage model only for `llm_judge` emissions;
  `forced_task` and `rich_event` emissions MUST NOT incur model cost for the is-task decision.
- **FR-014a**: The system MUST enforce a per-poll cap on `llm_judge` emissions (configurable,
  conservative default). Once the cap is reached, remaining `llm_judge` items for that poll MUST
  fail closed — held `PROPOSED` without invoking the model — so a single poll cannot ship an
  unbounded backlog to the external model.
- **FR-015**: Disposition handling MUST fail closed: an unknown disposition, a `rich_event`
  missing confidence or stakes, or out-of-range axis values MUST result in holding for sign-off
  (or rejection), never in auto-accept.

#### Provenance, chain integration & calibration

- **FR-016**: Every created task (forced, auto-accepted, or accepted-from-PROPOSED) MUST carry
  provenance — a source-stable reference to the raw item (not a stored copy of its content) and
  the reason it was flagged — viewable on the operator edge, with raw detail re-fetched on
  demand via the connector.
- **FR-017**: An emitted signal MUST enter the existing chain at the creation stage and be
  triaged by the existing triage stage; the phase MUST NOT introduce a separate intake-gate
  component.
- **FR-018**: Accepting a `PROPOSED` intake task MUST run the chain; dismissing it MUST record
  the dismissal reason via the existing Phase 2 dismissal path (so Phase 8 can consume it as
  calibration signal).

#### Credentials & owner control

- **FR-019**: OAuth (and equivalent) credentials MUST be stored encrypted at rest, with an
  expiry, and the connector MUST manage its own refresh; the owner performs the OAuth dance once
  per source.
- **FR-020**: The system MUST expose owner-only mutations `setConnectorConfig` and
  `enableConnector`, and an owner-scoped `connectors` query, each structurally guarded by the
  owner-only check before any DB write or read of integration state.
- **FR-021**: A disabled connector MUST NOT emit signals; toggling enabled MUST take effect for
  subsequent scheduled polls.

### Non-Functional Requirements

- **NFR-001 (privacy firewall)**: Raw source content MUST leave the box (to an external model)
  only via an `llm_judge` emission's normalized payload. No path may ship `forced_task` or
  `rich_event` payloads to a model for the is-task decision.
- **NFR-002 (durability)**: A connector poll MUST be crash-safe: an interrupted poll resumed
  after restart MUST produce the same set of tasks as an uninterrupted run (no duplicates via
  idempotency, no silent drops).
- **NFR-003 (secure default)**: Disposition thresholds MUST default conservatively so that, in
  the absence of explicit owner tuning, the default outcome for an ambiguous `rich_event` is
  "hold for sign-off," not auto-accept.
- **NFR-004 (containment)**: The intake edge MUST rely on config-allowlist + universal-gate
  containment only; it MUST NOT introduce an untrusted-code execution surface.
- **NFR-005 (reuse reserved schema)**: The phase MUST reuse the Phase 0 `connector_configs`,
  `source_credentials`, and `intake_signals` schema; any new migration MUST be justified against
  that reserved schema.

### Key Entities

- **PotentialTaskSignal**: The versioned in-edge contract — one normalized emission from a
  connector. Carries version, source identity, idempotency key, provenance, payload,
  disposition, and (for `rich_event`) confidence + stakes hint. Persisted as an intake-signal
  record.
- **Connector**: A trusted Go implementation of one source type (Gmail, Calendar, IMAP,
  webhook-in, RSS) behind a single `Run(ctx, config, emit)` interface. Code, fixed base set.
- **ConnectorConfig (integration)**: A row binding one connector to credentials + a coarse
  filter + a schedule + disposition rules (including the confidence floor and stakes ceiling).
  The unit the owner creates/edits; enabling it schedules a polling workflow.
- **SourceCredentials**: Encrypted-at-rest OAuth/equivalent tokens for one source, with expiry;
  refresh is connector-managed.
- **IntakeSignal record**: The persisted emission, unique per `(connector, idempotency_key)`,
  feeding the creation stage.
- **Provenance**: A source-stable reference (which message/event/item — an ID, not a content
  copy) plus the reason the connector flagged it; surfaced on the operator edge, with raw detail
  re-fetched on demand.
- **Disposition**: The per-emission firewall selector — `forced_task`, `rich_event`, or
  `llm_judge`.

## Out of Scope (deferred)

- **Cross-integration dedup** (email + calendar invite collapsing to one task) — the idempotency
  key kills *self*-duplication only; cross-source linking is Phase 10.
- **Intake privacy / source scoping** (a `none` rung over *sources* a connector may not read) —
  Phase 10.
- **Webhook ingress / relay for NAT boxes** — polling is the v1 default; webhook connectors only
  where the box has real ingress. Relay is Phase 10.
- **Community connectors (open registration)** — core ships the fixed base set and freezes the
  contract now; open registration is Phase 10. A community contribution is an in-tree, reviewed,
  trusted connector or a shared config.
- **Phase 8 calibration consumption** — this phase only *records* dismissal reasons; reading
  them as the intake half of the calibration loop is Phase 8.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With a Gmail integration connected once, an email flagged `forced_task` becomes
  exactly one task that surfaces on the operator edge with its provenance — and the owner typed
  nothing.
- **SC-002**: A `rich_event` clearing both the confidence floor and the stakes ceiling
  auto-accepts as a dismissible enrich-only task and has completed expansion before the owner
  views it; one that clears only one axis is held `PROPOSED`.
- **SC-003**: An `llm_judge` emission invokes the triage model exactly once and lands `PROPOSED`;
  in a mixed batch, no `forced_task` or `rich_event` emission invokes the model.
- **SC-004**: The same source item arriving twice (same connector + idempotency key) yields
  exactly one signal record and one task.
- **SC-005**: A connector poll killed mid-flight and restarted produces the same set of tasks as
  an uninterrupted run — zero duplicates, zero drops.
- **SC-006**: A `PROPOSED` intake task displays its provenance (raw ref + flag reason) on the
  operator edge; accepting it runs the chain; dismissing it records the reason.
- **SC-007**: `setConnectorConfig`, `enableConnector`, and the `connectors` query are refused
  for any non-owner principal before any DB write or read of integration state.
- **SC-008**: With no explicit threshold tuning, an ambiguous `rich_event` defaults to
  "hold for sign-off," never auto-accept.
- **SC-009**: A single poll producing more `llm_judge` items than the configured per-poll cap
  invokes the model at most cap times; every item beyond the cap is held `PROPOSED` with no
  model call.

## Assumptions

- The Phase 6 triage stage is a real agent and is the LLM that `llm_judge` emissions are handed
  to; no new triage component is introduced here.
- The Phase 0 `connector_configs`, `source_credentials`, and `intake_signals` tables exist with
  the columns restated in the brief; this phase fills them rather than redesigning the schema.
- The Phase 0/7 credentials-at-rest seam (`internal/crypto` AES-256-GCM, `TENDANT_CREDENTIALS_KEY`)
  is the mechanism for encrypting `source_credentials`.
- The owner is the single `user` principal; `auth.RequireOwner(ctx)` (Phase 4) is the guard for
  all connector mutations and the `connectors` query.
- Provenance display reuses the existing operator-edge inbox/detail surface (Phases 2–6) rather
  than a new client surface, beyond what is needed to render the raw ref + flag reason.
- The deployment topology is a self-hosted box, frequently behind NAT, which is why polling
  (durable scheduled workflows) is the default trigger and webhook connectors are conditional on
  real ingress.
- "Coarse filter" in a connector_config is a connector-side pre-filter to bound what is read and
  emitted; it is not a privacy guarantee (source-scoping is deferred to Phase 10).
