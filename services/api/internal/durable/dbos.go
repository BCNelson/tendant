// Package durable wraps DBOS Transact for the tendant core. Phase 0 only
// initialises DBOS over the shared pgx pool; no workflows are registered by
// the main binary (the throwaway demo lives in cmd/dbosdemo).
package durable

import (
	"context"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"
)

// AppName is the DBOS application identifier.
const AppName = "tendant"

// Init constructs a DBOSContext bound to the given pgx pool. DBOS isolates its
// own tables in the `dbos` schema; app tables stay in `public`.
//
// executorID pins the DBOS executor identity for recovery — keep it stable
// across restarts so PENDING workflows for this executor are recovered on
// Launch. The main binary uses "tendant"; the recovery demo overrides to
// "demo" so its workflows don't collide with main.
func Init(ctx context.Context, pool *pgxpool.Pool, executorID string) (dbos.DBOSContext, error) {
	return dbos.NewDBOSContext(ctx, dbos.Config{
		AppName:        AppName,
		SystemDBPool:   pool,
		DatabaseSchema: "dbos",
		ExecutorID:     executorID,
	})
}

// Launch starts the DBOS runtime (creates the `dbos` schema if needed,
// recovers PENDING workflows for this executor). Launch returning nil is the
// DBOS readiness signal (FR-012 / US4-AC1).
func Launch(ctx dbos.DBOSContext) error {
	return dbos.Launch(ctx)
}

// Shutdown gracefully tears down DBOS within the given timeout.
func Shutdown(ctx dbos.DBOSContext, timeout time.Duration) {
	dbos.Shutdown(ctx, timeout)
}
