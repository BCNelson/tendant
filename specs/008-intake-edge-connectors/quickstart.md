# Quickstart: The Intake Edge (Connectors & Dispositions)

This walks the Phase 7 demo, mapped 1:1 to the spec's exit criteria. It uses the two
zero-credential connectors (`webhook-in`, `rss`) for fully-local runs, and `gmail` (with a faked
`messageFetcher` in tests) for the OAuth-exemplar path.

## Prerequisites

```sh
direnv allow
make up                      # migrates (incl. 00006), seeds owner, serves /graphql + /healthz
export TENDANT_CREDENTIALS_KEY=$(head -c32 /dev/urandom | base64)   # AES key for source_credentials
```

The owner principal is seeded at boot (Phase 0). All connector mutations below require the owner
session token (Phase 2 pairing) — they are `auth.RequireOwner`-guarded.

---

## 1. Configure & enable a connector (owner-only) → SC-007

```graphql
# Create/Upsert an integration (owner session required).
mutation {
  setConnectorConfig(connectorId: "<uuid>", config: {
    connector_type: "rss",
    filter: { feed: "https://example.com/releases.xml" },
    schedule: "0 */5 * * * *",                 # cron: every 5 min (per-integration; no default)
    disposition_rules: { confidence_floor: 0.85, stakes_ceiling: 0.30, llm_judge_per_poll: 5 }
  }) { id connectorType enabled config }
}

mutation { enableConnector(connectorId: "<uuid>", enabled: true) { id enabled } }
```

A DBOS schedule `intake:<uuid>` is created (cron from `schedule`). A **non-owner** principal calling
any of `connectors`, `setConnectorConfig`, `enableConnector` is rejected `PERMISSION_DENIED` before
any DB access (SC-007).

---

## 2. `forced_task`: an item becomes a task, no typing → SC-001

A connector flags a matching item `forced_task`. On the next poll tick:
- signal persists to `intake_signals` (`disposition='forced_task'`);
- a `tasks` row is created `state='accepted'` with `provenance` + `intake_signal_id`;
- the **is-task judgment is skipped** (no model call);
- the chain runs; the task appears on the operator edge.

```graphql
query { tasks(state: ACCEPTED) { items { id title provenance currentStage } } }
# provenance => { "raw_ref": "rss:.../releases.xml#<guid>", "reason": "matched filter: ..." }
```

For the **Gmail OAuth path**: complete the one-time consent (`/oauth/callback/gmail` seals tokens into
`source_credentials`); thereafter a flagged email becomes a task with no typing.

---

## 3. `rich_event`: confident + low-stakes auto-accepts, arrives enriched → SC-002

A `rich_event` with `confidence=0.92` (≥ `0.85`) and `stakes_hint=0.10` (≤ `0.30`):
- clears **both** thresholds ⇒ **auto-accepts** (`state='accepted'`, not `PROPOSED`);
- runs creation → triage → **expansion** (arrives already enriched);
- `Task.autonomy` reports **`enrich-only`**; it is **dismissible**.

A `rich_event` clearing only one axis (e.g. `confidence=0.92`, `stakes_hint=0.55`) is held `PROPOSED`.
With no `disposition_rules` tuning, conservative defaults hold ambiguous events `PROPOSED` (SC-008).

```graphql
query { task(id: "<auto-accepted>") { state autonomy currentStage findings } }
# expect: state ACCEPTED, autonomy ENRICH_ONLY, currentStage past EXPANSION, findings populated
mutation { dismissProposedTask(taskId: "<auto-accepted>", reason: "not relevant") { id state } }
# allowed for intake-origin tasks; records the reason (Phase 8 calibration input)
```

---

## 4. `llm_judge`: ambiguous item judged by the model, lands PROPOSED → SC-003 / SC-009

A connector emits `llm_judge`. Within the per-poll cap:
- a `PROPOSED` task is created; triage's LLM runs is-task/shape/stakes over the **normalized payload only**;
- it stays `PROPOSED` for sign-off.

In a **mixed batch**, only the `llm_judge` items invoke the model — `forced_task`/`rich_event` do not
(SC-003). If a single poll emits more `llm_judge` items than `llm_judge_per_poll`, the overflow is held
`PROPOSED` with **no model call** (`llm_judge_capped` audit; SC-009).

---

## 5. Same item twice → one task → SC-004

Re-emit the same `(connector_id, idempotency_key)` on a later poll:
- the `intake_signals` insert hits `ON CONFLICT DO NOTHING` ⇒ no new signal, no new task;
- a `signal_deduped` audit is written.

```sql
SELECT count(*) FROM intake_signals WHERE connector_id='<uuid>' AND idempotency_key='<k>'; -- 1
SELECT count(*) FROM tasks WHERE intake_signal_id IN
  (SELECT id FROM intake_signals WHERE idempotency_key='<k>');                              -- 1
```

---

## 6. Kill mid-poll, resume cleanly → SC-005

```sh
just dbos-demo   # or: start a multi-item poll, kill -9 the process mid-emit, restart
```

On restart, `dbos.Launch` recovers the `intake:<uuid>` schedule and any in-flight poll workflow;
DBOS-memoized emit steps + the unique index mean each source item produces exactly **one** task — same
set as an uninterrupted run, zero duplicates, zero drops.

---

## 7. Provenance on the operator edge → SC-006

A `PROPOSED` intake task shows its provenance (raw ref + flag reason) via `Task.provenance` (rendered by
the Flutter `ProvenanceCard`). `acceptProposedTask` runs the chain; `dismissProposedTask` records the
reason.

---

## Test surface (CI, no external services)

- `internal/intake` — disposition dial (both-axes truth table, fail-closed cases), idempotent ingest
  (`ON CONFLICT`), per-poll cap, enrich-only lifecycle + dismiss.
- `internal/connector` — `webhook-in` + `rss` end-to-end (fixture → signal → task); `gmail` with a faked
  `messageFetcher`; `calendar`/`imap` stub-emits-nothing.
- GraphQL e2e — owner-guard on all three operations (non-owner ⇒ `PERMISSION_DENIED`); a `forced_task`
  fixture flowing to an inbox task with provenance.
- DBOS — schedule create/delete on enable/disable; crash-recovery resume (SC-005).
