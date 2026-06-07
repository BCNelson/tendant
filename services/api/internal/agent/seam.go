package agent

import "context"

// InboundQueryHandler is the Phase 9 sub-agent seam. In v1 this is a no-op
// stub; the full inbound query/answer protocol ships later.
type InboundQueryHandler interface {
	HandleQuery(ctx context.Context, query string) (string, error)
}

// NoOpQueryHandler is the default stub that returns an empty answer.
type NoOpQueryHandler struct{}

// HandleQuery returns an empty response (Phase 9 stub).
func (NoOpQueryHandler) HandleQuery(_ context.Context, _ string) (string, error) {
	return "", nil
}
