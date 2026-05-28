# Feature Specification: Operator Edge & the Wake Channel (Phase 2)

**Feature Branch**: `003-operator-edge-wake`
**Created**: 2026-05-28
**Status**: Draft
**Input**: User description: "Phase 2 — Operator Edge & the Wake Channel. Build the human edge: the full versioned GraphQL contract, the two delivery channels (foreground subscription + background push) off one trigger, and a Flutter client that renders the inbox and submits decisions/assignments."

## Overview

Phase 1 left the chain workflow able to produce work items (`AgentAssignment` rows) that need a human, but with no surface to deliver them. Phase 2 builds that surface — the **operator edge** — so the owner can see and act on the queue from a real client, and so any future durable human-wait (the gate, Phase 3) has somewhere to escalate to.

The load-bearing claim of this phase: **the moment the core enters a durable human-wait is the moment the operator edge must reach the human — and reaching a backgrounded phone is push, not a socket.** From this follows the two-channel design: one trigger inside the core fans out to (a) a foreground GraphQL subscription for the open app, and (b) a background push (APNs/FCM) for the closed app. The push is the *guarantee*; the subscription is a latency optimization on top.

## Clarifications

### Session 2026-05-28

- Q: Contract-versioning policy — locked for all five long-lived contracts. → A: **Hybrid** — additive + field-deprecation as the default within a version; a versioned endpoint is introduced only for breaking changes that cannot be field-deprecated. Deprecation window: at least one minor release between deprecation announcement and removal.
- Q: Push payload delivery mode (alert / silent / hybrid). → A: **Hybrid** — alert push (user-visible generic title) plus `content-available: 1` on iOS / FCM notification + data payload on Android & web, so the OS displays the banner *and* the app may opportunistically update in background where the platform allows. Alert delivery is what underwrites the "guarantee" claim; the data side is best-effort.
- Q: Push retry / provider-failure policy. → A: **DBOS-step push** — each push attempt is a DBOS step (or enqueued on a DBOS durable queue), so retries are crash-safe, uniform with the Phase 1 chain workflow's durability model, and observable through the same machinery. Provider delivery remains best-effort by nature; what is durable is the *attempt* (not the wake itself).
- Q: Auth identity surface for Phase 2. → A: **Owner-scoped session tokens** — first-launch device pairing exchanges a one-time deployment-config setup secret for a per-device server-side session row; the session token is persisted on the device and sent as a bearer on every request and on subscription connect. Revocation invalidates the session row server-side (Story 3 becomes concretely testable). Federation in later phases is "issue more sessions, bind to more principals" — no resolver changes required.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Backgrounded phone is reached when something needs me (Priority: P1)

The owner has the app installed on a phone with the screen off, app backgrounded. Somewhere in the system, the Phase 1 chain reaches a stage that creates an `AgentAssignment` — i.e., something needs a decision or completion from the owner. Within seconds, a push notification reaches the device. Tapping the push opens the app directly on the item; from there the owner can `completeTask` and the chain resumes.

**Why this priority**: This is the entire reason Phase 2 exists. Without it, "things that need me find me" is rhetoric. Foreground subscriptions, the inbox query, and the offline rail are all secondary to the push delivery guarantee — those layers exist *because* push exists and shapes the rest of the edge.

**Independent Test**: Background the app on a physical device (not a simulator — see Risks). Trigger an assignment by walking a task through the Phase 1 chain to a human-wait. Verify a push lands, the tap opens the app on the correct item, and `completeTask` from that screen resumes the chain.

**Acceptance Scenarios**:

