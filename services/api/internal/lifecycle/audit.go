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

	// Phase 5 (gate scripts + owner rules). Scope annotations refer to the
	// migration-00005 CHECK (audit_task_required_unless_owner_scope): the four
	// owner-scope kinds may carry task_id = NULL; the two task-scope kinds MUST
	// carry a non-NULL task_id like every Phase-0 – Phase-4 kind.
	KindGateScriptEvaluated = "gate_script_evaluated" // task-scope
	KindGateScriptSkipped   = "gate_script_skipped"   // task-scope
	KindGateScriptRejected  = "gate_script_rejected"  // owner-scope (task_id NULL)
	KindGateScriptAttached  = "gate_script_attached"  // owner-scope (task_id NULL)
	KindGateScriptDisabled  = "gate_script_disabled"  // owner-scope (task_id NULL)
	KindOwnerRuleSet        = "owner_rule_set"        // owner-scope (task_id NULL)

	// Phase 6: agent layer audit kinds.
	KindAgentRunStarted      = "agent_run_started"
	KindAgentRunFinished     = "agent_run_finished"
	KindRouterSelected       = "router_selected"
	KindAgentCallRefused     = "agent_call_refused"
	KindBudgetExhausted      = "budget_exhausted"
	KindMaxIterationsReached = "max_iterations_reached"
	KindAgentHandoff         = "agent_handoff" // task-scope: agent called handoff_to_human

	// Phase 7 (the intake edge). Scope annotations refer to the migration-00006
	// CHECK (audit_task_required_unless_owner_scope, extended): the three
	// pre-task kinds may carry task_id = NULL; the three task-scope kinds MUST
	// carry a non-NULL task_id.
	KindSignalEmitted      = "signal_emitted"       // pre-task (task_id NULL)
	KindSignalDeduped      = "signal_deduped"       // pre-task (task_id NULL)
	KindLLMJudgeCapped     = "llm_judge_capped"     // pre-task (task_id NULL)
	KindDispositionApplied = "disposition_applied"  // task-scope
	KindIntakeAutoAccepted = "intake_auto_accepted" // task-scope
	KindLLMJudgeInvoked    = "llm_judge_invoked"    // task-scope

	// Phase 8 (calibration & the earned-autonomy ratchet). All four are
	// task-scoped (a non-NULL task_id) — no CHECK-allowlist change. Promotion
	// kinds carry the representative task; demotion/flag kinds carry the task
	// the tool acted under.
	KindOutcomeFlagged     = "outcome_flagged"     // task-scope
	KindToolDemoted        = "tool_demoted"        // task-scope
	KindPromotionProposed  = "promotion_proposed"  // task-scope (representative)
	KindPromotionResponded = "promotion_responded" // task-scope (representative)

	// Post-completion feedback (conversational). All task-scoped (a completed
	// task always has a real task_id) — no CHECK-allowlist change.
	KindFeedbackOpened           = "feedback_opened"            // task-scope: agent opened the conversation
	KindFeedbackSubmitted        = "feedback_submitted"         // task-scope: owner accepted/dismissed (carries rating)
	KindAgentGuidanceApplied     = "agent_guidance_applied"     // task-scope: owner accepted a verbatim guidance note
	KindFeedbackContextConsulted = "feedback_context_consulted" // task-scope: feedback agent read task context via a tool

	// HITL timeout overhaul: explicit outcomes for an expired human wait. Both
	// are task-scoped (every human wait belongs to a task), so the migration-
	// 00006 CHECK allowlist is unchanged.
	KindDecisionExpired      = "decision_expired"       // task-scope: a pending_decisions wait timed out (approval/feedback/question)
	KindStageTimeoutRerouted = "stage_timeout_rerouted" // task-scope: a human stage slot timed out and was re-routed/escalated
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
	Outcome   string    `json:"outcome"` // "clean" | "bad" | "denied_by_script"
}

