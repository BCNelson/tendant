package lifecycle_test

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupTestDB(t *testing.T) (*pgxpool.Pool, *db.Queries, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	return pool, q, ctx
}

func seedTask(t *testing.T, ctx context.Context, q *db.Queries, state lifecycle.TaskState) db.Task {
	t.Helper()
	id := uuid.New()
	row, err := q.CreateTask(ctx, db.CreateTaskParams{
		ID:           id,
		GlobalUri:    core.TaskURI(id),
		Title:        "test",
		State:        state,
		CurrentStage: lifecycle.StageCreation,
	})
	require.NoError(t, err)
	return row
}

func TestIsLegalAndIsTerminal(t *testing.T) {
	t.Parallel()
	cases := []struct {
		from, to lifecycle.TaskState
		legal    bool
	}{
		{lifecycle.StateProposed, lifecycle.StateAccepted, true},
		{lifecycle.StateProposed, lifecycle.StateDismissed, true},
		{lifecycle.StateProposed, lifecycle.StateHalted, true},
		{lifecycle.StateAccepted, lifecycle.StateExecuting, true},
		{lifecycle.StateAccepted, lifecycle.StateWaiting, true},
		{lifecycle.StateAccepted, lifecycle.StateHalted, true},
		{lifecycle.StateWaiting, lifecycle.StateExecuting, true},
		{lifecycle.StateExecuting, lifecycle.StateDone, true},
		{lifecycle.StateExecuting, lifecycle.StateHalted, true},
		// Illegal edges.
		{lifecycle.StateProposed, lifecycle.StateExecuting, false},
		{lifecycle.StateAccepted, lifecycle.StateDone, false},
		{lifecycle.StateWaiting, lifecycle.StateAccepted, false},
		// Terminal sinks: no outbound edges.
		{lifecycle.StateDone, lifecycle.StateExecuting, false},
		{lifecycle.StateDone, lifecycle.StateHalted, false},
		{lifecycle.StateDismissed, lifecycle.StateAccepted, false},
		{lifecycle.StateHalted, lifecycle.StateExecuting, false},
	}
	for _, c := range cases {
		got := lifecycle.IsLegal(c.from, c.to)
		require.Equal(t, c.legal, got, "%s → %s", c.from, c.to)
	}

	require.True(t, lifecycle.IsTerminal(lifecycle.StateDone))
	require.True(t, lifecycle.IsTerminal(lifecycle.StateDismissed))
	require.True(t, lifecycle.IsTerminal(lifecycle.StateHalted))
	require.False(t, lifecycle.IsTerminal(lifecycle.StateAccepted))
	require.False(t, lifecycle.IsTerminal(lifecycle.StateExecuting))
}

func TestTransition_LegalEdgeWritesAuditAndAdvances(t *testing.T) {
	t.Parallel()
	pool, q, ctx := setupTestDB(t)
	task := seedTask(t, ctx, q, lifecycle.StateAccepted)

	var firstAuditID uuid.UUID
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		id, err := lifecycle.Transition(ctx, tx, task.ID, lifecycle.StateAccepted, lifecycle.StateExecuting, "readiness true", lifecycle.StageExpansion)
		firstAuditID = id
		return err
	}))

	got, err := q.GetTask(ctx, task.ID)
	require.NoError(t, err)
	require.Equal(t, lifecycle.StateExecuting, got.State)

	rows, err := q.ListAuditForTask(ctx, task.ID)
	require.NoError(t, err)
	require.Len(t, rows, 1, "exactly one audit row per transition")
	require.Equal(t, lifecycle.KindStateTransition, rows[0].Kind)
	require.Equal(t, firstAuditID, rows[0].ID)
	require.False(t, rows[0].InReplyTo.Valid, "first transition has no parent")

	var payload lifecycle.StateTransitionPayload
	require.NoError(t, json.Unmarshal(rows[0].Payload, &payload))
	require.Equal(t, lifecycle.StateAccepted, payload.From)
	require.Equal(t, lifecycle.StateExecuting, payload.To)
	require.Equal(t, "readiness true", payload.Reason)
	require.Equal(t, "expansion", payload.Stage)

	// Second transition should chain in_reply_to to the first.
	var secondAuditID uuid.UUID
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		id, err := lifecycle.Transition(ctx, tx, task.ID, lifecycle.StateExecuting, lifecycle.StateDone, "complete", "")
		secondAuditID = id
		return err
	}))
	rows, err = q.ListAuditForTask(ctx, task.ID)
	require.NoError(t, err)
	require.Len(t, rows, 2)
	require.Equal(t, secondAuditID, rows[1].ID)
	require.True(t, rows[1].InReplyTo.Valid)
	require.Equal(t, firstAuditID, uuid.UUID(rows[1].InReplyTo.Bytes))
}

