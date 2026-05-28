# Implementation Plan: Phase 2 — Operator Edge & the Wake Channel

**Branch**: `003-operator-edge-wake` | **Date**: 2026-05-28 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/003-operator-edge-wake/spec.md`

## Summary

Phase 2 turns the chain workflow from Phase 1 into something a human can actually use, by building the **operator edge**: the full versioned GraphQL contract (PendingDecision interface, ApprovalRequest / AgentQuestion / PromotionProposal types, the InboxItem union, the `inbox` query, the live subscriptions, device-token mutations, and stubbed decision mutations); the two delivery channels off one trigger (an in-process `LISTEN tendant_events` dispatcher fanning to GraphQL subscribers, plus a DBOS-step push fan-out worker dispatching APNs/FCM); the central `Can(ctx, principal, action, target)` authorization machinery; the owner-scoped **session-token** pairing surface (a one-time deployment-config setup secret → per-device server-side session row, bearer-presented on every request and subscription connect); and a Flutter client (`ferry`/`riverpod`/`drift`/`go_router`) that renders the unified inbox, submits `completeTask` from the `AgentAssignment` view, deep-links from push, reads from a normalized cache offline, and persists low-stakes writes to a `drift` outbox while *refusing* floor-relevant writes offline (the rail Phase 3 will lean on).

The four clarifications locked in `spec.md § Clarifications` are load-bearing:
- **Contract versioning** is hybrid (additive + field-deprecation within a version; versioned endpoint only for unavoidable breaking changes; ≥1 minor release deprecation window). This phase ships the policy *and* the first contract under it.
- **Push payload mode** is hybrid alert + data — alert is the guarantee (banner survives force-quit on iOS); the data payload is opportunistic background refresh where the platform allows.
- **Push retry** is a DBOS step (or DBOS durable-queue enqueue) — crash-safe, uniform with the Phase 1 chain workflow, observable through the same machinery.
- **Auth identity** is owner-scoped session tokens — first-launch device pairing exchanges a one-time setup secret for a per-device `sessions` row; bearer on every request and subscription connect; revocation = `UPDATE sessions SET revoked_at = now()`.

One additive migration (`00003_operator_edge_wake.sql`) introduces the `sessions` table (the only new persistence Phase 2 requires); everything else uses the Phase 0 spine (`device_tokens`, `pending_decisions`, `agent_assignments`, the `notify_event` triggers, the `tools` table).

## Technical Context

**Language/Version**: Go 1.25 server (unchanged); Dart / Flutter (existing `apps/mobile/` already at SDK `>=3.4.0 <4.0.0`).

**Primary dependencies** — server side (already approved unless **NEW**):

- HTTP / GraphQL: `chi/v5`, `gqlgen` v0.17.90 — gqlgen's built-in `transport.Websocket` carries the `graphql-transport-ws` (a.k.a. `graphql-ws`) protocol for subscriptions; no extra dep required.
- DB: `pgx/v5` v5.9.2; `sqlc` v1.31.1; `goose/v3` v3.27.1.
- Durable engine: `dbos-transact-golang` v0.15.0 — Phase 2 leans on:
  - `dbos.RunAsStep` for the push attempt (idempotent retry + crash recovery).
  - DBOS durable queues (the library's `Queue` / `Enqueue` primitive) for the push fan-out worker, so pushes survive process restart and back-pressure naturally. The dependency is already pinned; this is a new *use* of an existing primitive.
- **NEW — APNs**: `github.com/sideshow/apns2` (Apache-2.0). Standard Go HTTP/2 APNs client; tiny dep, no transitive sprawl. Flagged for approval (see Dependency Flags).
- **NEW — FCM**: `firebase.google.com/go/v4` (`messaging` package, Apache-2.0). The official Firebase Admin SDK for Go; covers Android + web push uniformly. Flagged for approval.
- UUID: `google/uuid` (unchanged).
- Crypto for session token: `crypto/rand` (stdlib).

**Primary dependencies** — Flutter side (`apps/mobile/`), all **NEW** and flagged for approval together as the Phase 2 client stack:

- `ferry` (GraphQL client with normalized cache) + `ferry_generator` + `gql_http_link` + `gql_websocket_link` for subscriptions.
- `flutter_riverpod` (state management).
- `drift` (SQLite ORM) + `drift_dev` for the outbox.
- `go_router` (declarative routing + deep-link handling).
- `flutter_secure_storage` (session token at rest).
- `firebase_core` + `firebase_messaging` (FCM tokens on Android & web; APNs token on iOS via the same SDK).
- `flutter_local_notifications` (display incoming pushes when app is foregrounded; bookkeeping for tap callbacks).
- `connectivity_plus` (online/offline detection driving outbox flush).
- `build_runner` (dev dep) for ferry + drift codegen.

**Storage**: Same Postgres 16 + pgvector container. One additive migration:

- `db/migrations/00003_operator_edge_wake.sql` — creates `sessions` table; adds the `agent_assignments.to_principal` column (NULL = unassigned) so the push fan-out worker knows which principal to notify; activates **no** other Phase 0 tables that weren't already activated.
  - Note: the `device_tokens` table already exists from Phase 0 with the right shape; it gets queried but not altered.
  - Note: the `notify_event` PL/pgSQL function and triggers on `pending_decisions` and `agent_assignments` exist from Phase 0. Phase 2 attaches a `LISTEN` consumer to the existing `tendant_events` channel — no DDL change required.

**Testing**: `go test -race` with `testcontainers-go` v0.39.0 (Phase 0 helper). New test surface:

- LISTEN dispatcher unit + integration tests (subscriber registration, event fan-out, auth re-check on emit, slow-subscriber drop policy).
- Push fan-out worker tests against a `LogProvider` stub (urgency gating, token pruning on `IsTokenInvalid`, content-leak assertion that the marshaled payload contains *only* `{deep_link_id, generic_title}`).
- Session pairing + revocation tests (auth middleware, subscription connect-time check, mid-session revocation event suppression).
- `Can(...)` decision-point coverage test (resolver-registration table walked to assert every operator-edge field consults it; static check at CI).
- End-to-end "wake" test (real Postgres + DBOS + a real WebSocket subscriber and a real LogProvider, walking the Phase 1 chain to an assignment and asserting both channels fire).
- Flutter side: `flutter test` for the inbox renderer, the offline outbox flush, and the floor-relevant-rail refusal; goldens for the inbox tile / assignment screen.

**Target Platform**: Linux server (unchanged). Flutter client targets iOS 15+, Android 7+ (API 24+), modern Chrome/Edge/Safari for web, macOS / Linux / Windows desktop as best-effort (subscription always; push opportunistic per the spec's "Out of Scope — desktop/web background-wake polish").

**Project Type**: Web service (Go core + GraphQL operator edge) + mobile/desktop/web client (Flutter). Both already in the `go.work` / `apps/mobile` layout; no new top-level project.

**Performance goals** (from SC-001/002/007):

- Push delivery: under 10 s from inbox-row commit to OS-banner display in 95% of trials, on stable network. The bound is dominated by APNs/FCM tail latency — server-side DBOS step → provider POST should be < 500 ms p95.
- Subscription delivery: foreground inbox-row commit → UI render within 2 s. Server-side dispatcher → WebSocket frame should be < 100 ms p95; the rest is client refetch + render.
- Offline dismiss: < 200 ms local (UI optimistic update + drift outbox insert).

**Constraints**:

- IDs-only `pg_notify` (8 KB cap) — unchanged; the dispatcher and the push worker both refetch full entities.
- **Push payloads MUST contain zero task content** (FR-015 / SC-003) — enforced by the Provider interface's typed `PushBody{DeepLinkID, GenericTitle}` shape; nothing else is marshalable.
- **Visibility MUST be SQL-predicate, not post-fetch** (FR-031 / SC-006) — enforced by sqlc query design + a CI grep gate against post-filter patterns in resolvers.
- **`Can(...)` on every operator-edge resolver** (FR-030 / SC-005) — enforced by a registry pattern (every resolver registers a `(field, action, target)` triple) plus a startup-time assertion that every gqlgen field has a registry entry.
- Generated code committed (gqlgen for Go, ferry for Dart); CI drift gate stays green on both.

**Scale/Scope**: One owner; one to a handful of devices; low-thousands of subscribers upper bound (spec's stated envelope). The LISTEN dispatcher uses a single `pgx` connection in `pgx.Conn.Notification()` loop mode — sufficient for this scale.

## Constitution Check

*GATE: evaluated against constitution v1.2.0. Re-checked post-design — still passing.*

| Principle | Phase 2 status |
|---|---|
| I. Capability at the edges | ✅ Phase 2 *is* the edge — the operator (human) edge in full. The core gains exactly one new persistence (`sessions`) plus one nullable column (`agent_assignments.to_principal`) to support the wake channel; everything else is on the edge or in the seam (auth, push fan-out, subscription dispatch). No new intake or outward-action capability lands. |
| II. Task ≠ workflow | ✅ Untouched. Sessions and device tokens are unrelated to workflow identity. |
| III. Hard-rule floor immune | ✅ The floor doesn't exist yet (lands in Phase 3), but the rail is installed: Phase 2's contract declares decision mutations (`approveArtifact` / `answerQuestion` / `decidePromotion`) that return a typed `NOT_YET_AVAILABLE` error pre-Phase-3 (FR-005). The Flutter offline outbox refuses to enqueue floor-relevant writes (FR-027) — when those writes become reachable in Phase 3, the rail already says "no" without further work. |
| IV. Owner authors trust | ✅ Sessions are owner-bound (single principal). No autonomy logic. Pairing requires the deployment-config setup secret — owner-authored at deploy time. |
| V. Cancel halts | ✅ N/A — no new workflow logic this phase. The chain workflow's cancel semantics from Phase 1 are unchanged. |
| VI. Audit message-shaped | ✅ Three new audit kinds land additively: `session_issued`, `session_revoked`, and `push_attempted` (the last as a success/error record per DBOS-step attempt — verifiable from inside the DBOS step). All write `audit_messages` rows with `from_principal` / `to_principal` / payload, in the same SQL tx as the underlying mutation. |
| VII. Edge contracts versioned / additive | ✅ **Every addition is additive on `graphql.v1.graphqls`**: new types (`Tool`, `Artifact`, `Mandate`, `ApprovalRequest`, `AgentQuestion`, `PromotionProposal`, `Notification`); new interface (`PendingDecision`); new union (`ApprovalPayload`, `InboxItem`); new query (`inbox`); new subscriptions (`inboxItemArrived`, `taskChanged`, `notificationReceived`); new mutations (`registerDeviceToken`, `unregisterDeviceToken`, `pairDevice`, `revokeSession`, and the stubbed decision mutations). **No existing field is changed.** The hybrid versioning policy (Clarification Q1) lands as `contracts/versioning-policy.md` referenced from `schema.graphqls` and `CLAUDE.md`. |
| VIII. Federation-shaped | ✅ `Tool` is a top-level addressable resource and carries `globalUri` (the DB column exists from Phase 0). `Session` is a sub-resource of `Principal` — addressed via its owner; no own `globalUri` (consistent with v1.2.0 narrowing). The session pairing flow uses the owner's principal globalUri as the binding. New `Notification` and `InboxItem` are GraphQL surface shapes over already-globalUri'd entities. |
| IX. Untrusted code sandboxed | ✅ N/A — no gate-script execution this phase. |

**Technology Constraints**:

- Postgres-only ✅ — `sessions` is Postgres; LISTEN/NOTIFY is the realtime transport; no broker, no secondary store.
- DBOS engine ✅ — the push fan-out runs as DBOS steps / on a DBOS durable queue (Clarification Q3).
- Adopted stack ✅ — Go `gqlgen`/`chi`/`pgx` on the server; Flutter on the client.
- Language policy ✅ — Go and Dart only; both already adopted.
- **No new dependencies without approval** ❗ — Phase 2 adds dependencies on **both** sides. Flagged below.

**Dependency Flags (require explicit approval before tasks are generated)**:

- **Server: `github.com/sideshow/apns2`** — Apache-2.0; the standard Go APNs/2 HTTP/2 client. Alternatives considered: rolling our own HTTP/2 client over the APNs endpoint (rejected — re-implementing token authentication, retry, and feedback parsing for marginal benefit). Stable, widely used, no transitive bloat.
- **Server: `firebase.google.com/go/v4`** — Apache-2.0; the official Firebase Admin SDK. Alternatives considered: legacy `gcm`/`fcm` libraries (deprecated by Google), direct HTTP POSTs to the FCM v1 endpoint (rejected — OAuth-token management and message shaping is precisely what this library exists to provide). The transitive footprint is non-trivial (`google.golang.org/api`, `cloud.google.com/go`) but unavoidable for the FCM v1 API.
- **Flutter client stack** — `ferry`, `ferry_generator`, `gql_http_link`, `gql_websocket_link`, `flutter_riverpod`, `drift`, `drift_dev`, `go_router`, `flutter_secure_storage`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`, `build_runner`. The constitution's Technology Constraints already name "the client is a single Flutter codebase" and call out `Ferry` by name (under *Adopted stack*); these are the specific packages that implement that stack. Listed individually here so each can be cross-checked against the approval list.
- **No new datastores, no new transports.** Everything ships through Postgres + `LISTEN/NOTIFY` + WebSocket (the existing gqlgen subscription transport) + HTTPS POSTs to APNs/FCM (outbound only).

