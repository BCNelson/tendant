package connector

import (
	"context"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// ConnectorConfig is the resolved config handed to a connector's Run. Aliased
// from intake so the in-edge contract has a single source of truth.
type ConnectorConfig = intake.ConnectorConfig

// Connector is the trusted source adapter. An integration is a ConnectorConfig
// over a Connector. Run polls the source once and emits one normalized
// PotentialTaskSignal per item through emit; the connector is the privacy
// firewall — it chooses what each signal's Payload carries.
//
// Connectors are reviewed, in-tree Go — there is no sandbox on this edge
// (Constitution IX). A new source is one Connector implementation plus a
// registry entry, and zero changes to internal/intake.
type Connector interface {
	Type() string
	Run(ctx context.Context, cfg ConnectorConfig, emit intake.EmitFunc) error
}
