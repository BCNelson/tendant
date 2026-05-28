package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ErrUnauthorized is the sentinel returned by Resolve when a bearer does not
// match any active session.
var ErrUnauthorized = errors.New("unauthorized")

// MintToken returns a fresh random session bearer: 32 bytes of crypto/rand
// encoded as base64-RawURL (no padding). 43 characters on the wire.
func MintToken() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic("auth: crypto/rand failed: " + err.Error())
	}
	return base64.RawURLEncoding.EncodeToString(b)
}

// HashToken returns sha256(raw); the bytes are what we store in
// sessions.token_hash (never the raw token).
func HashToken(raw string) []byte {
	h := sha256.Sum256([]byte(raw))
	return h[:]
}

// IssueSession persists a freshly minted session for principalID and returns
// (row, rawToken, err). The raw token is returned exactly once — the caller's
// only chance to surface it to the client.
func IssueSession(ctx context.Context, q *db.Queries, principalID uuid.UUID, displayName string) (db.Session, string, error) {
	raw := MintToken()
	row, err := q.IssueSession(ctx, db.IssueSessionParams{
		PrincipalID: principalID,
		TokenHash:   HashToken(raw),
		DisplayName: displayName,
	})
	if err != nil {
		return db.Session{}, "", fmt.Errorf("issue session: %w", err)
	}
	return row, raw, nil
}

// RevokeSession sets revoked_at on the row. Returns pgx.ErrNoRows if the
// session was already revoked or never existed.
func RevokeSession(ctx context.Context, q *db.Queries, sessionID uuid.UUID) (db.Session, error) {
	return q.RevokeSession(ctx, sessionID)
}

// Resolve looks up the bearer, returns the matching Principal + Session, or
// ErrUnauthorized for any miss / revoked / mismatch case. Single hot path
// consulted by the HTTP middleware and the WS InitFunc.
func Resolve(ctx context.Context, q *db.Queries, raw string) (*Principal, *db.Session, error) {
	if raw == "" {
		return nil, nil, ErrUnauthorized
	}
	session, err := q.FindSessionByTokenHash(ctx, HashToken(raw))
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil, ErrUnauthorized
		}
		return nil, nil, fmt.Errorf("find session: %w", err)
	}
	row, err := q.GetPrincipalByID(ctx, session.PrincipalID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil, ErrUnauthorized
		}
		return nil, nil, fmt.Errorf("get principal: %w", err)
	}
	p := &Principal{
		ID:          row.ID,
		GlobalURI:   row.GlobalUri,
		DisplayName: row.DisplayName,
		Kind:        row.Kind,
	}
	return p, &session, nil
}
