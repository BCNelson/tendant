---
description: "Task list — Phase 0: Foundations & Scaffolding"
---

# Tasks: Phase 0 — Foundations & Scaffolding

**Input**: Design documents from `specs/001-foundations-scaffolding/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/graphql.v1.graphqls, quickstart.md

**Tests**: INCLUDED — the spec requests them (FR-017, SC-005, and a per-story Independent Test).

**Organization**: tasks grouped by user story. P1 stories (US1 boot+migrate, US2 create+read)
are the MVP. Most work in this phase is shared foundation; the stories are the verifiable
increments on top.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no incomplete-task deps)
- **[Story]**: US1–US5 (user-story phases only)
- Module roots: `db/` = `github.com/bcnelson/tendant/db`; `services/api/` = `github.com/bcnelson/tendant/services/api`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: establish the `go.work` workspace, the toolchain bump, and tool configs.

- [ ] T001 Restructure into a `go.work` workspace: create `/go.work` (`use ./services/api`, `use ./db`); create module `db` (`/db/go.mod` module `github.com/bcnelson/tendant/db`); create module `services/api` (`/services/api/go.mod` module `github.com/bcnelson/tendant/services/api`); move existing `/cmd`, `/internal`, `/main_test.go` into `/services/api/` and rewrite imports to `github.com/bcnelson/tendant/services/api/...`; remove the old root `/go.mod`.
- [ ] T002 In `/services/api/go.mod` set `go 1.25`; add `github.com/go-chi/chi/v5`, `github.com/99designs/gqlgen`, `github.com/pressly/goose/v3`, `github.com/dbos-inc/dbos-transact-golang`, `github.com/google/uuid`; raise `github.com/jackc/pgx/v5` to v5.9.1 and `github.com/testcontainers/testcontainers-go`(+`/modules/postgres`) to v0.39.0; run `go work sync` then `go mod tidy` in `/services/api` and `/db`. (See [[dep-testcontainers-docker-dbos-coupling]].)
- [ ] T003 [P] Bump the toolchain everywhere: `/devenv.nix` Go → 1.25; `/Dockerfile` builder image → `golang:1.25`; confirm `/.github/workflows/ci.yml` `setup-go` uses `go-version-file: go.mod`.
- [ ] T004 [P] Add `/compose.yaml`: one `postgres` service (`pgvector/pgvector:pg16`), database `tendant`, port 5432, `pg_isready` healthcheck.
- [ ] T005 [P] Add `/services/api/sqlc.yaml`: version "2", engine postgresql, `queries: internal/db/queries`, `schema: ../../db/migrations`, `sql_package: pgx/v5`, out `internal/db` pkg `db`, `emit_json_tags`/`emit_pointers_for_null_types`, overrides `uuid→github.com/google/uuid.UUID`, `jsonb→encoding/json.RawMessage`, `timestamptz→time.Time`.
- [ ] T006 [P] Add `/services/api/gqlgen.yml`: schema `graph/*.graphqls`, exec `graph/generated.go`, model pkg `graph/model`, resolvers follow-schema in `graph/`, scalar binds `Time→github.com/99designs/gqlgen/graphql.Time`, `JSON→github.com/99designs/gqlgen/graphql.Map`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: the data spine, codegen, pool, and a bootable (migrate→seed→serve) core. **⚠️ Blocks all user stories.**

- [ ] T007 Author `/db/migrations/00001_v2_ddl_spine.sql` — the full Appendix A DDL from data-model.md: 8 enums, 14 tables in FK order (`principals`→…→`device_tokens`), indexes incl. partial-unique `idx_chainwf_task_live ... WHERE ended_at IS NULL`, `notify_event(topic,id)` + `trg_pending_notify`/`trg_assign_notify` (each plpgsql body wrapped in `-- +goose StatementBegin/StatementEnd`), and both `AFTER INSERT` triggers; with a complete `-- +goose Down` dropping triggers→functions→tables(reverse)→types. (No `autonomy` column on `tasks`.)
- [ ] T008 [P] Add `/db/embed.go`: `//go:embed migrations/*.sql` → `var Migrations embed.FS`.
- [ ] T009 Add sqlc queries in `/services/api/internal/db/queries/` — `principals.sql` (UpsertOwner, GetViewer), `tasks.sql` (CreateTask, GetTask, ListTasks keyset), `inbox.sql` (InsertPendingDecision, InsertAgentAssignment); then `sqlc generate` and commit `/services/api/internal/db/*.go`. (Depends T005, T007.)
- [ ] T010 [P] Add `/services/api/internal/server/config.go` + pool: load `DATABASE_URL`, open a `*pgxpool.Pool`, expose a `Close()`.
- [ ] T011 [P] Add `/services/api/internal/core/globaluri.go` (`local://task/<id>`, `local://principal/<id>` helpers) and `/services/api/internal/core/seed.go` (idempotent owner-Principal upsert via sqlc `UpsertOwner`).
- [ ] T012 [P] Add `/services/api/graph/schema.graphqls` (copy contracts/graphql.v1.graphqls: scalars, enums, Principal/User/Bot, Task, TaskEdge, TaskConnection, PageInfo, Query viewer/task/tasks); run `gqlgen generate` and commit `/services/api/graph/generated.go`, `graph/model/*`, resolver stubs. (Depends T006.)
- [ ] T013 Add `/services/api/internal/server/server.go`: chi router; mount gqlgen handler at `/graphql` (`handler.New` + `transport.POST/GET/Options` + LRU query cache + dev `extension.Introspection`); `/playground`; `/healthz` (pool ping). Resolver root struct holds `*db.Queries`/`*pgxpool.Pool` (no package-level state). (Depends T010, T012.)
- [ ] T014 [P] Add `/services/api/internal/db/migrate.go`: `Migrate(ctx)` using `goose.SetBaseFS(dbmod.Migrations)`, `goose.SetDialect("postgres")`, `goose.Up(sql.Open("pgx", dsn), "migrations")` (pgx stdlib driver). (Depends T008.)
- [ ] T015 Add `/services/api/cmd/tendant/main.go` boot sequence: load config → open pool → `Migrate` → seed owner → build server → `ListenAndServe` with graceful `http.Server.Shutdown`. (Depends T010, T011, T013, T014.)

**Checkpoint**: `go run ./services/api/cmd/tendant` boots, migrates, seeds, serves `/graphql` + `/healthz`.

---

## Phase 3: User Story 1 - Boot + migrate + idempotent up/down (Priority: P1) 🎯 MVP

**Goal**: one command boots core + Postgres with the full schema applied; `down`/`up` is idempotent; core reports healthy.

**Independent Test**: `make up` → `/healthz` 200 and all enums/tables/`notify_event` exist; `make down && make up` succeeds with identical schema.

- [ ] T016 [P] [US1] Add `just up`/`just down` recipes to `/justfile` and a root `/Makefile` shim (`up`/`down`/`test`/`generate` → `just`); `up` starts Postgres (`docker compose up -d postgres`, or the in-shell devenv service) then runs the core; `down` stops the core and tears down the compose volume so the next `up` re-migrates clean (SC-001).
- [ ] T017 [P] [US1] Add `/services/api/internal/db/migrate_test.go` (testcontainers Postgres): run `Migrate`; assert the 8 enums + 14 tables + `notify_event` exist; run `Migrate` again → no error (restart no-op / idempotency).

**Checkpoint**: MVP-A — the system boots and migrates idempotently with one command.

---

## Phase 4: User Story 2 - Create + read a Task over GraphQL (Priority: P1)

**Goal**: create a Task (+ seeded owner Principal); read it via `task(id)`, `tasks`, and `viewer`, each carrying `globalUri`; `Task.autonomy` is a resolved readout.

**Independent Test**: create a Task, run GraphQL `viewer`/`task(id)`/`tasks` → globalUri non-empty, `state=ELIGIBLE`, `currentStage=CREATION`, `autonomy` non-null.

- [ ] T018 [US2] Implement `/services/api/internal/core/task.go` `CreateTask(ctx, title, desc)` (sets `global_uri=local://task/<uuid>` via sqlc `CreateTask`); add a `seed-task` path — a `cmd/tendant` `seed` subcommand or a `just seed-task` helper. (Depends T009, T011.)
- [ ] T019 [US2] Implement resolvers in `/services/api/graph/*.resolvers.go`: `viewer`→owner `User`; `task(id)`→`GetTask`; `tasks(first,after,state)`→keyset `TaskConnection` (fetch `first+1`, build edges/cursors/`PageInfo`); map sqlc rows → gqlgen models. (Depends T012, T009.)
- [ ] T020 [P] [US2] Implement `Task.autonomy` computed resolver (Phase 0 fixed default `NONE` per data-model.md) and `Task.globalUri`/field mappers in `/services/api/graph/task.resolvers.go`; `Task.workflow` resolver returns `nil` this phase (no chain workflow attaches in Phase 0).
- [ ] T021 [P] [US2] Add `/services/api/graph/task_integration_test.go` (testcontainers Postgres): boot pool+migrate+seed, `CreateTask`, execute GraphQL `viewer`+`task(id)`+`tasks` through the gqlgen handler; assert globalUri, defaults, and non-null autonomy.

**Checkpoint**: MVP complete — create + query a Task over GraphQL (the phase headline).

---

## Phase 5: User Story 3 - IDs-only pg_notify on inbox inserts (Priority: P2)

**Goal**: inserting `pending_decisions`/`agent_assignments` fires one IDs-only `pg_notify` on `tendant_events`.

**Independent Test**: `LISTEN tendant_events`; insert each row type → one notification `{topic, data:{id}}` with no row content.

- [ ] T022 [US3] Add `/services/api/internal/db/notify_test.go` (testcontainers Postgres): seed a task; on a pgx conn `LISTEN tendant_events`; insert `pending_decisions` → assert one payload `{"topic":"decision","data":{"id":...}}` and no other fields; insert `agent_assignments` → assert `topic="assignment"`, id-only. (Triggers ship in T007.)

**Checkpoint**: the transition-notify seam is verified IDs-only (8 KB cap respected).

---

## Phase 6: User Story 4 - DBOS workflow survives a forced restart (Priority: P2)

**Goal**: a throwaway durable workflow resumes exactly once after `kill -9` + restart.

**Independent Test**: run `cmd/dbosdemo`, `kill -9` mid-sleep, restart → "checkpoint A" logged once, "resumed" appears, workflow → SUCCESS.

- [ ] T023 [US4] Add `/services/api/internal/durable/dbos.go`: `Init(ctx, pool)` via `dbos.NewDBOSContext(ctx, dbos.Config{AppName:"tendant", SystemDBPool: pool, DatabaseSchema:"dbos"})`, register workflows, `dbos.Launch`; expose `Shutdown(timeout)`. (Depends T010.)
- [ ] T024 [US4] Add the throwaway workflow + `/services/api/cmd/dbosdemo/main.go`: workflow = step "checkpoint A" (logs once via `RunAsStep`) → `dbos.Sleep(ctx, 60s)` → log "resumed"; launch with `WithWorkflowID("demo-1")`. (Depends T023.)
- [ ] T025 [US4] Wire DBOS `Init`/`Launch` + `defer Shutdown` into `/services/api/cmd/tendant/main.go` after seed, before serve (startup order in plan.md). `Launch` returning nil is the DBOS readiness signal (satisfies FR-012 / US4-AC1). (Depends T015, T023.)
- [ ] T026 [P] [US4] Add `/scripts/dbos-recovery-demo.sh` + a `just dbos-demo` recipe (run dbosdemo, capture pid, `kill -9` after a checkpoint, restart, assert "checkpoint A" once + "resumed"); reference it from quickstart.md.

**Checkpoint**: crash-recovery semantics proven on the box (de-risks Phase 1's chain workflow).

---

## Phase 7: User Story 5 - The foundation cannot regress silently (Priority: P3)

**Goal**: CI fails on stale generated code, broken migration up/down, or a failing create-read test.

**Independent Test**: introduce drift / a broken Down / a broken create-read test → CI fails on each.

- [ ] T027 [US5] Add `/services/api/internal/db/migrate_roundtrip_test.go` (testcontainers Postgres): `goose Up → Down → Up`; assert each step succeeds (every `-- +goose Down` drops cleanly). (Depends T014.)
- [ ] T028 [US5] Extend `/.github/workflows/ci.yml`: add a `codegen-drift` job (install `sqlc` v1.31.1 + `gqlgen`; run `sqlc diff` and `gqlgen generate && git diff --exit-code`); make `go-test` run `./...` across the workspace (Docker present on runners for testcontainers).
- [ ] T029 [P] [US5] Update `/.github/workflows/ci.yml` lint job (and any `.golangci.yml`) to cover `services/api/...` and `db/...` across the `go.work` workspace.

**Checkpoint**: all five exit criteria are guarded by CI.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T030 [P] Add `/services/api/internal/crypto/crypto.go` (AES-256-GCM `Seal`/`Open`, 32-byte key from `TENDANT_CREDENTIALS_KEY` base64, random nonce prepended) + `/services/api/internal/crypto/crypto_test.go` round-trip. (FR-009 seam; no callers yet — research §7.)
- [ ] T031 [P] Update `/justfile` `generate` to run both `cd services/api && sqlc generate` and `gqlgen generate`; refresh `/CLAUDE.md` + `/README.md` stack notes (DBOS, Go 1.25, `go.work`, services/api layout).
- [ ] T032 Run `quickstart.md` end-to-end (make up; create+read; `psql LISTEN` notify; DBOS kill-9 demo) and confirm SC-001…SC-005.

---

## Dependencies & Execution Order

### Phase dependencies
- **Setup (P1)** → no deps. T001 first (everything lives in the new module roots); T002 after T001; T003–T006 [P] after T001.
- **Foundational (P2)** → after Setup. Internal order: T007 → T009; T008 → T014; (T010, T011, T012) [P] → T013 → T015. **Blocks all stories.**
- **US1, US2 (P1)** → after Foundational. Independent of each other.
- **US3 (P2)** → after Foundational (needs T007 triggers + T009 inserts). Independent.
- **US4 (P2)** → T023/T024 after T010; T025 also needs T015 (US1-adjacent boot). Demo (T026) after T024.
- **US5 (P3)** → after Foundational; T027 needs T014; CI tasks reference all prior tests.
- **Polish (P8)** → after the stories it documents/validates (T032 last).

### Story independence
- US1 = boot/migrate orchestration + idempotency (`make up`/`down`, schema test).
- US2 = GraphQL read surface + create/seed (in-process handler test — no `make up` needed).
- US3 = a `LISTEN` integration test over the foundational triggers.
- US4 = a standalone `cmd/dbosdemo` + `internal/durable` (the recovery proof needs no main server); T025 separately folds DBOS into the main boot.
- US5 = CI + the migration round-trip test.

### Parallel opportunities
- Setup: T003, T004, T005, T006 in parallel (after T001).
- Foundational: T008, T010, T011, T012 in parallel; then T013, T014 (T014 [P] with T013), then T015.
- US2: T020, T021 parallel with each other once T019 lands.
- Cross-story: after Foundational, US1/US2/US3/US4(demo) can proceed by different people in parallel.

## Parallel Example: Foundational

```bash
# After T007 + T001/T002, run these together (different files):
Task: "T008 db/embed.go (//go:embed migrations)"
Task: "T010 internal/server/config.go + pgx pool"
Task: "T011 internal/core globaluri.go + seed.go"
Task: "T012 graph/schema.graphqls + gqlgen generate"
```

## Implementation Strategy

### MVP first (US1 + US2 — both P1)
1. Phase 1 Setup → 2. Phase 2 Foundational → 3. Phase 3 US1 (boot/migrate) → **validate** →
4. Phase 4 US2 (create+read over GraphQL) → **validate**. This is the spec's headline:
"boot the core, apply migrations, and create + query a Task over GraphQL."

### Incremental delivery
US1 → US2 (MVP) → US3 (notify seam) → US4 (DBOS recovery) → US5 (CI gates) → Polish. Each
story is a self-contained increment; stop at any checkpoint to validate.

## Notes
- [P] = different files, no incomplete-task deps.
- `cmd/tendant/main.go` is touched by T015 (foundational), T025 (US4) — sequential, not [P].
- Generated code (sqlc, gqlgen) is committed; CI checks drift (T028).
- The `kill -9` demo is a binary + script (T024/T026), not an in-process unit test.
- Commit after each task or logical group; the `after_tasks` hook can commit this file.
