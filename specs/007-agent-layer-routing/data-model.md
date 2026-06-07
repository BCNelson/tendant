# Data Model: The Agent Layer (Specialists as Config) & Routing

**Date**: 2026-06-07 | **Branch**: `007-agent-layer-routing`

## Existing Tables (Phase 0, no migration needed)

### `agent_configs`

Already declared in migration 00001. Phase 6 populates and queries it.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| id | uuid PK | gen_random_uuid() | |
| name | text NOT NULL | | Human-readable specialist name |
| stage | agent_stage (enum) | | `triage` \| `expansion` \| `execution` |
| is_human | boolean NOT NULL | false | Unused in v1 (human is synthesized) |
| system_prompt | text | | The specialist's LLM system prompt |
| model | text | | Model ID resolved via platform gateway |
| tool_allowlist | jsonb NOT NULL | '[]' | Array of tool UUIDs the agent may call |
| eligibility | jsonb NOT NULL | '{}' | Boolean expression (see grammar below) |
| origin | config_origin (enum) | 'core' | `core` \| `community` (community deferred to Phase 10) |
| version | int NOT NULL | 1 | Internal schema version |

### `tasks` (relevant columns)

| Column | Type | Default | Phase 6 usage |
|--------|------|---------|---------------|
| findings | jsonb NOT NULL | '{}' | Written by triage/expansion agents (Findings schema below) |
| context_refs | jsonb NOT NULL | '{}' | Written by expansion agent |
| current_stage | chain_stage | 'creation' | Updated by chain workflow as stages advance |
| state | task_state | 'accepted' | ACCEPTED → EXECUTING transition at expansion→execution |

### `agent_assignments` (unchanged)

Used when the router places the **human** in a slot. Same schema as Phase 2.

### `audit_messages` (new kinds only)

No schema change. New `kind` values:
- `agent_run_started` — payload: `{config_id, config_name, stage, task_id}`
- `agent_run_finished` — payload: `{config_id, stage, task_id, iterations, tokens_in, tokens_out}`
- `router_selected` — payload: `{stage, eligible_set: [config_ids], picked: config_id|"human", findings_hash}`
- `agent_call_refused` — payload: `{tool_global_uri, reason: "not_in_allowlist"}`
- `budget_exhausted` — payload: `{task_id, budget, calls_made, stage}`
- `max_iterations_reached` — payload: `{task_id, stage, iterations}`

## New Types (Go, not persisted)

### Findings (written to `tasks.findings`)

```go
type Findings struct {
    Structured StructuredFindings `json:"structured"`
    FreeText   string             `json:"free_text"`
}

// v1 normative schema — eligibility may only bind to these fields.
type StructuredFindings struct {
    CategoryHints        []string        `json:"category_hints"`
    StakesScore          float64         `json:"stakes_score"`
    Entities             []Entity        `json:"entities"`
    RequiredCapabilities []string        `json:"required_capabilities"`
}

type Entity struct {
    Name string `json:"name"`
    Type string `json:"type"` // "person", "org", "service", etc.
}
```

### StageResult (returned by agent runner)

```go
type StageResult struct {
    Findings         *Findings       `json:"findings,omitempty"`
    ContextRefs      json.RawMessage `json:"context_refs,omitempty"` // expansion only
    FailCloseToHuman bool            `json:"fail_close_to_human"`
    FailReason       string          `json:"fail_reason,omitempty"`  // "budget_exhausted", "max_iterations", "gateway_error"
}
```

### SlotDecision (memoized DBOS step result)

```go
type SlotDecision struct {
    IsHuman     bool            `json:"is_human"`
    ConfigID    *uuid.UUID      `json:"config_id,omitempty"`    // nil for human
    ConfigName  string          `json:"config_name,omitempty"`
    StageResult json.RawMessage `json:"stage_result,omitempty"` // populated only for agent path
}
```

### Eligibility Expression (stored in `agent_configs.eligibility` as JSON)

```go
type Expression struct {
    And  []Expression `json:"and,omitempty"`
    Or   []Expression `json:"or,omitempty"`
    Not  *Expression  `json:"not,omitempty"`
    Pred *Predicate   `json:"pred,omitempty"`
}

type Predicate struct {
    Op    string      `json:"op"`    // "subset", "gte", "lte", "gt", "lt", "contains"
    Field string      `json:"field"` // "required_capabilities", "stakes_score", "category_hints", "entities"
    Value interface{} `json:"value"` // string[], number, or string depending on op
}
```

**Example eligibility (JSON in DB)**:
```json
{
  "and": [
    {"pred": {"op": "subset", "field": "required_capabilities", "value": ["send-email"]}},
    {"pred": {"op": "gte", "field": "stakes_score", "value": 3}}
  ]
}
```

Always-eligible (matches everything): `{}` (empty object evaluates to `true`).

## Relationships

```
tasks 1──∞ audit_messages (task_id, nullable Phase 5+)
tasks 1──∞ agent_assignments (task_id)
tasks 1──1 chain_workflows (task_id)
agent_configs ──── tools (tool_allowlist references tools.id as UUID[])
tasks.findings ←── agent runner writes
tasks.findings ──→ router reads (for eligibility + LLM pick)
```

## State Transitions (unchanged from Phase 1)

```
PROPOSED → ACCEPTED / DISMISSED / HALTED
ACCEPTED → EXECUTING / WAITING / HALTED
WAITING → EXECUTING / HALTED
EXECUTING → DONE / HALTED
```

Phase 6 path: task starts ACCEPTED → chain advances through stages → at expansion→execution
boundary, transitions to EXECUTING (readiness predicate) → at completion, transitions to DONE.

## Indexes (no new indexes needed)

Phase 0 already created indexes on `agent_configs(stage)` and `tasks(state)`.