1. **Given** the app is installed and backgrounded on iOS, **When** the core enters a human-wait for the owner, **Then** an APNs push arrives carrying only a deep-link id + a generic title (no task content), and tapping it routes the app to that specific inbox item.
2. **Given** the app is installed and backgrounded on Android, **When** the core enters a human-wait for the owner, **Then** an FCM push arrives with the same contract (deep-link id + generic title) and deep-links the same way.
3. **Given** the owner has opened the deep-linked item, **When** the owner submits `completeTask`, **Then** the chain advances past the wait and the item disappears from the inbox.
4. **Given** a device token registered against the owner has been invalidated by the provider (uninstall, token rotation), **When** the next push is attempted, **Then** the worker prunes that token and does not retry it.
5. **Given** APNs/FCM credentials are not yet configured in the deployment, **When** the core enters a human-wait, **Then** a `LogProvider` stub records the intended push at a structured log line so the flow is end-to-end testable without real provider credentials.

---

### User Story 2 - Foregrounded app sees new work without polling (Priority: P2)

The owner has the app open and foregrounded — looking at the inbox, or at a specific task. When new work appears (a new assignment, a state change on a visible task), the screen updates within sub-second latency without the client polling. The same trigger that fired the push (Story 1) also drives this update; the difference is the *channel*, not the source of truth.

**Why this priority**: This is the latency optimization. It is not the guarantee — if the subscription dies, the push still wakes the user; if both fail, the inbox query on next foreground still recovers. But for the common case of an attentive operator, polling is the wrong default and the experience suffers without live updates.

**Independent Test**: Foreground the app. Trigger a new assignment for the owner. Verify the inbox updates within a few seconds with no manual refresh, and that the resulting item is identical (by id, by content) to what would have arrived had the app been backgrounded.

**Acceptance Scenarios**:

1. **Given** the app is foregrounded with an active subscription, **When** a new inbox item is created in the core, **Then** the client receives a subscription event identifying the item by id and refetches its full payload through the normal authenticated query path.
2. **Given** the subscription delivers an event for an item the viewer is not allowed to see, **When** the refetch executes, **Then** the refetch returns nothing (auth re-checked at refetch time) and the client does not render the item.
3. **Given** the app has an active subscription on `taskChanged(taskId:)`, **When** that task's lifecycle state or chain stage changes, **Then** the open task view reflects the new state without a manual refresh.

---

### User Story 3 - Revoked viewer stops receiving updates without reconnect (Priority: P2)

A viewer's access to a task is revoked while their subscription is still open. The subscription does *not* keep streaming events for that task; the auth predicate is re-evaluated for each event, and revoked viewers see nothing further on revoked targets — without needing to drop the socket and reconnect.

**Why this priority**: This is the foundation the entire authorization model leans on. Today there is one owner, so the practical surface is small, but the *machinery* — a central `Can(ctx, principal, action, target)` consulted by every resolver, visibility expressed as SQL predicates rather than post-fetch filtering, subscriptions re-checking auth on every event — is what federation (multi-principal, delegated access) will lean on later. Getting it right while the model is simple is the only chance to get it right at all.

**Independent Test**: Open a subscription as a viewer with access to a specific task. Revoke that viewer's access at the data layer. Cause a state change on the task. Verify the subscription neither errors nor emits an event for the now-invisible target, while continuing to deliver events for tasks the viewer still has access to.

**Acceptance Scenarios**:

1. **Given** an active subscription scoped to items visible to the viewer, **When** the viewer's access to a particular item is revoked, **Then** subsequent state changes on that item produce no client-visible event on the existing subscription.
2. **Given** an inbox query, **When** the viewer does not have access to certain items, **Then** those items are filtered at the SQL layer (never returned and then dropped in application code).
3. **Given** any resolver on the operator-edge surface, **When** it serves a field, **Then** it consults the central `Can(ctx, principal, action, target)` decision rather than implementing visibility logic inline.

---

### User Story 4 - Offline-tolerant inbox with a floor-relevant rail (Priority: P3)

The owner loses connectivity. They open the app and can still read their inbox from the last cached state. They can perform low-stakes writes — dismiss a proposed task, mark something read, accept an enrich-only task — and those writes queue locally and flush when the network returns. They cannot submit floor-relevant writes (the kinds that will exist from Phase 3: approving an artifact that contacts a third party, authorizing a mandate, disclosing a secret); the client may let them *compose* such an action but refuses to commit until connectivity is restored, so the core can re-evaluate the hard-rule floor at submit time.

