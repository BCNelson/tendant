-- name: NextGateScriptVersion :one
-- Monotonic per-tool version allocator. Returns 1 for the first attach.
SELECT COALESCE(MAX(version), 0) + 1 AS next_version
FROM gate_scripts
WHERE tool_id = $1;

-- name: CreateGateScript :one
-- Append-only insert (FR-021/FR-022). Caller computes version via
-- NextGateScriptVersion and advances tools.active_script_version separately.
INSERT INTO gate_scripts (
  tool_id, version, manifest, manifest_hash, wasm, source, tier, attached_by_principal
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING id, tool_id, version, manifest, manifest_hash, wasm, source, tier, status, attached_by_principal, attached_at;

-- name: GetGateScriptByID :one
SELECT id, tool_id, version, manifest, manifest_hash, wasm, source, tier, status, attached_by_principal, attached_at
FROM gate_scripts
WHERE id = $1
LIMIT 1;

-- name: GetActiveGateScript :one
-- The row pointed at by tools.active_script_version. Returns pgx.ErrNoRows
-- when no script is attached (pointer NULL) or the active version was cleared.
SELECT gs.id, gs.tool_id, gs.version, gs.manifest, gs.manifest_hash, gs.wasm, gs.source,
       gs.tier, gs.status, gs.attached_by_principal, gs.attached_at
FROM gate_scripts gs
JOIN tools t ON t.id = gs.tool_id AND t.active_script_version = gs.version
WHERE gs.tool_id = $1
  AND gs.status = 'active'
LIMIT 1;

-- name: ListGateScriptsByTool :many
-- Version history newest-first (Tool.gateScripts). limit/offset clamped by
-- the resolver to a server-side max of 100.
SELECT id, tool_id, version, manifest, manifest_hash, wasm, source, tier, status, attached_by_principal, attached_at
FROM gate_scripts
WHERE tool_id = $1
ORDER BY version DESC
LIMIT $2 OFFSET $3;

-- name: UpdateActiveScriptVersion :one
-- Advance the pointer to the newly-attached version. Owner-only at resolver.
UPDATE tools
SET active_script_version = $2
WHERE id = $1
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score, mcp_server_id, input_schema, mcp_annotations, retired_at;

-- name: ClearActiveScriptVersion :one
-- disableGateScript (FR-024): clear the pointer. Returns the prior value so
-- the resolver can mark the right row disabled and audit prior_active_version.
UPDATE tools
SET active_script_version = NULL
WHERE id = $1
RETURNING id, global_uri, name, rung, permissions, overseer_instructions, active_script_version, trust_score, mcp_server_id, input_schema, mcp_annotations, retired_at;

-- name: DisableGateScriptVersion :exec
-- Mark a specific (tool_id, version) row disabled (the only legal UPDATE per
-- the append-only trigger). Called by disableGateScript after clearing the
-- pointer.
UPDATE gate_scripts
SET status = 'disabled'
WHERE tool_id = $1 AND version = $2;

-- name: GateScriptEvaluatedForDecision :one
-- Resolves ApprovalRequest.gateScriptEvaluation: the gate_script_evaluated row
-- whose payload references this decision id (stamped when a script's
-- RequestDecision raised the approval). pgx.ErrNoRows when floor/overseer-raised.
SELECT id, task_id, from_principal, to_principal, in_reply_to, kind, payload, at
FROM audit_messages
WHERE kind = 'gate_script_evaluated'
  AND payload->>'decision_id' = $1::text
ORDER BY at DESC, id DESC
LIMIT 1;
