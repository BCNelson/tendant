package feedback

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
)

// WorkflowName is the DBOS workflow name for the feedback workflow.
const WorkflowName = "tendant.feedback"

// WorkflowIDPrefix / FeedbackTopicPrefix are the deterministic prefixes. Both
// the workflow id and the wait topic key on the DECISION id so the
// accept/dismiss resolvers — which only know the decision id — can derive both
// without a task lookup (mirrors toolflow's approval topic).
const (
	WorkflowIDPrefix    = "feedback:"
	FeedbackTopicPrefix = "feedbacktopic:"
)

// feedbackNamespace derives a deterministic decision id from a task id so the
// open step is idempotent under recovery (re-running never double-creates).
var feedbackNamespace = uuid.MustParse("f33dbac0-0000-4000-8000-000000000001")

// DecisionID is the deterministic feedback pending_decisions id for a task.
func DecisionID(taskID uuid.UUID) uuid.UUID { return uuid.NewSHA1(feedbackNamespace, taskID[:]) }

// WorkflowID / FeedbackTopic derive from the decision id.
func WorkflowID(decisionID uuid.UUID) string    { return WorkflowIDPrefix + decisionID.String() }
func FeedbackTopic(decisionID uuid.UUID) string { return FeedbackTopicPrefix + decisionID.String() }

// DecisionPayload is the JSON shape stored in a feedback_request
// pending_decisions.payload: the agent's current draft guidance, the task
// summary the resolver needs to continue the conversation, and the set of
// read-only context tools the agent has consulted so far (surfaced in the UI).
type DecisionPayload struct {
	DraftGuidance    string      `json:"draft_guidance"`
	TaskSummary      TaskSummary `json:"task_summary"`
	ContextConsulted []string    `json:"context_consulted,omitempty"`
}

// envDeps closes over the workflow's runtime dependencies. Set once by Register.
type envDeps struct {
	pool       *pgxpool.Pool
	queries    *db.Queries
	converser  Converser
	retriever  Retriever
	calibrator *calibration.Engine
	timeouts   chain.Timeouts // feedback-wait window; nil ⇒ legacy 72h
}

var (
	depsMu sync.RWMutex
	deps   *envDeps
)

// Register stores deps and registers EvaluationWorkflow with DBOS. MUST be
// called between dbos.NewDBOSContext and dbos.Launch.
func Register(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, converser Converser, retriever Retriever, calibrator *calibration.Engine, timeouts chain.Timeouts) {
	depsMu.Lock()
	deps = &envDeps{pool: pool, queries: q, converser: converser, retriever: retriever, calibrator: calibrator, timeouts: timeouts}
	depsMu.Unlock()
	dbos.RegisterWorkflow(dctx, EvaluationWorkflow, dbos.WithWorkflowName(WorkflowName))
}

func loadDeps() (*envDeps, error) {
	depsMu.RLock()
	d := deps
	depsMu.RUnlock()
	if d == nil {
		return nil, errors.New("feedback.Register was not called before workflow ran")
	}
	return d, nil
}

// Enqueuer is the seam internal/chain uses to start the feedback workflow at
// completion, without importing this package (mirrors chain.PushEnqueuer). It
// is a thin adapter: the chain workflow passes its own DBOS context so the
// feedback workflow is started as a durable child of the chain workflow.
type Enqueuer struct{}

// EnqueueFeedback satisfies chain.FeedbackEnqueuer.
func (Enqueuer) EnqueueFeedback(ctx dbos.DBOSContext, taskID uuid.UUID) error {
	return StartFeedbackWorkflow(ctx, taskID)
}

// StartFeedbackWorkflow kicks off EvaluationWorkflow with the deterministic id.
// Idempotent under retry — DBOS dedupes on the workflow id.
func StartFeedbackWorkflow(ctx dbos.DBOSContext, taskID uuid.UUID) error {
	wfID := WorkflowID(DecisionID(taskID))
	_, err := dbos.RunWorkflow(ctx, EvaluationWorkflow, taskID.String(), dbos.WithWorkflowID(wfID))
	return err
}

// terminalEnvelope is what acceptFeedbackGuidance / dismissFeedback Send to wake
// the workflow once the owner finishes the conversation.
type terminalEnvelope struct {
	Accepted    bool       `json:"accepted"`
	Rating      int        `json:"rating"`
	GuidanceID  *uuid.UUID `json:"guidance_id,omitempty"`
	SubmittedBy string     `json:"submitted_by"`
	DecisionID  uuid.UUID  `json:"decision_id"`
}

