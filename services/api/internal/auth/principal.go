// Package auth carries Phase 2's session-token machinery, the central
// Can(ctx, principal, action, target) decision point, and the registry that
// asserts every operator-edge field consults Can at startup.
package auth

import (
	"context"

	"github.com/google/uuid"
)

// Principal is the authenticated subject attached to a request context. The
// shape mirrors the gqlgen `Principal` interface so resolvers can return it
// directly. Phase 2 has exactly one Principal — the seeded owner.
type Principal struct {
	ID          uuid.UUID
	GlobalURI   string
	DisplayName string
	Kind        string // "user" or "bot"
}

type principalCtxKey struct{}

// WithPrincipal attaches p to ctx. Use from the chi middleware and the
// WebSocket InitFunc.
func WithPrincipal(ctx context.Context, p *Principal) context.Context {
	return context.WithValue(ctx, principalCtxKey{}, p)
}

// FromContext returns the principal attached by WithPrincipal, if any. The
// caller is responsible for fail-closed handling when ok == false.
func FromContext(ctx context.Context) (*Principal, bool) {
	p, ok := ctx.Value(principalCtxKey{}).(*Principal)
	if !ok || p == nil {
		return nil, false
	}
	return p, true
}
