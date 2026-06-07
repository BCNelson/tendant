package intake

import "encoding/json"

// SignalVersion is the current revision of the in-edge contract. It is the
// second of the five long-lived versioned contracts (Constitution VII).
// Evolution is additive by default; a breaking change bumps to "intake.v2"
// and runs both for the documented window.
//
// Contract: specs/008-intake-edge-connectors/contracts/signal.v1.md.
const SignalVersion = "intake.v1"

// Disposition values — the per-emission privacy/cost firewall.
const (
	// DispositionForcedTask — "this IS a task." Creates the record directly,
	// skips the is-task judgment. No model. Confidence/StakesHint ignored.
	DispositionForcedTask = "forced_task"
	// DispositionRichEvent — a structured candidate. Auto-accepts iff it clears
	// both the confidence floor and the stakes ceiling; otherwise holds
	// PROPOSED. No model.
	DispositionRichEvent = "rich_event"
	// DispositionLLMJudge — "I can't decide." Hands Payload (and only Payload)
	// to triage's LLM; lands PROPOSED. Subject to the per-poll cap.
	DispositionLLMJudge = "llm_judge"
)

// PotentialTaskSignal is one normalized emission from a connector — the single
// shape the core reads, never Gmail/RSS/IMAP specifics.
type PotentialTaskSignal struct {
	SignalVersion  string          // MUST be SignalVersion ("intake.v1")
	SourceID       string          // connector_type + integration identity, e.g. "gmail:<connectorID>"
	IdempotencyKey string          // stable per source item; dedupe is UNIQUE(connector_id, idempotency_key)
	Provenance     Provenance      // reference (not content) + why flagged
	Payload        json.RawMessage // connector-normalized; the ONLY thing llm_judge ships to a model
	Disposition    string          // one of the Disposition* values
	Confidence     *float64        // REQUIRED for rich_event; ∈ [0.0, 1.0]; nil otherwise
	StakesHint     *float64        // REQUIRED for rich_event; ∈ [0.0, 1.0]; nil otherwise
}

// Provenance is a source-stable reference plus a human-readable reason — never
// a copy of raw content. Re-fetchable by the connector on demand.
type Provenance struct {
	RawRef string `json:"raw_ref"` // e.g. "gmail:message/<id>", "rss:<feed>#<guid>"
	Reason string `json:"reason"`  // why the connector flagged it (filter match, rule, etc.)
}

// Validate checks the static field rules from the contract (signal.v1.md).
// Disposition-specific axis validation (confidence/stakes presence + range for
// rich_event) is enforced in the disposition router, fail-closed, so a bad
// rich_event holds PROPOSED rather than being rejected outright.
func (s PotentialTaskSignal) Validate() error {
	switch {
	case s.SignalVersion != SignalVersion:
		return &SignalError{Field: "SignalVersion", Reason: "must be " + SignalVersion}
	case s.SourceID == "":
		return &SignalError{Field: "SourceID", Reason: "required"}
	case s.IdempotencyKey == "":
		return &SignalError{Field: "IdempotencyKey", Reason: "required"}
	case s.Provenance.RawRef == "":
		return &SignalError{Field: "Provenance.RawRef", Reason: "required"}
	case len(s.Payload) == 0:
		return &SignalError{Field: "Payload", Reason: "required"}
	case s.Disposition != DispositionForcedTask &&
		s.Disposition != DispositionRichEvent &&
		s.Disposition != DispositionLLMJudge:
		return &SignalError{Field: "Disposition", Reason: "unknown disposition: " + s.Disposition}
	}
	return nil
}

// SignalError describes a static contract violation on an emitted signal.
type SignalError struct {
	Field  string
	Reason string
}

func (e *SignalError) Error() string {
	return "intake.signal: " + e.Field + ": " + e.Reason
}
