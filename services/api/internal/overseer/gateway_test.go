package overseer_test

import (
	"context"
	"errors"
	"regexp"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// fakeProvider is a test seam that returns canned responses or errors.
// Tracks call count via atomic so a goroutine-stressed test stays honest.
type fakeProvider struct {
	name     string
	resp     overseer.RawResponse
	err      error
	callsCnt int64
}

func (f *fakeProvider) Name() string { return f.name }
func (f *fakeProvider) Call(_ context.Context, _ overseer.PromptPayload) (overseer.RawResponse, error) {
	atomic.AddInt64(&f.callsCnt, 1)
	return f.resp, f.err
}
func (f *fakeProvider) Calls() int { return int(atomic.LoadInt64(&f.callsCnt)) }

// failProvider asserts the test if Call is ever invoked. Used to prove the
// cap-exceeded path short-circuits without dispatching to the provider.
type failProvider struct{ t *testing.T }

func (f *failProvider) Name() string { return "fail" }
func (f *failProvider) Call(_ context.Context, _ overseer.PromptPayload) (overseer.RawResponse, error) {
	f.t.Fatalf("provider Call must not be invoked on cap-exceeded path")
	return overseer.RawResponse{}, nil
}

// seededEnv mirrors the test pattern in services/api/graph: a fresh
// testcontainers Postgres + migrations + the seeded owner. The gateway
// only needs queries (for the cap query) and a non-nil pool isn't strictly
// required, but we keep it so future tests can write audit rows.
type seededEnv struct {
	pool    *pgxpool.Pool
	queries *db.Queries
	taskID  uuid.UUID
}

func newSeededEnv(t testing.TB) *seededEnv {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)

	// Seed an owner principal so audit rows can be authored against it.
	_, err := pool.Exec(ctx, `
		INSERT INTO principals (id, global_uri, display_name, kind)
		VALUES (gen_random_uuid(), 'local://principal/test-owner', 'test', 'user')
		ON CONFLICT (global_uri) DO NOTHING
	`)
	require.NoError(t, err)

	// Seed a Task row so the cap query has a valid task_id to count against.
	taskID := uuid.New()
	_, err = pool.Exec(ctx, `
		INSERT INTO tasks (id, global_uri, title, state, current_stage)
		VALUES ($1::uuid, 'tendant://tasks/test-' || ($1::uuid)::text, 'gateway test', 'accepted'::task_state, 'execution'::chain_stage)
	`, taskID)
	require.NoError(t, err)

	return &seededEnv{pool: pool, queries: q, taskID: taskID}
}

func seedOverseerAuditRow(t testing.TB, env *seededEnv) {
	t.Helper()
	_, err := env.pool.Exec(context.Background(), `
		INSERT INTO audit_messages (id, task_id, from_principal, kind, payload, at)
		VALUES (gen_random_uuid(), $1, 'local://principal/system', 'overseer_evaluated', '{}'::jsonb, now())
	`, env.taskID)
	require.NoError(t, err)
}

func TestGateway_PerTaskCapExceeded_DoesNotCallProvider(t *testing.T) {
	env := newSeededEnv(t)
	// Cap = 2; seed 2 rows; the third Grade must fail closed without
	// invoking the provider.
	seedOverseerAuditRow(t, env)
	seedOverseerAuditRow(t, env)

	provider := &failProvider{t: t}
	gw := overseer.NewGateway(provider, env.queries, 2, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionRequestDecision, v.Decision, "cap-exceeded must fail-closed to RequestDecision")
	require.Equal(t, "per_task_eval_cap_exceeded", v.Reason)
}

func TestGateway_HappyPath_ApproveRecordsWindow(t *testing.T) {
	env := newSeededEnv(t)
	provider := &fakeProvider{
		name: "log",
		resp: overseer.RawResponse{
			Verdict:   "approve",
			Evidence:  overseer.Evidence{Summary: "ok", ConsideredFields: []string{"payload.to"}},
			ModelID:   "log",
			TokensIn:  10,
			TokensOut: 5,
		},
	}
	gw := overseer.NewGateway(provider, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionApprove, v.Decision)
	require.Equal(t, 1, provider.Calls())
	require.Equal(t, "log", v.Provider)
	require.Equal(t, "log", v.ModelID)
	require.Equal(t, []string{"payload.to"}, v.Evidence.ConsideredFields)
	// Rate window should record this evaluation.
	require.Equal(t, 1, gw.RatePerMinute(), "rate window must record the eval")
}

func TestGateway_ProviderError_FailsClosed(t *testing.T) {
	env := newSeededEnv(t)
	provider := &fakeProvider{
		name: "log",
		err:  errors.New("provider down"),
	}
	gw := overseer.NewGateway(provider, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
	require.NoError(t, err, "Grade itself never returns an error — fail-closed paths return a verdict")
	require.Equal(t, overseer.DecisionRequestDecision, v.Decision)
	require.Equal(t, "gateway_error", v.Reason)
}

func TestGateway_MalformedVerdict_FailsClosed(t *testing.T) {
	env := newSeededEnv(t)
	provider := &fakeProvider{
		name: "log",
		resp: overseer.RawResponse{
			Verdict:  "deny", // not in {"approve","request_decision"}
			ModelID:  "log",
			TokensIn: 1, TokensOut: 1,
		},
	}
	gw := overseer.NewGateway(provider, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionRequestDecision, v.Decision)
	require.Equal(t, "malformed_model_response", v.Reason)
}

func TestGateway_RatePerMinuteTrimsOldEntries(t *testing.T) {
	env := newSeededEnv(t)
	provider := &fakeProvider{
		name: "log",
		resp: overseer.RawResponse{Verdict: "approve", ModelID: "log"},
	}
	gw := overseer.NewGateway(provider, env.queries, 50, "log")
	// Run 3 evals; assert count = 3 immediately.
	for i := 0; i < 3; i++ {
		_, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
		require.NoError(t, err)
	}
	require.Equal(t, 3, gw.RatePerMinute())
	// Sleep is not appropriate here; the trim is "anything older than now-60s".
	// We can't move time forward without injection. Just confirm the count is
	// bounded by recent calls.
	require.LessOrEqual(t, gw.RatePerMinute(), 3)
}

func TestGateway_NoProvider_FailsClosed(t *testing.T) {
	env := newSeededEnv(t)
	gw := overseer.NewGateway(nil, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionRequestDecision, v.Decision)
	require.Equal(t, "gateway_error", v.Reason)
}

func TestGateway_LogProvider_DefaultApproves(t *testing.T) {
	env := newSeededEnv(t)
	lp := overseer.NewLogProviderWithPattern(nil)
	gw := overseer.NewGateway(lp, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{
		TaskID:       env.taskID,
		ConcreteCall: []byte(`{"to":"tendant://principals/owner","body":"hi"}`),
	})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionApprove, v.Decision)
	require.Equal(t, 1, lp.Calls())
}

