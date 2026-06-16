package graph_test

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gate"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
	"github.com/bcnelson/tendant/services/api/internal/router"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// This file drives the "static resources [config agents] that call tools in
// repeatable ways" flow end-to-end: a catalog AgentConfig occupies the
// EXECUTION stage and a LogAgentClient scripts its turns. The runner, router,
// real gate (floor + overseer), and tool registry are all the production
// components — only the model client is the deterministic fixture stub, so each
// run is byte-for-byte repeatable.
//
// Triage and expansion route to the human (no agent config seeded for those
// stages); only execution is agent-occupied, which isolates the agent→tool path.

// --- deterministic agent-chain wiring (mirrors cmd/tendant/agentwiring.go) ---

// recordingEmailProvider captures the last send-email payload so a test can
// assert the tool actually dispatched (vs. being gated/refused).
type recordingEmailProvider struct {
	mu     chan struct{} // 1-slot mutex
	called bool
	got    tools.SendEmailPayload
}

func newRecordingEmailProvider() *recordingEmailProvider {
	p := &recordingEmailProvider{mu: make(chan struct{}, 1)}
	p.mu <- struct{}{}
	return p
}

func (p *recordingEmailProvider) Send(_ context.Context, payload tools.SendEmailPayload) (tools.Result, error) {
	<-p.mu
	defer func() { p.mu <- struct{}{} }()
	p.called = true
	p.got = payload
	return tools.Result{Provider: "recording"}, nil
}

func (p *recordingEmailProvider) wasCalled() bool {
	<-p.mu
	defer func() { p.mu <- struct{}{} }()
	return p.called
}

// testPicker deterministically picks the first eligible config.
type testPicker struct{}

func (testPicker) Pick(_ context.Context, eligible []db.AgentConfig, _ string) (*db.AgentConfig, error) {
	if len(eligible) == 0 {
		return nil, nil
	}
	c := eligible[0]
	return &c, nil
}

// testPrincipalLookup is the gate.PrincipalLookup the floor uses (mirrors
// graph.principalLookupFromQueries).
type testPrincipalLookup struct{ q *db.Queries }

func (p testPrincipalLookup) IsKnownPrincipal(ctx context.Context, globalURI string) (bool, error) {
	_, err := p.q.GetPrincipalByGlobalURI(ctx, globalURI)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	return err == nil, err
}

// testGateEval adapts the real gate.Gate to agent.GateEvaluator: it loads the
// tool row by ID and runs the full gate (read-only → floor → overseer).
type testGateEval struct {
	q *db.Queries
	g gate.Gate
}

func (ge testGateEval) EvaluateCall(ctx context.Context, taskID, toolID uuid.UUID, payload json.RawMessage) (agent.GateVerdict, error) {
	tool, err := ge.q.GetToolByID(ctx, toolID)
	if err != nil {
		return agent.GateVerdict{}, err
	}
	v, err := ge.g.Evaluate(ctx, &gate.ToolCall{TaskID: taskID, ToolID: toolID, Payload: payload}, &tool)
	if err != nil {
		return agent.GateVerdict{}, err
	}
	return agent.GateVerdict{Decision: v.Decision.String()}, nil
}

// testDispatcher adapts the real tools.Registry to agent.ToolDispatcher.
type testDispatcher struct {
	q        *db.Queries
	registry *tools.Registry
}

func (d testDispatcher) Dispatch(ctx context.Context, taskID, toolID uuid.UUID, payload json.RawMessage) (string, error) {
	tool, err := d.q.GetToolByID(ctx, toolID)
	if err != nil {
		return "", err
	}
	res, err := d.registry.Execute(tools.WithIdempotencyKey(ctx, taskID.String()), tool.GlobalUri, payload)
	if err != nil {
		return "", err
	}
	b, _ := json.Marshal(res)
	return string(b), nil
}

// testAuditWriter writes the agent layer's audit rows (mirrors
// chainAuditWriter, minus the notify_event side-channel the test doesn't need).
type testAuditWriter struct{ pool *pgxpool.Pool }

func (w testAuditWriter) WriteAudit(ctx context.Context, taskID uuid.UUID, kind string, payload any) error {
	return pgx.BeginFunc(ctx, w.pool, func(tx pgx.Tx) error {
		_, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, kind, payload, uuid.Nil)
		return err
	})
}

// testChainRouter adapts router.Router to chain.Router (mirrors chainRouterAdapter).
type testChainRouter struct{ inner *router.Router }

