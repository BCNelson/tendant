package lifecycle

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Audit kind values used by Phase 1. Stored in audit_messages.kind (text).
const (
	KindStateTransition    = "state_transition"
	KindStageAdvance       = "stage_advance"
	KindAssignmentCreated  = "assignment_created"
	KindAssignmentResolved = "assignment_resolved"
	KindWorkflowStarted    = "workflow_started"
	KindWorkflowCancelled  = "workflow_cancelled"
)

// SystemActorURI is the principal globalUri used for system-authored audit
// rows (transitions written by the chain workflow / state machine on the
// owner's behalf). Phase 1 has no separate workflow principal yet.
const SystemActorURI = "local://principal/system"

// StateTransitionPayload — kind=state_transition.
type StateTransitionPayload struct {
	From   TaskState `json:"from"`
	To     TaskState `json:"to"`
	Stage  string    `json:"stage,omitempty"`
	Reason string    `json:"reason,omitempty"`
}

// StageAdvancePayload — kind=stage_advance.
type StageAdvancePayload struct {
	From   ChainStage `json:"from"`
	To     ChainStage `json:"to"`
	Reason string     `json:"reason,omitempty"`
}

// AssignmentCreatedPayload — kind=assignment_created.
type AssignmentCreatedPayload struct {
	AssignmentID uuid.UUID  `json:"assignment_id"`
	Stage        ChainStage `json:"stage"`
	Ask          string     `json:"ask"`
}

// AssignmentResolvedPayload — kind=assignment_resolved.
type AssignmentResolvedPayload struct {
	AssignmentID uuid.UUID       `json:"assignment_id"`
	Stage        ChainStage      `json:"stage"`
	Result       json.RawMessage `json:"result,omitempty"`
}

// WorkflowStartedPayload — kind=workflow_started.
type WorkflowStartedPayload struct {
	DbosWorkflowID string `json:"dbos_workflow_id"`
}

// WorkflowCancelledPayload — kind=workflow_cancelled.
type WorkflowCancelledPayload struct {
	Reason string `json:"reason,omitempty"`
}

// WriteAuditMessage inserts one audit_messages row inside the provided tx.
// Caller controls commit. inReplyTo may be uuid.Nil (writes NULL). The
// returned id is generated client-side so callers can chain `in_reply_to`
// without a round trip.
//
// fromPrincipal is the actor globalUri; pass SystemActorURI for workflow-
// authored transitions, or the owner's URI for direct mutations.
func WriteAuditMessage(
	ctx context.Context,
	tx pgx.Tx,
	taskID uuid.UUID,
	fromPrincipal string,
	kind string,
	payload any,
	inReplyTo uuid.UUID,
) (uuid.UUID, error) {
	raw, err := json.Marshal(payload)
	if err != nil {
		return uuid.Nil, fmt.Errorf("marshal audit payload: %w", err)
	}
	id := uuid.New()
	params := db.InsertAuditMessageParams{
		ID:            id,
		TaskID:        taskID,
		FromPrincipal: fromPrincipal,
		Kind:          kind,
		Payload:       raw,
	}
	if inReplyTo != uuid.Nil {
		params.InReplyTo = pgtype.UUID{Bytes: inReplyTo, Valid: true}
	}
	q := db.New(tx)
	row, err := q.InsertAuditMessage(ctx, params)
	if err != nil {
		return uuid.Nil, fmt.Errorf("insert audit row: %w", err)
	}
	return row.ID, nil
}

// latestTransitionID returns the id of the most recent transition-class audit
// row for the task, or uuid.Nil if there is no prior transition (first one
// for this task). Used to wire the in_reply_to spine.
func latestTransitionID(ctx context.Context, q *db.Queries, taskID uuid.UUID) (uuid.UUID, error) {
	row, err := q.LatestTransitionForTask(ctx, taskID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, nil
		}
		return uuid.Nil, fmt.Errorf("latest transition: %w", err)
	}
	return row.ID, nil
}
