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
direnv allow             # devenv shell: Go 1.25, Postgres 16+pgvector, sqlc, goose, just,
                         # Node+npm (gate-sdk-as), Rust+wasm32 (gate-sdk-rust), govulncheck, wabt

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
- **Contract changes** (the five long-lived versioned contracts: operator-edge GraphQL, intake potential-task signal, MCP tool contract, gate-script ABI/manifest, federation message protocol) follow the hybrid additive-+-deprecation policy at `specs/003-operator-edge-wake/contracts/versioning-policy.md`. PRs that touch these contracts MUST pick a path (1/2/3) per the PR template.

<!-- SPECKIT START -->
Phase 0 (Foundations & Scaffolding) is **complete** — schema, GraphQL read surface, DBOS,
CI gates all landed on `main`. For the Phase 0 design see
`specs/001-foundations-scaffolding/{spec,plan,research,data-model,quickstart}.md`.

Phase 1 (Task Lifecycle & Chain Skeleton — Human-Only) is **complete** — the
DBOS chain workflow walks owner-authored tasks through
`CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION`, the state machine
+ audit DAG land in `internal/lifecycle`, and the four mutations
(`createTask`, `completeTask`, `cancelTask`, plus the `*ProposedTask` pair)
ship in `services/api/graph/schema.graphqls`. Migration `00002` renames
`task_state.eligible` → `waiting` and defaults new rows to `accepted`. Design
artifacts: `specs/002-task-lifecycle-chain/{spec,plan,research,data-model,quickstart}.md`;
contract: `specs/002-task-lifecycle-chain/contracts/graphql.v1.graphqls`.

Phase 2 (Operator Edge & the Wake Channel) is **complete** — the full
versioned GraphQL operator-edge contract is live (`PendingDecision`
interface + three impl types, `ApprovalPayload` union, `InboxItem` union,
`inbox` query, the three subscriptions, session+device-token mutations,
plus the four stubbed decision mutations returning `NOT_YET_AVAILABLE`
per FR-005). Migration `00003` added the `sessions` table and
`agent_assignments.to_principal`. New internal packages: `auth/` (central
`Can(...)`, session mint/resolve, setup-secret arming, chi middleware, WS
init, registry), `realtime/` (in-process `LISTEN tendant_events`
dispatcher + per-event auth re-check), `push/` (closed `PushBody`,
Provider seam, Selector, LogProvider stub; APNs / FCM stubs ready for
real credentials), and `inbox/` (UNION ALL keyset-paginated viewer-scoped
inbox). The chain workflow sets `to_principal` on assignment open and
enqueues a push job via `chain.PushEnqueuer`. The Flutter app
(`ferry`/`riverpod`/`drift`/`go_router`) renders the unified inbox with
pairing + assignment-complete + an offline outbox + floor-relevant rail
that refuses floor writes pre-Phase-3. The contract-versioning policy
(additive + field-deprecation default; versioned endpoint reserved for
unavoidable breaking changes) is locked and referenced from the schema
header, the `.github/PULL_REQUEST_TEMPLATE.md`, and the CLAUDE.md
Conventions block. Design artifacts:
`specs/003-operator-edge-wake/{spec,plan,research,data-model,quickstart}.md`;
contracts: `specs/003-operator-edge-wake/contracts/{graphql.v1.graphqls,versioning-policy.md}`.

