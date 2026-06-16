package graph

import (
	"context"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// McpDeps is the owner-mutation wiring for the MCP-client resolvers. main
// supplies the func values (seal auth, sync/discover, disable, invalidate the
// cached client) so the graph package imports neither internal/mcp nor
// internal/crypto. Mirrors ConnectorDeps.
type McpDeps struct {
	// SealAuth seals + stores the server's auth ({header, value}). A nil/empty
	// auth clears any stored credential.
	SealAuth func(ctx context.Context, serverID uuid.UUID, auth map[string]any) error
	// Sync discovers the server's tools and reconciles the catalog + registry,
	// returning the count of live tools discovered.
	Sync func(ctx context.Context, serverID uuid.UUID) (int, error)
	// Disable retires the server's tools + deregisters their adapters + drops the
	// cached client (on disable / remove).
	Disable func(ctx context.Context, serverID uuid.UUID) error
	// InvalidateClient drops the cached client so the next call rebuilds it with
	// fresh endpoint + auth (on reconfigure). Does NOT retire tools.
	InvalidateClient func(serverID uuid.UUID)
}

func (d McpDeps) configured() bool {
	return d.SealAuth != nil && d.Sync != nil && d.Disable != nil && d.InvalidateClient != nil
}

// mapMcpServer projects an mcp_servers row + live tool count into the GraphQL
// model. Credentials never appear.
func mapMcpServer(row *db.McpServer, toolCount int) *model.McpServer {
	m := &model.McpServer{
		ID:          row.ID.String(),
		Slug:        row.Slug,
		Name:        row.Name,
		EndpointURL: row.EndpointUrl,
		Enabled:     row.Enabled,
		Status:      row.Status,
		ToolCount:   toolCount,
	}
	if row.ProtocolVersion != nil {
		m.ProtocolVersion = row.ProtocolVersion
	}
	if row.LastSyncedAt.Valid {
		t := row.LastSyncedAt.Time
		m.LastSyncedAt = &t
	}
	return m
}

// liveToolCount returns the number of non-retired tools for a server.
func (r *Resolver) liveToolCount(ctx context.Context, serverID uuid.UUID) int {
	rows, err := r.Queries.ListMcpToolsByServer(ctx, pgtype.UUID{Bytes: serverID, Valid: true})
	if err != nil {
		return 0
	}
	return len(rows)
}

func (r *queryResolver) mcpServersImpl(ctx context.Context) ([]*model.McpServer, error) {
	rows, err := r.Queries.ListMcpServers(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]*model.McpServer, 0, len(rows))
	for i := range rows {
		out = append(out, mapMcpServer(&rows[i], r.liveToolCount(ctx, rows[i].ID)))
	}
	return out, nil
}

func (r *mutationResolver) registerMcpServerImpl(ctx context.Context, slug, name, endpointURL string, auth map[string]any) (*model.McpServer, error) {
	slug = strings.TrimSpace(slug)
	if slug == "" {
		return nil, gqlerror.Errorf("slug is required")
	}
	if strings.ContainsAny(slug, "/ \t") {
		return nil, gqlerror.Errorf("slug must not contain slashes or whitespace")
	}
	if strings.TrimSpace(endpointURL) == "" {
		return nil, gqlerror.Errorf("endpointUrl is required")
	}
	row, err := r.Queries.InsertMcpServer(ctx, db.InsertMcpServerParams{
		Slug:        slug,
		Name:        name,
		EndpointUrl: endpointURL,
	})
	if err != nil {
		return nil, gqlerror.Errorf("register mcp server: %s", err)
	}
	if auth != nil {
		if err := r.Mcp.SealAuth(ctx, row.ID, auth); err != nil {
			return nil, gqlerror.Errorf("seal auth: %s", err)
		}
	}
	return mapMcpServer(&row, 0), nil
}

