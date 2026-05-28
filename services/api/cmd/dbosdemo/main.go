// Command dbosdemo is the throwaway DBOS crash-recovery proof (FR-013 / SC-004).
//
// It runs a single workflow `demo-1`:
//
//	step "checkpoint A" (logs once)  →  durable Sleep(60s)  →  log "resumed"
//
// kill -9 the binary mid-sleep, then restart. The second run must NOT re-log
// "checkpoint A executed" (the step is memoized) and MUST log "resumed past
// the block" once the sleep finishes.
package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"

	"github.com/bcnelson/tendant/services/api/internal/durable"
	"github.com/bcnelson/tendant/services/api/internal/server"
)

// demoExecutorID pins DBOS executor identity across restarts so recovery
// finds the prior run's PENDING workflow.
const demoExecutorID = "demo"

// demoWorkflowID is the stable workflow identity for the recovery proof.
const demoWorkflowID = "demo-1"

// demoSleep is the durable sleep duration — long enough to outlast a kill -9
// landed within the first few seconds, short enough to make the test runnable.
const demoSleep = 60 * time.Second

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)
	if err := run(); err != nil {
		slog.Error("dbosdemo failed", "err", err)
		os.Exit(1)
	}
}

func demoWorkflow(ctx dbos.DBOSContext, _ string) (string, error) {
	if _, err := dbos.RunAsStep(ctx, func(_ context.Context) (string, error) {
		slog.Info("checkpoint A executed")
		return "A", nil
	}, dbos.WithStepName("checkpoint-A")); err != nil {
		return "", fmt.Errorf("step A: %w", err)
	}
	if _, err := dbos.Sleep(ctx, demoSleep); err != nil {
		return "", fmt.Errorf("durable sleep: %w", err)
	}
	slog.Info("resumed past the block")
	return "done", nil
}

func run() error {
	ctx := context.Background()
	cfg := server.LoadConfig()
	pool, err := server.OpenPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return fmt.Errorf("open pool: %w", err)
	}
	defer pool.Close()

	dctx, err := durable.Init(ctx, pool, demoExecutorID)
	if err != nil {
		return fmt.Errorf("dbos init: %w", err)
	}
	defer durable.Shutdown(dctx, 5*time.Second)

	dbos.RegisterWorkflow(dctx, demoWorkflow, dbos.WithWorkflowName("dbosdemo.demo"))
	if err := durable.Launch(dctx); err != nil {
		return fmt.Errorf("dbos launch: %w", err)
	}
	slog.Info("dbos launched (recovery, if any, completed)")

	handle, err := dbos.RunWorkflow(dctx, demoWorkflow, "",
		dbos.WithWorkflowID(demoWorkflowID))
	if err != nil {
		return fmt.Errorf("run workflow: %w", err)
	}
	res, err := handle.GetResult()
	if err != nil {
		return fmt.Errorf("workflow result: %w", err)
	}
	slog.Info("workflow finished", "result", res)
	return nil
}
