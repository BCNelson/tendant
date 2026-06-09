package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/stretchr/testify/require"
)

func setTaskCategoryGQL(t *testing.T, env *chainEnv, key, label string) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($input: SetTaskCategoryInput!) {
		   setTaskCategory(input: $input) { key label }
		 }`,
		"variables": map[string]any{"input": map[string]any{"key": key, "label": label}},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

// TestSetTaskCategory_AgentDenied is the owner-only authz regression: a category
// edit is refused for an agent identity before any DB write (no row created),
// while the owner succeeds.
func TestSetTaskCategory_AgentDenied(t *testing.T) {
	env := newChainEnv(t)
	ctx := context.Background()
	const key = "authz-email"

	// --- Agent (bot) is refused. ---
	botBearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = botBearer
	resp := setTaskCategoryGQL(t, env, key, "Email")
	require.NotEmpty(t, resp.Errors, "an agent must NOT edit categories")
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	// No row written by the denied attempt.
	_, err := env.queries.GetTaskCategoryByKey(ctx, key)
	require.ErrorIs(t, err, pgx.ErrNoRows, "no category may exist after a denied attempt")

	// --- Owner succeeds. ---
	testBearer = ownerBearer(t, env)
	t.Cleanup(func() { testBearer = prev })
	okResp := setTaskCategoryGQL(t, env, key, "Email")
	require.Empty(t, okResp.Errors, "owner must succeed: %v", okResp.Errors)
	var data struct {
		SetTaskCategory struct {
			Key   string `json:"key"`
			Label string `json:"label"`
		} `json:"setTaskCategory"`
	}
	require.NoError(t, json.Unmarshal(okResp.Data, &data))
	require.Equal(t, key, data.SetTaskCategory.Key)

	row, err := env.queries.GetTaskCategoryByKey(ctx, key)
	require.NoError(t, err)
	require.Equal(t, "Email", row.Label)
}
