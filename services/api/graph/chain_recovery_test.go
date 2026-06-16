package graph_test

import (
	"context"
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

// TestChainRecovery_TriageSurvivesProcessKill drives a task to pause on
// TRIAGE, abruptly shuts down DBOS (simulating kill -9), re-inits + re-
// registers + re-launches DBOS over the same Postgres database, and
// verifies the same assignment row is still open and the chain advances on
// completeTask (US3 / SC-003 / FR-011).
//
// The same pgx pool is reused — only the DBOS context is torn down and
// rebuilt; the workflow goroutine inside the old DBOS context is abandoned
// and recovery on the new context picks the workflow back up.
func TestChainRecovery_TriageSurvivesProcessKill(t *testing.T) {
	ctx := context.Background()
	pool1 := testutil.TestDB(t)
	dsn := pool1.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	require.NoError(t, core.SeedOwner(ctx, db.New(pool1)))

	// Phase 1: stable executor ID — recovery looks up workflows registered to
	// this executor's pending set on Launch.
	executorID := "recovery-test-" + uuid.New().String()

	// --- Run 1: bring up DBOS, create a task, let it pause at TRIAGE. ---
	dctx1, err := durable.Init(ctx, pool1, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx1, pool1, db.New(pool1), chain.HumanOnlyRouter{}, nil, "", nil, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx1))

	handler1 := server.New(pool1, dctx1, server.Options{})
	env1 := &chainEnv{pool: pool1, dctx: dctx1, handler: handler1, queries: db.New(pool1)}
	taskID := createTaskGQL(t, env1, "recovery test")
	openBefore := pollUntilAssignmentAt(t, env1, taskID, db.ChainStageTriage)

	// Simulate process loss: graceful Shutdown will record the workflow's
	// status as ERROR (because Recv returned context.Canceled), which DBOS
	// recovery skips. To mimic kill -9 — where the process dies before the
	// goroutine wrapper can record the outcome — force the status back to
	// PENDING via a separate pool so the next Launch's recovery picks it up.
	workflowID := chain.ChainWorkflowID(taskID)
	durable.Shutdown(dctx1, 1*time.Second)
	pool1.Close()
	resetPool, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	_, err = resetPool.Exec(ctx,
		`UPDATE dbos.workflow_status SET status = 'PENDING' WHERE workflow_uuid = $1`,
		workflowID)
	require.NoError(t, err)
	resetPool.Close()

	// --- Run 2: same DB, fresh pool + DBOS context, same executor ID. ---
	pool2, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	t.Cleanup(func() { pool2.Close() })
	q2 := db.New(pool2)

	dctx2, err := durable.Init(ctx, pool2, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx2, pool2, q2, chain.HumanOnlyRouter{}, nil, "", nil, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx2))
	defer durable.Shutdown(dctx2, 5*time.Second)

	handler2 := server.New(pool2, dctx2, server.Options{})
	env2 := &chainEnv{pool: pool2, dctx: dctx2, handler: handler2, queries: q2}

	// Same assignment row should still be the open one.
	openAfter := pollUntilAssignmentAt(t, env2, taskID, db.ChainStageTriage)
	require.Equal(t, openBefore.ID, openAfter.ID, "recovery should NOT create a new TRIAGE assignment")

	// Give recovery a moment to re-enter Recv before resolving the slot.
	time.Sleep(500 * time.Millisecond)

	// completeTask now advances the chain.
	completeTaskGQL(t, env2, taskID, map[string]any{"recovered": true})
	pollUntilAssignmentAt(t, env2, taskID, db.ChainStageExpansion)
}

