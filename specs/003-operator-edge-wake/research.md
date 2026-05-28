# Research — Phase 2 Operator Edge & the Wake Channel

Phase 2 introduces no new clarifications beyond the four already locked in `spec.md § Clarifications`. The research below resolves the remaining technical decisions that the plan defers to design time.

---

## R1: GraphQL subscription transport — `graphql-transport-ws` vs the legacy protocol

**Decision**: Use **`graphql-transport-ws`** (sometimes called `graphql-ws`) — the newer protocol from `enisdenjo/graphql-ws`.

**Rationale**:
- gqlgen's `transport.Websocket` supports both `graphql-ws` (legacy `subscriptions-transport-ws`) and `graphql-transport-ws` simultaneously via subprotocol negotiation. We enable `graphql-transport-ws` only.
- The newer protocol has explicit `connection_init` payload handling (carries the bearer token), proper acks (`connection_ack`), and ping/pong heartbeats — all of which we need for auth-on-connect (Story 3) and idle-connection liveness.
- The legacy protocol is deprecated upstream and will not be extended; betting on the newer protocol future-proofs the contract.
- Flutter `ferry`'s `gql_websocket_link` supports `graphql-transport-ws` natively.

**Alternatives considered**:
- *Both protocols negotiated* — strictly larger attack surface (two parsers to keep safe, two code paths to test) for no benefit in a fresh-deployment client/server.
- *SSE (Server-Sent Events)* — half-duplex; would still need a separate path for `connection_init`-style auth. WebSocket-on-`/graphql` is the gqlgen-idiomatic path.

**Wiring**: `services/api/internal/server/server.go` adds:

```go
srv.AddTransport(&transport.Websocket{
    KeepAlivePingInterval: 10 * time.Second,
    InitFunc: auth.WebsocketInitFunc, // reads bearer from connection_init payload
})
```

---

## R2: Push provider seam — APNs and FCM behind one interface

**Decision**: Define a server-internal `push.Provider` interface; ship three implementations (`APNs`, `FCM`, `LogProvider`); choose at boot via a `push.Selector` that routes by `device_platform`.

```go
type PushBody struct {
    DeepLinkID    string // the inbox-item id (FR-015)
    GenericTitle  string // e.g., "tendant" / "something needs you" — NEVER task content
}

type Provider interface {
    Send(ctx context.Context, token string, body PushBody) error
    IsTokenInvalid(err error) bool
}

type Selector struct {
    APNs, FCM, Log Provider
}

func (s Selector) Pick(platform db.DevicePlatform) Provider {
    if s.APNs == nil && s.FCM == nil { return s.Log }
    switch platform {
    case db.DevicePlatformIOS:                       return s.APNs
    case db.DevicePlatformANDROID, db.DevicePlatformWEB: return s.FCM
    }
    return s.Log
}
```

**Why a struct-shaped Provider, not arbitrary fields**: the closed `PushBody` shape is what enforces FR-015 / SC-003. A test asserts that nothing else can be marshaled into the outgoing payload (the function takes `PushBody`, not `any`).

**Rationale**:
- Two implementations diverge in transport (APNs HTTP/2 with JWT auth vs FCM v1 with OAuth) but share the conceptual shape.
- `LogProvider` stands in when credentials aren't configured (FR-018) — emits a structured-log line per intended push, sufficient for CI and quickstart demos.
- `IsTokenInvalid(err)` lets the worker prune dead tokens uniformly (FR-017): APNs returns `BadDeviceToken` / `Unregistered`; FCM returns `messaging/registration-token-not-registered` and similar; both providers' adapters classify into the same shape.

**Alternatives considered**:
- *Server-side webhook to a third-party push relay (OneSignal etc.)* — extra dependency, extra failure surface, and the spec's "no task content in push body" constraint is harder to enforce when going through a relay's content-templating system.
- *Direct HTTP POSTs without `sideshow/apns2` or `firebase.google.com/go`* — re-implementing token mint and retry semantics is what the libraries exist to do.

---

## R3: DBOS step / queue use for push fan-out

**Decision**: Push fan-out is a **DBOS step** for each `(deviceToken, principal, deepLinkID)` triple, enqueued onto a **DBOS durable queue** for back-pressure isolation.

