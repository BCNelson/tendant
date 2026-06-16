// Package durable wraps DBOS Transact for the tendant core. Phase 1 adds
// chain-workflow registration; the throwaway demo still lives in cmd/dbosdemo.
package durable

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/feedback"
	"github.com/bcnelson/tendant/services/api/internal/toolflow"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// AppName is the DBOS application identifier.
const AppName = "tendant"

// Init constructs a DBOSContext bound to the given pgx pool. DBOS isolates its
// own tables in the `dbos` schema; app tables stay in `public`.
//
// executorID pins the DBOS executor identity for recovery — keep it stable
// across restarts so PENDING workflows for this executor are recovered on
// Launch. The main binary uses "tendant"; the recovery demo overrides to
// "demo" so its workflows don't collide with main.
//
// EnablePatching pins the DBOS application version to a stable constant
// ("PATCHING_ENABLED") instead of the auto-computed binary hash. This matters
// because Launch's recovery only re-runs PENDING workflows whose
// application_version matches the current one: with the binary hash, every
// rebuild orphaned in-flight human-wait workflows (they stayed PENDING with
// no goroutine in Recv, so completing the assignment delivered a notification
// nothing consumed). With patching on, the version is stable across rebuilds
// so those workflows recover. The trade-off is that DBOS no longer guards
// step-replay against changed code automatically — use dbos.Patch /
// dbos.DeprecatePatch when a registered workflow's step sequence changes
// incompatibly. (DBOS__APPVERSION still overrides if ever set.)
func Init(ctx context.Context, pool *pgxpool.Pool, executorID string) (dbos.DBOSContext, error) {
	return dbos.NewDBOSContext(ctx, dbos.Config{
		AppName:        AppName,
		SystemDBPool:   pool,
		DatabaseSchema: "dbos",
		ExecutorID:     executorID,
		EnablePatching: true,
	})
}

// RecoverOrphans re-enqueues PENDING workflows for this executor that were
// created under a DIFFERENT application version than the one now running.
// Launch's built-in recovery filters PENDING workflows by the CURRENT
// application_version, so a workflow created by an older binary (before the
// version was pinned via EnablePatching, or by a different release) is
// orphaned: it stays PENDING with no live goroutine in Recv, so a delivered
// notification (e.g. completeTask's stage:execution Send) is never consumed
// and the workflow never advances.
//
// ResumeWorkflow re-enqueues each orphan onto the running executor; on
// re-execution the workflow replays its memoized steps and the replayed Recv
// consumes the already-present notification, advancing to completion — without
// re-prompting any human.
//
// MUST run AFTER Launch (the workflow functions must be registered and the
// internal queue dispatcher running). Gated to the given workflow names so
// only known tendant workflows are touched. Idempotent: rows already on the
// current version are skipped (a live goroutine owns those), and terminal
// workflows are excluded by ResumeWorkflow.
//
// Each orphan is first ADOPTED into the current application version, then
// resumed. The adoption is required: ResumeWorkflow re-enqueues onto the
// internal queue but leaves application_version untouched, and the queue
// dispatcher only dequeues rows whose application_version matches the current
// one (or is NULL). Without the rewrite a resumed orphan would sit ENQUEUED
// forever. Adopting is correct here because the version is now pinned stable
// (EnablePatching) — these workflows belong to the running code.
func RecoverOrphans(ctx dbos.DBOSContext, pool *pgxpool.Pool, names ...string) error {
	current := ctx.GetApplicationVersion()
	pending, err := dbos.ListWorkflows(ctx,
		dbos.WithStatus([]dbos.WorkflowStatusType{dbos.WorkflowStatusPending}),
		dbos.WithExecutorIDs([]string{ctx.GetExecutorID()}),
		dbos.WithName(names...),
	)
	if err != nil {
		return fmt.Errorf("durable: list pending for orphan recovery: %w", err)
	}
	var resumed, skipped int
	for _, wf := range pending {
		if wf.ApplicationVersion == current {
			continue // current-version PENDING rows are already owned/recovered
		}
		if _, uerr := pool.Exec(context.Background(),
			`UPDATE dbos.workflow_status SET application_version = $1 WHERE workflow_uuid = $2`,
			current, wf.ID); uerr != nil {
			slog.Error("durable: orphan version adopt failed",
				"workflow_id", wf.ID, "name", wf.Name, "err", uerr)
			skipped++
			continue
		}
		if _, rerr := dbos.ResumeWorkflow[any](ctx, wf.ID); rerr != nil {
			slog.Error("durable: orphan resume failed",
				"workflow_id", wf.ID, "name", wf.Name,
				"orphan_version", wf.ApplicationVersion, "current_version", current,
				"err", rerr)
			skipped++
			continue
		}
		slog.Info("durable: resumed orphaned workflow",
			"workflow_id", wf.ID, "name", wf.Name,
			"orphan_version", wf.ApplicationVersion, "current_version", current)
		resumed++
	}
	if resumed > 0 || skipped > 0 {
		slog.Info("durable: orphan recovery complete", "resumed", resumed, "skipped", skipped)
	}
	return nil
}

