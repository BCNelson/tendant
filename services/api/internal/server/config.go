// Package server wires the chi HTTP router, gqlgen handler, and a pgx pool.
package server

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Config holds runtime configuration loaded from the environment.
type Config struct {
	DatabaseURL string
	HTTPAddr    string
}

// LoadConfig reads configuration from the environment. DATABASE_URL is required;
// HTTP_ADDR defaults to :8080.
func LoadConfig() Config {
	return Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		HTTPAddr:    envOr("HTTP_ADDR", ":8080"),
	}
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// OpenPool opens a new pgx connection pool against the given DSN. Caller owns
// the returned pool and must Close it.
func OpenPool(ctx context.Context, dsn string) (*pgxpool.Pool, error) {
	if dsn == "" {
		return nil, fmt.Errorf("DATABASE_URL is empty")
	}
	return pgxpool.New(ctx, dsn)
}
