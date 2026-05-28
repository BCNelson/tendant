package graph

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require
// here.

import (
	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Resolver is the gqlgen root resolver. Dependencies hang off the struct (no
// package-level state — CLAUDE.md convention). DBOS is nil-able for the
// Phase-0-style smoke tests that don't drive the chain workflow.
type Resolver struct {
	Pool    *pgxpool.Pool
	Queries *db.Queries
	DBOS    dbos.DBOSContext
}
