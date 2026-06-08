package calibration

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// Demotion trigger labels (recorded in the tool_demoted audit).
const (
	TriggerBadOutcome  = "bad_outcome"
	TriggerCancelTask  = "cancel_task"
	TriggerFlagOutcome = "flag_outcome"
)

// Proposal is an eligible promotion the sweep turns into a PromotionProposal.
type Proposal struct {
	ToolID      uuid.UUID
	ReprTaskID  uuid.UUID
	Fingerprint string
	FromLevel   Level
	ToLevel     Level
	Evidence    lifecycle.PromotionEvidence
}

// Knobs supplies the calibration tunables at read time, so an owner's DB
// override takes effect without a restart. *config.Live satisfies it
// structurally. When an Engine's Knobs is nil it falls back to the boot Config.
type Knobs interface {
	CalibrationMaturation() time.Duration
	CalibrationWindowN() int
	CalibrationRatio() float64
	CalibrationMinSample() int
	CalibrationDemotionDecrement() float64
}

// Engine is the concrete Calibrator. It owns the pool + config + metrics; the
// recording methods ride the caller's tx, the proposal/flag methods open their
// own.
type Engine struct {
	pool    *pgxpool.Pool
	cfg     Config
	metrics *Metrics
	now     func() time.Time

	// Knobs, when set, supplies the tunables live (DB overlay > boot). nil ⇒ cfg.
	Knobs Knobs
}

var _ Calibrator = (*Engine)(nil)

// New constructs an Engine. metrics may be nil (no-op).
func New(pool *pgxpool.Pool, cfg Config, metrics *Metrics) *Engine {
	return &Engine{pool: pool, cfg: cfg, metrics: metrics, now: time.Now}
}

// Config exposes the engine's knobs (read-only) for callers that need the
// maturation window etc. (e.g. /healthz). Reflects live overrides when Knobs is set.
func (e *Engine) Config() Config {
	c := e.cfg
	c.Maturation = e.maturation()
	c.WindowN = e.windowN()
	c.Ratio = e.ratio()
	c.MinSample = e.minSample()
	c.DemotionDecrement = e.demotionDecrement()
	return c
}

// Live knob accessors — read through Knobs when present, else the boot cfg.
func (e *Engine) maturation() time.Duration {
	if e.Knobs != nil {
		return e.Knobs.CalibrationMaturation()
	}
	return e.cfg.Maturation
}
func (e *Engine) windowN() int {
	if e.Knobs != nil {
		return e.Knobs.CalibrationWindowN()
	}
	return e.cfg.WindowN
}
func (e *Engine) ratio() float64 {
	if e.Knobs != nil {
		return e.Knobs.CalibrationRatio()
	}
	return e.cfg.Ratio
}
func (e *Engine) minSample() int {
	if e.Knobs != nil {
		return e.Knobs.CalibrationMinSample()
	}
	return e.cfg.MinSample
}
func (e *Engine) demotionDecrement() float64 {
	if e.Knobs != nil {
		return e.Knobs.CalibrationDemotionDecrement()
	}
	return e.cfg.DemotionDecrement
}

func (e *Engine) clock() time.Time {
	if e.now != nil {
		return e.now()
	}
	return time.Now()
}

// RecordOutcome inserts an inferred-clean outcome with a computed matured_at +
// routine fingerprint, inside the caller's tx. The caller continues to write
// the tool_outcome_recorded audit (the chain is preserved).
func (e *Engine) RecordOutcome(ctx context.Context, tx pgx.Tx, in OutcomeInput) (db.ToolOutcome, error) {
	return e.insertOutcome(ctx, tx, in, db.ToolOutcomeKindClean)
}

// RecordBad inserts a bad outcome AND reflexively demotes, inside the caller's
// tx (the dispatch-error path). The caller still writes the
// tool_outcome_recorded audit and then propagates the dispatch error.
func (e *Engine) RecordBad(ctx context.Context, tx pgx.Tx, in OutcomeInput) (db.ToolOutcome, error) {
	out, err := e.insertOutcome(ctx, tx, in, db.ToolOutcomeKindBad)
	if err != nil {
		return db.ToolOutcome{}, err
	}
	fp := Fingerprint(in.ToolGlobalURI, in.Payload)
	if _, derr := e.demote(ctx, tx, in.ToolID, in.TaskID, fp, TriggerBadOutcome); derr != nil {
		return db.ToolOutcome{}, derr
	}
	return out, nil
}

func (e *Engine) insertOutcome(ctx context.Context, tx pgx.Tx, in OutcomeInput, kind db.ToolOutcomeKind) (db.ToolOutcome, error) {
	at := in.At
	if at.IsZero() {
		at = e.clock()
	}
	fp := Fingerprint(in.ToolGlobalURI, in.Payload)
	matured := pgtype.Timestamptz{Time: at.Add(e.maturation()), Valid: true}
	q := db.New(tx)
	out, err := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
		ToolID:             in.ToolID,
		TaskID:             in.TaskID,
		Outcome:            kind,
		MaturedAt:          matured,
		RoutineFingerprint: &fp,
	})
	if err != nil {
		return db.ToolOutcome{}, fmt.Errorf("insert tool_outcome: %w", err)
	}
	return out, nil
}

