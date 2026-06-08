// Package server wires the chi HTTP router, gqlgen handler, and a pgx pool.
package server

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/jackc/pgx/v5/pgxpool"

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
// the returned pool and must Close it.
func OpenPool(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	if dsn == "" {
		return nil, fmt.Errorf("DATABASE_URL is empty")
	}
	return pgxpool.New(ctx, dsn)
}
