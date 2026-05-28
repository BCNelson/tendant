package graph

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require
// here.

import (
	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/push"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
)

// Resolver is the gqlgen root resolver. Dependencies hang off the struct (no
// package-level state — CLAUDE.md convention).
//
// DBOS, Dispatcher, PushQueueName, and PushSelector are nil-able / zero-value
// for the Phase 0-style smoke tests that don't drive subscriptions or push.
type Resolver struct {
	Pool          *pgxpool.Pool
	Queries       *db.Queries
	DBOS          dbos.DBOSContext
	Dispatcher    *realtime.Dispatcher
	PushSelector  push.Selector
	PushQueueName string
	SetupSecret   *auth.SetupSecretState
}
