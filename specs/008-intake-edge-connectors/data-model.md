# Phase 1 Data Model: The Intake Edge

Scope: the entities the intake edge reads and writes. **Almost everything is Phase-0 reserved** —
this phase fills `connector_configs`, `source_credentials`, `intake_signals`, and the intake fields
on `tasks`. The only DDL is migration `00006` (extend an audit CHECK allowlist + optional poller index).

Legend: 🟢 existing (Phase 0/1–5), ✏️ edited this phase, 🆕 new this phase.

---

## 1. `connector_configs` 🟢 (Phase 0 — `00001`)

An **integration**: one connector type bound to a filter, schedule, and disposition rules.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `connector_type` | text | registry key: `gmail` \| `calendar` \| `imap` \| `webhook-in` \| `rss` |
| `filter` | jsonb | coarse connector-side pre-filter (bounds what is read/emitted; **not** a privacy guarantee) |
| `schedule` | text | **cron string** (per-integration cadence; required to enable — no framework default) |
| `disposition_rules` | jsonb | `{confidence_floor, stakes_ceiling, llm_judge_per_poll, ...}` — see §6 |
| `enabled` | boolean | gates whether a DBOS schedule exists for this connector |
| `created_at` | timestamptz | |

**Validation**:
- `connector_type` MUST be a registered type (registry lookup) — else `setConnectorConfig` rejects.
- `enableConnector(true)` requires a non-blank, valid cron `schedule`; else reject (no default cadence).
- `disposition_rules.confidence_floor` / `stakes_ceiling` ∈ `[0.0, 1.0]`; conservative defaults applied
  when absent (high floor, low ceiling ⇒ "hold for sign-off" by default — NFR-003).
- Owner-only writes (`auth.RequireOwner`).

---

## 2. `source_credentials` 🟢 (Phase 0 — `00001`)

Encrypted OAuth/equivalent tokens, one row per connector.

| Column | Type | Notes |
|---|---|---|
| `connector_id` | uuid PK → `connector_configs(id)` | one credential bundle per integration |
| `encrypted` | bytea | `crypto.Seal(json{access, refresh, scopes, ...})` — AES-256-GCM, `TENDANT_CREDENTIALS_KEY` |
| `expires_at` | timestamptz | drives connector-managed refresh (refresh when near expiry) |

**Validation**: never serialized over GraphQL; refresh re-seals in place; absence ⇒ connector cannot poll
(credentialed types fail their poll gracefully and surface the gap to the owner — see Edge Cases).

---

## 3. `intake_signals` 🟢 (Phase 0 — `00001`) — the persisted emission

| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `signal_version` | text | `"intake.v1"` (the versioned in-edge contract) |
| `connector_id` | uuid → `connector_configs(id)` | emitting integration |
| `idempotency_key` | text | stable per source item |
| `provenance` | jsonb | `{raw_ref, reason}` — **reference, not content copy** (see §7) |
| `payload` | jsonb | connector-normalized; the **only** thing `llm_judge` ships to a model |
| `disposition` | `signal_disposition` enum | `forced_task` \| `rich_event` \| `llm_judge` |
| `confidence` | double precision | set for `rich_event`; ∈ `[0.0, 1.0]` |
| `stakes_hint` | double precision | set for `rich_event`; ∈ `[0.0, 1.0]` |
| `created_at` | timestamptz | |
| `processed_at` | timestamptz NULL | set once the disposition router has handled it |
| **UNIQUE** | `(connector_id, idempotency_key)` | **the dedupe point** (SC-004) |

**Validation** (disposition router, fail-closed):
- `rich_event` MUST carry `confidence` AND `stakes_hint`, both in `[0.0, 1.0]`; missing/out-of-range ⇒
  treat as hold-for-sign-off (`PROPOSED`), never auto-accept (FR-015).
- `forced_task` / `llm_judge` ignore `confidence`/`stakes_hint`.
- Unknown `disposition` string ⇒ enum rejects at insert; router treats as fail-closed.
- Insert is `ON CONFLICT (connector_id, idempotency_key) DO NOTHING` — idempotent by construction.

---

## 4. `tasks` 🟢/✏️ (Phase 0 fields; behavior added this phase)

Reused as-is — **no schema change**. Intake sets two reserved fields:

| Column | Type | Intake use |
|---|---|---|
| `provenance` | jsonb | copied from the signal's provenance (`{raw_ref, reason}`) — rendered on operator edge |
| `intake_signal_id` | uuid → `intake_signals(id)` | back-link; also the **marker** that a task is intake-origin |
| `state` | `task_state` enum | `accepted` (forced / auto-accepted) or `proposed` (rich-hold / llm_judge) |
| `current_stage` | `chain_stage` | starts `creation`; chain drives forward as today |

