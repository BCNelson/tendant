// Package ownerrule is a thin service over the owner_rules table (Phase 5).
// It backs the owner.rule(key) gate-script host function (read path) and the
// owner-only setOwnerRule mutation (write path). Owner rules are free-form
// (key, value) preferences a script reads as internal data — never fetched
// from inside the sandbox.
package ownerrule

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Service wraps the sqlc owner_rules queries.
type Service struct {
	q *db.Queries
}

// New constructs a Service over the given queries handle.
func New(q *db.Queries) *Service {
	return &Service{q: q}
}

// Get returns the value for (ownerURI, key). The bool is false when no rule is
// set — distinct from an empty-string value. A missing row is not an error.
func (s *Service) Get(ctx context.Context, ownerURI, key string) (string, bool, error) {
	v, err := s.q.GetOwnerRule(ctx, db.GetOwnerRuleParams{OwnerGlobalUri: ownerURI, Key: key})
	if errors.Is(err, pgx.ErrNoRows) {
		return "", false, nil
	}
	if err != nil {
		return "", false, err
	}
	return v, true, nil
}

// Set upserts (ownerURI, key) → value and returns the previous value, or nil
// when the key was unset. The previous value lets the caller record
// owner_rule_set audit payloads with both old and new values.
func (s *Service) Set(ctx context.Context, ownerURI, key, value string) (*string, error) {
	prev, found, err := s.Get(ctx, ownerURI, key)
	if err != nil {
		return nil, err
	}
	if _, err := s.q.UpsertOwnerRule(ctx, db.UpsertOwnerRuleParams{
		OwnerGlobalUri: ownerURI,
		Key:            key,
		Value:          value,
	}); err != nil {
		return nil, err
	}
	if found {
		p := prev
		return &p, nil
	}
	return nil, nil
}
