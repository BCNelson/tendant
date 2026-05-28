# Quickstart — Phase 2 Operator Edge & the Wake Channel

End-to-end walkthrough exercising all four exit criteria from `spec.md`:

1. Backgrounded-phone push wakes the human.
2. Foregrounded subscription delivers without polling.
3. Mid-session session revocation suppresses subsequent events on the open subscription.
4. Offline dismiss flushes on reconnect; stubbed floor-relevant write is refused offline.

The walkthrough uses the `LogProvider` push stub (no real APNs/FCM credentials needed) for steps 1–3. A separate "real-device" addendum at the bottom describes the physical-phone verification that closes SC-001.

---

## Prereqs

```sh
direnv allow                                  # devenv shell: Go 1.25, Postgres 16, sqlc, goose, just, Flutter
make up                                       # brings up Postgres + the server on :8080
curl -fsS localhost:8080/healthz              # → "ok"
```

The server boot logs include:

```
{"level":"info","msg":"sessions setup_secret armed","secret_source":"env(TENDANT_SETUP_SECRET)"}
{"level":"info","msg":"realtime dispatcher LISTENing","channel":"tendant_events"}
{"level":"info","msg":"push provider","provider":"LogProvider"}
```

Copy the value of `$TENDANT_SETUP_SECRET` from the running container for the pairing step:

```sh
SETUP=$(docker compose exec api printenv TENDANT_SETUP_SECRET)
```

(The dev `compose.yaml` arms a fixed secret for predictability; production uses a random one.)

---

## Step 0 — Pair the Flutter client

In one terminal, run the Flutter app for the desktop or web target (whichever is convenient — both run the same code):

```sh
cd apps/mobile
flutter run -d chrome                          # or -d macos / -d linux / -d windows
```

The app boots into the **Pairing** screen. Paste `$SETUP` into the field, give the device a name (e.g., "Dev laptop"), and tap **Pair**.

The Flutter app calls:

```graphql
mutation { pairDevice(setupSecret: "...", displayName: "Dev laptop") {
  session { id displayName }
  token
}}
```

The token is written to `flutter_secure_storage` and used as the bearer for all subsequent calls. The app navigates to **Inbox**.

In another terminal, confirm a session row landed:

```sh
psql $DATABASE_URL -c "SELECT id, display_name, revoked_at FROM sessions ORDER BY created_at DESC LIMIT 1"
```

---

## Step 1 — Backgrounded-phone push (LogProvider stub)

The Flutter client doesn't have a real device token in this mode — `firebase_messaging` returns a token on web only when configured against a Firebase project. For the LogProvider walkthrough, **manually insert** a test device token so the push fan-out has something to target:

```sh
PRINCIPAL=$(psql $DATABASE_URL -tAc "SELECT global_uri FROM principals WHERE kind='user' LIMIT 1")
psql $DATABASE_URL -c "INSERT INTO device_tokens (token, owner_id, platform) VALUES (
  'stub-token-quickstart',
  (SELECT id FROM principals WHERE global_uri = '$PRINCIPAL'),
  'ios'
)"
```

(In the **real-device addendum** at the bottom, `firebase_messaging.getToken()` produces a real APNs/FCM token and `registerDeviceToken` lands it via the proper code path. The stub-insert above only exists to exercise the fan-out worker against `LogProvider`.)

Now create a task and walk the Phase 1 chain to an assignment:

```sh
just seed-task TITLE="quickstart phase 2"     # core.CreateTask via dev helper
```

In the server logs, you should see (within a second or two of `seed-task` returning):

```
{"level":"info","msg":"chain.OpenAssignment","task_id":"...","stage":"triage"}
{"level":"info","msg":"push.Enqueue","task_id":"...","recipient":"<owner-globalUri>","step_id":"...","queue":"push"}
{"level":"info","msg":"push.LogProvider.Send","token":"stub-token-quickstart","platform":"ios","title":"tendant","deep_link_id":"<assignment-id>"}
```

