# Data Model — Phase 2 Operator Edge & the Wake Channel

Phase 0 already shipped the bulk of the spine. Phase 2 adds **one new table** (`sessions`) and **one nullable column** to an existing table (`agent_assignments.to_principal`), plus **three new audit kinds** (no schema change — `audit_messages.kind` is `text`). The GraphQL contract gains a substantial additive surface; see `contracts/graphql.v1.graphqls`.

---

## Schema changes (one additive migration)

### `db/migrations/00003_operator_edge_wake.sql`

```sql
-- +goose Up

-- Sessions: owner-scoped, per-device bearer tokens (Clarification Q4).
-- token_hash is sha256(raw token); we never store the raw token.
CREATE TABLE sessions (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  principal_id  uuid NOT NULL REFERENCES principals(id) ON DELETE CASCADE,
  token_hash    bytea NOT NULL,
  display_name  text NOT NULL,          -- e.g. "Brad's iPhone"
  created_at    timestamptz NOT NULL DEFAULT now(),
  last_seen_at  timestamptz NOT NULL DEFAULT now(),
  revoked_at    timestamptz,
  UNIQUE (token_hash)
);
CREATE INDEX idx_sessions_principal ON sessions(principal_id) WHERE revoked_at IS NULL;

-- agent_assignments: add to_principal so the push fan-out worker knows who to
-- wake. Existing rows from Phase 1 stay null (the chain workflow always routed
-- to the seeded owner in Phase 1; Phase 2 populates this column going forward).
ALTER TABLE agent_assignments
  ADD COLUMN to_principal text;
CREATE INDEX idx_assign_to_principal ON agent_assignments(to_principal) WHERE resolved_at IS NULL;

-- +goose Down

DROP INDEX IF EXISTS idx_assign_to_principal;
ALTER TABLE agent_assignments DROP COLUMN IF EXISTS to_principal;

DROP INDEX IF EXISTS idx_sessions_principal;
DROP TABLE IF EXISTS sessions;
```

**Why `text` for `to_principal` and not `uuid REFERENCES principals(id)`**: Phase 0 chose `text` for `agent_assignments.from_principal`, storing the principal's `globalUri` (the federation handle) rather than the local UUID. Phase 2 follows the same convention: `to_principal` stores a `globalUri`, so remote-household principals work the same shape on the wire (Principle VIII). The Phase-0 seeded owner's `globalUri` is the value used through Phase 2.

**Why a `to_principal` column rather than a join table**: each open assignment routes to exactly one principal in Phase 2. A join table would over-engineer; multi-recipient routing (broadcast, group household) is explicitly deferred.

**No other Phase 0 tables change.** Specifically:

- `device_tokens` (from Phase 0) is used as-is. The `token` is the PK; uniqueness is on `token` alone, which means a single device that reinstalls and gets a fresh FCM token registers a new row — this is correct, the old token row will be pruned the next time a push targeted at the old token gets `IsTokenInvalid`.
- `pending_decisions` (from Phase 0) is used as-is — already has `kind`, `payload`, `tool_id`, `disclosure_class`, `resolved_at`, `resolution`. Phase 2 reads it for the inbox; Phase 3 writes it.
- `tools` (from Phase 0) is used as-is — already has `global_uri`, `rung`, `permissions`, `overseer_instructions`. Phase 2 exposes it on the wire (read-only).
- `audit_messages` (from Phase 0) gains three new `kind` values without schema change.

---

## Entities

### `sessions` (new)

| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | server-generated |
| `principal_id` | uuid → `principals(id)` | the owner this session authenticates as |
| `token_hash` | bytea, UNIQUE | `sha256(raw_token)`; raw token never persisted |
| `display_name` | text | human-readable device label from pairing flow |
| `created_at` | timestamptz | session issuance |
| `last_seen_at` | timestamptz | updated lazily on every authenticated request |
| `revoked_at` | timestamptz | NULL while active; set by `revokeSession` mutation |

**Lifecycle**:
- `INSERT` on `pairDevice` success (Q4 / R6).
- `UPDATE revoked_at = now()` on `revokeSession`. No DELETE — the row stays as audit history.
- Auth middleware path on every request: `SELECT principal_id FROM sessions WHERE token_hash = sha256($bearer) AND revoked_at IS NULL`; if no row, the request is unauthenticated (resolvers see no principal in context and most fail closed).
- `last_seen_at` updated by the middleware via an `UPDATE` that runs outside the request's transaction (best-effort).

