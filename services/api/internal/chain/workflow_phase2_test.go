package chain_test

import (
	"context"
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
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

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
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, owner.GlobalUri, enqueuer)
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
