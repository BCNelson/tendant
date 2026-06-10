// Package embedding is tendant's generic, swappable vector-embedding subsystem.
// It embeds source data (task categories first; tasks/messages later) into a
// single `embeddings` table with two unconstrained `vector` slot columns
// (blue/green). A model swap reindexes into the idle slot and atomically flips
// it live, so the embedding model is changeable at runtime with no schema
// migration — even across dimensions. The first consumer is triage, which
// embeds the task input and injects only the top-K nearest categories.
//
// Layering mirrors internal/llm + internal/push: a stdlib-only HTTP Embedder
// seam, a Store over the DB, a DBOS reindex workflow, and a Matcher the agent
// layer consumes through a narrow interface.
package embedding

import (
	"context"
	"errors"
	"strings"
)

// ErrTransient marks an embedder error a caller should treat as a transient
// outage (network, 5xx, timeout, malformed body) rather than a structural fault.
// Callers fail open to the full-taxonomy fallback on any embed error.
var ErrTransient = errors.New("embedding: transient provider error")

// Embedder is one configured connection to an embeddings API. Implementations
// are safe for concurrent use.
type Embedder interface {
	// Embed returns one vector per input text, in input order.
	Embed(ctx context.Context, texts []string) ([][]float32, error)
	// Provider is the canonical protocol name ("openai") written into the
	// version registry and audit.
	Provider() string
	// Model is the embedding model identifier.
	Model() string
	// Dimension is the expected vector length from config (0 if unspecified).
	// The actual length is taken from the first response and recorded per
	// version; this is only used for validation/logging.
	Dimension() int
}

// Config is the resolved [embedding] configuration.
type Config struct {
	Provider  string
	Model     string
	BaseURL   string
	APIKey    string
	Dimension int
}

// NewEmbedder builds an Embedder from config, or returns nil when embedding is
// disabled (empty/"log" provider). A nil Embedder means the whole subsystem is
// off and triage uses the full-taxonomy fallback.
func NewEmbedder(cfg Config) Embedder {
	switch strings.ToLower(strings.TrimSpace(cfg.Provider)) {
	case "", "log", "none", "off":
		return nil
	case "openai", "openai-compatible", "ollama", "azure", "openrouter":
		return newOpenAIEmbedder(cfg)
	default:
		// Unknown provider: treat as OpenAI-compatible (operator points BaseURL).
		return newOpenAIEmbedder(cfg)
	}
}
