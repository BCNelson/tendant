package graph_test

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/router"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// testAgentStarter mirrors cmd/tendant's agentStageStarter: it starts the
// durable AgentStageWorkflow and awaits its StageResult. Wired into the chain
// by bootChainEnv when an agent-stage runner is provided, so the B10 cutover
// (chain → durable agent) can be driven end-to-end.
type testAgentStarter struct{}

func (testAgentStarter) StartStageAndAwait(ctx dbos.DBOSContext, taskID uuid.UUID, stage lifecycle.ChainStage, configID uuid.UUID) (json.RawMessage, error) {
	agentStage, ok := chainStageToAgentStage(stage)
	if !ok {
		return nil, fmt.Errorf("stage %s is not agent-occupiable", stage)
	}
	h, err := dbos.RunWorkflow(ctx, agent.AgentStageWorkflow, agent.StageInput{
		TaskID:   taskID,
		Stage:    agentStage,
		ConfigID: configID,
	}, dbos.WithWorkflowID(agent.StageWorkflowID(taskID, agentStage)))
	if err != nil {
		return nil, err
	}
	res, err := h.GetResult()
	if err != nil {
		return nil, err
	}
	return json.RawMessage(res), nil
}

// alwaysRequestDecisionGate forces every agent tool call onto the human-approval
// path so the durable wait is exercised deterministically.
type alwaysRequestDecisionGate struct{}

func (alwaysRequestDecisionGate) EvaluateCall(_ context.Context, _, _ uuid.UUID, _ json.RawMessage) (agent.GateVerdict, error) {
	return agent.GateVerdict{Decision: "request_decision"}, nil
}

// startAgentStage starts the durable AgentStageWorkflow for a (task, execution,
// config) and returns its handle.
func startAgentStage(t *testing.T, env *chainEnv, taskID, configID uuid.UUID) dbos.WorkflowHandle[string] {
	t.Helper()
	h, err := dbos.RunWorkflow(env.dctx, agent.AgentStageWorkflow, agent.StageInput{
		TaskID:   taskID,
		Stage:    db.AgentStageExecution,
		ConfigID: configID,
	}, dbos.WithWorkflowID(agent.StageWorkflowID(taskID, db.AgentStageExecution)))
	require.NoError(t, err)
	return h
}

// pollOpenApprovalForTask returns the first open approval_request decision for
// the task (the one the agent workflow registered before waiting).
func pollOpenApprovalForTask(t *testing.T, env *chainEnv, taskID uuid.UUID) db.PendingDecision {
	t.Helper()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		rows, err := env.queries.ListOpenPendingDecisions(context.Background())
		require.NoError(t, err)
		for _, r := range rows {
			if r.TaskID == taskID && r.Kind == db.DecisionKindApprovalRequest {
				return r
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for an open approval decision on task %s", taskID)
	return db.PendingDecision{}
}

// TestAgentDurableWait_ApprovalInjected proves the Phase-B happy path: the agent
// proposes a gated tool call, the workflow durably waits, a human approves, the
// tool dispatches, and the outcome is injected back into the loop so the agent
// completes — all in one durable run (no fail-close to a human stage).
func TestAgentDurableWait_ApprovalInjected(t *testing.T) {
	ctx := context.Background()
	recorder := newRecordingEmailProvider()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(recorder))

	client := &agent.LogAgentClient{Fixtures: []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "send-email",
			Payload: `{"to":"local://principal/owner","subject":"hi","body":"there"}`}}},
		{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"sent after approval"}}`},
	}}

	env := newChainEnv(t,
		withToolRegistry(registry),
		withAgentStageRunner(func(pool *pgxpool.Pool, q *db.Queries, reg *tools.Registry) *agent.Runner {
			return &agent.Runner{
				Client:     client,
				Gate:       alwaysRequestDecisionGate{},
				Dispatcher: testDispatcher{q: q, registry: reg},
				Auditor:    testAuditWriter{pool: pool},
				Queries:    q,
				MaxIter:    10,
				Budget:     10,
			}
		}),
	)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	configID := seedExecutionAgent(t, env, []uuid.UUID{tool.ID})
	taskID := createTaskGQL(t, env, "durable approval injection")

	handle := startAgentStage(t, env, taskID, configID)

	// The workflow registered an approval and is waiting. Approve it.
	decision := pollOpenApprovalForTask(t, env, taskID)
	require.NotNil(t, decision.NotifyWorkflowID, "agent-registered decision must carry the back-channel target")
	approveArtifactGQL(t, env, decision.ID)

	// The durable run resumes with the tool result injected and completes.
	resultJSON, err := handle.GetResult()
	require.NoError(t, err)
	require.NotContains(t, resultJSON, `"fail_close_to_human":true`, "an approved+dispatched call must not fail-close")
	require.True(t, recorder.wasCalled(), "the approved send-email must have dispatched")
}

// TestAgentDurableWait_TimeoutInjectsHumanNoResponse proves the headline Phase-B
// behavior: when the human never answers, the tool-call workflow expires and the
// agent loop receives an explicit human_no_response error inline, lets the model
// react, and completes — instead of dying as ERROR.
func TestAgentDurableWait_TimeoutInjectsHumanNoResponse(t *testing.T) {
	ctx := context.Background()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(newRecordingEmailProvider()))

	// Turn 1 proposes a gated call; turn 2 (after the injected human_no_response)
	// the model gives up gracefully and finishes.
	client := &agent.LogAgentClient{Fixtures: []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "send-email",
			Payload: `{"to":"local://principal/owner","subject":"hi","body":"there"}`}}},
		{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"no human response; proceeding without the tool"}}`},
	}}

	env := newChainEnv(t,
		withToolRegistry(registry),
		withTimeouts(fixedTimeouts{approval: 50 * time.Millisecond}),
		withAgentStageRunner(func(pool *pgxpool.Pool, q *db.Queries, reg *tools.Registry) *agent.Runner {
			return &agent.Runner{
				Client:     client,
				Gate:       alwaysRequestDecisionGate{},
				Dispatcher: testDispatcher{q: q, registry: reg},
				Auditor:    testAuditWriter{pool: pool},
				Queries:    q,
				MaxIter:    10,
				Budget:     10,
			}
		}),
	)

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	configID := seedExecutionAgent(t, env, []uuid.UUID{tool.ID})
	taskID := createTaskGQL(t, env, "durable approval timeout")

	handle := startAgentStage(t, env, taskID, configID)

	// No approval: the toolflow approval wait expires after 50ms and reports back.
	resultJSON, err := handle.GetResult()
	require.NoError(t, err, "an expired approval must not poison the agent workflow to ERROR")

	var sr agent.StageResult
	require.NoError(t, json.Unmarshal([]byte(resultJSON), &sr))
	require.False(t, sr.FailCloseToHuman, "the agent reacted to human_no_response and completed")
	require.NotNil(t, sr.Findings)
	require.True(t, strings.Contains(sr.Findings.FreeText, "no human response") ||
		strings.Contains(sr.Findings.FreeText, "proceeding"),
		"the model's post-timeout turn should drive the result")

	// The expired decision was resolved + audited (drops from the inbox).
	d := pollExpiredDecision(t, env, taskID)
	require.True(t, d.ResolvedAt.Valid)
	require.GreaterOrEqual(t, auditKindCount(t, env, taskID)[lifecycle.KindDecisionExpired], 1)
}

