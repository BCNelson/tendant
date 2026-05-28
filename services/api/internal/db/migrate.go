package db

import (
	"context"
	"database/sql"
	"fmt"
	"io/fs"

	_ "github.com/jackc/pgx/v5/stdlib" // pgx stdlib driver registration for goose
	"github.com/pressly/goose/v3"
	"github.com/pressly/goose/v3/database"

	dbmod "github.com/bcnelson/tendant/db"
)

// Migrate applies all embedded migrations using goose against the pgx stdlib
// driver. Idempotent — re-running on an up-to-date database is a no-op.
func Migrate(ctx context.Context, dsn string) error {
	sqlDB, err := sql.Open("pgx", dsn)
	if err != nil {
		return fmt.Errorf("open sql.DB: %w", err)
	}
	defer func() { _ = sqlDB.Close() }()
	provider, err := newProvider(sqlDB)
	if err != nil {
		return err
	}
	if _, err := provider.Up(ctx); err != nil {
		return fmt.Errorf("goose up: %w", err)
	}
	return nil
}

// MigrateDown rolls back every applied migration. Used by the round-trip test
// (T027) to prove each `-- +goose Down` cleans up cleanly.
func MigrateDown(ctx context.Context, dsn string) error {
	sqlDB, err := sql.Open("pgx", dsn)
	if err != nil {
		return fmt.Errorf("open sql.DB: %w", err)
	}
	defer func() { _ = sqlDB.Close() }()
	provider, err := newProvider(sqlDB)
	if err != nil {
		return err
	}
	if _, err := provider.DownTo(ctx, 0); err != nil {
		return fmt.Errorf("goose down-to 0: %w", err)
	}
	return nil
}

// newProvider constructs a per-call goose.Provider so parallel tests don't
// race on goose's package-level globals (SetBaseFS / SetDialect).
func newProvider(sqlDB *sql.DB) (*goose.Provider, error) {
	migrationsFS, err := fs.Sub(dbmod.Migrations, "migrations")
	if err != nil {
		return nil, fmt.Errorf("scope migrations FS: %w", err)
	}
	provider, err := goose.NewProvider(database.DialectPostgres, sqlDB, migrationsFS)
	if err != nil {
		return nil, fmt.Errorf("goose provider: %w", err)
	}
	return provider, nil
}
