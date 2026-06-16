package chain

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
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// WorkflowName is the DBOS workflow name for the chain. Stable across
// restarts; recovery looks the function up by this name.
const WorkflowName = "tendant.chain"

// ChainWorkflowIDPrefix is the deterministic prefix for chain workflow IDs.
// Full id is `chain:<task_uuid>` (R5).
const ChainWorkflowIDPrefix = "chain:"

// CancelSentinelKey is the JSON key the chain workflow uses to detect that
// a Recv payload is a cancellation sentinel (sent by the cancelTask
// resolver) rather than a real completeTask result. The wait *primitive*
// stays generic — only the chain layer interprets this convention.
const CancelSentinelKey = "_chain_cancel"

// ChainWorkflowID is the deterministic workflow id for a given task — kept
// in lockstep with `chain_workflows.dbos_workflow_id`.
func ChainWorkflowID(taskID uuid.UUID) string {
	return ChainWorkflowIDPrefix + taskID.String()
}

// TopicForStage is the deterministic Send/Recv topic for a stage's human
// slot. Wait-key derivation from (taskID, stage) is reconstructible without
// a DB lookup (R5).
func TopicForStage(stage lifecycle.ChainStage) string {
	return "stage:" + string(stage)
}

// CancelSentinel returns the JSON payload the cancelTask resolver Sends to
// unblock the workflow's Recv, signalling "exit; the resolver already did
// the cleanup writes." The wait primitive stays generic — the chain layer
// owns this convention and decodes it post-Recv.
func CancelSentinel() json.RawMessage {
	return json.RawMessage(`{"` + CancelSentinelKey + `":true}`)
}

// PushEnqueuer is the seam the chain workflow uses to schedule a push when
// it opens an assignment. The Phase 2 implementation calls a DBOS-queued
// workflow; tests use a recording stub. nil is allowed (no-push mode, used
// in Phase 0/1 tests and in CI before APNs/FCM credentials are wired).
type PushEnqueuer interface {
	EnqueuePush(ctx context.Context, payload PushJobPayload) error
}

// FeedbackEnqueuer is the seam the chain workflow uses to start the
// post-completion feedback workflow as a durable child, without importing
// internal/feedback (that would close an import cycle: feedback → chain). The
// adapter (feedback.Enqueuer) calls feedback.StartFeedbackWorkflow with the
// chain workflow's own DBOS context. nil is allowed (no-feedback mode, used in
// Phase 0–7 tests and CI before a generator is wired).
type FeedbackEnqueuer interface {
	EnqueueFeedback(ctx dbos.DBOSContext, taskID uuid.UUID) error
}

// PushJobPayload mirrors push.JobPayload so the chain package doesn't take a
// direct dependency on internal/push (that would close a circular import via
// internal/push → internal/db; we keep chain at the lower layer).
type PushJobPayload struct {
	TaskID             uuid.UUID
	AssignmentID       uuid.UUID
	RecipientGlobalURI string
	DeepLinkID         string
	Title              string
}

// envDeps carries the closure over the chain workflow's runtime
// dependencies. Set once by Register at startup; read-only thereafter.
type envDeps struct {
	pool           *pgxpool.Pool
	queries        *db.Queries
	router         Router
	runner         StageRunner // Phase 6: agent runner for non-human stages
	ownerGlobalURI string
	push           PushEnqueuer
	feedback       FeedbackEnqueuer
}

var (
	depsMu sync.RWMutex
	deps   *envDeps
)

// Register stores deps and registers ChainWorkflow with DBOS. MUST be called
// once between dbos.NewDBOSContext and dbos.Launch — Launch performs recovery
// against the registered function, so the function must be in place beforehand.
// Safe to call again (e.g., in tests that init a fresh DBOS context).
//
// ownerGlobalURI populates agent_assignments.to_principal so the push fan-out
// worker knows whose tokens to push (Phase 2). push is optional; nil opts out
// of push enqueue (Phase 0/1 tests, CI without APNs/FCM creds).
func Register(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, router Router, runner StageRunner, ownerGlobalURI string, pushEnqueuer PushEnqueuer, feedbackEnqueuer FeedbackEnqueuer) {
	depsMu.Lock()
	deps = &envDeps{
		pool:           pool,
		queries:        q,
		router:         router,
		runner:         runner,
		ownerGlobalURI: ownerGlobalURI,
		push:           pushEnqueuer,
		feedback:       feedbackEnqueuer,
	}
	depsMu.Unlock()
	dbos.RegisterWorkflow(dctx, ChainWorkflow, dbos.WithWorkflowName(WorkflowName))
}

