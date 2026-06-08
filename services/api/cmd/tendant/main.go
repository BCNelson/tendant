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
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/chain"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/intake"
	"github.com/bcnelson/tendant/services/api/internal/llm"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
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
	// A dynamic level so log.level can be changed at runtime (config overlay).
	var logLevel slog.LevelVar // zero value = Info
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: &logLevel}))
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

	if err := runServe(&logLevel); err != nil {
		slog.Error("startup failed", "err", err)
		os.Exit(1)
	}
}

// applyLogLevel sets the dynamic slog level from a config string.
func applyLogLevel(lv *slog.LevelVar, level string) {
	switch level {
	case "debug":
		lv.Set(slog.LevelDebug)
	case "warn":
		lv.Set(slog.LevelWarn)
	case "error":
		lv.Set(slog.LevelError)
	default:
		lv.Set(slog.LevelInfo)
	}
}

func runServe(logLevel *slog.LevelVar) error {
	slog.Info("tendant starting",
		"version", version,
		"commit", commit,
		"build_date", buildDate,
	)

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	// Resolve the layered config (env > file > defaults; DB overlay loaded below).
	fs := flag.NewFlagSet("serve", flag.ContinueOnError)
	configPath := fs.String("config", "", "path to tendant.toml (else standard search paths)")
	serveArgs := os.Args[1:]
	if len(serveArgs) > 0 && serveArgs[0] == "serve" {
		serveArgs = serveArgs[1:]
	}
	if err := fs.Parse(serveArgs); err != nil {
		return fmt.Errorf("parse flags: %w", err)
	}
	cfg, err := config.Load(*configPath)
	if err != nil {
		return fmt.Errorf("load config: %w", err)
	}

	// 1. Open pgx pool.
	pool, err := server.OpenPool(ctx, cfg.Database.URL)
	if err != nil {
		return fmt.Errorf("open pool: %w", err)
	}
	defer pool.Close()

	// 2. Migrations.
	if err := db.Migrate(ctx, cfg.Database.URL); err != nil {
		return fmt.Errorf("migrate: %w", err)
	}

	// 2b. Config overlay (config_entries) — the DB-side override layer for
	// db_configurable keys. Loaded after migrate (the table now exists) and kept
	// live via LISTEN config_changed so admin edits propagate without restart.
	overlay := config.NewOverlay(pool, slog.Default())
	if err := overlay.Load(ctx); err != nil {
		return fmt.Errorf("config overlay load: %w", err)
	}
	if err := overlay.Listen(ctx); err != nil {
		slog.Warn("config overlay: LISTEN failed; runtime overrides won't hot-reload", "err", err)
	}
	defer overlay.Stop()

	// Live resolver: subsystems read tunables through this so an owner's DB
	// override takes effect without a restart (DB overlay > boot snapshot).
	live := config.NewLive(cfg, overlay)
	applyLogLevel(logLevel, live.LogLevel())
	overlay.OnChange(func(key string) {
		if key == "log.level" {
			applyLogLevel(logLevel, live.LogLevel())
			slog.Info("config: log level changed live", "level", live.LogLevel())
		}
	})

	// 3. Seed owner + reconcile catalogs. The reconcilers are file/DB-driven and
	// fall back to the in-code default catalog when the config omits a section.
	q := db.New(pool)
	if err := core.SeedOwner(ctx, q); err != nil {
		return fmt.Errorf("seed owner: %w", err)
	}
	if err := tools.ReconcileTools(ctx, q, cfg.Tools); err != nil {
		return fmt.Errorf("reconcile tools: %w", err)
	}
	if err := tools.SeedExampleGateScriptIf(ctx, q, cfg.Seed.ExampleGateScript, ceilingsFromConfig(cfg)); err != nil {
		return fmt.Errorf("seed example gate script: %w", err)
	}
	if err := core.ReconcileAgentCatalog(ctx, q, cfg.Agents); err != nil {
		return fmt.Errorf("reconcile agent catalog: %w", err)
	}
	if err := core.ReconcileConnectors(ctx, q, cfg.Connectors); err != nil {
		return fmt.Errorf("reconcile connectors: %w", err)
	}
	ownerURI := ownerGlobalURI(ctx, q)

	// 3b. In-process tool registry. Phase 3 ships one tool (send-email)
	// behind a LogProvider; real providers slot in for Phase 7.
	toolRegistry := tools.NewRegistry()
	toolRegistry.Register(tools.NewSendEmail(nil))

	// 3c. Phase 8 calibration subsystem: config knobs (env → constants), the
	// rolling /healthz metrics, the Engine (recording + demotion + flag + sweep),
	// and the intake threshold tuner. The Engine is injected into the tool-call
	// workflow (outcome recording), the gate (via the resolver's grant lookup),
	// the cancel path, and the flagOutcome mutation.
	calibCfg := calibrationConfigFrom(cfg, overlay)
	calibMetrics := calibration.NewMetrics(calibCfg.Maturation)
	calibrator := calibration.New(pool, calibCfg, calibMetrics)
	calibrator.Knobs = live // live ratio/window/min-sample/maturation/demotion
	calibTuner := calibration.NewIntakeTuner(pool, q, calibCfg.IntakeTightenK)
	calibTuner.KFn = live.CalibrationIntakeTightenK // live intake tightening
	slog.Info("calibration",
		"maturation", calibCfg.Maturation,
		"window_n", calibCfg.WindowN,
		"ratio", calibCfg.Ratio,
		"min_sample", calibCfg.MinSample,
		"demotion_decrement", calibCfg.DemotionDecrement,
		"sweep_cron", calibCfg.SweepCron,
		"intake_tighten_k", calibCfg.IntakeTightenK,
	)

	// 4. Static auth password + push selector.
	if password := cfg.Auth.Password; password != "" {
		auth.Password.Set(password)
		slog.Info("auth password configured", "password_source", "config(auth.password)")
	} else {
		slog.Warn("auth.password not set — device pairing disabled this boot")
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
	durable.RegisterChainWorkflow(dctx, pool, q, chain.HumanOnlyRouter{}, nil, ownerURI, pushAdapter)
	durable.RegisterPushQueue(dctx)
	durable.RegisterToolCallWorkflow(dctx, pool, q, toolRegistry, calibrator)

	// 5b. Phase 7 intake edge: connector registry + disposition router +
	// per-connector poll workflow. Registered before Launch so recovery and
	// the dynamic-schedule reconciler find the function.
	intakeWiring := buildIntakeWiring(pool, q, dctx, cfg)
	// Phase 8: the disposer tightens effective thresholds + reads dismissal
	// history from the calibration tuner.
	intakeWiring.disposer.Tuner = calibTuner
	intake.RegisterPoll(dctx, pool, q, intakeWiring.registry, intakeWiring.disposer, intakeWiring.credStore, intakeWiring.refresher)

	// 5b'. Phase 8 calibration sweep workflow (single schedule). Registered
	// before Launch so recovery + the schedule reconciler find the function.
	calibration.RegisterSweep(dctx, pool, q, calibrator, calibMetrics, pushAdapter, ownerURI)

	if err := durable.Launch(dctx); err != nil {
		return fmt.Errorf("dbos launch: %w", err)
	}
	slog.Info("dbos launched (recovery, if any, completed)")

	// 5c. Rehydrate a schedule for every enabled connector (after Launch so the
	// reconciler is running). Crash-safe by construction — schedules are
	// DB-backed and recovered, this just ensures each enabled connector has one.
	if err := intake.RehydrateSchedules(ctx, dctx); err != nil {
		slog.Error("intake: schedule rehydration failed", "err", err)
	}

	// 5d. Phase 8 calibration sweep schedule (DB-backed, crash-recovered). Idempotent.
	if err := calibration.CreateSchedule(dctx, calibCfg.SweepCron); err != nil {
		slog.Error("calibration: sweep schedule creation failed", "err", err)
	}

	// 6. LISTEN dispatcher.
	disp, err := realtime.New(ctx, pool, q, nil)
	if err != nil {
		return fmt.Errorf("realtime dispatcher: %w", err)
	}
	go disp.Run(ctx)
	defer disp.Stop(context.Background())

	// 6b. Phase 4 overseer gateway. Provider selected at boot from env
	// (TENDANT_OVERSEER_PROVIDER). LogProvider is the deterministic default
	// — CI uses it; production opts in to anthropic/openai. Anthropic /
	// OpenAI provider construction lands in US4.
	llmRegistry := buildLLMRegistry(cfg)
	overseerProvider, overseerModelID := buildOverseerProvider(cfg, llmRegistry)
	if overseerModelID == "" {
		overseerModelID = "log"
	}
	maxEvalPerTask := overlay.IntOr("overseer.max_eval_per_task", cfg.Overseer.MaxEvalPerTask)
	if maxEvalPerTask <= 0 {
		maxEvalPerTask = overseer.DefaultMaxEvalPerTask
	}
	gateway := overseer.NewGateway(overseerProvider, q, maxEvalPerTask, overseerModelID)
	gateway.MaxEvalFn = live.OverseerMaxEvalPerTask // live per-task eval cap
	slog.Info("overseer.gateway",
		"provider", overseerProvider.Name(),
		"model_id", overseerModelID,
		"max_eval_per_task", maxEvalPerTask,
	)

	// 6c. Phase 5 gate-script Layer-3 evaluator. The runner is WazeroRunner in
	// production and LogRunner in CI/tests (TENDANT_GATESCRIPT_RUNNER). The
	// Service projects the owner's data into the six read-only host functions.
	ceilings := ceilingsFromConfig(cfg)
	var scriptRunner gatescript.Runner
	switch cfg.Gatescript.Runner {
	case "log":
		scriptRunner = gatescript.NewLogRunner()
	default:
		wr, werr := gatescript.NewWazeroRunner(ctx, ceilings)
		if werr != nil {
			return fmt.Errorf("gatescript wazero runner: %w", werr)
		}
		defer wr.Close(context.Background())
		scriptRunner = wr
	}
	scriptSvc := gatescript.NewService(scriptRunner, q, ceilings, ownerURI)
	scriptRunnerKind := cfg.Gatescript.Runner
	if scriptRunnerKind == "" {
		scriptRunnerKind = "wazero"
	}
	slog.Info("gatescript.service", "runner", scriptRunnerKind,
		"max_module_bytes", ceilings.MaxModuleBytes,
		"max_timeout_ms", ceilings.MaxTimeoutMs,
		"max_memory_pages", ceilings.MaxMemoryPages,
	)

	// Tier-1 server-compile backend. Default: COMPILE_FAILED (the sandboxed
	// asc-on-wazero backend is pending vendored binaries). An operator may
	// opt into the non-sandboxed subprocess backend (gatescript.asc_backend=
	// subprocess) when `asc` is on PATH — e.g. in the devenv shell.
	if cfg.Gatescript.ASCBackend == "subprocess" {
		if comp, cerr := gatescript.NewSubprocessASCCompiler(); cerr == nil {
			gatescript.SetASCCompiler(comp.Compile)
			slog.Warn("gatescript.asc: subprocess backend active (compiler NOT sandboxed) — see internal/gatescript/asc.go")
		} else {
			slog.Warn("gatescript.asc: subprocess backend requested but `asc` not found on PATH; Tier-1 server compile stays disabled")
		}
	}

	// 7. Operator-edge auth registry assertion.
	graph.RegisterOperatorEdgeAuth(auth.DefaultRegistry)
	auth.DefaultRegistry.AssertCovers(graph.OperatorEdgeRequiredFields())

	// 8. HTTP server.
	httpServer := &http.Server{
		Addr: cfg.Server.HTTPAddr,
		Handler: server.New(pool, dctx, server.Options{
			Dispatcher:        disp,
			PushSelector:      pushSel,
			PushQueue:         durable.PushQueueName,
			Password:          auth.Password,
			Overseer:          gateway,
			ToolRegistry:      toolRegistry,
			GateScript:        scriptSvc,
			WebhookIngress:    webhookIngressHandler(intakeWiring.inbound),
			OAuthCallback:     oauthCallbackHandler(intakeWiring.credStore, cfg),
			ConnectorResolver: intakeWiring.connectorResolverDeps(),
			IntakeRate:        intakeWiring.metrics,
			Calibrator:        calibrator,
			CalibrationRate:   calibMetrics,
			ConfigOverlay:     overlay,
			ConfigSnapshot:    cfg,
		}),
		ReadHeaderTimeout: 10 * time.Second,
	}

	serverErr := make(chan error, 1)
	go func() {
		slog.Info("listening", "addr", cfg.Server.HTTPAddr)
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

// ceilingsFromConfig maps the resolved config into the gatescript ceilings.
func ceilingsFromConfig(cfg *config.Config) gatescript.Ceilings {
	g := cfg.Gatescript
	return gatescript.Ceilings{
		MaxModuleBytes:        g.MaxModuleBytes,
		MaxTimeoutMs:          g.MaxTimeoutMs,
		MaxMemoryPages:        g.MaxMemoryPages,
		CalendarMaxWindowDays: g.CalendarMaxWindowDays,
		CompileCacheMB:        g.CompileCacheMB,
		ASCMaxCompileMs:       g.ASCMaxCompileMs,
		ASCMaxMemoryPages:     g.ASCMaxMemoryPages,
	}
}

// calibrationConfigFrom maps the resolved config into the Phase-8 calibration
// Config. The DB overlay wins for the db_configurable hot knobs (so an admin
// override applies from this boot), else the env/file/default snapshot value.
func calibrationConfigFrom(cfg *config.Config, ov *config.Overlay) calibration.Config {
	c := cfg.Calibration
	return calibration.Config{
		Maturation:        c.Maturation,
		WindowN:           c.WindowN,
		Ratio:             ov.Float64Or("calibration.ratio", c.Ratio),
		MinSample:         ov.IntOr("calibration.min_sample", c.MinSample),
		DemotionDecrement: ov.Float64Or("calibration.demotion_decrement", c.DemotionDecrement),
		SweepCron:         c.SweepCron,
		IntakeTightenK:    ov.Float64Or("calibration.intake_tighten_k", c.IntakeTightenK),
	}
}

// buildOverseerProvider selects the active overseer Provider from config at
// boot, returning the provider and its model id (for audit + cost lookups). The
// choice is intentionally NOT addressable at runtime — agents cannot reroute
// inference. Precedence: a named [[llm_connections]] entry (overseer.connection)
// wins; otherwise the legacy overseer.provider switch applies. Empty / "log" /
// any failure → deterministic LogProvider (CI default + production fallback if
// real-provider creds are missing).
func buildOverseerProvider(cfg *config.Config, reg *llm.Registry) (overseer.Provider, string) {
	if name := cfg.Overseer.Connection; name != "" {
		client, ok := reg.Get(name)
		if !ok {
			slog.Error("overseer: connection not found in llm_connections; falling back to LogProvider", "connection", name)
			return overseer.NewLogProvider(), "log"
		}
		slog.Info("overseer: using llm connection", "connection", name, "provider", client.Provider(), "model", client.Model())
		return overseer.NewLLMProvider(client.Provider(), client), client.Model()
	}

	switch cfg.Overseer.Provider {
	case "anthropic":
		p, err := overseer.NewAnthropicProvider(overseer.AnthropicConfig{
			APIKey:  cfg.Overseer.Anthropic.APIKey,
			BaseURL: cfg.Overseer.Anthropic.BaseURL,
			ModelID: cfg.Overseer.ModelID,
		})
		if err != nil {
			slog.Error("overseer: anthropic provider construction failed; falling back to LogProvider", "err", err)
			return overseer.NewLogProvider(), "log"
		}
		return p, cfg.Overseer.ModelID
	case "openai":
		p, err := overseer.NewOpenAIProvider(overseer.OpenAIConfig{
			APIKey:  cfg.Overseer.OpenAI.APIKey,
			BaseURL: cfg.Overseer.OpenAI.BaseURL,
			ModelID: cfg.Overseer.ModelID,
		})
		if err != nil {
			slog.Error("overseer: openai provider construction failed; falling back to LogProvider", "err", err)
			return overseer.NewLogProvider(), "log"
		}
		return p, cfg.Overseer.ModelID
	default:
		return overseer.NewLogProvider(), "log"
	}
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
	configPath := fs.String("config", "", "path to tendant.toml (else standard search paths)")
	if err := fs.Parse(args); err != nil {
		return err
	}

	cfg, err := config.Load(*configPath)
	if err != nil {
		return fmt.Errorf("load config: %w", err)
	}
	ctx := context.Background()
	pool, err := server.OpenPool(ctx, cfg.Database.URL)
	if err != nil {
		return fmt.Errorf("open pool: %w", err)
	}
	defer pool.Close()

	if err := db.Migrate(ctx, cfg.Database.URL); err != nil {
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
