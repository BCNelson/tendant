package router

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupRouterDB(t *testing.T) (*db.Queries, context.Context) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	return db.New(pool), ctx
}

func insertExecAgent(t *testing.T, ctx context.Context, q *db.Queries, name string) {
	t.Helper()
	prompt := name + " prompt"
	_, err := q.InsertAgentConfig(ctx, db.InsertAgentConfigParams{
		Name:          name,
		Stage:         db.AgentStageExecution,
		IsHuman:       false,
		SystemPrompt:  &prompt,
		ToolAllowlist: json.RawMessage(`[]`),
		Eligibility:   json.RawMessage(`{}`), // always eligible
		Origin:        db.ConfigOriginCore,
		Version:       1,
	})
	require.NoError(t, err)
}

// TestSelect_CategoryRoutesToBoundAgent is the routing e2e: a category whose
// execution binding names email-specialist narrows the candidate set to that
// agent even though code-executor is also a generally-eligible execution agent,
// and an uncategorized task still routes via plain eligibility (regression).
func TestSelect_CategoryRoutesToBoundAgent(t *testing.T) {
	q, ctx := setupRouterDB(t)
	insertExecAgent(t, ctx, q, "email-specialist")
	insertExecAgent(t, ctx, q, "code-executor")

	// communication/email binds execution to [email-specialist] gated on stakes<=6.
	_, err := q.InsertTaskCategory(ctx, db.InsertTaskCategoryParams{
		Key:           "communication/email",
		ParentID:      pgtype.UUID{},
		Label:         "Email",
		StageBindings: json.RawMessage(`{"execution":{"agents":["email-specialist"],"eligibility":{"pred":{"op":"lte","field":"stakes_score","value":6}}}}`),
		Origin:        db.ConfigOriginCore,
		Version:       1,
	})
	require.NoError(t, err)

	// The picker would prefer code-executor if it were a candidate — proving the
	// category binding, not the picker, is what narrows the set.
	r := New(q, &LogPicker{PickByName: "code-executor"})

	findingsJSON := func(f agent.StructuredFindings) json.RawMessage {
		b, _ := json.Marshal(agent.Findings{Structured: f})
		return b
	}

	t.Run("category binding narrows to email-specialist", func(t *testing.T) {
		dec, err := r.Select(ctx, db.AgentStageExecution, findingsJSON(agent.StructuredFindings{
			Category:    "communication/email",
			StakesScore: 3,
		}))
		require.NoError(t, err)
		require.False(t, dec.IsHuman)
		require.Equal(t, "email-specialist", dec.ConfigName)
	})

	t.Run("binding expression empties set → fallback to eligibility", func(t *testing.T) {
		// stakes 9 > 6 empties the bound candidate set; both agents are then
		// generally eligible and the picker takes code-executor.
		dec, err := r.Select(ctx, db.AgentStageExecution, findingsJSON(agent.StructuredFindings{
			Category:    "communication/email",
			StakesScore: 9,
		}))
		require.NoError(t, err)
		require.False(t, dec.IsHuman)
		require.Equal(t, "code-executor", dec.ConfigName)
	})

	t.Run("uncategorized task routes via eligibility", func(t *testing.T) {
		dec, err := r.Select(ctx, db.AgentStageExecution, findingsJSON(agent.StructuredFindings{}))
		require.NoError(t, err)
		require.False(t, dec.IsHuman)
		require.Equal(t, "code-executor", dec.ConfigName)
	})
}
