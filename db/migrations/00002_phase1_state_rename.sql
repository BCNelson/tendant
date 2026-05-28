-- Phase 1: rename task_state.eligible → waiting, default new tasks to 'accepted'.
-- See specs/002-task-lifecycle-chain/data-model.md §"Schema changes" and
-- research §R4 for rationale.

-- +goose Up
-- +goose StatementBegin
ALTER TYPE task_state RENAME VALUE 'eligible' TO 'waiting';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE tasks ALTER COLUMN state SET DEFAULT 'accepted';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TYPE task_state RENAME VALUE 'waiting' TO 'eligible';
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE tasks ALTER COLUMN state SET DEFAULT 'eligible';
-- +goose StatementEnd
