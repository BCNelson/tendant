# tendant

One-line description goes here.

## Tech stack

| Concern | Choice |
|---|---|
| Language | Go 1.25 (toolchain auto-tracks; locally Go 1.26 is fine) |
| Workspace | `go.work` with two modules: `services/api` + `db` |
| HTTP | `chi/v5` |
| GraphQL | `gqlgen` v0.17.90 (schema-first; generated code committed) |
| DB driver | `pgx/v5` (≥ v5.9.2) |
| DB codegen | `sqlc` v1.31.1 (queries → `services/api/internal/db`) |
| Migrations | `goose/v3` v3.27.1 (embedded `embed.FS` in `db` module) |
| Durable engine | `dbos-transact-golang` v0.15.0 (shares the app Postgres, `dbos` schema) |
| Mobile | Flutter (in `apps/mobile/`) |
| Logs | `log/slog` JSON |
| Tests | `go test -race` + testcontainers-go v0.39.0 (Docker v28.5.2 coupling) |
| Task runner | Just (root `Makefile` shim → `just`) |
| Linter | golangci-lint v2 (per-module) |
| Credentials at rest | AES-256-GCM seam in `internal/crypto` (intake lands in Phase 7) |

## Project layout

```
.
├── go.work                              # use ./services/api ; use ./db
├── compose.yaml                         # postgres (pgvector/pgvector:pg16) for `just up`
├── db/                                  # module github.com/bcnelson/tendant/db
│   ├── embed.go                         # //go:embed migrations/*.sql
│   └── migrations/                      # goose-numbered SQL migrations (00001_*)
├── services/api/                        # module github.com/bcnelson/tendant/services/api
│   ├── cmd/tendant/                     # main binary: boot → migrate → seed → DBOS Launch → serve
│   ├── cmd/dbosdemo/                    # throwaway crash-recovery proof (kill -9 + restart)
│   ├── graph/                           # gqlgen: schema, generated.go, model/, resolvers
│   ├── sqlc.yaml / gqlgen.yml
│   └── internal/
│       ├── db/                          # sqlc-generated + migrate.go + tests
│       ├── server/                      # config + pool + chi router
│       ├── core/                        # CreateTask, AttachChainWorkflow, SeedOwner
│       ├── durable/                     # DBOS init/launch/shutdown + chain registration
│       ├── lifecycle/                   # state machine + audit-message helpers (Phase 1)
│       ├── chain/                       # DBOS chain workflow + router + wait primitive (Phase 1)
│       ├── crypto/                      # AES-256-GCM Seal/Open (TENDANT_CREDENTIALS_KEY)
│       └── testutil/                    # testcontainers Postgres shared-pool helper
├── apps/mobile/                         # Flutter app
├── scripts/                             # dbos-recovery-demo.sh, etc.
└── .github/workflows/                   # CI (lint, codegen-drift, test) + container publish
```

## Running locally

```sh
direnv allow             # devenv shell: Go 1.25, Postgres 16+pgvector, sqlc, goose, just

# Bring up Postgres + the core (migrates, seeds owner, serves /graphql + /healthz).
make up                  # equivalent: just up
curl -fsS localhost:8080/healthz

make down                # tears down compose volume so next up re-migrates clean (SC-001)

just seed-task TITLE=hello       # insert a Task via internal/core.CreateTask
```

## Testing

`just test` runs `go test -race` per workspace module. Tests use testcontainers-go, so
Docker (or rootless Podman) must be running. The shared container starts once per test
binary and each test gets a unique database.

```sh
just test                # all tests, per-module
just coverage            # HTML report at coverage.html
just dbos-demo           # kill -9 + restart proof (scripts/dbos-recovery-demo.sh)
```

## Database

Migrations live in `db/migrations/` and are run with `goose` via
`services/api/internal/db.Migrate(ctx, dsn)` on boot. sqlc config is in
`services/api/sqlc.yaml`; queries go in `services/api/internal/db/queries/*.sql`;
regenerate with `just generate`.

```sh
goose -dir db/migrations create my_change sql        # new migration
just generate                                        # sqlc + gqlgen (committed, CI checks drift)
```

## MCP servers

`.mcp.json` configures project-local MCP servers:

- **context7** — up-to-date library docs lookup (always on).
- **postgres** — read access to `$DATABASE_URL` once devenv is active.
- **dart-mcp-server** — Dart/Flutter tooling.

process-compose MCP is configured separately at the devenv layer.

## CI

- `.github/workflows/ci.yml` runs on PRs: per-module Go lint, codegen-drift (sqlc + gqlgen),
  workspace tests with coverage (testcontainers needs Docker on the runner).
- `.github/workflows/container.yml` publishes a multi-arch image to GHCR on pushes to
  `main` and semver tags. The Dockerfile is workspace-aware (`go build -C services/api`).

## Conventions

- Table-driven tests with `t.Run` sub-tests.
- `context.Context` first arg on every function that touches DB / I/O / external services.
- Errors are typed where callers need to discriminate; otherwise wrap with `fmt.Errorf("...: %w", err)`.
- `internal/` for non-exported packages; nothing under `pkg/` until a second consumer exists.
- sqlc-generated queries, not hand-written `database/sql`. Edit `internal/db/queries/*.sql` and regenerate.
- No package-level mutable state. No `init()` for behavior — only registration of types.

<!-- SPECKIT START -->
Phase 0 (Foundations & Scaffolding) is **complete** — schema, GraphQL read surface, DBOS,
CI gates all landed on `main`. For the Phase 0 design see
`specs/001-foundations-scaffolding/{spec,plan,research,data-model,quickstart}.md`.

Phase 1 (Task Lifecycle & Chain Skeleton — Human-Only) is **complete** on
branch `002-task-lifecycle-chain` — the DBOS chain workflow walks owner-authored
tasks through `CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION`, the
state machine + audit DAG land in `internal/lifecycle`, and the four mutations
(`createTask`, `completeTask`, `cancelTask`, plus the `*ProposedTask` pair)
ship in `services/api/graph/schema.graphqls`. Migration `00002` renames
`task_state.eligible` → `waiting` and defaults new rows to `accepted`. Design
artifacts: `specs/002-task-lifecycle-chain/{spec,plan,research,data-model,quickstart}.md`;
contract: `specs/002-task-lifecycle-chain/contracts/graphql.v1.graphqls`.
<!-- SPECKIT END -->
