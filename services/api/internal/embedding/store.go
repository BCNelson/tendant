package embedding

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pgvector/pgvector-go"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Slot identifies one of the two fixed vector columns. At any time one slot is
// active (serving queries) and the other idle (the rebuild target).
const (
	SlotBlue  = "blue"
	SlotGreen = "green"
)

const maxDimension = 16000 // pgvector's storage ceiling for `vector`

// Match is one nearest-neighbour result.
type Match struct {
	ID       uuid.UUID
	Text     string
	Distance float64
}

// Store is the data layer for the embedding subsystem: sqlc for the registry +
// dimension-agnostic writes, hand-written pgx for the KNN search and the dynamic
// per-slot index DDL.
type Store struct {
	pool *pgxpool.Pool
	q    *db.Queries
}

// NewStore builds a Store over a pgx pool.
func NewStore(pool *pgxpool.Pool) *Store {
	return &Store{pool: pool, q: db.New(pool)}
}

// Pool exposes the pool for transactional callers (the reindex transitions).
func (s *Store) Pool() *pgxpool.Pool { return s.pool }

// Queries exposes the sqlc queries bound to the pool.
func (s *Store) Queries() *db.Queries { return s.q }

func validateSlot(slot string) error {
	if slot != SlotBlue && slot != SlotGreen {
		return fmt.Errorf("embedding: invalid slot %q", slot)
	}
	return nil
}

func validateDim(dim int) error {
	if dim <= 0 || dim > maxDimension {
		return fmt.Errorf("embedding: invalid dimension %d", dim)
	}
	return nil
}

// IdleSlot returns the slot the active version is not using (blue when none).
func IdleSlot(activeSlot string) string {
	if activeSlot == SlotBlue {
		return SlotGreen
	}
	return SlotBlue
}

// HashText is the content_hash of the embedded text (skip-recompute key).
func HashText(text string) string {
	sum := sha256.Sum256([]byte(text))
	return hex.EncodeToString(sum[:])
}

// ActiveSlotDim returns the active version's slot + dimension, or ok=false when
// no version is active yet (caller falls back).
func (s *Store) ActiveSlotDim(ctx context.Context) (slot string, dim int, ok bool, err error) {
	v, err := s.q.GetActiveEmbeddingVersion(ctx)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", 0, false, nil
	}
	if err != nil {
		return "", 0, false, err
	}
	return v.Slot, int(v.Dimension), true, nil
}

// Upsert writes one row's metadata + the slot's vector (dimension-agnostic sqlc).
func (s *Store) Upsert(ctx context.Context, slot, sourceType string, id uuid.UUID, text, hash string, vec []float32) error {
	if err := validateSlot(slot); err != nil {
		return err
	}
	v := pgvector.NewVector(vec)
	switch slot {
	case SlotBlue:
		return s.q.UpsertEmbeddingBlue(ctx, db.UpsertEmbeddingBlueParams{
			SourceType: sourceType, SourceID: id, SourceText: text, ContentHash: hash, Embedding: &v,
		})
	default:
		return s.q.UpsertEmbeddingGreen(ctx, db.UpsertEmbeddingGreenParams{
			SourceType: sourceType, SourceID: id, SourceText: text, ContentHash: hash, Embedding: &v,
		})
	}
}

// ClearSlot NULLs a slot's column (frees the retired slot after a flip).
func (s *Store) ClearSlot(ctx context.Context, slot string) error {
	if err := validateSlot(slot); err != nil {
		return err
	}
	if slot == SlotBlue {
		return s.q.ClearEmbeddingBlue(ctx)
	}
	return s.q.ClearEmbeddingGreen(ctx)
}

// CountEmbedded reports how many rows of a source_type have a non-NULL vector in
// the slot (the "all re-embedded?" tracker).
func (s *Store) CountEmbedded(ctx context.Context, slot, sourceType string) (int64, error) {
	if err := validateSlot(slot); err != nil {
		return 0, err
	}
	if slot == SlotBlue {
		return s.q.CountEmbeddedBlue(ctx, sourceType)
	}
	return s.q.CountEmbeddedGreen(ctx, sourceType)
}

// ContentHash returns the stored content_hash for a row (ok=false if absent).
func (s *Store) ContentHash(ctx context.Context, sourceType string, id uuid.UUID) (string, bool, error) {
	h, err := s.q.GetEmbeddingContentHash(ctx, db.GetEmbeddingContentHashParams{SourceType: sourceType, SourceID: id})
	if errors.Is(err, pgx.ErrNoRows) {
		return "", false, nil
	}
	if err != nil {
		return "", false, err
	}
	return h, true, nil
}

// DropSlotIndex drops a slot's HNSW index (before a bulk reindex of that slot).
func (s *Store) DropSlotIndex(ctx context.Context, slot string) error {
	if err := validateSlot(slot); err != nil {
		return err
	}
	_, err := s.pool.Exec(ctx, fmt.Sprintf(`DROP INDEX IF EXISTS idx_embeddings_%s`, slot))
	return err
}

// BuildSlotIndex builds a slot's HNSW expression index at the given dimension
// (one-shot build after the idle slot is fully loaded). Idempotent.
func (s *Store) BuildSlotIndex(ctx context.Context, slot string, dim int) error {
	if err := validateSlot(slot); err != nil {
		return err
	}
	if err := validateDim(dim); err != nil {
		return err
	}
	stmt := fmt.Sprintf(
		`CREATE INDEX IF NOT EXISTS idx_embeddings_%s ON embeddings USING hnsw ((embedding_%s::vector(%d)) vector_cosine_ops)`,
		slot, slot, dim,
	)
	_, err := s.pool.Exec(ctx, stmt)
	return err
}

// TopK returns the k nearest rows of a source_type to queryVec, using the slot's
// expression index (hand-written: the ::vector(dim) cast carries the runtime
// dimension, which sqlc cannot parameterize).
func (s *Store) TopK(ctx context.Context, slot string, dim int, sourceType string, queryVec []float32, k int) ([]Match, error) {
	if err := validateSlot(slot); err != nil {
		return nil, err
	}
	if err := validateDim(dim); err != nil {
		return nil, err
	}
	col := "embedding_" + slot
	q := fmt.Sprintf(
		`SELECT source_id, source_text, %s::vector(%d) <=> $1::vector(%d) AS distance
		 FROM embeddings
		 WHERE source_type = $2 AND %s IS NOT NULL
		 ORDER BY %s::vector(%d) <=> $1::vector(%d)
		 LIMIT $3`,
		col, dim, dim, col, col, dim, dim,
	)
	rows, err := s.pool.Query(ctx, q, pgvector.NewVector(queryVec), sourceType, k)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Match
	for rows.Next() {
		var m Match
		if err := rows.Scan(&m.ID, &m.Text, &m.Distance); err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}
