# The Potential-Task Signal — `intake.v1`

The **in-edge contract**: the single normalized shape every connector emits, and the second of the
five long-lived versioned contracts (Constitution Principle VII). It is the boundary that keeps the
core source-agnostic — the core reads `intake.v1`, never Gmail/RSS/IMAP specifics.

**Versioning policy**: `specs/003-operator-edge-wake/contracts/versioning-policy.md`.
Evolution is **additive by default** (new optional field, new disposition value behind a capability,
new provenance key). A breaking change bumps `SignalVersion` (`intake.v2`) and runs both for the
documented window. **This PR: Path 1 — additive (introduces `intake.v1`).**

---

## Go shape (the wire/in-process contract)

```go
// SignalVersion for this contract revision.
const SignalVersion = "intake.v1"

// PotentialTaskSignal is one normalized emission from a connector.
type PotentialTaskSignal struct {
    SignalVersion  string          // MUST be "intake.v1"
    SourceID       string          // connector_type + integration identity, e.g. "gmail:<connectorID>"
    IdempotencyKey string          // stable per source item; dedupe is UNIQUE(connector_id, idempotency_key)
    Provenance     Provenance      // reference (not content) + why flagged
    Payload        json.RawMessage // connector-normalized; the ONLY thing llm_judge ships to a model
    Disposition    string          // "forced_task" | "rich_event" | "llm_judge"
    Confidence     *float64        // REQUIRED for rich_event; ∈ [0.0, 1.0]; nil otherwise
    StakesHint     *float64        // REQUIRED for rich_event; ∈ [0.0, 1.0]; nil otherwise
}

// Provenance is a source-stable reference plus a human-readable reason — never a copy of raw content.
type Provenance struct {
    RawRef string `json:"raw_ref"` // e.g. "gmail:message/<id>", "rss:<feed>#<guid>"
    Reason string `json:"reason"`  // why the connector flagged it (filter match, rule, etc.)
}

// Connector is the trusted adapter; an integration is a ConnectorConfig over it.
type Connector interface {
    Type() string
    Run(ctx context.Context, cfg ConnectorConfig, emit func(PotentialTaskSignal) error) error
}
```

## Field rules

| Field | Required | Constraint |
|---|---|---|
| `SignalVersion` | yes | exactly `"intake.v1"`; mismatch ⇒ signal rejected |
| `SourceID` | yes | identifies the emitting integration; used in `from_principal` audit |
| `IdempotencyKey` | yes | MUST derive from a **stable source identity** so distinct items get distinct keys; reuse for distinct items would suppress real tasks |
| `Provenance.RawRef` | yes | a reference/ID, **not** content; re-fetchable by the connector on demand |
| `Provenance.Reason` | yes | short, human-readable |
| `Payload` | yes | normalized JSON; the connector is the privacy firewall — it chooses what this carries |
| `Disposition` | yes | one of the three values; unknown ⇒ fail-closed (treated as needing sign-off) |
| `Confidence` | iff `rich_event` | float `[0.0, 1.0]`; absent/out-of-range on a `rich_event` ⇒ fail-closed to `PROPOSED` |
| `StakesHint` | iff `rich_event` | float `[0.0, 1.0]`; absent/out-of-range on a `rich_event` ⇒ fail-closed to `PROPOSED` |

## Disposition semantics (the firewall)

- **`forced_task`** — "this IS a task." Creates the record directly; **skips the is-task judgment**.
  No model. `Confidence`/`StakesHint` ignored.
- **`rich_event`** — a structured candidate. The core's intake-autonomy dial auto-accepts iff
  `Confidence ≥ confidence_floor` **AND** `StakesHint ≤ stakes_ceiling` (thresholds from the
  connector's `disposition_rules`); otherwise holds `PROPOSED`. No model.
- **`llm_judge`** — "I can't decide." Hands `Payload` (and only `Payload`) to triage's LLM for
  is-task / shape / stakes; lands `PROPOSED`. Subject to the per-poll cap; overflow holds `PROPOSED`
  with no model call.

## Invariants

- **Privacy**: raw source content leaves the box (to a model) **only** via an `llm_judge` `Payload`.
  No `forced_task`/`rich_event` path invokes a model for the is-task decision.
- **Idempotency**: a re-emission of an already-seen `(connector, IdempotencyKey)` is a no-op.
- **Trusted edge**: connectors are reviewed in-tree Go; containment is the config allowlist + the
  universal gate, not a sandbox. There is no untrusted code on this edge.
