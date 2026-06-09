-- name: ListTaskCategories :many
SELECT id, key, parent_id, label, description, stage_bindings, origin, version
FROM task_categories
ORDER BY key;

-- name: GetTaskCategoryByKey :one
SELECT id, key, parent_id, label, description, stage_bindings, origin, version
FROM task_categories
WHERE key = @key;

-- name: InsertTaskCategory :one
INSERT INTO task_categories (key, parent_id, label, description, stage_bindings, origin, version)
VALUES (@key, @parent_id, @label, @description, @stage_bindings, @origin, @version)
RETURNING id, key, parent_id, label, description, stage_bindings, origin, version;

-- name: UpdateTaskCategoryByKey :one
-- Applies an override to an existing category row. Bumps version so the change
-- is observable, mirroring UpdateAgentConfigByNameAndStage.
UPDATE task_categories
SET parent_id      = @parent_id,
    label          = @label,
    description    = @description,
    stage_bindings = @stage_bindings,
    version        = version + 1
WHERE key = @key
RETURNING id, key, parent_id, label, description, stage_bindings, origin, version;

-- name: DeleteTaskCategoryByKey :exec
DELETE FROM task_categories
WHERE key = @key;
