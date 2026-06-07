# Feature Specification: Calibration & the Earned-Autonomy Ratchet

**Feature Branch**: `009-calibration-autonomy-ratchet`
**Created**: 2026-06-07
**Status**: Draft
**Input**: Phase 8 — Calibration & the Earned-Autonomy Ratchet (v2 arch §7.4–§7.6, §11.2, §11.4, §14.4, App. A/D, §16)

## Overview

Phase 8 closes the trust loop. Every prior phase made the system act and recorded *what it did*
into the audit DAG; this phase reads that record back and lets it move a dial. A single
**calibration subsystem** reads the audit DAG on **both** edges — execution outcomes (did a
tool's action turn out clean?) and intake dismissals (did a proposed item get thrown away?) —
and drives one **asymmetric, per-tool earned-autonomy ratchet**:

- **Trust is earned upward, but only with the owner's consent.** A tool that has done a routine
  action cleanly enough, long enough, crosses a threshold; the agent then **proposes** a discrete
  promotion (a `PromotionProposal` carrying legible `evidence`) into the owner's inbox. The owner
  approves via `respondToPromotion` and the tool's autonomy rises. **The agent never raises its
  own autonomy** — proposing is the most it can do. That single constraint is the trust model.
- **Trust is lost reflexively, with no consent required.** A bad outcome, an owner `cancelTask`,
  or an owner `flagOutcome` drops the tool's autonomy **automatically** — no proposal, no
  mutation, no approval. Earning is slow and gated; losing is immediate and free.
- **The hard-rule floor is immune.** No amount of clean track record ever lets a tool past the
  spend / irreversible-third-party / secret-disclosure floor. Trust buys *up*, never below the
  floor.

The signal that feeds the ratchet is **inferred-clean by default with a retroactive owner veto**:
an action that reaches a successful end with no cancel and no complaint is recorded *clean*. But
because trust accrues silently, a fresh clean outcome is **not yet promotion-eligible** — it must
first survive a **maturation window** (`tool_outcomes.matured_at`) during which the owner can
still retroactively flag it bad. Only **matured-clean** outcomes count toward promotion, so the
veto always has time to land before an outcome can buy autonomy.

This phase introduces **no new act-edge behavior** and **no new connector** — it only reads the
log both edges already write, and adds the one consumer of `tools` autonomy that was reserved but
inert through Phases 3–7: until now the gate always gated; after this phase a sufficiently-trusted
tool's routine, floor-clearing action can auto-approve.

## Clarifications

### Session 2026-06-07

- Q: When a bad outcome / `cancelTask` / `flagOutcome` reflexively demotes a tool, how far does
  its autonomy drop? → A: **Neither a fixed one-rung step nor a hard reset — the stored per-tool
  autonomy becomes a continuous floating-point trust score, and demotion subtracts a configurable
  decrement from it.** The discrete `AutonomyLevel` rungs (`NONE`, `ENRICH_ONLY`, `PROPOSE`,
  `EXECUTE_GATED`, `EXECUTE_AUTO`) become **threshold bands** over that score — the level a tool
  reports is derived from which band its score falls in. This gives finer granularity than named
  rungs while keeping the discrete contract surface (a `PromotionProposal` still proposes a
  `fromLevel`→`toLevel` band crossing the owner can reason about). Demotion is therefore
  *proportional*: a bad signal subtracts a (configurable) amount, which may or may not drop the
  tool into a lower band.
- Q: How do intake dismissals tune what subsequently gets proposed (the intake half of the loop)?
  → A: **Both axes.** (1) Accumulated dismissals **tighten the effective thresholds** for the
  emitting connector/source pattern (raise the confidence floor / lower the stakes ceiling), so
  similar items hold `PROPOSED` instead of auto-accepting — deterministic, no model cost. (2)
  Accumulated dismissal **reasons are surfaced to the triage stage as labeled
  `[DISMISSAL_HISTORY]` evidence**, so the triage LLM judges similar future items more skeptically.
  The labeled-section discipline (Phase 4/5) applies: dismissal history is *evidence to weigh*,
  never an instruction to obey.
- Q: What default shape does the promotion threshold take? → A: **A matured-clean ratio over a
  rolling window.** A tool becomes promotion-eligible when its matured-clean fraction over a
  rolling window of recent outcomes is at or above a configurable percentage (with a configurable
  minimum sample size so a single clean outcome cannot promote). This tolerates rare bad outcomes
  better than a strict consecutive streak while still being legible as evidence ("48 of the last
  50 matured clean").
- Q: Is `respondToPromotion` reachable by an agent identity? → A: **No — owner-only, structurally
  guarded by `auth.RequireOwner(ctx)` (Principal.Kind == "user") before any DB write**, the same
  discipline as the Phase 4/5/7 owner mutations. An agent principal calling it is refused before
  any rung moves. This is the structural enforcement of "the agent never self-escalates."
- Q: Does a declined promotion immediately re-propose? → A: **No.** When the owner declines a
  `PromotionProposal`, the tool's autonomy is unchanged and the subsystem MUST NOT re-propose the
  same band crossing until **new matured-clean outcomes accrue** past the threshold again (a
  cooldown by construction, not a timer). This keeps the consent surface from becoming a
  rubber-stamp nag.
- Q: Is the maturation window a per-outcome property or a global setting? → A: **Per-outcome
  stamp from a configurable global window.** Each `tool_outcomes` row gets a `matured_at`
  computed from its `at` plus a single configurable maturation duration; "matured" means
  `now() ≥ matured_at` and the row is still `clean`. The duration is one knob, applied per row.
- Q: What numeric scale does the trust score use, and which `AutonomyLevel` values are meaningful
  bands for a *tool's* gate behavior? → A: **A `0.0–1.0` score with three tool-meaningful bands:**
  `NONE` (disabled), `EXECUTE_GATED` (baseline — always gate), and `EXECUTE_AUTO` (auto-approve
  when the floor clears). The two intake-oriented levels (`ENRICH_ONLY`, `PROPOSE`) are **not**
  tool-gate states — they describe intake/task posture, not how a tool's action is gated. The
  migrated baseline for an existing `execute_gated` tool is a mid `EXECUTE_GATED`-band score;
  evidence renders the score legibly as a percentage / tally.
- Q: Once a tool reaches `EXECUTE_AUTO`, does every floor-clearing call auto-approve, or only
  calls resembling the routine it earned trust on? → A: **Per-routine.** Auto-approval is scoped
  to a **routine fingerprint** (a call-equivalence signature): a call auto-approves only when the
  tool is in the `EXECUTE_AUTO` band **AND** the specific call matches a routine whose
  matured-clean track record earned the promotion **AND** the floor clears. An unfamiliar call
  shape from the same tool still gates even at `EXECUTE_AUTO`. Consequently the matured-clean
  threshold is computed **per `(tool, routine fingerprint)`**, and a `PromotionProposal` names the
  specific routine ("this routine, done cleanly 15×"). The *stored autonomy band* remains per-tool
  (`tools` score — invariant preserved); the per-routine scoping is the **eligibility filter** on
  top of the band, derived from the fingerprints recorded on `tool_outcomes`. Defining the
  fingerprint precisely (which call fields are salient) is a design task, bounded by: semantically
  equivalent calls MUST share a fingerprint and materially different calls MUST NOT.
- Q: How far down can automatic demotion push a tool's score? → A: **Auto-demotion floors at the
  `EXECUTE_GATED` baseline.** Reflexive demotion strips *earned* autonomy (instantly removing
  `EXECUTE_AUTO`) but never pushes a tool below the always-gate baseline; reaching `NONE`
  (disabled) is an **explicit owner action only**. So a transient bad streak or a noisy flag
  cannot silently brick a tool the owner still needs, while the reflexive drop still instantly
  achieves the real safety goal (no more auto-approval).
- Q: Is the promotion rolling window count-based or time-based? → A: **Count-based — a ratio over
  the last N matured outcomes for the `(tool, routine fingerprint)`** (e.g. clean ≥ 90% of the
  last 50). This makes evidence self-normalizing and legible ("clean 48 of the last 50"), gives
  deterministic acceptance tests, and lets a rarely-used-but-reliable routine keep accumulating
  toward promotion rather than have its record expire by calendar time. Both N (window size) and
  the ratio threshold are configurable (NFR-005).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A tool earns autonomy on a routine it has done cleanly (Priority: P1)

A tool (say, `send-email` to a known contact) performs the same routine, floor-clearing action
many times. Each completion is recorded **clean by default**. Those outcomes **mature** (survive
the settling window with no retroactive flag). Once the matured-clean track record crosses the
threshold, the agent emits a **`PromotionProposal`** — surfaced in the owner's inbox as a
`PendingDecision` with legible evidence ("done cleanly 48 of the last 50; promote from
EXECUTE_GATED to EXECUTE_AUTO?"). The owner accepts via `respondToPromotion(accept: true)`; the
tool's per-tool autonomy rises. The **same routine now auto-approves** without a human wait — but
is **still floor-checked** on every call.

**Why this priority**: This is the headline capability — the system stops asking you to
re-approve the same routine forever. Without it the phase delivers nothing observable. It
exercises the full happy path: inferred-clean recording → maturation → threshold → proposal →
owner consent → rung up → auto-approval (floor-checked).

**Independent Test**: Drive a tool through N clean completions of a floor-clearing action, advance
time past the maturation window, confirm a single `PromotionProposal` with coherent evidence
appears in the inbox; accept it; confirm the tool's reported autonomy rises and the next identical
call auto-approves (no pending decision) while a floor-tripping variant still requests a decision.

**Acceptance Scenarios**:

1. **Given** a tool completing a floor-clearing action, **When** the action reaches a successful
   end with no cancel and no complaint, **Then** a `tool_outcomes` row is recorded with
   `outcome=clean` by default.
2. **Given** enough matured-clean outcomes to cross the threshold, **When** the calibration
   subsystem evaluates the tool, **Then** it emits exactly one `PromotionProposal` carrying
   `fromLevel`, `toLevel`, and legible `evidence`, surfaced in the inbox as a `PendingDecision`.
3. **Given** that proposal, **When** the owner calls `respondToPromotion(accept: true)`, **Then**
   the tool's per-tool autonomy rises (its reported `AutonomyLevel` band advances) and the
   mutation returns the updated `Tool`.
4. **Given** the now-promoted tool, **When** it next performs the identical floor-clearing
   routine, **Then** the action auto-approves with no pending decision created.
5. **Given** the same promoted tool, **When** it attempts a variant that **trips the hard-rule
   floor**, **Then** the gate still produces a `RequestDecision` (promotion did not buy past the
   floor).

---

### User Story 2 - A bad signal reflexively demotes, instantly and without approval (Priority: P1)

Something goes wrong with a tool's action — it is recorded **bad**, or the owner **cancels the
task** it ran under, or the owner **flags the outcome** after the fact. Any one of these **drops
the tool's autonomy immediately** — no proposal, no owner approval, no mutation required for the
drop itself. The reflexive demotion surfaces via tool state / `taskChanged` so the owner can see
it happened.

**Why this priority**: The whole ratchet is only safe because losing trust is free and instant.
If demotion required the same consent ceremony as promotion, a misbehaving tool would keep its
autonomy until the owner found time to revoke it. This is the asymmetry that makes earned autonomy
acceptable.

**Independent Test**: Promote a tool (or set its score mid-band), then trigger each demotion path
— a bad outcome, a `cancelTask` on its task, and a `flagOutcome` — and confirm each independently
and immediately lowers the tool's trust score (and, if it crosses a band boundary, its reported
`AutonomyLevel`), with no `PromotionProposal` or approval involved.

**Acceptance Scenarios**:

1. **Given** a tool with accrued trust, **When** one of its actions is recorded `bad`, **Then**
   its trust score drops by the configured decrement **automatically**, with no proposal or
   approval.
2. **Given** a tool with accrued trust, **When** the owner `cancelTask`s a task that tool acted
   under, **Then** the tool is reflexively demoted by the same automatic path.
3. **Given** a completed action, **When** the owner calls `flagOutcome(taskId, toolId, reason)`,
   **Then** the outcome is recorded `bad` **and** the tool is reflexively demoted in the same
   operation.
4. **Given** any reflexive demotion, **When** it occurs, **Then** no mutation is required to
   effect the drop and the change is observable via tool state / `taskChanged`.

---

### User Story 3 - A retroactive veto on an un-matured action stops it ever buying a rung (Priority: P1)

A tool completes an action; it is recorded clean by default, but it has **not yet matured**.
Before the maturation window elapses, the owner **retroactively flags it bad** (`flagOutcome`).
Because only matured-clean outcomes count toward promotion, that flagged outcome **never
contributes to a promotion** — and the flag also reflexively demotes the tool now.

**Why this priority**: The honesty of "inferred-clean by default" depends entirely on the
retroactive veto having time to land. If un-matured outcomes could already buy autonomy, the
silent default would be unsafe. This story proves the maturation window does its job.

**Independent Test**: Record a clean outcome, do **not** advance past its maturation window,
`flagOutcome` it, then drive the calibration evaluation; confirm the flagged outcome counts as bad
(not clean), is excluded from any matured-clean tally, and no promotion is proposed on its
strength.

**Acceptance Scenarios**:

1. **Given** a clean outcome whose `matured_at` is still in the future, **When** the owner flags
   it bad, **Then** it is recorded `bad` and is excluded from the matured-clean count forever.
2. **Given** that flagged-before-maturity outcome, **When** the calibration subsystem evaluates
   the tool, **Then** the outcome contributes nothing toward crossing the promotion threshold.
3. **Given** an outcome that **has** matured clean (window elapsed, never flagged), **When** the
   owner flags it, **Then** the flag still reflexively demotes the tool now — the already-counted
   maturation remains the honest record of what was true at maturation time.

---

### User Story 4 - The floor is immune to any track record (Priority: P1)

No matter how long a tool's clean streak, the hard-rule floor (spend / irreversible-third-party /
secret-disclosure) is never bought past. A fully-trusted, maximally-promoted tool that attempts a
floor-tripping action still produces a decision request, exactly as a brand-new tool would.

**Why this priority**: This is the non-negotiable safety bound on the whole feature. Earned
autonomy that could erode the floor would invert the trust model. It must hold by construction,
independent of calibration state.

**Independent Test**: Promote a tool to the top band, then have it attempt a clearly
floor-tripping action (e.g. above the spend limit, or to a stranger recipient); confirm the gate
returns `RequestDecision` regardless of the tool's autonomy.

**Acceptance Scenarios**:

1. **Given** a tool at the maximum autonomy band, **When** it attempts an action that trips any
   floor clause, **Then** the gate produces `RequestDecision` — the autonomy is ignored for that
   action.
2. **Given** any trust score whatsoever, **When** the floor would trip, **Then** auto-approval is
   structurally impossible (the floor is consulted before any autonomy short-circuit).

---

### User Story 5 - The agent cannot escalate itself (Priority: P1)

The one prohibited move is the agent raising its own autonomy. An agent principal that attempts
`respondToPromotion` (the only path that raises a rung) is refused before any rung moves. The
agent may *propose*; only the owner *disposes*.

**Why this priority**: Self-escalation is the single move that breaks the trust model — if an
agent could approve its own promotion, "owner-gated promotion" is fiction. This must be a
structural guarantee, not a convention.

**Independent Test**: As a non-owner (agent) principal, call `respondToPromotion(accept: true)` on
a live proposal; confirm it is refused before any DB write and the tool's autonomy is unchanged.

**Acceptance Scenarios**:

1. **Given** a live `PromotionProposal`, **When** an agent (non-`user`) principal calls
   `respondToPromotion`, **Then** the request is refused before any DB write and no autonomy
   moves.
2. **Given** the same proposal, **When** the owner (`user` principal) calls it, **Then** it
   succeeds — establishing that the refusal is an authorization boundary, not a broken mutation.
3. **Given** any agent identity, **When** it acts anywhere in the chain, **Then** there exists no
   path other than an owner-approved `respondToPromotion` that raises a tool's autonomy.

---

### User Story 6 - Intake dismissals tune what subsequently gets proposed (Priority: P2)

The intake half of the same loop: when the owner repeatedly **dismisses** proposed items from a
source, the calibration subsystem reads those dismissals and **tunes subsequent intake** two ways
— it tightens the effective thresholds for that connector/source pattern (so similar items hold
`PROPOSED` rather than auto-accept) and it surfaces the accumulated dismissal reasons to the
triage stage as labeled evidence (so the triage LLM judges similar items more skeptically). One
subsystem, two edges, one loop.

**Why this priority**: This proves the "one loop, both edges" claim — that execution calibration
and intake tuning are the same subsystem, not two. It is P2 because the execution edge (US1–US5)
is the headline; the intake edge demonstrably tunes but builds on the calibration plumbing the
execution stories establish.

**Independent Test**: Dismiss several proposed items from one source with reasons; confirm a
subsequent comparable item from that source is held `PROPOSED` (not auto-accepted) where it
previously would have auto-accepted, and that the triage stage receives the dismissal history as
labeled evidence.

**Acceptance Scenarios**:

1. **Given** repeated dismissals of items from a source, **When** a comparable item later arrives,
   **Then** the effective confidence floor / stakes ceiling for that source has tightened such
   that the item holds `PROPOSED` instead of auto-accepting.
2. **Given** the same accumulated dismissals, **When** the triage stage judges a later item from
   that source, **Then** the dismissal reasons are presented to it as labeled `[DISMISSAL_HISTORY]`
   evidence (weighed, never obeyed).
3. **Given** the intake and execution edges, **When** calibration runs, **Then** both are served
   by one subsystem reading the audit DAG, not two parallel mechanisms.

---

### Edge Cases

- **Promotion declined, then more clean outcomes**: After an owner declines, the subsystem must
  not re-propose the same band crossing until *new* matured-clean outcomes push past the threshold
  again — no immediate re-nag.
- **Bad outcome arrives while a `PromotionProposal` is still open**: The pending proposal must be
  invalidated/withdrawn (or resolve to no-op on accept) — a reflexive demotion must not be
  out-raced by an owner accepting a now-stale proposal that the evidence no longer supports.
- **`flagOutcome` on an outcome from a tool already at the `EXECUTE_GATED` baseline**: The flag
  still records bad; the score decrement is clamped at the baseline (auto-demotion cannot push the
  tool sub-gated toward `NONE` — only an explicit owner action disables a tool).
- **Maturation window of zero / disabled**: If the maturation duration is mis-configured to zero,
  the retroactive veto window collapses — the spec requires a conservative non-zero default and
  that the window be observable/instrumented (honesty of inferred-clean).
- **A tool with no outcomes**: Never proposes (sample below the minimum); stays at its baseline
  autonomy.
- **Concurrent outcomes near a band boundary**: Trust-score updates must be serializable so two
  near-simultaneous outcomes don't lose an update (a demotion swallowed by a promotion-eligible
  recompute).
