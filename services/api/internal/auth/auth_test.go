package auth_test

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"log/slog"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setupDB(t *testing.T) (*db.Queries, db.Principal) {
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

func TestMintTokenAndHashToken(t *testing.T) {
	t.Parallel()
	raw := auth.MintToken()
	require.Len(t, raw, 43, "32 bytes base64-RawURL should be 43 chars")

	decoded, err := base64.RawURLEncoding.DecodeString(raw)
	require.NoError(t, err)
	require.Len(t, decoded, 32)

	h := auth.HashToken(raw)
	want := sha256.Sum256([]byte(raw))
	require.True(t, bytes.Equal(h, want[:]))
}

func TestIssueAndResolveSession(t *testing.T) {
	t.Parallel()
	q, owner := setupDB(t)
	ctx := context.Background()

	sess, raw, err := auth.IssueSession(ctx, q, owner.ID, "Test Device")
	require.NoError(t, err)
	require.NotEmpty(t, raw)

	h := auth.HashToken(raw)
	require.True(t, bytes.Equal(sess.TokenHash, h))
	require.Equal(t, "Test Device", sess.DisplayName)

	p, resolved, err := auth.Resolve(ctx, q, raw)
	require.NoError(t, err)
	require.Equal(t, owner.ID, p.ID)
	require.Equal(t, owner.GlobalUri, p.GlobalURI)
	require.Equal(t, sess.ID, resolved.ID)
}

func TestRevokeSession(t *testing.T) {
	t.Parallel()
	q, owner := setupDB(t)
	ctx := context.Background()

	sess, raw, err := auth.IssueSession(ctx, q, owner.ID, "Test Device")
	require.NoError(t, err)

	revoked, err := auth.RevokeSession(ctx, q, sess.ID)
	require.NoError(t, err)
	require.True(t, revoked.RevokedAt.Valid, "revoked_at should be set")

	_, _, err = auth.Resolve(ctx, q, raw)
	require.ErrorIs(t, err, auth.ErrUnauthorized)
}

func TestResolveEmpty(t *testing.T) {
	t.Parallel()
	q, _ := setupDB(t)
	_, _, err := auth.Resolve(context.Background(), q, "")
	require.ErrorIs(t, err, auth.ErrUnauthorized)
}

func TestSetupSecretConsume(t *testing.T) {
	t.Parallel()
	s := &auth.SetupSecretState{}

	// Un-armed.
	require.ErrorIs(t, s.Consume("anything"), auth.ErrNotArmed)

	s.Arm("supersecret")
	require.True(t, s.IsArmed())
	// Bad value.
	require.ErrorIs(t, s.Consume("bad"), auth.ErrBadSetupSecret)
	// Good value succeeds; one-time.
	require.NoError(t, s.Consume("supersecret"))
	require.ErrorIs(t, s.Consume("supersecret"), auth.ErrAlreadyConsumed)
	require.False(t, s.IsArmed())
}

func TestCanOwnerPositive(t *testing.T) {
	t.Parallel()
	p := &auth.Principal{ID: uuid.New(), GlobalURI: "local://principal/owner", DisplayName: "Owner", Kind: "user"}
	require.True(t, auth.Can(context.Background(), p, "view", &db.Task{}))
	require.True(t, auth.Can(context.Background(), p, "complete", &db.AgentAssignment{}))
	require.True(t, auth.Can(context.Background(), p, "view", &db.PendingDecision{}))
	require.True(t, auth.Can(context.Background(), p, "revoke_session", auth.SessionRef{ID: uuid.New()}))
}

func TestCanNilPrincipal(t *testing.T) {
	t.Parallel()
	require.False(t, auth.Can(context.Background(), nil, "view", &db.Task{}))
}

func TestCanUnknownTarget(t *testing.T) {
	t.Parallel()
	var buf bytes.Buffer
	prev := slog.Default()
	slog.SetDefault(slog.New(slog.NewJSONHandler(&buf, &slog.HandlerOptions{Level: slog.LevelWarn})))
	defer slog.SetDefault(prev)

	p := &auth.Principal{ID: uuid.New(), GlobalURI: "local://principal/owner"}
	type random struct{}
	require.False(t, auth.Can(context.Background(), p, "view", random{}))
	require.Contains(t, buf.String(), "auth.Can: unrecognized target type", "should log warn on unknown target")
}

func TestRegistryAssertCovers(t *testing.T) {
	t.Parallel()
	r := auth.NewRegistry()
	r.MustRegister("Query", "inbox", "view", "InboxItem")
	require.True(t, r.Has("Query", "inbox"))
	require.False(t, r.Has("Query", "missing"))

	require.NotPanics(t, func() {
		r.AssertCovers([]auth.FieldKey{{TypeName: "Query", FieldName: "inbox"}})
	})
	require.Panics(t, func() {
		r.AssertCovers([]auth.FieldKey{{TypeName: "Query", FieldName: "missing"}})
	})
}

func TestRegistryDuplicateRegistration(t *testing.T) {
	t.Parallel()
	r := auth.NewRegistry()
	r.MustRegister("Mutation", "pairDevice", "register_device", "Principal")
	require.Panics(t, func() {
		r.MustRegister("Mutation", "pairDevice", "register_device", "Principal")
	})
}

// Smoke check that ErrUnauthorized stays a sentinel value (callers do
// errors.Is checks rather than string compare).
func TestErrUnauthorizedIsSentinel(t *testing.T) {
	t.Parallel()
	err := auth.ErrUnauthorized
	require.True(t, errors.Is(err, auth.ErrUnauthorized))
}
