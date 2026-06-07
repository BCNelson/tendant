# Specification Quality Checklist: Calibration & the Earned-Autonomy Ratchet

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-06-07
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Items marked incomplete require spec updates before `/speckit.clarify` or `/speckit.plan`
- Clarifications resolved in-session (2026-06-07), recorded in the Clarifications section; no open
  markers remain. Specify-stage: demotion model (continuous trust score with threshold bands),
  intake-tuning mechanism (both threshold-tightening and dismissal evidence), promotion-threshold
  shape (matured-clean ratio over a rolling window), plus declined-promotion cooldown and
  per-outcome maturation stamp. Clarify-stage (4 added): `0.0–1.0` score with three tool-meaningful
  bands (`NONE`/`EXECUTE_GATED`/`EXECUTE_AUTO`); **per-routine** auto-approval scoped to a routine
  fingerprint; auto-demotion floors at the `EXECUTE_GATED` baseline (disable is owner-only);
  count-based rolling window (last N matured outcomes).
- Deferred to `/speckit.plan` (tunable, non-blocking): the concrete default numeric values for the
  maturation duration, window size N, ratio percentage, minimum sample size, and demotion
  decrement; and the precise routine-fingerprint field set.
- The spec names GraphQL/DB identifiers (`tool_outcomes`, `tools.rung`, `respondToPromotion`,
  `PromotionProposal`, `AutonomyLevel`) because they are pre-existing, reserved contract/schema
  surfaces from Phases 0–7 the brief restates verbatim — not new implementation choices. They are
  the shared vocabulary of this codebase's contracts, kept for traceability against the v2 arch
  spec and the committed GraphQL/migrations.
