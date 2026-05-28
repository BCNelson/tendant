package graph_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// setupGQLForRevoke arms two sessions for the same owner. Distinct from
// setupGQL because the setup secret only allows one pairing per boot — we
// IssueSession directly for the second.
func setupGQLForRevoke(t *testing.T) (handler http.Handler, sessionA, tokenA, sessionB, tokenB string) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	a, rawA, err := auth.IssueSession(ctx, q, owner.ID, "A")
	require.NoError(t, err)
	b, rawB, err := auth.IssueSession(ctx, q, owner.ID, "B")
	require.NoError(t, err)

	h := server.New(pool, nil, server.Options{})
	return h, a.ID.String(), rawA, b.ID.String(), rawB
}

func TestRevokeSessionInvalidatesBearer(t *testing.T) {
	t.Parallel()
	h, _, tokenA, sessionB, tokenB := setupGQLForRevoke(t)

	// Session A revokes session B.
	body := `{"query":"mutation { revokeSession(sessionId:\"` + sessionB + `\") { id } }"}`
	resp := postGQL(t, h, body, tokenA)
	require.Empty(t, resp.Errors, "expected no errors; got %+v", resp.Errors)

	// Session B can no longer authenticate.
	viewerBody := `{"query":"{ viewer { id } }"}`
	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(viewerBody))
	r.Header.Set("Content-Type", "application/json")
	r.Header.Set("Authorization", "Bearer "+tokenB)
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusOK, w.Code)
	var out gqlResp
	require.NoError(t, json.Unmarshal(w.Body.Bytes(), &out))

	// viewer is non-required; the resolver returns nil when no principal.
	// So `data.viewer` should be null after revocation (bearer middleware
	// quietly drops the principal).
	require.True(t, strings.Contains(string(out.Data), `"viewer":null`),
		"expected viewer to be null post-revoke; got %s", string(out.Data))
}

// Session listing should reflect post-revoke state.
func TestRevokeSessionUpdatesListing(t *testing.T) {
	t.Parallel()
	h, _, tokenA, sessionB, _ := setupGQLForRevoke(t)
	body := `{"query":"mutation { revokeSession(sessionId:\"` + sessionB + `\") { id } }"}`
	resp := postGQL(t, h, body, tokenA)
	require.Empty(t, resp.Errors)

	listBody := `{"query":"{ sessions { id displayName } }"}`
	list := postGQL(t, h, listBody, tokenA)
	require.Empty(t, list.Errors)
	// Only session A should remain active.
	require.True(t, strings.Contains(string(list.Data), `"displayName":"A"`))
	require.False(t, strings.Contains(string(list.Data), sessionB),
		"session B id should not appear in active list")
}
