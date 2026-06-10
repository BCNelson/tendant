// Package server wires the chi HTTP router, gqlgen handler, and a pgx pool.
package server

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"strconv"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	pgxvec "github.com/pgvector/pgvector-go/pgx"

	"github.com/bcnelson/tendant/services/api/internal/secret"
)

// Config holds runtime configuration loaded from the environment.
type Config struct {
	DatabaseURL string
	HTTPAddr    string

	// Phase 6: agent layer budget controls.
	GateCallBudget int // per-task max gated calls before fail-close to human
	AgentMaxIter   int // per-stage max agent loop iterations
}

// LoadConfig reads configuration from the environment. DATABASE_URL is required;
// HTTP_ADDR defaults to :8080.
func LoadConfig() Config {
	return Config{
		DatabaseURL:    secret.Getenv("DATABASE_URL"),
		HTTPAddr:       envOr("HTTP_ADDR", ":8080"),
		GateCallBudget: envInt("TENDANT_GATE_CALL_BUDGET", 100),
		AgentMaxIter:   envInt("TENDANT_AGENT_MAX_ITER", 20),
	}
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func envInt(key string, def int) int {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return def
	}
	return n
}

// OpenPool opens a new pgx connection pool against the given DSN. Caller owns
// the returned pool and must Close it. Each connection registers the pgvector
// types (binary codecs for the `vector` column used by internal/embedding).
// Registration is best-effort: the pool is opened before migrations run, so a
// connection established before the `vector` extension exists must still succeed
// — `pgvector.Vector` falls back to text via driver.Valuer/Scanner, and
// post-migration connections pick up the binary codec.
func OpenPool(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	if dsn == "" {
		return nil, fmt.Errorf("DATABASE_URL is empty")
	}
	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("parse pool config: %w", err)
	}
	cfg.AfterConnect = func(ctx context.Context, conn *pgx.Conn) error {
		if err := pgxvec.RegisterTypes(ctx, conn); err != nil {
			// vector extension not present yet (pre-migration) — tolerate it.
			slog.Debug("pgvector type registration skipped", "err", err)
		}
		return nil
	}
	return pgxpool.NewWithConfig(ctx, cfg)
}
