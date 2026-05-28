---
description: "Task list — Phase 2: Operator Edge & the Wake Channel"
---

# Tasks: Phase 2 — Operator Edge & the Wake Channel

**Input**: Design documents from `specs/003-operator-edge-wake/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/graphql.v1.graphqls, contracts/versioning-policy.md, quickstart.md

**Tests**: INCLUDED — the spec's success criteria (SC-001…SC-011) require verifiable behaviour. Server tests use `testcontainers-go` + the existing `internal/testutil` helper; Flutter tests use `flutter_test` + widget goldens where useful.

**Organization**: tasks grouped by user story. **US1 (P1) is the MVP** — backgrounded-phone push wake (LogProvider stub is sufficient for CI; real-device verification is a separate, post-merge step at SC-001). The Foundational phase carries the bulk of the shared infrastructure (auth, dispatcher, push seam, schema additions, migration); user stories add the resolver + integration test for their slice plus, where required, the Flutter UI.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no incomplete-task deps)
- **[Story]**: US1–US5 (user-story phases only)
- Module roots: `db/` = `github.com/bcnelson/tendant/db`; `services/api/` = `github.com/bcnelson/tendant/services/api`; Flutter at `apps/mobile/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: confirm new dependencies and the Flutter codegen toolchain. Server has no new toolchain — gqlgen, sqlc, goose all unchanged from Phase 0/1.

