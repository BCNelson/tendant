# Schema separation: the `agentkit` schema

**Decision:** agentkit owns a dedicated Postgres schema, `agentkit`. Its tables,
its sqlc-generated queries, and its goose migration lineage are independent of
the consuming application's. This follows the precedent already in the codebase:
DBOS runs in its own `dbos` schema against the same database.

**Scope note:** agentkit is the *agent* layer, not task management. It does
**not** own `tasks`, the chain workflow, the lifecycle state machine, the
human-approval/decision tables, the inbox, intake, or auth — those stay in the
consuming application. The framework's schema is therefore small: just the
agent + trust catalog.

## Mechanics

**Schema-qualified everywhere.** Framework DDL creates tables in `agentkit.*`
and the framework's queries reference them schema-qualified (`agentkit.tools`,
not `tools`). Qualifying in SQL — rather than relying on a connection
`search_path` — keeps the queries unambiguous when the framework and the app
share one `*pgxpool.Pool`, and avoids search_path juggling between the two.

**Independent migration ledger.** The framework's goose migrations are tracked
in their own version table (`agentkit.goose_db_version`, via goose's table-name
override), separate from the app's `public.goose_db_version`. Two entry points
run independently:

- `agentkit.Migrate(ctx, dsn)` — `CREATE SCHEMA IF NOT EXISTS agentkit`, then
  apply framework migrations against the framework version table.
- the app's existing migrate — applies app migrations against the app version
  table.

There is no migration-ordering constraint between the two: with task management
out of scope, no framework table FKs an app table **and** no app table needs to
FK a framework table (the consumer links its own rows to agent runs by the
opaque correlation id below, not a database FK). The two lineages are
independent.

**DBOS is unchanged** — it keeps its own `dbos` schema and its own lifecycle.

**sqlc.** A framework `sqlc.yaml` reads the framework migrations + queries and
emits `agentkit/db` (a public package, not `internal/`, so consumers can import
it). The app keeps its own sqlc config for the app half. Optionally emit a
`Querier` interface (`emit_interface: true`) on the framework side so consumers
can mock the framework's persistence in their own tests.

## Tables the framework owns (`agentkit` schema)

| Table | Role |
|---|---|
| `agent_configs` | the specialist catalog (a specialist = a config row) |
| `tools` | the action-edge catalog + permissions / overseer instructions |
| `tool_outcomes` | gated-call outcomes + routine fingerprints (→ `tools`; keyed by correlation id) |
| `tool_routine_grants` | earned-autonomy grants (→ `tools`) |
| `gate_scripts` | the untrusted-code gate layer |
| `owner_rules` | owner-rule key/value backing the gate-script host fn |

The only FKs among these are framework→framework (`tool_outcomes` and
`tool_routine_grants` → `tools`), so the schema is self-contained.

## Tables the application owns (NOT agentkit)

Everything task-management and edge-related stays app-side: `tasks`,
`audit_messages`, `transitions`, `chain_workflows`, `agent_assignments`,
`pending_decisions`, `principals`, `intake_signals`, `connector_configs`,
`source_credentials`, `task_categories`, `agent_guidance`, `feedback_messages`,
`embeddings`, `embedding_versions`, `config_entries`, `sessions`,
`device_tokens`.

Note `embeddings` and `agent_guidance` are app-owned by design: the agent runner
consumes them through seams (`CategoryMatcher`, a guidance lookup), so a
consumer supplies its own implementation — they are not framework machinery.

## The correlation id (no cross-schema FK)

The framework's trust state currently keys on `task_id` (`tool_outcomes.task_id`,
and the overseer's per-task evaluation cap). Because `tasks` is app-owned, the
framework must not FK it. The fix: **rekey on an opaque `correlation_id` the
consumer supplies** — a `uuid`/`text` column with **no foreign key**. In tendant
that value is the task id; in another app it is whatever identifies the run (the
DBOS workflow id, an objective id, …). The framework treats it as an opaque
grouping key for cost caps and audit correlation; it never dereferences it.

Audit is not a framework table at all: the runner and calibration write through
the `AuditWriter` seam, so the audit DAG lives in whatever store the consumer
keeps (in tendant, `audit_messages`).

## What the move costs

Smaller than the full extraction, because most of the original schema stays
app-side. The framework migrations carry only the six catalog/trust tables
above (rewritten schema-qualified into `agentkit.*`, with `task_id` → an
unkeyed `correlation_id`). The bulk of `00001–00016` — tasks, lifecycle,
decisions, intake, inbox, auth — is untouched and stays in the app's lineage.
The re-point of `internal/db` importers is correspondingly narrower: only the
agent/gate/overseer/calibration packages move to `agentkit/db`.
