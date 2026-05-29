package overseer

import (
	"encoding/json"
	"errors"
	"fmt"
)

// ErrInvalidPermissions is the validator's sentinel; resolvers map it to a
// GraphQL error code of "INVALID_PERMISSIONS".
var ErrInvalidPermissions = errors.New("overseer: invalid permissions")

// validIrreversibleModes mirrors the floor's reader (internal/gate/floor.go).
// Adding a new mode here is the second step of adding a new floor clause;
// keep these two lists in lockstep so the validator and the runtime can
// never disagree.
var validIrreversibleModes = map[string]struct{}{
	"never":              {},
	"always":             {},
	"stranger_recipient": {},
}

// validPermissionKeys is the closed set of top-level keys the validator
// accepts. Unknown keys are an error (so a typo doesn't silently no-op a
// floor clause). Future floor clauses add to this set at the same time
// they add to the floor's reader.
var validPermissionKeys = map[string]struct{}{
	"read_only":                {},
	"spend":                    {},
	"irreversible_third_party": {},
	"secret_classes":           {},
}

// ValidatePermissions returns nil iff raw is a JSON object matching the
// floor's schema. Wraps ErrInvalidPermissions on every failure so callers
// can errors.Is against the sentinel.
func ValidatePermissions(raw json.RawMessage) error {
	if len(raw) == 0 || string(raw) == "null" {
		return fmt.Errorf("%w: empty or null permissions", ErrInvalidPermissions)
	}
	var m map[string]json.RawMessage
	if err := json.Unmarshal(raw, &m); err != nil {
		return fmt.Errorf("%w: not a JSON object: %v", ErrInvalidPermissions, err)
	}
	for k := range m {
		if _, ok := validPermissionKeys[k]; !ok {
			return fmt.Errorf("%w: unknown key %q", ErrInvalidPermissions, k)
		}
	}

	// Typed checks per key.
	if v, ok := m["read_only"]; ok {
		var b bool
		if err := json.Unmarshal(v, &b); err != nil {
			return fmt.Errorf("%w: read_only must be bool", ErrInvalidPermissions)
		}
	}
	if v, ok := m["spend"]; ok {
		var b bool
		if err := json.Unmarshal(v, &b); err != nil {
			return fmt.Errorf("%w: spend must be bool", ErrInvalidPermissions)
		}
	}
	if v, ok := m["irreversible_third_party"]; ok {
		var s string
		if err := json.Unmarshal(v, &s); err != nil {
			return fmt.Errorf("%w: irreversible_third_party must be string", ErrInvalidPermissions)
		}
		if _, ok := validIrreversibleModes[s]; !ok {
			return fmt.Errorf("%w: irreversible_third_party=%q not in {never, always, stranger_recipient}", ErrInvalidPermissions, s)
		}
	}
	if v, ok := m["secret_classes"]; ok {
		var arr []string
		if err := json.Unmarshal(v, &arr); err != nil {
			return fmt.Errorf("%w: secret_classes must be []string", ErrInvalidPermissions)
		}
	}
	return nil
}
