package graph_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/connector"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// chainEnv holds the boot products of a single test: pool, dbos context,
// HTTP handler. Tests own teardown via testing.T cleanup hooks. executorID is
// retained so recovery tests can reboot DBOS on a fresh pool under the same
// executor (Launch recovery looks up pending workflows by executor id).
type chainEnv struct {
	pool       *pgxpool.Pool
	dctx       dbos.DBOSContext
	handler    http.Handler
	queries    *db.Queries
	executorID string
}

// chainEnvConfig carries optional overrides for newChainEnv. The zero value
// reproduces the historical default boot (human-only routing + the
// send-email-only registry) so existing no-arg callers are unaffected.
type chainEnvConfig struct {
	// registry, when non-nil, replaces the default send-email-only tool
	// registry. Used by toolflow tests that need a failing provider.
	registry *tools.Registry
	// agentChain, when non-nil, is called after the pool/queries/registry are
	// ready to build the chain router + stage runner (and the owner global URI
	// addressed on human assignments). Used by the agent→tool e2e to wire a real
	// router + runner in place of HumanOnlyRouter.
	agentChain func(pool *pgxpool.Pool, q *db.Queries, registry *tools.Registry) (chain.Router, chain.StageRunner, string)
}

// chainEnvOpt mutates a chainEnvConfig. Pass to newChainEnv.
type chainEnvOpt func(*chainEnvConfig)

// withToolRegistry overrides the tool registry the tool-call workflow dispatches
// through (e.g. to inject a provider that fails, driving an outcome=bad path).
func withToolRegistry(r *tools.Registry) chainEnvOpt {
	return func(c *chainEnvConfig) { c.registry = r }
}

// withAgentChain wires a real chain router + stage runner (instead of the
// human-only default) so a config agent drives a stage. The builder receives the
// booted pool/queries and the resolved tool registry and returns the router,
// runner, and the owner global URI to address human assignments to.
func withAgentChain(build func(pool *pgxpool.Pool, q *db.Queries, registry *tools.Registry) (chain.Router, chain.StageRunner, string)) chainEnvOpt {
	return func(c *chainEnvConfig) { c.agentChain = build }
}

// newChainEnv boots a fresh testcontainers Postgres + DBOS context for a
// test. The executor ID is randomized so parallel/sequential tests don't
// share recovery state. Options override the registry and/or the chain wiring;
// with no options it reproduces the historical human-only boot.
func newChainEnv(t *testing.T, opts ...chainEnvOpt) *chainEnv {
	t.Helper()
	cfg := &chainEnvConfig{}
	for _, o := range opts {
		o(cfg)
	}

	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	require.NoError(t, core.SeedOwner(ctx, db.New(pool)))

	executorID := "test-" + uuid.New().String()
	env := bootChainEnv(t, ctx, pool, executorID, cfg)
	t.Cleanup(func() {
		durable.Shutdown(env.dctx, 5*time.Second)
	})
	return env
}