func TestTransition_IllegalEdgeReturnsTypedError(t *testing.T) {
	t.Parallel()
	pool, q, ctx := setupTestDB(t)
	task := seedTask(t, ctx, q, lifecycle.StateAccepted)

	err := pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		_, txErr := lifecycle.Transition(ctx, tx, task.ID, lifecycle.StateAccepted, lifecycle.StateDone, "skip", "")
		return txErr
	})
	require.Error(t, err)
	var ill *lifecycle.ErrIllegalTransition
	require.True(t, errors.As(err, &ill))
	require.Equal(t, lifecycle.StateAccepted, ill.From)
	require.Equal(t, lifecycle.StateDone, ill.To)

	// State should NOT have changed (tx rolled back).
	got, err := q.GetTask(ctx, task.ID)
	require.NoError(t, err)
	require.Equal(t, lifecycle.StateAccepted, got.State)

	rows, err := q.ListAuditForTask(ctx, task.ID)
	require.NoError(t, err)
	require.Empty(t, rows, "no audit row on illegal transition")
}

func TestTransition_TerminalOutboundRejected(t *testing.T) {
	t.Parallel()
	pool, q, ctx := setupTestDB(t)
	task := seedTask(t, ctx, q, lifecycle.StateDone)

	err := pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		_, txErr := lifecycle.Transition(ctx, tx, task.ID, lifecycle.StateDone, lifecycle.StateExecuting, "", "")
		return txErr
	})
	var ill *lifecycle.ErrIllegalTransition
	require.True(t, errors.As(err, &ill))
}

func TestAdvanceStage_WritesAuditAndChains(t *testing.T) {
	t.Parallel()
	pool, q, ctx := setupTestDB(t)
	task := seedTask(t, ctx, q, lifecycle.StateAccepted)

	var firstID uuid.UUID
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		id, err := lifecycle.AdvanceStage(ctx, tx, task.ID, lifecycle.StageCreation, lifecycle.StageTriage, "genesis")
		firstID = id
		return err
	}))

	got, err := q.GetTask(ctx, task.ID)
	require.NoError(t, err)
	require.Equal(t, lifecycle.StageTriage, got.CurrentStage)

	rows, err := q.ListAuditForTask(ctx, task.ID)
	require.NoError(t, err)
	require.Len(t, rows, 1)
	require.Equal(t, lifecycle.KindStageAdvance, rows[0].Kind)
	require.Equal(t, firstID, rows[0].ID)

	// A second AdvanceStage chains in_reply_to.
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		_, err := lifecycle.AdvanceStage(ctx, tx, task.ID, lifecycle.StageTriage, lifecycle.StageExpansion, "")
		return err
	}))
	rows, err = q.ListAuditForTask(ctx, task.ID)
	require.NoError(t, err)
	require.Len(t, rows, 2)
	require.True(t, rows[1].InReplyTo.Valid)
	require.Equal(t, firstID, uuid.UUID(rows[1].InReplyTo.Bytes))
}
