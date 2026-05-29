# Data Model: Phase 4 — The Overseer

Phase 4 is **schema-flat on Phase 3**. No new tables, no new columns, no migration. All new state lives in:
- `audit_messages.payload jsonb` — under three new `kind` values.
- `tools.permissions jsonb` — already in Phase 0; now mutable via `setToolPermissions`.
- `tools.overseer_instructions text` — already in Phase 0; now mutable via `setToolOverseerInstructions`.

## No migration in Phase 4

The Phase 0 schema (`db/migrations/00001_v2_ddl_spine.sql`) reserved both target columns:

```sql
-- excerpt, db/migrations/00001_v2_ddl_spine.sql:95-102
CREATE TABLE tools (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  global_uri            text NOT NULL UNIQUE,
  name                  text NOT NULL,
  rung                  text NOT NULL DEFAULT 'execute_gated',
  permissions           jsonb NOT NULL DEFAULT '{}',
  overseer_instructions text                                    -- owner-authored ONLY
);
```

Phase 4 starts writing them.

## Audit-message payload shapes

### `kind = "overseer_evaluated"`

Written exactly once per overseer evaluation. Chains via `in_reply_to` to the predecessor `gate_verdict` audit row (Phase 3).

```json
{
  "verdict": "approve" | "request_decision" | "fail_closed_request_decision" | "fail_closed_per_task_cap",
  "model_id": "string",                       // e.g. "claude-sonnet-4-6"; "log" for LogProvider
  "provider": "log" | "anthropic" | "openai",
  "owner_instructions_hash": "sha256-hex",    // hash of tools.overseer_instructions at gate-entry time
  "evidence": {
    "summary": "string",                      // 1-2 sentence reasoning
    "considered_fields": ["payload.body", "payload.to", ...],
    "reason": "per_task_eval_cap_exceeded",   // OPTIONAL — present only on fail-closed paths
    "current_count": 50,                      // OPTIONAL — fail_closed_per_task_cap path only
    "cap": 50                                 // OPTIONAL — fail_closed_per_task_cap path only
  },
  "tokens_in": 12345,                         // 0 on LogProvider synth or fail-closed paths
  "tokens_out": 234,
  "estimated_cost_usd": 0.0123                // 0 on LogProvider; computed from a small in-package pricing table for real providers
}
```

Note: `evidence.reason` is the canonical place for fail-closed reason codes — matches spec.md FR-011 and Story 4 acceptance (`evidence.reason = "per_task_eval_cap_exceeded"`). Normal Approve / RequestDecision verdicts omit `reason`, `current_count`, and `cap`.

`from_principal = "local://principal/system"` (the gateway runs as `system`). `to_principal = null`.

### `kind = "overseer_instructions_changed"`

Written by `setToolOverseerInstructions` after the row update. Chains in_reply_to the prior `overseer_instructions_changed` row for the same tool (or null on the first write).

```json
{
  "tool_id": "uuid",
  "tool_global_uri": "tendant://tools/send-email",
  "previous_hash": "sha256-hex" | null,
  "new_hash": "sha256-hex",
  "length_chars": 137
}
```

`from_principal = viewer.global_uri` (the seeded owner). `to_principal = null`. **The instruction text itself is not duplicated into audit** — the canonical place is the `tools` row; audit captures only the hash + length so a future audit-replay can detect change without exposing the text in two stores.

### `kind = "tool_permissions_changed"`

Same shape as `overseer_instructions_changed`, but with `previous_permissions` and `new_permissions` (the full JSON, since they are small structural objects that future calibration may want to introspect):

```json
{
  "tool_id": "uuid",
  "tool_global_uri": "tendant://tools/send-email",
  "previous_permissions": { "read_only": false, "spend": false, ... } | null,
  "new_permissions":      { "read_only": false, "spend": false, ... }
}
```

`from_principal = viewer.global_uri`.

## Entity refresh

### `tools` (Phase 0 schema; Phase 4 first mutator of `permissions` / `overseer_instructions`)

| column | type | Phase 4 use |
|---|---|---|
| `id` | uuid PK | tool registry key (unchanged) |
| `global_uri` | text unique | unchanged |
| `name` | text | unchanged |
| `rung` | text default `'execute_gated'` | unchanged (Phase 8 will move it) |
| `permissions` | jsonb | **now mutable via `setToolPermissions`**; floor still reads it on every call |
| `overseer_instructions` | text nullable | **now populated + mutable**; overseer reads it on every call |

