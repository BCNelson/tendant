# Schema separation: the `agentkit` schema

**Decision:** agentkit owns a dedicated Postgres schema, `agentkit`. Its tables,
its sqlc-generated queries, and its goose migration lineage are independent of
the consuming application's. This follows the precedent already in the codebase:
DBOS runs in its own `dbos` schema against the same database.

This is the design for roadmap step 2 (the db-foundation split). It is not yet
implemented.

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

**Ordering.** Framework migrations run **first**: app tables hold FKs that
reference `agentkit.*` tables (allowed: app → framework), so the framework
schema must exist before the app's migrations apply.

**DBOS is unchanged** — it keeps its own `dbos` schema and its own lifecycle.

**sqlc.** A framework `sqlc.yaml` reads the framework migrations + queries and
emits `agentkit/db` (a public package, not `internal/`, so consumers can import
it). The app keeps its own sqlc config for the app half. Optionally emit a
`Querier` interface (`emit_interface: true`) on the framework side so consumers
can mock the framework's persistence in their own tests.

## Table partition

The rule that drives classification: **no foreign key may point from
`agentkit.*` to an app-owned table** (the framework must not depend on the
app). Everything the framework's own FKs reach is therefore framework-owned.

### Framework (`agentkit` schema)

| Table | Role |
|---|---|
| `tasks` | the unit of work the chain walks |
| `audit_messages` | the audit DAG (self-referencing parent) |
| `principals` | minimal identity the gate / assignments / decisions reference |
| `agent_configs` | the specialist catalog (a specialist = a config row) |
| `agent_assignments` | human-slot assignments (→ tasks, → principals) |
| `chain_workflows` | DBOS chain bookkeeping (→ tasks) |
| `pending_decisions` | gate decisions awaiting resolution (→ tasks) |
| `tools` | the action-edge catalog + permissions/overseer instructions |
| `tool_outcomes` | gated-call outcomes + routine fingerprints (→ tools, → tasks) |
| `tool_routine_grants` | earned-autonomy grants (→ tools) |
| `gate_scripts` | the untrusted-code gate layer |
| `owner_rules` | owner-rule key/value backing the gate-script host fn |

### Application (e.g. `public` schema, tendant-owned)

| Table | Role |
|---|---|
| `intake_signals` | the intake edge (Phase 7) |
| `connector_configs`, `source_credentials` | intake connectors |
| `task_categories` | tendant categorization tree |
| `agent_guidance` | owner-feedback notes the runner reads |
| `feedback_messages` | feedback generation loop |
| `embeddings`, `embedding_versions` | semantic search (the `CategoryMatcher` seam impl) |
| `config_entries` | config overlay |
| `sessions`, `device_tokens` | operator-edge auth + push |

`embeddings` is app-owned by design: the agent runner consumes a
`CategoryMatcher` *interface*; tendant's embedding subsystem is one
implementation of that seam, not framework machinery.

## The one inversion edge to resolve

`tasks.intake_signal_id → intake_signals` is the only FK pointing from a
framework table to an app table. Resolution: **drop the typed FK column from the
framework `tasks` table and carry the intake reference in the existing
`tasks.provenance jsonb`** (already present, and already documented as "a
reference, not a content copy"). The framework treats provenance as opaque; the
app interprets it.

If the app wants enforced referential integrity for the linkage, it owns an
app-side link table — `task_intake_links(task_id → agentkit.tasks(id),
signal_id → intake_signals(id))` — whose FKs are app→framework and app→app, both
allowed.

## Allowed cross-schema edges (app → framework)

These stay as ordinary FKs; they point inward, which is fine:
`agent_guidance → tasks`, `feedback_messages → tasks`, the app's intake-link
table → `tasks`, etc. The only constraint they impose is migration ordering
(framework first), already required above.

## What the move actually costs

The mechanical heavy lift of step 2 is partitioning the existing migrations
`00001–00016`: extracting framework DDL into the `agentkit` migration lineage
(rewritten schema-qualified into `agentkit.*`) and leaving app DDL in the app
lineage, then re-pointing the ~130 importers of `internal/db` to either
`agentkit/db` or the app's db package depending on which queries they use. The
partition above is what makes that a mechanical sort rather than a judgment call
per file.