// demote applies one reflexive demotion inside tx: lock the tool, slide the
// score (clamped at baseline), revoke the affected grant (or all grants when
// fingerprint is empty), write the tool_demoted audit, and withdraw any open
// promotion proposal for the tool (FR-014). Returns the new score.
func (e *Engine) demote(ctx context.Context, tx pgx.Tx, toolID, taskID uuid.UUID, fingerprint, trigger string) (float64, error) {
	q := db.New(tx)
	tool, err := q.GetToolForUpdate(ctx, toolID)
	if err != nil {
		return 0, fmt.Errorf("lock tool %s: %w", toolID, err)
	}
	oldScore := tool.TrustScore
	newScore := Demote(oldScore, e.demotionDecrement())

	if _, err := q.SetTrustScore(ctx, db.SetTrustScoreParams{
		ID:         toolID,
		TrustScore: newScore,
		Rung:       string(Band(newScore)),
	}); err != nil {
		return 0, fmt.Errorf("set trust score: %w", err)
	}

	revokedAll := fingerprint == ""
	if revokedAll {
		if err := q.RevokeAllGrantsForTool(ctx, toolID); err != nil {
			return 0, fmt.Errorf("revoke all grants: %w", err)
		}
	} else {
		if err := q.RevokeRoutineGrant(ctx, db.RevokeRoutineGrantParams{
			ToolID:             toolID,
			RoutineFingerprint: fingerprint,
		}); err != nil {
			return 0, fmt.Errorf("revoke grant: %w", err)
		}
	}

	parent, err := latestTransitionInTx(ctx, tx, taskID)
	if err != nil {
		return 0, err
	}
	if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
		lifecycle.KindToolDemoted,
		lifecycle.ToolDemotedPayload{
			ToolID:             toolID,
			Trigger:            trigger,
			OldScore:           oldScore,
			NewScore:           newScore,
			RevokedFingerprint: fingerprint,
			RevokedAll:         revokedAll,
		},
		parent,
	); err != nil {
		return 0, err
	}

	// Withdraw any open promotion proposal for this tool (a demotion invalidates
	// in-flight promotions).
	open, err := q.OpenPromotionProposalsForTool(ctx, pgtype.UUID{Bytes: toolID, Valid: true})
	if err != nil {
		return 0, fmt.Errorf("list open proposals: %w", err)
	}
	for _, row := range open {
		if _, err := q.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
			ID:         row.ID,
			ResolvedAt: pgtype.Timestamptz{Time: e.clock(), Valid: true},
			Resolution: []byte(`{"accepted":false,"reason":"withdrawn: tool demoted"}`),
		}); err != nil {
			return 0, fmt.Errorf("withdraw proposal %s: %w", row.ID, err)
		}
	}

	if e.metrics != nil {
		e.metrics.RecordDemotion()
	}
	return newScore, nil
}

// FlagBad is the owner flagOutcome path: record a bad outcome for the tool's
// most-recent routine under the task + demote, in one tx. Returns the updated
// Tool.
func (e *Engine) FlagBad(ctx context.Context, taskID, toolID uuid.UUID, reason string) (db.Tool, error) {
	var updated db.Tool
	err := pgx.BeginFunc(ctx, e.pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		// The "affected routine" = the fingerprint of the latest outcome the
		// tool recorded under this task (nil → revoke all grants).
		fpPtr, ferr := q.LatestOutcomeForToolTask(ctx, db.LatestOutcomeForToolTaskParams{
			ToolID: toolID,
			TaskID: taskID,
		})
		if ferr != nil && !errors.Is(ferr, pgx.ErrNoRows) {
			return fmt.Errorf("latest outcome fingerprint: %w", ferr)
		}
		fp := ""
		if fpPtr != nil {
			fp = *fpPtr
		}

		at := e.clock()
		matured := pgtype.Timestamptz{Time: at.Add(e.maturation()), Valid: true}
		var fpInsert *string
		if fp != "" {
			fpInsert = &fp
		}
		out, oerr := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
			ToolID:             toolID,
			TaskID:             taskID,
			Outcome:            db.ToolOutcomeKindBad,
			MaturedAt:          matured,
			RoutineFingerprint: fpInsert,
		})
		if oerr != nil {
			return fmt.Errorf("insert flagged outcome: %w", oerr)
		}

		parent, perr := latestTransitionInTx(ctx, tx, taskID)
		if perr != nil {
			return perr
		}
		if _, aerr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindOutcomeFlagged,
			lifecycle.OutcomeFlaggedPayload{ToolID: toolID, OutcomeID: out.ID, Reason: reason},
			parent,
		); aerr != nil {
			return aerr
		}

		if _, derr := e.demote(ctx, tx, toolID, taskID, fp, TriggerFlagOutcome); derr != nil {
			return derr
		}

		t, terr := q.GetToolByID(ctx, toolID)
		if terr != nil {
			return fmt.Errorf("reload tool: %w", terr)
		}
		updated = t
		return nil
	})
	return updated, err
}

