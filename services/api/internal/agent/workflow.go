package agent

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/toolflow"
)

// StageWorkflowName is the DBOS workflow name for the durable agent stage loop.
const StageWorkflowName = "tendant.agentstage"

// StageWorkflowIDPrefix is the deterministic prefix for agent-stage workflow
// ids. Full id is `agentstage:<taskID>:<stage>` — one durable agent run per
// (task, stage), idempotent to start.
const StageWorkflowIDPrefix = "agentstage:"

// StageWorkflowID returns the deterministic workflow id for a (task, stage).
func StageWorkflowID(taskID uuid.UUID, stage db.AgentStage) string {
	return StageWorkflowIDPrefix + taskID.String() + ":" + string(stage)
}

// StageInput is the AgentStageWorkflow input. DBOS serializes it via the
// configured serializer.
type StageInput struct {
	TaskID   uuid.UUID     `json:"task_id"`
	Stage    db.AgentStage `json:"stage"`
	ConfigID uuid.UUID     `json:"config_id"`
}

// stageDeps closes over the workflow's runtime dependencies. Set once by
// RegisterStageWorkflow at startup; read-only thereafter.
type stageDeps struct {
	pool     *pgxpool.Pool
	queries  *db.Queries
	runner   *Runner
	timeouts chain.Timeouts
}

var (
	stageDepsMu sync.RWMutex
	stageDepsV  *stageDeps
)

// RegisterStageWorkflow stores deps and registers AgentStageWorkflow with DBOS.
// MUST be called between dbos.NewDBOSContext and dbos.Launch. A nil runner is
// allowed (the workflow is then never started — the chain falls back to human).
func RegisterStageWorkflow(dctx dbos.DBOSContext, pool *pgxpool.Pool, q *db.Queries, runner *Runner, timeouts chain.Timeouts) {
	stageDepsMu.Lock()
	stageDepsV = &stageDeps{pool: pool, queries: q, runner: runner, timeouts: timeouts}
	stageDepsMu.Unlock()
	dbos.RegisterWorkflow(dctx, AgentStageWorkflow, dbos.WithWorkflowName(StageWorkflowName))
}

func loadStageDeps() (*stageDeps, error) {
	stageDepsMu.RLock()
	d := stageDepsV
	stageDepsMu.RUnlock()
	if d == nil || d.runner == nil {
		return nil, errors.New("agent.RegisterStageWorkflow was not called with a runner before the workflow ran")
	}
	return d, nil
}

// StartStageWorkflow starts (or idempotently re-attaches to) the durable agent
// stage workflow for a (task, stage, config). Returns the workflow handle's id.
func StartStageWorkflow(ctx dbos.DBOSContext, in StageInput) error {
	_, err := dbos.RunWorkflow(ctx, AgentStageWorkflow, in,
		dbos.WithWorkflowID(StageWorkflowID(in.TaskID, in.Stage)),
	)
	return err
}

// AgentStageWorkflow runs the agent plan→act→observe loop durably, segment by
// segment. Each segment is a memoized step (the LLM turns + auto-approved
// dispatches up to the next human decision). When a segment stops on a
// request_decision, the workflow registers the approval, starts the tool-call
// workflow, and durably waits on the back-channel for the outcome — which the
// tool-call workflow Sends on approve / reject / timeout. The outcome (or, on
// timeout, a `human_no_response` error) is injected back into the loop and the
// next segment resumes. The returned string is the StageResult JSON the chain
// consumes (same shape RunStage produced before).
func AgentStageWorkflow(ctx dbos.DBOSContext, in StageInput) (string, error) {
	d, err := loadStageDeps()
	if err != nil {
		return "", err
	}

	// Step: load the agent config + task and build the run context. Memoized so
	// replay doesn't re-read.
	rc, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (RunConfig, error) {
		cfg, cerr := d.queries.GetAgentConfigByID(stepCtx, in.ConfigID)
		if cerr != nil {
			return RunConfig{}, fmt.Errorf("load agent config: %w", cerr)
		}
		task, terr := d.queries.GetTask(stepCtx, in.TaskID)
		if terr != nil {
			return RunConfig{}, fmt.Errorf("load task: %w", terr)
		}
		desc := ""
		if task.Description != nil {
			desc = *task.Description
		}
		return RunConfig{
			Config:    cfg,
			TaskID:    in.TaskID,
			TaskTitle: task.Title,
			TaskDesc:  desc,
			Findings:  task.Findings,
		}, nil
	}, dbos.WithStepName("agent.load_run_config"))
	if err != nil {
		return "", err
	}

	selfID := StageWorkflowID(in.TaskID, in.Stage)
	segIn := segmentInput{}
	for {
		seg, serr := dbos.RunAsStep(ctx, func(stepCtx context.Context) (segmentResult, error) {
			return d.runner.runSegment(stepCtx, rc, segIn)
		}, dbos.WithStepName("agent.segment"))
		if serr != nil {
			return "", serr
		}
		if seg.Done {
			out, merr := json.Marshal(seg.Result)
			if merr != nil {
				return "", fmt.Errorf("marshal stage result: %w", merr)
			}
			return string(out), nil
		}

		// request_decision: register the approval (memoized → stable decision id),
		// start the tool-call workflow, then durably wait for its outcome.
		decisionID, rerr := dbos.RunAsStep(ctx, func(stepCtx context.Context) (uuid.UUID, error) {
			return registerApproval(stepCtx, d, in.TaskID, selfID, seg.Pending)
		}, dbos.WithStepName("agent.register_approval"))
		if rerr != nil {
			return "", rerr
		}
		if err := toolflow.StartToolCallWorkflow(ctx, decisionID); err != nil {
			return "", fmt.Errorf("start tool-call workflow: %w", err)
		}

		// Wait with no timeout of our own — the tool-call workflow owns the
		// hitl.approval_timeout and always reports back (approve / reject /
		// expired) on this topic.
		raw, werr := chain.WaitForResultOrExpire(ctx, toolflow.ToolOutcomeTopic(decisionID), 0)
		if werr != nil {
			return "", fmt.Errorf("await tool outcome: %w", werr)
		}
		var env toolflow.OutcomeEnvelope
		if uerr := json.Unmarshal(raw, &env); uerr != nil {
			return "", fmt.Errorf("decode outcome envelope: %w", uerr)
		}
		segIn = segmentInput{State: seg.State, Injected: env.Content}
	}
}

// registerApproval composes the agent-initiated approval_request decision row —
// carrying the back-channel target (this workflow's id) so the tool-call
// workflow knows where to report — with a freshly minted, replay-stable id.
func registerApproval(ctx context.Context, d *stageDeps, taskID uuid.UUID, selfID string, p *pendingApproval) (uuid.UUID, error) {
	if p == nil {
		return uuid.Nil, errors.New("registerApproval: nil pending approval")
	}
	decisionID := uuid.New()
	wfID := toolflow.WorkflowID(decisionID)
	topic := toolflow.ApprovalTopic(decisionID)
	if err := d.queries.InsertApprovalDecision(ctx, db.InsertApprovalDecisionParams{
		ID:               decisionID,
		TaskID:           taskID,
		ToolID:           pgtype.UUID{Bytes: p.ToolID, Valid: true},
		Payload:          p.Payload,
		WorkflowID:       &wfID,
		DecisionTopic:    &topic,
		NotifyWorkflowID: &selfID,
	}); err != nil {
		return uuid.Nil, fmt.Errorf("insert approval decision: %w", err)
	}
	return decisionID, nil
}
