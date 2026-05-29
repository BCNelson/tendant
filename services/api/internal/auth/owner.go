package auth

import (
	"context"
	"errors"
)

// ErrPermissionDenied is the structural sentinel returned when a context
// carries no principal or carries one whose Kind is not "user". Distinct
// from Can() — Can() answers "is this principal allowed to act on this
// row"; RequireOwner answers "is this principal the owner-of-record".
// Phase 4 introduces this split because Can() returns true for any
// authenticated principal under the single-household assumption, so it
// cannot stand alone as the owner-only gate on tool tuning mutations.
var ErrPermissionDenied = errors.New("auth: permission denied")

// RequireOwner returns the context's Principal iff it is non-nil and has
// Kind == "user"; otherwise ErrPermissionDenied. Resolvers MUST call this
// FIRST THING — before any DB write — for owner-only mutations.
//
// When multi-owner deployments arrive, the body changes to "principal must
// be the resource's owner-of-record" without touching call sites.
func RequireOwner(ctx context.Context) (*Principal, error) {
	p, ok := FromContext(ctx)
	if !ok || p == nil {
		return nil, ErrPermissionDenied
	}
	if p.Kind != "user" {
		return nil, ErrPermissionDenied
	}
	return p, nil
}
