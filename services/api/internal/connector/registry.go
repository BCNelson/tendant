package connector

import (
	"context"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// Registry maps a connector_type to its Connector implementation. Populated at
// boot with the base set via RegisterBaseSet; owner mutations validate
// connector_type against it before persisting a config (FR / SC-008).
//
// Registry satisfies intake.ConnectorRunner, so main injects it into the poll
// workflow without internal/intake importing this package.
type Registry struct {
	byType map[string]Connector
}

// NewRegistry returns an empty registry. Call RegisterBaseSet (or Register)
// to populate it.
func NewRegistry() *Registry {
	return &Registry{byType: make(map[string]Connector)}
}

// Register adds a connector under its Type(). A duplicate type panics — the
// base set is fixed at boot, so a collision is a programming error.
func (r *Registry) Register(c Connector) {
	t := c.Type()
	if _, dup := r.byType[t]; dup {
		panic(fmt.Sprintf("connector: duplicate registration for type %q", t))
	}
	r.byType[t] = c
}

// Get returns the connector for a type and whether it is registered.
func (r *Registry) Get(connectorType string) (Connector, bool) {
	c, ok := r.byType[connectorType]
	return c, ok
}

// Has reports whether a connector_type is registered (used by the owner
// mutations to reject unknown types before any DB write).
func (r *Registry) Has(connectorType string) bool {
	_, ok := r.byType[connectorType]
	return ok
}

// Types returns the registered connector types (unordered) — for diagnostics.
func (r *Registry) Types() []string {
	out := make([]string, 0, len(r.byType))
	for t := range r.byType {
		out = append(out, t)
	}
	return out
}

// Run dispatches a poll to the connector named by cfg.ConnectorType, making
// Registry an intake.ConnectorRunner. An unregistered type is a hard error —
// the schedule should never have been created for it.
func (r *Registry) Run(ctx context.Context, cfg ConnectorConfig, emit intake.EmitFunc) error {
	c, ok := r.byType[cfg.ConnectorType]
	if !ok {
		return fmt.Errorf("connector: no registered connector for type %q", cfg.ConnectorType)
	}
	return c.Run(ctx, cfg, emit)
}

// RegisterBaseSet populates the registry with the Phase-7 base set:
//   - webhook-in, rss  — fully implemented, zero-credential
//   - gmail            — OAuth exemplar (live call behind a fetcher seam)
//   - calendar, imap   — stub providers (emit nothing this phase)
//
// inbound supplies the webhook-in connector its queued-item source (the chi
// ingress route drains into it). Pass nil to register a webhook-in that emits
// nothing (useful in tests that only exercise other connectors).
func RegisterBaseSet(r *Registry, inbound InboundQueue) {
	r.Register(NewWebhookIn(inbound))
	r.Register(NewRSS(nil))
	r.Register(NewGmail(nil))
	r.Register(NewCalendarStub())
	r.Register(NewIMAPStub())
}

// Compile-time assertion that Registry is an intake.ConnectorRunner.
var _ intake.ConnectorRunner = (*Registry)(nil)
