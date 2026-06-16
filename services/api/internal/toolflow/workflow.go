// Package toolflow is the Phase 3 sibling workflow that owns the lifecycle
// of a single tool call from the moment it's gated through dispatch and
// outcome recording. The chain workflow is unchanged — keeping its
// deterministic step sequence intact — and the tool-call workflow is
// independently durable.
//
// Lifecycle (happy path):
//
//  1. ResolverProposeToolCall: composes a ToolCall, runs gate.Evaluate, on
//     RequestDecision writes a pending_decisions row (kind=approval_request,
//     frozen_payload + workflow_id + decision_topic populated), then starts
//     ToolCallWorkflow(decisionID) with a deterministic workflow id.
//  2. ToolCallWorkflow: dbos.Recv on "approval:"+decisionID, 72h timeout.
//  3. ResolverApproveArtifact / RejectApproval: marks the row resolved,
//     then dbos.Send the decision payload to the topic so step 2 wakes.
//  4. ToolCallWorkflow: on approval → dispatch via registry → write
//     tool_outcomes row + audit. On rejection → audit only.
//
// Cancel-after-dispatch is safe: tool_outcomes is append-only and the
// chain workflow's HALTED transition does not touch this package.
package toolflow

import (
	"context"
	"encoding/json"
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

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// WorkflowName is the DBOS workflow name for the tool-call workflow.
const WorkflowName = "tendant.toolcall"

// WorkflowIDPrefix is the deterministic prefix for tool-call workflow IDs.
// Full id is `toolcall:<decision_uuid>`.
const WorkflowIDPrefix = "toolcall:"

// ApprovalTopicPrefix is the dbos.Send/Recv topic prefix for approval
// resolutions. Full topic is `approval:<decision_uuid>`.
const ApprovalTopicPrefix = "approval:"

// ApprovalTimeout matches chain.HumanSlotTimeout — the same human latency
// budget.
const ApprovalTimeout = chain.HumanSlotTimeout

// WorkflowID returns the deterministic DBOS workflow id for a given
// decision id. Used both at start (mutation) and at wake (resolver).
func WorkflowID(decisionID uuid.UUID) string {
	return WorkflowIDPrefix + decisionID.String()
}

// ApprovalTopic returns the deterministic dbos.Send topic for a given
// decision id.
func ApprovalTopic(decisionID uuid.UUID) string {
	return ApprovalTopicPrefix + decisionID.String()
}

// ToolOutcomeTopicPrefix is the back-channel topic a tool-call workflow Sends
// its final outcome on, so a durably-waiting AgentStageWorkflow can resume with
// the result injected. Full topic is `tooloutcome:<decision_uuid>`.
const ToolOutcomeTopicPrefix = "tooloutcome:"

// ToolOutcomeTopic returns the deterministic back-channel topic for a decision.
func ToolOutcomeTopic(decisionID uuid.UUID) string {
	return ToolOutcomeTopicPrefix + decisionID.String()
}

// OutcomeEnvelope is what a tool-call workflow Sends back to a waiting agent
// workflow on ToolOutcomeTopic. Kind is the disposition; Content is the
// tool_result string the agent injects into its model loop so the LLM can react.
type OutcomeEnvelope struct {
	Kind    string `json:"kind"`    // "clean" | "bad" | "rejected" | "expired"
	Content string `json:"content"` // tool_result to inject into the agent loop
}

// stepOutcome is what the dispatch / expire steps return to the workflow body so
// it can fire the back-channel Send at workflow scope (dbos.Send is a workflow
// primitive and must not be called from inside a step). NotifyWorkflowID empty ⇒
// no waiter (a human-initiated approval); the workflow skips the Send.
type stepOutcome struct {
	NotifyWorkflowID string
	Envelope         OutcomeEnvelope
}

// envDeps closes over the workflow's runtime dependencies. Set once by
// Register at startup; read-only thereafter.
type envDeps struct {
	pool       *pgxpool.Pool
	queries    *db.Queries
	registry   *tools.Registry
	calibrator *calibration.Engine
	timeouts   chain.Timeouts // approval-wait window; nil ⇒ legacy 72h
}

var (
	depsMu sync.RWMutex
	deps   *envDeps
)

// Register stores deps and registers ToolCallWorkflow with DBOS. MUST be
// called between dbos.NewDBOSContext and dbos.Launch.
func Register(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, registry *tools.Registry, calibrator *calibration.Engine, timeouts chain.Timeouts) {
	depsMu.Lock()
	deps = &envDeps{pool: pool, queries: q, registry: registry, calibrator: calibrator, timeouts: timeouts}
	depsMu.Unlock()
	dbos.RegisterWorkflow(dctx, ToolCallWorkflow, dbos.WithWorkflowName(WorkflowName))
}

func loadDeps() (*envDeps, error) {
	depsMu.RLock()
	d := deps
	depsMu.RUnlock()
	if d == nil {
		return nil, errors.New("toolflow.Register was not called before workflow ran")
	}
	return d, nil
}

// approvalEnvelope is what the approve/reject resolvers Send to the
// workflow. Encoded as JSON on the wire (dbos.Send payload).
type approvalEnvelope struct {
	Approved   bool      `json:"approved"`
	Reason     string    `json:"reason,omitempty"`
	ResolvedBy string    `json:"resolved_by,omitempty"`
	DecisionID uuid.UUID `json:"decision_id"`
}

// ResolveDecision is the resolver-facing wake primitive. Called by
// approveArtifact / rejectApproval after the decision row has been marked
// resolved. Idempotent — DBOS handles repeated Send semantics.
func ResolveDecision(ctx dbos.DBOSContext, decisionID uuid.UUID, approved bool, reason, resolvedBy string) error {
	env := approvalEnvelope{
		Approved:   approved,
		Reason:     reason,
		ResolvedBy: resolvedBy,
		DecisionID: decisionID,
	}
	raw, err := json.Marshal(env)
	if err != nil {
		return fmt.Errorf("marshal approval envelope: %w", err)
	}
	return chain.Resolve(ctx, WorkflowID(decisionID), ApprovalTopic(decisionID), raw)
}

// ToolCallWorkflow is the DBOS-registered workflow that owns one tool
// call. Input is the decision id as a string (DBOS serializes input via
// the configured serializer; string is the simplest stable shape).
//
// The workflow body MUST run the exact same sequence of DBOS step calls on
// every invocation (DBOS replay invariant). Branching on observed approval
// state happens INSIDE the dispatch step, not at the workflow level —
// the step's outcome is memoized, the internal branch is not.
func ToolCallWorkflow(ctx dbos.DBOSContext, decisionIDStr string) (string, error) {
	decisionID, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return "", fmt.Errorf("invalid decisionID: %w", err)
	}

	d, err := loadDeps()
	if err != nil {
		return "", err
	}

	// Step 1: durable wait on the approval topic. The ResolveDecision call
	// from the resolver Sends the approvalEnvelope here. On timeout the wait
	// returns ErrHumanWaitExpired instead of poisoning the workflow to ERROR —
	// the human didn't respond within hitl.approval_timeout, so we resolve the
	// decision as expired (no dispatch) and let the audit DAG record it.
	timeout := chain.ApprovalTimeoutOr(d.timeouts)
	raw, err := chain.WaitForResultOrExpire(ctx, ApprovalTopic(decisionID), timeout)
	if errors.Is(err, chain.ErrHumanWaitExpired) {
		out, serr := dbos.RunAsStep(ctx, func(stepCtx context.Context) (stepOutcome, error) {
			return expireDecision(stepCtx, d, decisionID, timeout)
		}, dbos.WithStepName("toolflow.expire_decision"))
		if serr != nil {
			return "", serr
		}
		if nerr := notifyWaiter(ctx, decisionID, out); nerr != nil {
			return "", nerr
		}
		return "expired", nil
	}
	if err != nil {
		return "", fmt.Errorf("await approval: %w", err)
	}

	var env approvalEnvelope
	if uerr := json.Unmarshal(raw, &env); uerr != nil {
		return "", fmt.Errorf("decode approval envelope: %w", uerr)
	}

	// Step 2: dispatch + outcome. Run as ONE step so DBOS memoization
	// covers the (load-decision, execute, write-outcome, audit) bundle.
	// On approve we run the tool; on reject we skip the dispatch and audit
	// the rejection only.
	out, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (stepOutcome, error) {
		return dispatchAndRecord(stepCtx, d, decisionID, env)
	}, dbos.WithStepName("toolflow.dispatch_and_record"))
	if err != nil {
		return "", err
	}
	// Back-channel: notify a durably-waiting AgentStageWorkflow at workflow
	// scope (dbos.Send is a workflow primitive, not valid inside a step).
	if nerr := notifyWaiter(ctx, decisionID, out); nerr != nil {
		return "", nerr
	}
	return "ok", nil
}

