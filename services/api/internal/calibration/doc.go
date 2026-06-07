// Package calibration is the Phase 8 trust-loop subsystem. One Calibrator reads
// the audit DAG on both edges and drives the asymmetric, per-tool earned-autonomy
// ratchet:
//
//   - Inferred-clean recording + maturation: every clean tool_outcomes row is
//     stamped matured_at = at + window at insert and carries a routine
//     fingerprint so promotion/auto-approval are scoped per routine.
//   - Owner-gated promotion: a DBOS-scheduled sweep finds (tool, routine) groups
//     whose matured-clean ratio over the last N outcomes clears a threshold and
//     emits a PromotionProposal. The owner accepts via respondToPromotion; only
//     then does the per-tool trust_score rise into the EXECUTE_AUTO band and the
//     routine get a live grant.
//   - Reflexive demotion: a bad outcome, an owner cancelTask, or flagOutcome
//     automatically decrements the score (clamped at baseline) and revokes the
//     routine's grant — no proposal, no approval.
//   - Intake half: the subsystem reads dismissals to tighten effective
//     disposition thresholds and feeds dismissal reasons to the triage seam as
//     labeled evidence.
//
// The gate stays pure: the routine-grant lookup is an injected seam
// (gate.RoutineGrantLookup), mirroring gate.PrincipalLookup. Promotion is the
// only autonomy-raising path and is owner-only (Constitution IV); demotion is
// automatic (Constitution V — halts, never rolls back). The floor is always
// evaluated before the band (Constitution III).
package calibration

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// OutcomeInput is the shape both the clean and bad recording paths pass in. The
// caller (toolflow) supplies the tx so recording rides the same atomic write as
// the audit chain.
type OutcomeInput struct {
	ToolID        uuid.UUID
	TaskID        uuid.UUID
	ToolGlobalURI string
	Payload       json.RawMessage
	At            time.Time
}

// Calibrator is the one subsystem façade. RecordOutcome/RecordBad ride the
// caller's transaction (the toolflow dispatch step); MaybeProposePromotion and
// FlagBad open their own.
type Calibrator interface {
	// RecordOutcome inserts an inferred-clean tool_outcomes row with a computed
	// matured_at + routine fingerprint, inside the caller's tx.
	RecordOutcome(ctx context.Context, tx pgx.Tx, in OutcomeInput) (db.ToolOutcome, error)
	// RecordBad inserts a bad tool_outcomes row AND reflexively demotes, inside
	// the caller's tx (the system/dispatch-error path).
	RecordBad(ctx context.Context, tx pgx.Tx, in OutcomeInput) (db.ToolOutcome, error)
	// MaybeProposePromotion evaluates a single (tool, routine) group and returns
	// a proposal when eligible (nil otherwise).
	MaybeProposePromotion(ctx context.Context, toolID uuid.UUID, fingerprint string) (*Proposal, error)
	// FlagBad is the owner flagOutcome path: records a bad outcome + demotes in
	// one tx (its own).
	FlagBad(ctx context.Context, taskID, toolID uuid.UUID, reason string) (db.Tool, error)
}
