# tendant

One-line description goes here.

## Tech stack

| Concern | Choice |
|---|---|
| Language | Go 1.26 (devenv pins `go_1_26`; `go.mod` directive `go 1.25` is the floor) |
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

Phase 7 (The Intake Edge — Connectors & Dispositions) is **complete & green** on
branch `008-intake-edge-connectors` (`go build` + `go test ./...` pass across all
API packages). Two new trusted packages land: `internal/connector` (the
source-adapter seam, mirrors `internal/push` — `Connector` interface + `Registry`)
and `internal/intake` (the in-edge: the versioned `PotentialTaskSignal` contract,
the disposition router, idempotent ingest, the DBOS-scheduled poll, and the
scheduler glue). The dependency points inward — `connector` imports `intake`,
never the reverse — so a new source is one file in `internal/connector` + a
registry entry and **zero** changes to `internal/intake` (Principle I, by
construction). The base set ships in two tiers (the push APNs/FCM precedent):
**fully implemented + E2E-tested, zero-credential** (`webhook-in`, `rss` via
stdlib `encoding/xml`); the **OAuth exemplar** (`gmail` — list/get over stdlib
`net/http`, live call behind a `messageFetcher` seam, token refresh + sealed
`source_credentials` via `internal/crypto`); and **stub providers** (`calendar`,
`imap` — emit nothing; `imap`'s real client is the lone deferred dep-approval).
Polling is a **DBOS dynamic schedule** (`intake:<connectorID>`, one per enabled
connector, DB-backed + crash-recovered on `Launch`; boot `RehydrateSchedules`
re-creates them). The per-emission **disposition** is the privacy/cost firewall:
`forced_task` → accepted task directly (skip is-task, no model); `rich_event` →
auto-accept iff `confidence ≥ confidence_floor` **AND** `stakes_hint ≤
stakes_ceiling` (conservative fail-closed defaults, NFR-003) yielding a derived
**enrich-only** task (`accepted`, runs the chain, EXECUTION routes to the owner;
the relaxed `accepted→dismissed` edge via `lifecycle.TransitionIntake` makes it
dismissible), else hold `PROPOSED`; `llm_judge` → hand the **normalized payload
only** (NFR-001) to the triage seam as labeled `[INTAKE_SIGNAL]` evidence
(Principle IV), bounded by a per-poll cap (`llm_judge_per_poll`, default 5;
overflow holds `PROPOSED` with no model call + `llm_judge_capped` audit). Triage
is a `TriageJudge` seam (nil = secure default, `llm_judge` holds `PROPOSED` with
no model). Idempotency rides the Phase-0 `UNIQUE(connector_id, idempotency_key)`
(`ON CONFLICT DO NOTHING`) plus a dispose-time task-exists guard, so a kill
mid-poll resumes to the same task set (SC-005). `Task.autonomy` reports
`ENRICH_ONLY` for auto-accepted intake tasks (resolver-derived, no stored dial);
provenance is a **reference, not a content copy**, surfaced via the existing
`Task.provenance` + a Flutter `ProvenanceCard`. GraphQL is strictly additive
(**Path 1**): `Connector` type, owner-only `connectors` query +
`setConnectorConfig`/`enableConnector` mutations (all `auth.RequireOwner` FIRST —
rejected before any DB access; the wiring reaches the registry + scheduler via
`graph.ConnectorDeps` func values so `graph` imports neither package). The owner
controls integrations from a Flutter Connectors settings list. Six intake audit
kinds land (`signal_emitted`/`signal_deduped`/`llm_judge_capped` pre-task with
NULL `task_id`; `disposition_applied`/`intake_auto_accepted`/`llm_judge_invoked`
task-scoped); `/healthz` gains intake rate counters (overseer parity). **Zero new
deps** (stdlib `net/http`/`encoding/xml`/`net/mail`; `robfig/cron` transitive via
DBOS); **one migration** (`00006`) extending the Phase-5
`audit_messages.task_id`-NULL CHECK allowlist for the three pre-task kinds + a
partial unprocessed-signal index. Webhook ingress (`POST
/intake/webhook/<id>`) + OAuth callback (`GET /oauth/callback/gmail`) mount on the
chi router. Design artifacts:
`specs/008-intake-edge-connectors/{spec,plan,research,data-model,quickstart}.md`;
contracts: `specs/008-intake-edge-connectors/contracts/{signal.v1.md,graphql.v1.graphqls}`.
See `specs/008-intake-edge-connectors/tasks.md` for per-task status.

Phase 8 (Calibration & the Earned-Autonomy Ratchet) is **complete & green** on
branch `009-calibration-autonomy-ratchet` (`go build ./...` + `go test ./...`
pass across all API packages; `gofmt`/`go vet` clean). A single
`internal/calibration` subsystem
reads the audit DAG on both edges and drives the **asymmetric per-tool ratchet**:
inferred-clean recording + a `matured_at` (stamped `at + window` at insert) +
a per-row **routine fingerprint**; a DBOS-scheduled **sweep** (`calibration:sweep`,
mirrors the Phase-7 intake scheduler) emits a `PromotionProposal` when a
`(tool, routine)`'s matured-clean **ratio over the last N** clears a configurable
threshold; the owner accepts via the new owner-only `respondToPromotion` →
the per-tool **continuous `tools.trust_score`** (new, `0.0–1.0`; the discrete
`AutonomyLevel` enum becomes derived bands `NONE`/`EXECUTE_GATED`/`EXECUTE_AUTO`)
jumps into the auto band **and** a `tool_routine_grants` row is written.
**Reflexive demotion** (a bad outcome, `cancelTask`, or the new owner-only
`flagOutcome`) is automatic — proportional score decrement clamped at the
`EXECUTE_GATED` baseline + revoke the routine's grant — no mutation/approval.
A **new gate layer** (after the floor, in the overseer's slot, via a pure
`RoutineGrantLookup` seam) auto-approves only when the tool is `EXECUTE_AUTO`
**AND** the call's fingerprint has a live grant **AND** the floor cleared —
floor supremacy (III) + no self-escalation (IV) preserved. The **intake half**
tunes from dismissals (`tasks.intake_signal_id → intake_signals.connector_id`):
derived effective-threshold tightening + a labeled `[DISMISSAL_HISTORY]` section
to the Phase-6 triage seam. GraphQL is **Path 1** (additive `respondToPromotion`,
`flagOutcome`, both `auth.RequireOwner` FIRST) **+ Path 2** (deprecate the
Phase-2 `decidePromotion` stub). **One migration** (`00007`: `tools.trust_score`,
`tool_outcomes.routine_fingerprint`, `tool_routine_grants`; no CHECK-allowlist
change — four new audit kinds are task-scoped); **zero new deps**. The
`Engine` (recording + reflexive demotion + `FlagBad` + sweep) is injected into
the tool-call workflow (clean→`RecordOutcome`, bad→`RecordBad`+demote), the
cancel path (`DemoteForCancel`), and `flagOutcome`; the gate's pure
`autonomyApprove` sits after the floor and script terminal verdicts. The owner
config knobs are env-driven (`TENDANT_CALIBRATION_*`, `buildCalibrationConfig`
in `cmd/tendant`). The Flutter app gains a `PromotionProposalCard` and an
autonomy/grant readout on the read-only `ToolDetailPage`. **Landed & tested:**
pure score/fingerprint unit tests, gate `autonomy_test` + `floor_supremacy_test`
(ordering invariant — grant lookup never consulted before the floor), DB-backed
calibrator tests (eligibility/min-sample/ratio/dedupe, maturation veto FR-004,
demotion clamp + grant revoke, `GetToolForUpdate` serialization), the
`respondToPromotion` agent-denied authz e2e (US5/NFR-004), and a US1+US4 e2e
(a promoted+granted floor-clearing routine auto-approves while a stranger
recipient still gates — SC-004). The only open task is T047 (manual
quickstart run against a live core). Design
artifacts: `specs/009-calibration-autonomy-ratchet/{spec,plan,research,data-model,quickstart}.md`;
contract delta: `specs/009-calibration-autonomy-ratchet/contracts/graphql.v1.graphqls`.
<!-- SPECKIT END -->
