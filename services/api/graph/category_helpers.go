package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// mapTaskCategory projects a task_categories row into the GraphQL model. parent
// and children are lazy field resolvers, so only the row's own scalar fields are
// filled here. stageBindings is decoded from jsonb into a JSON map.
func mapTaskCategory(row *db.TaskCategory) *model.TaskCategory {
	bindings := map[string]any{}
	if len(row.StageBindings) > 0 {
		_ = json.Unmarshal(row.StageBindings, &bindings)
	}
	return &model.TaskCategory{
		Key:           row.Key,
		Label:         row.Label,
		Description:   row.Description,
		StageBindings: bindings,
	}
}

// categoriesImpl lists the full taxonomy ordered by key. Read-only; any
// authenticated viewer may read it.
func (r *Resolver) categoriesImpl(ctx context.Context) ([]*model.TaskCategory, error) {
	if _, ok := auth.FromContext(ctx); !ok {
		return nil, unauthorizedError(ctx)
	}
	rows, err := r.Queries.ListTaskCategories(ctx)
	if err != nil {
		return nil, fmt.Errorf("list categories: %w", err)
	}
	out := make([]*model.TaskCategory, 0, len(rows))
	for i := range rows {
		out = append(out, mapTaskCategory(&rows[i]))
	}
	return out, nil
}

// categoryParentImpl resolves a category's parent by looking up its own row, then
// the row its parent_id points to. Returns nil for a root category.
func (r *Resolver) categoryParentImpl(ctx context.Context, key string) (*model.TaskCategory, error) {
	self, err := r.Queries.GetTaskCategoryByKey(ctx, key)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	if !self.ParentID.Valid {
		return nil, nil
	}
	rows, err := r.Queries.ListTaskCategories(ctx)
	if err != nil {
		return nil, err
	}
	parentID := uuid.UUID(self.ParentID.Bytes)
	for i := range rows {
		if rows[i].ID == parentID {
			return mapTaskCategory(&rows[i]), nil
		}
	}
	return nil, nil
}

// categoryChildrenImpl resolves a category's direct children (rows whose
// parent_id points at this category).
func (r *Resolver) categoryChildrenImpl(ctx context.Context, key string) ([]*model.TaskCategory, error) {
	self, err := r.Queries.GetTaskCategoryByKey(ctx, key)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	rows, err := r.Queries.ListTaskCategories(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]*model.TaskCategory, 0)
	for i := range rows {
		if rows[i].ParentID.Valid && uuid.UUID(rows[i].ParentID.Bytes) == self.ID {
			out = append(out, mapTaskCategory(&rows[i]))
		}
	}
	return out, nil
}

// taskCategoryImpl resolves a task's assigned category from
// findings.structured.category. Returns nil when uncategorized or the key no
// longer resolves to a row.
func (r *Resolver) taskCategoryImpl(ctx context.Context, taskID uuid.UUID) (*model.TaskCategory, error) {
	t, err := r.Queries.GetTask(ctx, taskID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	var findings struct {
		Structured struct {
			Category string `json:"category"`
		} `json:"structured"`
	}
	if len(t.Findings) > 0 {
		_ = json.Unmarshal(t.Findings, &findings)
	}
	key := strings.TrimSpace(findings.Structured.Category)
	if key == "" {
		return nil, nil
	}
	row, err := r.Queries.GetTaskCategoryByKey(ctx, key)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return mapTaskCategory(&row), nil
}

// setTaskCategoryImpl upserts a category by key. OWNER-ONLY: auth.RequireOwner is
// the FIRST statement, before any DB access. parent is resolved from an explicit
// input.parent or the key path prefix.
func (r *Resolver) setTaskCategoryImpl(ctx context.Context, input model.SetTaskCategoryInput) (*model.TaskCategory, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return nil, permissionDeniedError(ctx)
	}

	key := strings.TrimSpace(input.Key)
	if key == "" {
		return nil, gqlerror.Errorf("input.key is required")
	}

	// Resolve the parent key: explicit input.parent wins (including "" forcing
	// root); otherwise derive from the key path prefix.
	parentKey := ""
	if input.Parent != nil {
		parentKey = strings.TrimSpace(*input.Parent)
	} else if i := strings.LastIndex(key, "/"); i > 0 {
		parentKey = key[:i]
	}

	var parentID pgtype.UUID
	if parentKey != "" {
		parent, err := r.Queries.GetTaskCategoryByKey(ctx, parentKey)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return nil, gqlerror.Errorf("parent category %q not found", parentKey)
			}
			return nil, err
		}
		parentID = pgtype.UUID{Bytes: parent.ID, Valid: true}
	}

	label := key
	if input.Label != nil && strings.TrimSpace(*input.Label) != "" {
		label = *input.Label
	}

	bindings := json.RawMessage("{}")
	if input.StageBindings != nil {
		b, err := json.Marshal(input.StageBindings)
		if err != nil {
			return nil, gqlerror.Errorf("invalid stageBindings: %s", err)
		}
		bindings = b
	}

	// Upsert: update if the key exists, else insert.
	if _, err := r.Queries.GetTaskCategoryByKey(ctx, key); err == nil {
		row, err := r.Queries.UpdateTaskCategoryByKey(ctx, db.UpdateTaskCategoryByKeyParams{
			Key:           key,
			ParentID:      parentID,
			Label:         label,
			Description:   input.Description,
			StageBindings: bindings,
		})
		if err != nil {
			return nil, err
		}
		return mapTaskCategory(&row), nil
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return nil, err
	}

	row, err := r.Queries.InsertTaskCategory(ctx, db.InsertTaskCategoryParams{
		Key:           key,
		ParentID:      parentID,
		Label:         label,
		Description:   input.Description,
		StageBindings: bindings,
		Origin:        db.ConfigOriginCommunity, // owner-edited rows survive boot re-sync
		Version:       1,
	})
	if err != nil {
		return nil, err
	}
	return mapTaskCategory(&row), nil
}

// deleteTaskCategoryImpl removes a category by key. OWNER-ONLY.
func (r *Resolver) deleteTaskCategoryImpl(ctx context.Context, key string) (bool, error) {
	if _, err := auth.RequireOwner(ctx); err != nil {
		return false, permissionDeniedError(ctx)
	}
	if err := r.Queries.DeleteTaskCategoryByKey(ctx, strings.TrimSpace(key)); err != nil {
		return false, err
	}
	return true, nil
}
