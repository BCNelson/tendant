package testutil

import (
	"context"
	"fmt"
	"math/rand/v2"
	"os"
	"strings"
	"sync"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/testcontainers/testcontainers-go/wait"
)

func init() {
	// Disable Ryuk reaper when using rootless Podman — Ryuk tries to bind to
	// the Docker socket which fails outside of Docker proper.
	if os.Getenv("TESTCONTAINERS_RYUK_DISABLED") == "" {
		_ = os.Setenv("TESTCONTAINERS_RYUK_DISABLED", "true")
	}
}

var (
	sharedContainer *postgres.PostgresContainer
	sharedConnStr   string
	containerOnce   sync.Once
	containerErr    error
)

func getContainer(t testing.TB) (string, error) {
	t.Helper()
	containerOnce.Do(func() {
		ctx := context.Background()
		sharedContainer, containerErr = postgres.Run(ctx,
			"docker.io/pgvector/pgvector:0.7.1-pg16",
			postgres.WithDatabase("postgres"),
			postgres.WithUsername("test"),
			postgres.WithPassword("test"),
			testcontainers.WithWaitStrategy(
				wait.ForLog("database system is ready to accept connections").WithOccurrence(2),
			),
		)
		if containerErr != nil {
			return
		}
		sharedConnStr, containerErr = sharedContainer.ConnectionString(ctx, "sslmode=disable")
	})
	return sharedConnStr, containerErr
}

// TestDB returns a pgx pool connected to a fresh database on the shared
// testcontainers Postgres instance. The database is dropped on test cleanup.
// Safe for parallel tests. Accepts testing.TB so benchmarks can use it
// too (just_test runs with -race + benchmarks behind -bench).
func TestDB(t testing.TB) *pgxpool.Pool {
	t.Helper()
	ctx := context.Background()

	connStr, err := getContainer(t)
	require.NoError(t, err, "start testcontainers postgres")

	adminPool, err := pgxpool.New(ctx, connStr)
	require.NoError(t, err)

	dbName := sanitizeDBName(t.Name()) + fmt.Sprintf("_%d", rand.IntN(99999))
	_, err = adminPool.Exec(ctx, "CREATE DATABASE "+quoteIdent(dbName))
	require.NoError(t, err)
	adminPool.Close()

	testConnStr := strings.Replace(connStr, "/postgres?", "/"+dbName+"?", 1)
	pool, err := pgxpool.New(ctx, testConnStr)
	require.NoError(t, err)

	t.Cleanup(func() {
		pool.Close()
		cleanupPool, cleanupErr := pgxpool.New(context.Background(), connStr)
		if cleanupErr == nil {
			_, _ = cleanupPool.Exec(context.Background(), "DROP DATABASE IF EXISTS "+quoteIdent(dbName))
			cleanupPool.Close()
		}
	})

	return pool
}

func sanitizeDBName(name string) string {
	r := strings.NewReplacer("/", "_", " ", "_", "-", "_")
	s := r.Replace(strings.ToLower(name))
	if len(s) > 50 {
		s = s[:50]
	}
	return s
}

func quoteIdent(s string) string {
	return `"` + strings.ReplaceAll(s, `"`, `""`) + `"`
}
