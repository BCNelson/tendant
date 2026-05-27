# Implementation Plan: Phase 0 — Foundations & Scaffolding

**Branch**: `001-foundations-scaffolding` | **Date**: 2026-05-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-foundations-scaffolding/spec.md`

## Summary

Stand up the empty skeleton every later phase hangs off: a `go.work` monorepo, the Go core
API process (`chi` + `gqlgen` + `pgx`) serving GraphQL at `/graphql`, Postgres carrying the
full v2 data model (Appendix A) via embedded Goose migrations applied on startup, DBOS
(durable execution) initialized over the same Postgres, and the read-only GraphQL surface.
No behavior — the system boots, migrates idempotently, round-trips a `Task`, fires the
IDs-only `pg_notify` transition triggers, and proves DBOS crash-recovery with a throwaway
workflow. Two cheap-now/expensive-later invariants are baked into the schema on day one: the
message-shaped audit DAG (`audit_messages.in_reply_to`) and `global_uri`/`Principal` on
every entity.

Technical approach (from research): introduce a 2-Go-module workspace (`services/api` +
`db`), bump the toolchain to **Go 1.25** (hard DBOS requirement) and bump `pgx`→v5.9.1 /
`testcontainers-go`→v0.39 (docker v28.5.2 coupling), generate+commit `gqlgen` and `sqlc`
code, embed migrations from the `db` module, and wire startup order **pgx pool → goose Up →
DBOS Launch → chi serve**. Credential encryption is decided (app-level AES-256-GCM, env key)
and landed as a tested seam with no callers yet.

## Technical Context

**Language/Version**: Go **1.25** (raised from 1.23 — `dbos-transact-golang` requires go
1.25; cascades to `go.mod`, `devenv.nix`, `Dockerfile`, CI via `go-version-file`).
**Primary Dependencies**:
- HTTP: `github.com/go-chi/chi/v5`
- GraphQL: `github.com/99designs/gqlgen` v0.17.90 (committed generated code)
- DB driver: `github.com/jackc/pgx/v5` v5.9.1 (raised from 5.7.2 via MVS)
- DB codegen: `sqlc` v1.31.1 (CLI, devenv) → `internal/db` generated package
- Migrations: `github.com/pressly/goose/v3` v3.27.1 (embedded `embed.FS`)
- Durable engine: `github.com/dbos-inc/dbos-transact-golang/dbos` v0.15.0
- UUID: `github.com/google/uuid` (sqlc `uuid` override) — *new dep, flagged below*
- Tests: `testcontainers-go` v0.39.0 (raised from 0.34.0) + `stretchr/testify`
**Storage**: Postgres 16 (single datastore + `LISTEN/NOTIFY` transport; no broker). DBOS
shares the same database in a dedicated `dbos` schema; app tables in `public`.
**Testing**: `go test -race` with `testcontainers-go` (shared pgvector/pg16 container, unique
DB per test); a `kill -9` restart demo for DBOS recovery runs as a standalone binary + shell
script (not an in-process test).
**Target Platform**: Linux server, self-hosted single-box, single-household.
**Project Type**: Web service (Go core + GraphQL) in a `go.work` monorepo with a Flutter
client stub.
**Performance Goals**: Local single-box; boot-to-healthy in well under 2 min (local target); no
throughput targets this phase.
**Constraints**: Postgres-only; IDs-only `pg_notify` (8 KB cap); generated code committed
and drift-checked; migrations idempotent up→down→up.
**Scale/Scope**: One owner, one box. Full Appendix A schema (14 tables, 8 enums, 1 function,
2 triggers); read-only GraphQL subset; ~one integration test + one migration round-trip test.

## Constitution Check

*GATE: evaluated against constitution v1.2.0. Re-checked post-design — still passing.*

| Principle | Phase 0 status |
|---|---|
| I. Capability at the edges | ✅ Only the stable core + schema is built; no source/action/agent hardwired. Edge tables land empty. |
| II. Task ≠ workflow | ✅ Physical split: `tasks` vs `chain_workflows` (nullable link, partial-unique live index). |
| III. Hard-rule floor immune | ✅ No gate yet (deferred); nothing bypasses a floor that doesn't exist. |
| IV. Owner authors trust | ✅ No promotion/escalation logic; `tools.overseer_instructions` lands owner-only by schema. |
| V. Cancel halts | ✅ N/A this phase; `HALTED` exists in the `task_state` enum. |
| VI. Audit is message-shaped | ✅ `audit_messages.in_reply_to` self-FK ships in the first migration. |
| VII. Edge contracts versioned/additive | ✅ GraphQL contract in `contracts/`; versioning discipline begun in spirit (read-only subset). |
| VIII. Federation-shaped | ✅ `global_uri` on `principals`/`tasks`/`tools` (addressable resources per VIII v1.2.0); `Principal` interface (`User`/`Bot`). |
| IX. Untrusted code sandboxed | ✅ No gate-script execution (deferred); `gate_scripts` table lands unused. |

**Technology Constraints**: Postgres-only ✅ (DBOS reuses the same Postgres, no broker);
DBOS engine ✅; adopted stack (Go `gqlgen`/`chi`/`pgx`, Flutter, WASM-later) ✅; Go language ✅.

**Dependency / deviation flags (Workflow gate — declared, not violations):**
- The core libraries (`gqlgen`, `chi`, `pgx`, `goose`, **DBOS**) are named in the
  constitution's Technology Constraints → pre-approved.
- **`github.com/google/uuid`** — new direct dependency (sqlc UUID override). Justification:
  ergonomic UUID type at the DB/GraphQL boundary; stdlib has no UUID. Low-risk, ubiquitous.
  — **approved** by owner (analyze review, 2026-05-26).
- **Go 1.23 → 1.25** toolchain bump — forced by DBOS v0.15.0. Cascades to devenv, Docker, CI.
- **`pgx` 5.7.2 → 5.9.1**, **`testcontainers-go` 0.34.0 → 0.39.0**, **`docker/docker`
  → v28.5.2** (transitive, MVS) — forced by DBOS coupling; see [[dep-testcontainers-docker-dbos-coupling]].
- No new datastore/transport/language introduced. Encryption uses Go stdlib (`crypto/aes`,
  `crypto/cipher`) — no new dep.

→ **Constitution Check: PASS.** No unjustified complexity; Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-foundations-scaffolding/
├── plan.md              # This file
├── research.md          # Phase 0 decisions (DBOS, gqlgen, goose, sqlc, module layout, crypto, runner)
├── data-model.md        # Appendix A schema → first migration, entities, indexes, triggers
├── quickstart.md        # Boot, create+read a Task, verify pg_notify, verify DBOS restart
├── contracts/
│   └── graphql.v1.graphqls   # Versioned operator-edge contract (read-only subset)
└── checklists/
    └── requirements.md  # (from /speckit-specify)
```

