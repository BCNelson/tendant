-- name: UpsertOwner :exec
-- Seeds the single owner Principal. Idempotent on startup.
INSERT INTO principals (global_uri, kind, display_name)
VALUES ('local://principal/owner', 'user', 'Owner')
ON CONFLICT (global_uri) DO NOTHING;

-- name: GetViewer :one
-- Returns the owner Principal (the GraphQL `viewer`).
SELECT id, global_uri, kind, display_name, created_at
FROM principals
WHERE global_uri = 'local://principal/owner';
