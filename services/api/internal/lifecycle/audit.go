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

// Audit kind values used by Phase 1+. Stored in audit_messages.kind (text).
const (
	KindStateTransition    = "state_transition"
	KindStageAdvance       = "stage_advance"
	KindAssignmentCreated  = "assignment_created"
	KindAssignmentResolved = "assignment_resolved"
	KindWorkflowStarted    = "workflow_started"
	KindWorkflowCancelled  = "workflow_cancelled"

	// Phase 3 (gate + first tool).
	KindToolCallComposed    = "tool_call_composed"
	KindGateVerdict         = "gate_verdict"
	KindDecisionResolved    = "decision_resolved"
	KindToolDispatched      = "tool_dispatched"
	KindToolOutcomeRecorded = "tool_outcome_recorded"

	// Phase 4 (overseer + owner tuning).
	KindOverseerEvaluated           = "overseer_evaluated"
	KindOverseerInstructionsChanged = "overseer_instructions_changed"
	KindToolPermissionsChanged      = "tool_permissions_changed"
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

// ToolCallComposedPayload — kind=tool_call_composed. Recorded the moment a
// caller composes a tool call (before the gate sees it).
type ToolCallComposedPayload struct {
	ToolID        uuid.UUID       `json:"tool_id"`
	ToolGlobalURI string          `json:"tool_global_uri"`
	Payload       json.RawMessage `json:"payload"`
	ComposedBy    string          `json:"composed_by"` // principal globalUri
}

// GateVerdictPayload — kind=gate_verdict. The verdict returned by the gate
// for the composed call; used to audit floor trips and (in later phases)
// script / overseer outcomes.
type GateVerdictPayload struct {
	ToolID   uuid.UUID       `json:"tool_id"`
	Decision string          `json:"decision"`
	Context  json.RawMessage `json:"context,omitempty"`
}

// DecisionResolvedPayload — kind=decision_resolved. The human's response
// to an ApprovalRequest. Approved/reason are owner-supplied; ResolvedBy is
// the principal globalUri.
type DecisionResolvedPayload struct {
	DecisionID uuid.UUID `json:"decision_id"`
	Approved   bool      `json:"approved"`
	Reason     string    `json:"reason,omitempty"`
	ResolvedBy string    `json:"resolved_by"`
}

// ToolDispatchedPayload — kind=tool_dispatched. Recorded after the tool's
// Execute returns, before the outcome row lands.
type ToolDispatchedPayload struct {
	ToolID   uuid.UUID       `json:"tool_id"`
	Provider string          `json:"provider"`
	Detail   json.RawMessage `json:"detail,omitempty"`
	Error    string          `json:"error,omitempty"`
}

// ToolOutcomeRecordedPayload — kind=tool_outcome_recorded.
type ToolOutcomeRecordedPayload struct {
	ToolID    uuid.UUID `json:"tool_id"`
	OutcomeID uuid.UUID `json:"outcome_id"`
	Outcome   string    `json:"outcome"` // "clean" | "bad"
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
