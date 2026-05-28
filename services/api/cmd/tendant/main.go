// Command tendant is the core API process: opens a pgx pool, runs the
// embedded Goose migrations, seeds the owner Principal, then serves the
// GraphQL surface on chi.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/server"
)

var (
	version   = "dev"
	commit    = "unknown"
	buildDate = "unknown"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	// Subcommand dispatch (seed is added in T018). Default is serve.
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "seed":
			if err := runSeed(os.Args[2:]); err != nil {
				slog.Error("seed failed", "err", err)
				os.Exit(1)
			}
			return
		case "serve":
			// fallthrough to serve
		default:
			slog.Error("unknown subcommand", "arg", os.Args[1])
			os.Exit(2)
		}
	}

	if err := runServe(); err != nil {
		slog.Error("startup failed", "err", err)
		os.Exit(1)
	}
}

func runServe() error {
	slog.Info("tendant starting",
		"version", version,
		"commit", commit,
		"build_date", buildDate,
	)

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	cfg := server.LoadConfig()

	// 1. Open pgx pool.
	pool, err := server.OpenPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return fmt.Errorf("open pool: %w", err)
	}
	defer pool.Close()

	// 2. Apply embedded migrations (idempotent).
	if err := db.Migrate(ctx, cfg.DatabaseURL); err != nil {
		return fmt.Errorf("migrate: %w", err)
	}

	// 3. Seed the owner Principal.
	if err := core.SeedOwner(ctx, db.New(pool)); err != nil {
		return fmt.Errorf("seed owner: %w", err)
	}

	// 4. DBOS init / launch (recovers PENDING workflows for this executor).
	dctx, err := durable.Init(ctx, pool, "tendant")
	if err != nil {
		return fmt.Errorf("dbos init: %w", err)
	}
	defer durable.Shutdown(dctx, 5*time.Second)
	if err := durable.Launch(dctx); err != nil {
		return fmt.Errorf("dbos launch: %w", err)
	}
	slog.Info("dbos launched")

	// 5. Build the chi router (gqlgen handler + /healthz) and serve.
	httpServer := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           server.New(pool),
		ReadHeaderTimeout: 10 * time.Second,
	}

	serverErr := make(chan error, 1)
	go func() {
		slog.Info("listening", "addr", cfg.HTTPAddr)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
			return
		}
		close(serverErr)
	}()

	select {
	case <-ctx.Done():
		slog.Info("shutdown signal received")
	case err := <-serverErr:
		if err != nil {
			return fmt.Errorf("http server: %w", err)
		}
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		slog.Error("http shutdown", "err", err)
	}
	return nil
}

// runSeed creates a Task via internal/core.CreateTask. Ensures the schema
// + owner Principal exist first (idempotent) so `seed` works even before the
// server has been booted against a fresh database.
func runSeed(args []string) error {
	fs := flag.NewFlagSet("seed", flag.ExitOnError)
	title := fs.String("title", "hello", "task title")
	description := fs.String("description", "", "task description (optional)")
	if err := fs.Parse(args); err != nil {
		return err
	}

	cfg := server.LoadConfig()
	ctx := context.Background()
	pool, err := server.OpenPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return fmt.Errorf("open pool: %w", err)
	}
	defer pool.Close()

	if err := db.Migrate(ctx, cfg.DatabaseURL); err != nil {
		return fmt.Errorf("migrate: %w", err)
	}
	q := db.New(pool)
	if err := core.SeedOwner(ctx, q); err != nil {
		return fmt.Errorf("seed owner: %w", err)
	}

	created, err := core.CreateTask(ctx, q, *title, *description)
	if err != nil {
		return err
	}
	slog.Info("created task",
		"id", created.ID,
		"global_uri", created.GlobalURI,
		"title", created.Title,
	)
	// Print the id to stdout so scripts can capture it.
	fmt.Println(created.ID)
	return nil
}
