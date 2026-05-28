# Data Model: Phase 3

Phase 3 is **schema-additive** on Phase 0/2. Migration `00004` adds three nullable columns to `pending_decisions`; no existing column is renamed, removed, or retyped.

## Migration 00004 — additive columns

```sql
-- +goose Up
ALTER TABLE pending_decisions
  ADD COLUMN frozen_payload jsonb,            -- the exact composed ToolCall payload
  ADD COLUMN workflow_id    text,             -- DBOS workflow id of the ToolCallWorkflow awaiting resolution
  ADD COLUMN decision_topic text;             -- dbos.Send topic the resolver writes to

-- Phase 3 only fills these for kind='approval_request'. agent_question /
-- promotion_proposal rows keep them NULL.

-- +goose Down
ALTER TABLE pending_decisions
  DROP COLUMN frozen_payload,
  DROP COLUMN workflow_id,
  DROP COLUMN decision_topic;
```

## Entity refresh

### `tools` (Phase 0, unchanged)

| column | type | Phase 3 use |
|---|---|---|
| `id` | uuid PK | tool registry key |
| `global_uri` | text unique | lookup from `proposeToolCall(toolGlobalUri:)` |
| `name` | text | display |
| `rung` | text default `'execute_gated'` | calibration (Phase 8) |
| `permissions` | jsonb | **feeds the floor** (Phase 3 first reader) |
| `overseer_instructions` | text | Phase 4 |

**Phase 3 seed row** (idempotent on boot):
```json
{
  "global_uri": "tendant://tools/send-email",
  "name": "send-email",
  "rung": "execute_gated",
  "permissions": {
    "read_only": false,
    "spend": false,
    "irreversible_third_party": "stranger_recipient",
    "secret_classes": []
  }
}
```

### `pending_decisions` (Phase 0, extended)

| column | type | Phase 3 use |
|---|---|---|
| `id` | uuid PK | decision id, surfaces in inbox |
| `task_id` | uuid FK | task |
| `tool_id` | uuid FK nullable | populated for `approval_request` |
| `kind` | enum | Phase 3 writes `approval_request` |
| `payload` | jsonb | discriminated `ApprovalPayload` envelope: `{"type":"artifact","artifact":{...}}` |
| `disclosure_class` | text nullable | populated when secrets clause is in play |
| `created_at` | timestamptz | |
| `resolved_at` | timestamptz nullable | set by `approveArtifact` / `rejectApproval` |
| `resolution` | jsonb nullable | `{"approved": true}` or `{"approved": false, "reason": ...}` |
| **`frozen_payload`** | **jsonb nullable (new)** | the tool-call payload byte-for-byte |
| **`workflow_id`** | **text nullable (new)** | DBOS workflow id of the awaiting `ToolCallWorkflow` |
| **`decision_topic`** | **text nullable (new)** | `"approval:" + id` — what the resolver Sends to |

### `tool_outcomes` (Phase 0, first writer in Phase 3)

| column | type | Phase 3 use |
|---|---|---|
| `id` | uuid PK | |
| `tool_id` | uuid FK | |
| `task_id` | uuid FK | |
| `outcome` | enum `clean`/`bad` | Phase 3 writes both; default `clean` |
| `at` | timestamptz | |
| `matured_at` | timestamptz nullable | Phase 8 sets this |

## In-memory types

```go
// internal/gate
type Decision int
const (
    DecisionApprove Decision = iota
    DecisionDeny
    DecisionRequestDecision
    DecisionAgentHandoff
)

type Verdict struct {
    Decision Decision
    Context  json.RawMessage
}

type ToolCall struct {
    TaskID  uuid.UUID
    ToolID  uuid.UUID
    Payload json.RawMessage  // tool-specific shape; opaque to gate except for floor predicates
}

type Gate interface {
    Evaluate(ctx context.Context, call *ToolCall, tool *Tool) (Verdict, error)
}
```

```go
// internal/tools
type Result struct {
    Provider string          // e.g. "log", "smtp"
    Detail   json.RawMessage // provider-specific result envelope
}

type Tool interface {
    GlobalURI() string
    Execute(ctx context.Context, payload json.RawMessage) (Result, error)
}

type Registry interface {
    ByGlobalURI(uri string) (Tool, bool)
}
```

## Audit kinds (added in Phase 3)

`lifecycle.KindToolCallComposed`, `lifecycle.KindGateVerdict`, `lifecycle.KindToolDispatched`, `lifecycle.KindToolOutcomeRecorded`.

Each chains via `in_reply_to` to its predecessor:
- `tool_call_composed` → root for the call (in_reply_to = latest task transition)
- `gate_verdict` → in_reply_to = `tool_call_composed`
- `tool_dispatched` → in_reply_to = `gate_verdict`
- `tool_outcome_recorded` → in_reply_to = `tool_dispatched`
