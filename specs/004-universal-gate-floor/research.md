# Research: Phase 3 — Universal Gate, Hard-Rule Floor & the First Tool

## R1. Where does the gate live, mechanically?

**Decision**: New `internal/gate` package — pure Go, no I/O.

**Rationale**: The gate is a function from `(ToolCall, Tool) → Verdict`. Keeping it pure means:
- Unit tests have zero infrastructure cost.
- Floor verdicts are reproducible from JSON fixtures.
- Future LLM overseer (Phase 4) and WASM script (Phase 5) plug in as composable layers without changing the function's shape.

**Alternatives**:
- *In `internal/chain`*: rejected — couples gate logic to chain workflow internals, blocks Phase 4 callers (subagents) that don't run inside the chain.
- *In `services/api/graph` resolvers*: rejected — duplicates logic for every caller surface (mutations, subscriptions, future REST).

## R2. Where does the gate get invoked from?

**Decision**: A new mutation `proposeToolCall(taskId, toolGlobalUri, payload)` is the sole entry point in Phase 3. It runs the gate inline, then either dispatches synchronously (read-only) or starts the `ToolCallWorkflow`.

**Rationale**: With only the human-only router in Phase 1/2, agents don't yet compose tool calls. The owner is the composer. A dedicated mutation makes the gate boundary explicit and gives the Flutter UI a clean affordance. When the overseer LLM (Phase 4) starts composing on the agent's behalf, the same mutation surface is reused — the only difference is who's calling.

**Alternatives**:
- *Side-effect of `completeTask`*: rejected — overloads a mutation whose contract is "I'm done with this assignment." Tool composition is a distinct verb.
- *Synthesised from assignment payload in chain workflow*: rejected — couples gate to chain step ordering and adds branching to a deterministic workflow body (R5 violation).

## R3. How does the workflow wait for approval without polling?

**Decision**: Reuse Phase 1's `chain.WaitForResult` shape (`dbos.Recv[json.RawMessage](ctx, topic, timeout)`). The topic is deterministic: `"approval:" + decisionID`. The approval mutation `dbos.Send`s the resolution payload to that topic.

**Rationale**: This is the same primitive that already powers Phase 1's stage waits and Phase 2's assignment completes. Reusing it means:
- No new DBOS infrastructure.
- The wait is durable across restarts identically to the chain's stage waits.
- The 72h timeout is consistent with `chain.HumanSlotTimeout`.

**Alternatives**:
- *Polling pending_decisions.resolved_at*: rejected — defeats the durability guarantee; misses fast-acting approvals.
- *LISTEN/NOTIFY on resolution*: rejected — works for the operator-edge realtime fan-out but not for in-workflow waits (DBOS-style Recv is the right shape).

## R4. How is the frozen payload bound to the approval?

**Decision**: Write the exact composed `payload` JSON into a new `pending_decisions.frozen_payload jsonb` column. On approval, the workflow loads this row and dispatches it byte-for-byte. The `Artifact.content` field returned to the client is the same JSON, so what-you-see-is-what-you-approve.

**Rationale**: The spec is explicit: "Approval is bound to the frozen payload (the Artifact): the human approves the exact composed call and the gate proceeds as-approved without re-screening." Storing the payload at compose time, separately from any agent-side state, makes that binding observable in audit and impossible to bypass.

**Alternatives**:
- *Re-fetch payload from agent state at dispatch*: rejected — opens a TOCTOU window where the agent could rewrite the payload between approval and dispatch. (For Mandate this gap is unavoidable v1; for Artifact it must be closed.)
- *Hash the payload into the decision row, store full payload in audit*: rejected — adds indirection without security benefit, since the audit row is the same database.

## R5. How does the floor express its three clauses?

**Decision**: `tools.permissions` jsonb (already in Phase 0 schema) is the per-tool data feed. The shape for Phase 3:

```json
{
  "read_only": false,
  "spend": false,
  "irreversible_third_party": "stranger_recipient" | "always" | "never",
  "secret_classes": ["disclosure_class_name", ...]
}
```

The `Floor` evaluator interprets each key:
- `spend: true` → always trips.
- `irreversible_third_party: "stranger_recipient"` → trips if `payload.recipient` is not in `principals.global_uri`.
- `irreversible_third_party: "always"` → trips always (e.g. a future `send-sms` to anyone).
- `irreversible_third_party: "never"` → never trips on this clause.
- `secret_classes` non-empty → trips if `payload.disclosure_class` is in the list. (Wired but not exercised until Phase 9 sub-agents.)

**Rationale**: jsonb keeps the floor's data model schema-less so new clauses can land without migrations. The clauses are interpreted by a tiny pure Go function (`floor.Check(payload, permissions)`), trivially unit-tested.

**Alternatives**:
- *Per-tool Go code*: rejected — defeats the goal of a categorical floor; a forgotten check is a safety hole.
- *DSL / WASM*: deferred to Phase 5 (gate scripts), which are *per-tool tuning* below the categorical floor.

## R6. What does `send-email` look like behind the tool boundary?

**Decision**: `Tool` interface in `internal/tools`. `SendEmail` struct implements it. A `Provider` seam (interface) carries the actual SMTP/HTTP call; `LogProvider` (default) writes a structured log line. Real SMTP provider is a stub here — Phase 3 ships LogProvider only; CI doesn't have credentials.

**Rationale**: Mirrors the Phase 2 `internal/push.Provider` pattern. The boundary keeps real-time / interactive concerns *behind* the tool, never in core. The `LogProvider` makes Phase 3 fully testable without external services.

**Alternatives**:
- *Direct net/smtp in core*: rejected — violates the boundary rule and complicates testing.
- *Real SMTP provider now*: deferred — no deployment configuration is wired yet; Phase 7 (credentials encryption) is where real provider creds land.

## R7. Outcome recording

**Decision**: One `tool_outcomes` row per dispatch attempt — `outcome='clean'` on success, `outcome='bad'` on provider error. `matured_at` left null (Phase 8's calibration ratchet sets it).

**Rationale**: The schema exists since Phase 0; Phase 3 is the first writer. Defaulting to `clean` matches the spec's "inferred-clean by default" language. The `bad` path supports the calibration ledger so Phase 8 has data to work with from day one.

**Alternatives**:
- *Don't record on failure*: rejected — Phase 8 needs failure data to demote tools.
- *Defer the writer to Phase 8*: rejected — Phase 3 is the first phase that has dispatches to record; the writer must land with them.

## R8. Why no overseer / script in this phase?

Restating the brief: the floor is the *foundation*. Both the overseer (Phase 4) and gate scripts (Phase 5) sit *above* it and *below* it respectively — but they only make sense once the floor is unbypassable. Shipping the floor first means Phases 4 and 5 inherit a safety guarantee for free; shipping them first would mean retrofitting the floor through completed code paths.

The temporary cost is that every non-floor graded call also escalates to the owner. The overseer (Phase 4) is what fixes that.
