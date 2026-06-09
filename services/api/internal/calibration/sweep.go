package calibration

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// SweepWorkflowName is the DBOS workflow name for the promotion sweep. Stable
// across restarts so recovery and the schedule reconciler find the function.
const SweepWorkflowName = "tendant.calibration.sweep"

// ScheduleName is the single DBOS schedule name for the sweep.
const ScheduleName = "calibration:sweep"

// proposalPayload is the JSON frozen into pending_decisions.payload for a
// promotion_proposal. The PromotionProposal resolvers read these fields; the
// top-level routine_fingerprint backs the OpenPromotionProposal dedupe query.
type proposalPayload struct {
	FromLevel          string                      `json:"from_level"`
	ToLevel            string                      `json:"to_level"`
	RoutineFingerprint string                      `json:"routine_fingerprint"`
	Evidence           lifecycle.PromotionEvidence `json:"evidence"`
}

// sweepDeps closes over the sweep's runtime dependencies, set once by
// RegisterSweep at boot (mirrors intake.RegisterPoll).
type sweepDeps struct {
	pool     *pgxpool.Pool
	queries  *db.Queries
	engine   *Engine
	metrics  *Metrics
	push     chain.PushEnqueuer // nil ⇒ no push (inbox NOTIFY still surfaces it)
	ownerURI string
}

var (
	sweepMu          sync.RWMutex
	currentSweepDeps *sweepDeps
)

// RegisterSweep stores the sweep deps and registers SweepWorkflow with DBOS.
// MUST be called between dbos.NewDBOSContext and dbos.Launch.
func RegisterSweep(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, engine *Engine, metrics *Metrics, push chain.PushEnqueuer, ownerURI string) {
	sweepMu.Lock()
	currentSweepDeps = &sweepDeps{pool: pool, queries: q, engine: engine, metrics: metrics, push: push, ownerURI: ownerURI}
	sweepMu.Unlock()
	dbos.RegisterWorkflow(dctx, SweepWorkflow, dbos.WithWorkflowName(SweepWorkflowName))
}

func loadSweepDeps() (*sweepDeps, error) {
	sweepMu.RLock()
	d := currentSweepDeps
	sweepMu.RUnlock()
	if d == nil {
		return nil, errors.New("calibration.RegisterSweep was not called before the sweep ran")
	}
	return d, nil
}

// CreateSchedule registers the DBOS dynamic schedule for the sweep. cron must be
// non-blank. DB-backed + crash-recovered on Launch.
func CreateSchedule(dctx dbos.DBOSContext, cron string) error {
	if cron == "" {
		return fmt.Errorf("calibration: a non-blank cron schedule is required")
	}
	// Idempotent: the sweep schedule persists in workflow_schedules across boots,
	// and dbos.CreateSchedule errors on a duplicate schedule_name, so skip when
	// it already exists rather than failing every restart.
	existing, err := dbos.GetSchedule(dctx, ScheduleName)
	if err != nil {
		return fmt.Errorf("calibration: check existing sweep schedule: %w", err)
	}
	if existing != nil {
		return nil
	}
	return dbos.CreateSchedule(dctx, SweepWorkflow, dbos.CreateScheduleRequest{
		ScheduleName: ScheduleName,
		Schedule:     cron,
	})
}

// SweepWorkflow is the DBOS scheduled workflow run once per cron tick. It scans
// candidate (tool, routine) groups and emits a PromotionProposal for each that
// MaybeProposePromotion deems eligible. Idempotent: an open proposal or an
// existing grant short-circuits re-emission, so a kill mid-sweep resumes safely.
func SweepWorkflow(ctx dbos.DBOSContext, _ dbos.ScheduledWorkflowInput) (any, error) {
	d, err := loadSweepDeps()
	if err != nil {
		return nil, err
	}

	_, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (int, error) {
		candidates, lerr := d.queries.CandidateRoutinesForSweep(stepCtx)
		if lerr != nil {
			return 0, fmt.Errorf("candidate routines: %w", lerr)
		}
		emitted := 0
		for _, c := range candidates {
			if c.RoutineFingerprint == nil {
				continue
			}
			d.metrics.RecordOutcomeMatured()
			prop, perr := d.engine.MaybeProposePromotion(stepCtx, c.ToolID, *c.RoutineFingerprint)
			if perr != nil {
				slog.ErrorContext(stepCtx, "calibration.sweep.eval", "tool_id", c.ToolID, "err", perr)
				return emitted, perr
			}
			if prop == nil {
				continue
			}
			if eerr := d.emitProposal(stepCtx, prop); eerr != nil {
				return emitted, eerr
			}
			emitted++
		}
		// Refresh the open-proposals gauge.
		if open, gerr := d.queries.CountOpenPromotionProposals(stepCtx); gerr == nil {
			d.metrics.SetOpenProposals(int(open))
		}
		return emitted, nil
	}, dbos.WithStepName("calibration.sweep"))
	if err != nil {
		return nil, err
	}
	return nil, nil
}

// emitProposal writes the pending_decisions promotion_proposal row + the
// promotion_proposed audit, refreshes metrics, and enqueues a push (if wired).
func (d *sweepDeps) emitProposal(ctx context.Context, prop *Proposal) error {
	decisionID := uuid.New()
	payload, err := json.Marshal(proposalPayload{
		FromLevel:          string(prop.FromLevel),
		ToLevel:            string(prop.ToLevel),
		RoutineFingerprint: prop.Fingerprint,
		Evidence:           prop.Evidence,
	})
	if err != nil {
		return fmt.Errorf("marshal proposal payload: %w", err)
	}

	if _, err := d.queries.InsertPromotionProposal(ctx, db.InsertPromotionProposalParams{
		ID:      decisionID,
		TaskID:  prop.ReprTaskID,
		ToolID:  pgtype.UUID{Bytes: prop.ToolID, Valid: true},
		Payload: payload,
	}); err != nil {
		return fmt.Errorf("insert promotion proposal: %w", err)
	}

	// promotion_proposed audit on the representative task.
	if err := pgxAudit(ctx, d.pool, prop.ReprTaskID, lifecycle.KindPromotionProposed,
		lifecycle.PromotionProposedPayload{
			ToolID:     prop.ToolID,
			DecisionID: decisionID,
			FromLevel:  string(prop.FromLevel),
			ToLevel:    string(prop.ToLevel),
			Evidence:   prop.Evidence,
		}); err != nil {
		return err
	}

	d.metrics.RecordProposalEmitted()

	if d.push != nil {
		_ = d.push.EnqueuePush(ctx, chain.PushJobPayload{
			TaskID:             prop.ReprTaskID,
			RecipientGlobalURI: d.ownerURI,
			DeepLinkID:         decisionID.String(),
			Title:              "A routine is ready for autonomy",
		})
	}
	return nil
}
