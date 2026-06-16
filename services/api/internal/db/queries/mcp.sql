-- name: InsertMcpServer :one
-- registerMcpServer (owner-only). A new server starts disabled + unsynced;
-- enableMcpServer + syncMcpServer bring it online. slug is UNIQUE.
INSERT INTO mcp_servers (slug, name, endpoint_url)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetMcpServer :one
SELECT * FROM mcp_servers WHERE id = $1;

-- name: GetMcpServerBySlug :one
SELECT * FROM mcp_servers WHERE slug = $1;

-- name: ListMcpServers :many
SELECT * FROM mcp_servers ORDER BY created_at;

-- name: ListEnabledMcpServers :many
SELECT * FROM mcp_servers WHERE enabled = true ORDER BY created_at;

-- name: UpdateMcpServerConfig :one
-- setMcpServerConfig (owner-only). Updates the display name + endpoint.
UPDATE mcp_servers
  SET name = $2, endpoint_url = $3
WHERE id = $1
RETURNING *;

-- name: SetMcpServerEnabled :one
-- enableMcpServer (owner-only).
UPDATE mcp_servers SET enabled = $2 WHERE id = $1 RETURNING *;

-- name: SetMcpServerSyncResult :one
-- Records the outcome of a sync attempt (status + negotiated protocol version +
-- timestamp).
UPDATE mcp_servers
  SET status = $2, protocol_version = $3, last_synced_at = now()
WHERE id = $1
RETURNING *;

-- name: DeleteMcpServer :exec
-- removeMcpServer (owner-only). Tool rows are ON DELETE SET NULL (retired first
-- by the resolver), credentials cascade.
DELETE FROM mcp_servers WHERE id = $1;

-- name: UpsertMcpServerCredential :exec
-- Seal-at-rest (AES-256-GCM): `encrypted` is crypto.Seal(mcp.Auth JSON).
INSERT INTO mcp_server_credentials (mcp_server_id, encrypted, expires_at)
VALUES ($1, $2, $3)
ON CONFLICT (mcp_server_id) DO UPDATE
  SET encrypted = EXCLUDED.encrypted, expires_at = EXCLUDED.expires_at;

-- name: GetMcpServerCredential :one
SELECT * FROM mcp_server_credentials WHERE mcp_server_id = $1;

-- name: DeleteMcpServerCredential :exec
DELETE FROM mcp_server_credentials WHERE mcp_server_id = $1;
