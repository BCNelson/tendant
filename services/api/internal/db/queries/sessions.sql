-- name: IssueSession :one
INSERT INTO sessions (principal_id, token_hash, display_name)
VALUES ($1, $2, $3)
RETURNING id, principal_id, token_hash, display_name, created_at, last_seen_at, revoked_at;

-- name: FindSessionByTokenHash :one
SELECT id, principal_id, token_hash, display_name, created_at, last_seen_at, revoked_at
FROM sessions
WHERE token_hash = $1 AND revoked_at IS NULL
LIMIT 1;

-- name: RevokeSession :one
UPDATE sessions
SET revoked_at = now()
WHERE id = $1 AND revoked_at IS NULL
RETURNING id, principal_id, token_hash, display_name, created_at, last_seen_at, revoked_at;

-- name: GetSessionByID :one
SELECT id, principal_id, token_hash, display_name, created_at, last_seen_at, revoked_at
FROM sessions
WHERE id = $1
LIMIT 1;

-- name: ListActiveSessionsForPrincipal :many
SELECT id, principal_id, token_hash, display_name, created_at, last_seen_at, revoked_at
FROM sessions
WHERE principal_id = $1 AND revoked_at IS NULL
ORDER BY created_at DESC;

-- name: TouchSessionLastSeen :exec
UPDATE sessions SET last_seen_at = now() WHERE id = $1;
