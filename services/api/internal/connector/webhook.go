package connector

import (
	"context"
	"encoding/json"
	"sync"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// connectorTypeWebhookIn is the registry key for the inbound-webhook connector.
const connectorTypeWebhookIn = "webhook-in"

// InboundItem is one queued inbound delivery awaiting the next poll. The chi
// ingress route enqueues these; a poll drains and emits them.
type InboundItem struct {
	IdempotencyKey string          // stable per delivery (e.g. a provider event id)
	Payload        json.RawMessage // connector-normalized body
	Disposition    string          // intake.Disposition* — defaults to forced_task if blank
	Reason         string          // provenance reason
	RawRef         string          // provenance raw_ref
	Confidence     *float64        // rich_event only
	StakesHint     *float64        // rich_event only
}

// InboundQueue is the seam between the ingress route and the poll. The default
// in-memory implementation (MemoryInboundQueue) is enough for a single box; a
// future durable queue can replace it without touching the connector.
type InboundQueue interface {
	// Drain returns and clears all queued items.
	Drain() []InboundItem
}

// MemoryInboundQueue is a goroutine-safe in-memory InboundQueue. The ingress
// route Pushes; the poll Drains.
type MemoryInboundQueue struct {
	mu    sync.Mutex
	items []InboundItem
}

// Push enqueues an inbound delivery.
func (q *MemoryInboundQueue) Push(item InboundItem) {
	q.mu.Lock()
	defer q.mu.Unlock()
	q.items = append(q.items, item)
}

// Drain returns and clears all queued items.
func (q *MemoryInboundQueue) Drain() []InboundItem {
	q.mu.Lock()
	defer q.mu.Unlock()
	out := q.items
	q.items = nil
	return out
}

// WebhookIn is the zero-credential inbound-webhook connector. On Run it drains
// its InboundQueue and emits one signal per queued delivery. Idempotency is the
// delivery's provided key, so a duplicate delivery (or a replay across polls)
// dedupes at the intake_signals unique index.
type WebhookIn struct {
	queue InboundQueue
}

// NewWebhookIn constructs the connector over an inbound queue. A nil queue
// makes Run a no-op (emits nothing) — useful in tests of other connectors.
func NewWebhookIn(queue InboundQueue) *WebhookIn { return &WebhookIn{queue: queue} }

// Type implements Connector.
func (*WebhookIn) Type() string { return connectorTypeWebhookIn }

// Run drains the queue and emits a signal per item.
func (c *WebhookIn) Run(ctx context.Context, cfg ConnectorConfig, emit intake.EmitFunc) error {
	if c.queue == nil {
		return nil
	}
	for _, item := range c.queue.Drain() {
		if err := ctx.Err(); err != nil {
			return err
		}
		disposition := item.Disposition
		if disposition == "" {
			disposition = intake.DispositionForcedTask
		}
		sig := intake.PotentialTaskSignal{
			SignalVersion:  intake.SignalVersion,
			SourceID:       sourceID(connectorTypeWebhookIn, cfg.ConnectorID),
			IdempotencyKey: item.IdempotencyKey,
			Provenance:     intake.Provenance{RawRef: item.RawRef, Reason: item.Reason},
			Payload:        item.Payload,
			Disposition:    disposition,
			Confidence:     item.Confidence,
			StakesHint:     item.StakesHint,
		}
		if err := emit(sig); err != nil {
			return err
		}
	}
	return nil
}
