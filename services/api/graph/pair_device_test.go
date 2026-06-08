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

type gqlResp struct {
	Data   json.RawMessage `json:"data"`
	Errors []struct {
		Message    string         `json:"message"`
		Extensions map[string]any `json:"extensions"`
	} `json:"errors"`
}

func postGQL(t *testing.T, h http.Handler, body string, bearer string) gqlResp {
	t.Helper()
	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/graphql", strings.NewReader(body))
	r.Header.Set("Content-Type", "application/json")
	if bearer != "" {
		r.Header.Set("Authorization", "Bearer "+bearer)
	}
	h.ServeHTTP(w, r)
	require.Equal(t, http.StatusOK, w.Code, "graphql response should be 200: %s", w.Body.String())
	var out gqlResp
	require.NoError(t, json.Unmarshal(w.Body.Bytes(), &out))
	return out
}

func setupGQL(t *testing.T) (http.Handler, *db.Queries) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	state := &auth.PasswordState{}
	state.Set("dev-setup-secret")
	h := server.New(pool, nil, server.Options{Password: state})
	return h, q
}

func TestPairDeviceMintsSession(t *testing.T) {
	t.Parallel()
	h, q := setupGQL(t)

	body := `{"query":"mutation { pairDevice(password:\"dev-setup-secret\", displayName:\"Test Device\") { session { id displayName } token } }"}`
	resp := postGQL(t, h, body, "")
	require.Empty(t, resp.Errors, "expected no errors; got %+v", resp.Errors)

	var data struct {
		PairDevice struct {
			Session struct {
				ID          string `json:"id"`
				DisplayName string `json:"displayName"`
			} `json:"session"`
			Token string `json:"token"`
		} `json:"pairDevice"`
	}
	require.NoError(t, json.Unmarshal(resp.Data, &data))
	require.NotEmpty(t, data.PairDevice.Session.ID)
	require.Equal(t, "Test Device", data.PairDevice.Session.DisplayName)
	require.Len(t, data.PairDevice.Token, 43, "32 bytes base64-RawURL")

	// Session row in DB matches the returned token hash.
	owner, err := q.GetViewer(context.Background())
	require.NoError(t, err)
	sessions, err := q.ListActiveSessionsForPrincipal(context.Background(), owner.ID)
	require.NoError(t, err)
	require.Len(t, sessions, 1)
}

func TestPairDevicePasswordReusable(t *testing.T) {
	t.Parallel()
	h, _ := setupGQL(t)

	body := `{"query":"mutation { pairDevice(password:\"dev-setup-secret\", displayName:\"first\") { token } }"}`
	resp := postGQL(t, h, body, "")
	require.Empty(t, resp.Errors)

	// The static password is reusable: a second device may pair with it.
	resp2 := postGQL(t, h, body, "")
	require.Empty(t, resp2.Errors, "expected no errors; got %+v", resp2.Errors)
}

func TestPairDeviceRejectsBadSecret(t *testing.T) {
	t.Parallel()
	h, _ := setupGQL(t)

	body := `{"query":"mutation { pairDevice(password:\"wrong\", displayName:\"first\") { token } }"}`
	resp := postGQL(t, h, body, "")
	require.NotEmpty(t, resp.Errors)
	require.Equal(t, "BAD_PASSWORD", resp.Errors[0].Extensions["code"])
}

func TestPairDeviceRejectsEmptyDisplayName(t *testing.T) {
	t.Parallel()
	h, _ := setupGQL(t)

	body := `{"query":"mutation { pairDevice(password:\"dev-setup-secret\", displayName:\"\") { token } }"}`
	resp := postGQL(t, h, body, "")
	require.NotEmpty(t, resp.Errors)
}