func (a testChainRouter) Select(ctx context.Context, stage lifecycle.ChainStage, findings json.RawMessage) (chain.SlotDecision, error) {
	agentStage, ok := chainStageToAgentStage(stage)
	if !ok {
		return chain.SlotDecision{IsHuman: true}, nil
	}
	d, err := a.inner.Select(ctx, agentStage, findings)
	if err != nil {
		return chain.SlotDecision{}, err
	}
	return chain.SlotDecision{IsHuman: d.IsHuman, ConfigID: d.ConfigID, ConfigName: d.ConfigName}, nil
}

func chainStageToAgentStage(s lifecycle.ChainStage) (db.AgentStage, bool) {
	switch s {
	case lifecycle.StageTriage:
		return db.AgentStageTriage, true
	case lifecycle.StageExpansion:
		return db.AgentStageExpansion, true
	case lifecycle.StageExecution:
		return db.AgentStageExecution, true
	default:
		return "", false
	}
}

// testChainRunner adapts agent.Runner to chain.StageRunner (mirrors chainStageRunner).
type testChainRunner struct{ runner *agent.Runner }

func (s testChainRunner) RunStage(ctx context.Context, taskID string, _ lifecycle.ChainStage, configID string) (json.RawMessage, error) {
	taskUUID, err := uuid.Parse(taskID)
	if err != nil {
		return nil, fmt.Errorf("parse taskID: %w", err)
	}
	cfgUUID, err := uuid.Parse(configID)
	if err != nil {
		return nil, fmt.Errorf("parse configID: %w", err)
	}
	cfg, err := s.runner.Queries.GetAgentConfigByID(ctx, cfgUUID)
	if err != nil {
		return nil, fmt.Errorf("load agent config: %w", err)
	}
	task, err := s.runner.Queries.GetTask(ctx, taskUUID)
	if err != nil {
		return nil, fmt.Errorf("load task: %w", err)
	}
	desc := ""
	if task.Description != nil {
		desc = *task.Description
	}
	result, _ := s.runner.Run(ctx, agent.RunConfig{
		Config:    cfg,
		TaskID:    taskUUID,
		TaskTitle: task.Title,
		TaskDesc:  desc,
		Findings:  task.Findings,
	})
	return json.Marshal(result)
}

// newAgentChainEnv boots a chainEnv whose EXECUTION stage is driven by a real
// router + runner + gate + dispatcher. client supplies the scripted agent turns;
// registry is the tool registry the dispatcher executes through.
func newAgentChainEnv(t *testing.T, client agent.AgentModelClient, registry *tools.Registry) *chainEnv {
	t.Helper()
	return newChainEnv(t,
		withToolRegistry(registry),
		withAgentChain(func(pool *pgxpool.Pool, q *db.Queries, reg *tools.Registry) (chain.Router, chain.StageRunner, string) {
			lookup := testPrincipalLookup{q: q}
			gw := overseer.NewGateway(overseer.NewLogProvider(), q, 50, "log")
			g := gate.NewDefaultGateWithOverseer(lookup, gw)
			runner := &agent.Runner{
				Client:     client,
				Gate:       testGateEval{q: q, g: g},
				Dispatcher: testDispatcher{q: q, registry: reg},
				Auditor:    testAuditWriter{pool: pool},
				Queries:    q,
				MaxIter:    10,
				Budget:     10,
			}
			return testChainRouter{inner: router.New(q, testPicker{})}, testChainRunner{runner: runner}, "local://principal/owner"
		}),
	)
}

// seedExecutionAgent inserts an always-eligible EXECUTION-stage agent config
// with the given tool allowlist, and returns its id.
func seedExecutionAgent(t *testing.T, env *chainEnv, allowlist []uuid.UUID) uuid.UUID {
	t.Helper()
	ids, err := json.Marshal(allowlist)
	require.NoError(t, err)
	prompt := "You are a deterministic test executor."
	cfg, err := env.queries.InsertAgentConfig(context.Background(), db.InsertAgentConfigParams{
		Name:          "test-executor",
		Stage:         db.AgentStageExecution,
		IsHuman:       false,
		SystemPrompt:  &prompt,
		ToolAllowlist: ids,
		Eligibility:   json.RawMessage(`{}`), // empty expression ⇒ always eligible
		Origin:        db.ConfigOriginCore,
		Version:       1,
	})
	require.NoError(t, err)
	return cfg.ID
}

// walkHumanStagesToExecution drives the human-routed TRIAGE + EXPANSION stages so
// the agent-occupied EXECUTION stage runs next. Unlike walkToExecution it does
// NOT wait for an execution assignment (the agent occupies it, no human slot).
func walkHumanStagesToExecution(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env, taskID, map[string]any{"ok": true})
}

