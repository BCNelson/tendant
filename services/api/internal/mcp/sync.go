package mcp

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// GlobalURIPrefix namespaces every MCP-backed tool: tendant://mcp/<slug>/<name>.
const GlobalURIPrefix = "tendant://mcp/"

// failClosedPermissions is the conservative default floor config every newly
// discovered MCP tool lands with. irreversible_third_party:"always" trips the
// gate's hard-rule floor on EVERY call, so nothing an MCP server exposes can
// auto-execute before the owner reviews it and tunes the permissions via the
// existing setToolPermissions. This is the security crux (Constitution III/IV):
// the owner, never the untrusted upstream, decides a tool's autonomy.
var failClosedPermissions = mustJSON(map[string]any{
	"read_only":                false,
	"spend":                    false,
	"irreversible_third_party": "always",
	"secret_classes":           []string{},
})

func mustJSON(v any) json.RawMessage {
	b, err := json.Marshal(v)
	if err != nil {
		panic(fmt.Sprintf("mcp: marshal default permissions: %v", err))
	}
	return b
}

// GlobalURI builds the stable tool identity from the server slug + upstream name.
func GlobalURI(slug, toolName string) string {
	return GlobalURIPrefix + slug + "/" + toolName
}

// upstreamName recovers the upstream tool name from a global_uri + slug. Used at
// rehydration (the upstream name is the global_uri's trailing segment after the
// owner-controlled slug, both of which tendant constructs — so this is exact).
func upstreamName(globalURI, slug string) string {
	return strings.TrimPrefix(globalURI, GlobalURIPrefix+slug+"/")
}

// providerLabel is the audit-row Provider value for a server's tools.
func providerLabel(slug string) string { return "mcp:" + slug }

// Service owns discovery + reconciliation: it turns a server's tools/list into
// rows in the `tools` table and adapters in the shared tool registry. It holds
// no DB-write logic beyond the reconcile diff; the gate/workflow/calibration
// machinery consumes the rows it produces unchanged.
type Service struct {
	queries  *db.Queries
	registry *tools.Registry
	pool     *ClientPool
}

// NewService wires the reconciler.
func NewService(q *db.Queries, registry *tools.Registry, pool *ClientPool) *Service {
	return &Service{queries: q, registry: registry, pool: pool}
}

// SyncResult summarizes a sync for the owner-facing audit/log.
type SyncResult struct {
	Discovered      int
	Retired         int
	ProtocolVersion string
}

// Sync discovers the server's tools and reconciles them: upserts each discovered
// tool (fail-closed on first sight, upstream fields refreshed thereafter),
// registers its adapter, and retires+deregisters any previously-live tool the
// server no longer advertises. It records the sync outcome on the server row.
func (s *Service) Sync(ctx context.Context, serverID uuid.UUID) (SyncResult, error) {
	server, err := s.queries.GetMcpServer(ctx, serverID)
	if err != nil {
		return SyncResult{}, fmt.Errorf("load mcp server %s: %w", serverID, err)
	}

	res, syncErr := s.discoverAndReconcile(ctx, server)
	// Always record the attempt (status + negotiated version), even on failure,
	// so the owner UI reflects reality.
	status := "ok"
	var protoVer *string
	if syncErr != nil {
		status = "error"
	} else if res.ProtocolVersion != "" {
		pv := res.ProtocolVersion
		protoVer = &pv
	}
	if _, rerr := s.queries.SetMcpServerSyncResult(ctx, db.SetMcpServerSyncResultParams{
		ID:              serverID,
		Status:          status,
		ProtocolVersion: protoVer,
	}); rerr != nil {
		slog.WarnContext(ctx, "mcp.sync.record_result_failed", "server_id", serverID, "err", rerr)
	}
	return res, syncErr
}