func loadDeps() (*envDeps, error) {
	depsMu.RLock()
	d := deps
	depsMu.RUnlock()
	if d == nil {
		return nil, errors.New("chain.Register was not called before workflow ran")
	}
	return d, nil
}

// ChainWorkflow is the DBOS-registered workflow that walks a task through
// its stages. The taskID is passed as a string (DBOS serializes input via
// the configured serializer; string is the simplest stable shape).
//
// Lifecycle:
//   - Load task. If current_stage is already COMPLETION, return — the
//     workflow recovered after completion.
//   - For each stage that needs an occupant, open the slot (one DBOS step:
//     insert assignment row + assignment_created audit row), then block on
//     WaitForResult. On return, run a resolve step (close assignment, audit,
//     advance stage). At EXPANSION→EXECUTION boundary, transition
//     ACCEPTED → EXECUTING (or WAITING) via the readiness predicate.
//   - On reaching COMPLETION, transition EXECUTING → DONE and close the
//     chain_workflows row.
//
// Cancellation: the cancelTask resolver does the bulk of the cleanup work
// directly (state → HALTED, audit, EndChainWorkflow); it then dbos.Sends a
// cancel-sentinel to the current stage's topic so this workflow unblocks
// and exits cleanly. The workflow does NOT itself write HALTED — that's
// already done by the resolver.
func ChainWorkflow(ctx dbos.DBOSContext, taskIDStr string) (string, error) {
	taskID, err := uuid.Parse(taskIDStr)
	if err != nil {
		return "", fmt.Errorf("invalid taskID: %w", err)
	}

	d, err := loadDeps()
	if err != nil {
		return "", err
	}

	// Recovery safety: the workflow body MUST run the exact same sequence of
	// DBOS step calls on every invocation; DBOS memoization keys by
	// (function_id, function_name) and any deviation (skipping a step,
	// branching on observed state) raises an UnexpectedStep error and tears
	// the workflow down. So below is a straight-line, stage-by-stage drive
	// that calls each step regardless of current_stage — the step bodies
	// only execute the first time, and the memoized outcome is replayed on
	// recovery.

	// Quick exit for an already-terminal workflow. Reading state for this
	// check is fine because it doesn't change which step calls follow — both
	// branches return immediately without any RunAsStep / Recv.
	task, err := d.queries.GetTask(ctx, taskID)
	if err != nil {
		return "", fmt.Errorf("load task: %w", err)
	}
	if lifecycle.IsTerminal(task.State) {
		return "", nil
	}

	// 1. CREATION → TRIAGE (no occupant on CREATION; first step in the chain).
	if err := runAdvanceStageStep(ctx, d, taskID, lifecycle.StageCreation, lifecycle.StageTriage, "genesis"); err != nil {
		return "", err
	}

	// 2-N. Drive each occupied stage. Per-stage pattern (Phase 6):
	//   - Route-and-occupy step (memoized): router picks human or agent;
	//     if agent, runs the loop inline and returns StageResult.
	//   - If human: durable wait on the stage topic (Recv).
	//   - Resolve + advance step.
	//
	// Recovery safety: the route-and-occupy step is memoized. Branching on
	// its result (IsHuman) is deterministic on replay because DBOS replays
	// the memoized return value byte-for-byte. If the original execution
	// called Recv, replay calls Recv (memoized). If it skipped, replay skips.
	for _, stage := range []lifecycle.ChainStage{lifecycle.StageTriage, lifecycle.StageExpansion, lifecycle.StageExecution} {
		decision, err := runRouteAndOccupyStep(ctx, d, taskID, stage, task.Findings)
		if err != nil {
			return "", err
		}

		var result json.RawMessage
		if decision.IsHuman {
			// Human path: open assignment + durable wait (Phase 1/2 mechanism).
			if err := runOpenAssignmentStep(ctx, d, taskID, stage, decision.HandoffReason); err != nil {
				return "", err
			}
			result, err = WaitForResult(ctx, TopicForStage(stage), HumanSlotTimeout)
			if err != nil {
				return "", err
			}
			if isCancelSentinel(result) {
				return "", nil
			}
		} else {
			// Agent path: result is already in the memoized decision.
			result = decision.StageResult
		}

		next, _ := NextStage(stage)
		if err := runResolveAndAdvanceStep(ctx, d, taskID, stage, next, result); err != nil {
			return "", err
		}
	}

	// Final: COMPLETION step (EXECUTING → DONE + EndChainWorkflow).
	if err := runCompletionStep(ctx, d, taskID); err != nil {
		return "", err
	}

	// Post-completion: start the feedback workflow as a durable child (mirrors
	// the toolflow sibling). Best-effort by design — a crash in the narrow
	// window between the completion commit and this child-start would, on
	// recovery, hit the terminal early-return above and skip feedback for this
	// task. Started from the workflow body (NOT a step): DBOS forbids spawning a
	// child workflow from within a step, and the fixed child id makes the start
	// idempotent. nil enqueuer (tests / CI) is a no-op.
	if d.feedback != nil {
		if err := d.feedback.EnqueueFeedback(ctx, taskID); err != nil {
			return "", fmt.Errorf("enqueue feedback: %w", err)
		}
	}
	return "ok", nil
}

