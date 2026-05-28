package lifecycle

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Transition writes a state change + one audit row in the same tx (FR-002).
// Returns the id of the new audit row so callers can use it as in_reply_to
// for a downstream chained row (assignment_resolved, workflow_cancelled).
//
// Pure over a single pgx.Tx — caller controls commit. Rejects with
// *ErrIllegalTransition when (from, to) is not in the legal-edges table.
//
// `reason` is recorded in the audit payload; stage (optional) is the chain
// stage at which the transition happens (e.g., EXPANSION when ACCEPTED→EXECUTING).
func Transition(
	ctx context.Context,
	tx pgx.Tx,
	taskID uuid.UUID,
	from, to TaskState,
	reason string,
	stage ChainStage, // optional; pass "" if not relevant
) (uuid.UUID, error) {
	if !IsLegal(from, to) {
		return uuid.Nil, &ErrIllegalTransition{From: from, To: to}
	}
	q := db.New(tx)

	// Apply the state write.
	if _, err := q.UpdateTaskState(ctx, db.UpdateTaskStateParams{
		ID:    taskID,
		State: to,
	}); err != nil {
		return uuid.Nil, fmt.Errorf("update task state: %w", err)
	}

	parent, err := latestTransitionID(ctx, q, taskID)
	if err != nil {
		return uuid.Nil, err
	}

	payload := StateTransitionPayload{
		From:   from,
		To:     to,
		Reason: reason,
	}
	if stage != "" {
		payload.Stage = string(stage)
	}
	return WriteAuditMessage(ctx, tx, taskID, SystemActorURI, KindStateTransition, payload, parent)
}

// AdvanceStage writes a stage change + one audit row in the same tx (FR-004
// + FR-002). Returns the new audit row id for in_reply_to chaining.
//
// AdvanceStage does not consult the legal-state-edges table — chain stages
// advance monotonically (CREATION → TRIAGE → … → COMPLETION); the chain
// workflow itself is the gate on which advance to perform.
func AdvanceStage(
	ctx context.Context,
	tx pgx.Tx,
	taskID uuid.UUID,
	from, to ChainStage,
	reason string,
) (uuid.UUID, error) {
	q := db.New(tx)

	if _, err := q.UpdateTaskStage(ctx, db.UpdateTaskStageParams{
		ID:           taskID,
		CurrentStage: to,
	}); err != nil {
		return uuid.Nil, fmt.Errorf("update task stage: %w", err)
	}

	parent, err := latestTransitionID(ctx, q, taskID)
	if err != nil {
		return uuid.Nil, err
	}

	payload := StageAdvancePayload{
		From:   from,
		To:     to,
		Reason: reason,
	}
	return WriteAuditMessage(ctx, tx, taskID, SystemActorURI, KindStageAdvance, payload, parent)
}