→ **Constitution Check: PASS** *conditional* on dependency approval; the complete dependency list is enumerated above for an explicit owner sign-off before `/speckit-tasks`. No principle violations; Complexity Tracking left empty.

> **Dependency approval recorded**: 2026-05-28 (owner: bradleynelson102@gmail.com) — all server (`sideshow/apns2`, `firebase.google.com/go/v4`) and Flutter Phase 2 dependencies enumerated above are approved. `/speckit-implement` may proceed past T001.

## Project Structure

### Documentation (this feature)

```text
specs/003-operator-edge-wake/
├── plan.md                  # This file
├── research.md              # Phase 0 of plan: subscription transport, push provider seam, DBOS queue use, LISTEN dispatcher pattern, Flutter stack picks, session pairing, drift outbox, push payload shape
├── data-model.md            # sessions table, agent_assignments.to_principal column, new audit kinds; full GraphQL additions table
├── quickstart.md            # Walk: pair → walk a task to an assignment → see it arrive over subscription → see push fire (LogProvider stub) → resolve → revoke session → confirm subscription stops
├── contracts/
│   ├── graphql.v1.graphqls  # Amended v1 schema (full Phase 2 SDL — additive only)
│   └── versioning-policy.md # The hybrid additive-+-field-deprecation policy locked in Clarification Q1
└── checklists/
    └── requirements.md      # (from /speckit-specify, updated by /speckit-clarify)
```

