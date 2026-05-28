package auth

import (
	"errors"
	"sync"
)

// ErrBadSetupSecret indicates the presented setup secret did not match the
// armed value.
var ErrBadSetupSecret = errors.New("bad setup secret")

// ErrAlreadyConsumed indicates the armed setup secret was consumed earlier
// during this process lifetime. A container restart re-arms the same value
// (research R6).
var ErrAlreadyConsumed = errors.New("setup secret already consumed")

// ErrNotArmed indicates the server booted without a setup secret in the
// environment — pairing is disabled until one is armed.
var ErrNotArmed = errors.New("setup secret not armed")

// SetupSecretState carries an in-process armed setup secret and tracks whether
// it has been consumed. Single-use per boot.
type SetupSecretState struct {
	mu       sync.Mutex
	armed    string
	consumed bool
}

// Arm sets the armed setup secret. Calling Arm a second time silently
// re-arms (used by tests). An empty value leaves the state un-armed.
func (s *SetupSecretState) Arm(secret string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.armed = secret
	s.consumed = false
}

// Consume validates the presented secret and marks the state consumed.
// Returns ErrBadSetupSecret on mismatch, ErrAlreadyConsumed if a previous
// Consume already succeeded this boot, ErrNotArmed if no value was armed.
func (s *SetupSecretState) Consume(presented string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.armed == "" {
		return ErrNotArmed
	}
	if s.consumed {
		return ErrAlreadyConsumed
	}
	if presented != s.armed {
		return ErrBadSetupSecret
	}
	s.consumed = true
	return nil
}

// IsArmed reports whether a setup secret is currently armed and unconsumed.
// Test-only helper.
func (s *SetupSecretState) IsArmed() bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.armed != "" && !s.consumed
}

// SetupSecret is the process-wide armed-secret state. Boot wiring calls
// SetupSecret.Arm(os.Getenv("TENDANT_SETUP_SECRET")); pairDevice calls Consume.
var SetupSecret = &SetupSecretState{}
