-- name: GetToolByID :one
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version
FROM tools
WHERE id = $1
LIMIT 1;

-- name: GetToolByGlobalURI :one
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version
FROM tools
WHERE global_uri = $1
LIMIT 1;

-- name: ListTools :many
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version
FROM tools
ORDER BY name ASC;

-- name: UpsertTool :one
-- Idempotent: callers can re-run on boot to keep the tool row in sync with
-- the in-process tool registry. global_uri is the natural key.
INSERT INTO tools (global_uri, name, rung, permissions, overseer_instructions)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (global_uri) DO UPDATE
  SET name                  = EXCLUDED.name,
      rung                  = EXCLUDED.rung,
      permissions           = EXCLUDED.permissions,
      overseer_instructions = EXCLUDED.overseer_instructions
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version;