// notifyWaiter delivers a tool-call outcome to a durably-waiting agent workflow
// on the back-channel topic. No-op when no waiter registered (a human-initiated
// approval). Runs at workflow scope; dbos.Send is durable + idempotent on replay.
func notifyWaiter(ctx dbos.DBOSContext, decisionID uuid.UUID, out stepOutcome) error {
	if out.NotifyWorkflowID == "" {
		return nil
	}
	payload, err := json.Marshal(out.Envelope)
	if err != nil {
		return fmt.Errorf("marshal outcome envelope: %w", err)
	}
	// Send as json.RawMessage (not []byte) so the DBOS serializer round-trips it
	// the same way the agent's dbos.Recv[json.RawMessage] expects — matching the
	// approval-envelope wire shape in chain.Resolve.
	if err := dbos.Send(ctx, out.NotifyWorkflowID, json.RawMessage(payload), ToolOutcomeTopic(decisionID)); err != nil {
		return fmt.Errorf("notify waiter %s: %w", out.NotifyWorkflowID, err)
	}
	return nil
}

// expireDecision resolves a timed-out approval decision as expired and records
// a decision_expired audit. No dispatch happens. Resolving the
// pending_decisions row (first-write-wins) clears it from the inbox; the audit
// gives the operator an explicit signal that the human didn't respond in time.
//
// Race: a human may resolve at the exact timeout boundary (mark the row
// resolved just before our Recv deadline fires). First-write-wins means our
// resolve then no-ops (ErrNoRows); we treat that as "already decided" and exit
// without dispatching — fail-closed, the safe direction for an at-boundary
// approval. The window is sub-second after a multi-hour wait.
func expireDecision(ctx context.Context, d *envDeps, decisionID uuid.UUID, timeout time.Duration) (stepOutcome, error) {
	resolution, err := json.Marshal(map[string]any{
		"expired": true,
		"reason":  "human_no_response",
	})
	if err != nil {
		return stepOutcome{}, fmt.Errorf("marshal expired resolution: %w", err)
	}
	row, err := d.queries.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
		ID:         decisionID,
		ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
		Resolution: resolution,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// Already resolved at the boundary by a human — honor that, do
			// nothing here (no waiter notification: the human path already did).
			slog.WarnContext(ctx, "toolflow.expire_skipped_already_resolved", "decision_id", decisionID)
			return stepOutcome{}, nil
		}
		return stepOutcome{}, fmt.Errorf("resolve decision expired: %w", err)
	}

	notify := ""
	if row.NotifyWorkflowID != nil {
		notify = *row.NotifyWorkflowID
	}
	out := stepOutcome{
		NotifyWorkflowID: notify,
		Envelope: OutcomeEnvelope{
			Kind:    "expired",
			Content: fmt.Sprintf(`{"error":"human_no_response","detail":"the human did not respond within %s"}`, timeout),
		},
	}

	return out, pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		parent, perr := latestTransitionIDInTx(ctx, tx, row.TaskID)
		if perr != nil {
			return perr
		}
		_, werr := lifecycle.WriteAuditMessage(ctx, tx, row.TaskID, lifecycle.SystemActorURI,
			lifecycle.KindDecisionExpired,
			lifecycle.DecisionExpiredPayload{
				DecisionID: decisionID,
				Flow:       string(db.DecisionKindApprovalRequest),
				Timeout:    timeout.String(),
			},
			parent,
		)
		return werr
	})
}