**Rationale**:
- `dbos-transact-golang` v0.15.0 supports both `RunAsStep(ctx, fn)` inside a workflow and standalone `Enqueue(queueName, payload)` against a named queue. Either gives crash-safe step semantics (idempotency keyed by step id; recovery on Launch).
- A queue gives back-pressure isolation: a slow APNs response from one device doesn't head-of-line block the chain workflow that scheduled the push. The chain workflow's `RunAsStep` for push simply does `dbos.Enqueue("push", payload)` and returns; the queue worker drains asynchronously.
- DBOS's retry envelope (configurable per queue: max attempts, backoff curve) is the durable-retry semantics Clarification Q3 locks in.

**Configuration for Phase 2**:

```go
// internal/durable/dbos.go
dbos.NewQueue(dctx, "push", dbos.QueueConfig{
    MaxAttempts: 5,
    Backoff: dbos.ExponentialBackoff{Initial: 1*time.Second, Max: 1*time.Minute, Multiplier: 2.0},
    Workers: 4, // concurrent pushes; ample for single-household
})
```

**Idempotency**: the step is keyed by `(taskID, deepLinkID, deviceToken)` so retries don't double-deliver. Providers themselves are idempotent on the same `apns-id` / FCM `message_id`, so even a duplicate enqueue (from a crash between commit and queue insert) does no harm.

**Alternatives considered**:
- *Inline retry in a goroutine* — non-durable; loses the wake on process crash, which is exactly the failure the clarification rejected.
- *External job runner (Asynq, River)* — would be a new dependency and a second persistence path. Constitution forbids without amendment.

---

## R4: LISTEN dispatcher — single connection, in-process fan-out

**Decision**: One dedicated `pgx.Conn` (taken from the pool, not returned to it) issues `LISTEN tendant_events` and runs `conn.WaitForNotification(ctx)` in a goroutine. Notifications fan out in-process to an in-memory subscriber registry; each subscriber holds a channel.

```go
type Dispatcher struct {
    conn *pgx.Conn
    mu   sync.RWMutex
    subs map[*Subscriber]struct{}
}

type Subscriber struct {
    Principal     *Principal
    Match         func(topic, id string) bool   // e.g., taskChanged(taskId="X") → match topic=="task" && id==X
    Out           chan<- EventEnvelope
    DroppedCount  atomic.Int64
}
```

**Rationale**:
- gqlgen's WebSocket transport invokes the subscription resolver, which returns a channel that the gqlgen runtime then drains. We attach the resolver-returned channel to a `Subscriber` registered on the dispatcher; the resolver's cleanup deregisters it.
- A single LISTEN connection per process is sufficient for the spec's "low-thousands of subscribers" envelope. PG handles the fan-out from the writers' `pg_notify` to the listening connection; the in-process registry handles the next hop.
- Auth re-check on emit (FR-013 / FR-032) happens *before* sending to the subscriber's channel: the dispatcher calls `auth.Can(sub.Principal, "view", entity)` and silently drops the event for revoked viewers — no error to the client, no reconnect needed (SC-004).

**Slow-subscriber policy**: subscriber channels are bounded (capacity 32); on full channel, **drop the event** (increment `DroppedCount`) rather than block. The client recovers via next foreground refetch; blocking would HoL the entire dispatcher.

**Restart behavior**: the dispatcher is non-durable. If the server restarts, the dispatcher is recreated empty, clients reconnect via `gql_websocket_link`'s automatic reconnect, and resume from the inbox query. Push (the durable channel) is the safety net for events missed during the dispatcher gap.

**Alternatives considered**:
- *One LISTEN connection per subscriber* — exhausts `pgx` pool capacity at trivial subscriber counts.
- *External pubsub (Redis, NATS)* — new dependency; new datastore; constitution prohibits.
- *Polling `agent_assignments` / `pending_decisions`* — Phase 0 explicitly chose `pg_notify` over polling; reversing would discard that infra.

---

## R5: Flutter stack — confirm each package and pin versions

**Decision**: The exact pubspec entries for the Phase 2 client stack:

```yaml
dependencies:
  flutter: { sdk: flutter }
  ferry: ^0.16.0                 # GraphQL client + normalized cache
  gql_http_link: ^1.0.1
  gql_websocket_link: ^1.0.1
  gql_link: ^1.0.0
  ferry_flutter: ^0.10.0         # widgets
  flutter_riverpod: ^3.0.0       # state mgmt; Riverpod 3 is current as of 2026
  drift: ^2.33.0                 # SQLite ORM for outbox
  go_router: ^17.0.0             # declarative routing + deep links
  flutter_secure_storage: ^10.0.0
  firebase_core: ^4.0.0
  firebase_messaging: ^16.0.0    # FCM (Android, web, and APNs forwarding on iOS)
  flutter_local_notifications: ^19.0.0  # display incoming pushes when foregrounded
  connectivity_plus: ^7.0.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: { sdk: flutter }
  flutter_lints: ^6.0.0
  build_runner: ^2.15.0
  ferry_generator: ^0.13.0
  drift_dev: ^2.33.0
```

**Why `ferry` and not `graphql_flutter`**:
- `ferry` ships a normalized cache out of the box (offline read requirement, FR-025).
- `ferry`'s generated typed operations are stronger than `graphql_flutter`'s document-based API — they fit Flutter's null-safe Dart 3.4+ ergonomics.
- Constitution's adopted-stack note explicitly names `Ferry`.

**Why Riverpod 3 over Provider / Bloc**:
- Riverpod 3 (released 2025) is the current major; it's the project's stated state-management direction. No Provider or InheritedWidget gymnastics; testable in isolation; works naturally with `ferry`'s streams via `StreamProvider`.

**Why `drift` and not `sqflite`**:
- The outbox is a small typed table with a few atomic ops (enqueue, list, mark-flushed, delete). `drift`'s code-generated DAO is the right size; raw `sqflite` would mean hand-writing the boilerplate.

**Why `firebase_messaging` for *both* APNs and FCM**:
- Firebase Messaging's iOS path receives the APNs token from the OS and either uses it directly or maps it to an FCM token. Either is fine — the server stores whatever the client registers. Using one client SDK across platforms simplifies the device-token mutation surface (the platform enum disambiguates on the server side).

---

## R6: Session pairing — one-time setup secret exchange

**Decision**: Pairing is a single GraphQL mutation `pairDevice(setupSecret, displayName): Session!` that returns the session token. The setup secret is read from `TENDANT_SETUP_SECRET` at boot and held in-process. It is single-use per boot — once consumed, subsequent calls fail.

**Rationale**:
- This is the minimum surface for a single-household deployment: the owner does `docker exec ... echo $TENDANT_SETUP_SECRET` (or reads it from the compose file), enters it on the pairing screen, and the device is bound. No QR code, no Bluetooth pairing, no email-based bootstrap.
- The setup secret is *not* the session token — it's the one-time grant that mints the session. The session token is server-issued (`crypto/rand`, 32 bytes, base64-encoded), persisted in `sessions`, and returned to the device once. After that, the bearer is what the client presents.
- "Single-use per boot" is acceptable for a self-hosted single-household system: if pairing fails halfway, restart the container, the secret is re-armed.

**Token format**:

```go
func mintSessionToken() string {
    b := make([]byte, 32)
    _, _ = rand.Read(b)
    return base64.RawURLEncoding.EncodeToString(b)
}
```

**Storage**: never logged, never returned in any other API response, server-side stored *hashed* (`sha256(token)`) so a database leak doesn't yield active sessions. The token-hash, not the token, is the lookup key.

**Subscription connect-time auth**: `auth.WebsocketInitFunc` reads the bearer from the `connection_init` payload (`{ "authorization": "Bearer <token>" }`), resolves the session, attaches the principal to the WebSocket connection context. Per-event re-check (R4 above) reads from the same context.

**Mid-session revocation**: `revokeSession(sessionId)` mutation sets `revoked_at`. The next request (HTTP or subscription event) finds `revoked_at != NULL` in `auth.Resolve(...)` and fails closed. No active-connection eviction is needed because the dispatcher's per-event re-check catches it within one event.

**Alternatives considered**:
- *External IdP (OIDC)* — Clarification Q4 rejected; multi-household machinery before there are multiple households.
- *Static API key in deployment config* — no revocation surface; defeats Story 3.

---

## R7: Subscription auth re-check — server-side filter + client-side refetch

**Decision**: Two layers of auth, both required.

**Server**:

```go
func (d *Dispatcher) dispatch(evt EventEnvelope) {
    entity, err := d.loadByTopic(evt.Topic, evt.ID)  // single-row fetch
    if err != nil { return }
    d.mu.RLock(); defer d.mu.RUnlock()
    for sub := range d.subs {
        if !sub.Match(evt.Topic, evt.ID) { continue }
        if !auth.Can(sub.Principal, "view", entity) { continue } // silently skip
        select { case sub.Out <- evt: ; default: sub.DroppedCount.Add(1) }
    }
}
```

**Client**:
- Receives `{__typename, id}` on the subscription.
- Issues a `task(id:)` / `pendingDecision(id:)` / `agentAssignment(id:)` refetch through the *normal* `/graphql` HTTP path, which runs through the same `auth.Middleware` and `auth.Can(...)` decision points.
- If the refetch returns null (auth revoked between emit and refetch — a real race), the client drops the event silently.

**Why two layers**: the server-side filter is a *latency* optimization — it avoids waking the client for events the client can't see. The client-side refetch is the *correctness* guarantee — it's the same authoritative path as direct queries. Either alone would be insufficient: server-only is a single failure mode (the auth call there is the only check); client-only would force every subscriber to refetch every event and let a hostile client see ids it can't view.

---

## R8: `drift` outbox flush — last-write-wins reconciliation

**Decision**: The outbox is a single SQLite table `outbox(id INTEGER PK AUTOINCREMENT, op TEXT, target_id TEXT, args TEXT (JSON), created_at INTEGER)`. On reconnect (or app foreground with online status), flush in `created_at` order. Each entry is sent as the corresponding GraphQL mutation; on success, delete the row; on `NOT_FOUND` / `ALREADY_RESOLVED` errors, also delete (the server has authoritative state — last-write-wins by acceptance).

**Rationale**:
- Phase 2's low-stakes writes are *commutative on the target* — dismissing an already-dismissed task is a no-op, marking-read an already-read item is a no-op. Last-write-wins is sufficient.
- The drift schema is the smallest thing that does the job; no ack/nack queue, no exactly-once semantics needed.

**Conflict cases**:
- Server deleted the target while the client was offline: returns `NOT_FOUND`; client drops the outbox entry.
- Server already resolved the target by another channel: returns `ALREADY_RESOLVED`; client drops the outbox entry.
- Network blip mid-flush: the outbox entry stays; the next flush retries.

---

## R9: Push payload shape — APNs and FCM concrete details

**Decision**: APNs payload exactly:

```json
{
  "aps": {
    "alert": { "title": "<GenericTitle>", "body": "" },
    "sound": "default",
    "content-available": 1,
    "category": "TENDANT_INBOX_ITEM"
  },
  "deep_link_id": "<DeepLinkID>"
}
```

FCM v1 message exactly:

```json
{
  "message": {
    "token": "<deviceToken>",
    "notification": { "title": "<GenericTitle>", "body": "" },
    "data": { "deep_link_id": "<DeepLinkID>" },
    "android": { "priority": "HIGH" },
    "apns": { "headers": { "apns-priority": "10" } },
    "webpush": { "headers": { "Urgency": "high" } }
  }
}
```

**Rationale**:
- Both payloads carry the *generic title* in the alert/notification surface (the only user-visible string) and the *deep-link id* in a side channel for the app to read. Nothing else.
- `content-available: 1` (iOS) and the `data` block (FCM) carry the deep-link id even when the user doesn't tap — apps that are foregrounded can opportunistically pre-fetch.
- High priority on both ensures wake-from-background; this is the "guarantee" channel.

**Body intentionally empty**: a non-empty body field is where task content tends to leak. By policy: `body == ""`.

---

## R10: Audit additions for sessions and push attempts

**Decision**: Three new `audit_messages.kind` values, written additively (no schema change; the `kind` column is `text`):