- **Owner cancels a task that ran multiple tools**: Each tool that acted under the cancelled task
  is reflexively demoted (cancel is a task-level bad signal applied per acting tool).
- **Discrete contract vs continuous score**: The owner-facing `PromotionProposal` always describes
  a discrete `fromLevel`→`toLevel` band crossing even though the underlying score is continuous;
  the evidence and the proposal must agree on the band acceptance lands in.
- **Floor reclassification mid-track-record**: If an owner tightens a tool's floor permissions, a
  previously auto-approving routine that now trips the floor must immediately route back to a
  decision request — the floor is evaluated live, not cached from past outcomes.
- **Unfamiliar call shape at `EXECUTE_AUTO`**: A floor-clearing call whose fingerprint does not
  match any promotion-earning routine must still gate, even though the tool is in the auto band —
  trust is earned per routine, not blanket per tool.
- **Fingerprint drift / collision**: A fingerprint that is too coarse would let a risky novel call
  ride an unrelated routine's trust (must avoid); one too fine would never accumulate enough
  matured-clean samples to promote (degrades to always-gate, the safe direction).

## Requirements *(mandatory)*

### Functional Requirements

#### Clean/bad determination & the maturation window

- **FR-001**: On an action reaching a successful end with no cancel and no complaint, the system
  MUST record a `tool_outcomes` row defaulting to `outcome=clean` (inferred-clean).
