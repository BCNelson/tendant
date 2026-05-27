# Research & Decisions: Phase 0 — Foundations & Scaffolding

All "NEEDS CLARIFICATION" items from Technical Context resolved below. Format per decision:
**Decision / Rationale / Alternatives**.

---

## 1. DBOS Transact Go SDK

**Decision**: Use `github.com/dbos-inc/dbos-transact-golang/dbos` **v0.15.0** (pinned).
Initialize with `dbos.NewDBOSContext(ctx, dbos.Config{AppName:"tendant", SystemDBPool:
pool, DatabaseSchema:"dbos"})`, register workflows, then `dbos.Launch(ctx)`;
`defer dbos.Shutdown(ctx, 5*time.Second)`. Reuse the app's `*pgxpool.Pool` via `SystemDBPool`
(takes precedence over `DatabaseURL`); DBOS isolates its tables in a `dbos` schema, sharing
the same Postgres database.

**Crash recovery**: automatic inside `Launch` — it recovers all `PENDING` workflows for this
executor. Completed steps are memoized in Postgres (`(workflowID, stepID)`), so a recovered
workflow re-enters its function but skips finished steps → effectively exactly-once. No
explicit recovery call needed.

**Throwaway demo (FR-013)**: a standalone binary `cmd/dbosdemo` registers a workflow that
(1) runs a step logging "checkpoint A" once, (2) `dbos.Sleep(ctx, 60s)` (durable), (3) logs
"resumed". Start it with `WithWorkflowID("demo-1")`, `kill -9` during the sleep, restart →
observe step A is **not** re-run and execution resumes past the sleep. A shell script in
`quickstart.md` automates the kill/restart. (`kill -9` of an in-process `go test` is awkward,
so this is a binary + script, not a unit test; `ForkWorkflow`/`ResumeWorkflow` can simulate
recovery in-process if a CI-friendly variant is wanted later.)

**Health**: `Launch` returning nil is the readiness signal. We surface `/healthz` on chi
(pings the pool). DBOS's optional admin server (`/dbos-healthz` on :3001) is left **off** to
avoid a second port.

**Hard constraints discovered**:
- **Requires Go 1.25** (module `go 1.25.0`). → bump `go.mod`, `devenv.nix`, `Dockerfile`, CI.
- Requires `pgx/v5` **v5.9.1** → MVS raises our 5.7.2 (stable within v5; low risk).
- Direct-requires `github.com/docker/docker v28.5.2+incompatible` (only its *CLI* uses it,
  but MVS still pulls it module-wide). See decision #6.

**Rationale**: DBOS is the constitution's mandated engine; v0.15.0 is current (2026-05-18).
Sharing the pool + `dbos` schema keeps "Postgres-only, single box" intact.
**Alternatives**: separate DBOS database (rejected — unnecessary on one box); river/temporal
(rejected — constitution fixes DBOS). Pre-1.0 churn risk accepted; version pinned.

---

## 2. GraphQL — gqlgen

**Decision**: `gqlgen` **v0.17.90**, schema-first. `gqlgen.yml` binds `Time → time.Time`
(built-in `graphql.Time`) and `JSON → map[string]interface{}` (built-in `graphql.Map`).
Hand-write `TaskConnection`/`TaskEdge`/`PageInfo` in the SDL (gqlgen has **no** Relay-
connection generator) with keyset (cursor) pagination, fetching `first+1` to compute
`hasNextPage`. Serve via `handler.New(...)` + explicit transports (`POST`, `GET`,
`Options`), an LRU query cache, `extension.Introspection` (dev only), mounted at
`r.Handle("/graphql", srv)` on chi; playground at `/playground`. Resolver dependencies
(`*pgxpool.Pool` / sqlc `*db.Queries`) hang off the `Resolver` root struct (no package-level
state — satisfies the CLAUDE.md rule). Generated code committed; drift caught in CI by
`gqlgen generate` + `git diff --exit-code`.

**Rationale**: constitution-fixed; `NewDefaultServer` is deprecated, so explicit transports
are required (forgetting `POST` is a known runtime error). **Alternatives**: federation
plugin (not needed — single instance, federation is wire-shape only this phase); auto
connections (none exist).

---

## 3. Migrations — goose (embedded)

