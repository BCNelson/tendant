# Tasks: The Intake Edge (Connectors & Dispositions)

**Input**: Design documents from `/specs/008-intake-edge-connectors/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: INCLUDED. The codebase is test-driven (table-driven `t.Run`, `go test -race`,
testcontainers-go). The quickstart defines a CI test surface and the SCs are framed as verifiable,
so each story carries test tasks. Connector live calls are faked behind the Provider seam so the
suite is green with no external services / no credentials.

**Organization**: Tasks are grouped by user story (P1 first). Each story is an independently testable
increment. `[P]` = parallelizable (different files, no incomplete-task dependency).

## Path Conventions

Go workspace module `services/api` (`github.com/bcnelson/tendant/services/api`), `db` module for
migrations, Flutter at `apps/mobile`. All paths below are repo-relative.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Package skeletons, the one migration, and audit-kind constants every story uses.

- [X] T001 [P] Create `services/api/internal/intake/` package skeleton (`doc.go` describing the in-edge: contract + disposition router + idempotent ingest + scheduler glue)
- [X] T002 [P] Create `services/api/internal/connector/` package skeleton (`doc.go` describing the trusted connector seam, mirroring `internal/push`)
- [X] T003 [P] Write migration `db/migrations/00006_intake_audit_kinds.sql`: extend the Phase-5 `audit_messages.task_id`-NULL CHECK allowlist with `signal_emitted`, `signal_deduped`, `llm_judge_capped`; add partial index `intake_signals(connector_id) WHERE processed_at IS NULL` (goose up/down)
- [X] T004 [P] Add 6 intake audit-kind constants to `services/api/internal/lifecycle/audit.go` (`KindSignalEmitted`, `KindSignalDeduped`, `KindDispositionApplied`, `KindIntakeAutoAccepted`, `KindLLMJudgeInvoked`, `KindLLMJudgeCapped`)
- [X] T005 Run `just generate` and confirm migration applies cleanly against a testcontainer (no codegen drift yet — schema unchanged beyond CHECK/index)

**Checkpoint**: Packages exist, migration applies, audit kinds defined.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The contract, the trusted seam, idempotent persistence, signal→task creation, and the
disposition dispatcher skeleton — everything every story builds on.

**⚠️ CRITICAL**: No user-story work begins until this phase is complete.

- [X] T006 [P] Define the `intake.v1` contract in `services/api/internal/intake/signal.go`: `PotentialTaskSignal`, `Provenance`, `const SignalVersion = "intake.v1"`, per [contracts/signal.v1.md](./contracts/signal.v1.md)
- [X] T007 [P] Define the trusted `Connector` interface + `ConnectorConfig` struct in `services/api/internal/connector/connector.go` (`Type()`, `Run(ctx, cfg, emit)`)
- [X] T008 Implement the `Registry` (type→factory map + base-set registration entry points) in `services/api/internal/connector/registry.go`
- [X] T009 [P] Write `services/api/internal/db/queries/intake_signals.sql`: idempotent insert (`INSERT ... ON CONFLICT (connector_id, idempotency_key) DO NOTHING RETURNING id`), `MarkSignalProcessed`, `GetUnprocessedSignals`
- [X] T010 [P] Write `services/api/internal/db/queries/connectors.sql`: `connector_configs` upsert/get/list, `source_credentials` upsert/get
- [X] T011 Run `just generate` (sqlc) and verify generated methods compile (`go build ./...`)
- [X] T012 Implement idempotent ingest in `services/api/internal/intake/ingest.go`: persist signal via the `ON CONFLICT` query; on dedupe write `signal_deduped` audit and return no-op; on insert write `signal_emitted` audit
- [X] T013 Implement `CreateTaskFromSignal(ctx, pool, dctx, signal, state)` in `services/api/internal/core/task.go`: insert task with `provenance` + `intake_signal_id`, optionally `AttachChainWorkflow`
- [X] T014 Implement the disposition dispatcher skeleton in `services/api/internal/intake/disposition.go`: `switch disposition { forced_task | rich_event | llm_judge }` with branch stubs + `disposition_applied` audit hook (validates `confidence`/`stakes_hint` presence+range for `rich_event`, fail-closed)
- [X] T015 [P] Implement credential seal/open + refresh seam in `services/api/internal/intake/credentials.go` using `internal/crypto.Seal`/`Open` and `source_credentials` (token bundle JSON; refresh-when-near-expiry stub)

**Checkpoint**: An emitted signal persists idempotently, dedupes, and can become a task — disposition
branches are stubbed and ready for per-story behavior.

---

## Phase 3: User Story 1 — A flagged item becomes a task, no typing (Priority: P1) 🎯 MVP

**Goal**: A connector flags an item `forced_task`; on a scheduled poll it becomes a task directly,
skips the is-task judgment, runs the chain, and surfaces on the operator edge with provenance.

**Independent Test**: With a seeded enabled connector and a `forced_task` rule on a known item, run a
poll and confirm exactly one task is created (`state=accepted`), its `provenance` references the source
item, and it appears in `tasks(state: ACCEPTED)` — no model invoked.

### Implementation

- [X] T016 [US1] Implement the `forced_task` branch in `services/api/internal/intake/disposition.go`: `CreateTaskFromSignal(state=accepted)`, skip is-task, attach chain, write `disposition_applied`
- [X] T017 [P] [US1] Implement the `webhook-in` connector (zero-credential) in `services/api/internal/connector/webhook.go` (`Run` consumes queued inbound items → `emit`)
- [X] T018 [P] [US1] Implement the `rss` connector (zero-credential) in `services/api/internal/connector/rss.go` using stdlib `encoding/xml` (feed fetch via an injectable `httpDoer` seam; idempotency key = feed item GUID)
- [X] T019 [P] [US1] Register `calendar` and `imap` as `LogProvider`-style **stub** connectors (emit nothing) in `services/api/internal/connector/{calendar.go,imap.go}` — completes the base-set registration
- [X] T020 [US1] Implement the per-connector poll workflow body in `services/api/internal/intake/poll.go`: load config+creds → `connector.Run(emit=ingest→dispose)` with DBOS-memoized per-item steps
- [X] T021 [US1] Implement scheduler glue in `services/api/internal/intake/scheduler.go`: `CreateSchedule("intake:<id>", cron, WithScheduleContext(id))` / `DeleteSchedule` (rejects blank/invalid cron)
- [X] T022 [US1] Register the intake scheduled workflow + rehydrate a schedule for every enabled connector on boot in `services/api/cmd/tendant/main.go` (after `dbos.Launch`)
- [X] T023 [P] [US1] Seed an example enabled connector (`rss` or `webhook-in`) in `services/api/internal/core/seed_catalog.go` (or a new `seed_connectors.go`) so US1–US3 demo without the owner mutations
- [X] T024 [US1] Implement the `gmail` OAuth-exemplar connector in `services/api/internal/connector/gmail.go`: list/get over stdlib `net/http`, live call behind a `messageFetcher` seam; refresh via `credentials.go`
- [X] T025 [US1] Add the `/oauth/callback/<connectorType>` chi route + consent-URL helper in `services/api/internal/server/` (code exchange over `net/http` → `crypto.Seal` → `source_credentials` upsert)
- [X] T026 [P] [US1] Flutter: add `ProvenanceCard` to the task-detail page in `apps/mobile/lib/.../task/` rendering `Task.provenance` (`raw_ref` + `reason`)

### Tests for User Story 1

- [X] T027 [P] [US1] Unit test the `forced_task` branch in `services/api/internal/intake/disposition_test.go` (creates accepted task, no model call, provenance set)
- [X] T028 [P] [US1] E2E test: `rss` fixture feed → poll → one `accepted` task with provenance, in `services/api/internal/connector/rss_test.go`
- [X] T029 [P] [US1] E2E test: `webhook-in` inbound item → poll → one `accepted` task, in `services/api/internal/connector/webhook_test.go`
- [X] T030 [P] [US1] Unit test the `gmail` connector with a faked `messageFetcher` (list/get → emit) in `services/api/internal/connector/gmail_test.go`

**Checkpoint**: A flagged item becomes a task with no typing, end-to-end, in CI without external services.

---

## Phase 4: User Story 2 — Confident + low-stakes event auto-accepts, arrives enriched (Priority: P1)

**Goal**: A `rich_event` clearing both the confidence floor and the stakes ceiling auto-accepts as a
dismissible **enrich-only** task that has run expansion before the owner sees it; failing either axis
holds `PROPOSED`.

**Independent Test**: Emit a `rich_event{conf=0.92, stakes=0.10}` → task auto-accepts, `autonomy` reads
`enrich-only`, `current_stage` is past expansion, and it is dismissible. Emit `{conf=0.92, stakes=0.55}`
→ held `PROPOSED`.

### Implementation

- [X] T031 [US2] Implement the `rich_event` dial in `services/api/internal/intake/disposition.go`: auto-accept iff `confidence ≥ confidence_floor` AND `stakes_hint ≤ stakes_ceiling` (floats `0.0–1.0`, thresholds from `disposition_rules`, conservative defaults); else `PROPOSED`; missing/out-of-range ⇒ fail-closed `PROPOSED`; write `intake_auto_accepted` on auto-accept
- [X] T032 [US2] Relax `services/api/internal/lifecycle/edges.go` to permit `accepted → dismissed` for intake-origin tasks (`intake_signal_id IS NOT NULL`)
- [X] T033 [US2] Route EXECUTION to the owner (human slot) for enrich-only intake tasks in `services/api/internal/chain/` (router/workflow) so an auto-accepted task halts for sign-off after expansion
- [X] T034 [US2] Implement `Task.autonomy = ENRICH_ONLY` derivation for intake-origin auto-accepted tasks in the Phase-6 autonomy resolver (`services/api/graph/` + any `internal/lifecycle` autonomy helper)
- [X] T035 [US2] Ensure `dismissProposedTask` resolver records the reason for enrich-only intake tasks (reuse Phase-2 path; verify the relaxed edge is honored)

### Tests for User Story 2

- [X] T036 [P] [US2] Table-driven dial test in `services/api/internal/intake/disposition_test.go`: both-axes truth table (clear/clear, clear/fail, fail/clear, fail/fail) + missing/out-of-range fail-closed
- [X] T037 [P] [US2] Lifecycle test in `services/api/internal/lifecycle/edges_test.go`: `accepted→dismissed` allowed for intake-origin, rejected for owner-authored
- [X] T038 [US2] Integration test: auto-accepted task runs through expansion and halts at owner sign-off; `dismissProposedTask` records reason (in `services/api/internal/chain/` or a graph e2e test)

**Checkpoint**: Auto-accept (both axes) yields a dismissible, already-enriched enrich-only task; single-axis holds PROPOSED.

---

## Phase 5: User Story 3 — Ambiguous item judged by the LLM, lands PROPOSED (Priority: P1)

**Goal**: `llm_judge` hands only the normalized payload to triage's LLM (is-task/shape/stakes), lands
`PROPOSED`, the model is invoked only for `llm_judge` items, and a per-poll cap bounds fan-out.

**Independent Test**: Emit `llm_judge` → triage model invoked once, task `PROPOSED`. In a mixed batch,
`forced_task`/`rich_event` invoke no model. Exceed the per-poll cap → overflow held `PROPOSED`, no model call.

### Implementation

- [X] T039 [US3] Implement the `llm_judge` branch in `services/api/internal/intake/disposition.go`: create `PROPOSED` task, hand normalized `payload` to the Phase-6 triage agent as a labeled `[INTAKE_SIGNAL]` evidence slot; write `llm_judge_invoked`; on is-task=false mark processed + no surfaced task (audited)
- [X] T040 [US3] Add the `[INTAKE_SIGNAL]` labeled section to the triage agent prompt assembly (Phase-6 `internal/agent` prompt builder) — evidence-not-instruction (Principle IV)
- [X] T041 [US3] Implement the per-poll `llm_judge` cap in `services/api/internal/intake/poll.go`: count forwarded `llm_judge` items vs `disposition_rules.llm_judge_per_poll` (conservative default 5); overflow ⇒ `PROPOSED` with no model call + `llm_judge_capped` audit

### Tests for User Story 3

- [X] T042 [P] [US3] Unit test: `llm_judge` invokes the (faked) triage model exactly once and lands `PROPOSED`, in `services/api/internal/intake/disposition_test.go`
- [X] T043 [P] [US3] Mixed-batch test: only `llm_judge` items invoke the model; `forced_task`/`rich_event` invoke none (assert call count on a faked model client)
- [X] T044 [P] [US3] Cap test: a poll exceeding `llm_judge_per_poll` invokes the model ≤ cap times; overflow held `PROPOSED` with `llm_judge_capped` audit, in `services/api/internal/intake/poll_test.go`

**Checkpoint**: `llm_judge` is the bounded, opt-in model path; the firewall holds.

---

## Phase 6: User Story 4 — Same item twice produces one task (Priority: P1)

**Goal**: A re-emitted `(connector_id, idempotency_key)` is a no-op — one signal, one task.

**Independent Test**: Emit the same item across two polls → exactly one `intake_signals` row and one task;
a `signal_deduped` audit on the second.

### Tests / Verification

- [X] T045 [US4] Integration test: emit identical `(connector_id, idempotency_key)` twice across two poll runs → 1 signal row, 1 task, `signal_deduped` audit on the second, in `services/api/internal/intake/ingest_test.go`
- [X] T046 [P] [US4] Unit test the `ON CONFLICT DO NOTHING` ingest path (empty RETURNING ⇒ dedupe branch) in `services/api/internal/intake/ingest_test.go`
- [X] T047 [US4] Verify a duplicate webhook delivery and an unchanged RSS item across polls both dedupe (extend `rss_test.go`/`webhook_test.go`)

**Checkpoint**: Self-duplication is impossible; polling is safe to repeat. (Implementation already landed in Foundational T012 — this story proves it.)

---

## Phase 7: User Story 5 — Killing the box mid-poll resumes cleanly (Priority: P2)

**Goal**: A poll killed mid-flight resumes on restart with no double-emit and no drops.

**Independent Test**: Start a multi-item poll, `kill -9` mid-emit, restart → resumed workflow yields the
same task set as an uninterrupted run.

### Implementation

- [X] T048 [US5] Ensure each per-item emit in `services/api/internal/intake/poll.go` is a discrete DBOS-memoized step (idempotent on replay) and the poll workflow is recovery-deterministic
- [X] T049 [US5] Confirm boot rehydration (T022) re-creates the schedule and `dbos.Launch` recovers an in-flight poll workflow

### Tests for User Story 5

- [X] T050 [US5] Crash-recovery integration test (testcontainers): emit N items, interrupt mid-poll, restart, assert exactly N tasks (no dupes/drops), in `services/api/internal/intake/poll_recovery_test.go` (or extend `scripts/dbos-recovery-demo.sh`)

**Checkpoint**: Durability + idempotency hold across a hard kill.

---

## Phase 8: User Story 6 — Owner configures and toggles a connector (Priority: P2)

**Goal**: Owner-only `setConnectorConfig` / `enableConnector` and an owner-only `connectors` query;
non-owners are refused before any DB access.

**Independent Test**: As owner, set a config and toggle enabled (schedule created/deleted); a non-owner
is refused all three operations.

### Implementation

- [X] T051 [US6] Add the additive GraphQL surface to `services/api/graph/schema.graphqls`: `type Connector`, `Query.connectors`, `Mutation.setConnectorConfig`, `Mutation.enableConnector` (per [contracts/graphql.v1.graphqls](./contracts/graphql.v1.graphqls))
- [X] T052 [US6] Run `just generate` (gqlgen) and wire models in `services/api/gqlgen.yml` if needed; confirm no codegen drift
- [X] T053 [US6] Implement resolvers in `services/api/graph/connector.resolvers.go`: `auth.RequireOwner(ctx)` FIRST on all three; validate `connector_type` against the registry; require a valid cron `schedule` to enable
- [X] T054 [US6] Wire `enableConnector(true)` → `scheduler.CreateSchedule`, `enableConnector(false)` → `scheduler.DeleteSchedule`; `setConnectorConfig` upserts `connector_configs`
- [X] T055 [P] [US6] Flutter: add an owner-only Connectors settings list (`connectors` query + enable/disable + config edit) in `apps/mobile/lib/.../settings/connectors/`

### Tests for User Story 6

- [X] T056 [P] [US6] Owner-guard e2e: non-owner principal is refused `connectors`, `setConnectorConfig`, `enableConnector` with `PERMISSION_DENIED` before any DB access, in `services/api/graph/connector_resolvers_test.go`
- [X] T057 [P] [US6] Test: `enableConnector(true)` with a valid cron creates schedule `intake:<id>`; `(false)` deletes it; blank/invalid cron is rejected
- [X] T058 [P] [US6] Test: `setConnectorConfig` with an unregistered `connector_type` is rejected; valid config persists

**Checkpoint**: The owner fully controls integrations; all three operations are owner-gated.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [X] T059 [P] Add `intake.signals_emitted_per_minute` (and dedupe/cap counters) to `/healthz` in `services/api/internal/server/` (observability parity with the Phase-4 overseer rate field)
- [X] T060 [P] Document the `imap` deferral + future dep-approval note in `services/api/internal/connector/imap.go` header and `research.md` cross-reference
- [X] T061 [P] Run `just lint` (per-module golangci-lint) and `govulncheck` clean
- [X] T062 [P] Update the root README / connector authoring note: "a new source is one file in `internal/connector` + a registry entry" (Principle I made concrete)
- [X] T063 Walk the [quickstart.md](./quickstart.md) end-to-end against `make up` (SC-001…SC-009 spot-check) and tick the PR template **Path 1 (additive)** for the `intake.v1` signal contract + GraphQL delta
- [X] T064 Final `just test` (all modules, `-race`) green with and without credentials/external services

---

## Dependencies & Execution Order

**Phase order**: Setup (P1) → Foundational (P2) → US1 (P3) → US2/US3/US4 (P4–6) → US5/US6 (P7–8) → Polish (P9).

**Hard dependencies**:
- Everything depends on **Foundational** (T006–T015), which depends on **Setup** (T001–T005).
- **US1** establishes the poll workflow (T020) + scheduler (T021) + boot rehydrate (T022) that **US5**
  (durability) and **US6** (enable/disable) extend.
- **US2/US3/US4** depend only on Foundational + the disposition dispatcher (T014); they touch different
  branches of `disposition.go` so are sequential on that file but otherwise independent.
- **US4** is mostly *verification* of Foundational T012 (ingest idempotency) — its tasks are tests.
- **US6** depends on US1's `scheduler.go` (T021) for the enable/disable wiring.

**Story independence**: US1 is a complete MVP on its own. US2, US3 add disposition branches; US4 proves
idempotency; US5 proves durability; US6 adds the owner control surface. Each is independently testable.

## Parallel Execution Examples

- **Setup**: T001, T002, T003, T004 in parallel (different files) → then T005.
- **Foundational**: T006, T007, T009, T010, T015 in parallel; then T008/T011/T012/T013/T014 (T012–T014 share `intake/` files, sequence them; T011 after the `.sql` files).
- **US1 connectors**: T017, T018, T019 in parallel (separate files); tests T027–T030 in parallel after their impls.
- **US2 tests**: T036, T037 in parallel.
- **US3 tests**: T042, T043, T044 in parallel.
- **US6 tests**: T056, T057, T058 in parallel.
- **Polish**: T059, T060, T061, T062 in parallel → T063 → T064.

## Implementation Strategy

- **MVP = Phase 1 + Phase 2 + US1.** Delivers the headline ("a flagged item becomes a task, no typing")
  end-to-end with the two zero-credential connectors + the Gmail OAuth exemplar.
- **Increment 2 = US2 + US3 + US4** — the full disposition firewall (auto-accept, llm_judge cap, idempotency).
- **Increment 3 = US5 + US6** — durability proof + the owner control surface.
- **Finish with Polish** — observability, lint/vuln, quickstart walk, contract-path sign-off.

## Notes

- **One migration only** (T003) — every other piece of state rides Phase-0-reserved columns +
  `audit_messages.payload jsonb`.
- **Zero new dependencies** — stdlib `net/http`/`encoding/xml`/`net/mail`; `robfig/cron` is transitive
  via DBOS. The lone exception (a real IMAP client) ships as a stub (T019/T060), flagged for future approval.
- **Privacy invariant (NFR-001)**: only `llm_judge` ever forwards a payload to a model — assert this in
  T043 (no model call for forced/rich).
- **Owner-guard discipline**: `auth.RequireOwner(ctx)` FIRST in every Phase-8 resolver (T053), proven by T056.
