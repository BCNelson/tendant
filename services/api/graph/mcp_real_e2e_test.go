package graph_test

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// TestMCP_RealEverythingServer_E2E runs the FULL client edge against the official
// Model Context Protocol reference server ("everything"), which is purpose-built
// for transport/protocol conformance testing. It boots the server in a
// testcontainer over the real Streamable HTTP transport, registers + enables it
// through tendant's GraphQL surface (discovering its real tools fail-closed),
// then proposes + approves its `echo` tool and asserts a clean dispatch.
//
// It is OPT-IN (skipped unless TENDANT_MCP_REAL_E2E=1) because it pulls a Node
// image and `npx`-installs the server from the npm registry at container start —
// a network dependency the default hermetic suite (which uses an in-process fake
// MCP server, see mcp_e2e_test.go) deliberately avoids. Run it with:
//
//	TENDANT_MCP_REAL_E2E=1 go test ./graph/ -run TestMCP_RealEverythingServer_E2E
func TestMCP_RealEverythingServer_E2E(t *testing.T) {
	if os.Getenv("TENDANT_MCP_REAL_E2E") != "1" {
		t.Skip("opt-in: set TENDANT_MCP_REAL_E2E=1 to run the real reference-server e2e")
	}
	ctx := context.Background()

	// The everything reference server's Streamable HTTP transport listens on
	// PORT (default 3001) at path /mcp. Pin the version for reproducibility.
	const everythingPkg = "@modelcontextprotocol/server-everything@2026.1.26"
	req := testcontainers.ContainerRequest{
		Image:        "node:22-alpine",
		Cmd:          []string{"npx", "-y", everythingPkg, "streamableHttp"},
		Env:          map[string]string{"PORT": "3001"},
		ExposedPorts: []string{"3001/tcp"},
		WaitingFor:   wait.ForListeningPort("3001/tcp").WithStartupTimeout(3 * time.Minute),
	}
	ctr, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	require.NoError(t, err, "start everything MCP server container")
	t.Cleanup(func() { _ = ctr.Terminate(context.Background()) })

	host, err := ctr.Host(ctx)
	require.NoError(t, err)
	port, err := ctr.MappedPort(ctx, "3001/tcp")
	require.NoError(t, err)
	endpoint := fmt.Sprintf("http://%s:%s/mcp", host, port.Port())

	registry := tools.NewRegistry()
	env := newChainEnv(t, withToolRegistry(registry), withMcp(mcpTestDeps))
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	// Register + enable → the first sync discovers the server's real tool catalog.
	serverID := registerMcpServerGQL(t, env, "everything", "Everything Reference", endpoint)
	data := enableMcpServerGQL(t, env, serverID, true)
	require.Contains(t, string(data), `"status":"ok"`)

	// The `echo` tool is discovered, fail-closed.
	echoURI := "tendant://mcp/everything/echo"
	toolRow, err := env.queries.GetToolByGlobalURI(ctx, echoURI)
	require.NoError(t, err, "everything server should advertise an `echo` tool")
	var perms map[string]any
	require.NoError(t, json.Unmarshal(toolRow.Permissions, &perms))
	require.Equal(t, "always", perms["irreversible_third_party"])
	require.True(t, registry.Has(echoURI))

	// Propose → floor gates → approve → real upstream tools/call → clean outcome.
	taskID := createTaskGQL(t, env, "echo via the real reference server")
	walkToExecution(t, env, taskID)
	decisionID := proposeToolCallGQL(t, env, taskID, echoURI, map[string]any{"message": "tendant-says-hi"})

	row, err := env.queries.GetPendingDecisionByID(ctx, decisionID)
	require.NoError(t, err)
	require.Equal(t, db.DecisionKindApprovalRequest, row.Kind)

	approveArtifactGQL(t, env, decisionID)
	pollUntilToolOutcome(t, env, taskID)

	n, err := env.queries.CountToolOutcomesForTask(ctx, taskID)
	require.NoError(t, err)
	require.EqualValues(t, 1, n, "exactly one clean outcome from the real echo dispatch")
}