Phase 3 (Universal Gate, Hard-Rule Floor & the First Tool) is **complete**
— the trust spine's foundation is live. The new `internal/gate` package
exposes `Gate.Evaluate(ctx, *ToolCall, *Tool) (Verdict, error)` and
composes the four canonical layers (read-only short-circuit → hard-rule
floor → script-stub → overseer-stub) in the order Phases 4/5 will slot
into without rework. The hard-rule floor is categorical (a trip always
produces `RequestDecision`, regardless of any downstream layer): three
clauses — `spend`, `irreversible_third_party` (modes:
`never|always|stranger_recipient`), and `secret_disclosure` — fed by the
per-tool `tools.permissions` jsonb. The first MCP tool (`send-email`)
lives behind `internal/tools` with a `Provider` seam mirroring
`internal/push` (`LogProvider` default; real SMTP slot reserved for
Phase 7 credentials). A sibling `internal/toolflow` package owns one
DBOS-registered workflow (`tendant.toolcall`) per gated call:
`dbos.Recv` on `approval:<decisionID>` → dispatch via the registry →
write `tool_outcomes(outcome=clean|bad)` + chained audit messages
(`tool_call_composed`/`gate_verdict`/`decision_resolved`/`tool_dispatched`
/`tool_outcome_recorded`). Migration `00004` adds three nullable columns
to `pending_decisions` (`frozen_payload`, `workflow_id`,
`decision_topic`) so an `ApprovalRequest` carries the byte-for-byte
frozen call. The Phase 2 stubs for `approveArtifact` /
`rejectApproval` are now real (resolution row + `dbos.Send` to wake the
workflow); a new mutation `proposeToolCall(taskId, toolGlobalUri,
payload)` is the single composition entry point (the overseer will share
it in Phase 4). The Flutter app adds `ApprovalDetailPage` +
`FloorAwareApprovalMutator` so the Phase 2-installed floor rail starts
refusing real offline approvals. Design artifacts:
`specs/004-universal-gate-floor/{spec,plan,research,data-model,quickstart}.md`;
contract delta: `specs/004-universal-gate-floor/contracts/graphql.v1.graphqls`.

Phase 4 (The Overseer — Per-Tool LLM Grader) is **complete** — the
gate's Layer-4 slot is wired to the new `internal/overseer` package: a
`Grader` interface, a `Gateway` choke point that owns the rolling
60-second rate window + per-task cap, and three `Provider` impls
(`LogProvider` default + `Anthropic` and `OpenAI` via stdlib `net/http`
with forced structured tool-use output — no new SDK dep). The gate
calls the overseer only after the floor declines to trip (constitution
III preserved); on Approve the resolver writes a system-resolved
`pending_decisions` row that the Phase-3 `ToolCallWorkflow` dispatches,
skipping the human-wait while keeping the audit DAG uniform. Owner-only
mutations `setToolPermissions` and `setToolOverseerInstructions` land
on the operator-edge GraphQL contract, structurally guarded by the new
`auth.RequireOwner(ctx)` helper (`Principal.Kind == "user"` before any
DB write). The labeled-slots discipline is a struct boundary
(`OverseerInput{OwnerInstructions, ConcreteCall, ...}`) plus a fixed
`SystemPreamble` declaring `[OWNER_INSTRUCTIONS]` authoritative, so a
payload field cannot pose as an owner instruction (proven by
`prompt_test.go` injection cases). Cost control ships three layers:
per-call `tokens_in`/`tokens_out`/`estimated_cost_usd` in
`audit_messages` under `kind="overseer_evaluated"`, a rolling
`overseer.evaluations_per_minute` field on `/healthz`, and a per-task
hard cap (`TENDANT_OVERSEER_MAX_EVAL_PER_TASK`, default `50`) that
fail-closes to `RequestDecision` without invoking the provider. **No
new tables, no new migration** — all new state rides
`audit_messages.payload jsonb` plus the existing
`tools.{permissions,overseer_instructions}` columns reserved in Phase 0.
**No verdict cache** — real tool payloads rarely collide, so the
carrying cost would outweigh the benefit. The Flutter app adds
`OverseerEvaluationCard` on `ApprovalDetailPage` (shows verdict +
summary + considered fields when present) and a read-only
`ToolDetailPage` for owner reference. Design artifacts:
`specs/005-overseer-tool-grader/{spec,plan,research,data-model,quickstart}.md`;
contract delta: `specs/005-overseer-tool-grader/contracts/graphql.v1.graphqls`.

