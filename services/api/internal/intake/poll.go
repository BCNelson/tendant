package intake

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// pgUUID wraps a uuid.UUID as a valid pgtype.UUID query arg.
func pgUUID(id uuid.UUID) pgtype.UUID { return pgtype.UUID{Bytes: id, Valid: true} }

// PollWorkflowName is the DBOS workflow name for the per-connector poll. Stable
// across restarts; recovery and the dynamic schedule look the function up by it.
const PollWorkflowName = "tendant.intake.poll"

// RefresherFactory builds a TokenRefresher for a credentialed connector. main
// supplies it (e.g. a gmail refresher for connector_type "gmail"); intake stays
// connector-blind. Return nil for connectors that need no refresh.
type RefresherFactory func(connectorType string, connectorID uuid.UUID) TokenRefresher

// pollDeps closes over the poll workflow's runtime dependencies, set once by
// RegisterPoll at boot (mirrors chain.Register).
type pollDeps struct {
	pool      *pgxpool.Pool
	queries   *db.Queries
	runner    ConnectorRunner
	disposer  *Disposer
	credStore *SealedCredentialStore // nil ⇒ no credentialed connectors this boot
	refresher RefresherFactory       // nil ⇒ no refresh
	metrics   *Metrics               // nil ⇒ no-op
}

var (
	pollMu          sync.RWMutex
	currentPollDeps *pollDeps
)

// RegisterPoll stores the poll deps and registers PollWorkflow with DBOS. MUST
// be called between dbos.NewDBOSContext and dbos.Launch so recovery and the
// schedule reconciler can find the function.
func RegisterPoll(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, runner ConnectorRunner, disposer *Disposer, credStore *SealedCredentialStore, refresher RefresherFactory) {
	var metrics *Metrics
	if disposer != nil {
		metrics = disposer.Metrics
	}
	pollMu.Lock()
	currentPollDeps = &pollDeps{
		pool:      pool,
		queries:   q,
		runner:    runner,
		disposer:  disposer,
		credStore: credStore,
		refresher: refresher,
		metrics:   metrics,
	}
	pollMu.Unlock()
	dbos.RegisterWorkflow(dctx, PollWorkflow, dbos.WithWorkflowName(PollWorkflowName))
}

func loadPollDeps() (*pollDeps, error) {
	pollMu.RLock()
	d := currentPollDeps
	pollMu.RUnlock()
	if d == nil {
		return nil, errors.New("intake.RegisterPoll was not called before the poll ran")
	}
	return d, nil
}

// PollWorkflow is the DBOS scheduled workflow run once per cron tick per enabled
// connector. input.Context carries the connector id (string). It runs in two
// durable, memoized steps:
//
//  1. fetch+ingest — run the connector, ingesting each emission idempotently
//     (ON CONFLICT). Re-running on crash re-fetches and re-ingests safely.
//  2. dispose — load the connector's unprocessed signals and route each through
//     the disposition firewall. The dispose step is idempotent (a task already
//     created for a signal is not duplicated) so a kill mid-poll resumes to the
//     same task set (SC-005).
func PollWorkflow(ctx dbos.DBOSContext, input dbos.ScheduledWorkflowInput) (any, error) {
	d, err := loadPollDeps()
	if err != nil {
		return nil, err
	}
	connectorID, err := connectorIDFromContext(input.Context)
	if err != nil {
		return nil, err
	}

	cfgRow, err := d.queries.GetConnectorConfig(ctx, connectorID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil // connector deleted; a lingering tick is a no-op
		}
		return nil, fmt.Errorf("load connector config: %w", err)
	}
	if !cfgRow.Enabled {
		return nil, nil // disabled between schedule-delete and this tick
	}
	rules := ParseDispositionRules(cfgRow.DispositionRules)

	runCfg := ConnectorConfig{
		ConnectorID:      connectorID,
		ConnectorType:    cfgRow.ConnectorType,
		Filter:           cfgRow.Filter,
		DispositionRules: cfgRow.DispositionRules,
	}
	if d.credStore != nil {
		var refresher TokenRefresher
		if d.refresher != nil {
			refresher = d.refresher(cfgRow.ConnectorType, connectorID)
		}
		runCfg.Credentials = d.credStore.Accessor(connectorID, refresher, time.Now)
	}

	// Step 1: fetch + idempotent ingest.
	_, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (int, error) {
		ingested := 0
		emit := func(sig PotentialTaskSignal) error {
			res, ierr := Ingest(stepCtx, d.pool, sig, cfgRow.ConnectorType, connectorID)
			if ierr != nil {
				return ierr
			}
			if res.Deduped {
				d.metrics.RecordDeduped()
			} else {
				ingested++
				d.metrics.RecordEmitted()
			}
			return nil
		}
		if rerr := d.runner.Run(stepCtx, runCfg, emit); rerr != nil {
			slog.ErrorContext(stepCtx, "intake.poll.run", "connector_id", connectorID, "err", rerr)
			return ingested, rerr
		}
		return ingested, nil
	}, dbos.WithStepName("intake.poll.fetch_ingest."+connectorID.String()))
	if err != nil {
		return nil, err
	}

	// Step 2: dispose unprocessed signals through the firewall.
	_, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (int, error) {
		unprocessed, lerr := d.queries.GetUnprocessedSignals(stepCtx, pgUUID(connectorID))
		if lerr != nil {
			return 0, fmt.Errorf("load unprocessed signals: %w", lerr)
		}
		capState := NewCapCounter(rules.LLMJudgePerPoll)
		disposed := 0
		for _, sig := range unprocessed {
			if _, derr := d.disposer.Dispose(stepCtx, sig, cfgRow.ConnectorType, rules, capState); derr != nil {
				return disposed, fmt.Errorf("dispose signal %s: %w", sig.ID, derr)
			}
			disposed++
		}
		return disposed, nil
	}, dbos.WithStepName("intake.poll.dispose."+connectorID.String()))
	if err != nil {
		return nil, err
	}
	return nil, nil
}

// connectorIDFromContext extracts the connector id from the schedule context,
// which DBOS round-trips as a JSON string.
func connectorIDFromContext(raw any) (uuid.UUID, error) {
	s, ok := raw.(string)
	if !ok {
		return uuid.Nil, fmt.Errorf("intake.poll: schedule context is not a string (got %T)", raw)
	}
	id, err := uuid.Parse(s)
	if err != nil {
		return uuid.Nil, fmt.Errorf("intake.poll: invalid connector id %q: %w", s, err)
	}
	return id, nil
}
