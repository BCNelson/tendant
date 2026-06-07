-- name: UpsertConnectorConfig :one
-- setConnectorConfig (owner-only). Upserts the integration's config; `enabled`
-- is left untouched on update and defaults false on insert — enable/disable is
-- the separate enableConnector mutation (which (de)registers the DBOS schedule).
INSERT INTO connector_configs (id, connector_type, filter, schedule, disposition_rules, enabled)
VALUES ($1, $2, $3, $4, $5, false)
ON CONFLICT (id) DO UPDATE
  SET connector_type    = EXCLUDED.connector_type,
      filter            = EXCLUDED.filter,
      schedule          = EXCLUDED.schedule,
      disposition_rules = EXCLUDED.disposition_rules
RETURNING *;

-- name: SetConnectorEnabled :one
-- enableConnector (owner-only). Flips the enabled flag; the resolver pairs this
-- with scheduler.CreateSchedule / DeleteSchedule.
UPDATE connector_configs SET enabled = $2 WHERE id = $1 RETURNING *;

-- name: GetConnectorConfig :one
SELECT * FROM connector_configs WHERE id = $1;

-- name: ListConnectorConfigs :many
-- Backs the owner-only `connectors` query.
SELECT * FROM connector_configs ORDER BY created_at;

-- name: ListEnabledConnectorConfigs :many
-- Boot rehydration: re-create a DBOS schedule for every enabled connector.
SELECT * FROM connector_configs WHERE enabled = true ORDER BY created_at;

-- name: UpsertSourceCredential :exec
-- Seal-at-rest (research R7): `encrypted` is crypto.Seal(token bundle JSON).
INSERT INTO source_credentials (connector_id, encrypted, expires_at)
VALUES ($1, $2, $3)
ON CONFLICT (connector_id) DO UPDATE
  SET encrypted = EXCLUDED.encrypted, expires_at = EXCLUDED.expires_at;

-- name: GetSourceCredential :one
SELECT * FROM source_credentials WHERE connector_id = $1;
