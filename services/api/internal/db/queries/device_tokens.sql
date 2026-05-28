-- name: UpsertDeviceToken :one
INSERT INTO device_tokens (token, owner_id, platform)
VALUES ($1, $2, $3)
ON CONFLICT (token) DO UPDATE
  SET owner_id = EXCLUDED.owner_id,
      platform = EXCLUDED.platform
RETURNING token, owner_id, platform, created_at;

-- name: DeleteDeviceToken :exec
DELETE FROM device_tokens WHERE token = $1 AND owner_id = $2;

-- name: ListDeviceTokensForPrincipal :many
SELECT token, owner_id, platform, created_at
FROM device_tokens
WHERE owner_id = $1
ORDER BY created_at DESC;

-- name: ListDeviceTokensForPrincipalByGlobalURI :many
SELECT dt.token, dt.owner_id, dt.platform, dt.created_at
FROM device_tokens dt
JOIN principals p ON p.id = dt.owner_id
WHERE p.global_uri = $1
ORDER BY dt.created_at DESC;

-- name: DeleteDeviceTokensByValue :exec
DELETE FROM device_tokens WHERE token = ANY($1::text[]);
