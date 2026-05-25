package main

import (
	"context"
	"testing"

	"github.com/bcnelson/tendant/internal/testutil"

	"github.com/stretchr/testify/require"
)

func TestPostgresContainerStarts(t *testing.T) {
	t.Parallel()
	pool := testutil.TestDB(t)
	var n int
	err := pool.QueryRow(context.Background(), "SELECT 1").Scan(&n)
	require.NoError(t, err)
	require.Equal(t, 1, n)
}

