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
	"sync"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

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

// envDeps closes over the workflow's runtime dependencies. Set once by
// Register at startup; read-only thereafter.
type envDeps struct {
	pool     *pgxpool.Pool
	queries  *db.Queries
	registry *tools.Registry
}

var (
	depsMu sync.RWMutex
	deps   *envDeps
)

// Register stores deps and registers ToolCallWorkflow with DBOS. MUST be
// called between dbos.NewDBOSContext and dbos.Launch.
func Register(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, registry *tools.Registry) {
	depsMu.Lock()
	deps = &envDeps{pool: pool, queries: q, registry: registry}
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
	// from the resolver Sends the approvalEnvelope here.
	raw, err := chain.WaitForResult(ctx, ApprovalTopic(decisionID), ApprovalTimeout)
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
	_, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		return struct{}{}, dispatchAndRecord(stepCtx, d, decisionID, env)
	}, dbos.WithStepName("toolflow.dispatch_and_record"))
	if err != nil {
		return "", err
	}
	return "ok", nil
}

// dispatchAndRecord loads the frozen call, executes the tool (on approve),
// writes a tool_outcomes row, and chains the audit messages. Runs inside a
// single DBOS step so the (execute, record, audit) bundle is memoized as a
// unit.
func dispatchAndRecord(ctx context.Context, d *envDeps, decisionID uuid.UUID, env approvalEnvelope) error {
	row, err := d.queries.GetPendingDecisionByID(ctx, decisionID)
	if err != nil {
		return fmt.Errorf("load decision %s: %w", decisionID, err)
	}
	if !row.ToolID.Valid {
		return fmt.Errorf("decision %s has no tool_id", decisionID)
	}
	toolID := row.ToolID.Bytes
	taskID := row.TaskID

	tool, err := d.queries.GetToolByID(ctx, toolID)
	if err != nil {
		return fmt.Errorf("load tool %s: %w", uuid.UUID(toolID), err)
	}

	if !env.Approved {
		// Rejection: audit only, no dispatch, no outcome.
		return pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
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
		return fmt.Errorf("decision %s missing frozen_payload", decisionID)
	}
	result, execErr := d.registry.Execute(ctx, tool.GlobalUri, payload)

	outcomeKind := db.ToolOutcomeKindClean
	dispatchErrStr := ""
	if execErr != nil {
		outcomeKind = db.ToolOutcomeKindBad
		dispatchErrStr = execErr.Error()
	}

	return pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		q := db.New(tx)
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

		outcome, ierr := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
			ToolID:  toolID,
			TaskID:  taskID,
			Outcome: outcomeKind,
		})
		if ierr != nil {
			return fmt.Errorf("insert tool_outcome: %w", ierr)
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

		// Propagate provider errors back up so DBOS marks the step failed
		// and retries (per its default policy) — but only AFTER the bad
		// outcome row + audit chain landed. This is the calibration story:
		// the ledger captures the failure for Phase 8.
		if execErr != nil {
			return fmt.Errorf("tool dispatch failed: %w", execErr)
		}
		return nil
	})
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