// isCancelSentinel decodes the result and reports whether it carries the
// CancelSentinelKey. Returns false on any decode error (a real result that
// happens to fail JSON shape checks isn't treated as cancellation).
func isCancelSentinel(raw json.RawMessage) bool {
	if len(raw) == 0 {
		return false
	}
	var m map[string]any
	if err := json.Unmarshal(raw, &m); err != nil {
		return false
	}
	v, ok := m[CancelSentinelKey]
	if !ok {
		return false
	}
	b, _ := v.(bool)
	return b
}

// runRouteAndOccupyStep is the memoized DBOS step that routes a stage.
// It calls the router to decide human vs agent, and if agent, runs the
// agent inline and returns the StageResult in the decision. The result is
// memoized by DBOS for recovery determinism.
func runRouteAndOccupyStep(ctx dbos.DBOSContext, d *envDeps, taskID uuid.UUID, stage lifecycle.ChainStage, findings json.RawMessage) (SlotDecision, error) {
	result, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (SlotDecision, error) {
		decision, rErr := d.router.Select(stepCtx, stage, findings)
		if rErr != nil {
			// Router error → fail-close to human.
			return SlotDecision{IsHuman: true}, nil
		}

		if decision.IsHuman {
			return SlotDecision{IsHuman: true}, nil
		}

		// Agent path: run the agent loop inline.
		if d.runner == nil {
			// No runner configured → fall back to human.
			return SlotDecision{IsHuman: true}, nil
		}

		configID := ""
		if decision.ConfigID != nil {
			configID = decision.ConfigID.String()
		}

		stageResult, runErr := d.runner.RunStage(stepCtx, taskID.String(), stage, configID)
		if runErr != nil {
			// Runner error → fail-close to human.
			return SlotDecision{IsHuman: true}, nil
		}

		// Check if the agent failed-close to human (budget exhausted,
		// max iterations, RequestDecision, gateway error, or an explicit
		// handoff_to_human call). If so, return IsHuman: true so the chain
		// enters the human-wait path, carrying the agent's handoff reason
		// (empty for non-handoff fail-closes) onto the assignment ask.
		if isFailCloseResult(stageResult) {
			return SlotDecision{IsHuman: true, HandoffReason: handoffReasonOf(stageResult)}, nil
		}

		return SlotDecision{
			IsHuman:     false,
			ConfigID:    decision.ConfigID,
			ConfigName:  decision.ConfigName,
			StageResult: stageResult,
		}, nil
	}, dbos.WithStepName("chain.route_and_occupy."+string(stage)))
	return result, err
}

// isFailCloseResult checks if a raw StageResult JSON indicates fail-close-to-human.
func isFailCloseResult(raw json.RawMessage) bool {
	if len(raw) == 0 {
		return false
	}
	var result struct {
		FailCloseToHuman bool `json:"fail_close_to_human"`
	}
	if err := json.Unmarshal(raw, &result); err != nil {
		return false
	}
	return result.FailCloseToHuman
}

// handoffReasonOf extracts the agent-authored handoff reason from a raw
// StageResult JSON. Empty for non-handoff fail-closes (budget, max-iter, etc.)
// and on any decode error.
func handoffReasonOf(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var result struct {
		HandoffReason string `json:"handoff_reason"`
	}
	if err := json.Unmarshal(raw, &result); err != nil {
		return ""
	}
	return result.HandoffReason
}

