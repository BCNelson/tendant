// Package intake is the in-edge: the trusted boundary that turns external
// source emissions into durable tasks (or PROPOSED candidates) without
// teaching the core anything source-specific.
//
// It owns four concerns:
//
//   - the versioned signal contract (signal.go) — every connector emits a
//     PotentialTaskSignal ("intake.v1"); the core reads that shape and never
//     Gmail/RSS/IMAP specifics (Constitution Principle I/VII).
//   - the disposition router (disposition.go) — the privacy/cost firewall.
//     A per-emission disposition (forced_task | rich_event | llm_judge)
//     decides whether an item becomes a task directly, auto-accepts as an
//     enrich-only task, holds PROPOSED, or is handed to the triage LLM. Only
//     llm_judge ever forwards a payload to a model (NFR-001).
//   - idempotent ingest (ingest.go) — persistence deduped by the Phase-0
//     UNIQUE(connector_id, idempotency_key) via ON CONFLICT DO NOTHING, with
//     a signal_emitted / signal_deduped audit per outcome (Constitution VI).
//   - the scheduler glue (scheduler.go) + per-connector poll workflow
//     (poll.go) — polling is a DBOS dynamic schedule (one per enabled
//     connector), DB-backed and crash-recovered on Launch.
//
// The package is trusted, reviewed, in-tree Go — there is no sandbox on this
// edge (Constitution IX); containment is the config allowlist plus the
// universal gate that governs any action a resulting task later takes.
package intake
