package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ownerBearer mints a session for the seeded owner principal.
func ownerBearer(t *testing.T, env *chainEnv) string {
	t.Helper()
	ctx := context.Background()
	owner, err := env.queries.GetViewer(ctx)
	require.NoError(t, err)
	_, raw, err := auth.IssueSession(ctx, env.queries, owner.ID, "phase8-authz")
	require.NoError(t, err)
	return raw
}

// seedPromotionProposal inserts a promotion_proposal pending_decisions row for a
// (tool, routine) with a representative task.
func seedPromotionProposal(t *testing.T, env *chainEnv, toolID, taskID uuid.UUID, fp string) uuid.UUID {
	t.Helper()
	id := uuid.New()
	payload := json.RawMessage(`{"from_level":"execute_gated","to_level":"execute_auto","routine_fingerprint":"` + fp + `","evidence":{"routine":"send-email","window_n":10,"matured_clean":9,"ratio":0.9,"min_sample":5}}`)
	_, err := env.queries.InsertPromotionProposal(context.Background(), db.InsertPromotionProposalParams{
		ID:      id,
		TaskID:  taskID,
		ToolID:  pgtype.UUID{Bytes: toolID, Valid: true},
		Payload: payload,
	})
	require.NoError(t, err)
	return id
}

func respondToPromotionGQL(t *testing.T, env *chainEnv, proposalID uuid.UUID, accept bool) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $a: Boolean!) {
		   respondToPromotion(proposalId: $id, accept: $a) { id globalUri rung }
		 }`,
		"variables": map[string]any{"id": proposalID.String(), "a": accept},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

// TestRespondToPromotion_AgentDenied is the US5/NFR-004 regression: the only
// autonomy-raising path is unreachable by an agent identity — refused before any
// DB write (no grant, score unchanged), while the owner succeeds.
func TestRespondToPromotion_AgentDenied(t *testing.T) {
	env := newChainEnv(t)
	ctx := context.Background()

	toolID := sendEmailToolID(t, env)
	task, err := core.CreateTask(ctx, env.pool, nil, "promo repr", "")
	require.NoError(t, err)
	const fp = "routine-abc"
	proposalID := seedPromotionProposal(t, env, toolID, task.ID, fp)

	scoreBefore, err := env.queries.GetTrustScore(ctx, toolID)
	require.NoError(t, err)

	// --- Agent (bot) is refused. ---
	botBearer, _ := issueBotBearer(t, env)
	prev := testBearer
	testBearer = botBearer
	resp := respondToPromotionGQL(t, env, proposalID, true)
	require.NotEmpty(t, resp.Errors, "an agent must NOT raise autonomy")
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	// No grant written, score unchanged, proposal still open.
	live, err := env.queries.LiveGrantExists(ctx, db.LiveGrantExistsParams{ToolID: toolID, RoutineFingerprint: fp})
	require.NoError(t, err)
	require.False(t, live, "no grant may exist after a denied attempt")
	scoreAfterBot, err := env.queries.GetTrustScore(ctx, toolID)
	require.NoError(t, err)
	require.Equal(t, scoreBefore, scoreAfterBot, "trust score must be unchanged")
	row, err := env.queries.GetPendingDecisionByID(ctx, proposalID)
	require.NoError(t, err)
	require.False(t, row.ResolvedAt.Valid, "proposal must remain open")

	// --- Owner succeeds. ---
	testBearer = ownerBearer(t, env)
	t.Cleanup(func() { testBearer = prev })
	okResp := respondToPromotionGQL(t, env, proposalID, true)
	require.Empty(t, okResp.Errors, "owner must succeed: %v", okResp.Errors)
	var data struct {
		RespondToPromotion struct {
			Rung string `json:"rung"`
		} `json:"respondToPromotion"`
	}
	require.NoError(t, json.Unmarshal(okResp.Data, &data))
	require.Equal(t, "EXECUTE_AUTO", data.RespondToPromotion.Rung)

	live, err = env.queries.LiveGrantExists(ctx, db.LiveGrantExistsParams{ToolID: toolID, RoutineFingerprint: fp})
	require.NoError(t, err)
	require.True(t, live, "owner accept must create a live grant")
	scoreAfterOwner, err := env.queries.GetTrustScore(ctx, toolID)
	require.NoError(t, err)
	require.GreaterOrEqual(t, scoreAfterOwner, calibration.AutoThreshold, "score must jump into the auto band")
}
