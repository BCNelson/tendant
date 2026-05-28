package graph

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require
// here.

import (
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Resolver is the gqlgen root resolver. Dependencies hang off the struct (no
// package-level state — CLAUDE.md convention).
type Resolver struct {
	Pool    *pgxpool.Pool
	Queries *db.Queries
}