### Source code (repository root) — target layout

Phase 2 lands inside the existing layout. **NEW** paths in **bold**:

```text
db/migrations/
├── 00001_v2_ddl_spine.sql                (Phase 0, unchanged)
├── 00002_phase1_state_rename.sql         (Phase 1, unchanged)
└── 00003_operator_edge_wake.sql          # NEW: sessions table; agent_assignments.to_principal column

services/api/
├── graph/
│   ├── schema.graphqls                   # AMENDED: Phase 2 additions (additive only — see contracts/graphql.v1.graphqls)
│   ├── generated.go                      # regenerated, committed
│   ├── model/                            # regenerated
│   └── *.resolvers.go                    # resolvers for new query/mutations; subscription resolvers (new file: subscription.resolvers.go)
└── internal/
    ├── auth/                             # NEW: central Can(...) decision point + session-token middleware + subscription connect-time auth
    │   ├── can.go                        # Can(ctx, principal, action, target) — Phase 2 returns "owner can do anything that targets owner-owned data" but the signature is the federation seam
    │   ├── session.go                    # Session row read/write, token mint, revoke
    │   ├── middleware.go                 # chi middleware: bearer → session → principal in ctx; subscription init-payload variant
    │   ├── registry.go                   # resolver registration + startup-time assert "every operator-edge field has a Can(...) entry"
    │   └── *_test.go
    ├── realtime/                         # NEW: in-process LISTEN dispatcher (Channel A)
    │   ├── dispatcher.go                 # LISTEN tendant_events; routes {topic,id} envelopes to in-process subscribers
    │   ├── subscriber.go                 # subscriber registry; per-topic + per-task filtering; auth re-check on emit
    │   └── *_test.go                     # subscriber registration, fan-out, slow-subscriber drop, auth revocation mid-stream
    ├── push/                             # NEW: push fan-out worker + provider seam (Channel B)
    │   ├── push.go                       # Enqueue(ctx, taskID, recipientPrincipalID, deepLinkID) → DBOS step / queue
    │   ├── provider.go                   # interface Provider { Send(ctx, token, platform, body PushBody) error; IsTokenInvalid(error) bool }
    │   ├── selector.go                   # Selector{Pick(platform) Provider} — iOS→APNs, ANDROID|WEB→FCM
    │   ├── apns.go                       # APNs provider (uses sideshow/apns2)
    │   ├── fcm.go                        # FCM provider (uses firebase.google.com/go/v4/messaging)
    │   ├── log_provider.go               # LogProvider stub — structured-log every intended push (FR-018)
    │   ├── body.go                       # PushBody{DeepLinkID, GenericTitle} — closed shape (content-leak prevention)
    │   ├── urgency.go                    # urgency-gating rule (Phase 2 conservative default: PendingDecision + owner-directed AgentAssignment push; informational state changes don't)
    │   └── *_test.go                     # content-leak assert, token-prune on IsTokenInvalid, urgency gate
    ├── inbox/                            # NEW: inbox query + InboxItem assembly
    │   ├── inbox.go                      # paginated viewer-scoped inbox over (pending_decisions ∪ agent_assignments)
    │   └── *_test.go
    ├── chain/                            # CHANGED: chain workflow enqueues push step after InsertAssignment (one new step call)
    │   └── workflow.go                   # + push.Enqueue(...) as a RunAsStep after assignment insert
    ├── db/
    │   ├── queries/
    │   │   ├── sessions.sql              # NEW: IssueSession, FindSessionByToken, RevokeSession, ListSessionsForPrincipal
    │   │   ├── device_tokens.sql         # NEW: RegisterDeviceToken (upsert), UnregisterDeviceToken, ListTokensForPrincipal, MarkTokenInvalid
    │   │   ├── inbox.sql                 # EXTENDED: viewer-scoped inbox SELECT with pagination cursors
    │   │   ├── decisions.sql             # NEW: FindPendingDecision(by id) + GetPendingDecisionForAuth (used by Can(...) refetch)
    │   │   └── assignments.sql           # EXTENDED: GetAssignmentForAuth + SetAssignmentRecipient (used when chain workflow opens an assignment)
    │   └── *.sql.go                      # regenerated
    ├── durable/
    │   └── dbos.go                       # CHANGED: registers the push step / push queue alongside the chain workflow
    └── server/
        └── server.go                     # CHANGED: adds the auth middleware on /graphql; wires the WebSocket transport's init-payload handler to auth; wires the LISTEN dispatcher startup + shutdown; loads APNs/FCM provider config

apps/mobile/                              # CHANGED: from "Hello, tendant!" scaffold to a real client
├── pubspec.yaml                          # AMENDED: Phase 2 dependency stack (see Dependency Flags)
├── build.yaml                            # AMENDED: ferry + drift codegen wiring; schema path → services/api/graph/schema.graphqls
├── graphql/                              # NEW: shared schema mirror (a symlink or a copy-on-build) + .graphql operation docs
│   ├── schema.graphql                    # mirror of services/api/graph/schema.graphqls
│   ├── inbox.graphql                     # query Inbox($first, $after) { inbox { ... } }
│   ├── task.graphql                      # query Task($id) { task(id:$id) { ... openAssignment { ... } } }
│   ├── complete_task.graphql             # mutation CompleteTask($taskId, $result) { ... }
│   ├── dismiss_proposed_task.graphql     # mutation DismissProposedTask($taskId, $reason) { ... }
│   ├── pair_device.graphql               # mutation PairDevice($setupSecret, $displayName) { ... }
│   ├── register_device_token.graphql     # mutation RegisterDeviceToken(...) { ... }
│   ├── inbox_subscription.graphql        # subscription InboxItemArrived { ... }
│   └── task_subscription.graphql         # subscription TaskChanged($taskId) { ... }
├── lib/
│   ├── main.dart                         # REPLACED: app bootstrap, Firebase init, secure-storage session load, root router
│   ├── app.dart                          # NEW: TendantApp widget (MaterialApp.router + ProviderScope)
│   ├── core/
│   │   ├── auth/
│   │   │   ├── session_store.dart        # NEW: read/write/clear session token in flutter_secure_storage
│   │   │   ├── pairing.dart              # NEW: first-launch device-pairing flow
│   │   │   └── auth_link.dart            # NEW: ferry link that adds Authorization: Bearer on HTTP + Connection-Init on WebSocket
│   │   ├── graphql/
│   │   │   ├── client.dart               # NEW: ferry Client wiring (http + ws + auth + cache)
│   │   │   └── cache.dart                # NEW: ferry HiveStore (or stdlib Cache) + cache type policies
│   │   ├── notifications/
│   │   │   ├── messaging.dart            # NEW: firebase_messaging + flutter_local_notifications wiring; token rotation hook → registerDeviceToken
│   │   │   └── deep_link.dart            # NEW: tap → go_router.push(/inbox/:id) routing
│   │   ├── offline/
│   │   │   ├── outbox.dart               # NEW: drift schema + queue/flush logic for low-stakes writes
│   │   │   ├── floor_rail.dart           # NEW: classifies a mutation as low-stakes or floor-relevant; refuses floor-relevant writes when offline
│   │   │   └── connectivity.dart         # NEW: connectivity_plus listener triggering outbox flush
│   │   └── router/
│   │       └── routes.dart               # NEW: go_router config (Pairing, Inbox, Item detail)
│   ├── features/
│   │   ├── inbox/
│   │   │   ├── inbox_page.dart           # NEW: list rendering InboxItem (switch on __typename)
│   │   │   ├── inbox_tile.dart           # NEW: per-kind tile (AgentAssignment vs PendingDecision read-only stubs)
│   │   │   └── inbox_provider.dart       # NEW: riverpod provider over ferry query + subscription stream
│   │   ├── task/
│   │   │   ├── assignment_view.dart      # NEW: AgentAssignment detail + completeTask submit
│   │   │   └── task_provider.dart        # NEW: riverpod provider over ferry task(id)
│   │   └── pairing/
│   │       └── pairing_page.dart         # NEW: first-launch screen, takes the setup secret, calls pairDevice
│   └── __generated__/                    # ferry codegen output (committed; CI drift gate)
└── test/                                 # widget tests (inbox renderer, outbox flush, floor-rail refusal)
```

