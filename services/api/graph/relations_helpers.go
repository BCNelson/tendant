package graph

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// relatedTasks runs a list-query that takes a task id and returns []db.Task,
// then maps the result — the shared shape behind every list-valued relation
// field resolver.
func (r *taskResolver) relatedTasks(ctx context.Context, taskID string, query func(context.Context, uuid.UUID) ([]db.Task, error)) ([]*model.Task, error) {
	id, err := uuid.Parse(taskID)
	if err != nil {
		return nil, fmt.Errorf("invalid id: %w", err)
	}
	rows, err := query(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("list related tasks: %w", err)
	}
	return mapTasks(rows)
}

// optionalRelatedTask runs a :one relation query that may return no row (no
// parent / not a duplicate) and maps the result to a nullable Task.
func (r *taskResolver) optionalRelatedTask(ctx context.Context, taskID string, query func(context.Context, uuid.UUID) (db.Task, error)) (*model.Task, error) {
	id, err := uuid.Parse(taskID)
	if err != nil {
		return nil, fmt.Errorf("invalid id: %w", err)
	}
	row, err := query(ctx, id)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("get related task: %w", err)
	}
	return mapTask(&row)
}

// mapTasks maps a slice of sqlc Task rows to GraphQL Task models. Autonomy is
// left at NONE — the relation traversals surface tasks for context (dependency
// lists, subtask trees), not full per-task derivation; clients re-query a task
// by id when they need its derived autonomy.
func mapTasks(rows []db.Task) ([]*model.Task, error) {
	out := make([]*model.Task, 0, len(rows))
	for i := range rows {
		m, err := mapTask(&rows[i])
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, nil
}

// lowerTaskRelationKind maps a GraphQL TaskRelationKind (uppercase) to the db
// enum (lowercase). The 1:1 name mapping mirrors the other enum conversions.
func lowerTaskRelationKind(k model.TaskRelationKind) db.TaskRelationKind {
	return db.TaskRelationKind(strings.ToLower(string(k)))
}

// isUniqueViolation reports whether err is a Postgres unique-constraint
// violation (SQLSTATE 23505) — used to turn a duplicate / second-parent /
// second-canonical insert into a friendly resolver error.
func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505"
}
