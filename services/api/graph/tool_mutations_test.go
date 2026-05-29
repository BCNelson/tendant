package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// issueBotBearer mints a session for a freshly-inserted bot principal.
func issueBotBearer(t *testing.T, env *chainEnv) (string, db.Principal) {
	t.Helper()
	ctx := context.Background()
	// Insert a bot principal directly. The unique global_uri lets us run
	// in parallel without colliding.
	botURI := "local://principal/bot-" + uuid.New().String()
	var bot db.Principal
	err := env.pool.QueryRow(ctx, `
		INSERT INTO principals (id, global_uri, kind, display_name)
		VALUES (gen_random_uuid(), $1, 'bot', 'tool-mut-test-bot')
		RETURNING id, global_uri, kind, display_name, created_at
	`, botURI).Scan(&bot.ID, &bot.GlobalUri, &bot.Kind, &bot.DisplayName, &bot.CreatedAt)
	require.NoError(t, err)

	_, raw, err := auth.IssueSession(ctx, env.queries, bot.ID, "phase4-mut-test")
	require.NoError(t, err)
	return raw, bot
}

func sendEmailToolID(t *testing.T, env *chainEnv) uuid.UUID {
	t.Helper()
	row, err := env.queries.GetToolByGlobalURI(context.Background(), "tendant://tools/send-email")
	require.NoError(t, err)
	return row.ID
}

func setToolOverseerInstructionsGQL(t *testing.T, env *chainEnv, toolID uuid.UUID, instructions string) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $i: String!) {
		   setToolOverseerInstructions(toolId: $id, instructions: $i) {
		     id  overseerInstructions
		   }
		 }`,
		"variables": map[string]any{"id": toolID.String(), "i": instructions},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func setToolPermissionsGQL(t *testing.T, env *chainEnv, toolID uuid.UUID, perms map[string]any) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $p: JSON!) {
		   setToolPermissions(toolId: $id, permissions: $p) {
		     id  permissions
		   }
		 }`,
		"variables": map[string]any{"id": toolID.String(), "p": perms},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func errorCode(t *testing.T, errs []json.RawMessage) string {
	t.Helper()
	require.NotEmpty(t, errs)
	var e struct {
		Extensions map[string]any `json:"extensions"`
	}
	require.NoError(t, json.Unmarshal(errs[0], &e))
	code, _ := e.Extensions["code"].(string)
	return code
}

// TestSetToolOverseerInstructions_OwnerHappyPath confirms an owner viewer
// can replace the instructions string and the row reflects the change.
func TestSetToolOverseerInstructions_OwnerHappyPath(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	toolID := sendEmailToolID(t, env)
	newInstr := "Approve only sends to known principals — additional rule from owner."

	resp := setToolOverseerInstructionsGQL(t, env, toolID, newInstr)
	require.Empty(t, resp.Errors, "expected no errors: %s", resp.Errors)

	row, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.NotNil(t, row.OverseerInstructions)
	require.Equal(t, newInstr, *row.OverseerInstructions)
}

// TestSetToolOverseerInstructions_BotDenied is the NFR-003 regression:
// a bot principal must NOT be able to mutate owner-authored trust state.
func TestSetToolOverseerInstructions_BotDenied(t *testing.T) {
	env := newChainEnv(t)
	bearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	toolID := sendEmailToolID(t, env)
	before, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)

	resp := setToolOverseerInstructionsGQL(t, env, toolID, "BOT-WROTE-THIS")
	require.NotEmpty(t, resp.Errors, "bot must NOT be allowed")
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	after, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.Equal(t, ptrToString(before.OverseerInstructions), ptrToString(after.OverseerInstructions),
		"DB must be unchanged after a denied mutation")
}

// TestSetToolOverseerInstructions_UnknownTool checks the typed error code.
func TestSetToolOverseerInstructions_UnknownTool(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	bogusID := uuid.New()
	resp := setToolOverseerInstructionsGQL(t, env, bogusID, "x")
	require.NotEmpty(t, resp.Errors)
	require.Equal(t, "TOOL_UNKNOWN", errorCode(t, resp.Errors))
}

// TestSetToolPermissions_OwnerHappyPath confirms an owner can replace the
// permissions JSON with a valid floor-schema shape.
func TestSetToolPermissions_OwnerHappyPath(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	toolID := sendEmailToolID(t, env)
	perms := map[string]any{
		"read_only":                false,
		"spend":                    true,
		"irreversible_third_party": "always",
		"secret_classes":           []string{},
	}
	resp := setToolPermissionsGQL(t, env, toolID, perms)
	require.Empty(t, resp.Errors, "expected no errors: %s", resp.Errors)

	row, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	var got map[string]any
	require.NoError(t, json.Unmarshal(row.Permissions, &got))
	require.Equal(t, true, got["spend"])
	require.Equal(t, "always", got["irreversible_third_party"])
}

// TestSetToolPermissions_InvalidUnknownKey returns INVALID_PERMISSIONS;
// the row remains unchanged.
func TestSetToolPermissions_InvalidUnknownKey(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	toolID := sendEmailToolID(t, env)
	before, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)

	perms := map[string]any{
		"read_only":  false,
		"new_clause": "future-floor-clause", // unknown top-level key
	}
	resp := setToolPermissionsGQL(t, env, toolID, perms)
	require.NotEmpty(t, resp.Errors)
	require.Equal(t, "INVALID_PERMISSIONS", errorCode(t, resp.Errors))

	after, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.Equal(t, string(before.Permissions), string(after.Permissions))
}

// TestSetToolPermissions_BotDenied mirrors the owner-only enforcement
// for setToolPermissions. The DB must be unchanged.
func TestSetToolPermissions_BotDenied(t *testing.T) {
	env := newChainEnv(t)
	bearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	toolID := sendEmailToolID(t, env)
	before, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)

	perms := map[string]any{
		"read_only":                false,
		"spend":                    true,
		"irreversible_third_party": "always",
		"secret_classes":           []string{},
	}
	resp := setToolPermissionsGQL(t, env, toolID, perms)
	require.NotEmpty(t, resp.Errors)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	after, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.Equal(t, string(before.Permissions), string(after.Permissions),
		"DB must be unchanged after a denied mutation")
}

func ptrToString(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}