- `session_issued` — payload `{session_id, device_displayName, source: "pairDevice"}`. `from_principal` = the owner; `to_principal` = NULL.
- `session_revoked` — payload `{session_id, reason}`. `from_principal` = the owner; `to_principal` = NULL; `in_reply_to` = the `session_issued` row.
- `push_attempted` — payload `{push_step_id, recipient_principal, platform, outcome: "ok"|"transient_error"|"token_invalid", provider_message_id?, error?}`. Written from inside the DBOS push step (in the same tx as the step's idempotency record).

These satisfy Principle VI (every gate verdict, state transition, and inter-agent message audited). The push-attempt records are the operability surface for SC-009 (verifiable token pruning).

---

## R11: Where the inbox query draws from

**Decision**: `inbox(first, after): [InboxItem!]!` is a paginated `UNION ALL` over `pending_decisions` (where `resolved_at IS NULL`) and `agent_assignments` (where `resolved_at IS NULL` and `to_principal = viewer.global_uri`), ordered by `created_at DESC` with a keyset cursor on `(created_at, id)`.

**Why not a single table**: forcing both kinds into one table to simplify the query would warp the data model just for the inbox; the union approach keeps each kind in its natural shape and isolates the join logic to the inbox resolver.

**SQL sketch** (lands in `internal/db/queries/inbox.sql`):

```sql
-- name: ListInbox :many
SELECT id, kind, task_id, created_at FROM (
  SELECT id, 'pending_decision'::text AS kind, task_id, created_at
    FROM pending_decisions
    WHERE resolved_at IS NULL
  UNION ALL
  SELECT id, 'agent_assignment'::text AS kind, task_id, created_at
    FROM agent_assignments
    WHERE resolved_at IS NULL AND to_principal = $1
) AS i
WHERE (i.created_at, i.id) < ($2::timestamptz, $3::uuid)  -- keyset cursor
ORDER BY i.created_at DESC, i.id DESC
LIMIT $4;
```

The resolver then loads the typed row from the matching base table and dispatches to the right gqlgen union member (`ApprovalRequest` / `AgentQuestion` / `PromotionProposal` / `AgentAssignment`).

For Phase 2, `pending_decisions` is empty in practice (no gate yet), but the inbox surface handles both kinds so Phase 3 just starts inserting `pending_decisions` rows and they appear in the inbox with zero additional work.

---

## R12: GraphQL union member discrimination

**Decision**: `pending_decisions.kind` (existing `decision_kind` enum: `approval_request | agent_question | promotion_proposal`) discriminates which `PendingDecision` implementation the resolver returns. `agent_assignment` rows always become `AgentAssignment`. `InboxItem.__typename` is derived from the source row.

**Rationale**: gqlgen requires `IsXxx()` interface methods on union members; resolving `InboxItem` requires returning a concrete Go struct that implements both `IsInboxItem()` and the appropriate `IsPendingDecision()` where applicable. The resolver assembles concrete structs from the union of rows in R11 above.

---

## Summary table

| Decision area | Choice | Where it lives |
|---|---|---|
| Subscription protocol | `graphql-transport-ws` only | `server.go`, `lib/core/graphql/client.dart` |
| Push provider seam | typed `PushBody`, `Provider`, `Selector` | `internal/push/` |
| Push retry semantics | DBOS step + DBOS durable queue | `internal/push/push.go`, `internal/durable/dbos.go` |
| LISTEN dispatcher | single dedicated `pgx.Conn`, in-process fan-out | `internal/realtime/` |
| Flutter packages | ferry + riverpod + drift + go_router + firebase_messaging | `apps/mobile/pubspec.yaml` |
| Session token | 32-byte random, sha256-hashed at rest, bearer on HTTP + WS init | `internal/auth/session.go` |
| Setup secret | one-time per boot, from `TENDANT_SETUP_SECRET` env var | `internal/auth/session.go` |
| Auth re-check | server filter + client refetch | `internal/realtime/dispatcher.go`, ferry refetch |
| Outbox conflict | last-write-wins; drop on NOT_FOUND / ALREADY_RESOLVED | `lib/core/offline/outbox.dart` |
| Push payload shape | hybrid alert + data; empty body; generic title only | `internal/push/body.go` |
| Audit additions | `session_issued`, `session_revoked`, `push_attempted` | `audit_messages.kind` (no schema change) |
| Inbox source | `UNION ALL` over `pending_decisions` + `agent_assignments` | `internal/db/queries/inbox.sql` |
| Union discrimination | `pending_decisions.kind` + source-table-as-kind for assignments | `internal/inbox/inbox.go` |

All Clarifications from `spec.md § Clarifications` map onto a concrete artifact in the layout above. No open NEEDS CLARIFICATION remains.