- **FR-002**: The system MUST stamp each `tool_outcomes` row with a `matured_at` derived from its
  recording time plus a single configurable maturation duration; an outcome is **matured-clean**
  only when the window has elapsed (`now() ≥ matured_at`) **and** the row is still `clean`.
- **FR-003**: The owner MUST be able to **retroactively flag** any completed action bad via
  `flagOutcome(taskId, toolId, reason)`; the flag MUST record the outcome `bad` **and** reflexively
  demote the tool in the same operation.
- **FR-004**: An outcome flagged bad **before** it matures MUST be excluded from the matured-clean
  tally permanently — it MUST NOT contribute to crossing the promotion threshold.
- **FR-005**: The maturation duration MUST default to a conservative non-zero value and be
  configurable; the system MUST instrument the window (so the honesty of inferred-clean — that the
  veto genuinely has time to land — is observable).

#### The asymmetric ratchet & the trust score

- **FR-006**: The per-tool autonomy the ratchet moves MUST be stored as a continuous
  floating-point **trust score on a `0.0–1.0` scale**; the discrete `AutonomyLevel` rungs MUST be
  **derived** as threshold bands over that score. Only three bands are meaningful for a tool's gate
  behavior — `NONE` (disabled), `EXECUTE_GATED` (baseline, always gate), and `EXECUTE_AUTO`
  (auto-approve when the floor clears); `ENRICH_ONLY` and `PROPOSE` are intake/task posture, not
  tool-gate states, and MUST NOT be assigned as tool autonomy bands.
