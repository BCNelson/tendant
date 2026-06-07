# Implementation Plan: Calibration & the Earned-Autonomy Ratchet

**Branch**: `009-calibration-autonomy-ratchet` | **Date**: 2026-06-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/009-calibration-autonomy-ratchet/spec.md`

## Summary

Close the trust loop. A single **calibration subsystem** (`internal/calibration`) reads the
audit DAG on both edges and drives an **asymmetric, per-tool earned-autonomy ratchet**:

- **Inferred-clean recording + maturation**: every `tool_outcomes` row already defaults
  `outcome=clean` (Phase 3); this phase stamps `matured_at = at + window` at insert and records a
  **routine fingerprint** per row so promotion/auto-approval can be scoped per routine.
- **Owner-gated promotion**: a DBOS-scheduled **calibration sweep** finds `(tool, routine)` groups
  whose matured-clean ratio over the last N outcomes clears a configurable threshold and emits a
  `PromotionProposal` (the reserved Phase-2 `pending_decisions.kind='promotion_proposal'`) with
  legible evidence. The owner accepts via a new **owner-only** mutation; only then does the
  per-tool **continuous trust score** (`tools.trust_score`, new) rise into the `EXECUTE_AUTO` band
  and the routine get an **auto-grant** (`tool_routine_grants`, new).
- **Reflexive demotion**: a bad outcome (tool dispatch error), an owner `cancelTask`, or the new
  `flagOutcome` mutation **automatically** decrements the trust score (proportional, clamped at the
  `EXECUTE_GATED` baseline) and revokes the affected routine's grant — no proposal, no approval.
- **The first consumer of tool autonomy**: a new gate layer (between the floor and the
  script/overseer layers) auto-approves a call iff the tool is in the `EXECUTE_AUTO` band **AND**
  the call's routine fingerprint has a live grant **AND** the floor cleared — preserving floor
  supremacy (Constitution III) and never letting an agent self-escalate (Constitution IV).
- **Intake half of the same loop**: the subsystem reads dismissals (`tasks.intake_signal_id →
  intake_signals.connector_id`) to (1) compute an **effective** confidence-floor/stakes-ceiling
  that tightens with dismissal volume and (2) surface dismissal reasons to the Phase-6 triage seam
  as labeled `[DISMISSAL_HISTORY]` evidence.

**Contract change** (Principle VII): operator-edge GraphQL — **Path 1 (additive)** for
`respondToPromotion` and `flagOutcome`, plus **Path 2 (deprecation)** marking the superseded
Phase-2 `decidePromotion` stub `@deprecated`.

## Technical Context

**Language/Version**: Go 1.25 (toolchain auto), `services/api` module
**Primary Dependencies**: chi/v5, gqlgen v0.17.90, pgx/v5, sqlc v1.31.1, goose/v3, dbos-transact-golang v0.15.0 — **no new dependencies**
**Storage**: Postgres (single datastore + `LISTEN/NOTIFY` transport). Migration `00007`.
**Testing**: `go test -race` + testcontainers-go v0.39.0; table-driven `t.Run`
**Target Platform**: Linux self-hosted box; Flutter client (mobile/desktop/web)
**Project Type**: web-service (Go core + GraphQL operator edge) + Flutter client
**Performance Goals**: calibration sweep is a periodic background workflow (default hourly); gate auto-approval adds one indexed grant lookup per gated call (sub-ms); no hot-path model calls
**Constraints**: floor supremacy is structural; no agent path raises autonomy; calibration reads only recorded, matured outcomes (Constitution III/IV/VI)
**Scale/Scope**: single household; tools O(10s), routines per tool O(10s), outcomes O(1000s) — count-based windows keep queries bounded

**Resolved design decisions** (see [research.md](./research.md)): trust-score scale + band thresholds; routine-fingerprint definition; maturation-at-insert vs sweep; per-routine grant table vs per-tool-only; gate layer placement (after script, replacing the overseer/human step); intake threshold-tightening formula (derived, no new state); the `decidePromotion`→`respondToPromotion` contract path; default knob values.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Capability grows at the edges | ✅ PASS | No new source/action. Calibration is a core trust-loop subsystem the architecture explicitly reserves (CC-1); it reads the audit DAG and moves the per-tool dial. Not an edge feature. |
| II. A task is not a workflow | ✅ PASS | The calibration sweep is a DBOS workflow attached to no task; promotions reference a *representative* task only to satisfy the `PendingDecision.task` non-null contract. No task/workflow fusion. |
| III. The hard-rule floor is immune | ✅ PASS (load-bearing) | The new autonomy layer sits **after** the floor; auto-approval requires the floor to have cleared. No score ever lowers the floor (FR-011/NFR-002). Verified by a dedicated floor-supremacy test independent of trust score (US4). |
| IV. Owner authors trust; agents never self-escalate | ✅ PASS (load-bearing) | Promotion is owner-gated (`respondToPromotion`, `auth.RequireOwner` FIRST); demotion is reflexive/automatic; `[DISMISSAL_HISTORY]` is labeled evidence to the triage prompt, never instruction. No agent-reachable path raises a rung (US5/NFR-004). |
| V. Cancel halts, not rollback | ✅ PASS | `cancelTask` gains a demotion side-effect (per acting tool) but does not roll back effects; it reads the existing cancel transition. |
| VI. Every decision audited; log is DAG | ✅ PASS | New task-scoped audit kinds (`outcome_flagged`, `tool_demoted`, `promotion_proposed`, `promotion_responded`) ride `audit_messages` with `in_reply_to` links. Calibration is *only* as honest as this log (NFR-003). |
| VII. Edge contracts versioned & additive | ✅ PASS | Operator-edge GraphQL: **Path 1** (add `respondToPromotion`, `flagOutcome`) + **Path 2** (deprecate `decidePromotion`). No breaking change. PR template path declared. Intake-signal / MCP / gate-script / federation contracts untouched. |
| VIII. Federation-shaped | ✅ PASS | New `tool_routine_grants` is a sub-resource addressed via its parent tool (which carries `global_uri`); per the 1.2.0 amendment it needs no own `globalUri`. Actors referenced by `globalUri` in audits. |
| IX. Untrusted code sandboxed | ✅ PASS | No new executable-extension surface. The gate stays pure (no direct I/O): the routine-grant lookup is injected as a seam mirroring the existing `PrincipalLookup`. |

**Technology Constraints**: Postgres-only ✅ (one migration, no new store/transport); DBOS for durability ✅ (the sweep + the demotion side-effects ride workflows/transactions); no new dependencies ✅; Go ✅.

**Result**: PASS. One deliberate, owner-clarified deviation from the brief's "the only stored autonomy is per-tool" — see Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/009-calibration-autonomy-ratchet/
├── plan.md              # This file
├── spec.md              # Feature spec (clarified)
├── research.md          # Phase 0 — design decisions
├── data-model.md        # Phase 1 — migration 00007, entities
├── quickstart.md        # Phase 1 — exit-criteria walkthrough
├── contracts/
│   └── graphql.v1.graphqls   # operator-edge delta (additive + deprecation)
└── checklists/requirements.md
```