// TestAgentTool_BenignDispatch: a config agent at EXECUTION calls send-email to
// the owner (a known principal). The real gate clears the floor and the overseer
// LogProvider approves, so the runner dispatches the tool and the chain completes
// autonomously — no human assignment at execution.
func TestAgentTool_BenignDispatch(t *testing.T) {
	ctx := context.Background()
	recorder := newRecordingEmailProvider()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(recorder))

	client := &agent.LogAgentClient{}
	env := newAgentChainEnv(t, client, registry)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	seedExecutionAgent(t, env, []uuid.UUID{tool.ID})

	// Script the execution agent: call send-email to the owner, then finish.
	client.Fixtures = []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "send-email",
			Payload: `{"to":"local://principal/owner","subject":"hi","body":"there"}`}}},
		{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"sent"}}`},
	}

	taskID := createTaskGQL(t, env, "agent sends a benign email")
	walkHumanStagesToExecution(t, env, taskID)

	// The chain completes autonomously once the agent finishes execution.
	pollUntilTaskState(t, env, taskID, db.TaskStateDone)

	require.True(t, recorder.wasCalled(), "the agent's approved send-email must have dispatched")
	require.Equal(t, "local://principal/owner", recorder.got.To)

	kinds := auditKindCount(t, env, taskID)
	require.GreaterOrEqual(t, kinds[lifecycle.KindAgentRunStarted], 1, "agent_run_started must be recorded")
	require.GreaterOrEqual(t, kinds[lifecycle.KindAgentRunFinished], 1, "agent_run_finished must be recorded")

	// No EXECUTION human assignment was opened — the agent occupied the slot.
	assignments := listAssignmentsAtStage(t, env, taskID, db.ChainStageExecution)
	require.Empty(t, assignments, "execution must be agent-occupied, no human assignment")
}

// TestAgentTool_FloorTripFailCloses: the agent calls send-email to a STRANGER.
// The real floor trips → gate RequestDecision → the runner fail-closes → the
// chain opens a human assignment at execution. The tool never dispatches.
func TestAgentTool_FloorTripFailCloses(t *testing.T) {
	ctx := context.Background()
	recorder := newRecordingEmailProvider()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(recorder))

	client := &agent.LogAgentClient{}
	env := newAgentChainEnv(t, client, registry)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	seedExecutionAgent(t, env, []uuid.UUID{tool.ID})

	client.Fixtures = []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "send-email",
			Payload: `{"to":"stranger@example.com","subject":"hi","body":"there"}`}}},
	}

	taskID := createTaskGQL(t, env, "agent emails a stranger")
	walkHumanStagesToExecution(t, env, taskID)

	// The floor-trip fail-close opens a human assignment at execution.
	pollUntilAssignmentAt(t, env, taskID, db.ChainStageExecution)
	require.False(t, recorder.wasCalled(), "a floor-tripping call must not dispatch")
}

// TestAgentTool_OffAllowlistRefused: the agent proposes a tool that is NOT in
// its allowlist. The runner refuses it (records agent_call_refused), the gate is
// never consulted, the tool never dispatches, and the agent recovers with
// findings so the chain still completes.
func TestAgentTool_OffAllowlistRefused(t *testing.T) {
	ctx := context.Background()
	recorder := newRecordingEmailProvider()
	registry := tools.NewRegistry()
	registry.Register(tools.NewSendEmail(recorder))

	client := &agent.LogAgentClient{}
	env := newAgentChainEnv(t, client, registry)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	tool, err := env.queries.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	// Allowlist contains only send-email; the agent will try a different tool.
	seedExecutionAgent(t, env, []uuid.UUID{tool.ID})

	client.Fixtures = []agent.ChatResponse{
		{ToolCalls: []agent.ToolCall{{ID: "1", Name: "delete-everything", Payload: `{}`}}},
		{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"recovered after refusal"}}`},
	}

	taskID := createTaskGQL(t, env, "agent reaches for an off-allowlist tool")
	walkHumanStagesToExecution(t, env, taskID)

	pollUntilTaskState(t, env, taskID, db.TaskStateDone)

	kinds := auditKindCount(t, env, taskID)
	require.GreaterOrEqual(t, kinds["agent_call_refused"], 1, "off-allowlist tool must be refused")
	require.False(t, recorder.wasCalled(), "a refused tool must not dispatch")
}

// listAssignmentsAtStage returns every assignment (open or closed) for a task at
// a stage — used to prove the agent occupied a stage with no human slot.
func listAssignmentsAtStage(t *testing.T, env *chainEnv, taskID uuid.UUID, stage db.ChainStage) []uuid.UUID {
	t.Helper()
	rows, err := env.pool.Query(context.Background(),
		`SELECT id FROM agent_assignments WHERE task_id = $1 AND stage = $2`, taskID, stage)
	require.NoError(t, err)
	defer rows.Close()
	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		require.NoError(t, rows.Scan(&id))
		ids = append(ids, id)
	}
	require.NoError(t, rows.Err())
	return ids
}