// --- Phase 5 (gate scripts + owner rules) audit payloads. -------------------

// GateScriptHostError is the optional host-error context attached to a
// fail_closed_host_error evaluation (FR-035).
type GateScriptHostError struct {
	Module   string `json:"module"`
	Name     string `json:"name"`
	SQLState string `json:"sqlstate,omitempty"`
}

// GateScriptEvidence is the evidence block recorded with a completed run.
type GateScriptEvidence struct {
	Summary          string               `json:"summary"`
	ConsideredFields []string             `json:"considered_fields"`
	Hostcalls        []string             `json:"hostcalls"`
	HostError        *GateScriptHostError `json:"host_error,omitempty"`
}

// GateScriptEvaluatedPayload — kind=gate_script_evaluated (task-scope).
// Written exactly once per *completed* run (FR-035). verdict is one of the
// four terminal verdicts or a fail_closed_* variant.
type GateScriptEvaluatedPayload struct {
	Verdict         string             `json:"verdict"`
	ScriptID        uuid.UUID          `json:"script_id"`
	ScriptVersion   int                `json:"script_version"`
	ManifestHash    string             `json:"manifest_hash"`
	Evidence        GateScriptEvidence `json:"evidence"`
	DurationMs      int                `json:"duration_ms"`
	PeakMemoryPages int                `json:"peak_memory_pages"`
	RanToCompletion bool               `json:"ran_to_completion"`
	FailureReason   string             `json:"failure_reason"`
}

// GateScriptSkippedPayload — kind=gate_script_skipped (task-scope). Written
// when the script slot fired on a tool whose active_script_version was
// cleared mid-flight.
type GateScriptSkippedPayload struct {
	Reason                string `json:"reason"`
	PreviousActiveVersion int    `json:"previous_active_version"`
}

// GateScriptRejectedPayload — kind=gate_script_rejected (owner-scope,
// task_id NULL). Written when static validation rejects an upload (FR-036).
type GateScriptRejectedPayload struct {
	Reason               string          `json:"reason"`
	ManifestHash         string          `json:"manifest_hash"`
	ToolID               uuid.UUID       `json:"tool_id"`
	AttemptedByPrincipal string          `json:"attempted_by_principal"`
	Detail               json.RawMessage `json:"detail,omitempty"`
}

// GateScriptAttachedPayload — kind=gate_script_attached (owner-scope,
// task_id NULL). Written on a successful attach (FR-037).
type GateScriptAttachedPayload struct {
	ScriptID              uuid.UUID `json:"script_id"`
	ToolID                uuid.UUID `json:"tool_id"`
	Version               int       `json:"version"`
	Tier                  string    `json:"tier"`
	ManifestHash          string    `json:"manifest_hash"`
	SourceHash            *string   `json:"source_hash"`
	PreviousActiveVersion *int      `json:"previous_active_version"`
}

// GateScriptDisabledPayload — kind=gate_script_disabled (owner-scope,
// task_id NULL).
type GateScriptDisabledPayload struct {
	ToolID             uuid.UUID `json:"tool_id"`
	PriorActiveVersion int       `json:"prior_active_version"`
}

// OwnerRuleSetPayload — kind=owner_rule_set (owner-scope, task_id NULL).
type OwnerRuleSetPayload struct {
	Key           string  `json:"key"`
	PreviousValue *string `json:"previous_value"`
	NewValue      string  `json:"new_value"`
}

// --- Phase 7 (the intake edge) audit payloads. ------------------------------

// SignalEmittedPayload — kind=signal_emitted (pre-task, task_id NULL). Written
// when a connector emission is persisted to intake_signals.
type SignalEmittedPayload struct {
	ConnectorID    string `json:"connector_id"`
	IdempotencyKey string `json:"idempotency_key"`
	Disposition    string `json:"disposition"`
	SignalID       string `json:"signal_id"`
}

