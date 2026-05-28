package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// taskAlreadyTerminalError shapes the typed GraphQL error returned when a
// mutation targets a terminal task. Extracted from schema.resolvers.go so
// gqlgen's resolver-rewriter doesn't orphan it.
func taskAlreadyTerminalError(ctx context.Context, state db.TaskState) *gqlerror.Error {
	return &gqlerror.Error{
		Message: fmt.Sprintf("task is already terminal (state=%s)", state),
		Path:    graphql.GetPath(ctx),
		Extensions: map[string]any{
			"code":  TaskAlreadyTerminalCode,
			"state": string(state),
		},
	}
}

// loadAnyWorkflow loads the most recent chain_workflows row for a task,
// regardless of status. Returns nil if no workflow has ever been attached.
func loadAnyWorkflow(ctx context.Context, pool interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}, taskID uuid.UUID) (*model.WorkflowRef, error) {
	row := pool.QueryRow(ctx,
		`SELECT dbos_workflow_id, started_at
		 FROM chain_workflows
		 WHERE task_id = $1
		 ORDER BY started_at DESC, id DESC
		 LIMIT 1`, taskID)
	var (
		wfID      string
		startedAt = pgtype.Timestamptz{}
	)
	if err := row.Scan(&wfID, &startedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("get any workflow: %w", err)
	}
	return &model.WorkflowRef{ID: wfID, StartedAt: startedAt.Time}, nil
}

// encodeResult marshals an optional map[string]any result into a stable JSON
// payload, using {} for nil.
func encodeResult(result map[string]any) (json.RawMessage, error) {
	if result == nil {
		return json.RawMessage("{}"), nil
	}
	b, err := json.Marshal(result)
	if err != nil {
		return nil, fmt.Errorf("marshal result: %w", err)
	}
	return b, nil
}