**Audit**:
- `session_issued`: payload `{session_id, display_name, source: "pairDevice"}`.
- `session_revoked`: payload `{session_id, reason?}`; `in_reply_to` points at the `session_issued` row.

### `agent_assignments` (extended — new column `to_principal`)

| Column | Type | Notes (Phase 2 additions in **bold**) |
|---|---|---|
| `id` | uuid PK | Phase 0 |
| `task_id` | uuid → `tasks(id)` | Phase 0 |
| `stage` | `chain_stage` | Phase 0 |
| `from_principal` | text | Phase 0; NULL = owner-authored |
| `ask` | text | Phase 0 |
| `gathered_context` | jsonb | Phase 0 |
| `created_at` | timestamptz | Phase 0 |
| `resolved_at` | timestamptz | Phase 0 |
| **`to_principal`** | **text** | **NEW: globalUri of the principal to notify. NULL = unassigned (pre-Phase-2 rows or future broadcast).** |

**Phase 2 write path**: the chain workflow's `InsertAssignment` step is amended to set `to_principal = <owner-principal-globalUri>` (the seeded owner). The push fan-out worker reads this column to know whose device tokens to look up.

### `audit_messages` (extended — three new `kind` values)

No schema change. New `kind` values:

| `kind` | When written | `payload` shape |
|---|---|---|
| `session_issued` | `pairDevice` success | `{session_id, display_name, source: "pairDevice"}` |
| `session_revoked` | `revokeSession` mutation | `{session_id, reason?}` |
| `push_attempted` | Inside the DBOS push step (per attempt) | `{push_step_id, recipient_principal, platform, outcome: "ok"\|"transient_error"\|"token_invalid", provider_message_id?, error?, attempt}` |

The `push_attempted` rows form an observable trail for SC-009 (token pruning verifiable in the audit log) and SC-001 (timing bounds verifiable end-to-end).

---

## Authorization model

Phase 2 introduces a central `auth.Can(ctx, principal, action, target)` decision point. For Phase 2's single-owner profile, the rule is trivial — the owner can do anything that touches an entity owned by the owner — but the decision-point's *signature* and *placement* are the federation seam (FR-033).

**Action verbs** Phase 2 recognizes:

