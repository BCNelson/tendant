package chain_test

import (
	"context"
	"encoding/json"
	"reflect"
	"testing"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// TestWaitPrimitive_IsGeneric registers a synthetic workflow that uses
// chain.WaitForResult against an arbitrary key (NOT a stage / task /
// assignment) and resolves it from outside the workflow with chain.Resolve.
// Asserts the payload arrives unmodified — proving the primitive is not
// human-/stage-specific (SC-004 / US5).
func TestWaitPrimitive_IsGeneric(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)

	dctx, err := durable.Init(ctx, pool, "wait-test-"+uuid.New().String())
	require.NoError(t, err)
	defer durable.Shutdown(dctx, 5*time.Second)

	dbos.RegisterWorkflow(dctx, syntheticWaitWorkflow,
		dbos.WithWorkflowName("test.synthetic.wait"))
	require.NoError(t, durable.Launch(dctx))

	wfID := "synthetic-" + uuid.New().String()
	handle, err := dbos.RunWorkflow(dctx, syntheticWaitWorkflow, "synthetic-key",
		dbos.WithWorkflowID(wfID))
	require.NoError(t, err)

	// Resolve from outside; wait primitive is a workflow-agnostic Send/Recv pair.
	go func() {
		// Tiny delay so the workflow has reached Recv.
		time.Sleep(100 * time.Millisecond)
		_ = chain.Resolve(dctx, wfID, "synthetic-key", json.RawMessage(`{"hello":"world"}`))
	}()

	result, err := handle.GetResult()
	require.NoError(t, err)
	require.JSONEq(t, `{"hello":"world"}`, result)
}

// syntheticWaitWorkflow uses the chain wait primitive directly with a
// non-stage key, returning the payload verbatim. Demonstrates the primitive
// works for any caller, not just the chain.
func syntheticWaitWorkflow(ctx dbos.DBOSContext, key string) (string, error) {
	raw, err := chain.WaitForResult(ctx, key, 10*time.Second)
	if err != nil {
		return "", err
	}
	return string(raw), nil
}

// TestWaitPrimitive_SurfaceHasNoHumanParams uses reflection to assert the
// surface of chain.WaitForResult and chain.Resolve has only opaque key /
// payload parameters — no stage / task / assignment / principal. If this
// test fails, a future change is leaking domain coupling into the
// primitive (SC-004).
func TestWaitPrimitive_SurfaceHasNoHumanParams(t *testing.T) {
	waitT := reflect.TypeOf(chain.WaitForResult)
	require.Equal(t, 3, waitT.NumIn(), "WaitForResult: (ctx, topic, timeout) only")
	require.Equal(t, "dbos.DBOSContext", waitT.In(0).String())
	require.Equal(t, "string", waitT.In(1).String())
	require.Equal(t, "time.Duration", waitT.In(2).String())

	resolveT := reflect.TypeOf(chain.Resolve)
	require.Equal(t, 4, resolveT.NumIn(), "Resolve: (ctx, workflowID, topic, payload) only")
	require.Equal(t, "dbos.DBOSContext", resolveT.In(0).String())
	require.Equal(t, "string", resolveT.In(1).String())
	require.Equal(t, "string", resolveT.In(2).String())
	require.Equal(t, "json.RawMessage", resolveT.In(3).String())
}
