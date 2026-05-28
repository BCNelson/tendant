package core

import (
	"context"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// SeedOwner idempotently upserts the single owner Principal. Safe to call on
// every boot; the underlying query is ON CONFLICT DO NOTHING.
func SeedOwner(ctx context.Context, q *db.Queries) error {
	return q.UpsertOwner(ctx)
}
