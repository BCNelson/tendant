package intake_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/crypto"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// fakeRefresher records calls and returns a canned fresh bundle.
type fakeRefresher struct {
	calls     int
	sawReftok string
	out       intake.TokenBundle
}

func (f *fakeRefresher) Refresh(_ context.Context, refreshToken string) (intake.TokenBundle, error) {
	f.calls++
	f.sawReftok = refreshToken
	return f.out, nil
}

func newCredStore(t *testing.T, q *db.Queries) *intake.SealedCredentialStore {
	t.Helper()
	// A fixed 32-byte key so the test doesn't depend on the env var.
	sealer, err := crypto.New([]byte("0123456789abcdef0123456789abcdef"))
	require.NoError(t, err)
	return intake.NewSealedCredentialStore(q, sealer)
}

// Seal → Open round-trips a token bundle through source_credentials.
func TestCredentials_SealOpenRoundTrip(t *testing.T) {
	ctx := context.Background()
	_, q := testEnv(t)
	cid := seedConnector(t, q, "gmail")
	store := newCredStore(t, q)

	want := intake.TokenBundle{
		AccessToken:  "tok-abc",
		RefreshToken: "ref-xyz",
		Scopes:       []string{"gmail.readonly"},
		ExpiresAt:    time.Now().Add(time.Hour).UTC().Truncate(time.Second),
	}
	require.NoError(t, store.Upsert(ctx, cid, want))

	// A token far from expiry is returned as-is, no refresh.
	acc := store.Accessor(cid, nil, func() time.Time { return time.Now() })
	got, err := acc.Token(ctx)
	require.NoError(t, err)
	require.Equal(t, want.AccessToken, got.AccessToken)
	require.Equal(t, want.RefreshToken, got.RefreshToken)

	// The sealed bytes are NOT the plaintext token (encrypted at rest).
	row, err := q.GetSourceCredential(ctx, cid)
	require.NoError(t, err)
	require.NotContains(t, string(row.Encrypted), "tok-abc")
}

// A token within the refresh skew triggers a refresh and re-seals in place.
func TestCredentials_RefreshNearExpiry(t *testing.T) {
	ctx := context.Background()
	_, q := testEnv(t)
	cid := seedConnector(t, q, "gmail")
	store := newCredStore(t, q)

	// Stored token expires in 30s — inside the 2-minute skew.
	require.NoError(t, store.Upsert(ctx, cid, intake.TokenBundle{
		AccessToken:  "old",
		RefreshToken: "ref-1",
		ExpiresAt:    time.Now().Add(30 * time.Second),
	}))

	refresher := &fakeRefresher{out: intake.TokenBundle{
		AccessToken: "fresh",
		ExpiresAt:   time.Now().Add(time.Hour),
		// note: no refresh token returned — provider often omits it.
	}}
	acc := store.Accessor(cid, refresher, time.Now)
	got, err := acc.Token(ctx)
	require.NoError(t, err)
	require.Equal(t, 1, refresher.calls, "near-expiry token must refresh")
	require.Equal(t, "ref-1", refresher.sawReftok)
	require.Equal(t, "fresh", got.AccessToken)
	require.Equal(t, "ref-1", got.RefreshToken, "refresh token is carried forward when the provider omits it")

	// The re-sealed row now holds the fresh token (open it back).
	acc2 := store.Accessor(cid, nil, func() time.Time { return time.Now() })
	reopened, err := acc2.Token(ctx)
	require.NoError(t, err)
	require.Equal(t, "fresh", reopened.AccessToken)
}

// A nil refresher (zero-credential or no-refresh connector) never refreshes.
func TestCredentials_NoRefresherReturnsStored(t *testing.T) {
	ctx := context.Background()
	_, q := testEnv(t)
	cid := seedConnector(t, q, "gmail")
	store := newCredStore(t, q)
	require.NoError(t, store.Upsert(ctx, cid, intake.TokenBundle{
		AccessToken: "x", ExpiresAt: time.Now().Add(time.Second), // even near-expiry
	}))
	got, err := store.Accessor(cid, nil, time.Now).Token(ctx)
	require.NoError(t, err)
	require.Equal(t, "x", got.AccessToken)
}
