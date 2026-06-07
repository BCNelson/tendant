package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// setConnectorConfigGQL runs the setConnectorConfig mutation.
func setConnectorConfigGQL(t *testing.T, env *chainEnv, id uuid.UUID, config map[string]any) ([]json.RawMessage, json.RawMessage) {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $c: JSON!) {
		   setConnectorConfig(connectorId: $id, config: $c) { id connectorType enabled config }
		 }`,
		"variables": map[string]any{"id": id.String(), "c": config},
	})
	require.NoError(t, err)
	resp := postGraphQL(t, env.handler, body)
	return resp.Errors, resp.Data
}

// enableConnectorGQL runs the enableConnector mutation.
func enableConnectorGQL(t *testing.T, env *chainEnv, id uuid.UUID, enabled bool) ([]json.RawMessage, json.RawMessage) {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $e: Boolean!) {
		   enableConnector(connectorId: $id, enabled: $e) { id enabled }
		 }`,
		"variables": map[string]any{"id": id.String(), "e": enabled},
	})
	require.NoError(t, err)
	resp := postGraphQL(t, env.handler, body)
	return resp.Errors, resp.Data
}

func connectorsQueryGQL(t *testing.T, env *chainEnv) ([]json.RawMessage, json.RawMessage) {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `query { connectors { id connectorType enabled } }`,
	})
	require.NoError(t, err)
	resp := postGraphQL(t, env.handler, body)
	return resp.Errors, resp.Data
}

// T056 — non-owner is refused all three operations with PERMISSION_DENIED.
func TestConnectors_OwnerGuard(t *testing.T) {
	env := newChainEnv(t)
	bearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	id := uuid.New()

	errs, _ := connectorsQueryGQL(t, env)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, errs))

	errs, _ = setConnectorConfigGQL(t, env, id, map[string]any{"connector_type": "rss"})
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, errs))

	errs, _ = enableConnectorGQL(t, env, id, true)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, errs))

	// No connector row was created (rejected before any DB write).
	var n int
	require.NoError(t, env.pool.QueryRow(context.Background(),
		`SELECT count(*) FROM connector_configs WHERE id=$1`, id).Scan(&n))
	require.Equal(t, 0, n)
}

// T058 — setConnectorConfig: unknown type rejected; valid type persists.
func TestSetConnectorConfig_TypeValidation(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	id := uuid.New()

	// Unknown connector_type rejected.
	errs, _ := setConnectorConfigGQL(t, env, id, map[string]any{"connector_type": "nope"})
	require.Equal(t, "CONNECTOR_TYPE_UNKNOWN", errorCode(t, errs))

	// Valid type persists.
	errs, data := setConnectorConfigGQL(t, env, id, map[string]any{
		"connector_type": "rss",
		"schedule":       "0 */5 * * * *",
		"filter":         map[string]any{"feed": "https://example.com/f.xml"},
	})
	require.Empty(t, errs)
	var out struct {
		SetConnectorConfig struct {
			ConnectorType string `json:"connectorType"`
			Enabled       bool   `json:"enabled"`
		} `json:"setConnectorConfig"`
	}
	require.NoError(t, json.Unmarshal(data, &out))
	require.Equal(t, "rss", out.SetConnectorConfig.ConnectorType)
	require.False(t, out.SetConnectorConfig.Enabled, "config upsert leaves connector disabled")
}

// T057 — enableConnector requires a valid cron; (true)/(false) toggle works.
func TestEnableConnector_ScheduleLifecycle(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	// Config WITHOUT a schedule — enabling must be rejected.
	idNoSched := uuid.New()
	errs, _ := setConnectorConfigGQL(t, env, idNoSched, map[string]any{"connector_type": "webhook-in"})
	require.Empty(t, errs)
	errs, _ = enableConnectorGQL(t, env, idNoSched, true)
	require.NotEmpty(t, errs, "enabling without a schedule must be rejected")

	// Config WITH a malformed (non-blank) cron — enabling must be rejected by
	// the DBOS cron validator, before the enabled flag flips.
	idBadCron := uuid.New()
	errs, _ = setConnectorConfigGQL(t, env, idBadCron, map[string]any{
		"connector_type": "webhook-in",
		"schedule":       "not-a-cron-expression",
	})
	require.Empty(t, errs)
	errs, _ = enableConnectorGQL(t, env, idBadCron, true)
	require.NotEmpty(t, errs, "enabling with an invalid cron must be rejected")
	badRow, err := env.queries.GetConnectorConfig(context.Background(), idBadCron)
	require.NoError(t, err)
	require.False(t, badRow.Enabled, "invalid cron must not flip the enabled flag")

	// Config WITH a valid cron — enable then disable.
	id := uuid.New()
	errs, _ = setConnectorConfigGQL(t, env, id, map[string]any{
		"connector_type": "webhook-in",
		"schedule":       "0 * * * * *",
	})
	require.Empty(t, errs)

	errs, data := enableConnectorGQL(t, env, id, true)
	require.Empty(t, errs)
	require.Contains(t, string(data), `"enabled":true`)

	// Row reflects enabled=true.
	row, err := env.queries.GetConnectorConfig(context.Background(), id)
	require.NoError(t, err)
	require.True(t, row.Enabled)

	errs, data = enableConnectorGQL(t, env, id, false)
	require.Empty(t, errs)
	require.Contains(t, string(data), `"enabled":false`)
	row, err = env.queries.GetConnectorConfig(context.Background(), id)
	require.NoError(t, err)
	require.False(t, row.Enabled)
}
