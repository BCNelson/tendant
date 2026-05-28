// Package realtime is Channel A: in-process LISTEN dispatcher that fans
// pg_notify('tendant_events', ...) envelopes out to subscription resolvers'
// channels. Subscriber registration, per-event auth re-check, and the
// dispatcher loop live here.
package realtime

import "encoding/json"

// EventEnvelope is the decoded shape of `notify_event(topic, id)` from the
// Phase 0 trigger. Keep it tiny — the per-row entity is loaded on demand.
type EventEnvelope struct {
	Topic string `json:"topic"`
	ID    string `json:"id"`
}

// parseEnvelope decodes a `notify_event` JSON payload of the form
// `{"topic":"...","data":{"id":"..."}}`.
func parseEnvelope(raw string) (EventEnvelope, error) {
	type wire struct {
		Topic string `json:"topic"`
		Data  struct {
			ID string `json:"id"`
		} `json:"data"`
	}
	var w wire
	if err := json.Unmarshal([]byte(raw), &w); err != nil {
		return EventEnvelope{}, err
	}
	return EventEnvelope{Topic: w.Topic, ID: w.Data.ID}, nil
}
