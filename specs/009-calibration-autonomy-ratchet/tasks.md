# Tasks: Calibration & the Earned-Autonomy Ratchet

**Input**: Design documents from `specs/009-calibration-autonomy-ratchet/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/graphql.v1.graphqls

**Tests**: INCLUDED — this codebase ships table-driven (`t.Run`) + testcontainers e2e tests per
phase (Constitution VI; CLAUDE.md conventions). Test tasks accompany each story.

**Organization**: by user story (US1–US6). US1 is the MVP backbone (promotion happy path). After
the Foundational phase, US2 (demotion) can proceed largely in parallel with US1; US3/US4/US5 build
on US1's gate + mutation plumbing; US6 (intake) is independent of the execution edge.

## Path Conventions

Go core: `services/api/internal/…`, `services/api/graph/…`, `services/api/cmd/tendant/…`.
Migrations: `db/migrations/`. Flutter: `apps/mobile/`. All paths repo-relative.

---

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 Create the new package skeleton `services/api/internal/calibration/` with a `doc.go` describing the subsystem (one Calibrator, both edges) and the `Calibrator` interface from plan.md Appendix-D (`RecordOutcome`, `FlagBad`, `MaybeProposePromotion`) plus the `RecordBad` system-path method.
- [X] T002 [P] Add the calibration config knobs (env→constants) per research.md R12 in `services/api/internal/calibration/config.go` (`Maturation`, `WindowN`, `Ratio`, `MinSample`, `DemotionDecrement`, `SweepCron`, `IntakeTightenK`) with the documented defaults and a `Config` struct.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user-story work can begin until this phase is complete.

- [X] T003 Write migration `db/migrations/00007_calibration_ratchet.sql` (up+down) per data-model.md: `ALTER tools ADD trust_score double precision NOT NULL DEFAULT 0.5 CHECK(0..1)`; `ALTER tool_outcomes ADD routine_fingerprint text`; `CREATE INDEX idx_outcomes_routine`; `CREATE TABLE tool_routine_grants` + `uq_grant_live` partial unique index.
- [X] T004 Verify the migration applies cleanly on a fresh DB and the down reverts (`just up` / goose down); confirm no change needed to the `audit_messages.task_id` CHECK allowlist or `decision_kind` enum.
- [X] T005 [P] Add the four task-scoped audit kinds to `services/api/internal/lifecycle/audit.go` (`KindOutcomeFlagged`, `KindToolDemoted`, `KindPromotionProposed`, `KindPromotionResponded`) with payload struct types.
- [X] T006 [P] Implement the pure trust-score↔band math in `services/api/internal/calibration/score.go` (`Band(score) AutonomyLevel`, `PromoteTo(band) float`, `Demote(score, decrement) float` clamped at baseline; constants `baseline=0.5`, `autoThreshold=0.8`) per research.md R1/R2.
- [X] T007 [P] Unit-test the score math in `services/api/internal/calibration/score_test.go` (table-driven: band boundaries, NONE only at 0.0, demotion clamp at baseline, promotion jump).
- [X] T008 [P] Implement the pure routine fingerprint in `services/api/internal/calibration/fingerprint.go` (`Fingerprint(toolGlobalURI string, payload json.RawMessage) string`; v1 salient-field mapping for `send-email` = recipient class + attachment presence; documented default for other tools = tool URI + sorted top-level scalar key presence) per research.md R3.
- [X] T009 [P] Unit-test the fingerprint in `services/api/internal/calibration/fingerprint_test.go` (equivalent calls share a fingerprint; a stranger recipient / added attachment differs; determinism).
- [X] T010 Add/edit sqlc queries in `services/api/internal/db/queries/outcomes.sql` and a new `services/api/internal/db/queries/calibration.sql`: revise `InsertToolOutcome` to accept `matured_at` + `routine_fingerprint`; add `MaturedCleanRatioByRoutine`, `LatestMaturedOutcomeForRoutine`, `GetTrustScore`/`SetTrustScore` (with `GetToolForUpdate` lock), `InsertRoutineGrant`/`RevokeRoutineGrant`/`RevokeAllGrantsForTool`/`LiveGrantExists`, `OpenPromotionProposal`, `ToolsActedUnderTask`, `DismissalsByConnector` (per data-model.md).
- [X] T011 Run `just generate` (sqlc) and commit the regenerated `services/api/internal/db/*.sql.go`; confirm CI codegen-drift will pass.

**Checkpoint**: schema, score/fingerprint primitives, queries, audit kinds, config all exist.

---

## Phase 3: User Story 1 — A routine earns autonomy (Priority: P1) 🎯 MVP

**Goal**: Clean matured track record → agent proposes → owner approves → per-tool band rises →
the same routine auto-approves (floor-checked).

**Independent Test**: Drive N clean outcomes of a floor-clearing routine, mature them, run the
sweep → one `PromotionProposal` with evidence; accept → `Tool.rung` becomes `EXECUTE_AUTO`; the
same routine auto-approves while a floor-tripping variant still gates.

- [X] T012 [P] [US1] Implement inferred-clean recording in `services/api/internal/calibration/calibrator.go` `RecordOutcome` (compute `matured_at = at + Maturation`, fingerprint, insert `tool_outcomes` clean) and wire it into the clean-dispatch path of `services/api/internal/toolflow/workflow.go` (replacing the direct `InsertToolOutcome`), preserving the existing audit chain.
- [X] T013 [US1] Implement `MaybeProposePromotion(toolID)` in `calibrator.go`: read `MaturedCleanRatioByRoutine`, gate on `MinSample` + `Ratio`, skip if already granted / open proposal exists / in decline-cooldown (no new matured outcome since last decline), else build the frozen `evidence` payload + `from/to` band.
- [X] T014 [US1] Implement the DBOS-scheduled sweep in `services/api/internal/calibration/sweep.go`: a registered workflow `calibration.sweep` that iterates candidate `(tool, fingerprint)` groups and, per `MaybeProposePromotion`, writes the `pending_decisions(kind='promotion_proposal', tool_id, task_id=<representative>, payload=evidence)` row + `promotion_proposed` audit + `tendant_events` notify + push enqueue (reuse the Phase-2 enqueuer). Add `CreateSweepSchedule`/`ScheduleName` mirroring `internal/intake/scheduler.go`.
- [X] T015 [US1] Wire the sweep schedule creation at boot in `services/api/cmd/tendant/main.go` (after `dbos.Launch`, mirroring `RehydrateSchedules`) using `SweepCron`, and construct + inject the `Calibrator` (pool + config).
- [X] T016 [US1] Implement the owner-only `respondToPromotion(proposalId, accept)` resolver: add to `services/api/graph/schema.graphqls` (per contracts/graphql.v1.graphqls) and implement in `services/api/graph/phase8_helpers.go` — `auth.RequireOwner(ctx)` FIRST; on accept: in one tx set trust score into the proposed band (`SetTrustScore`), `InsertRoutineGrant` with frozen evidence, resolve the `pending_decisions` row, write `promotion_responded` audit, return updated `Tool`; on decline: resolve row + audit, no score change.
- [X] T017 [US1] Register `respondToPromotion` as owner-only in `services/api/graph/auth_registration.go` and run `just generate` (gqlgen) for the new resolver stubs.
- [X] T018 [US1] Make the `PromotionProposal` resolvers real in `services/api/graph/schema.resolvers.go` + `phase2_helpers.go`: `mapPendingDecisionRow` reads `tool_id`, `from_level`/`to_level`, and `evidence` from the row payload; `Tool()` resolves the real tool (replace `phase2PlaceholderTool()`); `Task()` resolves the representative task.
- [X] T019 [US1] Derive `Tool.rung: AutonomyLevel!` from `trust_score` in the Tool resolver/mapper (`graph` mapping for `Tool`), using `calibration.Band`, instead of reading the `rung` text column.
- [X] T020 [US1] Implement the gate autonomy layer: new `services/api/internal/gate/autonomy.go` with a `RoutineGrantLookup` seam (mirrors `PrincipalLookup`) + band check; edit `services/api/internal/gate/gate.go` to consult it **after** the floor and **after** the script terminal verdicts, in the overseer's slot — `Approve` iff band==`EXECUTE_AUTO` AND `grantLookup(toolID, fingerprint(call))` live AND floor cleared, else fall through (research.md R7).
- [X] T021 [US1] Back the `RoutineGrantLookup` seam with `LiveGrantExists` and inject it into the gate construction in `services/api/cmd/tendant/main.go`.
- [X] T022 [P] [US1] Unit-test `MaybeProposePromotion` eligibility in `services/api/internal/calibration/calibrator_test.go` (min-sample gate, ratio threshold, dedupe/cooldown) with a stub queries layer or testcontainers.
- [X] T023 [US1] E2E test in `services/api/internal/calibration/sweep_e2e_test.go` (testcontainers): N clean matured outcomes → sweep emits exactly one `PromotionProposal` with correct evidence; `respondToPromotion(accept:true)` → score in auto band + live grant; subsequent identical call auto-approves (no `pending_decisions` row); decline path leaves score unchanged + cooldown holds.
- [X] T024 [US1] Gate test in `services/api/internal/gate/autonomy_test.go`: EXECUTE_AUTO + live grant + floor-clear → Approve; unfamiliar fingerprint → fall through (gates); EXECUTE_GATED → fall through.
- [X] T025 [P] [US1] Flutter: add a `PromotionProposalCard` to the inbox rendering tool + from/to band + legible evidence and an accept/decline action calling `respondToPromotion`, in `apps/mobile/` (mirror the Phase-4 `OverseerEvaluationCard` pattern).

**Checkpoint**: US1 independently demonstrable (Exit 1).

---

## Phase 4: User Story 2 — Reflexive demotion (Priority: P1)

**Goal**: A bad outcome, `cancelTask`, or `flagOutcome` drops the score automatically (no proposal,
no approval) and revokes the routine grant.

**Independent Test**: With a promoted tool, trigger each of the three paths and confirm immediate
score drop + grant revocation, no `PromotionProposal` involved.

- [X] T026 [US2] Implement reflexive demotion in `services/api/internal/calibration/calibrator.go` (`demote(tx, toolID, taskID, fingerprint, trigger)`): `GetToolForUpdate` lock → `SetTrustScore(Demote(...))` clamped at baseline → `RevokeRoutineGrant` (or `RevokeAllGrantsForTool` when fingerprint is empty/cancel) → `tool_demoted` audit → withdraw any open `promotion_proposal` for the tool (FR-014).
- [X] T027 [US2] Implement `RecordBad` (system path) and route the bad-dispatch branch of `services/api/internal/toolflow/workflow.go` through it (records the `bad` `tool_outcomes` row **then** demotes in the same tx), keeping the existing error-propagation-after-write behavior.
- [X] T028 [US2] Add the `cancelTask` demotion side-effect: in the cancel resolver/path, enumerate `ToolsActedUnderTask(taskID)` and `demote` each (fingerprint empty → revoke all grants for those tools) within the cancel transaction.
- [X] T029 [US2] Implement owner-only `flagOutcome(taskId, toolId, reason)` (`Calibrator.FlagBad`): add to schema per contract; resolver in `phase8_helpers.go` — `auth.RequireOwner` FIRST → record a `bad` outcome + `outcome_flagged` audit + `demote` in one tx → return updated `Tool`; register owner-only in `auth_registration.go`; `just generate`.
- [X] T030 [P] [US2] Unit/e2e test `services/api/internal/calibration/demote_test.go`: each trigger drops score by decrement, clamps at baseline, revokes grant, withdraws open proposal, emits `tool_demoted`; verify no proposal/approval is required and `taskChanged`-observable state changes.

**Checkpoint**: US2 demonstrable (Exit 2) independently of US1's sweep (shares score + Calibrator).

---

## Phase 5: User Story 3 — Retroactive veto on an un-matured action (Priority: P1)

**Goal**: A `flagOutcome` before maturity flips the outcome bad so it never counts toward promotion.

**Independent Test**: Record a clean outcome, flag it within the maturation window, run the sweep →
no proposal on its strength; the flagged row is excluded from the matured-clean tally forever.

- [X] T031 [US3] Confirm the matured-clean predicate (`MaturedCleanRatioByRoutine`) excludes any row whose `outcome='bad'` regardless of `matured_at`, and that `flagOutcome` (T029) flips `outcome` even when `matured_at` is in the future; add a guard/test that pre-existing NULL-`matured_at` rows are treated as never-matured.
- [X] T032 [P] [US3] E2E test `services/api/internal/calibration/maturation_veto_test.go`: clean outcome flagged before `matured_at` → excluded from the ratio → sweep emits no proposal; a separate matured-clean-then-flagged outcome still demotes now but its prior maturation is honest (US3 scenario 3).

**Checkpoint**: US3 demonstrable (Exit 3); proves the inferred-clean honesty.

---

## Phase 6: User Story 4 — The floor is immune (Priority: P1)

**Goal**: No trust score lets a floor-tripping call auto-approve.

**Independent Test**: Promote a tool to `EXECUTE_AUTO`, attempt a floor-tripping call → the gate
returns `RequestDecision` regardless of autonomy.

- [X] T033 [US4] Gate floor-supremacy test `services/api/internal/gate/floor_supremacy_test.go`: with band `EXECUTE_AUTO` + a live grant, a call that trips each floor clause (spend, irreversible_third_party=stranger_recipient, secret_disclosure) still yields `RequestDecision`; assert the autonomy layer is never consulted before the floor (ordering invariant, NFR-002).
- [X] T034 [P] [US4] E2E test extending the US1 e2e: a promoted routine's floor-clearing variant auto-approves but a stranger-recipient variant of the same tool creates an `ApprovalRequest` (SC-004).

**Checkpoint**: US4 demonstrable (Exit 4); the non-negotiable safety bound holds.

---

## Phase 7: User Story 5 — The agent cannot escalate itself (Priority: P1)

**Goal**: `respondToPromotion` (the only autonomy-raising path) is unreachable by an agent identity.

**Independent Test**: As a non-owner principal, call `respondToPromotion` → refused before any DB
write, no autonomy moves.

- [X] T035 [US5] Verify/lock the owner-only guard on `respondToPromotion` (`auth.RequireOwner` is the FIRST statement, before any query) and that it is registered owner-only in `auth_registration.go`; assert there is no other resolver/path that writes `trust_score` upward or inserts a grant.
- [X] T036 [P] [US5] E2E test `services/api/graph/respond_promotion_authz_test.go`: an agent (`Principal.Kind != "user"`) calling `respondToPromotion` gets `PERMISSION_DENIED` with no `tool_routine_grants` row and unchanged `trust_score`; the owner principal succeeds (NFR-004/SC-005).

**Checkpoint**: US5 demonstrable; the prohibited move is structurally closed.

---

## Phase 8: User Story 6 — Intake dismissals tune what gets proposed (Priority: P2)

**Goal**: The same subsystem reads dismissals to tighten effective thresholds and feed triage as
labeled evidence.

**Independent Test**: Dismiss several items from a source; a comparable later item holds `PROPOSED`
where it previously auto-accepted, and triage receives the dismissal history as labeled evidence.

- [X] T037 [US6] Implement effective-threshold tightening in `services/api/internal/calibration/intake.go`: `EffectiveThresholds(connectorID, base)` = `base ± IntakeTightenK * f(recent dismissal count)` (bounded), backed by `DismissalsByConnector` (research.md R9).
- [X] T038 [US6] Wire effective thresholds into `services/api/internal/intake/disposition.go` `richEvent()` dial (replace direct `rules.ConfidenceFloor`/`StakesCeiling` with the calibration-adjusted values), keeping the conservative fail-closed defaults when no dismissals exist.
- [X] T039 [US6] Build the `[DISMISSAL_HISTORY]` reader: collect recent dismissal reasons per connector and pass them as a labeled section to the `TriageJudge` (extend the triage input struct in `internal/intake/triage.go`), reusing the Phase-4/5 labeled-slot discipline (evidence, never instruction).
- [X] T040 [P] [US6] E2E test `services/api/internal/calibration/intake_tuning_test.go`: after N dismissals from a connector, a previously-auto-accepting `rich_event` holds `PROPOSED`; and the triage seam receives `[DISMISSAL_HISTORY]` (assert via a stub `TriageJudge`).
- [X] T041 [P] [US6] Flutter: surface the demotion/grant/autonomy state on the existing `ToolDetailPage` (read-only) so reflexive demotion and live grants are visible (FR-018), in `apps/mobile/`.

**Checkpoint**: US6 demonstrable (Exit 5); the loop's intake half is wired.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [X] T042 [P] Add the `/healthz` calibration block (`proposals_emitted_per_minute`, `demotions_per_minute`, `outcomes_matured_per_minute`, `maturation_window`, `open_proposals`) in `services/api/internal/server/healthz.go` + a `calibration.Metrics` roller in `services/api/internal/calibration/metrics.go` (mirror `intake/metrics.go`); wire counters at proposal/demotion/maturation sites (research.md R13).
- [X] T043 [P] Apply the `@deprecated` directive to `decidePromotion` in `services/api/graph/schema.graphqls` per contracts/graphql.v1.graphqls (Path 2) and confirm the stub still returns `NOT_YET_AVAILABLE`; `just generate`.
- [X] T044 [P] Concurrency test: two near-simultaneous outcomes for the same tool serialize via `GetToolForUpdate` (no lost score update) — `services/api/internal/calibration/concurrency_test.go` (spec edge case).
- [X] T045 [P] Document the new env knobs (R12) and the `decidePromotion`→`respondToPromotion` migration in the repo docs / `cmd/tendant` config comments; update the PR-template contract-path checkbox (Path 1 + Path 2).
- [X] T046 Run `go build ./...` + `go test -race ./...` across all API packages (with and without external deps), `golangci-lint`, and the codegen-drift check; fix any failures.
- [ ] T047 Execute `specs/009-calibration-autonomy-ratchet/quickstart.md` end-to-end against a running core (`make up` with demo knobs) and confirm all five exit criteria + the self-escalation check pass.

---

## Dependencies & Execution Order

- **Setup (T001–T002)** → **Foundational (T003–T011)** block everything.
- **US1 (T012–T025)** is the MVP backbone; T013/T014 depend on T010 queries + T006 score + T008 fingerprint; T020/T021 (gate) depend on T008 + T010.
- **US2 (T026–T030)** needs Foundational + the Calibrator/score (T006, T026 reuses T010 grants/score queries); largely parallel to US1's sweep but T026 shares `calibrator.go` with T012/T013 (sequence within the file).
- **US3 (T031–T032)** needs T029 (`flagOutcome`, in US2) + T013 eligibility (US1).
- **US4 (T033–T034)** needs T020 (gate layer, US1).
- **US5 (T035–T036)** needs T016 (`respondToPromotion`, US1).
- **US6 (T037–T041)** needs Foundational only (independent of the execution edge) — can run in parallel with US1–US5.
- **Polish (T042–T047)** last.

## Parallel Opportunities

- Foundational: T005, T006/T007, T008/T009 run in parallel (distinct files); T010→T011 sequence.
- US1: T022, T025 [P] alongside the implementation; T012 vs T020 touch different files.
- Across stories after Foundational: **US6 (T037–T041)** is fully parallel to the execution-edge stories.
- Polish: T042–T045 are all [P].

## Implementation Strategy

- **MVP = Foundational + US1** (T001–T025): a routine earns autonomy and auto-approves, floor-checked.
- **Safety increment = US2 + US4 + US5** (demotion, floor immunity, no self-escalation) — ship before relying on auto-approval in anger.
- **Honesty increment = US3** (maturation veto).
- **Loop closure = US6** (intake half).
- Each story is independently testable per its checkpoint; deliver incrementally.

## Notes

- All new owner mutations call `auth.RequireOwner(ctx)` as the FIRST statement (Constitution IV).
- The gate stays pure (no direct DB) — the grant lookup is an injected seam (Constitution IX).
- Calibration reads only recorded, matured outcomes (NFR-003); every move writes an audit DAG row.
- One migration (`00007`), zero new dependencies, no CHECK-allowlist change.