**Why this priority**: There are no floor-relevant actions to refuse yet — those land with the gate in Phase 3. But the rail must be in place *now*, because retrofitting it later means an already-shipped path where floor-relevant writes were optimistic. The job of Phase 2 here is to establish the policy and the guard, not to demonstrate every refusal.

**Independent Test**: Put the device offline. Dismiss a proposed task — confirm the dismissal appears locally and persists to the server upon reconnect. Attempt a (stubbed) floor-relevant action — confirm the client surfaces a "requires connectivity" refusal at commit time.

**Acceptance Scenarios**:

1. **Given** the device is offline, **When** the owner dismisses a proposed task, **Then** the action is recorded in a local outbox and the UI updates optimistically.
2. **Given** the device reconnects with queued outbox entries, **When** the client flushes, **Then** entries are sent last-write-wins; the server is the final source of truth for the resulting state.
3. **Given** the device is offline, **When** the owner attempts a floor-relevant write (stubbed for this phase), **Then** the client refuses to enqueue it and explains that submission requires connectivity.
4. **Given** the device is online and the cache is warm, **When** the owner opens the inbox, **Then** items render from the normalized cache before live data arrives, with no perceived loading state for already-seen items.

---

### User Story 5 - Contract-versioning policy is locked for all five contracts (Priority: P3)

The first of the system's five long-lived versioned contracts ships in this phase. The owner — and any future alternative client author or community extension author — has a clear, written rule for how the schema will evolve: when a change can land as an additive/deprecated field rotation, when it requires a versioned endpoint, and what "stable" means in practice (e.g., a deprecation window before removal).

**Why this priority**: This is a one-time decision with multi-year consequences. Getting it written down once now is far cheaper than retroactively imposing discipline across five contracts and an ecosystem of clients that grew up assuming none.

**Independent Test**: A new contributor (or future-self) reads the policy document, can answer: *given a proposed schema change X, can it land additively or does it need a new version?* Then look at the codified change-process to confirm.

**Acceptance Scenarios**:

1. **Given** the policy is written and committed, **When** a contributor proposes a schema change, **Then** they can determine from the policy alone whether the change is additive (field deprecation path) or breaking (versioned endpoint).
2. **Given** the policy specifies a deprecation window, **When** a deprecated field is removed, **Then** the removal post-dates the documented window from the deprecation announcement.

---

### Edge Cases

- **Push to a killed (force-quit) app.** Some platforms suppress notifications to user-killed apps. The system must behave correctly: ideally still deliver via the OS's silent-push or high-priority paths; minimally, the inbox is correct on next foreground. This is a real product risk and must be tested on devices, not simulators.
- **Web-push when the tab is closed.** Browser support varies. The acceptable degradation must be explicit (best-effort delivery, falls back to next-foreground read).
- **Pushed event fires before the corresponding row is durably committed.** Triggers ride on `pg_notify`, which is transactional with the committing write; this must hold across all code paths that produce inbox items.
- **Subscription receives an event for a viewer whose session has just expired or been revoked.** The refetch should fail closed (no item delivered) rather than racing the auth re-check.
- **Outbox entry references an item that has been deleted or invalidated server-side.** Flush must reconcile without corrupting either side; the server is authoritative.
- **Duplicate device tokens** across reinstalls or token-rotation events. Registration must converge, not accumulate dead rows.
- **Push provider returns "invalid token"** mid-fan-out. Token must be pruned and the fan-out continues for remaining tokens.
- **Dispatcher backpressure.** A long burst of `pg_notify` events while no subscribers exist must not back up the listener loop or grow memory unboundedly.

## Requirements *(mandatory)*

### Functional Requirements

#### Contract (the versioned GraphQL surface)