// DemoteForCancel demotes every tool that acted under a cancelled task (revoking
// all of each tool's grants, since the offending routine is unspecified). Opens
// its own tx (the cancel cleanup runs in a separate tx).
func (e *Engine) DemoteForCancel(ctx context.Context, taskID uuid.UUID) error {
	return pgx.BeginFunc(ctx, e.pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		toolIDs, err := q.ToolsActedUnderTask(ctx, taskID)
		if err != nil {
			return fmt.Errorf("tools acted under task: %w", err)
		}
		for _, toolID := range toolIDs {
			if _, derr := e.demote(ctx, tx, toolID, taskID, "", TriggerCancelTask); derr != nil {
				return derr
			}
		}
		return nil
	})
}

// MaybeProposePromotion evaluates a single (tool, routine) group. Returns a
// Proposal when eligible; nil when not (already granted, open proposal,
// decline-cooldown, below min-sample, or below ratio).
func (e *Engine) MaybeProposePromotion(ctx context.Context, toolID uuid.UUID, fingerprint string) (*Proposal, error) {
	q := db.New(e.pool)

	// Already granted for this routine → nothing to propose.
	granted, err := q.LiveGrantExists(ctx, db.LiveGrantExistsParams{ToolID: toolID, RoutineFingerprint: fingerprint})
	if err != nil {
		return nil, fmt.Errorf("live grant exists: %w", err)
	}
	if granted {
		return nil, nil
	}

	// An open proposal already covers this routine.
	if _, err := q.OpenPromotionProposal(ctx, db.OpenPromotionProposalParams{
		ToolID:             pgtype.UUID{Bytes: toolID, Valid: true},
		RoutineFingerprint: fingerprint,
	}); err == nil {
		return nil, nil
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("open proposal lookup: %w", err)
	}

	// Eligibility: ratio over the last N matured outcomes.
	ratioRow, err := q.MaturedCleanRatioByRoutine(ctx, db.MaturedCleanRatioByRoutineParams{
		ToolID:             toolID,
		RoutineFingerprint: &fingerprint,
		WindowN:            int32(e.windowN()),
	})
	if err != nil {
		return nil, fmt.Errorf("matured-clean ratio: %w", err)
	}
	total := int(ratioRow.Total)
	clean := int(ratioRow.Clean)
	if total < e.minSample() {
		return nil, nil
	}
	if float64(clean)/float64(total) < e.ratio() {
		return nil, nil
	}

	// Representative task = most-recent matured-clean outcome's task.
	repr, err := q.LatestMaturedOutcomeForRoutine(ctx, db.LatestMaturedOutcomeForRoutineParams{
		ToolID:             toolID,
		RoutineFingerprint: &fingerprint,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("representative task: %w", err)
	}

	// Decline-cooldown: skip if there was a decline with no NEW matured outcome
	// since (the latest matured-clean outcome predates the decline).
	declinedAt, err := q.LatestDeclinedPromotionAt(ctx, db.LatestDeclinedPromotionAtParams{
		ToolID:             pgtype.UUID{Bytes: toolID, Valid: true},
		RoutineFingerprint: fingerprint,
	})
	if err == nil && declinedAt.Valid && declinedAt.Time.After(repr.At) {
		return nil, nil
	} else if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("decline cooldown lookup: %w", err)
	}

	tool, err := q.GetToolByID(ctx, toolID)
	if err != nil {
		return nil, fmt.Errorf("load tool: %w", err)
	}

	return &Proposal{
		ToolID:      toolID,
		ReprTaskID:  repr.TaskID,
		Fingerprint: fingerprint,
		FromLevel:   Band(tool.TrustScore),
		ToLevel:     LevelExecuteAuto,
		Evidence: lifecycle.PromotionEvidence{
			Routine:            routineLabel(tool.GlobalUri, fingerprint),
			RoutineFingerprint: fingerprint,
			WindowN:            e.windowN(),
			MaturedClean:       clean,
			Ratio:              float64(clean) / float64(total),
			MinSample:          e.minSample(),
		},
	}, nil
}

// routineLabel renders a short legible routine name for the evidence block.
func routineLabel(toolGlobalURI, fingerprint string) string {
	short := fingerprint
	if len(short) > 8 {
		short = short[:8]
	}
	return fmt.Sprintf("%s → routine %s", toolGlobalURI, short)
}

// latestTransitionInTx returns the latest transition audit id for a task, or
// uuid.Nil if none (first audit on the task).
func latestTransitionInTx(ctx context.Context, tx pgx.Tx, taskID uuid.UUID) (uuid.UUID, error) {
	q := db.New(tx)
	row, err := q.LatestTransitionForTask(ctx, taskID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, nil
		}
		return uuid.Nil, fmt.Errorf("latest transition: %w", err)
	}
	return row.ID, nil
}
