# Data Model: Calibration & the Earned-Autonomy Ratchet

Migration **`00007_calibration_ratchet.sql`** (goose). Reuses the Phase-0 `tool_outcomes` table and
the per-tool autonomy slot; adds the continuous score, the routine fingerprint, and the one new
per-routine grant table. No change to the `audit_messages.task_id`-NULL CHECK allowlist (all new
audit kinds are task-scoped). No change to the `decision_kind` enum (`promotion_proposal` already
exists). No new dependency.

---

## Migration 00007 — up

### 1. `tools.trust_score` (continuous per-tool autonomy)

```sql
ALTER TABLE tools
  ADD COLUMN trust_score double precision NOT NULL DEFAULT 0.5
    CHECK (trust_score >= 0.0 AND trust_score <= 1.0);
```

- **Baseline `0.5`** = mid `EXECUTE_GATED` band. Existing seeded tools (currently
  `rung='execute_gated'`) migrate to baseline by the default.
- `rung text` is **retained** as a derived cache of the band (kept in sync on score writes by app
  code) for backward compatibility; behavior reads `trust_score`.

**Band derivation** (pure, `calibration/score.go`): `NONE` iff `score == 0.0` (owner-set only);
`EXECUTE_AUTO` iff `score >= 0.8`; else `EXECUTE_GATED`. Constants `baseline=0.5`,
`auto_threshold=0.8` overridable by config.

### 2. `tool_outcomes.routine_fingerprint` (per-routine key)

```sql
ALTER TABLE tool_outcomes
  ADD COLUMN routine_fingerprint text;          -- nullable; populated going forward

CREATE INDEX idx_outcomes_routine
  ON tool_outcomes (tool_id, routine_fingerprint, matured_at);
```

- `matured_at` (already on the table, Phase 0) is now **populated at insert** (`at + window`); the
  Phase-3 insert left it NULL. Pre-existing NULL rows are treated as "never matured" (excluded from
  promotion) — acceptable, they predate calibration.

### 3. `tool_routine_grants` (per-routine auto-approval eligibility)

```sql
CREATE TABLE tool_routine_grants (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id             uuid NOT NULL REFERENCES tools(id) ON DELETE CASCADE,
  routine_fingerprint text NOT NULL,
  evidence            jsonb NOT NULL DEFAULT '{}',   -- frozen track record at grant time
  granted_by          text NOT NULL,                 -- owner principal global_uri (audit trail)
  granted_at          timestamptz NOT NULL DEFAULT now(),
  revoked_at          timestamptz                    -- non-null = revoked by reflexive demotion
);

-- At most one LIVE grant per (tool, routine):
CREATE UNIQUE INDEX uq_grant_live
  ON tool_routine_grants (tool_id, routine_fingerprint)
  WHERE revoked_at IS NULL;
```

- A **live** grant = `revoked_at IS NULL`. Created on `respondToPromotion(accept:true)`; revoked
  (set `revoked_at`) by reflexive demotion of that routine (or all of a tool's grants on a
  task-cancel). Append-only history (revoked rows are retained for audit).
- Sub-resource addressed via parent `tools` (carries `global_uri`) — no own `globalUri` needed
  (Constitution VIII, 1.2.0 amendment).

---

## Migration 00007 — down

```sql
DROP TABLE IF EXISTS tool_routine_grants;
DROP INDEX IF EXISTS idx_outcomes_routine;
ALTER TABLE tool_outcomes DROP COLUMN IF EXISTS routine_fingerprint;
ALTER TABLE tools DROP COLUMN IF EXISTS trust_score;
```

(`matured_at` and `decision_kind` predate this migration; not dropped.)

---

## Entities

### Tool (extended)
| Field | Type | Notes |
|---|---|---|
| `trust_score` | float `0.0–1.0` | **NEW** — the only band-determining stored autonomy; per-tool |
| `rung` | text | retained, derived cache of the band |
| (existing) `permissions`, `overseer_instructions`, `global_uri`, … | | unchanged |

GraphQL `Tool.rung: AutonomyLevel!` is now **derived from `trust_score`** (band math), not read
from the `rung` text column.

### ToolOutcome (extended)
| Field | Type | Notes |
|---|---|---|
| `outcome` | enum `clean`\|`bad`\|`denied_by_script` | default `clean` (inferred-clean, Phase 0) |
| `matured_at` | timestamptz | **now populated at insert** = `at + maturation_window` |
| `routine_fingerprint` | text (nullable) | **NEW** — call-equivalence key (R3) |

