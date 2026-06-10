package embedding

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"log/slog"
	"strconv"
	"sync"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ReindexWorkflowName is the DBOS workflow name for an embedding reindex. Stable
// across restarts so crash recovery finds the function.
const ReindexWorkflowName = "tendant.embedding.reindex"

// embeddingBatchSize bounds how many texts are embedded per provider call/step.
const embeddingBatchSize = 64

// reindexDeps closes over the reindex job's runtime dependencies, set once by
// RegisterReindex at boot (mirrors calibration.RegisterSweep / intake.RegisterPoll).
type reindexDeps struct {
	pool     *pgxpool.Pool
	store    *Store
	embedder Embedder
	sources  *SourceRegistry
}

var (
	reindexMu          sync.RWMutex
	currentReindexDeps *reindexDeps
)

// RegisterReindex stores the reindex deps and registers ReindexWorkflow with
// DBOS. MUST be called between dbos.NewDBOSContext and dbos.Launch.
func RegisterReindex(dctx dbos.DBOSContext, store *Store, embedder Embedder, sources *SourceRegistry) {
	reindexMu.Lock()
	currentReindexDeps = &reindexDeps{pool: store.Pool(), store: store, embedder: embedder, sources: sources}
	reindexMu.Unlock()
	dbos.RegisterWorkflow(dctx, ReindexWorkflow, dbos.WithWorkflowName(ReindexWorkflowName))
}

func loadReindexDeps() (*reindexDeps, error) {
	reindexMu.RLock()
	d := currentReindexDeps
	reindexMu.RUnlock()
	if d == nil {
		return nil, errors.New("embedding.RegisterReindex was not called before a reindex ran")
	}
	return d, nil
}

// ConfigHash identifies an embedding configuration for change-detection.
func ConfigHash(cfg Config) string {
	h := sha256.Sum256([]byte(cfg.Provider + "|" + cfg.Model + "|" + strconv.Itoa(cfg.Dimension) + "|" + cfg.BaseURL))
	return hex.EncodeToString(h[:8])
}

func reindexWorkflowID(version int) string { return "embreindex:v" + strconv.Itoa(version) }

type reindexItem struct {
	SourceType string    `json:"source_type"`
	ID         uuid.UUID `json:"id"`
	Text       string    `json:"text"`
}

type prepResult struct {
	OK    bool          `json:"ok"`
	Slot  string        `json:"slot"`
	Items []reindexItem `json:"items"`
}