### Source Code (repository root)

```text
services/api/
├── internal/
│   ├── calibration/                 # NEW — the one subsystem, both edges
│   │   ├── calibrator.go            #   Calibrator iface + impl: RecordOutcome / FlagBad / MaybeProposePromotion
│   │   ├── score.go                 #   trust-score <-> AutonomyLevel band math (pure, table-tested)
│   │   ├── fingerprint.go           #   routine fingerprint (pure)
│   │   ├── sweep.go                 #   DBOS-scheduled promotion sweep workflow + schedule glue
│   │   ├── intake.go                #   effective-threshold tightening + dismissal-history reader
│   │   ├── metrics.go               #   rolling counters for /healthz (overseer/intake parity)
│   │   └── *_test.go
│   ├── gate/
│   │   ├── gate.go                  #   EDIT — new autonomy layer after floor, before overseer
│   │   └── autonomy.go              #   NEW — band check + RoutineGrantLookup seam (pure)
│   ├── toolflow/workflow.go         #   EDIT — route outcome recording through Calibrator (clean->record, bad->demote); stamp matured_at; record fingerprint
│   ├── db/queries/                  #   NEW/EDIT sqlc: outcomes (matured_at + fingerprint), grants, promotion-eligibility, dismissal-history
│   ├── intake/disposition.go        #   EDIT — read effective thresholds from calibration; pass [DISMISSAL_HISTORY] to triage
│   ├── lifecycle/audit.go           #   EDIT — four new task-scoped audit kinds
│   └── server/healthz.go            #   EDIT — calibration block
├── graph/
│   ├── schema.graphqls              #   EDIT — respondToPromotion, flagOutcome, @deprecate decidePromotion
│   ├── *.resolvers.go / phase8_helpers.go   # NEW resolvers + PromotionProposal Tool/levels/evidence real resolution
│   └── auth_registration.go         #   EDIT — register the two owner-only mutations
├── cmd/tendant/main.go              #   EDIT — wire Calibrator + sweep schedule + config knobs + grant lookup into gate
db/migrations/00007_calibration_ratchet.sql   # NEW

apps/mobile/                         # Flutter: PromotionProposal inbox card + flagOutcome action + tool autonomy/grant display
```

**Structure Decision**: Mirror the established phase pattern — a new trusted `internal/` package
(`calibration`) with a narrow interface, a DBOS-scheduled workflow (the sweep, mirroring
`internal/intake/scheduler.go`), a gate seam (mirroring `gate.PrincipalLookup`), additive GraphQL,
one migration, `/healthz` counters, and Flutter widgets — exactly the seams Phases 3–7 reserved.

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
|-----------|------------|--------------------------------------|
| `tool_routine_grants` table — autonomy state beyond the per-tool `tools.trust_score` (brief said "the only stored autonomy is per-tool") | The owner clarified (spec Clarifications 2026-06-07, Q2) that auto-approval is **per-routine**: an `EXECUTE_AUTO` tool must still gate an *unfamiliar* call shape. That requires storing which `(tool, routine)` the owner approved — a per-tool score alone cannot express it. | Per-tool-only autonomy would auto-approve *every* floor-clearing call of a promoted tool, contradicting the clarified safety requirement. Deriving eligibility purely from each routine's matured-clean ratio (no grant) would let an *unapproved* routine ride the tool's band the moment its ratio crosses — a self-escalation hole (Principle IV). The grant is the minimal store that keeps each routine owner-consented. The per-tool `trust_score` remains the band substrate (Q1); the grant is only the eligibility filter on top. |
| New `tools.trust_score` column (migrating away from the inert `tools.rung` text as the behavior source) | The owner clarified (Q1) a **continuous** `0.0–1.0` score with the `AutonomyLevel` enum as derived bands, so demotion is proportional. | Keeping `rung` as a discrete text label cannot express proportional demotion or a settle-able score. `rung` was reserved but never read for behavior; this is the phase that consumes it, and a float is the clarified representation. `rung` is retained as a derived cache for compatibility. |
