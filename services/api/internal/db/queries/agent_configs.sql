-- name: ListAgentConfigsByStage :many
SELECT id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version
FROM agent_configs
WHERE stage = @stage
ORDER BY name;

-- name: GetAgentConfigByID :one
SELECT id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version
FROM agent_configs
WHERE id = @id;

-- name: ListAllAgentConfigs :many
SELECT id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version
FROM agent_configs
ORDER BY stage, name;

-- name: GetAgentConfigByNameAndStage :one
SELECT id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version
FROM agent_configs
WHERE name = @name AND stage = @stage;

-- name: InsertAgentConfig :one
INSERT INTO agent_configs (name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version)
VALUES (@name, @stage, @is_human, @system_prompt, @model, @tool_allowlist, @eligibility, @origin, @version)
RETURNING id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version;

-- name: UpdateAgentConfigByNameAndStage :one
-- Used by the file-driven catalog reconciler to apply an override to an existing
-- (name, stage) row. Bumps version so the change is observable.
UPDATE agent_configs
SET is_human       = @is_human,
    system_prompt  = @system_prompt,
    model          = @model,
    tool_allowlist = @tool_allowlist,
    eligibility    = @eligibility,
    version        = version + 1
WHERE name = @name AND stage = @stage
RETURNING id, name, stage, is_human, system_prompt, model, tool_allowlist, eligibility, origin, version;
