package inbox

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"sync"

	"github.com/dbos-inc/dbos-transact-golang/dbos"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// The first-class inbox_messages table (migration 00018) is kept in lock-step
// with its three source tables by the trg_inbox_project triggers, which fire
// inside the mutating transaction — so every committed source-row write
// atomically projects its inbox row. This sweep is defense-in-depth: it repairs
// (and, by its non-zero result, ALARMS on) any projection a write managed to
// bypass — a disabled/dropped trigger, a bulk COPY/restore, or a trigger-logic
// regression. It mirrors calibration:sweep (a single DB-backed DBOS schedule).

// ReconcileWorkflowName is the DBOS workflow name for the projection reconcile.
// Stable across restarts so recovery + the schedule reconciler find the function.
const ReconcileWorkflowName = "tendant.inbox.reconcile"

// ReconcileScheduleName is the single DBOS schedule name for the reconcile sweep.
const ReconcileScheduleName = "inbox:reconcile"

// DefaultReconcileCron runs the sweep every 15 minutes — frequent enough to
// catch drift quickly, cheap enough to be a NOT EXISTS scan most ticks return 0.
const DefaultReconcileCron = "*/15 * * * *"

// reconcileDeps closes over the sweep's runtime dependencies, set once by
// RegisterReconcile at boot (mirrors calibration.RegisterSweep).
type reconcileDeps struct {
	queries *db.Queries
}

var (
	reconcileMu          sync.RWMutex
	currentReconcileDeps *reconcileDeps
)

// RegisterReconcile stores the sweep deps and registers ReconcileWorkflow with
// DBOS. MUST be called between dbos.NewDBOSContext and dbos.Launch.
func RegisterReconcile(dctx dbos.DBOSContext, q *db.Queries) {
	reconcileMu.Lock()
	currentReconcileDeps = &reconcileDeps{queries: q}
	reconcileMu.Unlock()
	dbos.RegisterWorkflow(dctx, ReconcileWorkflow, dbos.WithWorkflowName(ReconcileWorkflowName))
}

func loadReconcileDeps() (*reconcileDeps, error) {
	reconcileMu.RLock()
	d := currentReconcileDeps
	reconcileMu.RUnlock()
	if d == nil {
		return nil, errors.New("inbox.RegisterReconcile was not called before the reconcile ran")
	}
	return d, nil
}

// CreateReconcileSchedule registers the DBOS dynamic schedule for the sweep. cron
// must be non-blank. DB-backed + crash-recovered on Launch; idempotent across
// boots (skips when the schedule already exists, like calibration's).
func CreateReconcileSchedule(dctx dbos.DBOSContext, cron string) error {
	if cron == "" {
		return fmt.Errorf("inbox: a non-blank reconcile cron schedule is required")
	}
	existing, err := dbos.GetSchedule(dctx, ReconcileScheduleName)
	if err != nil {
		return fmt.Errorf("inbox: check existing reconcile schedule: %w", err)
	}
	if existing != nil {
		return nil
	}
	return dbos.CreateSchedule(dctx, ReconcileWorkflow, dbos.CreateScheduleRequest{
		ScheduleName: ReconcileScheduleName,
		Schedule:     cron,
	})
}

// ReconcileWorkflow is the DBOS scheduled workflow run once per cron tick. It
// inserts any missing inbox_messages projection (idempotent) and logs the count;
// a non-zero count is logged at WARN because it means a trigger did not fire.
func ReconcileWorkflow(ctx dbos.DBOSContext, _ dbos.ScheduledWorkflowInput) (any, error) {
	d, err := loadReconcileDeps()
	if err != nil {
		return nil, err
	}
	repaired, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (int64, error) {
		return Reconcile(stepCtx, d.queries)
	}, dbos.WithStepName("inbox.reconcile"))
	if err != nil {
		return nil, err
	}
	if repaired > 0 {
		slog.Warn("inbox.reconcile repaired missing projections — a projection trigger may not be firing",
			"repaired", repaired)
	} else {
		slog.Debug("inbox.reconcile clean", "repaired", 0)
	}
	return repaired, nil
}

// Reconcile inserts any missing inbox_messages projection for the three source
// tables and returns the number of rows repaired. Exposed (not just the
// workflow) so it can be invoked directly in tests and from a future
// owner-triggered "rebuild inbox" maintenance action.
func Reconcile(ctx context.Context, q *db.Queries) (int64, error) {
	repaired, err := q.ReconcileInboxMessages(ctx)
	if err != nil {
		return 0, fmt.Errorf("reconcile inbox messages: %w", err)
	}
	return repaired, nil
}
