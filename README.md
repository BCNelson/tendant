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

## Auth password

The device-pairing flow authenticates with a static password set at server
boot via `TENDANT_PASSWORD` (or `[auth] password` in `tendant.toml`).
`compose.yaml` ships a fixed dev value so `make up` produces a reproducible
pairing experience locally. The password is **reusable** — present it to the
`pairDevice` mutation to mint a per-device, revocable session token; pair as
many devices as you like. For production deployments:

1. Generate a fresh random value: `openssl rand -base64 32`.
2. Provide it through any of the supported sources (all redacted in logs):
   - `TENDANT_PASSWORD=<value>` directly, or
   - `TENDANT_PASSWORD_FILE=/path` (contents read at boot), or
   - systemd `LoadCredential` (`$CREDENTIALS_DIRECTORY/TENDANT_PASSWORD`), or
   - `password = "${file:/run/secrets/tendant-password}"` in `tendant.toml`.

   Do not commit the production value to git.
3. Restart the API container so the new value is read.
4. To rotate, change the value and restart; previously minted device session
   tokens remain valid until explicitly revoked via `revokeSession`.

## Adding an intake connector (Phase 7)

A new source is **one file in `services/api/internal/connector/` plus a registry
entry** — and zero changes to `internal/intake` (Principle I, by construction):

1. Implement the `connector.Connector` interface (`Type()` + `Run(ctx, cfg, emit)`).
   `Run` polls the source and calls `emit` once per item with a normalized
   `intake.PotentialTaskSignal` — the connector is the privacy firewall, so it
   chooses what each signal's `Payload` carries.
2. Register it in `connector.RegisterBaseSet` (or call `registry.Register`).
3. The owner configures + enables it via the `setConnectorConfig` /
   `enableConnector` GraphQL mutations; a DBOS schedule then polls it on the
   connector's cron. Per-item disposition (`forced_task` / `rich_event` /
   `llm_judge`) is the privacy/cost firewall — only `llm_judge` ever forwards a
   payload to a model.

Credentialed sources seal their tokens through `internal/crypto` into
`source_credentials` (see the `gmail` OAuth exemplar). The contract is versioned
(`intake.v1`) at `specs/008-intake-edge-connectors/contracts/signal.v1.md`.

## License

Not yet licensed.
