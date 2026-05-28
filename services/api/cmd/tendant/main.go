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

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/push"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

var (
	version   = "dev"
	commit    = "unknown"
	buildDate = "unknown"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "seed":
			if err := runSeed(os.Args[2:]); err != nil {
				slog.Error("seed failed", "err", err)
				os.Exit(1)
			}
			return
		case "serve":
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

	// 2. Migrations.
	if err := db.Migrate(ctx, cfg.DatabaseURL); err != nil {
		return fmt.Errorf("migrate: %w", err)
	}

	// 3. Seed owner Principal + Phase 3 tools.
	q := db.New(pool)
	if err := core.SeedOwner(ctx, q); err != nil {
		return fmt.Errorf("seed owner: %w", err)
	}
	if err := tools.SeedSendEmail(ctx, q); err != nil {
		return fmt.Errorf("seed send-email: %w", err)
	}
	ownerURI := ownerGlobalURI(ctx, q)

	// 3b. In-process tool registry. Phase 3 ships one tool (send-email)
	// behind a LogProvider; real providers slot in for Phase 7.
	toolRegistry := tools.NewRegistry()
	toolRegistry.Register(tools.NewSendEmail(nil))

	// 4. Phase 2 setup secret + push selector.
	if secret := os.Getenv("TENDANT_SETUP_SECRET"); secret != "" {
		auth.SetupSecret.Arm(secret)
		slog.Info("sessions setup_secret armed", "secret_source", "env(TENDANT_SETUP_SECRET)")
	} else {
		slog.Warn("TENDANT_SETUP_SECRET not set — device pairing disabled this boot")
	}

	pushSel := buildPushSelector()
	slog.Info("push provider", "provider", pushSel.Name())
	pushWorker := &push.Worker{Queries: q, Selector: pushSel}
	pushAdapter := pushAdapter{worker: pushWorker}

	// 5. DBOS init / register / launch.
	dctx, err := durable.Init(ctx, pool, "tendant")
	if err != nil {
		return fmt.Errorf("dbos init: %w", err)
	}
	defer durable.Shutdown(dctx, 5*time.Second)
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, ownerURI, pushAdapter)
	durable.RegisterPushQueue(dctx)
	durable.RegisterToolCallWorkflow(dctx, pool, q, toolRegistry)
	if err := durable.Launch(dctx); err != nil {
		return fmt.Errorf("dbos launch: %w", err)
	}
	slog.Info("dbos launched (recovery, if any, completed)")

	// 6. LISTEN dispatcher.
	disp, err := realtime.New(ctx, pool, q, nil)
	if err != nil {
		return fmt.Errorf("realtime dispatcher: %w", err)
	}
	go disp.Run(ctx)
	defer disp.Stop(context.Background())

	// 7. Operator-edge auth registry assertion.
	graph.RegisterOperatorEdgeAuth(auth.DefaultRegistry)
	auth.DefaultRegistry.AssertCovers(graph.OperatorEdgeRequiredFields())

	// 8. HTTP server.
	httpServer := &http.Server{
		Addr: cfg.HTTPAddr,
		Handler: server.New(pool, dctx, server.Options{
			Dispatcher:   disp,
			PushSelector: pushSel,
			PushQueue:    durable.PushQueueName,
			SetupSecret:  auth.SetupSecret,
		}),
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

// pushAdapter implements chain.PushEnqueuer for an in-process push.Worker.
// Phase 2 runs the worker inline inside the chain workflow's DBOS step
// (already crash-safe via step memoization). A future optimization can swap
// this for a real DBOS queue handle.
type pushAdapter struct{ worker *push.Worker }

func (a pushAdapter) EnqueuePush(ctx context.Context, p chain.PushJobPayload) error {
	return a.worker.Run(ctx, push.JobPayload{
		TaskID:             p.TaskID,
		AssignmentID:       p.AssignmentID,
		RecipientGlobalURI: p.RecipientGlobalURI,
		DeepLinkID:         p.DeepLinkID,
		Title:              p.Title,
	})
}

// buildPushSelector reads TENDANT_APNS_* / TENDANT_FCM_* env vars and
// constructs the platform → provider selector. Falls back to LogProvider
// when neither real provider is configured.
func buildPushSelector() push.Selector {
	sel := push.Selector{Log: push.LogProvider{}}
	// APNs / FCM real providers wired in US1 T047/T048; until then the
	// LogProvider stub is the boot default. Future wiring reads:
	//   TENDANT_APNS_KEY_ID, TENDANT_APNS_TEAM_ID, TENDANT_APNS_BUNDLE_ID,
	//   TENDANT_APNS_KEY_PATH, TENDANT_APNS_PRODUCTION
	//   GOOGLE_APPLICATION_CREDENTIALS, TENDANT_FCM_PROJECT_ID
	return sel
}

func ownerGlobalURI(ctx context.Context, q *db.Queries) string {
	v, err := q.GetViewer(ctx)
	if err != nil {
		slog.Warn("owner lookup failed; chain workflow will leave to_principal NULL", "err", err)
		return ""
	}
	return v.GlobalUri
}

// runSeed creates a Task via internal/core.CreateTask. Idempotent on
// migrations + owner so it works before the server has been booted.
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
	if err := core.SeedOwner(ctx, db.New(pool)); err != nil {
		return fmt.Errorf("seed owner: %w", err)
	}

	created, err := core.CreateTask(ctx, pool, nil, *title, *description)
	if err != nil {
		return err
	}
	slog.Info("created task",
		"id", created.ID,
		"global_uri", created.GlobalURI,
		"title", created.Title,
	)
	fmt.Println(created.ID)
	return nil
}