// dispatchAndRecord loads the frozen call, executes the tool (on approve),
// writes a tool_outcomes row, and chains the audit messages. Runs inside a
// single DBOS step so the (execute, record, audit) bundle is memoized as a
// unit.
func dispatchAndRecord(ctx context.Context, d *envDeps, decisionID uuid.UUID, env approvalEnvelope) (stepOutcome, error) {
	row, err := d.queries.GetPendingDecisionByID(ctx, decisionID)
	if err != nil {
		return stepOutcome{}, fmt.Errorf("load decision %s: %w", decisionID, err)
	}
	if !row.ToolID.Valid {
		return stepOutcome{}, fmt.Errorf("decision %s has no tool_id", decisionID)
	}
	toolID := row.ToolID.Bytes
	taskID := row.TaskID
	notify := ""
	if row.NotifyWorkflowID != nil {
		notify = *row.NotifyWorkflowID
	}

	tool, err := d.queries.GetToolByID(ctx, toolID)
	if err != nil {
		return stepOutcome{}, fmt.Errorf("load tool %s: %w", uuid.UUID(toolID), err)
	}

	if !env.Approved {
		// Rejection: audit only, no dispatch, no outcome. The waiter (if any) is
		// told the call was rejected so its loop can choose another path.
		out := stepOutcome{
			NotifyWorkflowID: notify,
			Envelope: OutcomeEnvelope{
				Kind:    "rejected",
				Content: fmt.Sprintf(`{"error":"the human rejected this tool call","reason":%q}`, env.Reason),
			},
		}
		return out, pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
			parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
			if perr != nil {
				return perr
			}
			_, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
				lifecycle.KindDecisionResolved,
				lifecycle.DecisionResolvedPayload{
					DecisionID: decisionID,
					Approved:   false,
					Reason:     env.Reason,
					ResolvedBy: env.ResolvedBy,
				},
				parent,
			)
			return werr
		})
	}

	// Approved → dispatch the frozen payload.
	payload := row.FrozenPayload
	if len(payload) == 0 {
		return stepOutcome{}, fmt.Errorf("decision %s missing frozen_payload", decisionID)
	}

	// Carry a stable idempotency key (the decision id — deterministic across
	// DBOS recovery re-runs) on the context handed to both the Idempotent check
	// and Execute, so a provider that dedups on it can guarantee exactly-once
	// even though DBOS steps are at-least-once.
	dispatchCtx := tools.WithIdempotencyKey(ctx, decisionID.String())

	// Idempotency guard. A crash between Execute and the step checkpoint re-runs
	// dispatchAndRecord on recovery. The tool inspects this ctx + payload to
	// report whether repeating the call is safe (its provider dedups on the
	// key). When it is NOT, skip re-Execute if this decision already dispatched
	// (an approved decision_resolved audit exists, written in the same tx as the
	// outcome below) so we don't repeat the side effect. Unknown tools fall
	// through to Execute, which returns ErrUnknownTool.
	if t, ok := d.registry.ByGlobalURI(tool.GlobalUri); ok && !t.Idempotent(dispatchCtx, payload) {
		dispatched, derr := d.queries.DecisionAlreadyDispatched(ctx, decisionID.String())
		if derr != nil {
			return stepOutcome{}, fmt.Errorf("dispatch idempotency guard: %w", derr)
		}
		if dispatched {
			slog.WarnContext(ctx, "toolflow.dispatch_skipped_already_dispatched",
				"decision_id", decisionID, "tool", tool.GlobalUri)
			// Recovery re-run after the outcome already committed: still notify
			// the waiter so it can't hang (the prior attempt's Send may not have
			// landed). The precise clean/bad split is not re-derived here.
			return stepOutcome{
				NotifyWorkflowID: notify,
				Envelope:         OutcomeEnvelope{Kind: "clean", Content: `{"status":"already_dispatched"}`},
			}, nil
		}
	}

	result, execErr := d.registry.Execute(dispatchCtx, tool.GlobalUri, payload)

	outcomeKind := db.ToolOutcomeKindClean
	dispatchErrStr := ""
	if execErr != nil {
		outcomeKind = db.ToolOutcomeKindBad
		dispatchErrStr = execErr.Error()
	}

	if err := pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		// Audit: decision_resolved → tool_dispatched → tool_outcome_recorded.
		parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
		if perr != nil {
			return perr
		}
		resolvedAudit, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindDecisionResolved,
			lifecycle.DecisionResolvedPayload{
				DecisionID: decisionID,
				Approved:   true,
				ResolvedBy: env.ResolvedBy,
			},
			parent,
		)
		if werr != nil {
			return werr
		}

		dispatchedAudit, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindToolDispatched,
			lifecycle.ToolDispatchedPayload{
				ToolID:   toolID,
				Provider: result.Provider,
				Detail:   result.Detail,
				Error:    dispatchErrStr,
			},
			resolvedAudit,
		)
		if werr != nil {
			return werr
		}

		// Phase 8: route outcome recording through the calibrator so each row
		// carries a matured_at + routine fingerprint. On the bad path the
		// calibrator also reflexively demotes the tool in this same tx (the
		// audit chain below still records tool_outcome_recorded). The dispatch
		// error is propagated AFTER the bad outcome + demotion land.
		in := calibration.OutcomeInput{
			ToolID:        toolID,
			TaskID:        taskID,
			ToolGlobalURI: tool.GlobalUri,
			Payload:       payload,
			At:            time.Now().UTC(),
		}
		var outcome db.ToolOutcome
		var ierr error
		if execErr != nil {
			outcome, ierr = d.calibrator.RecordBad(ctx, tx, in)
		} else {
			outcome, ierr = d.calibrator.RecordOutcome(ctx, tx, in)
		}
		if ierr != nil {
			return fmt.Errorf("record tool_outcome: %w", ierr)
		}

		if _, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindToolOutcomeRecorded,
			lifecycle.ToolOutcomeRecordedPayload{
				ToolID:    toolID,
				OutcomeID: outcome.ID,
				Outcome:   string(outcomeKind),
			},
			dispatchedAudit,
		); werr != nil {
			return werr
		}

		return nil
	}); err != nil {
		return stepOutcome{}, err
	}

	if execErr != nil {
		badOut := stepOutcome{
			NotifyWorkflowID: notify,
			Envelope:         OutcomeEnvelope{Kind: "bad", Content: fmt.Sprintf(`{"error":%q}`, execErr.Error())},
		}
		if notify != "" {
			// Agent waiter present: report the failure into the agent loop and
			// complete cleanly (the bad outcome row + demotion already committed
			// above). The agent's LLM decides how to react. We do NOT propagate
			// execErr here — that retry path is for the human-initiated flow.
			return badOut, nil
		}
		// Human flow: propagate provider errors so DBOS marks the step failed and
		// retries (default policy) — only AFTER the bad outcome row + audit chain
		// have COMMITTED (returning execErr from inside BeginFunc would roll them
		// back). On the retry the idempotency guard sees the decision already
		// dispatched and returns without re-executing, so exactly one bad outcome
		// is recorded. This is the Phase-8 calibration ledger.
		return stepOutcome{}, fmt.Errorf("tool dispatch failed: %w", execErr)
	}

	cleanContent := `{"status":"dispatched"}`
	if len(result.Detail) > 0 {
		cleanContent = string(result.Detail)
	}
	return stepOutcome{
		NotifyWorkflowID: notify,
		Envelope:         OutcomeEnvelope{Kind: "clean", Content: cleanContent},
	}, nil
}

