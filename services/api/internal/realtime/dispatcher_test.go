package realtime_test

import (
	"context"
	"encoding/json"
	"runtime"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupDB(t *testing.T) (*db.Queries, *db.Principal, string) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	return q, &owner, dsn
}

func startDispatcher(t *testing.T, canFn realtime.CanFunc) (*realtime.Dispatcher, *db.Queries, context.CancelFunc, *db.Principal) {
	t.Helper()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	ctx := context.Background()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	runCtx, cancel := context.WithCancel(ctx)
	d, err := realtime.New(runCtx, pool, q, canFn)
	require.NoError(t, err)
	go d.Run(runCtx)
	t.Cleanup(func() {
		cancel()
		d.Stop(context.Background())
	})
	return d, q, cancel, &owner
}

func insertTaskAndAssignment(t *testing.T, q *db.Queries, ownerGlobalURI string) (uuid.UUID, uuid.UUID) {
	t.Helper()
	ctx := context.Background()
	// Insert a task directly via the underlying connection. The chain
	// workflow isn't running in this test; we just need the rows so the
	// triggers fire.
	taskID := uuid.New()
	gURI := "local://task/" + taskID.String()
	_, err := q.CreateTask(ctx, db.CreateTaskParams{
		ID:           taskID,
		GlobalUri:    gURI,
		Title:        "test",
		State:        db.TaskStateAccepted,
		CurrentStage: db.ChainStageCreation,
	})
	require.NoError(t, err)
	asn, err := q.InsertAgentAssignment(ctx, db.InsertAgentAssignmentParams{
		TaskID:          taskID,
		Stage:           db.ChainStageTriage,
		Ask:             "test ask",
		GatheredContext: json.RawMessage("{}"),
	})
	require.NoError(t, err)
	_, err = q.SetAssignmentRecipient(ctx, db.SetAssignmentRecipientParams{
		ID:          asn.ID,
		ToPrincipal: &ownerGlobalURI,
	})
	require.NoError(t, err)
	return taskID, asn.ID
}

func TestDispatcherFanOutToMatchingSubscribers(t *testing.T) {
	t.Parallel()
	d, q, _, owner := startDispatcher(t, func(_ context.Context, _ *auth.Principal, _ string, _ any) bool { return true })

	all := realtime.NewInboxSubscriber(&auth.Principal{ID: owner.ID, GlobalURI: owner.GlobalUri, DisplayName: owner.DisplayName, Kind: owner.Kind})
	unrelated := uuid.New().String()
	otherTask := realtime.NewTaskChangedSubscriber(&auth.Principal{ID: owner.ID, GlobalURI: owner.GlobalUri}, &unrelated)

	dropAll := d.Register(all)
	defer dropAll()
	dropOther := d.Register(otherTask)
	defer dropOther()

	_, asnID := insertTaskAndAssignment(t, q, owner.GlobalUri)

	select {
	case env := <-all.Out:
		require.Equal(t, "assignment", env.Topic)
		require.Equal(t, asnID.String(), env.ID)
	case <-time.After(3 * time.Second):
		t.Fatal("inbox subscriber did not receive the assignment event")
	}

	select {
	case <-otherTask.Out:
		t.Fatal("unrelated task subscriber should not have received an event")
	case <-time.After(500 * time.Millisecond):
		// expected
	}
}

func TestDispatcherAuthRevocationMidStream(t *testing.T) {
	t.Parallel()
	var allow atomic.Bool
	allow.Store(true)

	d, q, _, owner := startDispatcher(t, func(_ context.Context, _ *auth.Principal, _ string, _ any) bool {
		return allow.Load()
	})

	sub := realtime.NewInboxSubscriber(&auth.Principal{ID: owner.ID, GlobalURI: owner.GlobalUri})
	dereg := d.Register(sub)
	defer dereg()

	_, _ = insertTaskAndAssignment(t, q, owner.GlobalUri)

	select {
	case <-sub.Out:
		// expected — auth still allowed.
	case <-time.After(3 * time.Second):
		t.Fatal("first event did not arrive while allowed")
	}

	// "Revoke" the subscriber by flipping the canFn to deny.
	allow.Store(false)
	_, _ = insertTaskAndAssignment(t, q, owner.GlobalUri)

	select {
	case env := <-sub.Out:
		t.Fatalf("expected zero events after revocation; got %+v", env)
	case <-time.After(1 * time.Second):
		// expected: silently dropped.
	}
}

func TestDispatcherSlowSubscriberDropPolicy(t *testing.T) {
	t.Parallel()
	d, q, _, owner := startDispatcher(t, func(_ context.Context, _ *auth.Principal, _ string, _ any) bool { return true })

	sub := realtime.NewInboxSubscriber(&auth.Principal{ID: owner.ID, GlobalURI: owner.GlobalUri})
	dereg := d.Register(sub)
	defer dereg()

	// Fill the channel without draining; the dispatcher should drop excess
	// events and increment DroppedCount.
	before := runtime.NumGoroutine()
	for i := 0; i < int(realtime.DefaultSubscriberCapacity)+5; i++ {
		_, _ = insertTaskAndAssignment(t, q, owner.GlobalUri)
	}

	require.Eventually(t, func() bool {
		return sub.DroppedCount.Load() >= 1
	}, 5*time.Second, 100*time.Millisecond, "expected at least one drop")

	// Drain so cleanup goroutines can exit; then assert no goroutine leak
	// in the steady state (modulo a generous tolerance — pgxpool background
	// goroutines, runtime variance).
	go func() {
		for range sub.Out {
		}
	}()
	time.Sleep(200 * time.Millisecond)
	after := runtime.NumGoroutine()
	require.LessOrEqualf(t, after-before, 50, "suspicious goroutine growth: before=%d after=%d", before, after)
}

// silence unused import warnings — pgtype is sometimes useful in this file
// but the assertions above don't end up needing it in every refactor.
var _ pgtype.Timestamptz