// ResolveFeedback is the resolver-facing wake primitive. Called by
// acceptFeedbackGuidance / dismissFeedback after the decision row has been
// marked resolved (and, on accept, the verbatim guidance row inserted).
func ResolveFeedback(ctx dbos.DBOSContext, decisionID uuid.UUID, accepted bool, rating int, guidanceID *uuid.UUID, submittedBy string) error {
	raw, err := json.Marshal(terminalEnvelope{
		Accepted:    accepted,
		Rating:      rating,
		GuidanceID:  guidanceID,
		SubmittedBy: submittedBy,
		DecisionID:  decisionID,
	})
	if err != nil {
		return fmt.Errorf("marshal terminal envelope: %w", err)
	}
	return chain.Resolve(ctx, WorkflowID(decisionID), FeedbackTopic(decisionID), raw)
}

// EvaluationWorkflow owns one task's feedback loop. Input is the task id as a
// string. Step sequence is fixed (DBOS replay invariant): open → wait → record.
func EvaluationWorkflow(ctx dbos.DBOSContext, taskIDStr string) (string, error) {
	taskID, err := uuid.Parse(taskIDStr)
	if err != nil {
		return "", fmt.Errorf("invalid taskID: %w", err)
	}
	d, err := loadDeps()
	if err != nil {
		return "", err
	}
	decisionID := DecisionID(taskID)

	// Step 1: open the conversation + persist the FeedbackRequest (memoized).
	if err := runOpenStep(ctx, d, taskID, decisionID); err != nil {
		return "", err
	}

	// Step 2: durable wait for the owner's terminal accept/dismiss. On timeout
	// the feedback request is silently dismissed (feedback is best-effort; an
	// unanswered survey shouldn't dangle in the inbox or poison the workflow).
	timeout := chain.FeedbackTimeoutOr(d.timeouts)
	raw, err := chain.WaitForResultOrExpire(ctx, FeedbackTopic(decisionID), timeout)
	if errors.Is(err, chain.ErrHumanWaitExpired) {
		_, serr := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
			return struct{}{}, expireFeedback(stepCtx, d, taskID, decisionID, timeout)
		}, dbos.WithStepName("feedback.expire"))
		if serr != nil {
			return "", serr
		}
		return "expired", nil
	}
	if err != nil {
		return "", fmt.Errorf("await feedback resolution: %w", err)
	}
	var env terminalEnvelope
	if uerr := json.Unmarshal(raw, &env); uerr != nil {
		return "", fmt.Errorf("decode terminal envelope: %w", uerr)
	}

	// Step 3: record the terminal audit + route the rating into calibration.
	_, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		return struct{}{}, recordFeedback(stepCtx, d, taskID, decisionID, env)
	}, dbos.WithStepName("feedback.record"))
	if err != nil {
		return "", err
	}
	return "ok", nil
}

// expireFeedback silently dismisses a timed-out feedback request: resolve the
// pending_decisions row as expired (clearing it from the inbox) and record a
// decision_expired audit. No guidance row, no calibration signal — an
// unanswered survey carries no information.
func expireFeedback(ctx context.Context, d *envDeps, taskID, decisionID uuid.UUID, timeout time.Duration) error {
	resolution, err := json.Marshal(map[string]any{
		"expired": true,
		"reason":  "no_response",
	})
	if err != nil {
		return fmt.Errorf("marshal expired resolution: %w", err)
	}
	if _, err := d.queries.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
		ID:         decisionID,
		ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
		Resolution: resolution,
	}); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			slog.WarnContext(ctx, "feedback.expire_skipped_already_resolved", "decision_id", decisionID)
			return nil
		}
		return fmt.Errorf("resolve feedback expired: %w", err)
	}

	return pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
		if perr != nil {
			return perr
		}
		_, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindDecisionExpired,
			lifecycle.DecisionExpiredPayload{
				DecisionID: decisionID,
				Flow:       string(db.DecisionKindFeedbackRequest),
				Timeout:    timeout.String(),
			},
			parent,
		)
		return werr
	})
}