- `view` — applied to Task, AgentAssignment, PendingDecision, Tool, InboxItem.
- `complete` — applied to AgentAssignment (for `completeTask`).
- `dismiss` — applied to Task in state `PROPOSED` (for `dismissProposedTask`).
- `accept` — applied to Task in state `PROPOSED` (for `acceptProposedTask`).
- `cancel` — applied to Task non-terminal (for `cancelTask`).
- `revoke_session` — applied to Session.
- `register_device` — applied to Principal (the registrant's self-principal).

**Target shapes**: `Can(...)` takes either a typed Go struct (the loaded entity) or a typed reference (`TaskRef`, `SessionRef`) when the entity hasn't been loaded yet. Resolvers that need to authorize *before* loading use the reference shape.

**Subscription emit re-check**: the dispatcher calls `auth.Can(sub.Principal, "view", entity)` after loading the entity by id; revoked viewers get silently skipped (no error to the client).

**Visibility-as-SQL rule (FR-031 / SC-006)**: every multi-row read passes the viewer principal's globalUri as a parameter and filters in SQL. The `inbox.sql` query takes `to_principal = $1` directly. The CI grep gate looks for patterns like `for ... if !Can(... ).Allowed` immediately after a list query — those would be post-fetch filtering and are rejected.

---

## GraphQL types (full Phase 2 additions — additive)

See `contracts/graphql.v1.graphqls` for the canonical SDL. Summary of additions:

### New types

```graphql
type Session {
  id: ID!
  displayName: String!
  createdAt: Time!
  lastSeenAt: Time!
  # token NEVER appears on Query.session — it's only returned once at pairDevice mint
}

type Tool {
  id: ID!  globalUri: String!  name: String!
  rung: AutonomyLevel!
  permissions: JSON!
  overseerInstructions: String
}

type Artifact { kind: String!  content: JSON!  recipient: String }
type Mandate  { goal: String!  constraints: JSON!  guardrails: JSON! }

interface PendingDecision { id: ID!  task: Task!  createdAt: Time! }

type ApprovalRequest implements PendingDecision {
  id: ID!  task: Task!  createdAt: Time!
  tool: Tool!  payload: ApprovalPayload!
}
type AgentQuestion implements PendingDecision {
  id: ID!  task: Task!  createdAt: Time!
  asker: Principal!  question: String!  disclosureClass: String
}
type PromotionProposal implements PendingDecision {
  id: ID!  task: Task!  createdAt: Time!
  tool: Tool!  fromLevel: AutonomyLevel!  toLevel: AutonomyLevel!  evidence: JSON!
}

type Notification { id: ID!  kind: String!  createdAt: Time!  taskId: ID }
```

### New unions

```graphql
union ApprovalPayload = Artifact | Mandate
union InboxItem = ApprovalRequest | AgentQuestion | PromotionProposal | AgentAssignment
```

### Extended `Query`

```graphql
extend type Query {
  inbox(first: Int, after: String): [InboxItem!]!
  pendingDecision(id: ID!): PendingDecision           # for subscription refetch
  agentAssignment(id: ID!): AgentAssignment           # for subscription refetch
  sessions: [Session!]!                                # list this principal's active sessions
}
```

### New mutations

```graphql
enum DevicePlatform { IOS ANDROID WEB }

extend type Mutation {
  # Session pairing & revocation (Q4)
  pairDevice(setupSecret: String!, displayName: String!): SessionMintResult!
  revokeSession(sessionId: ID!): Session!

  # Device-token registration
  registerDeviceToken(token: String!, platform: DevicePlatform!): Boolean!
  unregisterDeviceToken(token: String!): Boolean!

  # Decision-resolving mutations declared additively (FR-005); return
  # NOT_YET_AVAILABLE in Phase 2; wired in Phase 3.
  approveArtifact(decisionId: ID!): PendingDecision!
  rejectApproval(decisionId: ID!, reason: String): PendingDecision!
  answerQuestion(decisionId: ID!, answer: String!): PendingDecision!
  decidePromotion(decisionId: ID!, accept: Boolean!): PendingDecision!
}

# SessionMintResult is the only place the raw bearer token is ever returned.
type SessionMintResult {
  session: Session!
  token: String!
}
```

### New subscriptions

```graphql
type Subscription {
  inboxItemArrived: InboxItem!
  taskChanged(taskId: ID): Task!
  notificationReceived: Notification!
}
```

`taskChanged`'s `taskId` is **optional** — `null` = subscribe to all viewer-visible tasks; non-null = subscribe to one. Both forms refilter through `auth.Can` on every event.

### No existing field is changed

All Phase 0/1 types (`Task`, `AgentAssignment`, `User`, `Bot`, `Principal`, `TaskState`, `ChainStage`, `AutonomyLevel`, `WorkflowRef`, `TaskEdge`, `TaskConnection`, `PageInfo`) are unmodified. All Phase 1 mutations (`createTask`, `completeTask`, `cancelTask`, `acceptProposedTask`, `dismissProposedTask`) are unmodified.

This is what locks the contract under Principle VII's "evolution MUST be additive" rule.

---

## Cross-cutting validation rules

- `pairDevice(setupSecret, displayName)`: `setupSecret` MUST match the in-process armed secret AND not have been consumed since boot; `displayName` non-empty (≤200 chars). Failure: `BAD_SETUP_SECRET` (typed error).
- `revokeSession(sessionId)`: the calling session MUST have `Can(... "revoke_session", session)`; the session being revoked MUST belong to the calling principal (in Phase 2, both are the seeded owner). Failure: `SESSION_NOT_FOUND` or `FORBIDDEN`.
- `registerDeviceToken(token, platform)`: `token` non-empty, `platform` valid enum; upsert by `token`; sets `owner_id = calling principal`.
- `unregisterDeviceToken(token)`: deletes the row if it belongs to the calling principal.
- `inbox(first, after)`: `first` ∈ [1, 50], default 25; `after` is a base64-encoded `(timestamp, uuid)` cursor.
- `approveArtifact` / `rejectApproval` / `answerQuestion` / `decidePromotion`: ALL return `NOT_YET_AVAILABLE` in Phase 2 (FR-005); Phase 3 wires the real handlers.
- Subscription `connection_init` payload MUST contain `{authorization: "Bearer <token>"}`; missing or invalid → close the connection with `4401 Unauthorized` (graphql-transport-ws convention).