### Source Code (repository root) — target layout

```text
go.work                              # use ./services/api ; use ./db
db/                                  # module github.com/bcnelson/tendant/db
├── go.mod
├── embed.go                         # //go:embed migrations/*.sql  → var Migrations embed.FS
└── migrations/
    ├── 00001_v2_ddl_spine.sql       # full Appendix A DDL (Up + Down)
    └── (future migrations)
services/api/                        # module github.com/bcnelson/tendant/services/api
├── go.mod
├── sqlc.yaml                        # schema: ../../db/migrations ; out: internal/db
├── gqlgen.yml
├── cmd/tendant/main.go              # boot: pgx pool → goose Up → DBOS Launch → chi serve
├── cmd/dbosdemo/main.go             # throwaway crash-recovery workflow binary (FR-013)
├── graph/                           # gqlgen: schema, generated.go, models, resolvers (committed)
│   ├── schema.graphqls
│   ├── generated.go
│   ├── model/
│   └── *.resolvers.go
├── internal/
│   ├── db/                          # sqlc-generated package (committed) + queries/
│   ├── server/                      # chi router, /graphql, /healthz
│   ├── core/                        # domain types, globalUri helpers, seed (owner Principal)
│   ├── crypto/                      # AES-256-GCM Seal/Open + env key loader (+ test); no callers yet
│   └── testutil/                    # testcontainers helper (moved from root)
apps/mobile/                         # Flutter stub (existing) — monorepo member, not a Go module
.github/workflows/ci.yml             # + codegen-drift job, + migration up/down test, + integration test
compose.yaml                         # Postgres 16 for portable `make/just up` + CI services
justfile / Makefile                  # up / down / generate / test (Makefile delegates to just)
```

**Structure Decision**: A `go.work` workspace with **two Go modules** — `services/api`
(the core) and `db` (migrations + their `embed.FS`). `db` must be its own module because
`//go:embed` cannot reach a top-level `db/migrations/` from inside `services/api`, and the
spec wants `db/migrations` as a first-class top-level member. `apps/mobile` is the Flutter
client (no `go.mod`), documented as a monorepo member. The current root module
(`cmd/tendant`, `internal/`, `main_test.go`, `sqlc.yaml`) is **moved into `services/api`**
and import paths updated to `github.com/bcnelson/tendant/services/api/...`. Rationale and the
single-module alternative are recorded in `research.md`.

### Startup order (load-bearing — from DBOS research)

1. Open `pgxpool.Pool` from `DATABASE_URL`.
2. `goose.SetBaseFS(db.Migrations)` → `goose.SetDialect("postgres")` → `goose.Up` against a
   `*sql.DB` (pgx stdlib driver) — creates the app schema (`public`).
3. Seed the single owner `Principal` (idempotent upsert on `global_uri`).
4. `dbos.NewDBOSContext(ctx, dbos.Config{AppName: "tendant", SystemDBPool: pool, DatabaseSchema: "dbos"})` →
   `RegisterWorkflow(...)` → `dbos.Launch` (creates `dbos` schema, recovers pending workflows).
5. Build chi router (`/graphql`, `/healthz`), `http.ListenAndServe`.
6. `defer dbos.Shutdown(ctx, 5s)` + graceful `http.Server.Shutdown`.

## Complexity Tracking

> No Constitution Check violations. Section intentionally empty.
