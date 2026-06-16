-- name: GetToolByID :one
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
       mcp_server_id, input_schema, mcp_annotations, retired_at
FROM tools
WHERE id = $1
LIMIT 1;

-- name: GetToolByGlobalURI :one
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
       mcp_server_id, input_schema, mcp_annotations, retired_at
FROM tools
WHERE global_uri = $1
LIMIT 1;

-- name: ListTools :many
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
       mcp_server_id, input_schema, mcp_annotations, retired_at
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
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
          mcp_server_id, input_schema, mcp_annotations, retired_at;

-- name: UpsertMcpTool :one
-- Reconcile one discovered MCP tool. On INSERT it lands fail-closed: the caller
-- passes the conservative default permissions (every call trips the gate floor →
-- owner review) so nothing auto-executes before the owner tunes it. On CONFLICT
-- (the tool already exists from a prior sync) it touches ONLY the upstream-owned
-- fields (name, input_schema, mcp_annotations) and clears retired_at (un-retire
-- if the tool reappeared) + re-attaches the server — it NEVER clobbers the
-- owner-/calibration-owned columns (permissions, overseer_instructions, rung,
-- trust_score, active_script_version), mirroring ReconcileTools' discipline.
INSERT INTO tools (global_uri, name, rung, permissions, mcp_server_id, input_schema, mcp_annotations)
VALUES ($1, $2, 'execute_gated', $3, $4, $5, $6)
ON CONFLICT (global_uri) DO UPDATE
  SET name            = EXCLUDED.name,
      mcp_server_id   = EXCLUDED.mcp_server_id,
      input_schema    = EXCLUDED.input_schema,
      mcp_annotations = EXCLUDED.mcp_annotations,
      retired_at      = NULL
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
          mcp_server_id, input_schema, mcp_annotations, retired_at;

-- name: ListMcpToolsByServer :many
-- Live (non-retired) tools for one server — the reconcile diff reads this to
-- find rows to retire when an upstream tool vanishes.
SELECT id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score,
       mcp_server_id, input_schema, mcp_annotations, retired_at
FROM tools
WHERE mcp_server_id = $1 AND retired_at IS NULL
ORDER BY name ASC;

-- name: RetireMcpTool :exec
-- Mark a tool retired (upstream definition vanished or its server was removed).
-- The row is kept for audit/calibration history; its adapter is deregistered.
UPDATE tools SET retired_at = now() WHERE id = $1 AND retired_at IS NULL;

-- name: RetireMcpToolsForServer :exec
-- Retire every live tool for a server in one statement (the removeMcpServer flow).
UPDATE tools SET retired_at = now() WHERE mcp_server_id = $1 AND retired_at IS NULL;

-- name: ListActiveMcpTools :many
-- Boot rehydration: every live MCP-backed tool with its server's slug + endpoint,
-- so main can rebuild the registry adapters without contacting any upstream.
SELECT t.global_uri AS global_uri,
       t.mcp_server_id AS mcp_server_id,
       s.slug AS slug
FROM tools t
JOIN mcp_servers s ON s.id = t.mcp_server_id
WHERE t.mcp_server_id IS NOT NULL
  AND t.retired_at IS NULL
  AND s.enabled = true
ORDER BY s.slug, t.name;
