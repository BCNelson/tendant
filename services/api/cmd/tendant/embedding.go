package main

import (
	"context"
	"log/slog"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

// embeddingWiring bundles the embedding subsystem's runtime objects. embedder is
// nil (and matcher unset) when embedding is disabled — triage then falls back to
// the full category taxonomy.
type embeddingWiring struct {
	embedder embedding.Embedder
	store    *embedding.Store
	sources  *embedding.SourceRegistry
	matcher  agent.CategoryMatcher // nil ⇒ full-taxonomy fallback in triage
	topK     int
}

// embeddingConfig resolves the [embedding] config, reading the hot-reloadable
// dimension through the DB overlay (provider/model/base_url/api_key are
// boot-fixed, so they come from the boot snapshot).
func embeddingConfig(cfg *config.Config, ov *config.Overlay) embedding.Config {
	return embedding.Config{
		Provider:  cfg.Embedding.Provider,
		Model:     cfg.Embedding.Model,
		BaseURL:   cfg.Embedding.BaseURL,
		APIKey:    cfg.Embedding.APIKey,
		Dimension: ov.IntOr("embedding.dimension", cfg.Embedding.Dimension),
	}
}

// buildEmbedding constructs the embedding subsystem (embedder + store + sources
// + the triage matcher). A nil/"log" provider disables it.
func buildEmbedding(cfg *config.Config, pool *pgxpool.Pool, q *db.Queries, ov *config.Overlay) embeddingWiring {
	embCfg := embeddingConfig(cfg, ov)
	embedder := embedding.NewEmbedder(embCfg)
	store := embedding.NewStore(pool)
	sources := &embedding.SourceRegistry{}
	sources.Register(embedding.NewCategorySource(q))

	w := embeddingWiring{
		embedder: embedder,
		store:    store,
		sources:  sources,
		topK:     ov.IntOr("embedding.triage_top_k", cfg.Embedding.TriageTopK),
	}
	if m := embedding.NewMatcher(store, embedder, q); m != nil {
		w.matcher = categoryMatcherAdapter{m: m}
	}

	if embedder != nil {
		slog.Info("embedding.wiring", "provider", embedder.Provider(), "model", embedder.Model(), "dimension", embCfg.Dimension, "triage_top_k", w.topK)
	} else {
		slog.Info("embedding disabled (triage uses the full category taxonomy)")
	}
	return w
}

// categoryMatcherAdapter adapts embedding.Matcher to the agent.CategoryMatcher
// seam, keeping internal/agent free of any embedding dependency.
type categoryMatcherAdapter struct{ m *embedding.Matcher }

func (a categoryMatcherAdapter) TopCategories(ctx context.Context, taskText string, k int) ([]agent.CategoryMatch, error) {
	ms, err := a.m.TopCategories(ctx, taskText, k)
	if err != nil {
		return nil, err
	}
	out := make([]agent.CategoryMatch, 0, len(ms))
	for _, mm := range ms {
		out = append(out, agent.CategoryMatch{Key: mm.Key, Label: mm.Label})
	}
	return out, nil
}