The LogProvider's emitted line is what would have been an APNs payload. Notably absent from it: the task title, the description, any task content — only `title` (the generic title) and `deep_link_id`.

**SC-003 check**:

```sh
docker compose logs api 2>&1 | grep push.LogProvider.Send | head -1 | jq '.'
# Confirm: only deep_link_id and title are present in the payload fields.
```

---

## Step 2 — Foregrounded subscription delivers without polling

Keep the Flutter client running on the **Inbox** screen. The inbox already lists the assignment from Step 1 (it was there before you looked — the initial query fetched it).

In another terminal, create a *second* task:

```sh
just seed-task TITLE="quickstart phase 2 - second"
```

Watch the Flutter app: a new tile appears in the inbox within ~1 second, without any user action. The browser DevTools (or `flutter run` console) shows:

```
[ferry] subscription event: InboxItemArrived { __typename: "AgentAssignment", id: "..." }
[ferry] refetch: agentAssignment(id: "...")
```

i.e., the subscription delivered an id-only event; the client refetched the full entity through the normal authenticated path. (SC-002.)

Tap the new tile. The **AgentAssignment** detail view opens. Tap **Complete**. The mutation:

```graphql
mutation { completeTask(taskId: "...") { id state currentStage } }
```

returns `state: EXECUTING`, then the chain advances to `EXECUTION`, then `DONE`. Each transition fires a `taskChanged` subscription event that the open detail view consumes; the screen auto-navigates to the inbox when the task reaches `DONE`.

---

## Step 3 — Mid-session revocation stops subscription events

Open a second Flutter window (`flutter run -d chrome` in another terminal, on a different port). Pair it as a second session (re-arm the setup secret if needed by restarting the dev server briefly, or use the dev-only `re-arm setup secret` helper at `localhost:8080/debug/arm-setup` if compiled in).

The second window opens its own subscription. Confirm both windows receive events for a new task seeded via `just seed-task`.

Now revoke the second window's session:

```sh
psql $DATABASE_URL -c "SELECT id FROM sessions ORDER BY created_at DESC LIMIT 1"  # the second session
psql $DATABASE_URL -c "UPDATE sessions SET revoked_at = now() WHERE id = '<that-id>'"
```

(In a real flow, the `revokeSession(sessionId)` mutation from the *first* window would do this; the SQL nudge is purely to keep the quickstart self-contained.)

