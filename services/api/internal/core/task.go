package core

import (
	"context"
	"fmt"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
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
// It is the default-metadata wrapper around CreateTaskWithMeta: priority
// 'normal' and no deadline. dctx may be nil — in that case the task is
// inserted but no chain workflow is attached. Used by the legacy seed CLI /
// Phase-0 tests that don't yet drive the chain.
func CreateTask(
	ctx context.Context,
	pool *pgxpool.Pool,
	dctx dbos.DBOSContext,
	title, description string,
) (CreatedTask, error) {
	return CreateTaskWithMeta(ctx, pool, dctx, title, description, db.TaskPriorityNormal, nil)
}

// CreateTaskWithMeta is CreateTask plus the owner-set metadata composed on the
// create screen: a coarse priority dial and an optional due date. priority must
// be one of the db.TaskPriority* values; dueAt may be nil (no deadline).
func CreateTaskWithMeta(
	ctx context.Context,
	pool *pgxpool.Pool,
	dctx dbos.DBOSContext,
	title, description string,
	priority db.TaskPriority,
	dueAt *time.Time,
) (CreatedTask, error) {
	if title == "" {
		return CreatedTask{}, fmt.Errorf("title is required")
	}
	if priority == "" {
		priority = db.TaskPriorityNormal
	}
	id := uuid.New()
	var descPtr *string
	if description != "" {
		d := description
		descPtr = &d
	}
	var due pgtype.Timestamptz
	if dueAt != nil {
		due = pgtype.Timestamptz{Time: *dueAt, Valid: true}
	}

	q := db.New(pool)
	row, err := q.CreateTask(ctx, db.CreateTaskParams{
		ID:           id,
		GlobalUri:    TaskURI(id),
		Title:        title,
		Description:  descPtr,
		State:        lifecycle.StateAccepted,
		CurrentStage: lifecycle.StageCreation,
		Priority:     priority,
		DueAt:        due,
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

// CreateTaskFromSignal inserts an intake-origin Task carrying the signal's
// provenance and a back-link to intake_signals (the marker that a task is
// intake-origin). When state is 'accepted' and dctx is non-nil the chain
// workflow is attached immediately (forced_task / auto-accepted rich_event);
// 'proposed' tasks (rich-hold / llm_judge) attach their chain later, on
// acceptProposedTask — mirroring the Phase-2 proposed-task path.
//
// The provenance argument is the raw jsonb from the signal ({raw_ref, reason}).
func CreateTaskFromSignal(
	ctx context.Context,
	pool *pgxpool.Pool,
	dctx dbos.DBOSContext,
	signalID uuid.UUID,
	title string,
	provenance []byte,
	state lifecycle.TaskState,
) (CreatedTask, error) {
	if title == "" {
		title = "Untitled intake task"
	}
	id := uuid.New()
	q := db.New(pool)
	row, err := q.CreateIntakeTask(ctx, db.CreateIntakeTaskParams{
		ID:             id,
		GlobalUri:      TaskURI(id),
		Title:          title,
		State:          state,
		CurrentStage:   lifecycle.StageCreation,
		Provenance:     provenance,
		IntakeSignalID: signalID,
	})
	if err != nil {
		return CreatedTask{}, fmt.Errorf("create intake task: %w", err)
	}

	if state == lifecycle.StateAccepted && dctx != nil {
		if err := AttachChainWorkflow(ctx, pool, dctx, row.ID); err != nil {
			return CreatedTask{}, fmt.Errorf("attach chain workflow: %w", err)
		}
	}

	return CreatedTask{ID: row.ID, GlobalURI: row.GlobalUri, Title: row.Title}, nil
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