**Matured-clean predicate**: `matured_at IS NOT NULL AND matured_at <= now() AND outcome = 'clean'`.

### ToolRoutineGrant (new)
The per-routine auto-approval eligibility (R1/Complexity Tracking). Live iff `revoked_at IS NULL`.
Auto-approval at the gate requires a live grant for the call's fingerprint **and** the tool in the
`EXECUTE_AUTO` band **and** the floor cleared.

### PromotionProposal (now real)
Stored as `pending_decisions(kind='promotion_proposal')` — table unchanged. Fields used:
| Column | Use |
|---|---|
| `tool_id` (nullable, existing) | the tool being promoted |
| `task_id` (NOT NULL, existing) | **representative** task = most-recent matured-clean outcome's task |
| `payload` jsonb | frozen evidence + `from_level`/`to_level`/`routine_fingerprint` |
| `resolved_at`/`resolution` | set on `respondToPromotion` |

### Effective disposition thresholds (derived, not stored)
Computed at dispose time from `connector_configs.disposition_rules` (base) ± a bounded function of
the connector's recent dismissal count (R9). No column.

---

## New audit kinds (all task-scoped — no CHECK-allowlist change)

Added to `internal/lifecycle/audit.go`:

| Kind | Scope | Emitted when |
|---|---|---|
| `outcome_flagged` | task | owner `flagOutcome` records a bad outcome |
| `tool_demoted` | task | reflexive demotion (bad outcome / cancel / flag) — payload: trigger, old/new score, revoked routine |
| `promotion_proposed` | task (representative) | sweep emits a `PromotionProposal` — payload: evidence tally |
| `promotion_responded` | task (representative) | owner accept/decline via `respondToPromotion` |

Each links `in_reply_to` the message it answers (the outcome row's `tool_outcome_recorded`, the
cancel transition, or the `promotion_proposed`) — preserving the DAG (Constitution VI).

*(Intake threshold-tightening and `[DISMISSAL_HISTORY]` are derived reads; they reuse existing
`disposition_applied` / triage audits and add no new kind.)*

---

## sqlc queries (new/edited, `internal/db/queries/`)

| Query | Purpose |
|---|---|
| `InsertToolOutcome` (edit) | accept `matured_at` + `routine_fingerprint` params |
| `MaturedCleanRatioByRoutine` | per `(tool, fingerprint)`: clean/total over last N matured (for the sweep) |
| `LatestMaturedOutcomeForRoutine` | representative `task_id` + latest matured `at` (cooldown check) |
| `GetTrustScore` / `SetTrustScore` | read/CAS the per-tool score (serialized via `GetToolForUpdate`) |
| `InsertRoutineGrant` / `RevokeRoutineGrant` / `RevokeAllGrantsForTool` | grant lifecycle |
| `LiveGrantExists(tool_id, fingerprint)` | the gate's `RoutineGrantLookup` seam backing query |
| `OpenPromotionProposal(tool_id, fingerprint)` | dedupe + invalidate-on-demotion |
| `ToolsActedUnderTask(task_id)` | distinct tools for cancel-demotion |
| `DismissalsByConnector(connector_id, since)` | count + reasons for intake tightening / `[DISMISSAL_HISTORY]` |

**Concurrency**: trust-score and grant mutations take `GetToolForUpdate` (row lock) so concurrent
outcomes near a band boundary serialize (spec edge case) — no lost updates.

---

## State transitions (the ratchet)

```
score ∈ EXECUTE_GATED band, no grant
   │  sweep: matured-clean ratio ≥ threshold (per routine)
   ▼
PromotionProposal open ──owner respondToPromotion(accept:false)──▶ withdrawn; cooldown until a new matured-clean outcome
   │ owner respondToPromotion(accept:true)
   ▼
score := EXECUTE_AUTO band  +  live grant for (tool, routine)
   │  bad outcome / cancelTask / flagOutcome   (reflexive, automatic)
   ▼
score := max(baseline, score − decrement)  +  grant revoked   (open proposal, if any, withdrawn)
   │  (owner action only)
   ▼
score := 0.0  →  NONE (disabled)
```

Floor is evaluated **before** the band on every call — no transition in this diagram can lower it
(Constitution III).