**Structure Decision**: Keep the `go.work` workspace and `apps/mobile` Flutter app side-by-side; no new top-level module. The server gains four new internal packages — **`internal/auth`** (sessions + central `Can(...)` + middleware), **`internal/realtime`** (LISTEN dispatcher), **`internal/push`** (provider seam + fan-out worker + LogProvider stub), and **`internal/inbox`** (the unified-inbox query assembly). These packages depend on `internal/db` (sqlc) and `internal/durable` (DBOS); they are independently unit-testable. The Flutter app gains a `core/` (cross-cutting concerns: auth, graphql client, notifications, offline) and a `features/` (UI per feature) split; codegen output (`lib/__generated__/`) is committed and CI drift-gates it.

### Startup order (extends Phase 1 — additions in **bold**)

1. Open `pgxpool.Pool` from `DATABASE_URL`. *(unchanged)*
2. `goose.Up` — now runs migrations `00001 + 00002 + 00003`. *(extended)*
3. Seed the single owner `Principal`. *(unchanged)*
4. `durable.Init` → register chain workflow → **register push step / push queue** → `dbos.Launch`. *(extended)*
5. **Construct the push `Provider` selector** — read `TENDANT_APNS_*` / `TENDANT_FCM_*` env vars; if absent, install `LogProvider` (FR-018).
6. **Start the LISTEN dispatcher** — opens a dedicated `pgx.Conn` (taken from the pool), issues `LISTEN tendant_events`, runs the notification loop in a goroutine. *(new)*
7. Build chi router (`/graphql`, `/playground`, `/healthz`) — **adds `auth.Middleware` on `/graphql` and the WebSocket transport's `InitFunc` for connection-init auth**. *(extended)*
8. `http.ListenAndServe`; graceful shutdown — **also shuts down the LISTEN dispatcher and waits for in-flight push DBOS steps**. *(extended)*