- [X] T001 Confirm dependency approval per `plan.md § Dependency Flags`. Record the approval timestamp in `plan.md` (one-line note appended below the flag block). Server deps: `github.com/sideshow/apns2`, `firebase.google.com/go/v4`. Flutter deps: ferry stack, riverpod, drift, go_router, flutter_secure_storage, firebase stack, flutter_local_notifications, connectivity_plus, build_runner. No tasks under T002+ proceed until approval is recorded.
- [X] T002 [P] Update `/apps/mobile/pubspec.yaml` per `research.md` R5: enable the Phase 2 dependency block (`ferry`, `gql_*_link`, `ferry_flutter`, `flutter_riverpod`, `drift`, `go_router`, `flutter_secure_storage`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`); add `dev_dependencies` for `build_runner`, `ferry_generator`, `drift_dev`. Run `flutter pub get` from `/apps/mobile/` and commit `pubspec.lock`.
- [X] T003 [P] Add `/apps/mobile/build.yaml`: configure `ferry_generator|graphql_builder` with `schema: tendant|graphql/schema.graphql` and `extensions: [.graphql]` from `graphql/`; configure `drift_dev|preparing_builder` and `drift_dev|drift_dev` for the outbox schema (path `lib/core/offline/outbox.dart`). Output goes to `lib/__generated__/`.
- [X] T004 [P] Add `/apps/mobile/graphql/schema.graphql` as a copy of `/services/api/graph/schema.graphqls` (post-T029). For development ergonomics, a `just` target `just sync-flutter-schema` copies the file; CI runs the same target and fails on diff (drift gate). For T004 itself, create the file with the Phase 0/1 schema content as a placeholder; T029 will overwrite once the Phase 2 schema is live.
- [X] T005 Update `/compose.yaml` to define `TENDANT_SETUP_SECRET` as a build-arm dev secret (e.g., literal `"dev-setup-2026-05-28"` for local) so `make up` produces a reproducible pairing flow. Document the rotation procedure for production deployments in a one-paragraph note in `/README.md` (or in `quickstart.md` if the repo has no top-level README change yet).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: migration, sqlc queries, the four new internal packages (`auth`, `realtime`, `push`, `inbox`), the additive schema in `graph/schema.graphqls`, the regenerated gqlgen, the durable wiring for the push queue, and the server-wiring updates (auth middleware on `/graphql`, WS transport, dispatcher startup). **⚠️ Blocks all user stories.**

### Migration & sqlc

- [X] T006 Author `/db/migrations/00003_operator_edge_wake.sql` per `data-model.md`:
  - `-- +goose Up`:
    - `CREATE TABLE sessions (id, principal_id REFERENCES principals(id), token_hash bytea UNIQUE, display_name, created_at, last_seen_at, revoked_at)`.
    - `CREATE INDEX idx_sessions_principal ON sessions(principal_id) WHERE revoked_at IS NULL`.
    - `ALTER TABLE agent_assignments ADD COLUMN to_principal text`.
    - `CREATE INDEX idx_assign_to_principal ON agent_assignments(to_principal) WHERE resolved_at IS NULL`.
  - `-- +goose Down`: inverse in inverse order (drop index, drop column; drop index, drop table).
- [X] T007 [P] Add `/services/api/internal/db/migrate_phase2_test.go` (reuses `internal/testutil`): apply 00001 + 00002 + 00003; assert `sessions` table exists with the expected columns + the partial index; assert `agent_assignments.to_principal` column exists + the partial index; run down then up; assert idempotency.
- [X] T008 [P] Add `/services/api/internal/db/queries/sessions.sql` with sqlc directives: `IssueSession(principal_id, token_hash, display_name) RETURNING *`; `FindSessionByTokenHash(token_hash) RETURNING *` (only non-revoked); `RevokeSession(id) RETURNING *`; `ListActiveSessionsForPrincipal(principal_id) RETURNING *`; `TouchSessionLastSeen(id)` (updates `last_seen_at = now()`).
- [X] T009 [P] Add `/services/api/internal/db/queries/device_tokens.sql`: `UpsertDeviceToken(token, owner_id, platform) RETURNING *` (`INSERT ... ON CONFLICT (token) DO UPDATE SET owner_id = EXCLUDED.owner_id, platform = EXCLUDED.platform`); `DeleteDeviceToken(token, owner_id)`; `ListDeviceTokensForPrincipal(owner_id) RETURNING *`; `DeleteDeviceTokensByValue(tokens text[])` (bulk prune on invalid).
- [X] T010 [P] Add `/services/api/internal/db/queries/decisions.sql`: `GetPendingDecisionByID(id) RETURNING *`; `ListOpenPendingDecisionsForViewer(viewer_global_uri) RETURNING *` (placeholder — Phase 3 will tighten the viewer scope rules; Phase 2 owner-only returns all open rows).
- [X] T011 [P] Extend `/services/api/internal/db/queries/assignments.sql` (from Phase 1) with `SetAssignmentRecipient(id, to_principal)` (`UPDATE agent_assignments SET to_principal = $2 WHERE id = $1 RETURNING *`); `GetAgentAssignmentByID(id) RETURNING *`; `ListOpenAssignmentsForRecipient(to_principal) RETURNING *`.
- [X] T012 [P] Add `/services/api/internal/db/queries/inbox.sql` per `research.md` R11: `ListInbox(viewer_global_uri, cursor_created_at, cursor_id, lim)` — `UNION ALL` over `pending_decisions` (open) and `agent_assignments` (open AND `to_principal = $1`), keyset-paginated by `(created_at DESC, id DESC)`, returning `(id, kind, task_id, created_at)`.
- [X] T013 Run `sqlc generate` from `/services/api/` and commit the regenerated `/services/api/internal/db/sessions.sql.go`, `device_tokens.sql.go`, `decisions.sql.go`, `inbox.sql.go`, the updated `assignments.sql.go`, and any `models.go` changes (new `Session` row type, new `AgentAssignment.ToPrincipal` field). Verify `go build ./...` from repo root.

### Auth package (central decision point + session middleware)

- [X] T014 Add `/services/api/internal/auth/principal.go`: typed `Principal { ID uuid.UUID; GlobalURI string; DisplayName string; Kind string }` and a `ctx`-key helper `WithPrincipal(ctx, p) ctx` / `FromContext(ctx) (*Principal, bool)`. The principal struct deliberately matches the gqlgen `Principal` interface so resolvers consume the same shape.
- [X] T015 Add `/services/api/internal/auth/session.go`: `MintToken() string` (`crypto/rand` → 32 bytes → `base64.RawURLEncoding`); `HashToken(raw string) []byte` (`sha256(raw)`); `IssueSession(ctx, q, principalID, displayName) (Session, raw string, err error)` writes the row and returns the raw token *exactly once* alongside the row; `RevokeSession(ctx, q, sessionID) (Session, err error)`; `Resolve(ctx, q, raw string) (*Principal, *db.Session, error)` does `FindSessionByTokenHash(sha256(raw))` and joins `principals` for the principal struct; returns `(nil, nil, ErrUnauthorized)` if not found or revoked.
- [X] T016 [P] Add `/services/api/internal/auth/setup_secret.go`: in-process `Armed` state initialized from `TENDANT_SETUP_SECRET` at boot; `Consume(secret string) error` (returns `ErrBadSetupSecret` on mismatch; returns `ErrAlreadyConsumed` on second call; single-use per boot per research R6). Thread-safe (`sync.Mutex`).
- [X] T017 Add `/services/api/internal/auth/middleware.go`: chi `Middleware` that reads `Authorization: Bearer <token>` from the request, calls `Resolve`, attaches the principal to `ctx` via `WithPrincipal`, and runs the next handler. Unauthenticated requests are allowed through *with no principal in context* — resolvers that require a principal fail with `UNAUTHORIZED` via the `Can(...)` decision (so the GraphQL playground / introspection still works without a bearer). Also calls `TouchSessionLastSeen` opportunistically (in a goroutine) to update `last_seen_at`.
- [X] T018 [P] Add `/services/api/internal/auth/ws_init.go`: gqlgen `transport.Websocket.InitFunc` signature; reads `authorization` (or `Authorization`) from the `connection_init` payload, calls `Resolve`, returns a `ctx` with `WithPrincipal` set. Returns a `4401` close on invalid bearer (graphql-transport-ws convention).
- [X] T019 [P] Add `/services/api/internal/auth/can.go`: `Can(ctx, p *Principal, action string, target any) bool`. Phase 2 implementation: if `p == nil` return `false`; otherwise return `true` for all targets owned by the principal (in Phase 2 there is exactly one owner). The decision-point is the federation seam (FR-033) — keep the signature stable. Target shapes covered: `*db.Task`, `*db.AgentAssignment`, `*db.PendingDecision`, `*db.Tool`, `*db.Session`, and the typed refs `TaskRef`/`SessionRef` for pre-load auth. Unknown target types return `false` and `slog.Warn` (so adding a new target without a `Can(...)` clause is loud).
- [X] T020 [P] Add `/services/api/internal/auth/registry.go`: `Registry` mapping `(GraphQL type, field name) → (action, targetExtractor)`; `MustRegister(typeName, fieldName, action, extractor func(parent any) any)`. A startup-time assertion runs after gqlgen builds the executable schema: every operator-edge type/field (everything declared in `contracts/graphql.v1.graphqls` for Phase 2) MUST have a registry entry — missing entries panic at boot (caught in tests; SC-005 verification).
- [X] T021 [P] Add `/services/api/internal/auth/auth_test.go` (testcontainers-backed):
  - `IssueSession` writes a row; the returned raw token's `sha256` matches `token_hash`; calling `Resolve` with the raw token returns the principal.
  - `RevokeSession` sets `revoked_at`; subsequent `Resolve` returns `ErrUnauthorized`.
  - `setup_secret.Consume` succeeds once, fails on second call with `ErrAlreadyConsumed`, fails on mismatch with `ErrBadSetupSecret`.
  - `Can` returns `true` for owner-owned targets, `false` for nil principal, `false` for unrecognized target types (with a logged warning verified by capturing slog output).
  - `Registry` panics if a registered GraphQL field is missing from the operator-edge schema, or if any operator-edge schema field has no entry (covers SC-005).

### Push package (provider seam + selector + LogProvider — fan-out implementation lives in US1)

- [X] T022 Add `/services/api/internal/push/body.go`: closed struct `PushBody { DeepLinkID string; GenericTitle string }`. **No other fields.** A package-level test (`body_test.go`) asserts via reflection that the struct has exactly two exported fields — this is the structural content-leak prevention for FR-015 / SC-003.
- [X] T023 [P] Add `/services/api/internal/push/provider.go`: interface `Provider { Send(ctx, token string, platform db.DevicePlatform, body PushBody) error; IsTokenInvalid(err error) bool; Name() string }`. Also define `ErrTransient` and `ErrTokenInvalid` typed errors providers return; selectors and the fan-out worker switch on these for retry vs prune.
- [X] T024 [P] Add `/services/api/internal/push/selector.go`: `Selector { APNs, FCM, Log Provider }`; `Pick(platform db.DevicePlatform) Provider` per research R2; if both APNs and FCM are nil, return `Log` for every platform.
- [X] T025 [P] Add `/services/api/internal/push/log_provider.go`: `LogProvider{}` with a `Name() string { return "LogProvider" }`, `IsTokenInvalid(err) bool { return false }` (the stub never invalidates), and `Send` that emits a single structured `slog.Info("push.LogProvider.Send", "token", token, "platform", platform, "title", body.GenericTitle, "deep_link_id", body.DeepLinkID)`. Returns nil.
- [X] T026 [P] Add `/services/api/internal/push/urgency.go`: `ShouldPush(kind string) bool` per spec FR-016. Phase 2 conservative rule: `pending_decision` → true; `agent_assignment` → true *iff* `to_principal` is non-null (the assignment is directed); otherwise false. Phase 3+ can tighten via additional cases. Pure function over the inbox row's `kind` plus a small struct.
- [X] T027 [P] Add `/services/api/internal/push/push_test.go` covering:
  - `body_test.go` reflection assertion that `PushBody` has exactly two fields.
  - `LogProvider.Send` emits the expected slog record with no other fields (captured via a `slog.Handler` test harness; SC-003 verifiable here).
  - `Selector.Pick` routes platforms correctly; falls back to `Log` when APNs+FCM are nil.
  - `ShouldPush` returns the urgency table values.

### Realtime package (LISTEN dispatcher — subscription resolvers wire in US2)

- [X] T028 Add `/services/api/internal/realtime/event.go`: `EventEnvelope { Topic string; ID string }` parsed from `pg_notify('tendant_events', {topic, data: {id}})` JSON.
- [X] T029 [P] Add `/services/api/internal/realtime/subscriber.go`: `Subscriber { Principal *auth.Principal; Match func(topic, id string) bool; Out chan<- EventEnvelope; DroppedCount atomic.Int64 }`; helpers `NewInboxSubscriber(p, capacity)` (matches every event), `NewTaskChangedSubscriber(p, taskID, capacity)` (matches `topic=="task" && id==taskID`, or all task events when taskID is nil). Channel capacity 32.
- [X] T030 Add `/services/api/internal/realtime/dispatcher.go`: `Dispatcher { mu sync.RWMutex; subs map[*Subscriber]struct{}; conn *pgx.Conn; q *db.Queries; canFn func(p *auth.Principal, action string, target any) bool }`. Constructor `New(ctx, pool, q, canFn) (*Dispatcher, error)` — acquires one dedicated `pgx.Conn` from the pool (held for the dispatcher's lifetime), issues `LISTEN tendant_events`. `Run(ctx)` loop: `conn.WaitForNotification(ctx)` → parse envelope → in a goroutine, call `dispatch(env)`. `Register(s) func()` returns a deregister closure. `Stop(ctx)` releases the conn back to the pool after draining (research R4).
- [X] T031 [P] Add `dispatch` logic in `dispatcher.go`: load the row by topic — `task` → `GetTaskByID`, `assignment` → `GetAgentAssignmentByID`, `decision` → `GetPendingDecisionByID`. For each registered subscriber whose `Match(env.Topic, env.ID)` is true and `canFn(sub.Principal, "view", loadedTarget)` is true, try `sub.Out <- env` non-blocking; on full channel increment `DroppedCount` and continue.
- [X] T032 [P] Add `/services/api/internal/realtime/dispatcher_test.go` (testcontainers + pgx + a fake pgx-pool-backed dispatcher driver):
  - Register 3 subscribers (matchers: all-inbox, taskChanged(A), taskChanged(B)). Insert an `agent_assignment` for task A. Assert the all-inbox subscriber + taskChanged(A) subscriber receive the envelope; taskChanged(B) does not.
  - Mid-stream auth revocation: register a subscriber; revoke its principal's session; insert an event; assert no envelope arrives on the subscriber's channel (silently dropped via `canFn` re-check).
  - Slow-subscriber drop: fill a subscriber's channel; insert 5 more events; assert `DroppedCount == 5` and no goroutine leak (verified via runtime.NumGoroutine snapshot before/after `Stop`).

### Inbox package

- [X] T033 Add `/services/api/internal/inbox/inbox.go`: `Item` discriminated union shape `{ Kind string; ID uuid.UUID; TaskID uuid.UUID; CreatedAt time.Time }`. `List(ctx, q, viewerGlobalURI, cursor, limit) ([]Item, nextCursor, err)` — calls sqlc `ListInbox`, decodes the cursor string `<base64(timestamp + uuid)>` ↔ struct, encodes `nextCursor` from the last row.
- [X] T034 [P] Add `/services/api/internal/inbox/assemble.go`: `Assemble(ctx, q, items []Item) ([]InboxItemPayload, error)` — for each item, loads the typed row from the matching base table (`pending_decisions` with `kind` discriminator → `ApprovalRequest` / `AgentQuestion` / `PromotionProposal`; `agent_assignments` → `AgentAssignment`) and returns a slice of typed Go structs that implement gqlgen's `InboxItem` union (`Is_InboxItem()` markers added in T037).
- [X] T035 [P] Add `/services/api/internal/inbox/inbox_test.go`: insert 2 pending_decisions (kinds: `approval_request`, `agent_question`) + 2 agent_assignments routed to the owner. Call `List` + `Assemble`; assert the slice contains 4 items, ordered by `created_at DESC, id DESC`, with `__typename`-equivalent fields (`Kind`) matching the source. Test the keyset cursor: page 1 with `limit=2` returns the latest two; page 2 with the returned `nextCursor` returns the older two; the assembled task IDs match the inserts.

### GraphQL schema additions + gqlgen regenerate

- [X] T036 Update `/services/api/graph/schema.graphqls` to match `specs/003-operator-edge-wake/contracts/graphql.v1.graphqls` (the Phase 2 additive surface) in full. Preserve the schema header comment; add a new comment line pointing to `specs/003-operator-edge-wake/contracts/versioning-policy.md`. (Depends T006, T013.)
- [X] T037 Update `/services/api/gqlgen.yml`:
  - Add `models:` entries for `Session`, `SessionMintResult`, `Tool`, `Artifact`, `Mandate`, `ApprovalRequest`, `AgentQuestion`, `PromotionProposal`, `Notification`, binding to typed model structs in `graph/model/`.
  - Add `resolver: true` for `Task.openAssignment` (already there), `Query.inbox`, `Query.pendingDecision`, `Query.agentAssignment`, `Query.sessions`, and every new mutation/subscription field.
  - Confirm the `InboxItem`, `ApprovalPayload`, `PendingDecision` interfaces/unions get the standard gqlgen treatment (autobind off; resolvers do the type discrimination).
- [X] T038 Run `gqlgen generate` from `/services/api/`. Commit the regenerated `/services/api/graph/generated.go`, the updated `graph/model/*`, and the **new stub resolver files** (subscription stubs land here too — gqlgen scaffolds them empty, US-phase tasks fill them).
- [X] T039 [P] Add `/services/api/graph/auth_registration.go`: invokes `auth.MustRegister(...)` for every operator-edge field defined in the Phase 2 SDL (per research R7 and T020). Called from `cmd/tendant/main.go` before `dbos.Launch` (registry assertion runs at boot; missing entries panic).

### Chain workflow change — set to_principal + push.Enqueue

- [X] T040 Update `/services/api/internal/chain/workflow.go` step that inserts an `agent_assignment` row (T016b from Phase 1): in the same SQL tx, call `SetAssignmentRecipient(assignmentID, ownerGlobalURI)` (the seeded owner's `global_uri`). Then, *outside* the tx but inside the same DBOS step, call `push.Enqueue(ctx, dbosClient, queueName, push.JobPayload{TaskID, AssignmentID, RecipientGlobalURI, DeepLinkID: assignmentID, Title: "tendant"})`. (Real `push.Enqueue` stub lands here; the queue worker that consumes it lands in US1 T046.)
- [X] T041 [P] Add `/services/api/internal/chain/workflow_push_enqueue_test.go`: seed a task via `core.CreateTask`, walk the workflow to its first assignment, assert a row appears in the DBOS `push` queue (the DBOS introspection API exposes queue entries; if not, assert via the audit log that a `push_attempted`'s precursor `push_enqueued` was written). Assert `agent_assignments.to_principal` equals the seeded owner's `global_uri`.

### Durable wiring + server wiring + main boot

- [X] T042 Update `/services/api/internal/durable/dbos.go`:
  - Add `RegisterPushQueue(dctx, q, providerSel)` that calls `dbos.NewQueue(dctx, "push", dbos.QueueConfig{MaxAttempts: 5, Backoff: dbos.ExponentialBackoff{...}, Workers: 4})` and registers the queue's step function (the worker body lands in US1 T046).
  - `Launch` order: register chain workflow first (Phase 1), then `RegisterPushQueue`, then `dbos.Launch`.
- [X] T043 Update `/services/api/internal/server/server.go`:
  - Construct `auth.Middleware(q)` and apply to `r.Route("/graphql", ...)` only (leave `/playground` + `/healthz` unauthenticated).
  - Construct `transport.Websocket{KeepAlivePingInterval: 10s, InitFunc: auth.WebsocketInitFunc(q)}` and add via `srv.AddTransport`.
  - Accept a `realtime.Dispatcher` in `New(...)`; expose it to subscription resolvers via `graph.Resolver.Dispatcher`.
  - Accept a `push.Selector` and a `dbos.Queue("push")` handle; expose to mutation resolvers via the Resolver struct.
- [X] T044 Update `/services/api/cmd/tendant/main.go`:
  - Read `TENDANT_SETUP_SECRET` env var → `auth.SetupSecret.Arm(s)`.
  - Construct the push `Selector` from `TENDANT_APNS_*` / `TENDANT_FCM_*` env vars (APNs and FCM providers wired in US1 T047/T048); fall back to `LogProvider` when env is absent (`slog.Info("push provider","provider","LogProvider")` per quickstart).
  - Boot order: pool → goose Up → seed owner → `durable.Init` → register chain → `RegisterPushQueue` → `durable.Launch` → start `realtime.Dispatcher.New` + goroutine `Run` → `server.New(pool, dctx, dispatcher, pushSel, pushQueue)` → `auth_registration.go` registry init → `http.ListenAndServe`. Graceful shutdown also stops the dispatcher.
- [X] T045 [P] Add `/services/api/internal/server/server_auth_test.go`: integration test that `/graphql` without a bearer returns the same JSON shape as with an authenticated request *but with no principal* — so introspection still works (per the design note in T017); but resolvers that need a principal return a typed `UNAUTHORIZED` GraphQL error. Test that `/healthz` and `/playground` work without a bearer.

**Checkpoint**: foundation ready — sqlc + auth + dispatcher + push seam + schema + gqlgen + DBOS wiring + server middleware all in place. User stories now slot in their resolvers + integration tests.

---

## Phase 3: User Story 1 - Backgrounded-phone push wake (Priority: P1) 🎯 MVP

**Goal**: Complete Phase 1's chain produces an `AgentAssignment` → a push fires (LogProvider in CI; APNs/FCM with real credentials in the real-device addendum) → tap deep-links to the item → `completeTask` resumes the chain.

**Independent Test**: `just phase2-mvp` runs an end-to-end test that pairs a synthetic device, walks a task through the chain to an assignment, asserts (a) the push fan-out step ran in DBOS, (b) the LogProvider emitted exactly one record with only the deep-link id + generic title, (c) the assignment is fetchable via `agentAssignment(id:)`, and (d) calling `completeTask` advances the chain. Real-device verification is the addendum in `quickstart.md` — not required for CI but required to declare SC-001 met.

### Server mutations + push fan-out

- [X] T046 [US1] Add `/services/api/internal/push/push.go`:
  - `JobPayload { TaskID, AssignmentID, RecipientGlobalURI, DeepLinkID, Title string }` (the message on the DBOS queue).
  - `Enqueue(ctx, dctx dbos.DBOSContext, payload JobPayload) error` — calls `dbos.Enqueue(dctx, "push", payload)`.
  - The queue's worker function: load device tokens via `ListDeviceTokensForPrincipal(payload.RecipientGlobalURI)`; for each token, `selector.Pick(platform).Send(ctx, token, platform, PushBody{DeepLinkID, Title})`; classify result via `errors.Is(err, ErrTokenInvalid)` → call `DeleteDeviceTokensByValue([token])`, write `push_attempted` audit row with `outcome="token_invalid"`; on `ErrTransient` → return error (DBOS retries); on nil → write `push_attempted` audit row with `outcome="ok"`.
  - Registered with `RegisterPushQueue` in T042. Pure function over queue handle + queries; the DBOS step shape ensures crash-safe retries (research R3).
- [X] T047 [P] [US1] Add `/services/api/internal/push/apns.go`: `APNs` struct wrapping `apns2.Client` (one client per process); `Send(ctx, token, _, body) error` builds the alert+content-available payload per research R9; classifies APNs response statuses (`BadDeviceToken` / `Unregistered` → `ErrTokenInvalid`; `TooManyRequests` / 5xx → `ErrTransient`; other 4xx → permanent error with the response code). Provider config (`KeyID`, `TeamID`, `BundleID`, `KeyPath`, `Production` bool) sourced from `TENDANT_APNS_*` env vars in `cmd/tendant/main.go`.
- [X] T048 [P] [US1] Add `/services/api/internal/push/fcm.go`: `FCM` struct wrapping `firebase.google.com/go/v4/messaging.Client`; `Send(ctx, token, platform, body) error` builds the FCM v1 message per research R9 (notification + data + android.priority HIGH + apns.priority 10 + webpush.urgency high). Token-invalid classification: `messaging.IsRegistrationTokenNotRegistered(err)` → `ErrTokenInvalid`; transient → `ErrTransient`. Sources credentials from `GOOGLE_APPLICATION_CREDENTIALS` + `TENDANT_FCM_PROJECT_ID`.
- [X] T049 [US1] Add `/services/api/graph/mutation_pair_device.resolvers.go`: `PairDevice(ctx, setupSecret, displayName) (*model.SessionMintResult, error)`:
  - Validate `displayName` (non-empty, ≤200 chars).
  - `auth.SetupSecret.Consume(setupSecret)` — on error return `BAD_SETUP_SECRET`.
  - Resolve the owner principal (in Phase 2, the seeded owner from Phase 0).
  - `auth.IssueSession(ctx, q, ownerID, displayName) → (session, rawToken, err)`.
  - Write `session_issued` audit row in the same tx (`kind="session_issued"`, payload `{session_id, display_name, source:"pairDevice"}`).
  - Return `SessionMintResult{Session: session, Token: rawToken}`.
- [X] T050 [P] [US1] Add `/services/api/graph/mutation_register_device_token.resolvers.go`:
  - `RegisterDeviceToken(ctx, token, platform) (bool, error)` — calls `auth.FromContext` for the principal; validates token non-empty; calls `UpsertDeviceToken(token, principal.ID, platform)`; returns `true`. Errors with `UNAUTHORIZED` if no principal.
  - `UnregisterDeviceToken(ctx, token) (bool, error)` — calls `DeleteDeviceToken(token, principal.ID)`; returns `true`.
- [X] T051 [P] [US1] Add `/services/api/graph/query_sessions.resolvers.go`: `Sessions(ctx) ([]*model.Session, error)` — `ListActiveSessionsForPrincipal(principal.ID)` mapped to model.

### Server tests — push happy path + content-leak + token prune

- [X] T052 [US1] Add `/services/api/graph/pair_device_test.go`:
  - Arm a known `TENDANT_SETUP_SECRET`; call `pairDevice` via the GraphQL handler; assert the returned `token` is 43 base64-RawURL chars (32 bytes encoded); assert a `sessions` row exists with the matching `token_hash`; assert an `audit_messages` row with `kind="session_issued"` exists for the owner.
  - Call `pairDevice` again with the same secret; assert `BAD_SETUP_SECRET` (consumed).
- [X] T053 [P] [US1] Add `/services/api/graph/register_device_token_test.go`: pair a device (helper from T052); call `registerDeviceToken("test-token", IOS)`; assert one row in `device_tokens` for the owner principal. Call again with the same token; assert exactly one row (upsert).
- [X] T054 [P] [US1] Add `/services/api/internal/push/push_integration_test.go`:
  - Insert a device token; call `Enqueue` against the LogProvider with a known `JobPayload`; drive the DBOS queue worker; assert the LogProvider emitted exactly one `slog` record with fields `{token, platform, title="tendant", deep_link_id=<expected>}` and **no other fields** (parse the captured JSON and assert key set equality — this is SC-003).
  - Insert a token; install a provider that returns `ErrTokenInvalid` on first `Send`; enqueue; assert the token row is deleted from `device_tokens` and the `audit_messages` row has `outcome="token_invalid"` (SC-009).
  - Install a provider that returns `ErrTransient` on first call and nil on second; enqueue; assert two `push_attempted` audit rows (one transient, one ok), and DBOS step retried.
- [X] T055 [US1] Add `/services/api/graph/mvp_e2e_test.go` (end-to-end through the GraphQL handler):
  - Pair a device → register a stub token → `createTask("mvp")` → wait for the chain workflow to insert the first `AgentAssignment` (poll `task(id:).openAssignment` for ≤5 s).
  - Assert the LogProvider emitted exactly one record for the assignment.
  - Call `completeTask(taskId)` via the GraphQL mutation; assert the chain advances (state moves to `EXECUTING`, then `DONE` after subsequent slots resolve auto in Phase 1's human-only chain — for the MVP this test only asserts one assignment is resolved and the workflow advances past it).

### Flutter app — pairing → push receive → assignment view → completeTask

- [X] T056 [P] [US1] Replace `/apps/mobile/lib/main.dart` with a real bootstrap: `WidgetsFlutterBinding.ensureInitialized()`; `Firebase.initializeApp()`; read the session token from `flutter_secure_storage`; `runApp(ProviderScope(child: TendantApp(initialSession: token)))`. Move the old `HomePage` placeholder into a docs comment for reference (do not keep it as a route).
- [X] T057 [P] [US1] Add `/apps/mobile/lib/app.dart`: `TendantApp` widget that takes `initialSession`, constructs `GoRouter` from `core/router/routes.dart`, returns `MaterialApp.router(routerConfig: router)`.
- [X] T058 [P] [US1] Add `/apps/mobile/lib/core/auth/session_store.dart`: `SessionStore` with `Future<String?> read()`, `Future<void> write(String)`, `Future<void> clear()` backed by `flutter_secure_storage`. Riverpod provider exposes a stream of "current session token" (null = unpaired).
- [X] T059 [US1] Add `/apps/mobile/lib/core/auth/auth_link.dart`: ferry `Link` that prepends `Authorization: Bearer <token>` to HTTP requests by reading from `SessionStore`; constructs the `connection_init` payload `{authorization: "Bearer <token>"}` for the WS link. Returns no headers when unpaired.
- [X] T060 [P] [US1] Add `/apps/mobile/lib/core/graphql/client.dart`: builds the ferry `Client` — `gql_http_link.HttpLink('http://10.0.2.2:8080/graphql')` for Android emulator, override per platform; `gql_websocket_link.WebSocketLink(...)` for subscriptions (US2 attaches subscription handlers); `cache: Cache(...)` with sensible defaults; chains `AuthLink` (T059) in front. Riverpod provider exposes the singleton client.
- [X] T061 [P] [US1] Add `/apps/mobile/lib/core/notifications/messaging.dart`:
  - `messagingProvider` exposes the `FirebaseMessaging` instance.
  - On app startup (after pairing), `getToken()` → call `registerDeviceToken` mutation; subscribe to `onTokenRefresh` to re-register.
  - `onMessage` (foreground push): display a `flutter_local_notifications` banner so the user sees something even when the app is in front.
  - `onMessageOpenedApp` (tap on push when backgrounded): extract `deep_link_id` from the payload data; call `deep_link.dart` router (T062).
  - `getInitialMessage()` on app start: same handling, for the cold-launch-from-push case.
- [X] T062 [P] [US1] Add `/apps/mobile/lib/core/notifications/deep_link.dart`: `routeToInboxItem(String id)` calls `goRouter.push('/inbox/$id')`. Riverpod-scoped so it can resolve the current router.
- [X] T063 [US1] Add `/apps/mobile/lib/core/router/routes.dart`: `GoRouter` with routes `/pairing` (when no session), `/inbox`, `/inbox/:id` (resolves the InboxItem by id). A redirect guard reads `SessionStore` and routes unpaired → `/pairing`.
- [X] T064 [P] [US1] Add `/apps/mobile/lib/features/pairing/pairing_page.dart`: a `StatefulWidget` with a `TextField` for the setup secret + a `TextField` for the device display name; on submit, executes `pairDevice` via the ferry client, stores the returned token to `SessionStore`, and navigates to `/inbox`. Error states for `BAD_SETUP_SECRET` / network errors.
- [X] T065 [P] [US1] Add `/apps/mobile/graphql/pair_device.graphql`, `register_device_token.graphql`, `inbox.graphql`, `agent_assignment.graphql` (refetch), `complete_task.graphql`. Each is a single named operation. Run `dart run build_runner build --delete-conflicting-outputs` from `/apps/mobile/` and commit `lib/__generated__/`.
- [X] T066 [US1] Add `/apps/mobile/lib/features/inbox/inbox_page.dart`: at first render, runs the `Inbox` ferry query (operation from T065); renders a `ListView` of tiles via `InboxTile`. Switch on `InboxItem.__typename` — only `AgentAssignment` shows an actionable tile in Phase 2; the three `PendingDecision` kinds render a read-only "Decision (Phase 3)" placeholder tile per spec FR-022.
- [X] T067 [P] [US1] Add `/apps/mobile/lib/features/task/assignment_view.dart`: a `ConsumerStatefulWidget` parameterized by `assignmentId`; runs `AgentAssignment($id)` query; displays the `ask` and `gatheredContext`; a "Complete" button executes `completeTask(taskId:)`; on success, navigates back to `/inbox`.
- [X] T068 [P] [US1] Add `/apps/mobile/test/inbox_tile_test.dart`: widget test that an `InboxTile` rendered from an `AgentAssignment` shows the task title and the assignment stage; rendered from a `PendingDecision` shows the "Decision (Phase 3)" placeholder.
- [X] T069 [P] [US1] Add `/apps/mobile/test/pairing_page_test.dart`: widget test that submitting an empty setup secret shows a validation error; submitting a known-good secret with a stubbed ferry client navigates to `/inbox` and persists the token to a fake `SessionStore`.

**Checkpoint**: US1 complete. The MVP end-to-end works against the `LogProvider` stub in CI; on a real device with APNs/FCM credentials, the wake survives backgrounding (and per the addendum, force-quit).

---

## Phase 4: User Story 2 - Foregrounded subscription updates without polling (Priority: P2)

**Goal**: With the Flutter app foregrounded, a new inbox item appears in the UI within 2 seconds of its server-side commit, without polling.

**Independent Test**: With the Flutter app foregrounded on the inbox page, run `just seed-task TITLE="us2"`; the new tile appears within 2 s. Server-side, `internal/realtime/dispatcher_test.go` covers the dispatcher fan-out; this story adds the *subscription resolver* + *Flutter consumption* integration.

### Server: subscription resolvers + refetch queries

- [X] T070 [P] [US2] Add `/services/api/graph/query_inbox.resolvers.go`: `Inbox(ctx, first, after) ([]model.InboxItem, error)` — calls `inbox.List` then `inbox.Assemble` (T033/T034); returns the assembled slice. `auth.Can(ctx, "view", item)` filtering already happens at the SQL layer (FR-031) — this resolver does NOT re-filter post-fetch.
- [X] T071 [P] [US2] Add `/services/api/graph/query_refetch.resolvers.go`:
  - `PendingDecision(ctx, id) (model.PendingDecision, error)` — load via `GetPendingDecisionByID`; `auth.Can(... "view", row)` gate; return the discriminated typed result.
  - `AgentAssignment(ctx, id) (*model.AgentAssignment, error)` — load via `GetAgentAssignmentByID`; `auth.Can(... "view", row)` gate; return.
- [X] T072 [US2] Add `/services/api/graph/subscription.resolvers.go`:
  - `InboxItemArrived(ctx) (<-chan model.InboxItem, error)` — extracts principal from ctx (set by the WS init); registers a `realtime.NewInboxSubscriber(principal, 32)` on the dispatcher; spawns a goroutine reading from `Subscriber.Out` and *for each envelope*, loads the typed entity (via the inbox.Assemble code path on a single Item) and pushes onto the returned channel. On client disconnect (ctx done), deregister.
  - `TaskChanged(ctx, taskID *string) (<-chan *model.Task, error)` — analogous, using `NewTaskChangedSubscriber`. For each event, refetch the `Task` row, gate via `Can(... "view", task)`, push if allowed.
  - `NotificationReceived(ctx) (<-chan *model.Notification, error)` — registers a subscriber that matches `topic=="notification"`; Phase 2 emits no such events, so the channel stays open without ever firing. (Surface lands now; payload lands in Phase 4.)
- [X] T073 [US2] Update `/services/api/internal/server/server.go` (extending T043):
  - Confirm `transport.Websocket` is mounted; verify `KeepAlivePingInterval` set to 10 s.
  - Ensure the WS `InitFunc` runs through `auth.WebsocketInitFunc(q)` so the principal lands in the subscription ctx.
- [X] T074 [P] [US2] Add `/services/api/graph/subscription_e2e_test.go`:
  - Spin up the full server (`server.New(...)` + a real `realtime.Dispatcher`).
  - Pair a device, get a session token.
  - Open a WebSocket subscription on `inboxItemArrived` with the bearer in `connection_init`.
  - In another goroutine, `createTask("us2-sub")` via the HTTP mutation; assert the subscription emits one event within 2 seconds with the new assignment's id (SC-002).
  - Assert the event payload contains *only* `__typename` and `id` (no other fields populated on the wire, even though the gqlgen model has more — the refetch path resolves details).
- [X] T075 [P] [US2] Add `/services/api/graph/inbox_query_test.go`: insert a mix of `pending_decisions` + `agent_assignments`; call `inbox(first:25)` via the GraphQL handler; assert the response is ordered by `created_at DESC, id DESC`; assert each item resolves to the right gqlgen type per `__typename`.

### Flutter: subscription consumption

- [X] T076 [P] [US2] Update `/apps/mobile/lib/core/graphql/client.dart`: wire the `gql_websocket_link.WebSocketLink` so subscription operations route through it (the same `AuthLink` chains through for the `connection_init` payload, per T059).
- [X] T077 [P] [US2] Add `/apps/mobile/graphql/inbox_subscription.graphql` and `task_changed_subscription.graphql`. Re-run `build_runner build` and commit codegen.
- [X] T078 [US2] Update `/apps/mobile/lib/features/inbox/inbox_provider.dart` (or add if T066 didn't already): expose a Riverpod `StreamProvider<List<InboxItem>>` that:
  - Issues the initial `Inbox` query.
  - Subscribes to `InboxItemArrived`; on each event, refetches the inbox query (or, more precisely, runs the `AgentAssignment(id:)` / `PendingDecision(id:)` refetch and merges into ferry's normalized cache, which the inbox query then re-reads from).
  - Closes the subscription on dispose.
- [X] T079 [P] [US2] Update `/apps/mobile/lib/features/task/task_provider.dart`: when the assignment view is open, subscribe to `taskChanged(taskId)` and refresh the task state on each event (auto-navigation away on terminal states).
- [X] T080 [P] [US2] Add `/apps/mobile/test/inbox_subscription_test.dart`: widget test with a stubbed ferry client that emits a synthetic subscription event; assert the inbox list rebuilds and the new tile appears.

**Checkpoint**: US2 complete. Foreground updates flow over WebSocket; the refetch path keeps the auth boundary clean.

---

## Phase 5: User Story 3 - Revoked viewer mid-session (Priority: P2)

**Goal**: Revoking a session mid-stream stops subsequent events from arriving on the open subscription, without forcing a reconnect.

**Independent Test**: Open two subscriptions; revoke one session via the SQL nudge (or, when wired, via the `revokeSession` mutation from the other session); seed a new task; assert one subscription receives the event, the other does not — without the second client reconnecting.

### Server: revokeSession mutation + dispatcher per-event re-check verification

- [X] T081 [US3] Add `/services/api/graph/mutation_revoke_session.resolvers.go`: `RevokeSession(ctx, sessionID) (*model.Session, error)`:
  - Auth: `Can(ctx, principal, "revoke_session", SessionRef{ID: sessionID})` — Phase 2 owner-only.
  - In a tx: `RevokeSession(sessionID)`; insert `session_revoked` audit row with `in_reply_to` = the `session_issued` row id; commit.
  - Return the updated session.
- [X] T082 [P] [US3] Add `/services/api/graph/revoke_session_test.go`:
  - Pair two sessions; with session A's bearer, call `revokeSession(sessionId: <session-B-id>)`; assert session B is now revoked.
  - With session B's bearer, retry any authenticated query; assert `UNAUTHORIZED`.
- [X] T083 [US3] Add `/services/api/graph/revocation_subscription_test.go` (the SC-004 verifier):
  - Pair two sessions (A and B). Open an `inboxItemArrived` subscription per session (two real WebSocket clients).
  - `createTask("pre-revoke")`; assert both subscriptions emit one event.
  - Call `revokeSession(sessionId: <session-B-id>)` from session A.
  - `createTask("post-revoke")`; wait up to 5 s; assert session A emits one event, session B emits ZERO additional events (the second client is still connected — verify no reconnect happened by inspecting the underlying WS connection's `closeCode` is unset).
  - The dispatcher's per-event `Can(...)` re-check (T030/T031) is what makes this pass — the resolver layer needs no changes for this story beyond the mutation.

**Checkpoint**: US3 complete. Revocation has a concrete server-side handle and is verified end-to-end.

---

## Phase 6: User Story 4 - Offline-tolerant inbox + floor-relevant rail (Priority: P3)

**Goal**: Low-stakes writes survive offline via the outbox; floor-relevant writes are refused at compose time (the rail is in place before any floor-relevant actions exist).

**Independent Test**: Run the Flutter app offline (DevTools network panel for web; airplane mode on device). Dismiss a proposed task → confirm local update + outbox entry; bring online → confirm flush. Attempt the stubbed floor-relevant action → confirm refusal; bring online → confirm it commits.

### Flutter: outbox + connectivity + floor rail

- [X] T084 [P] [US4] Add `/apps/mobile/lib/core/offline/outbox.dart` (drift schema):
  - Table `OutboxEntries { id INTEGER PRIMARY KEY AUTOINCREMENT; op TEXT NOT NULL; targetId TEXT NOT NULL; argsJson TEXT NOT NULL; createdAt INTEGER NOT NULL }`.
  - DAO: `enqueue(op, targetId, args)`, `list()`, `delete(id)`, `count()`.
  - Re-run `build_runner build`; commit generated drift code.
- [X] T085 [P] [US4] Add `/apps/mobile/lib/core/offline/floor_rail.dart`: `enum WriteClass { lowStakes, floorRelevant }`; `WriteClass classify(String mutationName)` — returns `lowStakes` for `dismissProposedTask`, `acceptProposedTask`, and a (Phase 2-stubbed) `markRead`; returns `floorRelevant` for the four decision mutations (`approveArtifact`, `rejectApproval`, `answerQuestion`, `decidePromotion`). Unknown → `floorRelevant` (fail safe).
- [X] T086 [P] [US4] Add `/apps/mobile/lib/core/offline/connectivity.dart`: Riverpod `StreamProvider<bool>` (online/offline) backed by `connectivity_plus`. Emits whenever connectivity changes; outbox flush listens.
- [X] T087 [US4] Add `/apps/mobile/lib/core/offline/outbox_flush.dart`: when `connectivity` flips from offline to online, runs `outbox.list()` in `createdAt` order; for each entry, replays the mutation against the ferry client; on success delete the entry; on `NOT_FOUND` / `ALREADY_RESOLVED` server error delete the entry; on transient network error, keep the entry and retry on the next online event. (Last-write-wins per research R8.)
- [X] T088 [US4] Update `/apps/mobile/lib/features/inbox/inbox_tile.dart` (or the dismiss action handler in the tile): on dismiss tap, check `connectivity`; if online, run the mutation directly; if offline, `outbox.enqueue("dismissProposedTask", taskId, {reason})`, update the local cache optimistically (ferry cache write), and toast "Will be sent when online".
- [X] T089 [US4] Add `/apps/mobile/lib/features/debug/floor_relevant_stub.dart` (debug build only): a button on a hidden "Debug" page that calls `floor_rail.classify("approveArtifact")` and, when classified `floorRelevant` AND offline, shows a refusal banner. When online, posts the (stubbed) mutation; Phase 2's server returns `NOT_YET_AVAILABLE` — the client renders that error politely.
- [X] T090 [P] [US4] Add `/apps/mobile/test/outbox_test.dart`: drift-backed unit test that enqueueing a `dismissProposedTask` while a fake connectivity stream is offline persists the row; flipping the stream online triggers the flush and the row is deleted on stubbed success.
- [X] T091 [P] [US4] Add `/apps/mobile/test/floor_rail_test.dart`: widget test that, offline, tapping the debug floor-relevant button shows the refusal banner and the outbox row count stays zero. Online, the same tap posts the mutation and surfaces the `NOT_YET_AVAILABLE` error.

**Checkpoint**: US4 complete. The offline rail is exercised even though no real floor-relevant action lands until Phase 3.

---

## Phase 7: User Story 5 - Contract-versioning policy locked (Priority: P3)

**Goal**: The hybrid additive + field-deprecation policy is documented, referenced from every contract source, and gated by the PR process.

**Independent Test**: A new contributor (or future-self) reading `contracts/versioning-policy.md` can classify any proposed schema change as path 1, 2, or 3 — including the test question "given a hypothetical change X". The PR template requires the path checkbox.

- [X] T092 [P] [US5] Verify `/specs/003-operator-edge-wake/contracts/versioning-policy.md` content (already written during /speckit-plan): all three paths, the deprecation window, the pre-consumer carve-out, the PR-template language. No edits expected unless review surfaces gaps.
- [X] T093 [P] [US5] Update `/services/api/graph/schema.graphqls` header (extending T036): the leading comment block adds an explicit link `# Versioning policy: ../../specs/003-operator-edge-wake/contracts/versioning-policy.md`.
- [X] T094 [P] [US5] Update `/.github/PULL_REQUEST_TEMPLATE.md` (create if not present) to add the contract-version-path checkbox block from `contracts/versioning-policy.md § The PR checkbox`. If the file exists, append the block under a new `## Contract changes` section.
- [X] T095 [P] [US5] Update `/CLAUDE.md` § Conventions or the post-SPECKIT block: add a one-line entry pointing reviewers to the versioning policy file. This is the operational anchor — when reviewers see a schema-touching PR, the CLAUDE.md hint reminds them to check the path.

**Checkpoint**: US5 complete. The policy is locked, referenced, and reviewer-gated.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: CI gates, demo script, audit enrichment, post-merge state updates.

- [X] T096 [P] Update `/.github/workflows/ci.yml` to add a `flutter-codegen-drift` job: `flutter pub get` → `dart run build_runner build` → `git diff --exit-code lib/__generated__/`. Mirrors the existing gqlgen drift gate. Runs on PRs touching `apps/mobile/**`.
- [X] T097 [P] Add a `just sync-flutter-schema` recipe to `/Justfile` (and the `Makefile` shim): copies `services/api/graph/schema.graphqls` to `apps/mobile/graphql/schema.graphql`. Add a CI step that runs the recipe and asserts no diff (drift gate for the schema mirror).
- [X] T098 Add `/scripts/phase2-demo.sh`: executes the quickstart steps 1–4 against a running compose stack and asserts each criterion (pairs a device via `httpie`/`curl`; seeds a task via the `just seed-task` helper; greps the LogProvider line; opens a websocat subscription; revokes a session via SQL; replays an offline dismiss). Exit non-zero on any assertion failure. Wire into a `just phase2-demo` recipe.
- [X] T099 [P] Add `/services/api/internal/push/push_audit_test.go`: end-to-end assertion that each push attempt writes exactly one `audit_messages` row with `kind="push_attempted"`, that retried attempts append new rows (one per attempt), and that the `outcome` field matches the eventual classification.
- [X] T100 [P] Update `/services/api/internal/durable/recovery_test.go` (or add): kill-9 / restart test that an enqueued push survives — start the server, enqueue a push targeted at a token that the test-provider holds for 10 s before responding; SIGKILL the server; restart; assert DBOS replays the push step and the provider eventually receives it. Reuses the Phase 0 `scripts/dbos-recovery-demo.sh` pattern.
- [X] T101 Update `/CLAUDE.md` SPECKIT block: change "Phase 2 is **in planning**" to "Phase 2 is **complete**" with a one-paragraph summary of what landed and a pointer to the same design artifacts. (Final step before merge to `main`.)
- [X] T102 [P] Walk through `/specs/003-operator-edge-wake/quickstart.md` manually (or via the demo script) on a workstation; record one timing measurement per criterion (push latency under LogProvider, subscription delivery latency, offline dismiss flush latency) as evidence that SC-001 through SC-011 are met. Append the measurements to `quickstart.md § What gets verified at each step` (one row per criterion).
- [X] T103 Run `just generate` (gqlgen + sqlc) one final time; assert no drift via `git status` clean.
- [X] T104 Run `just test` (race-enabled, both modules); assert all green. Record the test summary in the PR description.

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: T001 (dep approval) blocks everything else; T002–T005 can run in parallel after T001.
- **Foundational (Phase 2)**: depends on Setup; **blocks all user stories**. Within Foundational:
  - Migration (T006) blocks sqlc query files (T008–T012), which block `sqlc generate` (T013).
  - sqlc generate (T013) blocks the auth (T014–T021), push (T022–T027), realtime (T028–T032), inbox (T033–T035), chain-workflow update (T040–T041), schema regen (T036–T038), server wiring (T042–T045) — all of which can run **in parallel** after T013.
- **US1 (Phase 3)**: depends on Foundational complete; the in-phase order is: server mutations (T046–T051) → server tests (T052–T055) and Flutter scaffolding (T056–T067) in parallel → Flutter tests (T068–T069).
- **US2 (Phase 4)**: depends on Foundational; resolvers (T070–T073) → server tests (T074–T075) parallel with Flutter consumption (T076–T080).
- **US3 (Phase 5)**: depends on Foundational + US1 (sessions exist) + US2 (subscriptions exist).
- **US4 (Phase 6)**: depends on Foundational + US1 (Flutter app scaffold + the inbox tile from US1 — tiles' dismiss action is what becomes outbox-aware in T088).
- **US5 (Phase 7)**: independent of all other user stories — purely documentation + CI; can run any time after Foundational T036.
- **Polish (Phase 8)**: depends on US1–US4 complete.

### Within each user story

- Tests are written **alongside** implementation in this phase rather than first-then-implementation. Server integration tests (`*_test.go` files marked [US1]/[US2]/etc.) MUST fail against the current code before the implementing task in the same phase lands, and MUST pass after. Where a Flutter widget test exercises a code path, the same rule applies.
- Models / sqlc-generated structs → services (`internal/auth`, `internal/push`, `internal/realtime`, `internal/inbox`) → resolvers → tests → Flutter consumers.

### Parallel opportunities (per phase)

- **Foundational**: after T013 (sqlc generate), the four internal packages — auth (T014–T021), push (T022–T027), realtime (T028–T032), inbox (T033–T035) — are independent and parallelizable across 4 developers/agents. Schema regen (T036–T038) sits in front of resolver work; it can run in parallel with the packages once the package signatures are agreed (`Can`, `Provider`, `Dispatcher`, `inbox.List`).
- **US1**: T046 (server push.Enqueue / queue worker) and T056 (Flutter main.dart rewrite) are independent. The provider implementations (T047 APNs, T048 FCM) are independent of each other.
- **US2**: T070 / T071 / T072 (resolvers) parallel with T076 / T077 (Flutter wiring).
- **US4**: T084 / T085 / T086 (drift schema, floor rail, connectivity) are independent.
- **Polish**: T096 / T097 / T098 / T099 / T100 / T102 are largely independent.

---

## Implementation strategy

### MVP first (US1 only)

1. **Phase 1: Setup** — T001 then T002–T005 in parallel.
2. **Phase 2: Foundational** — migration + sqlc → four packages in parallel → schema regen → server wiring.
3. **Phase 3: US1** — server push + pairDevice + registerDeviceToken; Flutter pairing + inbox + assignment view; LogProvider end-to-end test.
4. **STOP and VALIDATE**: `just phase2-mvp` (alias for the US1 e2e test in T055 + the Flutter widget tests). Real-device verification per `quickstart.md § Real-device addendum` is a post-merge step.
5. **Demo MVP** if ready.

### Incremental delivery beyond MVP

1. **US2 (foreground subscription)** — small additive layer; resolvers + Flutter stream consumption. Verifiable independently with `just phase2-subscription`.
2. **US3 (revocation)** — one mutation + one end-to-end test against US2's subscription path.
3. **US4 (offline)** — Flutter-only changes; outbox + floor rail.
4. **US5 (versioning policy)** — documentation + PR template; can land at any time.
5. **Polish (Phase 8)** — CI gates + demo script + final SPECKIT block update.

### Parallel team strategy

After Foundational completes, four work streams can proceed concurrently:

- **Server stream**: US1 server mutations (T046–T055) → US2 resolvers (T070–T075) → US3 mutation (T081–T083).
- **Flutter app stream**: US1 Flutter pairing + inbox + assignment (T056–T069) → US2 subscription consumption (T076–T080).
- **Flutter offline stream** (after US1 Flutter scaffold lands): US4 (T084–T091).
- **Docs / CI stream**: US5 (T092–T095) + Polish (T096–T100, T102).

---

## Notes

- [P] = different files, no incomplete-task deps.
- [USx] = traceability to spec.md user stories.
- Each user story is independently testable; the Polish phase exists *only* for cross-cutting concerns.
- Server tests use `testcontainers-go`; the shared container starts once per `go test` binary per the Phase 0 `internal/testutil` helper.
- Flutter widget tests run in pure Dart (no device); the real-device addendum is the only post-merge step required to declare SC-001 met.
- Commit after each task or logical group; the post-task git hook (`speckit-git-commit`) handles message shape.
- The Phase 1 chain workflow code (`internal/chain/workflow.go`) gets ONE in-place change (T040) — the `to_principal` set + `push.Enqueue` call. No other Phase 0/1 source touches this phase, by design (Constitution Principle I).