**Phase 4 update to the `send-email` seed** (idempotent; runs after Phase 3's seeder):

```sql
-- pseudo-code; actually implemented in services/api/internal/tools/seed.go
UPDATE tools
SET overseer_instructions = $1
WHERE global_uri = 'tendant://tools/send-email'
  AND overseer_instructions IS NULL;
```

Default instruction text (FR-013):
> "Approve sends to known principals whose body does not mention money. Flag anything else for owner review."

### `audit_messages` (Phase 0; first writer of three new kinds)

No schema change. The `payload jsonb` carries all new fields. The existing `idx_audit_task (task_id, at)` index covers the per-task cap count query (`SELECT count(*) WHERE kind = 'overseer_evaluated' AND task_id = $1`).

## In-memory types

```go
// internal/overseer
type Decision int
const (
    DecisionApprove Decision = iota
    DecisionRequestDecision   // only two legal verdicts in Phase 4 (FR-003)
)

// OverseerInput is the struct boundary that prevents payload fields from
// posing as owner instructions. NEVER replaced with a single string.
type OverseerInput struct {
    OwnerInstructions string
    ToolName          string
    ToolGlobalURI     string
    ConcreteCall      json.RawMessage  // the frozen ToolCall.Payload
    Permissions       json.RawMessage  // tools.permissions, for the prompt's [TOOL_METADATA]
    TaskID            uuid.UUID        // for the per-task cap query
}

type Evidence struct {
    Summary          string   `json:"summary"`
    ConsideredFields []string `json:"considered_fields"`
}

type OverseerVerdict struct {
    Decision         Decision
    Evidence         Evidence
    ModelID          string
    Provider         string  // "log" | "anthropic" | "openai"
    TokensIn         int
    TokensOut        int
    EstimatedCostUSD float64
    // Reason is populated only on fail-closed paths
    // ("per_task_eval_cap_exceeded", "malformed_model_response", "gateway_error").
    Reason           string
}

type Grader interface {
    Grade(ctx context.Context, in OverseerInput) (OverseerVerdict, error)
}

// Provider is the model-call seam, mirroring internal/push.Provider.
type Provider interface {
    Name() string  // "log" | "anthropic" | "openai"
    Call(ctx context.Context, prompt PromptPayload) (RawResponse, error)
}

// PromptPayload is the labeled-slot output of prompt.Serialize.
type PromptPayload struct {
    SystemPreamble    string  // fixed text shipped with the package
    OwnerInstructions string  // [OWNER_INSTRUCTIONS] slot
    ToolMetadata      string  // [TOOL_METADATA] slot (name + global_uri + permissions)
    ConcreteCall      string  // [CONCRETE_CALL] slot — JSON-stringified payload
}

// RawResponse is what a Provider hands back; the gateway parses it into Verdict.
type RawResponse struct {
    Verdict          string
    Evidence         Evidence
    ModelID          string
    TokensIn         int
    TokensOut        int
    EstimatedCostUSD float64
}
```

## Audit DAG chaining for Phase 4

A graded call now produces this chain for each evaluation (extending Phase 3's chain):

```
state_transition (Phase 1)
   └── tool_call_composed (Phase 3)
         └── gate_verdict (Phase 3)
               └── overseer_evaluated (NEW Phase 4)  ← when verdict != fail-closed-cap
                     └── decision_resolved (Phase 3) ← when verdict = request_decision
                           └── tool_dispatched (Phase 3)
                                 └── tool_outcome_recorded (Phase 3)
```

On an overseer-Approve verdict, the chain skips `decision_resolved` (no human in the loop) and proceeds directly from `overseer_evaluated → tool_dispatched`. This makes the auto-approve path trivially distinguishable in the audit DAG from the human-approve path.

## Indices

No new indices in Phase 4. The Phase-0 `idx_audit_task` covers the cap count query; no other new query patterns are introduced.

## Out-of-band: gateway in-memory state

| Name | Lifetime | Storage |
|---|---|---|
| Rolling 60-second eval window | Process lifetime; restart-resets | `Gateway` struct, `sync.Mutex`-protected `[]time.Time` |
| Active `Provider` | Process lifetime | `Gateway` struct, set at boot from `TENDANT_OVERSEER_PROVIDER` |
| Pricing table (cents/Mtok per provider/model) | Process lifetime; constant | `internal/overseer/pricing.go` (package-level `var pricing = map[string]...`) |

**Per principle V (no rollback)**: the rate window is observability, not state. A restart that zeros it is intended behaviour, not a bug.