// detachCancel strips cancellation/deadline from a step context while keeping
// its values. Short, idempotent DB-write steps run their transaction under it
// so a graceful shutdown mid-step lets the in-flight tx commit and the step
// record SUCCESS — instead of the DB call observing context.Canceled, which
// DBOS persists as the step's PERMANENT error (replayed on every recovery) and
// returns to the workflow body, poisoning the whole workflow to terminal ERROR
// (which DBOS never recovers). The drain timeout in durable.Shutdown bounds how
// long these can hold up shutdown. Do NOT use this for long-running I/O steps
// (agent/LLM, HTTP fetch, tool dispatch): those must stay cancellable and rely
// instead on idempotent re-run after a hard-kill recovery.
func detachCancel(ctx context.Context) context.Context { return context.WithoutCancel(ctx) }

// runAdvanceStageStep advances the chain stage in one DBOS step.
func runAdvanceStageStep(ctx dbos.DBOSContext, d *envDeps, taskID uuid.UUID, from, to lifecycle.ChainStage, reason string) error {
	_, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		stepCtx = detachCancel(stepCtx)
		err := pgx.BeginFunc(stepCtx, d.pool, func(tx pgx.Tx) error {
			_, txErr := lifecycle.AdvanceStage(stepCtx, tx, taskID, from, to, reason)
			return txErr
		})
		return struct{}{}, err
	}, dbos.WithStepName("chain.advance_stage."+string(to)))
	return err
}

// runOpenAssignmentStep inserts the agent_assignments row + assignment_created
// audit row in one tx. Idempotent under recovery (skips if an open row
// already exists for (task, stage)). After the tx commits, enqueues a push
// fan-out job (Phase 2; no-op when PushEnqueuer is nil).
//
// handoffReason, when non-empty, replaces the stage-default ask — an agent
// fail-closed via handoff_to_human, so the human sees the specialist's own
// explanation of why it could not complete the work.
func runOpenAssignmentStep(ctx dbos.DBOSContext, d *envDeps, taskID uuid.UUID, stage lifecycle.ChainStage, handoffReason string) error {
	ask := DefaultAsk(stage)
	if handoffReason != "" {
		ask = "An automated specialist handed this task to you: " + handoffReason
	}
	// The assignment id is returned from the step (not captured via a closure
	// variable) so it survives recovery: on replay DBOS returns the memoized
	// result without executing the closure, so any value set inside the closure
	// would be lost. Gating the post-commit enqueue_push step on a closure-set
	// id therefore diverged between the original run (id non-nil → enqueue_push
	// recorded) and recovery (id nil → enqueue_push skipped, Recv reached),
	// which DBOS detects as a non-deterministic step sequence and poisons the
	// workflow to terminal ERROR. Returning the id keeps the gate deterministic.
	outerAssignmentID, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (uuid.UUID, error) {
		var assignmentID uuid.UUID
		stepCtx = detachCancel(stepCtx)
		err := pgx.BeginFunc(stepCtx, d.pool, func(tx pgx.Tx) error {
			q := db.New(tx)
			if existing, fErr := q.FindOpenAssignmentForStage(stepCtx, db.FindOpenAssignmentForStageParams{
				TaskID: taskID,
				Stage:  stage,
			}); fErr == nil {
				assignmentID = existing.ID // recovery: existing open row, no need to re-insert
				return nil
			} else if !errors.Is(fErr, pgx.ErrNoRows) {
				return fErr
			}
			row, ierr := q.InsertAgentAssignment(stepCtx, db.InsertAgentAssignmentParams{
				TaskID:          taskID,
				Stage:           stage,
				Ask:             ask,
				GatheredContext: json.RawMessage("{}"),
			})
			if ierr != nil {
				return fmt.Errorf("insert assignment: %w", ierr)
			}
			if d.ownerGlobalURI != "" {
				owner := d.ownerGlobalURI
				if _, serr := q.SetAssignmentRecipient(stepCtx, db.SetAssignmentRecipientParams{
					ID:          row.ID,
					ToPrincipal: &owner,
				}); serr != nil {
					return fmt.Errorf("set assignment recipient: %w", serr)
				}
			}
			parent, lerr := latestTransitionIDInTx(stepCtx, tx, taskID)
			if lerr != nil {
				return lerr
			}
			payload := lifecycle.AssignmentCreatedPayload{
				AssignmentID: row.ID,
				Stage:        stage,
				Ask:          row.Ask,
			}
			if _, werr := lifecycle.WriteAuditMessage(stepCtx, tx, taskID, lifecycle.SystemActorURI, lifecycle.KindAssignmentCreated, payload, parent); werr != nil {
				return werr
			}
			assignmentID = row.ID
			return nil
		})
		return assignmentID, err
	}, dbos.WithStepName("chain.open_assignment."+string(stage)))
	if err != nil {
		return err
	}
	// Post-commit push enqueue. Run as a separate DBOS step so the enqueue
	// itself is crash-safe and idempotent (research R3). nil PushEnqueuer
	// is a no-op for tests + CI-without-credentials.
	if d.push != nil && outerAssignmentID != uuid.Nil && d.ownerGlobalURI != "" {
		_, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
			return struct{}{}, d.push.EnqueuePush(stepCtx, PushJobPayload{
				TaskID:             taskID,
				AssignmentID:       outerAssignmentID,
				RecipientGlobalURI: d.ownerGlobalURI,
				DeepLinkID:         outerAssignmentID.String(),
				Title:              "tendant",
			})
		}, dbos.WithStepName("chain.enqueue_push."+string(stage)))
		if err != nil {
			return err
		}
	}
	return nil
}

