package intake

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/crypto"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TokenBundle is the decrypted credential a connector uses to authenticate. It
// is sealed (AES-256-GCM, TENDANT_CREDENTIALS_KEY) as JSON into
// source_credentials.encrypted and never serialized over GraphQL (FR-019).
type TokenBundle struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token,omitempty"`
	Scopes       []string  `json:"scopes,omitempty"`
	TokenType    string    `json:"token_type,omitempty"`
	ExpiresAt    time.Time `json:"expires_at,omitempty"`
}

// refreshSkew is how close to expiry triggers a refresh.
const refreshSkew = 2 * time.Minute

// TokenRefresher exchanges a refresh token for a fresh bundle at the provider's
// token endpoint. Implemented per-connector (e.g. the gmail connector) over
// stdlib net/http; injected so credentials.go has no provider-specific code.
type TokenRefresher interface {
	Refresh(ctx context.Context, refreshToken string) (TokenBundle, error)
}

// SealedCredentialStore reads/writes source_credentials, sealing through the
// crypto seam. It backs the CredentialAccessor handed to a connector.
type SealedCredentialStore struct {
	q      *db.Queries
	sealer *crypto.Sealer
}

// NewSealedCredentialStore constructs a store over the given queries + sealer.
func NewSealedCredentialStore(q *db.Queries, sealer *crypto.Sealer) *SealedCredentialStore {
	return &SealedCredentialStore{q: q, sealer: sealer}
}

// Upsert seals and stores a token bundle for a connector (used by the OAuth
// callback after a code exchange).
func (s *SealedCredentialStore) Upsert(ctx context.Context, connectorID uuid.UUID, bundle TokenBundle) error {
	plain, err := json.Marshal(bundle)
	if err != nil {
		return fmt.Errorf("marshal token bundle: %w", err)
	}
	sealed, err := s.sealer.Seal(plain)
	if err != nil {
		return fmt.Errorf("seal token bundle: %w", err)
	}
	var expires pgtype.Timestamptz
	if !bundle.ExpiresAt.IsZero() {
		expires = pgtype.Timestamptz{Time: bundle.ExpiresAt, Valid: true}
	}
	return s.q.UpsertSourceCredential(ctx, db.UpsertSourceCredentialParams{
		ConnectorID: connectorID,
		Encrypted:   sealed,
		ExpiresAt:   expires,
	})
}

// open decrypts the stored bundle for a connector.
func (s *SealedCredentialStore) open(ctx context.Context, connectorID uuid.UUID) (TokenBundle, error) {
	row, err := s.q.GetSourceCredential(ctx, connectorID)
	if err != nil {
		return TokenBundle{}, err
	}
	plain, err := s.sealer.Open(row.Encrypted)
	if err != nil {
		return TokenBundle{}, fmt.Errorf("open credential: %w", err)
	}
	var bundle TokenBundle
	if err := json.Unmarshal(plain, &bundle); err != nil {
		return TokenBundle{}, fmt.Errorf("unmarshal token bundle: %w", err)
	}
	if !row.ExpiresAt.Valid {
		bundle.ExpiresAt = time.Time{}
	} else if bundle.ExpiresAt.IsZero() {
		bundle.ExpiresAt = row.ExpiresAt.Time
	}
	return bundle, nil
}

// Accessor returns a CredentialAccessor scoped to one connector, refreshing
// through the given refresher when the stored token is near expiry. A nil
// refresher means "no refresh" — the stored token is returned as-is.
func (s *SealedCredentialStore) Accessor(connectorID uuid.UUID, refresher TokenRefresher, now func() time.Time) CredentialAccessor {
	if now == nil {
		now = time.Now
	}
	return &sealedAccessor{store: s, connectorID: connectorID, refresher: refresher, now: now}
}

type sealedAccessor struct {
	store       *SealedCredentialStore
	connectorID uuid.UUID
	refresher   TokenRefresher
	now         func() time.Time
}

// Token returns the current access token, refreshing-and-re-sealing if the
// stored bundle is within refreshSkew of expiry and a refresher + refresh token
// are present.
func (a *sealedAccessor) Token(ctx context.Context) (TokenBundle, error) {
	bundle, err := a.store.open(ctx, a.connectorID)
	if err != nil {
		return TokenBundle{}, err
	}
	nearExpiry := !bundle.ExpiresAt.IsZero() && a.now().Add(refreshSkew).After(bundle.ExpiresAt)
	if nearExpiry && a.refresher != nil && bundle.RefreshToken != "" {
		refreshed, rerr := a.refresher.Refresh(ctx, bundle.RefreshToken)
		if rerr != nil {
			return TokenBundle{}, fmt.Errorf("refresh credential: %w", rerr)
		}
		if refreshed.RefreshToken == "" {
			refreshed.RefreshToken = bundle.RefreshToken // providers often omit it on refresh
		}
		if err := a.store.Upsert(ctx, a.connectorID, refreshed); err != nil {
			return TokenBundle{}, fmt.Errorf("re-seal refreshed credential: %w", err)
		}
		return refreshed, nil
	}
	return bundle, nil
}

// ErrNoCredentials is returned (wrapped) when a credentialed connector has no
// sealed bundle — it surfaces the gap to the owner rather than crashing a poll.
var ErrNoCredentials = pgx.ErrNoRows
