package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// seedAutoAcceptedIntakeTask inserts a connector, a rich_event signal, and an
// accepted intake-origin task referencing it — the shape the disposition router
// produces for an auto-accepted rich_event.
func seedAutoAcceptedIntakeTask(t *testing.T, env *chainEnv) uuid.UUID {
	t.Helper()
	ctx := context.Background()
	connectorID := uuid.New()
	_, err := env.pool.Exec(ctx, `
		INSERT INTO connector_configs (id, connector_type, filter, disposition_rules, enabled)
		VALUES ($1, 'rss', '{}', '{}', true)`, connectorID)
	require.NoError(t, err)

	var signalID uuid.UUID
	require.NoError(t, env.pool.QueryRow(ctx, `
		INSERT INTO intake_signals
		  (signal_version, connector_id, idempotency_key, provenance, payload, disposition, confidence, stakes_hint)
		VALUES ('intake.v1', $1, $2, $3, $4, 'rich_event', 0.92, 0.10)
		RETURNING id`,
		connectorID, "k-"+uuid.NewString(),
		json.RawMessage(`{"raw_ref":"rss:feed#1","reason":"matched"}`),
		json.RawMessage(`{"title":"Release notes"}`),
	).Scan(&signalID))

	created, err := core.CreateTaskFromSignal(ctx, env.pool, nil, signalID, "Release notes",
		json.RawMessage(`{"raw_ref":"rss:feed#1","reason":"matched"}`), lifecycle.StateAccepted)
	require.NoError(t, err)
	return created.ID
}

// T034/T038 — an auto-accepted intake task reports autonomy ENRICH_ONLY.
func TestIntakeTask_AutonomyEnrichOnly(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := seedAutoAcceptedIntakeTask(t, env)

	resp := graphqlRequest(t, env.handler,
		`query($id: ID!) { task(id: $id) { state autonomy provenance } }`,
		map[string]any{"id": taskID.String()})
	var out struct {
		Task struct {
			State      string         `json:"state"`
			Autonomy   string         `json:"autonomy"`
			Provenance map[string]any `json:"provenance"`
		} `json:"task"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &out))
	require.Equal(t, "ACCEPTED", out.Task.State)
	require.Equal(t, "ENRICH_ONLY", out.Task.Autonomy)
	require.Equal(t, "rss:feed#1", out.Task.Provenance["raw_ref"])
}

// T032/T035/T038 — an auto-accepted intake task is dismissible (the relaxed
// accepted→dismissed edge), and the reason is recorded.
func TestIntakeTask_Dismissible(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	taskID := seedAutoAcceptedIntakeTask(t, env)

	resp := graphqlRequest(t, env.handler,
		`mutation($id: ID!, $r: String) { dismissProposedTask(taskId: $id, reason: $r) { id state } }`,
		map[string]any{"id": taskID.String(), "r": "not relevant"})
	var out struct {
		DismissProposedTask struct {
			State string `json:"state"`
		} `json:"dismissProposedTask"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &out))
	require.Equal(t, "DISMISSED", out.DismissProposedTask.State)

	// The dismissal reason is recorded on the state_transition audit.
	var reason string
	require.NoError(t, env.pool.QueryRow(context.Background(), `
		SELECT payload->>'reason' FROM audit_messages
		WHERE task_id=$1 AND kind='state_transition' AND payload->>'to'='dismissed'
		ORDER BY at DESC LIMIT 1`, taskID).Scan(&reason))
	require.Equal(t, "not relevant", reason)
}

// An owner-authored (non-intake) accepted task is NOT dismissible — the relaxed
// edge is intake-origin only.
func TestOwnerTask_AcceptedNotDismissible(t *testing.T) {
	env := newChainEnv(t)
	bearer := issueOwnerBearer(t, env)
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })

	ctx := context.Background()
	created, err := core.CreateTask(ctx, env.pool, nil, "owner task", "")
	require.NoError(t, err)

	errs := graphqlRequestExpectError(t, env.handler,
		`mutation($id: ID!) { dismissProposedTask(taskId: $id, reason: "x") { id } }`,
		map[string]any{"id": created.ID.String()})
	require.NotEmpty(t, errs, "owner-authored accepted task must not be dismissible")
}