// runResolveAndAdvanceStep closes the open assignment, writes the
// assignment_resolved audit row (chained to the open's audit row), advances
// the chain stage, and — at EXPANSION→EXECUTION — also transitions
// ACCEPTED → EXECUTING (or WAITING) via the readiness predicate.
func runResolveAndAdvanceStep(
	ctx dbos.DBOSContext,
	d *envDeps,
	taskID uuid.UUID,
	stage, nextStage lifecycle.ChainStage,
	result json.RawMessage,
) error {
	stepName := "chain.resolve_and_advance." + string(stage) + "_to_" + string(nextStage)
	_, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		stepCtx = detachCancel(stepCtx)
		err := pgx.BeginFunc(stepCtx, d.pool, func(tx pgx.Tx) error {
			q := db.New(tx)
			// Unfiltered lookup (open OR already-closed): the completeTask
			// resolver closes the assignment synchronously so the inbox drops
			// it immediately, which can win the race against this step. Using
			// the resolved_at-agnostic query keeps this step the sole author of
			// the assignment_resolved audit regardless of who closed the row.
			open, ferr := q.FindLatestAssignmentForStage(stepCtx, db.FindLatestAssignmentForStageParams{
				TaskID: taskID,
				Stage:  stage,
			})
			if ferr != nil && !errors.Is(ferr, pgx.ErrNoRows) {
				return fmt.Errorf("find assignment: %w", ferr)
			}
			if ferr == nil {
				// Idempotent close — no-op (ErrNoRows) if the resolver already
				// closed it; the audit below is still written exactly once.
				if _, rerr := q.ResolveAssignment(stepCtx, db.ResolveAssignmentParams{
					ID:         open.ID,
					ResolvedAt: time.Now().UTC(),
				}); rerr != nil && !errors.Is(rerr, pgx.ErrNoRows) {
					return fmt.Errorf("resolve assignment: %w", rerr)
				}
				openCreatedAuditID, aerr := findAssignmentCreatedAuditID(stepCtx, tx, taskID, open.ID)
				if aerr != nil {
					return aerr
				}
				payload := lifecycle.AssignmentResolvedPayload{
					AssignmentID: open.ID,
					Stage:        stage,
					Result:       result,
				}
				if _, werr := lifecycle.WriteAuditMessage(stepCtx, tx, taskID, lifecycle.SystemActorURI, lifecycle.KindAssignmentResolved, payload, openCreatedAuditID); werr != nil {
					return werr
				}
			}

			if _, aerr := lifecycle.AdvanceStage(stepCtx, tx, taskID, stage, nextStage, ""); aerr != nil {
				return aerr
			}

			if stage == lifecycle.StageExpansion && nextStage == lifecycle.StageExecution {
				ready, rerr := EvaluateReadiness(stepCtx, db.New(tx), taskID)
				if rerr != nil {
					return fmt.Errorf("evaluate readiness: %w", rerr)
				}
				task, terr := q.GetTask(stepCtx, taskID)
				if terr != nil {
					return fmt.Errorf("get task: %w", terr)
				}
				if task.State == lifecycle.StateAccepted {
					target := lifecycle.StateWaiting
					reason := "readiness predicate false"
					if ready {
						target = lifecycle.StateExecuting
						reason = "readiness predicate true"
					}
					if _, terr := lifecycle.Transition(stepCtx, tx, taskID, lifecycle.StateAccepted, target, reason, lifecycle.StageExecution); terr != nil {
						return terr
					}
				}
			}
			return nil
		})
		return struct{}{}, err
	}, dbos.WithStepName(stepName))
	return err
}

