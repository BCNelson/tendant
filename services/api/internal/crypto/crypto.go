// Package crypto provides AES-256-GCM Seal/Open for app-level encryption of
// source credentials at rest (FR-009 / research §7). Phase 0 lands the seam
// with no callers; intake (Phase 7) is the first consumer.
//
// Key management: a single 32-byte key per box, supplied base64-encoded in
// TENDANT_CREDENTIALS_KEY. GCM nonce is random per Seal and prepended to the
// ciphertext.
package crypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"os"
)

// KeyEnvVar is the environment variable holding the base64-encoded 32-byte key.
const KeyEnvVar = "TENDANT_CREDENTIALS_KEY"

const (
	keySize   = 32 // AES-256
	nonceSize = 12 // AES-GCM standard
)

// Sealer wraps an AES-256-GCM AEAD ready to Seal/Open bytes.
type Sealer struct {
	aead cipher.AEAD
}

// NewFromEnv constructs a Sealer using the key in TENDANT_CREDENTIALS_KEY.
// Fail-closed: returns an error if the env var is unset, malformed, or the
// decoded key is not exactly 32 bytes.
func NewFromEnv() (*Sealer, error) {
	encoded := os.Getenv(KeyEnvVar)
	if encoded == "" {
		return nil, fmt.Errorf("%s is not set", KeyEnvVar)
	}
	key, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return nil, fmt.Errorf("decode %s: %w", KeyEnvVar, err)
	}
	return New(key)
}

// New constructs a Sealer from a raw 32-byte key.
func New(key []byte) (*Sealer, error) {
	if len(key) != keySize {
		return nil, fmt.Errorf("key must be %d bytes (got %d)", keySize, len(key))
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("aes cipher: %w", err)
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("aes-gcm: %w", err)
	}
	return &Sealer{aead: aead}, nil
}

// Seal returns nonce||ciphertext (nonce prepended) for the given plaintext.
func (s *Sealer) Seal(plaintext []byte) ([]byte, error) {
	nonce := make([]byte, nonceSize)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, fmt.Errorf("read nonce: %w", err)
	}
	// Seal appends to nonce, so the returned slice is nonce||ciphertext.
	return s.aead.Seal(nonce, nonce, plaintext, nil), nil
}

// ErrCiphertextTooShort is returned by Open when the input is smaller than a
// minimal nonce-prepended GCM payload.
var ErrCiphertextTooShort = errors.New("ciphertext too short")

// Open decrypts a nonce||ciphertext payload produced by Seal.
func (s *Sealer) Open(payload []byte) ([]byte, error) {
	if len(payload) < nonceSize {
		return nil, ErrCiphertextTooShort
	}
	nonce, ct := payload[:nonceSize], payload[nonceSize:]
	plaintext, err := s.aead.Open(nil, nonce, ct, nil)
	if err != nil {
		return nil, fmt.Errorf("aes-gcm open: %w", err)
	}
	return plaintext, nil
}