- **FR-007**: Promotion MUST be **owner-gated and discrete at the surface**: when a `(tool, routine
  fingerprint)`'s matured-clean track record crosses the promotion threshold, the agent MUST
  **propose** a discrete band crossing as a `PromotionProposal` that **names the specific routine**;
  the score MUST NOT rise without owner approval.
- **FR-008**: The promotion threshold MUST be a **matured-clean ratio over a count-based rolling
  window** — the last N matured outcomes for the `(tool, routine fingerprint)` (configurable
  window size N and configurable ratio percentage) — gated by a configurable **minimum sample
  size**, so a single clean outcome cannot trigger a proposal. The ratio MUST be computed
  **per `(tool, routine fingerprint)`**, not pooled across all of a tool's calls, and MUST NOT
  decay by calendar age (count-based, not time-based).
- **FR-008a**: The system MUST record a **routine fingerprint** (a call-equivalence signature) on
  each `tool_outcomes` row so promotion eligibility and auto-approval can be scoped per routine.
  Semantically equivalent calls MUST share a fingerprint; materially different calls MUST NOT.
- **FR-009**: Demotion MUST be **reflexive and automatic**: a bad outcome, an owner `cancelTask`
  on a task the tool acted under, or an owner `flagOutcome` MUST subtract a configurable decrement
  from the tool's trust score with **no proposal, no mutation, and no approval** required for the
  drop.