// latestTransitionIDInTx mirrors chain.latestTransitionIDInTx; duplicated
// here to avoid an internal-to-internal export. Returns uuid.Nil for first
// audit on a task.
func latestTransitionIDInTx(ctx context.Context, tx pgx.Tx, taskID uuid.UUID) (uuid.UUID, error) {
	q := db.New(tx)
	row, err := q.LatestTransitionForTask(ctx, taskID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, nil
		}
		return uuid.Nil, fmt.Errorf("latest transition (tx): %w", err)
	}
	return row.ID, nil
}

// StartToolCallWorkflow is the helper the proposeToolCall resolver uses to
// kick off the workflow with the deterministic id. Idempotent under retry —
// DBOS dedupes on the workflow id.
func StartToolCallWorkflow(ctx dbos.DBOSContext, decisionID uuid.UUID) error {
	wfID := WorkflowID(decisionID)
	_, err := dbos.RunWorkflow(ctx, ToolCallWorkflow, decisionID.String(),
		dbos.WithWorkflowID(wfID),
	)
	return err
}

// SilenceUnused keeps the imports above honest when partial refactors
// happen. (pgtype is referenced via db model fields; pgxpool via envDeps;
// time via ApprovalTimeout.) These references are real — this var is a
// belt-and-suspenders guard to prevent a future drive-by edit from
// orphaning an import unnoticed.
var _ = func() any { return []any{pgtype.UUID{}, pgxpool.Pool{}, time.Second} }
