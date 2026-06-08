-- name: UpsertConfigEntry :one
INSERT INTO config_entries (key, value, updated_at)
VALUES ($1, $2, now())
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()
RETURNING *;

-- name: GetConfigEntry :one
SELECT * FROM config_entries WHERE key = $1;

-- name: ListConfigEntries :many
SELECT * FROM config_entries ORDER BY key;

-- name: DeleteConfigEntry :exec
DELETE FROM config_entries WHERE key = $1;