- **FR-010**: Demotion MUST be **proportional** (a score decrement, not a fixed jump to a named
  level) and MUST be clamped at the **`EXECUTE_GATED` baseline** — automatic demotion MUST NOT push
  a tool below the always-gate baseline into a sub-gated / `NONE` state. Disabling a tool (`NONE`)
  MUST be an explicit owner action, not a consequence of reflexive demotion.
- **FR-011**: The **hard-rule floor MUST be immune** to the trust score: no score ever permits an
  action that trips a floor clause to auto-approve; the floor is consulted before any
  autonomy-based short-circuit.
- **FR-012**: A call MUST auto-approve (no pending decision) only when **all three** hold: the
  tool's trust score is in the `EXECUTE_AUTO` band, the call **matches a routine fingerprint** whose
  matured-clean track record earned that band, and the **floor clears**. A floor-clearing call with
  an **unfamiliar** fingerprint from the same tool MUST still gate. This is the first consumer of
  the per-tool autonomy reserved since Phase 0 and inert through Phases 3–7.
- **FR-013**: After an owner **declines** a `PromotionProposal`, the system MUST NOT re-propose the
  same band crossing until **new** matured-clean outcomes again push past the threshold (cooldown
  by construction).
- **FR-014**: A reflexive demotion that occurs while a `PromotionProposal` is open MUST invalidate
  that proposal (so an owner cannot accept a stale proposal the evidence no longer supports).

