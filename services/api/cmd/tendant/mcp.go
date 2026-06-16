package main

import (
	"context"
	"log/slog"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/crypto"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/mcp"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// mcpWiring bundles the MCP-client edge pieces main hands to the GraphQL resolver
// and the boot-time adapter rehydration.
type mcpWiring struct {
	service   *mcp.Service
	pool      *mcp.ClientPool
	credStore *mcp.CredentialStore // nil when TENDANT_CREDENTIALS_KEY is unset
}

// buildMcpWiring constructs the MCP client pool, credential store, and reconcile
// service. The client pool loads each server's endpoint + sealed auth lazily.
// The credential store is nil when no credentials key is configured — servers
// can still be registered/synced unauthenticated, and auth'd servers surface the
// gap rather than crashing boot (mirrors the intake credential store).
func buildMcpWiring(pool *pgxpool.Pool, q *db.Queries, toolRegistry *tools.Registry, cfg *config.Config) mcpWiring {
	var credStore *mcp.CredentialStore
	if sealer, err := crypto.NewFromBase64(cfg.Credentials.Key); err == nil {
		credStore = mcp.NewCredentialStore(q, sealer)
	} else {
		slog.Warn("mcp: credentials.key not set — authenticated MCP servers cannot present credentials", "err", err)
	}

	loader := func(ctx context.Context, serverID uuid.UUID) (string, mcp.Auth, error) {
		server, err := q.GetMcpServer(ctx, serverID)
		if err != nil {
			return "", mcp.Auth{}, err
		}
		var auth mcp.Auth
		if credStore != nil {
			a, oerr := credStore.Open(ctx, serverID)
			if oerr != nil {
				slog.WarnContext(ctx, "mcp: open credential failed; proceeding unauthenticated", "server_id", serverID, "err", oerr)
			} else {
				auth = a
			}
		}
		return server.EndpointUrl, auth, nil
	}

	clientPool := mcp.NewClientPool(nil, loader)
	service := mcp.NewService(q, toolRegistry, clientPool)
	return mcpWiring{service: service, pool: clientPool, credStore: credStore}
}

// mcpResolverDeps wires the GraphQL owner mutations to the MCP service +
// credential store without graph importing internal/mcp or internal/crypto.
func (w mcpWiring) mcpResolverDeps() graph.McpDeps {
	return graph.McpDeps{
		SealAuth: func(ctx context.Context, serverID uuid.UUID, raw map[string]any) error {
			if w.credStore == nil {
				return errCredStoreUnset
			}
			return w.credStore.Upsert(ctx, serverID, authFromMap(raw))
		},
		Sync: func(ctx context.Context, serverID uuid.UUID) (int, error) {
			res, err := w.service.Sync(ctx, serverID)
			return res.Discovered, err
		},
		Disable:          w.service.Forget,
		InvalidateClient: w.pool.Forget,
	}
}

// authFromMap projects the GraphQL JSON {header, value} into an mcp.Auth. Other
// keys are ignored; a missing/blank pair yields a zero Auth (clears credentials).
func authFromMap(raw map[string]any) mcp.Auth {
	if raw == nil {
		return mcp.Auth{}
	}
	header, _ := raw["header"].(string)
	value, _ := raw["value"].(string)
	return mcp.Auth{Header: header, Value: value}
}

// errCredStoreUnset is returned when auth is supplied but no credentials key is
// configured to seal it.
var errCredStoreUnset = credStoreUnsetError{}

type credStoreUnsetError struct{}

func (credStoreUnsetError) Error() string {
	return "credential store not configured (TENDANT_CREDENTIALS_KEY unset)"
}