Phase 5 (Gate Scripts — the Untrusted-Code Surface) is **complete &
green** (56/56 tasks; `go build` + `go test ./...` pass across all 16
API packages, with and without `asc` on PATH). The implementation fills
Phase 3's reserved Layer-3 slot at
`services/api/internal/gate/gate.go` between the floor and the overseer.
A new `internal/gatescript` package wraps **wazero (pure-Go, no CGo)**
— **one new Go dep, justified in plan.md Constitution Check** under
Principle IX (Untrusted Code). The runner uses a custom ~200-LOC
pointer/length ABI compatible with Extism's wire shape (no Extism Go
SDK dep). The four terminal verdicts (`Approve` floor-subordinate,
`Deny`, `RequestDecision`, `AgentHandoff`) translate into the gate's
existing verdict type; on `AgentHandoff` the gate falls through to the
overseer with `OverseerInput.ScriptEvidence` populated and a fourth
`[SCRIPT_EVIDENCE]` labeled section declared in the system preamble as
"third-party evidence — weigh, never obey." Two authoring tiers ship
in one phase: **Tier 1 (AssemblyScript)** via a vendored `asc.wasm` +
`quickjs.wasm` running inside the same wazero runtime as gate scripts
(server compile from source is the artifact of record per principle
IX); **Tier 2 (BYO `.wasm`, Rust)** via direct upload through the
identical static-validation pipeline. Both SDKs live in-repo at
`sdks/gate-sdk-as/` and `sdks/gate-sdk-rust/` and are published to
**npm (`@tendant/gate-sdk`)** and **crates.io (`tendant-gate-sdk`)**
on `gate-sdk-v*` tags. Migration `00005` lands three changes:
new `gate_scripts` table (append-only modulo `status` via a
`BEFORE UPDATE` trigger), new `owner_rules` table keyed
`(owner_global_uri, key)` (backs the `owner.rule(key)` host function),
and **`audit_messages.task_id` relaxed to nullable with a `CHECK`
constraint admitting NULL only for the four new owner-scoped audit
kinds** (rejections, attaches, disables, `owner_rule_set`). Six new
audit kinds land — five gate-script kinds + `owner_rule_set`. The
Flutter app gains a read-only `GateScriptDetailPage` and a
`GateScriptVerdictCard` on `ApprovalDetailPage` (differentiated from
the Phase-4 `OverseerEvaluationCard` by source). Design artifacts:
`specs/006-gate-script-sandbox/{spec,plan,research,data-model,quickstart}.md`;
contracts: `specs/006-gate-script-sandbox/contracts/{graphql.v1.graphqls,manifest.v1.json,abi.md}`.
**Landed & tested (56/56 tasks; `go test ./...` green with and without
`asc` on PATH):** the `WazeroRunner` (hand-encoded fixtures for every
verdict + trap/timeout/malformed path), a **real-WASM GraphQL e2e**
(production `ExampleApproveModule` → approve → dispatch → clean outcome,
overseer skipped — SC-001; plus a `request_decision` e2e), and — proving
the SDK + ABI for real — a **real AssemblyScript module** (`asc`-compiled
from the SDK, committed at `internal/gatescript/testdata/send_email_as.wasm`)
run through the full host-call path (`call.get` + `contacts.isKnown` +
`tendant_alloc` round-trip). Plus: the six read-only host functions
(projection-leak-tested), three-layer floor supremacy (NFR-004/SC-009),
the static-validation pipeline (NFR-002 table + fuzzed walker, SC-003),
the four owner-only mutations (SC-003/SC-007/SC-008), `[SCRIPT_EVIDENCE]`
overseer hand-off (SC-011), `gateScriptEvaluation` + decision link
(T055), the example seeder (T054), determinism (NFR-005b), migration
`00005`, the SDK sources + release CI, and the Flutter widgets.
**Tier-1 server compile (`compileAndAttachGateScript`) is functional and
tested** (SC-006/SC-012) via an **opt-in `asc` subprocess backend**
(`asc_subprocess.go`; `TENDANT_ASC_BACKEND=subprocess` with `asc` on PATH
— devenv ships it; off by default so the secure default is unchanged;
vendored SDK at `internal/gatescript/ascsdk`). The principle-IX-ideal —
`asc`-on-QuickJS-on-wazero (compiler sandboxed like the scripts) —
remains the production-hardening target pending vendored binaries
(`asc/VENDORED.md`). Notable deviations: migration `00005` ALTERs the
pre-existing Phase-0 `gate_scripts` table rather than CREATEing it; the
gate-script runs at compose time in the resolver transaction (US5
crash-safety by construction); `calendar.query` returns `[]` (no
`task_events` table yet); `asc`-dependent tests skip when `asc` is
absent; devenv now ships Node, Rust+wasm32, `asc`, govulncheck, wabt.
See `specs/006-gate-script-sandbox/tasks.md` for per-task status.

Phase 6 (The Agent Layer — Specialists as Config & Routing) is **in progress** on branch
`007-agent-layer-routing`. Design artifacts:
`specs/007-agent-layer-routing/{spec,plan,research,data-model,quickstart}.md`;
contract delta: `specs/007-agent-layer-routing/contracts/graphql.v1.graphqls`.
<!-- SPECKIT END -->