#### Promotion surface & owner mutations

- **FR-015**: A `PromotionProposal` MUST surface in the inbox as a `PendingDecision` carrying
  `tool`, `fromLevel`, `toLevel`, and **legible `evidence`** sufficient for an informed yes/no —
  including a human-legible descriptor of the **specific routine** and its matured-clean tally and
  window (e.g. "send-email to a known contact — clean 48 of last 50"). It is a consent surface,
  not a rubber stamp.
- **FR-016**: The system MUST expose `respondToPromotion(proposalId, accept)` returning the
  updated `Tool`; on `accept: true` the tool's trust score MUST rise to land in the proposed band,
  on `accept: false` the score MUST be unchanged.
- **FR-017**: `respondToPromotion` MUST be **owner-only**, structurally guarded by the owner check
  (`Principal.Kind == "user"`) **before any DB write**, and MUST be **unreachable by an agent
  identity** — there MUST be no other path that raises a tool's autonomy.
- **FR-018**: A reflexive demotion MUST require **no mutation**, but MUST be observable via tool
  state / `taskChanged` so the owner can see autonomy was lost.
- **FR-019**: `flagOutcome(taskId, toolId, reason)` MUST be exposed as an owner mutation returning
  the updated `Tool`, recording the bad outcome and the reflexive demotion together.

#### One calibration subsystem, both edges

- **FR-020**: A single calibration subsystem MUST serve **both** edges — execution outcomes
  (matured outcomes → per-tool trust score) and intake dismissals (dismissal history → what
  subsequently gets proposed) — reading the audit DAG, not two parallel mechanisms.
