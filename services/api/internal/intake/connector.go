package intake

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
)

// ConnectorConfig is the runtime configuration handed to a connector's Run.
// It is the resolved, decrypted view of a connector_configs row plus a
// credential accessor — the connector never touches the database directly.
//
// (This is the contract-side companion to PotentialTaskSignal; the two
// together are the in-edge boundary. The concrete Connector implementations
// live in internal/connector, which imports this package — the dependency
// points inward, never the reverse, so internal/intake stays connector-blind.)
type ConnectorConfig struct {
	ConnectorID      uuid.UUID
	ConnectorType    string
	Filter           json.RawMessage    // coarse connector-side pre-filter
	DispositionRules json.RawMessage    // force_rules/judge_rules are connector-interpreted
	Credentials      CredentialAccessor // nil for zero-credential connectors
}

// EmitFunc is the callback a connector invokes once per normalized source item.
// Returning an error aborts the poll for that connector tick; a nil return
// means the signal was ingested (or deduped) durably.
type EmitFunc func(PotentialTaskSignal) error

// ConnectorRunner is the seam the poll workflow depends on: given a resolved
// ConnectorConfig, run one poll, emitting signals. internal/connector's
// Registry satisfies this interface, and main injects it — so internal/intake
// imports no connector implementation (Constitution Principle I, by construction).
type ConnectorRunner interface {
	Run(ctx context.Context, cfg ConnectorConfig, emit EmitFunc) error
}

// CredentialAccessor gives a connector a current (refreshed-if-near-expiry)
// token bundle without exposing sealing/storage. Implemented in credentials.go.
type CredentialAccessor interface {
	// Token returns the current access token, refreshing through the provider
	// token endpoint if it is near expiry and re-sealing in place.
	Token(ctx context.Context) (TokenBundle, error)
}