// SignalDedupedPayload — kind=signal_deduped (pre-task, task_id NULL). Written
// when an emission collides with an existing (connector_id, idempotency_key).
type SignalDedupedPayload struct {
	ConnectorID    string `json:"connector_id"`
	IdempotencyKey string `json:"idempotency_key"`
}

// LLMJudgeCappedPayload — kind=llm_judge_capped (pre-task, task_id NULL).
// Written when a llm_judge item exceeds the per-poll cap; no model is called.
type LLMJudgeCappedPayload struct {
	ConnectorID string `json:"connector_id"`
	Cap         int    `json:"cap"`
	Count       int    `json:"count"`
}

// DispositionAppliedPayload — kind=disposition_applied (task-scope). Written
// when the router creates or holds a task. Outcome is one of
// "forced" | "auto_accept" | "proposed".
type DispositionAppliedPayload struct {
	Disposition string `json:"disposition"`
	Outcome     string `json:"outcome"`
	SignalID    string `json:"signal_id"`
}

// IntakeAutoAcceptedPayload — kind=intake_auto_accepted (task-scope). Written
// when a rich_event clears both the confidence floor and the stakes ceiling.
type IntakeAutoAcceptedPayload struct {
	Confidence      float64 `json:"confidence"`
	StakesHint      float64 `json:"stakes_hint"`
	ConfidenceFloor float64 `json:"confidence_floor"`
	StakesCeiling   float64 `json:"stakes_ceiling"`
}

// LLMJudgeInvokedPayload — kind=llm_judge_invoked (task-scope). Written when
// the triage model is invoked for an llm_judge item.
type LLMJudgeInvokedPayload struct {
	SignalID string `json:"signal_id"`
	IsTask   *bool  `json:"is_task,omitempty"`
}

// --- Phase 8 (calibration) audit payloads. ----------------------------------

// OutcomeFlaggedPayload — kind=outcome_flagged (task-scope). Owner flagOutcome
// records a bad outcome; reason is owner-supplied.
type OutcomeFlaggedPayload struct {
	ToolID    uuid.UUID `json:"tool_id"`
	OutcomeID uuid.UUID `json:"outcome_id"`
	Reason    string    `json:"reason,omitempty"`
}

// ToolDemotedPayload — kind=tool_demoted (task-scope). Reflexive demotion via a
// bad outcome / cancel / flag. Trigger is one of "bad_outcome" | "cancel_task"
// | "flag_outcome".
type ToolDemotedPayload struct {
	ToolID             uuid.UUID `json:"tool_id"`
	Trigger            string    `json:"trigger"`
	OldScore           float64   `json:"old_score"`
	NewScore           float64   `json:"new_score"`
	RevokedFingerprint string    `json:"revoked_fingerprint,omitempty"`
	RevokedAll         bool      `json:"revoked_all,omitempty"`
}

// PromotionEvidence is the frozen, legible track record carried by a proposal.
type PromotionEvidence struct {
	Routine            string  `json:"routine"`
	RoutineFingerprint string  `json:"routine_fingerprint"`
	WindowN            int     `json:"window_n"`
	MaturedClean       int     `json:"matured_clean"`
	Ratio              float64 `json:"ratio"`
	MinSample          int     `json:"min_sample"`
}

// PromotionProposedPayload — kind=promotion_proposed (task-scope). The sweep
// emits a PromotionProposal; the evidence is frozen here and into the
// pending_decisions.payload.
type PromotionProposedPayload struct {
	ToolID     uuid.UUID         `json:"tool_id"`
	DecisionID uuid.UUID         `json:"decision_id"`
	FromLevel  string            `json:"from_level"`
	ToLevel    string            `json:"to_level"`
	Evidence   PromotionEvidence `json:"evidence"`
}

