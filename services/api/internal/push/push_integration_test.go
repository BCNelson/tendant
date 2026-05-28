package push_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/push"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupPushDB(t *testing.T) (*db.Queries, db.Principal) {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	owner, err := q.GetViewer(ctx)
	require.NoError(t, err)
	return q, owner
}

func TestWorkerLogProviderEmitsOnlyExpectedFields(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupPushDB(t)

	// Register a token for the seeded owner.
	_, err := q.UpsertDeviceToken(ctx, db.UpsertDeviceTokenParams{
		Token:    "tok-leak-test",
		OwnerID:  owner.ID,
		Platform: db.DevicePlatformIos,
	})
	require.NoError(t, err)

	// Capture slog records.
	var buf bytes.Buffer
	prev := slog.Default()
	slog.SetDefault(slog.New(slog.NewJSONHandler(&buf, &slog.HandlerOptions{Level: slog.LevelInfo})))
	defer slog.SetDefault(prev)

	w := &push.Worker{Queries: q, Selector: push.Selector{Log: push.LogProvider{}}}
	err = w.Run(ctx, push.JobPayload{
		TaskID:             uuid.New(),
		AssignmentID:       uuid.New(),
		RecipientGlobalURI: owner.GlobalUri,
		DeepLinkID:         "deep-1",
		Title:              "tendant",
	})
	require.NoError(t, err)

	// SC-003 assertion: parse all log records, find the LogProvider.Send,
	// assert its key set is exactly the expected fields.
	found := false
	for _, line := range bytes.Split(bytes.TrimSpace(buf.Bytes()), []byte("\n")) {
		var rec map[string]any
		if err := json.Unmarshal(line, &rec); err != nil {
			continue
		}
		msg, _ := rec["msg"].(string)
		if msg != "push.LogProvider.Send" {
			continue
		}
		found = true
		want := map[string]bool{
			"time": true, "level": true, "msg": true,
			"token": true, "platform": true, "title": true, "deep_link_id": true,
		}
		for k := range rec {
			if !want[k] {
				t.Fatalf("unexpected key %q in LogProvider record: %v", k, rec)
			}
		}
		require.Equal(t, "tok-leak-test", rec["token"])
		require.Equal(t, "ios", rec["platform"])
		require.Equal(t, "tendant", rec["title"])
		require.Equal(t, "deep-1", rec["deep_link_id"])
	}
	require.True(t, found, "did not see push.LogProvider.Send in slog output")
}

// invalidTokenProvider returns ErrTokenInvalid the first time it's called.
type invalidTokenProvider struct{ called int }

func (p *invalidTokenProvider) Name() string { return "FakeInvalid" }
func (p *invalidTokenProvider) IsTokenInvalid(err error) bool {
	return errors.Is(err, push.ErrTokenInvalid)
}
func (p *invalidTokenProvider) Send(_ context.Context, _ string, _ db.DevicePlatform, _ push.PushBody) error {
	p.called++
	return push.ErrTokenInvalid
}

func TestWorkerPrunesInvalidTokens(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupPushDB(t)

	_, err := q.UpsertDeviceToken(ctx, db.UpsertDeviceTokenParams{
		Token:    "tok-bad",
		OwnerID:  owner.ID,
		Platform: db.DevicePlatformIos,
	})
	require.NoError(t, err)

	bad := &invalidTokenProvider{}
	w := &push.Worker{Queries: q, Selector: push.Selector{APNs: bad, Log: push.LogProvider{}}}
	err = w.Run(ctx, push.JobPayload{
		RecipientGlobalURI: owner.GlobalUri,
		DeepLinkID:         "deep-bad",
		Title:              "tendant",
	})
	require.NoError(t, err)

	tokens, err := q.ListDeviceTokensForPrincipal(ctx, owner.ID)
	require.NoError(t, err)
	require.Empty(t, tokens, "invalid token should have been pruned")
}