// ReindexWorkflow rebuilds the target version's idle slot and atomically flips
// it live. Crash-safe via DBOS steps; the flip re-checks the version is still
// 'building' (abandoning a superseded build), so a late finish can never
// overwrite a newer active version.
func ReindexWorkflow(ctx dbos.DBOSContext, version int) (any, error) {
	d, err := loadReindexDeps()
	if err != nil {
		return nil, err
	}

	// Step 1: confirm still building, drop the idle index, gather items.
	prep, err := dbos.RunAsStep(ctx, func(sctx context.Context) (prepResult, error) {
		v, err := d.store.Queries().GetEmbeddingVersion(sctx, int32(version))
		if err != nil {
			return prepResult{}, fmt.Errorf("load version %d: %w", version, err)
		}
		if v.Status != "building" {
			slog.InfoContext(sctx, "embedding.reindex superseded before start", "version", version, "status", v.Status)
			return prepResult{OK: false}, nil
		}
		if err := d.store.DropSlotIndex(sctx, v.Slot); err != nil {
			return prepResult{}, fmt.Errorf("drop idle index: %w", err)
		}
		var items []reindexItem
		for _, src := range d.sources.Sources() {
			rows, err := src.List(sctx)
			if err != nil {
				return prepResult{}, fmt.Errorf("list source %s: %w", src.Type(), err)
			}
			for _, it := range rows {
				items = append(items, reindexItem{SourceType: src.Type(), ID: it.ID, Text: it.Text})
			}
		}
		return prepResult{OK: true, Slot: v.Slot, Items: items}, nil
	}, dbos.WithStepName("embedding.reindex.prepare"))
	if err != nil {
		return nil, err
	}
	if !prep.OK {
		return nil, nil // superseded/cancelled — abandon quietly
	}

	// Step 2..n: embed + upsert each batch (network calls live in steps).
	dim := 0
	for i := 0; i < len(prep.Items); i += embeddingBatchSize {
		end := min(i+embeddingBatchSize, len(prep.Items))
		batch := prep.Items[i:end]
		batchDim, err := dbos.RunAsStep(ctx, func(sctx context.Context) (int, error) {
			texts := make([]string, len(batch))
			for j, it := range batch {
				texts[j] = it.Text
			}
			vecs, err := d.embedder.Embed(sctx, texts)
			if err != nil {
				return 0, fmt.Errorf("embed batch: %w", err)
			}
			if len(vecs) != len(batch) {
				return 0, fmt.Errorf("embed batch: got %d vectors for %d texts", len(vecs), len(batch))
			}
			for j, it := range batch {
				if err := d.store.Upsert(sctx, prep.Slot, it.SourceType, it.ID, it.Text, HashText(it.Text), vecs[j]); err != nil {
					return 0, fmt.Errorf("upsert %s/%s: %w", it.SourceType, it.ID, err)
				}
			}
			return len(vecs[0]), nil
		}, dbos.WithStepName(fmt.Sprintf("embedding.reindex.batch.%d", i/embeddingBatchSize)))
		if err != nil {
			return nil, err
		}
		if batchDim > 0 {
			dim = batchDim
		}
	}

	// Step: record the actual dimension and build the slot's expression index.
	if dim > 0 {
		_, err = dbos.RunAsStep(ctx, func(sctx context.Context) (struct{}, error) {
			if err := d.store.Queries().SetEmbeddingVersionDimension(sctx, db.SetEmbeddingVersionDimensionParams{
				Dimension: int32(dim), Version: int32(version),
			}); err != nil {
				return struct{}{}, fmt.Errorf("set dimension: %w", err)
			}
			if err := d.store.BuildSlotIndex(sctx, prep.Slot, dim); err != nil {
				return struct{}{}, fmt.Errorf("build index: %w", err)
			}
			return struct{}{}, nil
		}, dbos.WithStepName("embedding.reindex.build_index"))
		if err != nil {
			return nil, err
		}
	}

	// Step: atomic flip — only if still building.
	flipped, err := dbos.RunAsStep(ctx, func(sctx context.Context) (bool, error) {
		return d.flip(sctx, version)
	}, dbos.WithStepName("embedding.reindex.flip"))
	if err != nil {
		return nil, err
	}
	slog.InfoContext(context.Background(), "embedding.reindex done", "version", version, "slot", prep.Slot, "dim", dim, "items", len(prep.Items), "flipped", flipped)
	return nil, nil
}

// flip activates `version` iff it is still 'building', retiring + clearing the
// prior active slot. Returns false (abandon) if the version was superseded.
func (d *reindexDeps) flip(ctx context.Context, version int) (bool, error) {
	var flipped bool
	err := pgx.BeginFunc(ctx, d.pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		if err := q.AcquireEmbeddingTransitionLock(ctx); err != nil {
			return err
		}
		v, err := q.GetEmbeddingVersionForUpdate(ctx, int32(version))
		if err != nil {
			return err
		}
		if v.Status != "building" {
			return nil // superseded — abandon without flipping
		}
		oldActive, err := q.GetActiveEmbeddingVersion(ctx)
		hadActive := err == nil
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		if err := q.RetireActiveEmbeddingVersionExcept(ctx, int32(version)); err != nil {
			return err
		}
		if err := q.ActivateEmbeddingVersion(ctx, int32(version)); err != nil {
			return err
		}
		// Clear the retired slot's vectors (keeps schema at two slots).
		if hadActive && oldActive.Slot != v.Slot {
			if oldActive.Slot == SlotBlue {
				if err := q.ClearEmbeddingBlue(ctx); err != nil {
					return err
				}
			} else {
				if err := q.ClearEmbeddingGreen(ctx); err != nil {
					return err
				}
			}
		}
		flipped = true
		return nil
	})
	return flipped, err
}