- **FR-001**: System MUST publish a versioned GraphQL contract exposing the `PendingDecision` interface, the `ApprovalRequest`/`AgentQuestion`/`PromotionProposal`/`AgentAssignment` types (the first three implementing `PendingDecision`), and the `InboxItem` union over all four item kinds.
- **FR-002**: System MUST expose the `ApprovalPayload = Artifact | Mandate` union and the supporting `Tool`, `Artifact`, and `Mandate` types as specified in the inline artifact (see Provenance).
- **FR-003**: System MUST expose `inbox(first: Int, after: String): [InboxItem!]!` as a paginated, viewer-scoped query that returns only items the viewer is authorized to see.
- **FR-004**: System MUST expose `registerDeviceToken(token, platform)` and `unregisterDeviceToken(token)` mutations and a `DevicePlatform` enum with values `IOS`, `ANDROID`, `WEB`.
- **FR-005**: System MUST declare the decision-resolving mutations (`approveArtifact` and siblings) in the schema now, even though they cannot be reached until Phase 3 wires the gate. They MUST return a well-defined "not yet available" error if called before Phase 3 lands.
- **FR-006**: System MUST expose subscriptions `inboxItemArrived`, `taskChanged(taskId: ID)`, and `notificationReceived` per the inline artifact.
- **FR-007**: The contract MUST include a `Principal` shape (carried over from Phase 0) and a `globalUri` field on every actor type, so federation can be added later without breaking clients.
- **FR-008**: The contract version MUST be a stable identifier on the wire (e.g., `v1`). The locked policy governing changes is:
  - **Within a version**: changes MUST be additive (new fields/types/enums/inputs). Breaking changes within a version are prohibited.
  - **Field deprecation path**: any field that needs to be retired MUST first be marked with the `@deprecated(reason:)` directive and remain functional for **at least one minor release** before removal.
  - **Versioned endpoint path**: a new versioned endpoint (e.g., `v2`) MUST be introduced only for breaking changes that cannot be expressed as additive + field-deprecation (e.g., changing a field's type semantics in an incompatible way, removing a required interface implementation). Introducing `v2` does NOT immediately retire `v1`; the prior version MUST remain available for a documented retirement window.
  - The policy MUST be documented as a project artifact and referenced from both `CLAUDE.md` and `services/api/graph/schema.graphqls`.

#### Wake channel (one trigger → two channels)

- **FR-010**: Whenever the core durably writes a row that requires the owner's attention (a `PendingDecision` or an `AgentAssignment`), a transactional `pg_notify("tendant_events", {topic, data: {id}})` MUST fire as part of the same commit, carrying only IDs (never task content), and respecting the 8 KB notify payload cap.
- **FR-011**: An in-process dispatcher MUST `LISTEN` on `tendant_events` and fan messages out to active GraphQL subscribers, scoped to subscriptions the message matches (e.g., `inboxItemArrived` for any inbox item; `taskChanged` for events on the watched task).
- **FR-012**: When the dispatcher routes an event to a subscriber, the client MUST refetch the referenced entity by id through the normal authenticated query path. The realtime layer MUST NOT carry payload data.
- **FR-013**: Auth MUST be re-evaluated on the refetch; a revoked viewer MUST receive nothing for the now-invisible target (auth re-checked per event, not only at subscription start).
- **FR-014**: A fan-out worker MUST react to inbox-relevant events by looking up the device tokens registered for the target principal and dispatching a push through a `Selector` that routes `IOS → APNs` and `ANDROID|WEB → FCM`.
- **FR-014a**: Each push attempt MUST be a **DBOS step** (or enqueued on a DBOS durable queue), so retries are crash-safe and observable through the same durability machinery as the Phase 1 chain workflow. Transient provider errors (5xx, 429, network timeout) MUST be retried by the DBOS engine; permanent errors (invalid token per FR-017) MUST short-circuit and prune. The push *attempt* is durable; provider *delivery* remains best-effort by nature.
- **FR-015**: Push payloads MUST contain only a deep-link id and a generic title; no task content (subject lines, recipient names, gathered context) may leak into the push body.
- **FR-015a**: Pushes MUST be sent as **hybrid alert + data** — the user-visible alert (banner with the generic title) is the delivery guarantee; the data payload (`content-available: 1` on iOS APNs, FCM `notification` + `data` on Android, FCM web-push on web) is opportunistic background-refresh. Silent-only (data-only) pushes are prohibited as the primary delivery mode because iOS throttling and force-quit behavior make them unsound as a guarantee.
- **FR-016**: The push fan-out MUST be urgency-gated — items not requiring immediate operator attention MUST NOT trigger a push, even if they trigger a subscription event. (The exact urgency rule may be conservative for Phase 2; precise gating evolves with later phases.)
- **FR-017**: When the push provider reports a token as invalid (`IsTokenInvalid` or equivalent), the system MUST prune that token from registration so it is not retried.
- **FR-018**: When APNs/FCM credentials are not configured, a `LogProvider` stub MUST stand in: every intended push MUST emit a structured log entry sufficient to verify end-to-end behavior in tests and demos.
- **FR-019**: Real provider credentials MUST be loaded from deployment configuration (not committed to the repo), with a clear seam to swap the stub for the real provider.

#### Client (Flutter, one codebase for mobile / desktop / web)

- **FR-020**: The client MUST render the unified inbox by switching on `InboxItem.__typename` so all four item kinds are listed in one place.
- **FR-021**: The client MUST render an `AgentAssignment` detail view and submit `completeTask` from it.
- **FR-022**: The client MUST display read-only states for `ApprovalRequest`, `AgentQuestion`, and `PromotionProposal` items (full approval/answer UI lands in Phase 3 or later — the *types* render now, the *screens* for action come later).
- **FR-023**: The client MUST register its device token (`registerDeviceToken`) on first launch after permission grant, re-register on token rotation, and `unregisterDeviceToken` on logout.
- **FR-024**: A push tap MUST deep-link straight to the referenced item via `go_router` routes that match the contract's id shape.
- **FR-025**: The client MUST read from a normalized GraphQL cache so the inbox is available offline based on last-seen state.
- **FR-026**: The client MUST persist low-stakes writes (dismiss a proposed task, mark read, accept an enrich-only task) to a local SQLite outbox while offline and flush them last-write-wins on reconnect.
- **FR-027**: The client MUST refuse to enqueue a floor-relevant write while offline (the rail is present now even though no such actions exist yet); the user MUST see a clear "requires connectivity" affordance, and the client MAY permit composing the action locally as long as commit is gated.
- **FR-028**: The client MUST present a single login/identity surface backed by **owner-scoped session tokens**: on first launch the client exchanges a one-time deployment-config setup secret for a per-device server-side session row, persists the returned session token securely on the device, and sends it as the bearer credential on every HTTP request and subscription connect. `unregisterDeviceToken` on logout MUST also invalidate the session row.

#### Authorization

- **FR-030**: Every resolver on the operator-edge surface MUST consult a central `Can(ctx, principal, action, target)` decision before returning data or accepting a mutation.
- **FR-031**: Visibility restrictions MUST be expressed as SQL predicates pushed into queries; post-fetch filtering at the resolver layer is prohibited.
- **FR-032**: Subscriptions MUST re-check authorization on every emitted event, not only at subscription start, so revocation takes effect without forcing a reconnect.
- **FR-033**: For Phase 2's single-owner profile, `Can(...)` MUST resolve the principal from the bearer session token (FR-028) and bind to the owner principal seeded in Phase 0. Revoking a session MUST cause subsequent requests and subscription events on that connection to be denied without requiring the client to reconnect. The decision-point exists now so federation/multi-principal extensions in later phases require no resolver edits — only additional session-to-principal bindings.

### Key Entities *(include if feature involves data)*

- **`PendingDecision`** *(interface)*: Anything that needs the owner to make a call. Implementations: `ApprovalRequest` (tool wants to commit an Artifact/Mandate), `AgentQuestion` (an agent needs info), `PromotionProposal` (proposed autonomy ratchet for a tool). Common shape: `id`, `task`, `createdAt`.
- **`AgentAssignment`**: Phase 1 entity, restated on the wire: a chain-emitted ask for the human at a specific stage. Carries `id`, `task`, `createdAt`, `stage`, `fromAgent`, `ask`, `gatheredContext`.
- **`InboxItem`** *(union)*: The single surface across all four kinds above; this is what `inbox`, `inboxItemArrived` deliver.
- **`Tool`**: First-class actor in the system, identified by `globalUri`; carries its current autonomy `rung`, owner-authored `permissions`, and (from Phase 4) `overseerInstructions`. Phase 2 ships the *type* on the wire; the autonomy machinery lands later.
- **`Artifact` / `Mandate`**: The two payload kinds an `ApprovalRequest` can carry. Phase 2 ships the types; the screens to act on them ship in Phase 3.
- **`DeviceToken`** *(server-side registration record)*: `{principal, platform, token, registered_at, last_seen, invalidated_at}`. The fan-out worker reads from these; the providers' `IsTokenInvalid` writes `invalidated_at`.
- **`Session`** *(server-side bearer-token row)*: `{id, principal, created_at, last_seen, revoked_at}`. Issued at first-launch pairing in exchange for a one-time deployment-config setup secret. The bearer presented by the client maps to this row; `revoked_at` is the revocation point Story 3 tests against.
- **`tendant_events` notify channel** *(Postgres `LISTEN/NOTIFY`)*: The single trigger feeding both channels. Carries `{topic, data: {id}}`, IDs only.
- **`Outbox` entry** *(client-side, SQLite)*: A queued low-stakes mutation `{op, target_id, args, created_at}` flushed last-write-wins on reconnect.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With the app backgrounded on a real phone, completing the Phase 1 chain to a human-wait produces a push that arrives in **under 10 seconds** in 95% of trials over a stable network, and tapping it lands the owner on the correct item.
- **SC-002**: With the app foregrounded, a newly created inbox item is visible in the UI within **2 seconds of its commit** without any client-initiated poll.
- **SC-003**: Push payloads contain **zero task-content fields** when inspected at the network layer (verified by a test that asserts only `{deep_link_id, generic_title}` are present).
- **SC-004**: Revoking a viewer's access to a task causes subsequent state-change events for that task to be **suppressed within one event** on the existing subscription (no reconnect required).
- **SC-005**: 100% of operator-edge resolvers consult `Can(...)` before returning data — verifiable by static check, code review, or a resolver-registration test.
- **SC-006**: 0 cases of post-fetch visibility filtering in the data layer — verifiable by code review or grep-based lint at CI time.
- **SC-007**: With the device offline, dismissing a proposed task succeeds locally in **under 200 ms**, persists across app restart, and flushes to the server on the **first successful reconnect**.
- **SC-008**: Floor-relevant writes are refused offline in **100% of attempts** (since no such actions exist yet, the test uses a stubbed action wired to the rail).
- **SC-009**: A token returned as invalid by the provider on a push attempt is **pruned before the next attempt** — verifiable in the LogProvider's log trace or via a unit test against the prune path.
- **SC-010**: The contract-versioning policy is committed as a project document, referenced from `CLAUDE.md` and from `services/api/graph/schema.graphqls`, and answers the test question: *"given a hypothetical change X, is it additive or breaking?"* unambiguously in three reviewer trials.
- **SC-011**: End-to-end demo passes: (1) backgrounded-phone wake; (2) foregrounded subscription update; (3) auth revocation mid-session; (4) offline dismiss + reconnect flush.

## Assumptions

- The owner principal seeded in Phase 0 is the sole inbox subject for Phase 2. Multi-principal/federation is explicitly deferred.
- The Phase 0 `pg_notify` triggers exist and fire transactionally with the commits that produce inbox-relevant rows; if any gaps exist for `AgentAssignment` rows (added in Phase 1), this phase will close them.
- The Phase 1 chain workflow durably produces `AgentAssignment` rows on entering its assignment stages — this is the trigger source for Story 1.
- Real APNs and FCM credentials may not be available during development; the `LogProvider` stub is sufficient for CI and quickstart demos, but the make-or-break risk demands real-provider testing on physical devices before declaring SC-001 met.
- Flutter is the chosen client surface; one codebase serves iOS, Android, desktop, and web. Mobile push is mandatory; desktop/web background-wake is best-effort and degrades gracefully (subscription always; push where the platform allows).
- "Low-stakes" vs. "floor-relevant" write classification is set by the schema/contract, not by per-resolver hand-coded rules — the client knows from the type which rail to take.
- Auth re-check on every subscription event is acceptable for the load envelope of a single household; no scale optimization (event coalescing, viewer-affinity sharding) is required in Phase 2.
- "Urgency-gated push" in Phase 2 is permitted to be conservative (e.g., all `PendingDecision` items + all owner-directed `AgentAssignment` items push; informational state changes do not). Precise gating evolves with the gate (Phase 3) and the disclosure layer (Phase 9).
- The contract-versioning policy is a project-level decision; this phase ships *the policy* and *the first contract under it*, not a versioning engine.
- Generated code (`gqlgen` `generated.go`, `ferry` `__generated__`) is committed and CI checks drift, matching the existing Phase 0/1 convention.

## Dependencies

- **Phase 0 (Foundations & Scaffolding)** — schema, the `pg_notify` triggers, gqlgen scaffolding, the principal/`globalUri` shape on the wire, sqlc + goose machinery.
- **Phase 1 (Task Lifecycle & Chain Skeleton)** — the chain workflow that produces `AgentAssignment` rows, and the four lifecycle mutations the client surfaces (`completeTask`, `cancelTask`, `acceptProposedTask`, `dismissProposedTask`).
- **Real APNs/FCM credentials** — required for full SC-001 verification on physical devices; not required for development against the `LogProvider` stub.
- **Docker / testcontainers-go** — already in place for integration tests; the wake-channel test surface adds no new infra.

## Out of Scope (Deferred)

- **Approval rendering screens** for `Artifact` / `Mandate` — Phase 3 (the gate creates the decisions; the screens render them).
- **Disclosure-gating UI** (`disclosureClass`, `discloseSecret`) — Phase 9.
- **In-app gate-script editor** — Phase 5.
- **Desktop/web background-wake polish** — mobile push is solid first; desktop/web get the subscription unconditionally and push opportunistically (web push via FCM where supported; desktop via OS facilities or a foreground-socket fallback).
- **Realtime fan-out scaling** beyond single-household subscriber counts.
- **Multi-principal / federated identity** — the seam is set (`Principal`, `globalUri`, `Can(...)`), the multiplicity is not exercised.
- **Per-tool autonomy machinery** behind `Tool.rung` and `Tool.permissions` — Phase 4.

## Risks & Open Questions

- **Push reliability is the make-or-break product risk.** APNs/FCM behavior on backgrounded *and force-quit* apps must be tested on real devices early. The simulator masks several real failure modes (token rotation under OS restore, silent-push throttling, killed-app delivery). This risk dominates Phase 2 scheduling.
- **Flutter scope creep.** The temptation to polish inbox UI now is high; resist — Phases 3 and 6 will rebuild around new item shapes. Build only the inbox list + the assignment flow with current contracts.
- **Generated-code drift.** `gqlgen` and `ferry` outputs must be committed and CI must enforce no-drift on every `.graphql` change.
- **Open Q1 — desktop/web background-wake mechanism**: what's the acceptable bound when the tab is closed or the desktop app is fully quit? Phase 2 sets the bound to "best-effort via FCM web push; subscription on next foreground guarantees correctness."
- **Open Q2 — exact push urgency rule**. Phase 2 is permitted a conservative default; the gate (Phase 3) and disclosure (Phase 9) will tighten it.

## Provenance

v2 arch spec: §11 (operator edge in full), §11.5 (two channels / wake), §11.6 (offline, audit, auth), §15 open Q4 (contract versioning), Appendix B (GraphQL SDL). The user-supplied feature description for this command is reproduced normatively in the planning artifacts; in particular the inline GraphQL artifact, the wake-channel diagram, and the offline write policy are load-bearing.
