package graph_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestRegisterDeviceTokenUpsert(t *testing.T) {
	t.Parallel()
	h, q := setupGQL(t)
	// Pair to obtain a bearer.
	pairBody := `{"query":"mutation { pairDevice(setupSecret:\"dev-setup-secret\", displayName:\"D\") { token } }"}`
	pair := postGQL(t, h, pairBody, "")
	require.Empty(t, pair.Errors)
	var pd struct {
		PairDevice struct {
			Token string `json:"token"`
		} `json:"pairDevice"`
	}
	require.NoError(t, json.Unmarshal(pair.Data, &pd))
	bearer := pd.PairDevice.Token
	require.NotEmpty(t, bearer)

	// Register a token.
	regBody := `{"query":"mutation { registerDeviceToken(token:\"tok-1\", platform: IOS) }"}`
	resp := postGQL(t, h, regBody, bearer)
	require.Empty(t, resp.Errors, "expected no errors; got %+v", resp.Errors)

	// Re-register the same token (idempotent upsert).
	resp2 := postGQL(t, h, regBody, bearer)
	require.Empty(t, resp2.Errors)

	owner, err := q.GetViewer(context.Background())
	require.NoError(t, err)
	tokens, err := q.ListDeviceTokensForPrincipal(context.Background(), owner.ID)
	require.NoError(t, err)
	require.Len(t, tokens, 1, "upsert should keep exactly one row")
	require.Equal(t, "tok-1", tokens[0].Token)
}

func TestRegisterDeviceTokenUnauthorized(t *testing.T) {
	t.Parallel()
	h, _ := setupGQL(t)

	regBody := `{"query":"mutation { registerDeviceToken(token:\"tok-1\", platform: IOS) }"}`
	resp := postGQL(t, h, regBody, "")
	require.NotEmpty(t, resp.Errors)
	require.Equal(t, "UNAUTHORIZED", resp.Errors[0].Extensions["code"])
}
