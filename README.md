# tendant

A self-hosted, single-household task orchestrator. Phase 0 lands the empty-but-bootable
skeleton: a `go.work` Go core (`chi` + `gqlgen` + `pgx`) serving a read-only GraphQL surface
over Postgres, full v2 schema applied via embedded Goose migrations on startup, DBOS
durable execution initialised over the same Postgres, and IDs-only `pg_notify` triggers
wired for the operator edge.

## Setup

```sh
# First time — enters the devenv shell (Go 1.25, Postgres 16 + pgvector, sqlc, goose, just).
direnv allow

# Bring up Postgres + the core: migrates, seeds owner, serves /graphql + /healthz.
make up                  # equivalent: just up
curl -fsS localhost:8080/healthz   # → 200 OK

# Tests (Docker required for testcontainers).
just test
```

## Layout

A `go.work` workspace with two Go modules:

- `services/api/` — the Go core (`cmd/tendant`, `cmd/dbosdemo`, `graph/`, `internal/`).
- `db/` — Goose migrations embedded via `//go:embed`.
- `apps/mobile/` — Flutter client stub (monorepo member, not a Go module).

## Development

See [CLAUDE.md](./CLAUDE.md) for the full tech stack, conventions, and common tasks.
The active feature plan lives at `specs/001-foundations-scaffolding/plan.md`.

## Setup secret rotation (Phase 2)

The Phase 2 device-pairing flow needs a one-time setup secret armed at server
boot via the `TENDANT_SETUP_SECRET` environment variable. `compose.yaml` ships
a fixed dev value (`dev-setup-2026-05-28`) so `make up` produces a reproducible
pairing experience locally. For production deployments:

1. Generate a fresh random value: `openssl rand -base64 32`.
2. Set `TENDANT_SETUP_SECRET` on the running container's environment (e.g., via
   the orchestrator's secrets surface — `docker compose --env-file`, k8s
   `Secret`, systemd `EnvironmentFile`, etc.). Do not commit the production
   value to git.
3. Restart the API container so the new value is armed.
4. The secret is single-use *per boot*: after the first successful
   `pairDevice` mutation it is "consumed" in-process. To pair another device,
   either restart the container (re-arms the same secret) or rotate to a new
   value first.

## License

Not yet licensed.
