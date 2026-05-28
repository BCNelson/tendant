package core

import (
	"context"
	"fmt"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// CreatedTask is the slim shape returned to the seed path.
type CreatedTask struct {
	ID        uuid.UUID
	GlobalURI string
	Title     string
}

// CreateTask inserts a new owner-authored Task with state='accepted',
// current_stage='creation', then attaches a chain workflow that immediately
// advances to TRIAGE and opens the first human slot.
//
// dctx may be nil — in that case the task is inserted but no chain workflow
// is attached. Used by the legacy seed CLI / Phase-0 tests that don't yet
// drive the chain.
func CreateTask(
	ctx context.Context,
	pool *pgxpool.Pool,
	dctx dbos.DBOSContext,
	title, description string,
) (CreatedTask, error) {
	if title == "" {
		return CreatedTask{}, fmt.Errorf("title is required")
	}
	id := uuid.New()
	var descPtr *string
	if description != "" {
		d := description
		descPtr = &d
	}

	q := db.New(pool)
	row, err := q.CreateTask(ctx, db.CreateTaskParams{
		ID:           id,
		GlobalUri:    TaskURI(id),
		Title:        title,
		Description:  descPtr,
		State:        lifecycle.StateAccepted,
		CurrentStage: lifecycle.StageCreation,
	})
	if err != nil {
		return CreatedTask{}, fmt.Errorf("create task: %w", err)
	}

	if dctx != nil {
		if err := AttachChainWorkflow(ctx, pool, dctx, row.ID); err != nil {
			return CreatedTask{}, fmt.Errorf("attach chain workflow: %w", err)
		}
	}

	return CreatedTask{
		ID:        row.ID,
		GlobalURI: row.GlobalUri,
		Title:     row.Title,
	}, nil
}

// AttachChainWorkflow inserts the chain_workflows row, writes the initial
// `workflow_started` audit row, commits, then starts the DBOS workflow with
// the deterministic id `chain:<task_uuid>` (research R5). Idempotent against
// re-call only at the unique-index level — callers should ensure they invoke
// it once per task.
func AttachChainWorkflow(ctx context.Context, pool *pgxpool.Pool, dctx dbos.DBOSContext, taskID uuid.UUID) error {
	workflowID := chain.ChainWorkflowID(taskID)
	if err := pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		if _, err := q.InsertChainWorkflow(ctx, db.InsertChainWorkflowParams{
			TaskID:         taskID,
			DbosWorkflowID: workflowID,
		}); err != nil {
			return fmt.Errorf("insert chain workflow row: %w", err)
		}
		payload := lifecycle.WorkflowStartedPayload{DbosWorkflowID: workflowID}
		if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, lifecycle.KindWorkflowStarted, payload, uuid.Nil); err != nil {
			return fmt.Errorf("audit workflow_started: %w", err)
		}
		return nil
	}); err != nil {
		return err
	}

	if _, err := dbos.RunWorkflow(dctx, chain.ChainWorkflow, taskID.String(),
		dbos.WithWorkflowID(workflowID)); err != nil {
		return fmt.Errorf("run chain workflow: %w", err)
	}
	return nil
}