// TestChainAgentDurableApproval_EndToEnd is the B10 cutover proof: a task whose
// EXECUTION stage routes to an agent now runs through the durable
// AgentStageWorkflow. The agent proposes a gated tool call, the chain durably
// waits, the owner approves, the tool dispatches, the agent completes, and the
// chain advances to DONE — all without a synchronous in-step agent run.
func TestChainAgentDurableApproval_EndToEnd(t *testing.T) {
	ctx := context.Background()
	recorder := newRecordingEmailProvider()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(recorder))

	client := &agent.LogAgentClient{Fixtures: []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "send-email",
			Payload: `{"to":"local://principal/owner","subject":"hi","body":"there"}`}}},
		{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"sent after durable approval"}}`},
	}}

	env := newChainEnv(t,
		withToolRegistry(registry),
		// Router sends EXECUTION to an agent; the synchronous runner is nil
		// because the durable starter (wired when agentStage is set) owns the run.
		withAgentChain(func(pool *pgxpool.Pool, q *db.Queries, reg *tools.Registry) (chain.Router, chain.StageRunner, string) {
			return testChainRouter{inner: router.New(q, testPicker{})}, nil, "local://principal/owner"
		}),
		withAgentStageRunner(func(pool *pgxpool.Pool, q *db.Queries, reg *tools.Registry) *agent.Runner {
			return &agent.Runner{
				Client:     client,
				Gate:       alwaysRequestDecisionGate{},
				Dispatcher: testDispatcher{q: q, registry: reg},
				Auditor:    testAuditWriter{pool: pool},
				Queries:    q,
				MaxIter:    10,
				Budget:     10,
			}
		}),
	)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	seedExecutionAgent(t, env, []uuid.UUID{tool.ID})

	taskID := createTaskGQL(t, env, "durable agent through the chain")
	walkHumanStagesToExecution(t, env, taskID)

	// The chain started the durable agent workflow; the agent is waiting on an
	// approval. Approve it, and the chain should complete autonomously.
	decision := pollOpenApprovalForTask(t, env, taskID)
	approveArtifactGQL(t, env, decision.ID)

	pollUntilTaskState(t, env, taskID, db.TaskStateDone)
	require.True(t, recorder.wasCalled(), "the approved send-email must have dispatched via the durable path")
}

// pollExpiredDecision waits for the task's approval decision to resolve as expired.
func pollExpiredDecision(t *testing.T, env *chainEnv, taskID uuid.UUID) db.PendingDecision {
	t.Helper()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		rows, err := env.queries.ListAuditForTask(context.Background(), taskID)
		require.NoError(t, err)
		for _, r := range rows {
			if r.Kind == lifecycle.KindDecisionExpired {
				var p lifecycle.DecisionExpiredPayload
				require.NoError(t, json.Unmarshal(r.Payload, &p))
				dec, derr := env.queries.GetPendingDecisionByID(context.Background(), p.DecisionID)
				require.NoError(t, derr)
				return dec
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for an expired decision on task %s", taskID)
	return db.PendingDecision{}
}