DBOS `Launch` recovers any PENDING workflows (chain workflows from Phase 1 + push steps from Phase 2) from the previous boot. The LISTEN dispatcher does **not** itself need durability — if it crashes, the *next foreground refresh* recovers the inbox; the durable channel is push, which lives in DBOS.

## Two channels off one trigger — architecture

```text
                        Mutation / chain step that inserts an inbox row
                                                |
                                                v
                                  BEGIN sql tx
                                    INSERT pending_decisions / agent_assignments
                                      └── trigger trg_*_notify fires
                                           └── pg_notify('tendant_events', {topic,id})
                                    INSERT audit_messages (kind=assignment_created | decision_opened, ...)
                                    push.Enqueue(taskID, recipientPrincipal, deepLinkID)
                                      └── DBOS Enqueue → durable queue row
                                  COMMIT
                                                |
                +-------------------------------+-------------------------------+
                |                                                               |
        Channel A (foreground)                                           Channel B (background)
        realtime.Dispatcher                                                push DBOS worker
                |                                                               |
        consumes the pg_notify on its long-lived LISTEN conn                  pulls the next push step from the durable queue
                |                                                               |
        per-subscriber filter (matches inboxItemArrived / taskChanged(taskId))   provider.Send(token, platform, PushBody{DeepLinkID, GenericTitle})
                |                                                               |     - APNs hybrid alert+content-available  (iOS)
        auth.Can(subscriber.principal, "view", entity) re-checked              |     - FCM notification+data                 (Android/Web)
                |                                                               |     - LogProvider                            (stub)
        emit {__typename, id} to WebSocket frame                                |
                |                                                            on success: audit kind=push_attempted, outcome=ok
        client receives event → REFETCHES by id via normal /graphql query     on permanent error: prune token; audit kind=push_attempted, outcome=token_invalid
        (auth re-checked there too)                                          on transient error: DBOS retries with backoff
                |
        ferry normalizes into the cache → riverpod stream → UI rebuilds
```