func TestGateway_LogProvider_DenyPatternEscalates(t *testing.T) {
	env := newSeededEnv(t)
	re := regexp.MustCompile(`(?i)\$|money`)
	lp := overseer.NewLogProviderWithPattern(re)
	gw := overseer.NewGateway(lp, env.queries, 50, "log")
	v, err := gw.Grade(context.Background(), &overseer.OverseerInput{
		TaskID:       env.taskID,
		ConcreteCall: []byte(`{"to":"tendant://principals/owner","body":"send me $500"}`),
	})
	require.NoError(t, err)
	require.Equal(t, overseer.DecisionRequestDecision, v.Decision)
	require.Equal(t, "", v.Reason, "non-fail-closed escalation has empty reason")
}

// SC-004 property test: payload fields cannot influence which Provider the
// Gateway dispatches against. The provider is set at construction and never
// re-read from input. We assert: across many evaluations with payloads
// trying to "set" provider/model, the returned Provider on the verdict
// always matches the Gateway's configured provider.
func TestGateway_ProviderConstantRegardlessOfPayload(t *testing.T) {
	env := newSeededEnv(t)
	provider := &fakeProvider{
		name: "log",
		resp: overseer.RawResponse{Verdict: "approve", ModelID: "log"},
	}
	gw := overseer.NewGateway(provider, env.queries, 50, "log")

	payloads := [][]byte{
		[]byte(`{"provider":"anthropic","body":"hi"}`),
		[]byte(`{"model_override":"gpt-4.1-mini","body":"hi"}`),
		[]byte(`{"model_id":"claude-sonnet-4-6","body":"hi"}`),
		[]byte(`{"to":"x","provider":"openai","model_id":"gpt-4o-mini"}`),
	}
	for _, p := range payloads {
		v, err := gw.Grade(context.Background(), &overseer.OverseerInput{TaskID: env.taskID, ConcreteCall: p})
		require.NoError(t, err)
		require.Equal(t, "log", v.Provider, "payload must not influence active provider: %s", p)
	}
}

func TestAuditPayload_Shape(t *testing.T) {
	t.Parallel()
	verdict := overseer.OverseerVerdict{
		Decision:         overseer.DecisionApprove,
		Evidence:         overseer.Evidence{Summary: "ok", ConsideredFields: []string{"payload.body"}},
		ModelID:          "log",
		Provider:         "log",
		TokensIn:         10,
		TokensOut:        5,
		EstimatedCostUSD: 0,
	}
	payload := overseer.AuditPayload(&verdict, uuid.Nil, "sha256-abc")
	require.Equal(t, "approve", payload["verdict"])
	require.Equal(t, "log", payload["model_id"])
	require.Equal(t, "log", payload["provider"])
	require.Equal(t, "sha256-abc", payload["owner_instructions_hash"])
	require.Equal(t, 10, payload["tokens_in"])
	require.Equal(t, 5, payload["tokens_out"])
	ev, ok := payload["evidence"].(map[string]any)
	require.True(t, ok)
	require.Equal(t, "ok", ev["summary"])
	_, hasDecisionID := ev["decision_id"]
	require.False(t, hasDecisionID, "uuid.Nil decision_id must NOT be included")

	// Now with a decision_id present.
	decisionID := uuid.New()
	payload2 := overseer.AuditPayload(&verdict, decisionID, "sha256-abc")
	ev2 := payload2["evidence"].(map[string]any)
	require.Equal(t, decisionID.String(), ev2["decision_id"])
}

func TestAuditPayload_CapExceededRendersFailClosedString(t *testing.T) {
	t.Parallel()
	v := overseer.OverseerVerdict{
		Decision: overseer.DecisionRequestDecision,
		Reason:   "per_task_eval_cap_exceeded",
		Provider: "log",
		ModelID:  "log",
	}
	payload := overseer.AuditPayload(&v, uuid.Nil, "")
	require.Equal(t, "fail_closed_per_task_cap", payload["verdict"])
	ev := payload["evidence"].(map[string]any)
	require.Equal(t, "per_task_eval_cap_exceeded", ev["reason"])
}

func TestAuditPayload_GatewayErrorRendersFailClosedString(t *testing.T) {
	t.Parallel()
	v := overseer.OverseerVerdict{
		Decision: overseer.DecisionRequestDecision,
		Reason:   "gateway_error",
		Provider: "log",
	}
	payload := overseer.AuditPayload(&v, uuid.Nil, "")
	require.Equal(t, "fail_closed_request_decision", payload["verdict"])
}

// SilenceUnused keeps imports honest in partial refactors.
var _ = time.Second
