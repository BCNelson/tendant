package chain_test

import (
	"context"
	"encoding/json"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// handoffRouter routes every stage to an agent (never the human directly), so
// the agent path runs and the StageRunner's verdict decides what happens next.
type handoffRouter struct{}

func (handoffRouter) Select(_ context.Context, _ lifecycle.ChainStage, _ json.RawMessage) (chain.SlotDecision, error) {
	id := uuid.New()
	return chain.SlotDecision{IsHuman: false, ConfigID: &id, ConfigName: "stub-agent"}, nil
}

// handoffRunner is a StageRunner stub whose agent always calls handoff_to_human:
// it returns a fail-close StageResult carrying the handoff reason.
type handoffRunner struct{ reason string }

func (h handoffRunner) RunStage(_ context.Context, _ string, _ lifecycle.ChainStage, _ string) (json.RawMessage, error) {
	r, _ := json.Marshal(map[string]any{
		"fail_close_to_human": true,
		"fail_reason":         "agent_handoff",
		"handoff_reason":      h.reason,
	})
	return r, nil
}

// TestChainHandoffOpensOwnerAddressedAssignment proves that when an agent hands
// a task off to a human, the chain opens an OPEN assignment addressed to the
// owner (to_principal = owner) — exactly the row the inbox query lists — and the
// agent's handoff reason surfaces on that assignment's ask.
func TestChainHandoffOpensOwnerAddressedAssignment(t *testing.T) {
	// NOT t.Parallel(): chain.Register stores deps in a package-global, so two
	// DBOS-registering chain tests cannot run concurrently. Staying sequential
	// lets this test finish before the parallel TestChainSetsToPrincipal... runs.
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	dctx, err := durable.Init(ctx, pool, t.Name())
	require.NoError(t, err)
	defer durable.Shutdown(dctx, 2*time.Second)

	const reason = "this task needs a phone call and I have no tool for that"
	durable.RegisterChainWorkflow(dctx, pool, q, handoffRouter{}, handoffRunner{reason: reason}, owner.GlobalUri, nil, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx))

	created, err := core.CreateTask(ctx, pool, dctx, "handoff-test", "")
	require.NoError(t, err)

	deadline := time.Now().Add(10 * time.Second)
	var row db.AgentAssignment
	found := false
	for time.Now().Before(deadline) {
		r, ferr := q.FindOpenAssignmentForTask(ctx, created.ID)
		if ferr == nil && r.ToPrincipal != nil && *r.ToPrincipal == owner.GlobalUri {
			row = r
			found = true
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
	require.True(t, found, "handoff should open an owner-addressed assignment (the inbox)")
	require.Contains(t, row.Ask, reason, "handoff reason should surface on the assignment ask (inbox item)")
}

// recordingPushEnqueuer captures every EnqueuePush invocation so the test
// can assert the chain workflow scheduled exactly one push per assignment.
type recordingPushEnqueuer struct {
	mu       sync.Mutex
	payloads []chain.PushJobPayload
	count    atomic.Int64
}

func (r *recordingPushEnqueuer) EnqueuePush(_ context.Context, p chain.PushJobPayload) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.payloads = append(r.payloads, p)
	r.count.Add(1)
	return nil
}

func TestChainSetsToPrincipalAndEnqueuesPush(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	dctx, err := durable.Init(ctx, pool, t.Name())
	require.NoError(t, err)
	defer durable.Shutdown(dctx, 2*time.Second)

	enqueuer := &recordingPushEnqueuer{}
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, nil, owner.GlobalUri, enqueuer, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx))

	created, err := core.CreateTask(ctx, pool, dctx, "phase2-test", "")
	require.NoError(t, err)

	// Wait for the first assignment row to appear with to_principal set to
	// the seeded owner.
	deadline := time.Now().Add(10 * time.Second)
	var asnID uuid.UUID
	for time.Now().Before(deadline) {
		row, err := q.FindOpenAssignmentForTask(ctx, created.ID)
		if err == nil && row.ToPrincipal != nil && *row.ToPrincipal == owner.GlobalUri {
			asnID = row.ID
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
	require.NotEqual(t, uuid.Nil, asnID, "open assignment with to_principal set should appear")

	require.Eventually(t, func() bool {
		return enqueuer.count.Load() >= 1
	}, 5*time.Second, 50*time.Millisecond, "EnqueuePush should be called at least once")

	enqueuer.mu.Lock()
	require.NotEmpty(t, enqueuer.payloads)
	p := enqueuer.payloads[0]
	enqueuer.mu.Unlock()

	require.Equal(t, created.ID, p.TaskID)
	require.Equal(t, owner.GlobalUri, p.RecipientGlobalURI)
	require.Equal(t, asnID.String(), p.DeepLinkID)
	require.Equal(t, "tendant", p.Title)
}
