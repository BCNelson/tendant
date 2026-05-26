# tendant

One-line description goes here.

## Tech stack

| Concern | Choice |
|---|---|
| Language | Go 1.23+ |
| DB access | sqlc + pgx/v5 |
| Migrations | goose (in `db/migrations/`) |
| Mobile | Flutter (in `apps/mobile/`) |
| Logs | `log/slog` JSON |
| Tests | `go test -race` + testcontainers-go |
| Task runner | Just |
| Linter | golangci-lint v2 |

## Project layout

```
.
├── cmd/tendant/        # Main binary
├── internal/             # Domain packages (not importable externally)
│   ├── db/               # sqlc config, queries, generated code
│   └── testutil/         # Shared testcontainers helpers
├── apps/mobile/          # Flutter app
├── db/migrations/        # goose-numbered SQL migrations
├── services/             # Placeholder for future go.work monorepo split
└── .github/workflows/    # CI + container publish
```

## Running locally

```sh
# First time — enters the devenv shell with Go, Flutter, Postgres all wired up
direnv allow

# Build + run
just build
just run
```

## Testing

`just test` runs `go test -race` with coverage. Tests use testcontainers-go, so Docker (or rootless Podman) must be running. The shared container starts once per test binary and each test gets a unique database.

```sh
just test        # all tests
just coverage    # HTML report at coverage.html
```

## Database

Migrations live in `db/migrations/` and are run with `goose`. sqlc config is in `internal/db/sqlc.yaml`; queries go in `internal/db/queries/*.sql`; regenerate with `just generate`.

```sh
# Create a new migration
goose -dir db/migrations create my_change sql

# Regenerate sqlc code after editing queries
just generate
```

## MCP servers

`.mcp.json` configures project-local MCP servers:

- **context7** — up-to-date library docs lookup (always on).
- **postgres** — read access to `$DATABASE_URL` once devenv is active.
- **dart-mcp-server** — Dart/Flutter tooling.

process-compose MCP is configured separately at the devenv layer — devenv exposes the SSE endpoint, picked up by your global Claude Code config. Not in this file.

## CI

- `.github/workflows/ci.yml` runs on PRs: Go lint, Go test with coverage.
- `.github/workflows/container.yml` publishes a multi-arch image to GHCR on pushes to `main` and semver tags.

## Conventions

- Table-driven tests with `t.Run` sub-tests.
- `context.Context` first arg on every function that touches DB / I/O / external services.
- Errors are typed where callers need to discriminate; otherwise wrap with `fmt.Errorf("...: %w", err)`.
- `internal/` for non-exported packages; nothing under `pkg/` until a second consumer exists.
- sqlc-generated queries, not hand-written `database/sql`. Edit `internal/db/queries/*.sql` and regenerate.
- No package-level mutable state. No `init()` for behavior — only registration of types.

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
