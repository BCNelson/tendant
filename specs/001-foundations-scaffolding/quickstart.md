# Quickstart: Phase 0 — Foundations & Scaffolding

Verifies the four exit criteria. Assumes `direnv allow` (devenv shell with Go 1.25, Postgres
16, sqlc, goose, gqlgen, just) — or Docker for the `compose.yaml` path.

## 0. One-time codegen

```sh
just generate      # sqlc generate + gqlgen generate (committed; CI checks drift)
go work sync       # resolve the services/api + db modules
```

## 1. Boot + migrate + idempotent up/down  (Exit criterion 1 / SC-001)

```sh
make up             # delegates to `just up`: starts Postgres, runs the core
# core: opens pgx pool → goose Up (full Appendix A schema) → DBOS Launch → serves /graphql
curl -fsS localhost:8080/healthz        # => 200 OK (pool ping ok)

make down && make up                     # idempotent: clean re-migrate, comes up healthy
```

Confirm the schema landed:

```sh
psql "$DATABASE_URL" -c "\dT"            # 8 enums (task_state, chain_stage, ...)
psql "$DATABASE_URL" -c "\dt"            # 14 tables (principals … device_tokens)
psql "$DATABASE_URL" -c "\df notify_event"
```

## 2. Create + read a Task over GraphQL  (Exit criterion 2 / SC-002)

The owner `Principal` is seeded on boot. Create a Task via the seed/dev path, then read it
back through GraphQL.

```sh
just seed-task TITLE="hello"             # inserts via internal/core (sqlc), sets local://task/<uuid>

# viewer + tasks list
curl -fsS localhost:8080/graphql -H 'content-type: application/json' -d '{
  "query": "{ viewer { id globalUri displayName } tasks(first: 10) { edges { node { id globalUri title state currentStage autonomy } cursor } pageInfo { hasNextPage endCursor } } }"
}'
# expect: viewer.globalUri = local://principal/owner ; one TaskEdge with a non-empty globalUri,
#         state=ELIGIBLE, currentStage=CREATION, autonomy resolved (not null)

# task(id)
curl -fsS localhost:8080/graphql -H 'content-type: application/json' -d '{
  "query": "query($id: ID!){ task(id:$id){ id globalUri title } }",
  "variables": {"id": "<uuid-from-above>"}
}'
```

## 3. IDs-only pg_notify on insert  (Exit criterion 3 / SC-003)

In one terminal, listen; in another, insert.

```sh
# terminal A
psql "$DATABASE_URL" -c "LISTEN tendant_events;" -f - <<'SQL'
\watch 1
SQL
# (or: psql "$DATABASE_URL", then `LISTEN tendant_events;` and wait)

# terminal B — needs an existing task id for the FK
psql "$DATABASE_URL" -c "INSERT INTO pending_decisions (task_id, kind, payload)
  VALUES ('<task-uuid>', 'approval_request', '{}');"
```

Terminal A shows exactly one async notification:
`{"topic":"decision","data":{"id":"<uuid>"}}` — **only the id, no row content**. Repeat with
`agent_assignments` (`INSERT ... (task_id, stage, ask) VALUES (...,'execution','do x')`) →
`{"topic":"assignment","data":{"id":...}}`.

## 4. DBOS workflow survives a forced restart  (Exit criterion 4 / SC-004)

```sh
# start the throwaway demo (registers a workflow: step A → durable Sleep(60s) → "resumed")
go run ./services/api/cmd/dbosdemo &      # logs "checkpoint A executed", workflow id "demo-1"
DEMO_PID=$!
sleep 3
kill -9 $DEMO_PID                          # crash mid-sleep

go run ./services/api/cmd/dbosdemo         # restart: DBOS Launch recovers PENDING workflows
# expect logs: NO second "checkpoint A executed" (step memoized) ; then "resumed past the block"
#              workflow "demo-1" → status SUCCESS
```

(A scripted version lives in the integration tests / a `just dbos-demo` recipe.)

## 5. Tests / CI gates  (SC-005)

```sh
just test          # go test -race ./... : includes
                   #   • migration round-trip (goose Up→Down→Up on a testcontainers Postgres)
                   #   • integration: seed owner → insert Task (sqlc) → read via GraphQL resolvers
                   #   • crypto: AES-256-GCM Seal/Open round-trip
sqlc diff                              # no DB-codegen drift
gqlgen generate && git diff --exit-code  # no GraphQL-codegen drift
```

CI (`.github/workflows/ci.yml`) runs lint + the above; any drift, broken up/down, or failing
create-read test fails the build.

## Env

`DATABASE_URL=postgres://127.0.0.1:5432/tendant?sslmode=disable` (devenv default).
`TENDANT_CREDENTIALS_KEY=<base64 32 bytes>` — only needed once intake (Phase 7) wires the
`internal/crypto` seam to `source_credentials`; unused in Phase 0.