// PromotionRespondedPayload — kind=promotion_responded (task-scope). Owner
// accept/decline via respondToPromotion.
type PromotionRespondedPayload struct {
	ToolID     uuid.UUID `json:"tool_id"`
	DecisionID uuid.UUID `json:"decision_id"`
	Accepted   bool      `json:"accepted"`
	NewScore   float64   `json:"new_score,omitempty"`
}

// --- Post-completion feedback (conversational) audit payloads. --------------

// FeedbackOpenedPayload — kind=feedback_opened (task-scope). Written when the
// feedback workflow opens the conversation (inserts the FeedbackRequest + the
// agent's opening message).
type FeedbackOpenedPayload struct {
	DecisionID uuid.UUID `json:"decision_id"`
	Converser  string    `json:"converser"` // "llm:<model>" | "stub"
}

// FeedbackSubmittedPayload — kind=feedback_submitted (task-scope). Written when
// the owner accepts or dismisses the feedback conversation. Rating is the 1–5
// satisfaction (0 when not supplied); Negative is the derived dissatisfaction
// signal routed into calibration. GuidanceID is set when guidance was accepted.
type FeedbackSubmittedPayload struct {
	DecisionID  uuid.UUID  `json:"decision_id"`
	Accepted    bool       `json:"accepted"`
	Rating      int        `json:"rating,omitempty"`
	Negative    bool       `json:"negative"`
	GuidanceID  *uuid.UUID `json:"guidance_id,omitempty"`
	SubmittedBy string     `json:"submitted_by"`
}

// AgentGuidanceAppliedPayload — kind=agent_guidance_applied (task-scope). The
// owner accepted a verbatim guidance note and chose its scope.
type AgentGuidanceAppliedPayload struct {
	GuidanceID    uuid.UUID  `json:"guidance_id"`
	Scope         string     `json:"scope"` // "global" | "agent"
	AgentConfigID *uuid.UUID `json:"agent_config_id,omitempty"`
}

// FeedbackContextConsultedPayload — kind=feedback_context_consulted (task-scope).
// Written when the feedback agent pulls task context via a read-only context
// tool, so the audit DAG records what the agent reviewed before drafting its
// guidance. Consulted is the set of context-tool names the agent called.
type FeedbackContextConsultedPayload struct {
	DecisionID uuid.UUID `json:"decision_id"`
	Consulted  []string  `json:"consulted"`
}

// DecisionExpiredPayload — kind=decision_expired (task-scope). Written when a
// pending_decisions human wait (approval / feedback / question) hits its
// configured timeout and is resolved as expired rather than left dangling.
// Flow is the wait kind that expired; Timeout is the window it waited.
type DecisionExpiredPayload struct {
	DecisionID uuid.UUID `json:"decision_id"`
	Flow       string    `json:"flow"`    // "approval_request" | "feedback_request" | "agent_question"
	Timeout    string    `json:"timeout"` // the elapsed window, e.g. "72h0m0s"
}

// StageTimeoutReroutedPayload — kind=stage_timeout_rerouted (task-scope).
// Written when a human-occupied chain stage slot times out. Attempt is the
// 1-based count of timeouts seen on this stage; Escalated is true once the
// retry budget is exhausted and the slot falls back to a no-timeout wait.
type StageTimeoutReroutedPayload struct {
	AssignmentID uuid.UUID  `json:"assignment_id"`
	Stage        ChainStage `json:"stage"`
	Attempt      int        `json:"attempt"`
	Timeout      string     `json:"timeout"`
	Escalated    bool       `json:"escalated"`
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
		FromPrincipal: fromPrincipal,
		Kind:          kind,
		Payload:       raw,
	}
	// task_id is nullable as of migration 00005. uuid.Nil means an
	// owner-scoped row (gate_script_rejected/attached/disabled, owner_rule_set)
	// admitted by the audit_task_required_unless_owner_scope CHECK; every other
	// kind passes a real task id.
	if taskID != uuid.Nil {
		params.TaskID = pgtype.UUID{Bytes: taskID, Valid: true}
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