- **FR-021**: Accumulated intake **dismissals MUST tighten the effective thresholds** (raise
  confidence floor / lower stakes ceiling) for the emitting connector/source pattern, so
  comparable later items hold `PROPOSED` instead of auto-accepting.
- **FR-022**: Accumulated intake **dismissal reasons MUST be surfaced to the triage stage as
  labeled evidence** (`[DISMISSAL_HISTORY]`), weighed by the triage LLM but never obeyed as an
  instruction (the Phase 4/5 labeled-section discipline).
- **FR-023**: Calibration MUST read only what is already in the audit DAG — every verdict and
  piece of evidence it relies on MUST already be recorded (it adds no new act-edge behavior, only
  a reader plus the outcome/flag writes and the autonomy move).

#### v1 scope guard

- **FR-024**: Promotions MUST propose **discrete band changes only**; **auto-rewriting overseer
  instructions is out of scope** — free-text overseer instruction edits stay owner-authored
  (Phase 4 `setToolOverseerInstructions`).
- **FR-025**: Promotion MUST always be owner-approved — there MUST be **no auto-promotion** path.

### Non-Functional Requirements

- **NFR-001 (asymmetry)**: Earning autonomy MUST be strictly harder than losing it — promotion is
  multi-outcome, matured, thresholded, and owner-gated; demotion is single-signal, immediate, and
  automatic.
- **NFR-002 (floor supremacy)**: Floor immunity MUST hold by construction for every tool at every
  autonomy band — verified independently of calibration state.
- **NFR-003 (audit honesty)**: Calibration MUST be only as trusting as the log is honest — it MUST
  derive promotion solely from recorded, matured outcomes, never from un-recorded inference.
- **NFR-004 (no self-escalation)**: There MUST be exactly one path that raises a tool's autonomy —
  an owner-approved `respondToPromotion` — and it MUST be structurally closed to agent identities.
- **NFR-005 (tunability)**: The maturation duration, promotion ratio + window + minimum sample,
  and demotion decrement MUST all be configurable, so the loop can be tuned between "over-eager
  proposing" and "compounding trust never feels real."
- **NFR-006 (evidence legibility)**: `PromotionProposal.evidence` MUST be legible enough to make
  an informed decision (the concrete track record), not an opaque score.
- **NFR-007 (reuse reserved schema)**: The phase MUST reuse the Phase 0 `tool_outcomes` table and
  the per-tool autonomy column; representing autonomy as a continuous score MAY require migrating
  the existing `tools.rung` representation, which MUST be justified against the reserved schema.

### Key Entities

- **ToolOutcome**: One recorded result of a tool's action — `tool_id`, `task_id`, `outcome`
  (`clean` by default | `bad`), `at`, and `matured_at`. The atom calibration counts; only
  matured-clean rows buy autonomy.
- **Trust score (per-tool autonomy)**: The continuous floating-point value (`0.0–1.0`) the ratchet
  moves, stored per tool. The three tool-meaningful `AutonomyLevel` bands — `NONE` (disabled),
  `EXECUTE_GATED` (baseline), `EXECUTE_AUTO` (auto-approve when floor clears) — are threshold views
  over it (`ENRICH_ONLY`/`PROPOSE` are intake/task posture, not tool bands). The only stored
  autonomy; task-level autonomy stays emergent/computed.
- **PromotionProposal**: A `PendingDecision` (declared since Phase 2) the agent emits when a
  matured-clean track record crosses the threshold — `tool`, `fromLevel`, `toLevel`, `evidence`.
  The owner's consent surface for raising autonomy.
- **Calibrator**: The single subsystem reading both audit-DAG edges. Records inferred-clean
  outcomes, applies reflexive demotion on bad signals, evaluates matured-clean track records to
  propose promotions, and tunes intake from dismissal history.
- **Routine fingerprint**: A call-equivalence signature recorded on each `tool_outcomes` row that
  groups semantically equivalent calls of a tool. Promotion eligibility and auto-approval are
  scoped per `(tool, fingerprint)`, so a tool earns and exercises autonomy on a *specific routine*,
  not on every call shape. The per-tool band is the gate; the fingerprint is the eligibility filter.
- **Maturation window**: The configurable settling duration between an outcome's recording and its
  eligibility to count toward promotion — the time the retroactive veto has to land.
- **Dismissal history**: The accumulated intake dismissals (reason + source) the subsystem reads
  to tighten thresholds and feed triage as labeled evidence — the intake edge of the one loop.

