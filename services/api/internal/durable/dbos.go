// Package durable wraps DBOS Transact for the tendant core. Phase 1 adds
// chain-workflow registration; the throwaway demo still lives in cmd/dbosdemo.
package durable

import (
	"context"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
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

// RegisterChainWorkflow registers the chain workflow with DBOS, closing over
// its runtime deps. MUST be called between Init and Launch — Launch performs
// recovery against the registered function, so the function must be in place
// beforehand. Wires the deps through chain.Register.
//
// ownerGlobalURI populates agent_assignments.to_principal for Phase 2;
// pushEnqueuer (nil-able) schedules push fan-out on assignment open.
func RegisterChainWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, router chain.Router, ownerGlobalURI string, pushEnqueuer chain.PushEnqueuer) {
	chain.Register(dctx, pool, q, router, ownerGlobalURI, pushEnqueuer)
}

// PushQueueName is the named DBOS workflow queue used for push fan-out.
const PushQueueName = "push"

// RegisterPushQueue declares the named DBOS workflow queue for push fan-out
// and (when handler is non-nil) registers the per-job workflow against it.
// MUST be called between Init and Launch. handler nil signals "no real
// workers wired this boot" — useful when only LogProvider is configured
// (the chain workflow's push enqueue still records the work via the
// recordingPushEnqueuer-style hook in `chain.Register`).
func RegisterPushQueue(dctx dbos.DBOSContext) {
	_ = dbos.NewWorkflowQueue(dctx, PushQueueName,
		dbos.WithWorkerConcurrency(4),
	)
}
