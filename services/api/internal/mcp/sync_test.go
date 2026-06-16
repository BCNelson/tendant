package mcp

import (
	"context"
	"encoding/json"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// TestSyncReconcile is the DB-backed reconcile contract: first sync lands tools
// fail-closed; an owner's permission edit survives a re-sync (only upstream
// metadata refreshes); a vanished tool is retired + deregistered.
func TestSyncReconcile(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	q := db.New(pool)

	fake := &fakeMCP{pages: [][]ToolDescriptor{{
		{Name: "echo", Description: "v1", InputSchema: json.RawMessage(`{"type":"object"}`)},
	}}}
	srv := httptest.NewServer(fake)
	t.Cleanup(srv.Close)

	server, err := q.InsertMcpServer(ctx, db.InsertMcpServerParams{
		Slug: "fakemcp", Name: "Fake", EndpointUrl: srv.URL,
	})
	require.NoError(t, err)

	registry := tools.NewRegistry()
	clientPool := NewClientPool(srv.Client(), func(ctx context.Context, _ uuid.UUID) (string, Auth, error) {
		return srv.URL, Auth{}, nil
	})
	svc := NewService(q, registry, clientPool)

	// First sync: tool created fail-closed + adapter registered.
	res, err := svc.Sync(ctx, server.ID)
	require.NoError(t, err)
	require.Equal(t, 1, res.Discovered)

	globalURI := GlobalURI("fakemcp", "echo")
	toolRow, err := q.GetToolByGlobalURI(ctx, globalURI)
	require.NoError(t, err)
	require.True(t, registry.Has(globalURI))
	var perms map[string]any
	require.NoError(t, json.Unmarshal(toolRow.Permissions, &perms))
	require.Equal(t, "always", perms["irreversible_third_party"])

	// Owner tunes the permissions (relaxes the floor for this tool).
	ownerPerms := json.RawMessage(`{"read_only":true,"spend":false,"irreversible_third_party":"never","secret_classes":[]}`)
	_, err = q.UpdateToolPermissions(ctx, db.UpdateToolPermissionsParams{ID: toolRow.ID, Permissions: ownerPerms})
	require.NoError(t, err)

	// Re-sync with refreshed upstream description: permissions are PRESERVED, the
	// upstream metadata (name/schema) refreshes.
	fake.pages = [][]ToolDescriptor{{
		{Name: "echo", Title: "Echo v2", Description: "v2", InputSchema: json.RawMessage(`{"type":"object","x":1}`)},
	}}
	_, err = svc.Sync(ctx, server.ID)
	require.NoError(t, err)

	after, err := q.GetToolByGlobalURI(ctx, globalURI)
	require.NoError(t, err)
	var afterPerms map[string]any
	require.NoError(t, json.Unmarshal(after.Permissions, &afterPerms))
	require.Equal(t, "never", afterPerms["irreversible_third_party"], "owner-tuned permissions must survive a re-sync")
	require.Equal(t, "Echo v2", after.Name, "upstream title should refresh on re-sync")

	// Upstream drops the tool: it is retired + deregistered.
	fake.pages = [][]ToolDescriptor{{}}
	_, err = svc.Sync(ctx, server.ID)
	require.NoError(t, err)
	require.False(t, registry.Has(globalURI), "retired tool's adapter must be deregistered")
	retired, err := q.GetToolByGlobalURI(ctx, globalURI)
	require.NoError(t, err)
	require.True(t, retired.RetiredAt.Valid, "vanished tool must be retired")
}