// bootChainEnv registers every workflow + builds the GraphQL handler on an
// EXISTING pool under the given DBOS executor id, returning a ready chainEnv.
// Unlike newChainEnv it does NOT create/seed the database (the caller seeds the
// owner once before the first boot) and does NOT register a DBOS-shutdown
// cleanup (the caller owns dctx teardown). That makes it safe to call a second
// time on a fresh pool with the same executor id to simulate a server restart
// — see rebootChainEnv. The owner must already exist in the pool's database.
func bootChainEnv(t *testing.T, ctx context.Context, pool *pgxpool.Pool, executorID string, cfg *chainEnvConfig) *chainEnv {
	t.Helper()
	q := db.New(pool)

	// Phase 3 tool registry. Default is send-email-only; tests may inject one
	// with a failing provider via withToolRegistry.
	registry := cfg.registry
	if registry == nil {
		registry = tools.NewRegistry()
		registry.Register(tools.NewSendEmail(nil))
	}

	// Chain wiring: human-only by default, or a real router+runner when an agent
	// chain builder is supplied.
	var chainRouter chain.Router = chain.HumanOnlyRouter{}
	var chainRunner chain.StageRunner
	ownerURI := ""
	if cfg.agentChain != nil {
		chainRouter, chainRunner, ownerURI = cfg.agentChain(pool, q, registry)
	}

	dctx, err := durable.Init(ctx, pool, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx, pool, q, chainRouter, chainRunner, ownerURI, nil, nil)
	// Phase 3 tool-call workflow + send-email tool row. Idempotent on every
	// test boot; harmless for Phase 1 tests that don't exercise the path.
	durable.RegisterToolCallWorkflow(dctx, pool, q, registry, calibration.New(pool, calibration.DefaultConfig(), nil))
	require.NoError(t, tools.SeedSendEmail(ctx, q))
	// Phase 7: register the intake poll workflow + connector registry so the
	// connector owner-mutation resolvers (enableConnector → schedule) work.
	connRegistry := connector.NewRegistry()
	connector.RegisterBaseSet(connRegistry, nil)
	disposer := &intake.Disposer{Pool: pool, DBOS: dctx, Queries: q}
	intake.RegisterPoll(dctx, pool, q, connRegistry, disposer, nil, nil)
	require.NoError(t, durable.Launch(dctx))

	// Phase 5: wire a real WazeroRunner-backed gate-script evaluator. It is a
	// no-op for tools without an active script (every existing test), so it does
	// not change their behaviour; the gate-script e2e attaches a module and gets
	// real WASM execution.
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	scriptRunner, err := gatescript.NewWazeroRunner(ctx, gatescript.DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = scriptRunner.Close(context.Background()) })
	scriptSvc := gatescript.NewService(scriptRunner, q, gatescript.DefaultCeilings(), owner.GlobalUri)

	handler := server.New(pool, dctx, server.Options{
		GateScript: scriptSvc,
		ConnectorResolver: graph.ConnectorDeps{
			HasType:        connRegistry.Has,
			CreateSchedule: intake.CreateSchedule,
			DeleteSchedule: intake.DeleteSchedule,
		},
		Calibrator: calibration.New(pool, calibration.DefaultConfig(), nil),
	})
	return &chainEnv{pool: pool, dctx: dctx, handler: handler, queries: q, executorID: executorID}
}

// newRecoveryEnv is the first boot for a recovery test: it creates the DB, seeds
// the owner, and boots DBOS under a stable executor id — but, unlike newChainEnv,
// registers NO auto DBOS-shutdown cleanup, because the recovery test owns the
// dctx lifecycle (rebootChainEnv shuts the first dctx down; the caller defers
// shutdown of the rebooted dctx). Returns the env plus the cfg so the matching
// reboot re-registers identical wiring.
func newRecoveryEnv(t *testing.T, opts ...chainEnvOpt) (*chainEnv, *chainEnvConfig) {
	t.Helper()
	cfg := &chainEnvConfig{}
	for _, o := range opts {
		o(cfg)
	}
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	require.NoError(t, core.SeedOwner(ctx, db.New(pool)))
	executorID := "recovery-" + uuid.New().String()
	return bootChainEnv(t, ctx, pool, executorID, cfg), cfg
}

