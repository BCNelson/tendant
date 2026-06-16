package graph_test

import (
	"context"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// countingPushEnqueuer records how many times the chain workflow enqueued a
// push. A NON-nil enqueuer (plus a non-empty owner URI) is what makes the
// chain record the enqueue_push step — the precondition for the determinism
// bug this test guards against.
type countingPushEnqueuer struct{ count atomic.Int64 }

func (c *countingPushEnqueuer) EnqueuePush(_ context.Context, _ chain.PushJobPayload) error {
	c.count.Add(1)
	return nil
}

// TestChainRecovery_PushEnqueuerSurvivesRestartAtEachStage is the regression
// guard for the enqueue_push determinism bug, exercised at EVERY human-wait
// stage (TRIAGE, EXPANSION, EXECUTION).
//
// The bug: runOpenAssignmentStep captured the new assignment id in a closure
// variable and gated the *next* step (enqueue_push) on it. On the original run
// the closure executed (id non-nil) so enqueue_push was recorded; on recovery
// the memoized step body does NOT run, so the captured id stayed nil, the gate
// flipped, enqueue_push was skipped, and the workflow reached Recv where DBOS
// expected enqueue_push — a non-deterministic step sequence DBOS records as
// terminal ERROR. The task could then never advance, and the human's
// completeTask Send landed on a dead workflow ("completed but never moved on").
//
// The pre-existing recovery tests in chain_recovery_test.go register with a nil
// push enqueuer and empty owner URI, so enqueue_push is never recorded and the
// bug cannot reproduce — that is precisely why it slipped through. This test
// wires a real push enqueuer + owner URI so enqueue_push IS recorded on the
// original run, then restarts mid-wait and proves the recovered workflow does
// NOT poison to ERROR and still completes to DONE.
func TestChainRecovery_PushEnqueuerSurvivesRestartAtEachStage(t *testing.T) {
	humanWaitStages := []db.ChainStage{
		db.ChainStageTriage,
		db.ChainStageExpansion,
		db.ChainStageExecution,
	}

	for i, target := range humanWaitStages {
		stagesBefore := humanWaitStages[:i]
		stagesFrom := humanWaitStages[i:]
		t.Run("restart_in_"+string(target), func(t *testing.T) {
			ctx := context.Background()
			pool1 := testutil.TestDB(t)
			dsn := pool1.Config().ConnConfig.ConnString()
			require.NoError(t, db.Migrate(ctx, dsn))
			q1 := db.New(pool1)
			require.NoError(t, core.SeedOwner(ctx, q1))
			owner, err := q1.GetViewer(ctx)
			require.NoError(t, err)

			executorID := "recovery-push-" + uuid.New().String()
			enqueuer := &countingPushEnqueuer{}

			// --- Run 1: bring up DBOS with push + owner wired, drive to target. ---
			dctx1, err := durable.Init(ctx, pool1, executorID)
			require.NoError(t, err)
			durable.RegisterChainWorkflow(dctx1, pool1, q1, chain.HumanOnlyRouter{}, nil, owner.GlobalUri, enqueuer, nil)
			require.NoError(t, durable.Launch(dctx1))

			handler1 := server.New(pool1, dctx1, server.Options{})
			env1 := &chainEnv{pool: pool1, dctx: dctx1, handler: handler1, queries: q1}
			taskID := createTaskGQL(t, env1, "recovery-push-"+string(target))
			workflowID := chain.ChainWorkflowID(taskID)

			// The first block is always TRIAGE; complete each stage before the
			// target so the workflow is blocked precisely at `target`.
			pollUntilAssignmentAt(t, env1, taskID, db.ChainStageTriage)
			for j, stage := range stagesBefore {
				completeTaskGQL(t, env1, taskID, map[string]any{"stage": string(stage)})
				pollUntilAssignmentAt(t, env1, taskID, humanWaitStages[j+1])
			}
			openBefore := pollUntilAssignmentAt(t, env1, taskID, target)
			require.GreaterOrEqual(t, enqueuer.count.Load(), int64(1),
				"original run must record the enqueue_push step (else the bug can't reproduce)")

			// --- Simulate process loss: shut DBOS down, abandon the goroutine,
			//     and force the workflow row back to PENDING (mimicking kill -9)
			//     so the next Launch's version-matched recovery replays it. ---
			durable.Shutdown(dctx1, 1*time.Second)
			pool1.Close()
			resetPool, err := pgxpool.New(ctx, dsn)
			require.NoError(t, err)
			_, err = resetPool.Exec(ctx,
				`UPDATE dbos.workflow_status SET status = 'PENDING' WHERE workflow_uuid = $1`,
				workflowID)
			require.NoError(t, err)
			resetPool.Close()

			// --- Run 2: same DB + executor, fresh pool + DBOS context. ---
			pool2, err := pgxpool.New(ctx, dsn)
			require.NoError(t, err)
			t.Cleanup(func() { pool2.Close() })
			q2 := db.New(pool2)

			dctx2, err := durable.Init(ctx, pool2, executorID)
			require.NoError(t, err)
			durable.RegisterChainWorkflow(dctx2, pool2, q2, chain.HumanOnlyRouter{}, nil, owner.GlobalUri, enqueuer, nil)
			require.NoError(t, durable.Launch(dctx2))
			defer durable.Shutdown(dctx2, 5*time.Second)

			handler2 := server.New(pool2, dctx2, server.Options{})
			env2 := &chainEnv{pool: pool2, dctx: dctx2, handler: handler2, queries: q2}

			// The regression: the recovered workflow must NOT flip to terminal
			// ERROR while replaying its memoized steps.
			requireWorkflowNeverErrors(t, ctx, pool2, workflowID, 5*time.Second)

			// Recovery replays to the SAME open assignment, not a fresh one.
			openAfter := pollUntilAssignmentAt(t, env2, taskID, target)
			require.Equal(t, openBefore.ID, openAfter.ID, "recovery should NOT open a new assignment")

			// Give recovery a moment to re-enter Recv before resolving the slot.
			time.Sleep(500 * time.Millisecond)

			// Complete the target stage and every remaining stage → DONE.
			for k, stage := range stagesFrom {
				completeTaskGQL(t, env2, taskID, map[string]any{"stage": string(stage)})
				if k+1 < len(stagesFrom) {
					pollUntilAssignmentAt(t, env2, taskID, stagesFrom[k+1])
				}
			}
			pollUntilTaskState(t, env2, taskID, db.TaskStateDone)
		})
	}
}

// requireWorkflowNeverErrors asserts the DBOS workflow does not enter terminal
// ERROR over the window — the precise failure signature of the determinism bug.
func requireWorkflowNeverErrors(t *testing.T, ctx context.Context, pool *pgxpool.Pool, wfID string, window time.Duration) {
	t.Helper()
	deadline := time.Now().Add(window)
	for time.Now().Before(deadline) {
		var status, errMsg string
		err := pool.QueryRow(ctx,
			`SELECT status, COALESCE(error, '') FROM dbos.workflow_status WHERE workflow_uuid = $1`,
			wfID).Scan(&status, &errMsg)
		require.NoError(t, err)
		require.NotEqualf(t, "ERROR", status,
			"chain workflow poisoned to terminal ERROR on recovery (determinism regression): %s", errMsg)
		time.Sleep(100 * time.Millisecond)
	}
}