func (s *Service) discoverAndReconcile(ctx context.Context, server db.McpServer) (SyncResult, error) {
	client, err := s.pool.Get(ctx, server.ID)
	if err != nil {
		return SyncResult{}, err
	}
	upstream, err := client.ListTools(ctx)
	if err != nil {
		return SyncResult{}, err
	}

	seen := make(map[string]struct{}, len(upstream))
	for _, td := range upstream {
		if td.Name == "" {
			continue
		}
		globalURI := GlobalURI(server.Slug, td.Name)
		seen[globalURI] = struct{}{}

		if _, err := s.queries.UpsertMcpTool(ctx, db.UpsertMcpToolParams{
			GlobalUri:      globalURI,
			Name:           displayName(td),
			Permissions:    failClosedPermissions,
			McpServerID:    pgUUID(server.ID),
			InputSchema:    rawOrNil(td.InputSchema),
			McpAnnotations: rawOrNil(td.Annotations),
		}); err != nil {
			return SyncResult{}, fmt.Errorf("upsert mcp tool %s: %w", globalURI, err)
		}
		s.registry.Register(NewMCPTool(globalURI, server.ID, td.Name, providerLabel(server.Slug), s.pool))
	}

	// Retire any previously-live tool the server no longer advertises.
	live, err := s.queries.ListMcpToolsByServer(ctx, pgUUID(server.ID))
	if err != nil {
		return SyncResult{}, fmt.Errorf("list live mcp tools: %w", err)
	}
	retired := 0
	for i := range live {
		if _, ok := seen[live[i].GlobalUri]; ok {
			continue
		}
		if err := s.queries.RetireMcpTool(ctx, live[i].ID); err != nil {
			return SyncResult{}, fmt.Errorf("retire mcp tool %s: %w", live[i].GlobalUri, err)
		}
		s.registry.Deregister(live[i].GlobalUri)
		retired++
	}

	return SyncResult{
		Discovered:      len(seen),
		Retired:         retired,
		ProtocolVersion: client.NegotiatedVersion(),
	}, nil
}

// Forget retires every live tool for a server, deregisters their adapters, and
// drops the cached client — the disable / remove path. (Disable keeps the rows
// retired-but-recoverable on re-sync; remove deletes the server row afterward,
// orphaning the retired rows for history.)
func (s *Service) Forget(ctx context.Context, serverID uuid.UUID) error {
	live, err := s.queries.ListMcpToolsByServer(ctx, pgUUID(serverID))
	if err != nil {
		return fmt.Errorf("list live mcp tools: %w", err)
	}
	for i := range live {
		s.registry.Deregister(live[i].GlobalUri)
	}
	if err := s.queries.RetireMcpToolsForServer(ctx, pgUUID(serverID)); err != nil {
		return fmt.Errorf("retire mcp tools for server: %w", err)
	}
	s.pool.Forget(serverID)
	return nil
}

// RehydrateAdapters rebuilds the registry from the `tools` table on boot WITHOUT
// contacting any upstream — a server that is unreachable at boot still has its
// gated tool rows, and dispatch fails gracefully (recorded bad outcome) if the
// server is down when a call is actually made. Idempotent.
func (s *Service) RehydrateAdapters(ctx context.Context) (int, error) {
	rows, err := s.queries.ListActiveMcpTools(ctx)
	if err != nil {
		return 0, fmt.Errorf("list active mcp tools: %w", err)
	}
	for _, row := range rows {
		serverID, ok := fromPgUUID(row.McpServerID)
		if !ok {
			continue
		}
		name := upstreamName(row.GlobalUri, row.Slug)
		s.registry.Register(NewMCPTool(row.GlobalUri, serverID, name, providerLabel(row.Slug), s.pool))
	}
	return len(rows), nil
}

// --- helpers -----------------------------------------------------------------

// displayName prefers the upstream title, falling back to the tool name.
func displayName(td ToolDescriptor) string {
	if td.Title != "" {
		return td.Title
	}
	return td.Name
}

// rawOrNil returns nil for an empty/`null` raw message so the jsonb column stays
// NULL rather than storing the literal "null".
func rawOrNil(r json.RawMessage) []byte {
	if len(r) == 0 || string(r) == "null" {
		return nil
	}
	return r
}

func pgUUID(id uuid.UUID) pgtype.UUID {
	return pgtype.UUID{Bytes: id, Valid: true}
}

func fromPgUUID(v pgtype.UUID) (uuid.UUID, bool) {
	if !v.Valid {
		return uuid.Nil, false
	}
	return v.Bytes, true
}
