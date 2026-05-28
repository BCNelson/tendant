package auth

import (
	"fmt"
	"sort"
	"strings"
	"sync"
)

// FieldKey identifies a (GraphQL type, field name) pair in the operator-edge
// schema.
type FieldKey struct {
	TypeName  string
	FieldName string
}

func (k FieldKey) String() string { return k.TypeName + "." + k.FieldName }

// FieldEntry records the action verb and target-extractor used when Can is
// consulted for this field's resolver.
type FieldEntry struct {
	Action     string
	TargetType string // documentation hint, e.g. "Task" or "Session"
}

// Registry is the per-process operator-edge auth registry. Phase 2 boot
// registers an entry for every field in `contracts/graphql.v1.graphqls`; a
// startup-time assertion compares the registry to the executable schema and
// panics on missing entries (caught in tests; SC-005 verification).
type Registry struct {
	mu      sync.RWMutex
	entries map[FieldKey]FieldEntry
}

// NewRegistry builds an empty Registry.
func NewRegistry() *Registry {
	return &Registry{entries: map[FieldKey]FieldEntry{}}
}

// MustRegister adds a (type, field) → (action, target) entry. Panics on
// duplicate registration so the boot-time wiring is hard to break silently.
func (r *Registry) MustRegister(typeName, fieldName, action, targetType string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	k := FieldKey{TypeName: typeName, FieldName: fieldName}
	if _, exists := r.entries[k]; exists {
		panic(fmt.Sprintf("auth.Registry: duplicate registration for %s", k))
	}
	r.entries[k] = FieldEntry{Action: action, TargetType: targetType}
}

// Has reports whether the (type, field) is registered.
func (r *Registry) Has(typeName, fieldName string) bool {
	r.mu.RLock()
	defer r.mu.RUnlock()
	_, ok := r.entries[FieldKey{TypeName: typeName, FieldName: fieldName}]
	return ok
}

// Keys returns the registered (type, field) pairs sorted alphabetically.
// Test-only helper.
func (r *Registry) Keys() []FieldKey {
	r.mu.RLock()
	defer r.mu.RUnlock()
	keys := make([]FieldKey, 0, len(r.entries))
	for k := range r.entries {
		keys = append(keys, k)
	}
	sort.Slice(keys, func(i, j int) bool {
		if keys[i].TypeName == keys[j].TypeName {
			return keys[i].FieldName < keys[j].FieldName
		}
		return keys[i].TypeName < keys[j].TypeName
	})
	return keys
}

// AssertCovers panics if any required (type, field) is missing from the
// registry. Called from boot wiring after MustRegister of all entries.
func (r *Registry) AssertCovers(required []FieldKey) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	var missing []string
	for _, k := range required {
		if _, ok := r.entries[k]; !ok {
			missing = append(missing, k.String())
		}
	}
	if len(missing) > 0 {
		panic("auth.Registry: missing entries for operator-edge fields: " + strings.Join(missing, ", "))
	}
}

// DefaultRegistry is the process-wide registry; boot wiring populates it.
var DefaultRegistry = NewRegistry()
