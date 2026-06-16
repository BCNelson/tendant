-- +goose Up

-- MCP client edge: register external remote MCP servers (Streamable HTTP) and
-- expose each discovered upstream tool as a first-class, gated tendant tool.
--
-- Two new tables + four additive nullable columns on `tools`. No new audit
-- kinds this version (register/enable/sync are owner-config operations, like the
-- Phase-7 connector mutations, which audit nothing), so the
-- audit_messages.task_id-NULL CHECK allowlist (migration 00006) is unchanged.

-- A registered MCP server. `slug` is the owner-chosen stable handle used to
-- namespace tool global_uris (tendant://mcp/<slug>/<tool>); it is NOT derived
-- from the untrusted upstream server name. Credentials live sealed in the
-- sibling table and never cross the read surface. `status` records the last
-- sync result (e.g. ok | error) for the owner UI.
CREATE TABLE mcp_servers (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug             text NOT NULL UNIQUE,
  name             text NOT NULL DEFAULT '',
  endpoint_url     text NOT NULL,
  enabled          boolean NOT NULL DEFAULT false,
  protocol_version text,
  status           text NOT NULL DEFAULT 'unsynced',
  last_synced_at   timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- Sealed auth for a server (AES-256-GCM, TENDANT_CREDENTIALS_KEY) — mirrors
-- source_credentials. `encrypted` is the sealed mcp.Auth JSON; `expires_at`
-- reserved for the OAuth-refresh follow-up.
CREATE TABLE mcp_server_credentials (
  mcp_server_id uuid PRIMARY KEY REFERENCES mcp_servers(id) ON DELETE CASCADE,
  encrypted     bytea NOT NULL,
  expires_at    timestamptz
);

-- A tool may originate from an MCP server. mcp_server_id is ON DELETE SET NULL:
-- removing a server nulls the link on its tool rows but preserves the rows (and
-- their tool_outcomes / audit / calibration history) — the remove flow retires
-- them (retired_at) and deregisters their adapters first, so the history
-- survives a server deletion as orphaned, retired rows. input_schema is the
-- upstream JSON Schema (stored verbatim; the gate is policy, not schema
-- parsing). mcp_annotations holds the upstream tool annotations, surfaced to the
-- owner as permission *suggestions* only — never auto-applied. retired_at marks
-- a tool whose upstream definition has vanished (or whose server was removed);
-- the row is kept for audit history and its adapter is deregistered.
ALTER TABLE tools
  ADD COLUMN mcp_server_id   uuid REFERENCES mcp_servers(id) ON DELETE SET NULL,
  ADD COLUMN input_schema    jsonb,
  ADD COLUMN mcp_annotations jsonb,
  ADD COLUMN retired_at      timestamptz;

CREATE INDEX idx_tools_mcp_server ON tools(mcp_server_id) WHERE mcp_server_id IS NOT NULL;

-- +goose Down

ALTER TABLE tools
  DROP COLUMN IF EXISTS retired_at,
  DROP COLUMN IF EXISTS mcp_annotations,
  DROP COLUMN IF EXISTS input_schema,
  DROP COLUMN IF EXISTS mcp_server_id;

DROP TABLE IF EXISTS mcp_server_credentials;
DROP TABLE IF EXISTS mcp_servers;