// TestChainRecovery_ResumesOrphanedVersion reproduces the real bug: a human-wait
// chain workflow that spans a rebuild is left PENDING on an OLDER
// application_version, so Launch's version-filtered recovery skips it. When the
// owner then completes the task, completeTask's dbos.Send delivers a
// stage:execution notification that no live goroutine is in Recv to consume —
// the task is stuck `executing`. durable.RecoverOrphans re-enqueues the
// cross-version orphan; it replays its memoized steps, the replayed Recv
// consumes the already-delivered notification, and the chain finishes to DONE.
func TestChainRecovery_ResumesOrphanedVersion(t *testing.T) {
	ctx := context.Background()
	pool1 := testutil.TestDB(t)
	dsn := pool1.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	require.NoError(t, core.SeedOwner(ctx, db.New(pool1)))

	executorID := "recovery-test-" + uuid.New().String()

	// --- Run 1: drive a human-only task all the way to pause at EXECUTION. ---
	dctx1, err := durable.Init(ctx, pool1, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx1, pool1, db.New(pool1), chain.HumanOnlyRouter{}, nil, "", nil, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx1))

	handler1 := server.New(pool1, dctx1, server.Options{})
	env1 := &chainEnv{pool: pool1, dctx: dctx1, handler: handler1, queries: db.New(pool1)}
	taskID := createTaskGQL(t, env1, "orphaned recovery test")
	pollUntilAssignmentAt(t, env1, taskID, db.ChainStageTriage)
	completeTaskGQL(t, env1, taskID, map[string]any{"triaged": true})
	pollUntilAssignmentAt(t, env1, taskID, db.ChainStageExpansion)
	completeTaskGQL(t, env1, taskID, map[string]any{"expanded": true})
	pollUntilAssignmentAt(t, env1, taskID, db.ChainStageExecution)

	// Simulate the orphan: abandon the goroutine and rewrite the workflow row to
	// PENDING on a DIFFERENT application_version (a prior build). EnablePatching
	// pins both runs to "PATCHING_ENABLED", so the mismatch is forced directly.
	workflowID := chain.ChainWorkflowID(taskID)
	durable.Shutdown(dctx1, 1*time.Second)
	pool1.Close()
	resetPool, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	_, err = resetPool.Exec(ctx,
		`UPDATE dbos.workflow_status SET status = 'PENDING', application_version = 'old-version' WHERE workflow_uuid = $1`,
		workflowID)
	require.NoError(t, err)
	resetPool.Close()

	// --- Run 2: same DB + executor, new (current-version) DBOS context. ---
	pool2, err := pgxpool.New(ctx, dsn)
	require.NoError(t, err)
	t.Cleanup(func() { pool2.Close() })
	q2 := db.New(pool2)

	dctx2, err := durable.Init(ctx, pool2, executorID)
	require.NoError(t, err)
	durable.RegisterChainWorkflow(dctx2, pool2, q2, chain.HumanOnlyRouter{}, nil, "", nil, nil, nil, nil)
	require.NoError(t, durable.Launch(dctx2))
	defer durable.Shutdown(dctx2, 5*time.Second)

	handler2 := server.New(pool2, dctx2, server.Options{})
	env2 := &chainEnv{pool: pool2, dctx: dctx2, handler: handler2, queries: q2}

	// Launch's recovery must NOT pick up the old-version orphan: still PENDING.
	var status, version string
	require.NoError(t, pool2.QueryRow(ctx,
		`SELECT status, application_version FROM dbos.workflow_status WHERE workflow_uuid = $1`,
		workflowID).Scan(&status, &version))
	require.Equal(t, "PENDING", status, "version-filtered Launch recovery should skip the orphan")
	require.Equal(t, "old-version", version)

	// The owner completes the task while the workflow is orphaned: this resolves
	// the open EXECUTION assignment and delivers the stage:execution notification,
	// but nothing consumes it yet — the task stays `executing`.
	completeTaskGQL(t, env2, taskID, map[string]any{"recovered": true})

	// Now run the boot-time orphan recovery. It re-enqueues the cross-version
	// workflow, which replays and consumes the pending notification → DONE.
	require.NoError(t, durable.RecoverOrphans(dctx2, pool2, chain.WorkflowName))
	pollUntilTaskState(t, env2, taskID, db.TaskStateDone)
}
