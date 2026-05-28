package core

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// CreatedTask is the slim shape returned to the seed path.
type CreatedTask struct {
	ID        uuid.UUID
	GlobalURI string
	Title     string
}

// CreateTask inserts a new Task with a freshly generated id and the
// `local://task/<uuid>` global_uri. Defaults from the migration apply
// (state=eligible, current_stage=creation).
func CreateTask(ctx context.Context, q *db.Queries, title, description string) (CreatedTask, error) {
	if title == "" {
		return CreatedTask{}, fmt.Errorf("title is required")
	}
	id := uuid.New()
	var descPtr *string
	if description != "" {
		d := description
		descPtr = &d
	}
	row, err := q.CreateTask(ctx, db.CreateTaskParams{
		ID:          id,
		GlobalUri:   TaskURI(id),
		Title:       title,
		Description: descPtr,
	})
	if err != nil {
		return CreatedTask{}, fmt.Errorf("create task: %w", err)
	}
	return CreatedTask{
		ID:        row.ID,
		GlobalURI: row.GlobalUri,
		Title:     row.Title,
	}, nil
}