**Derived (no column)**:
- `Task.autonomy = enrich-only` ⇔ `intake_signal_id IS NOT NULL` AND auto-accepted `rich_event` AND not yet
  owner-authorized for execution (resolver-computed; Phase-6 derivation extended).

---

## 5. `audit_messages` 🟢/✏️ (CHECK extended in `00006`)

Intake writes six kinds (constitution VI). `payload jsonb` carries the per-event detail; no new columns.

| Kind | `task_id` | Emitted when | Payload highlights |
|---|---|---|---|
| `signal_emitted` | **NULL** | a connector emits a signal (persisted) | connector_id, idempotency_key, disposition |
| `signal_deduped` | **NULL** | emission collided with an existing key | connector_id, idempotency_key |
| `llm_judge_capped` | **NULL** | a `llm_judge` item exceeded the per-poll cap | connector_id, cap, count |
| `disposition_applied` | task | router created/held a task | disposition, outcome (`forced`/`auto_accept`/`proposed`) |
| `intake_auto_accepted` | task | a `rich_event` cleared both thresholds | confidence, stakes_hint, floors |
| `llm_judge_invoked` | task | triage model invoked for an `llm_judge` item | tokens (reuses overseer cost fields if shared) |

**Migration `00006`** extends the Phase-5 `task_id`-NULL CHECK allowlist with the three NULL-task kinds
above. `from_principal` = the connector's principal id (e.g. `connector:<type>:<id>`); `to_principal` set
where a recipient exists (e.g. the owner for `PROPOSED` surfacing).

---

## 6. `disposition_rules` shape (jsonb in `connector_configs`) 🆕

```jsonc
{
  "confidence_floor": 0.85,        // rich_event auto-accept requires confidence >= this  (default high)
  "stakes_ceiling":  0.30,         // rich_event auto-accept requires stakes_hint <= this (default low)
  "llm_judge_per_poll": 5,         // FR-014a cap; overflow -> PROPOSED, no model
  "force_rules":  { /* connector-specific predicates that select forced_task */ },
  "judge_rules":  { /* connector-specific predicates that select llm_judge */ }
}
```

Defaults are conservative so an untuned connector holds ambiguous `rich_event`s for sign-off (NFR-003).
`force_rules`/`judge_rules` are connector-interpreted; the **dial** (`confidence_floor`/`stakes_ceiling`/
`llm_judge_per_poll`) is core-interpreted in `intake/disposition.go`.

---

## 7. `provenance` shape (jsonb on signal and task) 🆕

```jsonc
{
  "raw_ref": "gmail:message/<id>",   // source-stable identifier — NOT a content copy
  "reason":  "matched filter: from:billing@acme.com subject:invoice"
}
```

Reference-only by clarification: re-fetched on demand by the connector for detail view; no inbox content
lives at rest beyond what the connector normalized into `payload`.

---

## 8. Disposition → state transition map

```
forced_task   → persist signal → CreateTaskFromSignal(state=accepted) → attach chain → [skip is-task]
                                                                         creation→triage→…→completion

rich_event    → persist signal → dial(confidence,stakes,rules):
                  ├ clears BOTH → state=accepted (enrich-only)  → creation→triage→expansion → EXECUTION:human(owner)
                  └ fails EITHER → state=proposed               → awaits owner sign-off
                  └ missing/out-of-range axis → state=proposed  (fail-closed)

llm_judge     → persist signal → per-poll cap?
                  ├ within cap → state=proposed → triage LLM is-task/shape/stakes (payload as [INTAKE_SIGNAL]) → stays proposed
                  │                                └ is-task=false → mark processed, no surfaced task (audited)
                  └ over cap   → state=proposed, NO model call (llm_judge_capped)
```

**Lifecycle edge added** (`lifecycle/edges.go`, Go-level, no DDL): `accepted → dismissed` permitted **iff**
`intake_signal_id IS NOT NULL` (enrich-only tasks are dismissible; reuses `dismissProposedTask` reason
capture). Existing edges unchanged for owner-authored tasks.

---

## 9. Entity relationships

```
connector_configs 1───1 source_credentials        (credentialed connectors)
connector_configs 1───* intake_signals            (UNIQUE(connector_id, idempotency_key))
intake_signals    1───0..1 tasks                   (tasks.intake_signal_id; one signal ⇒ ≤1 task)
tasks             1───* audit_messages             (task-scoped intake kinds)
connector_configs ·······> audit_messages          (pre-task kinds, NULL task_id, from connector principal)
connector_configs 1───1 DBOS schedule "intake:<id>" (exists iff enabled; not a table — DBOS system state)
```