**Decision**: `github.com/pressly/goose/v3` **v3.27.1**. Migrations live at top-level
`db/migrations/*.sql`, embedded in the `db` module via `//go:embed migrations/*.sql`. On
startup: `goose.SetBaseFS(db.Migrations)`, `goose.SetDialect("postgres")`, `goose.Up(sqlDB,
"migrations")` where `sqlDB` is `sql.Open("pgx", dsn)` (driver from
`github.com/jackc/pgx/v5/stdlib`). The first migration `00001_v2_ddl_spine.sql` carries the
full Appendix A DDL with a complete `-- +goose Down`. The `notify_event` /
`trg_pending_notify` / `trg_assign_notify` plpgsql function bodies are wrapped in
`-- +goose StatementBegin/StatementEnd` (internal semicolons); `CREATE TYPE ... AS ENUM` and
`CREATE TRIGGER` bindings are not wrapped. Zero-padded filename so sqlc's lexicographic order
matches goose.

**Rationale**: embedded migrations = "applied on startup" with no external goose binary in
prod. **Alternatives**: `goose.NewProvider(fs)` (equivalent; the simpler `Up` API suffices);
golang-migrate / atlas (rejected — constitution/CLAUDE.md fix goose).

---

## 4. DB codegen — sqlc + pgx/v5

**Decision**: `sqlc` **v1.31.1**, `version:"2"`, `engine:"postgresql"`, `sql_package:
"pgx/v5"`, `emit_json_tags:true`, `emit_pointers_for_null_types:true`. `schema:` points
directly at `../../db/migrations` (sqlc parses `-- +goose Up`, ignores `-- +goose Down` — no
separate schema file needed). Overrides: `uuid → github.com/google/uuid.UUID`, `jsonb →
encoding/json.RawMessage`, `timestamptz → time.Time`. Output package `internal/db`. Drift in
CI via `sqlc diff` (self-contained) and/or `sqlc generate` + `git diff`.