**Why both channels share *no* state**: each is independently complete. Push doesn't need the dispatcher to be running; the dispatcher doesn't need push to be running. Crash one — the other keeps working. Both ultimately recover via the next foreground query against the inbox, so even if both miss an event, correctness is preserved.

**Why the push enqueue lives at the *write site*, not the dispatcher**: the spec's "guarantee" claim depends on push attempts being durable from the moment the inbox row is committed. Hanging push off the LISTEN dispatcher would mean the window between `pg_notify` and the dispatcher's `RunAsStep` is unprotected. Enqueueing inside the writing transaction (DBOS uses the same pool; `Enqueue` is itself a step that lands in the durable queue) keeps the push guarantee transactionally aligned with the commit that created the work.

## Session pairing & revocation — sequence

```text
First launch on a device                            Mid-session revocation
-----------------------                            ----------------------
Client: read setup_secret env / display QR          Admin or owner mutation:
        (Phase 2: paste-in screen)                  revokeSession(sessionId)
        |                                                  |
        |   pairDevice(setupSecret, displayName)            UPDATE sessions SET revoked_at = now()
        v                                                  |
Server: validate setup_secret                              (no client-side hook needed —
        INSERT sessions(token, principal, ...)              the next request fails closed,
        return Session { token, principal }                 and the LISTEN dispatcher's
        |                                                   per-event Can(...) re-check
        v                                                   suppresses subsequent events
Client: flutter_secure_storage.write("session_token", t)    on the open WebSocket — no
        attach Authorization: Bearer <t> on:                reconnect required, per
          - all HTTP /graphql requests                      Story 3 + SC-004.)
          - WebSocket connection_init payload
        |
        |   registerDeviceToken(fcmToken, platform)
        v
Server: INSERT device_tokens (upsert by token)
```