Seed another task. The **first** window receives the inbox event. The **second** window does **not** — without reconnecting. The dispatcher's per-event `Can(...)` re-check (R7) finds the second session's principal is no longer authorized (the principal resolves but the session is revoked, so the connection's auth context is invalidated on its next event) and silently drops the emit.

If you then issue any HTTP query from the second window (e.g., a manual refetch), it fails closed with `UNAUTHORIZED` — confirming the bearer is now dead.

---

## Step 4 — Offline dismiss + floor-relevant rail

In the Flutter window, open Chrome DevTools, switch the Network tab to **Offline**.

In the app, navigate to **Inbox**. The list still renders — from the `ferry` normalized cache (FR-025). Find a `ProposedTask` tile (if there are none, use the dev helper `just seed-proposed-task TITLE="dismiss-me"` to insert one). Tap **Dismiss**.

The UI updates optimistically. The `drift` outbox table grows by one row:

```sh
# In the running app's app-data directory, drift's SQLite file:
sqlite3 ~/.local/share/tendant/outbox.db "SELECT id, op, target_id, created_at FROM outbox"
# 1|dismissProposedTask|<task-id>|2026-05-28T...
```

Now attempt a *stubbed floor-relevant* action — the dev build includes a debug menu **Debug → Compose Floor-Relevant Action** that constructs a fake `approveArtifact` call. Tap **Submit**. The UI immediately shows:

> Floor-relevant actions require a network connection. The action has been saved as a draft but cannot be committed offline.

The outbox does **not** grow (the floor rail refuses to enqueue). (SC-008.)

Re-enable the network in DevTools. Within a few seconds the outbox flush runs:

```
[outbox] flush start: 1 entries
[outbox] flush success: dismissProposedTask(<task-id>) → DISMISSED
[outbox] flush done: 0 entries remaining
```

The server side reflects `DISMISSED`; the inbox refreshes through the subscription channel and the tile disappears. (SC-007.)

---

## Demo run — all four together (SC-011)

The CI / quickstart-runnable script `scripts/phase2-demo.sh` executes Steps 0–4 in sequence using `httpie` / `psql` and assertions:

```sh
just phase2-demo
# 1/4 pair device ........................... OK (session: <id>, token: ****...)
# 2/4 push (LogProvider) channel ............. OK (push_attempted row found, no task content)
# 3/4 subscription channel ................... OK (event id: <assignment-id>)
# 4/4 revocation suppresses subscription ..... OK (second session got 0 events post-revoke)
# 5/5 offline outbox flushes; floor rail refuses ... OK
```

(`just phase2-demo` is the SC-011 verification target.)

---

## Real-device addendum (closes SC-001 — must be done on physical hardware)

The LogProvider walkthrough above exercises every code path *except* a real APNs/FCM provider talking to a real OS. Per the spec's "make-or-break risk" callout, SC-001 requires testing on physical devices.

**Prereqs**:
- An Apple Developer account; generate an APNs auth key (`.p8`); set `TENDANT_APNS_KEY_ID`, `TENDANT_APNS_TEAM_ID`, `TENDANT_APNS_BUNDLE_ID`, `TENDANT_APNS_KEY_PATH`, `TENDANT_APNS_PRODUCTION=true|false`.
- A Firebase project; generate a service-account JSON; set `GOOGLE_APPLICATION_CREDENTIALS` to its path and `TENDANT_FCM_PROJECT_ID`.

With both env groups set, the server boot log will say `"provider":"APNs+FCM"` instead of `"provider":"LogProvider"`.

**Run**:
1. Build the Flutter app for iOS (`flutter build ios`) and Android (`flutter build apk`); install on a real iPhone and a real Android phone.
2. Pair each device (Step 0 above).
3. The Flutter `firebase_messaging.onTokenRefresh` handler calls `registerDeviceToken`; confirm the row landed in `device_tokens`.
4. Background the iPhone (lock the screen). Run `just seed-task TITLE="real device wake"`.
5. **Expected**: within ~3–5 seconds, the iPhone shows a banner reading "tendant" (the generic title); no task content; tapping it opens the app on the `AgentAssignment` for the new task.
6. Repeat for the Android device.
7. Force-quit the Flutter app on iOS (swipe up from the app switcher). Run `just seed-task` again. **Expected**: the banner still arrives — this is the hybrid alert+content-available path's reason for being (the force-quit case silent push cannot serve).

Document the timing measurements (commit-to-banner latency, 20 trials per platform) as evidence for SC-001.

---

## What gets verified at each step

| Step | Spec criterion verified |
|------|------|
| 0 — Pair | FR-028 (session-token pairing); FR-023 (token registration follows pairing) |
| 1 — LogProvider push | FR-014, FR-014a (DBOS-step push); FR-015, FR-015a (hybrid alert+data); FR-018 (LogProvider stub); SC-003 (zero task content) |
| 2 — Subscription | FR-011 (dispatcher fanout); FR-012 (id-only events + authed refetch); FR-013 (auth re-check); SC-002 (< 2 s perceived latency) |
| 3 — Revocation | FR-032 (subscription auth per-event); SC-004 (revocation effective within one event) |
| 4 — Offline | FR-025, FR-026 (offline cache + outbox); FR-027 (floor-rail refusal); SC-007, SC-008 |
| Demo run (SC-011) | All of the above in sequence |
| Real-device addendum | SC-001 (force-quit-survivable wake on physical hardware) |
