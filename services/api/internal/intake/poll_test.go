package intake_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/connector"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/jackc/pgx/v5/pgxpool"
)

// pollEnv is a DBOS-backed env for exercising the poll workflow end-to-end.
type pollEnv struct {
	pool    *pgxpool.Pool
	dctx    dbos.DBOSContext
	queries *db.Queries
	inbound *connector.MemoryInboundQueue
	judge   *intake.LogTriageJudge
}

func newPollEnv(t *testing.T) *pollEnv {
	t.Helper()
	pool, q := testEnv(t)
	ctx := context.Background()

	dctx, err := durable.Init(ctx, pool, "intaketest-"+uuid.NewString())
	require.NoError(t, err)
	// The chain workflow must be registered so forced_task's chain attach works.
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, nil, "", nil, nil, nil, nil)

	inbound := &connector.MemoryInboundQueue{}
	registry := connector.NewRegistry()
	connector.RegisterBaseSet(registry, inbound)
	judge := &intake.LogTriageJudge{}
	disposer := &intake.Disposer{Pool: pool, DBOS: dctx, Queries: q, Triage: judge}
	intake.RegisterPoll(dctx, pool, q, registry, disposer, nil, nil)

	require.NoError(t, durable.Launch(dctx))
	t.Cleanup(func() { durable.Shutdown(dctx, 5*time.Second) })

	return &pollEnv{pool: pool, dctx: dctx, queries: q, inbound: inbound, judge: judge}
}

func (e *pollEnv) seedWebhook(t *testing.T) uuid.UUID {
	t.Helper()
	id := uuid.New()
	sched := "0 * * * * *"
	rules, _ := json.Marshal(map[string]any{"llm_judge_per_poll": 2})
	_, err := e.queries.UpsertConnectorConfig(context.Background(), db.UpsertConnectorConfigParams{
		ID:               id,
		ConnectorType:    "webhook-in",
		Filter:           json.RawMessage(`{}`),
		Schedule:         &sched,
		DispositionRules: rules,
	})
	require.NoError(t, err)
	_, err = e.queries.SetConnectorEnabled(context.Background(), db.SetConnectorEnabledParams{ID: id, Enabled: true})
	require.NoError(t, err)
	return id
}

func (e *pollEnv) runPoll(t *testing.T, connectorID uuid.UUID) {
	t.Helper()
	h, err := dbos.RunWorkflow(e.dctx, intake.PollWorkflow, dbos.ScheduledWorkflowInput{
		Context: connectorID.String(),
	})
	require.NoError(t, err)
	_, err = h.GetResult()
	require.NoError(t, err)
}

func (e *pollEnv) countTasksForConnector(t *testing.T, connectorID uuid.UUID) int {
	t.Helper()
	var n int
	require.NoError(t, e.pool.QueryRow(context.Background(), `
		SELECT count(*) FROM tasks WHERE intake_signal_id IN
		  (SELECT id FROM intake_signals WHERE connector_id=$1)`, connectorID).Scan(&n))
	return n
}

// US1 e2e — a webhook forced_task item becomes one accepted task with provenance.
func TestPoll_ForcedTaskBecomesAcceptedTask(t *testing.T) {
	env := newPollEnv(t)
	cid := env.seedWebhook(t)
	env.inbound.Push(connector.InboundItem{
		IdempotencyKey: "evt-1",
		Payload:        json.RawMessage(`{"title":"Pay invoice"}`),
		RawRef:         "webhook:evt-1",
		Reason:         "inbound delivery",
	})

	env.runPoll(t, cid)

	require.Equal(t, 1, env.countTasksForConnector(t, cid))
	var state, prov string
	require.NoError(t, env.pool.QueryRow(context.Background(), `
		SELECT state::text, provenance::text FROM tasks WHERE intake_signal_id IN
		  (SELECT id FROM intake_signals WHERE connector_id=$1)`, cid).Scan(&state, &prov))
	require.Equal(t, string(lifecycle.StateAccepted), state)
	require.Contains(t, prov, "webhook:evt-1")
	require.Equal(t, 0, env.judge.CallCount(), "forced_task invokes no model")
}

// T050 (recovery proxy) — re-running the same poll is idempotent: no double-emit,
// no double-task. The kill -9 path is the same mechanism (DBOS memoized steps +
// the unique index + the dispose idempotency guard).
func TestPoll_RerunIsIdempotent(t *testing.T) {
	env := newPollEnv(t)
	cid := env.seedWebhook(t)
	for i := 0; i < 3; i++ {
		env.inbound.Push(connector.InboundItem{
			IdempotencyKey: "item-" + string(rune('a'+i)),
			Payload:        json.RawMessage(`{"title":"t"}`),
			RawRef:         "webhook:item",
			Reason:         "x",
		})
	}
	env.runPoll(t, cid)
	require.Equal(t, 3, env.countTasksForConnector(t, cid))

	// Re-push the SAME items and poll again — dedupe ⇒ still 3 tasks.
	for i := 0; i < 3; i++ {
		env.inbound.Push(connector.InboundItem{
			IdempotencyKey: "item-" + string(rune('a'+i)),
			Payload:        json.RawMessage(`{"title":"t"}`),
			RawRef:         "webhook:item",
			Reason:         "x",
		})
	}
	env.runPoll(t, cid)
	require.Equal(t, 3, env.countTasksForConnector(t, cid), "re-emitting the same items must not create new tasks (SC-005)")
}

// T044 — a poll exceeding llm_judge_per_poll invokes the model ≤ cap times;
// overflow held PROPOSED with llm_judge_capped audit.
func TestPoll_LLMJudgeCap(t *testing.T) {
	env := newPollEnv(t)
	cid := env.seedWebhook(t) // llm_judge_per_poll = 2
	for i := 0; i < 5; i++ {
		env.inbound.Push(connector.InboundItem{
			IdempotencyKey: "lj-" + string(rune('a'+i)),
			Payload:        json.RawMessage(`{"title":"judge me"}`),
			Disposition:    intake.DispositionLLMJudge,
			RawRef:         "webhook:lj",
			Reason:         "ambiguous",
		})
	}
	env.runPoll(t, cid)

	require.LessOrEqual(t, env.judge.CallCount(), 2, "model fan-out bounded by the per-poll cap")

	var capped int
	require.NoError(t, env.pool.QueryRow(context.Background(),
		`SELECT count(*) FROM audit_messages WHERE kind=$1`, lifecycle.KindLLMJudgeCapped).Scan(&capped))
	require.Equal(t, 3, capped, "three over-cap items audit llm_judge_capped")
}
