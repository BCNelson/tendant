package mcp

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/crypto"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// CredentialStore seals/opens an mcp.Auth for a server through the crypto seam,
// persisting it in mcp_server_credentials (AES-256-GCM at rest). It mirrors
// intake.SealedCredentialStore. A nil store (TENDANT_CREDENTIALS_KEY unset)
// means servers can still be registered + synced with no auth, but auth'd
// servers surface the gap rather than crashing boot.
type CredentialStore struct {
	q      *db.Queries
	sealer *crypto.Sealer
}

// NewCredentialStore builds a store over the given queries + sealer.
func NewCredentialStore(q *db.Queries, sealer *crypto.Sealer) *CredentialStore {
	return &CredentialStore{q: q, sealer: sealer}
}

// Upsert seals and stores the auth for a server. An empty auth deletes any
// stored credential (the server becomes unauthenticated).
func (s *CredentialStore) Upsert(ctx context.Context, serverID uuid.UUID, auth Auth) error {
	if auth.Header == "" && auth.Value == "" {
		return s.q.DeleteMcpServerCredential(ctx, serverID)
	}
	plain, err := json.Marshal(auth)
	if err != nil {
		return fmt.Errorf("marshal auth: %w", err)
	}
	sealed, err := s.sealer.Seal(plain)
	if err != nil {
		return fmt.Errorf("seal auth: %w", err)
	}
	return s.q.UpsertMcpServerCredential(ctx, db.UpsertMcpServerCredentialParams{
		McpServerID: serverID,
		Encrypted:   sealed,
	})
}

// Open returns the decrypted auth for a server, or a zero Auth when none is
// stored (an unauthenticated server).
func (s *CredentialStore) Open(ctx context.Context, serverID uuid.UUID) (Auth, error) {
	row, err := s.q.GetMcpServerCredential(ctx, serverID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Auth{}, nil
		}
		return Auth{}, err
	}
	plain, err := s.sealer.Open(row.Encrypted)
	if err != nil {
		return Auth{}, fmt.Errorf("open auth: %w", err)
	}
	var auth Auth
	if err := json.Unmarshal(plain, &auth); err != nil {
		return Auth{}, fmt.Errorf("unmarshal auth: %w", err)
	}
	return auth, nil
}
