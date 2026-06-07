package ownerrule_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/ownerrule"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func setup(t *testing.T) *ownerrule.Service {
	t.Helper()
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	return ownerrule.New(db.New(pool))
}

const owner = "tendant://principals/owner"

func TestOwnerRule_MissingKeyReturnsNotFound(t *testing.T) {
	svc := setup(t)
	v, found, err := svc.Get(context.Background(), owner, "nope")
	require.NoError(t, err)
	require.False(t, found)
	require.Equal(t, "", v)
}

func TestOwnerRule_SetThenGet(t *testing.T) {
	svc := setup(t)
	ctx := context.Background()

	// First set: no previous value.
	prev, err := svc.Set(ctx, owner, "max_email_size_kb", "100")
	require.NoError(t, err)
	require.Nil(t, prev)

	v, found, err := svc.Get(ctx, owner, "max_email_size_kb")
	require.NoError(t, err)
	require.True(t, found)
	require.Equal(t, "100", v)
}

func TestOwnerRule_UpsertReturnsPrevious(t *testing.T) {
	svc := setup(t)
	ctx := context.Background()

	_, err := svc.Set(ctx, owner, "k", "v1")
	require.NoError(t, err)

	// Second set on the same key returns the previous value and overwrites.
	prev, err := svc.Set(ctx, owner, "k", "v2")
	require.NoError(t, err)
	require.NotNil(t, prev)
	require.Equal(t, "v1", *prev)

	v, found, err := svc.Get(ctx, owner, "k")
	require.NoError(t, err)
	require.True(t, found)
	require.Equal(t, "v2", v)
}

func TestOwnerRule_ScopedByOwner(t *testing.T) {
	svc := setup(t)
	ctx := context.Background()

	_, err := svc.Set(ctx, owner, "k", "mine")
	require.NoError(t, err)

	// A different owner URI must not see the first owner's rule.
	_, found, err := svc.Get(ctx, "tendant://principals/other", "k")
	require.NoError(t, err)
	require.False(t, found)
}
