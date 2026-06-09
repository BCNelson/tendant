package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/llm"
	"github.com/bcnelson/tendant/services/api/internal/router"
)

// buildAgentWiring returns the live agent router + stage runner when
// agent.connection names a registered [[llm_connections]] entry; otherwise it
// returns (chain.HumanOnlyRouter{}, nil) — the human-only default that keeps
// CI/production behavior byte-identical to before this wiring existed.
//
// Mirrors buildOverseerProvider's "name a connection, fall closed if absent"
// shape. Inference routing is fixed at boot (no self-escalation): an agent
// cannot mint a connection at runtime.
func buildAgentWiring(cfg *config.Config, reg *llm.Registry, pool *pgxpool.Pool, q *db.Queries, ov *config.Overlay) (chain.Router, chain.StageRunner) {
	name := cfg.Agent.Connection
	if name == "" {
		return chain.HumanOnlyRouter{}, nil
	}

	conn, ok := reg.Connection(name)
	if !ok {
		slog.Error("agent: connection not found; falling back to human-only routing", "connection", name)
		return chain.HumanOnlyRouter{}, nil
	}

	client, err := agent.NewAgentClientFromConnection(conn)
	if err != nil {
		slog.Error("agent: model client build failed; falling back to human-only routing", "connection", name, "err", err)
		return chain.HumanOnlyRouter{}, nil
	}

	// Picker model "" ⇒ the llm.Client uses the connection's default model, so
	// the connection's `model` is the single source of truth.
	rtr := router.New(q, router.NewLLMPicker(client, ""))

	runner := &agent.Runner{
		Client:     client,
		Gate:       failClosedGate{},             // defense-in-depth; default agents carry no tools
		Dispatcher: nil,                          // never reached: failClosedGate never approves
		Auditor:    chainAuditWriter{pool: pool}, // agent_run_* + refusal/budget rows on the audit DAG
		Queries:    q,
		MaxIter:    ov.IntOr("agent.max_iter", cfg.Agent.MaxIter),
		Budget:     ov.IntOr("gate.call_budget", cfg.Gate.CallBudget),
	}

	slog.Info("agent.wiring", "connection", name, "model", conn.Model)
	return chainRouterAdapter{inner: rtr}, chainStageRunner{runner: runner}
}

// failClosedGate is the agent runner's gate seam for the dev wiring. It returns
// request_decision for every call, which makes the runner fail-close to human
// rather than dispatch. The default seeded agents have an empty tool_allowlist
// so this is never consulted in practice; it exists so a future dev
// tool_allowlist cannot nil-panic the runner.
type failClosedGate struct{}

func (failClosedGate) EvaluateCall(_ context.Context, _, _ uuid.UUID, _ json.RawMessage) (agent.GateVerdict, error) {
	return agent.GateVerdict{Decision: "request_decision"}, nil
}

// chainAuditWriter implements agent.AuditWriter by writing one audit_messages
// row per call through lifecycle.WriteAuditMessage. The runner's seam supplies
// no tx, so each call opens its own (the agent runs inline inside a DBOS step;
// these rows are independent of that step's tx and committed immediately).
// Rows are authored by the system principal and task-scoped, so they satisfy
// the audit_task_required_unless_owner_scope CHECK.
type chainAuditWriter struct{ pool *pgxpool.Pool }

func (w chainAuditWriter) WriteAudit(ctx context.Context, taskID uuid.UUID, kind string, payload any) error {
	return pgx.BeginFunc(ctx, w.pool, func(tx pgx.Tx) error {
		if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, kind, payload, uuid.Nil); err != nil {
			return err
		}
		// Agent run start/finish doesn't touch the tasks row, so the tasks
		// notify trigger won't fire for it. Emit a 'task' event explicitly so
		// taskChanged subscribers (the live Tasks view) refresh the stage slots
		// when a specialist starts or finishes occupying a stage.
		if kind == lifecycle.KindAgentRunStarted || kind == lifecycle.KindAgentRunFinished {
			if _, err := tx.Exec(ctx, "SELECT notify_event('task', $1::uuid)", taskID); err != nil {
				slog.WarnContext(ctx, "agent audit: notify_event failed", "task_id", taskID, "kind", kind, "err", err)
			}
		}
		return nil
	})
}

// chainRouterAdapter adapts internal/router.Router (db.AgentStage /
// router.SlotDecision) to the chain.Router interface (lifecycle.ChainStage /
// chain.SlotDecision). Non-agent chain stages (creation, completion) route to
// the human without touching the DB.
type chainRouterAdapter struct{ inner *router.Router }

func (a chainRouterAdapter) Select(ctx context.Context, stage lifecycle.ChainStage, findings json.RawMessage) (chain.SlotDecision, error) {
	agentStage, ok := chainStageToAgentStage(stage)
	if !ok {
		return chain.SlotDecision{IsHuman: true}, nil
	}
	d, err := a.inner.Select(ctx, agentStage, findings)
	if err != nil {
		return chain.SlotDecision{}, err
	}
	return chain.SlotDecision{
		IsHuman:    d.IsHuman,
		ConfigID:   d.ConfigID,
		ConfigName: d.ConfigName,
	}, nil
}

func chainStageToAgentStage(s lifecycle.ChainStage) (db.AgentStage, bool) {
	switch s {
	case lifecycle.StageTriage:
		return db.AgentStageTriage, true
	case lifecycle.StageExpansion:
		return db.AgentStageExpansion, true
	case lifecycle.StageExecution:
		return db.AgentStageExecution, true
	default: // StageCreation, StageCompletion
		return "", false
	}
}

// chainStageRunner adapts agent.Runner to the chain.StageRunner interface: it
// loads the picked AgentConfig + the Task, runs the plan→act→observe loop, and
// marshals the StageResult. Marshaling StageResult directly yields the
// fail_close_to_human key the workflow's isFailCloseResult reads.
type chainStageRunner struct{ runner *agent.Runner }

func (s chainStageRunner) RunStage(ctx context.Context, taskID string, _ lifecycle.ChainStage, configID string) (json.RawMessage, error) {
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

	// Run returns a fail-close StageResult on its own internal errors, so the
	// marshaled result routes to human deterministically either way.
	result, _ := s.runner.Run(ctx, agent.RunConfig{
		Config:    cfg,
		TaskID:    taskUUID,
		TaskTitle: task.Title,
		TaskDesc:  desc,
		Findings:  task.Findings,
	})
	return json.Marshal(result)
}
