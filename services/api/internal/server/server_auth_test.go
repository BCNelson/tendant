package server_test

import (
	"context"
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

// TestHealthz checks /healthz works without an Authorization bearer.
func TestHealthz(t *testing.T) {
	t.Parallel()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(context.Background(), dsn))
	h := server.New(pool, nil, server.Options{})

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusOK, w.Code)
}

// TestGraphQLAnonymousIntrospection: an introspection query lands without a
// bearer (no principal in ctx), without 401 — the design requires that
// playground / introspection works anonymously and resolvers gate via Can.
func TestGraphQLAnonymousIntrospection(t *testing.T) {
	t.Parallel()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(context.Background(), dsn))
	require.NoError(t, core.SeedOwner(context.Background(), db.New(pool)))
	h := server.New(pool, nil, server.Options{})

	body := `{"query":"{ __schema { queryType { name } } }"}`
	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(body))
	r.Header.Set("Content-Type", "application/json")
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusOK, w.Code)
	require.Contains(t, w.Body.String(), `"queryType"`)
}

// TestGraphQLBearerSetsPrincipal verifies the chi middleware attaches the
// resolved Principal to ctx — the `viewer` query reaches the seeded owner.
func TestGraphQLBearerSetsPrincipal(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)

	_, raw, err := auth.IssueSession(ctx, q, owner.ID, "test")
	require.NoError(t, err)

	h := server.New(pool, nil, server.Options{})
	body := `{"query":"{ viewer { id displayName } }"}`
	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(body))
	r.Header.Set("Content-Type", "application/json")
	r.Header.Set("Authorization", "Bearer "+raw)
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusOK, w.Code)
	require.Contains(t, w.Body.String(), owner.DisplayName)
}