// runOpenStep loads the task, asks the converser for an opening message + draft,
// and persists a feedback_request pending_decision + the opening agent message +
// audit. Idempotent: skips if the deterministic decision row already exists.
func runOpenStep(ctx dbos.DBOSContext, d *envDeps, taskID, decisionID uuid.UUID) error {
	_, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (struct{}, error) {
		if _, gerr := d.queries.GetPendingDecisionByID(stepCtx, decisionID); gerr == nil {
			return struct{}{}, nil // recovery: already opened
		} else if !errors.Is(gerr, pgx.ErrNoRows) {
			return struct{}{}, fmt.Errorf("check existing feedback decision: %w", gerr)
		}

		task, terr := d.queries.GetTask(stepCtx, taskID)
		if terr != nil {
			return struct{}{}, fmt.Errorf("load task for feedback: %w", terr)
		}
		summary := summaryFromTask(task)
		summary.TaskID = taskID

		opening, draft, consulted, gerr := d.converser.Open(stepCtx, summary)
		if gerr != nil {
			slog.Warn("feedback: opener failed; using a generic prompt", "task", taskID, "err", gerr)
			opening, draft, consulted = "How did this task go? Anything you'd want handled differently next time?", "", nil
		}

		payload, merr := json.Marshal(DecisionPayload{DraftGuidance: draft, TaskSummary: summary, ContextConsulted: consulted})
		if merr != nil {
			return struct{}{}, fmt.Errorf("marshal decision payload: %w", merr)
		}

		err := pgx.BeginFunc(stepCtx, d.pool, func(tx pgx.Tx) error {
			tag, ierr := tx.Exec(stepCtx,
				`INSERT INTO pending_decisions (id, task_id, kind, payload)
				 VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO NOTHING`,
				decisionID, taskID, db.DecisionKindFeedbackRequest, payload)
			if ierr != nil {
				return fmt.Errorf("insert feedback decision: %w", ierr)
			}
			if tag.RowsAffected() == 0 {
				return nil // raced; opening already written
			}
			q := db.New(tx)
			if _, merr := q.InsertFeedbackMessage(stepCtx, db.InsertFeedbackMessageParams{
				DecisionID: decisionID,
				Role:       "agent",
				Content:    opening,
			}); merr != nil {
				return fmt.Errorf("insert opening message: %w", merr)
			}
			parent, perr := latestTransitionIDInTx(stepCtx, tx, taskID)
			if perr != nil {
				return perr
			}
			openedID, werr := lifecycle.WriteAuditMessage(stepCtx, tx, taskID, lifecycle.SystemActorURI,
				lifecycle.KindFeedbackOpened,
				lifecycle.FeedbackOpenedPayload{DecisionID: decisionID, Converser: d.converser.Label()},
				parent,
			)
			if werr != nil {
				return werr
			}
			// Record what task context the agent reviewed while composing the
			// opener, so the audit DAG shows the basis for its guidance.
			if len(consulted) > 0 {
				if _, aerr := lifecycle.WriteAuditMessage(stepCtx, tx, taskID, lifecycle.SystemActorURI,
					lifecycle.KindFeedbackContextConsulted,
					lifecycle.FeedbackContextConsultedPayload{DecisionID: decisionID, Consulted: consulted},
					openedID,
				); aerr != nil {
					return aerr
				}
			}
			return nil
		})
		return struct{}{}, err
	}, dbos.WithStepName("feedback.open"))
	return err
}

// recordFeedback writes the terminal feedback_submitted audit and — on a
// negative rating — demotes the tools that acted under the task. Guidance (when
// accepted) was already written verbatim by the resolver.
func recordFeedback(ctx context.Context, d *envDeps, taskID, decisionID uuid.UUID, env terminalEnvelope) error {
	negative := env.Rating > 0 && env.Rating <= NegativeRatingThreshold

	if err := pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		parent, perr := latestTransitionIDInTx(ctx, tx, taskID)
		if perr != nil {
			return perr
		}
		_, werr := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindFeedbackSubmitted,
			lifecycle.FeedbackSubmittedPayload{
				DecisionID:  decisionID,
				Accepted:    env.Accepted,
				Rating:      env.Rating,
				Negative:    negative,
				GuidanceID:  env.GuidanceID,
				SubmittedBy: env.SubmittedBy,
			},
			parent,
		)
		return werr
	}); err != nil {
		return err
	}

	if negative && d.calibrator != nil {
		if err := d.calibrator.DemoteForFeedback(ctx, taskID, "negative post-completion feedback"); err != nil {
			return fmt.Errorf("demote for feedback: %w", err)
		}
	}
	return nil
}

// summaryFromTask projects the de-identified task context for the converser.
func summaryFromTask(task db.Task) TaskSummary {
	s := TaskSummary{Title: task.Title, Findings: task.Findings}
	if task.Description != nil {
		s.Description = *task.Description
	}
	return s
}

// latestTransitionIDInTx mirrors chain/toolflow; duplicated to avoid an
// internal-to-internal export. Returns uuid.Nil for the first audit on a task.
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