func (r *mutationResolver) setMcpServerConfigImpl(ctx context.Context, serverID uuid.UUID, name, endpointURL *string, auth map[string]any) (*model.McpServer, error) {
	cur, err := r.Queries.GetMcpServer(ctx, serverID)
	if err != nil {
		return nil, gqlerror.Errorf("mcp server not found: %s", err)
	}
	newName := cur.Name
	if name != nil {
		newName = *name
	}
	newEndpoint := cur.EndpointUrl
	if endpointURL != nil {
		if strings.TrimSpace(*endpointURL) == "" {
			return nil, gqlerror.Errorf("endpointUrl must not be empty")
		}
		newEndpoint = *endpointURL
	}
	row, err := r.Queries.UpdateMcpServerConfig(ctx, db.UpdateMcpServerConfigParams{
		ID:          serverID,
		Name:        newName,
		EndpointUrl: newEndpoint,
	})
	if err != nil {
		return nil, err
	}
	if auth != nil {
		if err := r.Mcp.SealAuth(ctx, serverID, auth); err != nil {
			return nil, gqlerror.Errorf("seal auth: %s", err)
		}
	}
	// Endpoint / auth may have changed — drop the cached client so the next call
	// rebuilds it. Tools are untouched (the owner re-syncs to pick up changes).
	r.Mcp.InvalidateClient(serverID)
	return mapMcpServer(&row, r.liveToolCount(ctx, serverID)), nil
}

func (r *mutationResolver) enableMcpServerImpl(ctx context.Context, serverID uuid.UUID, enabled bool) (*model.McpServer, error) {
	row, err := r.Queries.SetMcpServerEnabled(ctx, db.SetMcpServerEnabledParams{ID: serverID, Enabled: enabled})
	if err != nil {
		return nil, err
	}
	if enabled {
		if _, err := r.Mcp.Sync(ctx, serverID); err != nil {
			return nil, gqlerror.Errorf("sync mcp server: %s", err)
		}
	} else {
		if err := r.Mcp.Disable(ctx, serverID); err != nil {
			return nil, gqlerror.Errorf("disable mcp server: %s", err)
		}
	}
	// Reload to reflect the sync result (status / last_synced_at) the Sync wrote.
	fresh, ferr := r.Queries.GetMcpServer(ctx, serverID)
	if ferr != nil {
		return mapMcpServer(&row, r.liveToolCount(ctx, serverID)), nil
	}
	return mapMcpServer(&fresh, r.liveToolCount(ctx, serverID)), nil
}

func (r *mutationResolver) syncMcpServerImpl(ctx context.Context, serverID uuid.UUID) (*model.McpServer, error) {
	cur, err := r.Queries.GetMcpServer(ctx, serverID)
	if err != nil {
		return nil, gqlerror.Errorf("mcp server not found: %s", err)
	}
	if !cur.Enabled {
		return nil, gqlerror.Errorf("enable the server before syncing")
	}
	if _, err := r.Mcp.Sync(ctx, serverID); err != nil {
		return nil, gqlerror.Errorf("sync mcp server: %s", err)
	}
	fresh, ferr := r.Queries.GetMcpServer(ctx, serverID)
	if ferr != nil {
		return mapMcpServer(&cur, r.liveToolCount(ctx, serverID)), nil
	}
	return mapMcpServer(&fresh, r.liveToolCount(ctx, serverID)), nil
}

func (r *mutationResolver) removeMcpServerImpl(ctx context.Context, serverID uuid.UUID) (bool, error) {
	if _, err := r.Queries.GetMcpServer(ctx, serverID); err != nil {
		return false, gqlerror.Errorf("mcp server not found: %s", err)
	}
	// Retire tools + deregister adapters + drop the cached client first; the tool
	// rows survive (mcp_server_id ON DELETE SET NULL) for audit history.
	if err := r.Mcp.Disable(ctx, serverID); err != nil {
		return false, gqlerror.Errorf("disable mcp server: %s", err)
	}
	if err := r.Queries.DeleteMcpServer(ctx, serverID); err != nil {
		return false, gqlerror.Errorf("delete mcp server: %s", err)
	}
	return true, nil
}