The setup secret is a deployment-config environment variable (`TENDANT_SETUP_SECRET`) on the server. For Phase 2, the client takes it as a paste-in / QR-scan on the pairing screen — this is sufficient for a single household and doesn't introduce identity-provider machinery. Single-use is enforced server-side by an in-memory "consumed setup secrets" set scoped to the process lifetime — a deployment restart re-enables the secret, which is acceptable for the single-household envelope.

## Contract versioning — the locked policy

`contracts/versioning-policy.md` codifies the rules:

1. **Within a version**: every change MUST be expressible as additive — new types, new fields, new enum values, new union members, new optional arguments. Breaking changes within a version are prohibited.
2. **Deprecation path**: a field that needs to be retired MUST first be marked `@deprecated(reason: "...")` and remain functional for **≥1 minor release** before removal. The deprecation announcement (the commit that lands the directive) and the removal commit MUST be in different minor versions.
3. **Versioned endpoint path**: a new versioned endpoint (`/graphql/v2`, etc.) is introduced *only* when a change cannot be expressed as additive + deprecation. Such changes are rare and require explicit owner approval. `/graphql/v1` MUST remain available for a documented retirement window (default: 6 months from `/graphql/v2`'s GA).
4. **Five-contract scope**: this policy applies to *all five* of tendant's long-lived versioned contracts (operator-edge GraphQL, intake potential-task signal, MCP tool contract, gate-script ABI/manifest, the federation sub-agent message protocol). The policy text lives once at the repo root level (`contracts/versioning-policy.md`) and is referenced by each contract's source.
5. **Reviewer test**: any proposed schema change MUST be classifiable as "additive (path 1)", "deprecation (path 2)", or "versioned (path 3)" *before* it lands. The PR template includes a one-line checkbox; reviewers reject PRs that don't pick a path.

## Complexity Tracking

> No Constitution Check violations beyond the dependency flags, which are *not* violations — they are the required approval surface for new third-party libraries per Technology Constraints. Section intentionally empty for principle violations.
