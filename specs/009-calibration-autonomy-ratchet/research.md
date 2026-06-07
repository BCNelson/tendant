# Research: Calibration & the Earned-Autonomy Ratchet

Phase 0 design decisions. Each resolves an unknown from the Technical Context. Format:
Decision · Rationale · Alternatives considered. Grounded in the existing code surfaces mapped
during planning (file:line references).

---

## R1. Trust-score scale & band thresholds

**Decision**: A `0.0–1.0` continuous `tools.trust_score` (new `double precision` column). Three
tool-meaningful `AutonomyLevel` bands derived from it:

| Band | Score range | Meaning |
|---|---|---|
| `NONE` | score `= 0.0` (owner-set only) | tool disabled |
| `EXECUTE_GATED` | `[0.5, 0.8)` — **baseline = 0.5** | always gate (the un-promoted default) |
| `EXECUTE_AUTO` | `[0.8, 1.0]` | auto-approve eligible (per-routine grant still required) |

`ENRICH_ONLY`/`PROPOSE` are **not** tool bands (they are intake/task posture). Band boundaries
(`auto_threshold=0.8`, `baseline=0.5`) are package constants, overridable by config.

**Rationale**: A float makes demotion *proportional* (the owner's Q1 steer) and keeps the discrete
`AutonomyLevel` enum (already in the GraphQL contract and `db` enum) as a derived view, so no
contract churn. Baseline 0.5 sits mid-`EXECUTE_GATED` so a single demotion decrement (0.25) drops a
freshly-promoted tool (0.8) out of the auto band (→0.55) yet stays clamped at baseline — exactly
the "one bad outcome drops the rung, never below the safe baseline" behavior (US2 + Q3).

**Alternatives**: discrete `rung` text steps (rejected — can't express proportional demotion, the
explicit owner steer); `0–100` integer (rejected — float is idiomatic for a ratio and the existing
`confidence`/`stakes_hint` columns are already `double precision`).

---

## R2. Promotion is a discrete owner-gated jump; demotion is a proportional automatic slide

**Decision**: Asymmetric score mechanics:
- **Promotion (owner-approved)**: on `respondToPromotion(accept:true)`, set `trust_score` into the
  `EXECUTE_AUTO` band (e.g. `max(score, auto_threshold)` → 0.8) **and** insert a
  `tool_routine_grants` row for the proposed `(tool, fingerprint)`. A discrete jump, gated.
- **Demotion (automatic)**: `trust_score = max(baseline, trust_score - decrement)` (default
  decrement 0.25) **and** revoke the affected routine's grant. A proportional slide, reflexive.

**Rationale**: Faithfully realizes "earned upward (gated, discrete), lost reflexively
(proportional, automatic)" — the asymmetry IS the trust model (Constitution IV; NFR-001). The
continuous score carries the proportional-demotion semantics; the discrete jump carries the
owner-consent semantics.

**Alternatives**: continuous accrual on each clean outcome (rejected — that is silent
self-escalation; promotion MUST be owner-gated, Principle IV); fixed one-rung demotion (rejected —
the owner explicitly wanted a finer floating-point model).

---

## R3. Routine fingerprint (the per-routine eligibility key)

**Decision**: A deterministic, pure `fingerprint(tool, payload) string` recorded on each
`tool_outcomes` row (new nullable `routine_fingerprint text`) and computed at gate time for
auto-approval matching. v1 fingerprint = `tool_global_uri` + a **canonicalized shape of the
salient payload fields**, where "salient" is per-tool: for `send-email` the recipient *class*
(known-contact vs other) + presence of attachments, **not** the subject/body text. Hashed to a
short hex string. Defined in `calibration/fingerprint.go` (pure, table-tested).

**Rationale**: Option B (per-routine) requires grouping "the same routine." The fingerprint must be
coarse enough to accumulate `min_sample` matured-clean outcomes yet fine enough that a materially
riskier call (a stranger recipient, an added attachment) is a *different* routine that still gates
(spec edge case "fingerprint drift / collision"). Keying on recipient *class* rather than identity
also keeps the floor (`irreversible_third_party: stranger_recipient`) as the backstop. Pure
function → deterministic and unit-testable; no model call.

**Alternatives**: hash the entire payload (rejected — too fine; trivial differences like a
timestamp would never accumulate, degrading to always-gate — the safe direction but useless); tool
only, ignoring payload (rejected — that is option A / per-tool, which the owner declined). The
exact salient-field set per tool is the one genuinely open design detail (spec defers it); v1
ships the `send-email` mapping and a documented default (tool URI + sorted top-level scalar keys'
*presence*, values excluded) for other tools.

---

## R4. Maturation: stamp `matured_at` at insert; promotion eligibility is a query

**Decision**: Set `matured_at = at + maturation_window` **at outcome insert** (app computes it from
the configurable window; passed into a revised `InsertToolOutcome`). "Matured-clean" is then a
pure query predicate: `matured_at <= now() AND outcome = 'clean'`. No separate maturation step
mutates rows.

**Rationale**: The window is a single global knob applied per row (spec Clarification). Stamping at
insert means the retroactive veto works for free: `flagOutcome` before `matured_at` flips
`outcome→'bad'`, so the row is excluded from the matured-clean predicate forever (FR-004) with no
race against a maturation job. The Phase-0 index `idx_outcomes_tool(tool_id, matured_at)` already
supports the query; we add `(tool_id, routine_fingerprint, matured_at)` for the per-routine ratio.

**Alternatives**: a maturation sweep that flips a boolean (rejected — extra write, race with the
veto, redundant with a time predicate); `matured_at` NULL-until-swept (rejected — the current Phase
3 behavior leaves it NULL; we need it populated to query).

---

## R5. Promotion proposals come from a DBOS-scheduled sweep

**Decision**: A new DBOS scheduled workflow `calibration.sweep` (schedule name
`calibration:sweep`, default cron hourly via `TENDANT_CALIBRATION_SWEEP_CRON`), registered and
created at boot exactly like `internal/intake/scheduler.go`'s `CreateSchedule`/`RehydrateSchedules`.
Each run: for every `(tool, routine_fingerprint)` with ≥ `min_sample` matured outcomes in the last
`N`, matured-clean ratio ≥ `ratio`, **not** already auto-granted, **no** open proposal, and **not**
in decline-cooldown → write a `pending_decisions(kind='promotion_proposal', tool_id, task_id=<repr>,
payload=<evidence>)` row, the `promotion_proposed` audit, a `tendant_events` notify, and a push job
(reusing the Phase-2 enqueuer).

**Rationale**: Maturation is time-based, so *something* must run after an outcome matures to notice
eligibility — a periodic sweep is the natural, crash-safe trigger and matches the
intake-poll precedent (durability for free). A rarely-used routine still gets proposed eventually
(count-based window, R6). The representative `task_id` is the most-recent matured-clean outcome's
task, satisfying the non-null `PendingDecision.task` contract without relaxing the schema.

**Alternatives**: evaluate lazily on each new outcome insert (rejected — a tool that goes idle right
after maturing would never propose); a separate cron daemon (rejected — violates "DBOS is the
execution engine"; the schedule must be crash-recovered).

---

## R6. Threshold shape: count-based matured-clean ratio

**Decision**: Eligibility = over the **last N** matured outcomes for the `(tool, fingerprint)`,
`clean / N ≥ ratio`, gated by `count(matured) ≥ min_sample`. Defaults: `N=50`, `ratio=0.90`,
`min_sample=20`. No calendar decay.

**Rationale**: The owner chose count-based (spec Clarification). Self-normalizing, legible evidence
("clean 48 of the last 50"), deterministic tests, and a reliable-but-infrequent routine keeps
accruing. `min_sample` prevents a 1/1 = 100% promotion.

**Alternatives**: time-window ratio (rejected by owner — record would expire by age); consecutive
streak (rejected — intolerant of one rare bad outcome; the owner picked ratio).

---

## R7. Gate layer placement — after the script, replacing the overseer/human step

**Decision**: Insert the autonomy layer in `gate.Evaluate` **after** the floor check and **after**
the gate-script layer's terminal verdicts, in the position the overseer is consulted. Logic: if the
floor did not trip and the script did not return a terminal `Deny`/`RequestDecision`, then if the
tool is in the `EXECUTE_AUTO` band **AND** `routineGrantLookup(toolID, fingerprint(call))` returns a
live grant → return `Approve` (skip the overseer/human wait). Otherwise fall through to the overseer
exactly as today. The lookup is a new injected seam `RoutineGrantLookup` (mirrors the existing
`PrincipalLookup` in `floor.go`), keeping `gate` pure (no direct DB).

**Rationale**: Placing it *after* the script preserves an owner-authored gate script's `Deny`
(Principle IX intent — the owner's custom rule still wins). Placing it where the overseer sits means
auto-approval replaces the *grading/human* step, never the floor (Constitution III). The seam keeps
the gate's purity invariant (`gate.go:18-20`) intact. The autonomy layer can only `Approve` or fall
through — it never denies — so it cannot weaken any other layer.

**Alternatives**: short-circuit immediately after the floor, before the script (rejected — would
bypass a denying owner script); make the gate read the DB directly (rejected — breaks gate purity,
Constitution-aligned design and existing tests).

---

## R8. Reflexive demotion wiring (three triggers)

**Decision**: All three demotion triggers funnel through `Calibrator` inside the existing
transaction/workflow that already writes the audit:
- **Bad outcome**: `internal/toolflow/workflow.go` already inserts a `bad` `tool_outcomes` row on
  dispatch error (line ~261). Route that through `Calibrator.RecordBad(toolID, taskID, fingerprint)`
  which records the row **and** demotes (decrement score + revoke that routine's grant + `tool_demoted`
  audit) in the same tx.
- **Owner cancel**: the `cancelTask` path enumerates tools that acted under the task (distinct
  `tool_id` in `tool_outcomes` for that task, plus any in-flight dispatch) and demotes each.
- **`flagOutcome` mutation**: owner-only; records a `bad` outcome (with `outcome_flagged` audit) +
  demotes — this is `Calibrator.FlagBad` from Appendix D.

A demotion that finds an **open** `promotion_proposal` for that tool resolves/withdraws it (FR-014).

**Rationale**: Demotion must be automatic and ride the same atomic write as the signal so it can
never be lost or require a mutation (NFR-001/FR-009/FR-018). Reusing the existing
outcome-insert/cancel sites means the audit DAG already has the parent message to link `in_reply_to`.

**Alternatives**: a demotion queue processed by the sweep (rejected — not reflexive/immediate; SC-002
requires the drop on the same event).

---

## R9. Intake tightening — derived, no new state

**Decision**: The "effective" disposition thresholds are computed at dispose time, not stored:
`effective_floor = min(1.0, base_floor + k * tighten_signal)` and
`effective_ceiling = max(0.0, base_ceiling - k * tighten_signal)`, where `tighten_signal` is a
bounded function of the count of recent **dismissals** attributable to the connector
(`tasks.intake_signal_id → intake_signals.connector_id`, joined to dismissal `state_transition`
rows). `base_floor`/`base_ceiling` stay in `connector_configs.disposition_rules`
(`internal/intake/disposition.go:32`). Separately, the connector's recent dismissal **reasons** are
read and handed to the `TriageJudge` as a labeled `[DISMISSAL_HISTORY]` section (mirroring the
Phase-7 `[INTAKE_SIGNAL]` labeling).

**Rationale**: "Calibration reads the audit DAG" (NFR-003) — tightening as a *derived* read keeps it
honest and avoids new stored tuning state. Per-connector granularity is the natural join and is
sufficient for v1 (source-pattern granularity is a documented refinement). The labeled section
reuses the Principle-IV discipline already proven in Phases 4/5/7 (`prompt_test.go` injection
cases).

**Alternatives**: store a learned per-source adjustment (rejected — new mutable tuning state,
contradicts "reads the DAG" and risks self-escalation of *intake* aggressiveness); model-scored
tightening (rejected — deterministic arithmetic is cheaper and legible).

---

## R10. Contract path — add `respondToPromotion` + `flagOutcome`, deprecate `decidePromotion`

**Decision**: Operator-edge GraphQL:
- **Path 1 (additive)**: add `respondToPromotion(proposalId: ID!, accept: Boolean!): Tool!` and
  `flagOutcome(taskId: ID!, toolId: ID!, reason: String): Tool!`, both owner-only.
- **Path 2 (deprecation)**: mark the existing Phase-2 stub
  `decidePromotion(decisionId: ID!, accept: Boolean!): PendingDecision!` with
  `@deprecated(reason: "Phase 8: use respondToPromotion; returns the updated Tool.")`. Its resolver
  keeps returning `NOT_YET_AVAILABLE`.

**Rationale**: The brief specifies these exact mutation names and `Tool!` return types (so the
client gets the updated band/score back). `decidePromotion` was a reserved stub (never functional);
superseding it additively + deprecating the old name is the policy's intended lane
(`versioning-policy.md`). No client breaks. The PR template path is declared (1 + 2).

**Alternatives**: implement `decidePromotion` in place (rejected — wrong return type `PendingDecision!`
vs the brief's `Tool!`, and a less useful name); remove `decidePromotion` (rejected — removal is a
breaking change, disallowed).

---

## R11. PromotionProposal resolution & evidence

**Decision**: Make the stubbed `PromotionProposal` resolvers real
(`graph/schema.resolvers.go:501` `Tool()` returns `phase2PlaceholderTool()` today). Resolve `tool`
from `pending_decisions.tool_id`; resolve `fromLevel`/`toLevel` from the proposal payload (the band
crossing); resolve `evidence: JSON!` from the payload's stored tally
(`{routine, window_n, matured_clean, ratio, sample}`). `mapPendingDecisionRow`
(`graph/phase2_helpers.go:129`) is updated to read these from the row instead of zero-values.

**Rationale**: The proposal must be a legible consent surface (NFR-006/FR-015); the evidence is
frozen into the `pending_decisions.payload` at sweep time so the inbox renders the exact track
record that justified it.

**Alternatives**: recompute evidence on read (rejected — the track record may have moved since the
proposal; the owner must see the evidence as of proposal time, like the Phase-3 frozen payload).

---

## R12. Config knobs (env, mirrors `TENDANT_OVERSEER_MAX_EVAL_PER_TASK`)

**Decision**: All knobs read in `cmd/tendant/main.go`, defaults as package constants in
`internal/calibration`:

| Env var | Default | Meaning |
|---|---|---|
| `TENDANT_CALIBRATION_MATURATION` | `24h` | maturation window (Go duration) |
| `TENDANT_CALIBRATION_WINDOW_N` | `50` | rolling window size |
| `TENDANT_CALIBRATION_RATIO` | `0.90` | matured-clean ratio to propose |
| `TENDANT_CALIBRATION_MIN_SAMPLE` | `20` | minimum matured sample |
| `TENDANT_CALIBRATION_DEMOTION_DECREMENT` | `0.25` | score subtracted per bad signal |
| `TENDANT_CALIBRATION_SWEEP_CRON` | `0 * * * *` | sweep cadence |
| `TENDANT_CALIBRATION_INTAKE_TIGHTEN_K` | `0.02` | per-dismissal threshold tightening coefficient (bounded) |

**Rationale**: NFR-005 mandates tunability; mirroring the overseer-cap env pattern keeps ops
consistent. Conservative defaults: a 24h veto window, a 90%-of-50 bar, and a quarter-score demotion.

**Alternatives**: a config table (rejected — Postgres-only but env is the established knob channel;
no need for runtime-mutable tuning in v1).

---

## R13. Observability (`/healthz` calibration block)

**Decision**: Add a `calibration` block to `healthzResponse` (mirrors `healthzIntakeBlock`,
`internal/server/healthz.go:39`) with rolling counters: `proposals_emitted_per_minute`,
`demotions_per_minute`, `outcomes_matured_per_minute`, plus a static `maturation_window` echo and an
`open_proposals` gauge. Backed by a `calibration.Metrics` roller (mirrors `intake/metrics.go`).

**Rationale**: The spec's risk register calls out instrumenting the honesty of inferred-clean
(maturation window) and over/under-proposing — these counters make both observable (FR-005/SC-008).

**Alternatives**: logs only (rejected — `/healthz` counters are the established surface and support
the demo assertions).