// EnsureActiveVersion is the auto-trigger: when the configured embedding differs
// from the active version, it provisions a new 'building' version (on the idle
// slot) and starts a reindex. Serialized under a pg_advisory_xact_lock so the
// single-active / single-building invariants hold under rapid changes;
// last-writer-wins (a stale in-flight build is superseded + cancelled).
func EnsureActiveVersion(ctx context.Context, dctx dbos.DBOSContext, store *Store, cfg Config) error {
	hash := ConfigHash(cfg)
	provisionalDim := cfg.Dimension
	if provisionalDim <= 0 {
		provisionalDim = 1 // corrected to the actual length during reindex
	}

	var newVersion int
	var supersededWFID *string
	err := pgx.BeginFunc(ctx, store.Pool(), func(tx pgx.Tx) error {
		q := db.New(tx)
		if err := q.AcquireEmbeddingTransitionLock(ctx); err != nil {
			return err
		}

		active, errA := q.GetActiveEmbeddingVersion(ctx)
		hasActive := errA == nil
		if errA != nil && !errors.Is(errA, pgx.ErrNoRows) {
			return errA
		}
		building, errB := q.GetBuildingEmbeddingVersion(ctx)
		hasBuilding := errB == nil
		if errB != nil && !errors.Is(errB, pgx.ErrNoRows) {
			return errB
		}

		// Already building exactly this config → dedupe (absorbs rapid identical events).
		if hasBuilding && building.ConfigHash == hash {
			return nil
		}
		// A stale build is in flight → supersede + remember to cancel it.
		if hasBuilding {
			if err := q.SetEmbeddingVersionStatus(ctx, db.SetEmbeddingVersionStatusParams{Status: "superseded", Version: building.Version}); err != nil {
				return err
			}
			supersededWFID = building.WorkflowID
		}
		// Active already matches (e.g. a flip-back) → no new build needed.
		if hasActive && active.ConfigHash == hash {
			return nil
		}

		maxV, err := q.MaxEmbeddingVersion(ctx)
		if err != nil {
			return err
		}
		newVersion = int(maxV) + 1
		activeSlot := ""
		if hasActive {
			activeSlot = active.Slot
		}
		slot := IdleSlot(activeSlot)
		if _, err := q.InsertEmbeddingVersion(ctx, db.InsertEmbeddingVersionParams{
			Version:    int32(newVersion),
			Slot:       slot,
			Provider:   cfg.Provider,
			Model:      cfg.Model,
			Dimension:  int32(provisionalDim),
			ConfigHash: hash,
		}); err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return err
	}

	// Best-effort cancel of a superseded build (correctness rests on the flip
	// re-check, not on cancellation succeeding).
	if supersededWFID != nil && *supersededWFID != "" {
		if cerr := dbos.CancelWorkflow(dctx, *supersededWFID); cerr != nil {
			slog.WarnContext(ctx, "embedding.reindex cancel superseded build failed", "workflow_id", *supersededWFID, "err", cerr)
		}
	}

	if newVersion == 0 {
		return nil // no-op (dedupe / flip-back)
	}

	wfID := reindexWorkflowID(newVersion)
	if err := store.Queries().SetEmbeddingVersionWorkflowID(ctx, db.SetEmbeddingVersionWorkflowIDParams{
		WorkflowID: &wfID, Version: int32(newVersion),
	}); err != nil {
		return err
	}
	if _, err := dbos.RunWorkflow(dctx, ReindexWorkflow, newVersion, dbos.WithWorkflowID(wfID)); err != nil {
		return fmt.Errorf("start reindex workflow v%d: %w", newVersion, err)
	}
	return nil
}
