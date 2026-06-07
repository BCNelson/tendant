package connector

import (
	"fmt"
	"net/http"

	"github.com/google/uuid"
)

// sourceID is the PotentialTaskSignal.SourceID: connector_type + integration
// identity, e.g. "gmail:<connectorID>".
func sourceID(connectorType string, connectorID uuid.UUID) string {
	return fmt.Sprintf("%s:%s", connectorType, connectorID)
}

// httpDoer is the injectable HTTP seam (mirrors the Phase-4 overseer's
// net/http approach): tests inject a fake; production uses http.DefaultClient.
type httpDoer interface {
	Do(req *http.Request) (*http.Response, error)
}