**Coexistence with gqlgen**: sqlc owns DB structs + typed queries; gqlgen owns GraphQL
types; resolvers are explicit mappers between them (do **not** autobind gqlgen onto sqlc
structs — nullability/`pgtype`/tags don't align).

**Rationale**: matches the existing `sqlc.yaml` intent (moved into `services/api`).
**Alternatives**: hand-written `database/sql` (rejected by CLAUDE.md conventions).

---

## 5. Monorepo / module layout (`go.work`)

**Decision**: `go.work` at root with `use ./services/api` and `use ./db`.
- `db` = module `github.com/bcnelson/tendant/db` — owns `migrations/*.sql` + `embed.go`.
- `services/api` = module `github.com/bcnelson/tendant/services/api` — the Go core
  (`cmd/`, `graph/`, `internal/`); imports `db` for the embedded migrations.
- `apps/mobile` = Flutter (no `go.mod`) — a monorepo member, not a workspace module.
- The current **root module is dissolved**: `cmd/tendant`, `internal/`, `main_test.go`,
  `sqlc.yaml` move into `services/api/`; imports become
  `github.com/bcnelson/tendant/services/api/...`.

**Rationale**: `//go:embed` cannot climb out of its module's directory, so keeping
`db/migrations` at top level (per spec FR-001) forces `db` to be its own module. Matches the
`pulse` lineage and the spec's three-member layout. **Alternatives**: (a) single root module
with migrations under `services/api/db/migrations` — rejected, contradicts the top-level
`db/migrations` member and the existing `sqlc.yaml`; (b) `go.work` listing only
`services/api` with migrations embedded from within it — same problem. The two-module cost is
one extra `go.mod` and is future-proof (db can grow seeds/fixtures).

---

## 6. Dependency version coupling (Go / pgx / testcontainers / docker)

**Decision**: bump **Go 1.23 → 1.25** (go.mod `go 1.25`, `devenv.nix`
`languages.go.package`/version, `Dockerfile` `golang:1.25`, CI `setup-go` reads
`go-version-file`). Bump **`testcontainers-go` 0.34.0 → 0.39.0**. Let MVS resolve **`pgx`
→ 5.9.1** and **`docker/docker` → v28.5.2**. Run `go mod tidy` per module + the integration
suite to confirm.

**Rationale**: DBOS v0.15.0 hard-requires Go 1.25 and direct-requires docker v28.5.2;
testcontainers-go ≤0.34 pins docker v27.x and is incompatible with the v28 line. v0.39.0
targets docker v28.x. This refines the memory note: the real requirement is
"testcontainers-go compatible with docker v28.5.2," satisfied by ≥0.38 (we take 0.39.0).
See [[dep-testcontainers-docker-dbos-coupling]]. **Alternatives**: isolating DBOS in its own
module to dodge the docker MVS bump — rejected as premature; single workspace keeps versions
unified.

---

## 7. `source_credentials` encryption at rest (deferred from spec → decided here)

**Decision**: **App-level AES-256-GCM.** A small `internal/crypto` package exposes
`Seal(plaintext []byte) ([]byte, error)` and `Open(ciphertext []byte) ([]byte, error)` using
a 32-byte key loaded from env `TENDANT_CREDENTIALS_KEY` (base64). GCM nonce is random per
seal and prepended to the ciphertext. Phase 0 lands the package + key loader + a round-trip
unit test **with no callers** (intake is Phase 7); the `source_credentials.encrypted bytea`
column ships in the migration. Key management: one key per box from env/secret file; absence
is fail-closed only once intake is enabled (a later phase); rotation deferred.

**Rationale**: simplest scheme for a single self-hosted box, stdlib-only (no new dep, no DB
extension), key never in the DB. Deciding the shape now (per the spec's flagged risk)
"shapes key management" without building Phase-7 behavior. **Alternatives**: `pgcrypto`
(rejected — key travels to DB session; adds extension); external KMS/`age` (rejected —
over-built for one box; revisit if managed-hosting is ever added).

---

## 8. Boot / teardown runner (`make up` vs existing `just`)

**Decision**: keep **`just`** as the real task runner (already in devenv/CLAUDE.md). Add
`just up` / `just down`, and a thin root **`Makefile`** whose `up`/`down`/`test`/`generate`
targets delegate to `just` (so the spec's `make up`/`make down` work verbatim). Add a
`compose.yaml` (Postgres 16 `pgvector/pgvector:pg16`) for a reproducible, out-of-shell
Postgres. `just up` = start Postgres (devenv service in-shell, else `docker compose up -d
postgres`) then `go run ./services/api/cmd/tendant` (auto-migrates, inits DBOS, serves
`/graphql`). `just down` = stop the core and tear down Postgres/volumes. Idempotency: `down`
drops the data volume so the next `up` re-migrates from clean (SC-001).

**Rationale**: honors both the build-plan's literal `make up` and the repo's `just`
convention without forcing a choice; `compose.yaml` makes the demo reproducible where devenv
isn't active. **Alternatives**: Make-only (rejected — discards the existing just setup);
just-only (rejected — breaks the spec's `make up` reference).

---

## 9. CI additions (FR-017)

**Decision**: extend `.github/workflows/ci.yml`:
- **codegen-drift** job: install `sqlc` + `gqlgen`, run `sqlc diff` and `gqlgen generate &&
  git diff --exit-code` (fail on drift). (Ferry/Flutter drift deferred — mobile is a stub.)
- **migration round-trip**: a Go test does `goose Up → Down → Up` against a testcontainers
  Postgres (asserts every `Down` is correct; SC-005).
- **integration**: a Go test boots the pool, migrates, seeds the owner `Principal`, inserts a
  `Task` via sqlc, and reads it back through the GraphQL `task(id)` / `tasks` resolvers
  (SC-002). Runs under the existing `go-test` job (GitHub runners provide Docker).
- `setup-go` already uses `go-version-file: go.mod` → picks up Go 1.25 automatically.

**Rationale**: directly satisfies FR-017 / SC-005. **Alternatives**: `sqlc push`/`verify`
(needs sqlc Cloud — skipped); separate workflow file (folded into `ci.yml` for one PR gate).

---

## 10. GraphQL contract versioning (Principle VII, in spirit)

**Decision**: the read-only SDL is committed as `contracts/graphql.v1.graphqls` (the
versioned operator-edge contract). Phase 0 exposes only the read subset + scalars + Relay
connections from Appendix B; intent-named mutations are deferred. Evolution will be additive
(new fields/union members), enforced concretely when the contract ships to the client in
Phase 2.

**Rationale**: begins the §15 Q4 / Principle VII discipline now without over-building.
**Alternatives**: deferring any contract file (rejected — the seam is cheap and the spec
asks for the read-only subset now).
