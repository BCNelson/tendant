package auth

import (
	"crypto/subtle"
	"errors"
	"sync"
)

// ErrBadPassword indicates the presented password did not match the configured
// value.
var ErrBadPassword = errors.New("bad password")

// ErrNoPassword indicates the server booted without an auth password in the
// environment/config — device pairing is disabled until one is set.
var ErrNoPassword = errors.New("auth password not configured")

// PasswordState carries the process-wide static auth password. Unlike the
// former one-time setup secret, it is reusable: any device that presents the
// configured password may pair (and is then issued its own revocable session
// token). The password is operator-set via TENDANT_PASSWORD / [auth] password.
type PasswordState struct {
	mu  sync.RWMutex
	set string
}

// Set installs the static password. An empty value leaves pairing disabled.
// Safe to call again (e.g. config reload) to rotate the value.
func (s *PasswordState) Set(password string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.set = password
}

// Verify checks the presented password against the configured value using a
// constant-time compare. Returns ErrNoPassword if none is configured and
// ErrBadPassword on mismatch. Verify never consumes the password — it may
// succeed any number of times.
func (s *PasswordState) Verify(presented string) error {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if s.set == "" {
		return ErrNoPassword
	}
	if subtle.ConstantTimeCompare([]byte(presented), []byte(s.set)) != 1 {
		return ErrBadPassword
	}
	return nil
}

// IsConfigured reports whether a password is currently set.
func (s *PasswordState) IsConfigured() bool {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.set != ""
}

// Password is the process-wide static-password state. Boot wiring calls
// Password.Set(cfg.Auth.Password); pairDevice calls Verify.
var Password = &PasswordState{}