// runCompletionStep transitions EXECUTING → DONE and closes the
// chain_workflows row. Last step before the workflow returns successfully.
func runCompletionStep(ctx dbos.DBOSContext, d *envDeps, taskID uuid.UUID) error {
	_, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		stepCtx = detachCancel(stepCtx)
		err := pgx.BeginFunc(stepCtx, d.pool, func(tx pgx.Tx) error {
			q := db.New(tx)
			task, gerr := q.GetTask(stepCtx, taskID)
			if gerr != nil {
				return fmt.Errorf("get task at completion: %w", gerr)
			}
			if task.State == lifecycle.StateExecuting {
				if _, terr := lifecycle.Transition(stepCtx, tx, taskID, lifecycle.StateExecuting, lifecycle.StateDone, "completion finished", lifecycle.StageCompletion); terr != nil {
					return terr
				}
			}
			if err := q.EndChainWorkflow(stepCtx, db.EndChainWorkflowParams{
				Status:  "success",
				EndedAt: time.Now().UTC(),
				TaskID:  taskID,
			}); err != nil {
				return fmt.Errorf("end chain workflow: %w", err)
			}
			return nil
		})
		return struct{}{}, err
	}, dbos.WithStepName("chain.completion"))
	return err
}

// HandleCancelCleanup writes state → HALTED, audits the cancel with
// in_reply_to = latest prior transition, and closes the chain_workflows row.
// Runs OUTSIDE the workflow (in the cancelTask resolver) so it doesn't
// depend on DBOS step infrastructure when the workflow has been cancelled
// in the DB. Idempotent: re-running on an already-cancelled task is a no-op.
func HandleCancelCleanup(ctx context.Context, pool *pgxpool.Pool, taskID uuid.UUID) error {
	return pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		task, gerr := q.GetTaskForUpdate(ctx, taskID)
		if gerr != nil {
			return fmt.Errorf("get task at cancel: %w", gerr)
		}
		if !lifecycle.IsTerminal(task.State) {
			if _, terr := lifecycle.Transition(ctx, tx, taskID, task.State, lifecycle.StateHalted, "cancelled by owner", task.CurrentStage); terr != nil {
				return terr
			}
		}
		parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
		if perr != nil {
			return perr
		}
		payload := lifecycle.WorkflowCancelledPayload{Reason: "cancelled by owner"}
		if _, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, lifecycle.KindWorkflowCancelled, payload, parent); werr != nil {
			return werr
		}
		if err := q.EndChainWorkflow(ctx, db.EndChainWorkflowParams{
			Status:  "cancelled",
			EndedAt: time.Now().UTC(),
			TaskID:  taskID,
		}); err != nil {
			return fmt.Errorf("end chain workflow on cancel: %w", err)
		}
		return nil
	})
}

// latestTransitionIDInTx fetches the most recent transition row id using the
// open tx so the read sees uncommitted rows from earlier in the same step.
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

// findAssignmentCreatedAuditID returns the id of the assignment_created
// audit row for the given assignment, so the matching assignment_resolved
// row's in_reply_to can point at it.
func findAssignmentCreatedAuditID(ctx context.Context, tx pgx.Tx, taskID, assignmentID uuid.UUID) (uuid.UUID, error) {
	row := tx.QueryRow(ctx, `
		SELECT id FROM audit_messages
		WHERE task_id = $1
		  AND kind = $2
		  AND (payload->>'assignment_id')::uuid = $3
		ORDER BY at DESC, id DESC
		LIMIT 1`, taskID, lifecycle.KindAssignmentCreated, assignmentID)
	var id uuid.UUID
	if err := row.Scan(&id); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, nil
		}
		return uuid.Nil, fmt.Errorf("find assignment_created audit row: %w", err)
	}
	return id, nil
}