// rebootChainEnv simulates a server restart: it shuts down the current DBOS
// context, abandons its goroutines, closes the pool, then boots a fresh pool +
// DBOS context against the SAME database under the SAME executor id so Launch
// recovery replays any in-flight (PENDING) workflows. cfg must match the boot
// config so the recovered workflow re-registers with the same wiring. The
// caller defers Shutdown of the returned env's dctx.
func rebootChainEnv(t *testing.T, env *chainEnv, cfg *chainEnvConfig) *chainEnv {
	t.Helper()
	ctx := context.Background()
	dsn := env.pool.Config().ConnConfig.ConnString()
	executorID := env.executorID

	durable.Shutdown(env.dctx, 1*time.Second)
	env.pool.Close()

	// Mimic kill -9: a graceful shutdown of a blocked Recv could record the
	// workflow as terminal ERROR (which recovery skips); force any such rows for
	// this executor back to PENDING so the next Launch recovers them. This runs
	// BEFORE the reboot's Launch, so it cannot mask a determinism ERROR raised
	// during recovery replay (that is what requireWorkflowNeverErrors guards).
	resetPool, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	_, err = resetPool.Exec(ctx,
		`UPDATE dbos.workflow_status SET status = 'PENDING' WHERE executor_id = $1 AND status = 'ERROR'`,
		executorID)
	require.NoError(t, err)
	resetPool.Close()

	pool2, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	t.Cleanup(func() { pool2.Close() })

	if cfg == nil {
		cfg = &chainEnvConfig{}
	}
	return bootChainEnv(t, ctx, pool2, executorID, cfg)
}

// pollUntilAssignmentAt blocks until the task has an open assignment at the
// given stage (lowercase enum value as stored in DB). Fails the test on timeout.
func pollUntilAssignmentAt(t *testing.T, env *chainEnv, taskID uuid.UUID, wantStage db.ChainStage) db.AgentAssignment {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		row, err := env.queries.FindOpenAssignmentForTask(ctx, taskID)
		if err == nil && row.Stage == wantStage {
			return row
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for open assignment at stage %s", wantStage)
	return db.AgentAssignment{}
}

// pollUntilTaskState blocks until the task reaches the given DB state.
func pollUntilTaskState(t *testing.T, env *chainEnv, taskID uuid.UUID, wantState db.TaskState) db.Task {
	t.Helper()
	ctx := context.Background()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		row, err := env.queries.GetTask(ctx, taskID)
		if err == nil && row.State == wantState {
			return row
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("timed out waiting for task state %s", wantState)
	return db.Task{}
}

// createTaskGQL runs the createTask mutation and returns the created task id.
func createTaskGQL(t *testing.T, env *chainEnv, title string) uuid.UUID {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($title: String!) { createTask(title: $title) { id } }`,
		map[string]any{"title": title})
	var data struct {
		CreateTask struct {
			ID string `json:"id"`
		} `json:"createTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	tid, err := uuid.Parse(data.CreateTask.ID)
	require.NoError(t, err)
	return tid
}

// completeTaskGQL runs the completeTask mutation. result may be nil → {}.
func completeTaskGQL(t *testing.T, env *chainEnv, taskID uuid.UUID, result map[string]any) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $r: JSON) { completeTask(taskId: $id, result: $r) { id } }`,
		map[string]any{"id": taskID.String(), "r": result})
	var data struct {
		CompleteTask struct {
			ID string `json:"id"`
		} `json:"completeTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.Equal(t, taskID.String(), data.CompleteTask.ID)
}

// cancelTaskGQL runs the cancelTask mutation.
func cancelTaskGQL(t *testing.T, env *chainEnv, taskID uuid.UUID) {
	t.Helper()
	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!) { cancelTask(taskId: $id) { id } }`,
		map[string]any{"id": taskID.String()})
	var data struct {
		CancelTask struct {
			ID string `json:"id"`
		} `json:"cancelTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
}

// graphqlRequestExpectError runs a GraphQL request and returns the errors
// array (does not fail on errors — the test asserts the shape).
func graphqlRequestExpectError(t *testing.T, handler http.Handler, query string, vars map[string]any) []json.RawMessage {
	t.Helper()
	body := mustJSON(map[string]any{"query": query, "variables": vars})
	resp := postGraphQL(t, handler, body)
	if len(resp.Errors) == 0 {
		t.Fatalf("expected errors but got: %s", resp.Data)
	}
	return resp.Errors
}

func mustJSON(v any) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		panic(fmt.Sprintf("marshal: %v", err))
	}
	return b
}