// Launch starts the DBOS runtime (creates the `dbos` schema if needed,
// recovers PENDING workflows for this executor). Launch returning nil is the
// DBOS readiness signal (FR-012 / US4-AC1).
func Launch(ctx dbos.DBOSContext) error {
	return dbos.Launch(ctx)
}

// Shutdown gracefully tears down DBOS within the given timeout.
func Shutdown(ctx dbos.DBOSContext, timeout time.Duration) {
	dbos.Shutdown(ctx, timeout)
}

// RegisterChainWorkflow registers the chain workflow with DBOS, closing over
// its runtime deps. MUST be called between Init and Launch — Launch performs
// recovery against the registered function, so the function must be in place
// beforehand. Wires the deps through chain.Register.
//
// ownerGlobalURI populates agent_assignments.to_principal for Phase 2;
// pushEnqueuer (nil-able) schedules push fan-out on assignment open.
func RegisterChainWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, router chain.Router, runner chain.StageRunner, ownerGlobalURI string, pushEnqueuer chain.PushEnqueuer, feedbackEnqueuer chain.FeedbackEnqueuer, timeouts chain.Timeouts, agentStarter chain.AgentStarter) {
	chain.Register(dctx, pool, q, router, runner, ownerGlobalURI, pushEnqueuer, feedbackEnqueuer, timeouts, agentStarter)
}

// RegisterFeedbackWorkflow registers the post-completion feedback workflow
// (open conversation → FeedbackRequest → await accept/dismiss → audit +
// calibration). MUST be called between Init and Launch, like the chain and
// tool-call workflows. converser opens the conversation (stub when no agent
// connection); calibrator routes the satisfaction signal.
func RegisterFeedbackWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, converser feedback.Converser, retriever feedback.Retriever, calibrator *calibration.Engine, timeouts chain.Timeouts) {
	feedback.Register(dctx, pool, q, converser, retriever, calibrator, timeouts)
}

// PushQueueName is the named DBOS workflow queue used for push fan-out.
const PushQueueName = "push"

// RegisterPushQueue declares the named DBOS workflow queue for push fan-out
// and (when handler is non-nil) registers the per-job workflow against it.
// MUST be called between Init and Launch. handler nil signals "no real
// workers wired this boot" — useful when only LogProvider is configured
// (the chain workflow's push enqueue still records the work via the
// recordingPushEnqueuer-style hook in `chain.Register`).
func RegisterPushQueue(dctx dbos.DBOSContext) {
	_ = dbos.NewWorkflowQueue(dctx, PushQueueName,
		dbos.WithWorkerConcurrency(4),
	)
}

// RegisterAgentStageWorkflow registers the durable agent-stage workflow (the
// Phase-B inline-durable-wait path). MUST be called between Init and Launch. A
// nil runner is a no-op-friendly registration: the workflow registers but is
// never started (the chain falls back to human-only routing).
func RegisterAgentStageWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, runner *agent.Runner, timeouts chain.Timeouts) {
	agent.RegisterStageWorkflow(dctx, pool, q, runner, timeouts)
}

// RegisterToolCallWorkflow registers Phase 3's sibling workflow that owns
// the lifecycle of a single gated tool call (await approval → dispatch →
// record outcome). MUST be called between Init and Launch, like the chain
// workflow. The registry carries the tool implementations the workflow
// dispatches against.
func RegisterToolCallWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, registry *tools.Registry, calibrator *calibration.Engine, timeouts chain.Timeouts) {
	toolflow.Register(dctx, pool, q, registry, calibrator, timeouts)
}