## Out of Scope (deferred)

- **Auto-refining overseer instructions** — the loop proposes discrete autonomy changes; it never
  rewrites free-text overseer instructions in v1 (§16). Instruction edits stay owner-authored.
- **Auto-promotion** — promotion is always owner-approved; there is no path that raises autonomy
  without consent.
- **Cross-edge calibration dedup** beyond what one shared subsystem naturally gives — no explicit
  reconciliation of the same underlying signal arriving on both edges.
- **Predictive / model-driven trust scoring** — the score moves on recorded outcomes by
  configured arithmetic, not a learned model.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A tool that performs a routine floor-clearing action cleanly enough to cross the
  threshold (after the outcomes mature) produces exactly one `PromotionProposal` with legible
  evidence; on owner acceptance the tool's autonomy band rises and the same routine thereafter
  auto-approves with no pending decision — still floor-checked.
- **SC-002**: A single bad outcome — or a `cancelTask`, or a `flagOutcome` — immediately lowers
  the tool's trust score with no proposal and no approval, observable via tool state.
- **SC-003**: An action flagged bad **before** it matured never contributes to a promotion: with
  it excluded, the tool does not cross the threshold and no proposal is emitted on its strength.
- **SC-004**: No amount of clean track record lets a maximally-promoted tool auto-approve a
  floor-tripping action — the gate returns `RequestDecision` regardless of autonomy.
- **SC-005**: An agent (non-owner) principal calling `respondToPromotion` is refused before any DB
  write and no autonomy moves; only the owner principal succeeds.
- **SC-006**: After repeated dismissals from a source, a comparable later item that previously
  would have auto-accepted is instead held `PROPOSED`, and the triage stage receives the dismissal
  history as labeled evidence — demonstrating the intake half of the one loop.
- **SC-007**: After an owner declines a `PromotionProposal`, no new proposal for the same band
  crossing appears until additional matured-clean outcomes again cross the threshold.
- **SC-008**: The maturation window, promotion ratio/window/minimum-sample, and demotion decrement
  are each adjustable, and changing them measurably changes how readily tools propose and how far
  bad signals demote.

## Assumptions

- The Phase 0 `tool_outcomes` table (`tool_id`, `task_id`, `outcome` default `clean`, `at`,
  `matured_at`) and the per-tool autonomy column on `tools` are the reserved storage; this phase
  fills them and consumes them. Representing autonomy as a continuous trust score may require a
  migration of the existing `tools.rung` text column (to a numeric score plus a derived-band view)
  — justified against the reserved schema per NFR-007; the discrete `AutonomyLevel` GraphQL enum
  and `PromotionProposal` shape (already in the contract) are preserved.
- The gate (Phases 3–5) is the enforcement point: it already consults the floor first; this phase
  adds the autonomy-band short-circuit *after* the floor, so floor supremacy is preserved by the
  existing ordering. Until this phase the per-tool autonomy was stored but never consulted.
- `flagOutcome` and `respondToPromotion` are additive to the operator-edge GraphQL contract
  (Path 1, additive) per the versioning policy; both are owner-only via the Phase 4
  `auth.RequireOwner(ctx)` discipline.
- "Bad outcome," "task cancel," and "owner flag" are the three demotion triggers; `cancelTask`
  (Phase 1) and the Phase 7 dismissal path already write to the audit DAG, so calibration reads
  existing signals rather than introducing new ones.
- The triage stage is the Phase 6 agent; surfacing `[DISMISSAL_HISTORY]` to it reuses the
  Phase 4/5 labeled-section discipline (evidence, not instruction) — no new triage component.
- The owner is the single `user` principal; every autonomy-raising and outcome-flagging operation
  is guarded by `auth.RequireOwner(ctx)` before any DB write.
- Promotion evaluation runs off recorded outcomes (e.g. on outcome maturation or a periodic
  sweep); the exact trigger is an implementation choice that does not change the observable
  contract (a proposal appears once the matured-clean track record crosses the threshold).
- "Routine action" for auto-approval means a call whose **routine fingerprint** matches past
  matured-clean calls of the same `(tool, fingerprint)` and that clears the floor; defining the
  fingerprint precisely (which call fields are salient) is a design task bounded by "semantically
  equivalent calls share a fingerprint, materially different calls do not" and "floor-checked every
  time." The per-tool autonomy band remains the only stored autonomy; per-routine scoping is
  derived from fingerprints on `tool_outcomes`, not a new stored autonomy axis.
