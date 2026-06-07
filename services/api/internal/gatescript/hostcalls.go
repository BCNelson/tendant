package gatescript

import (
	"context"
	"sync"
)

// hostcalls.go carries the per-call host implementation through context so a
// single shared wazero host module (instantiated once) can serve concurrent
// evaluations. Each evaluation builds a *HostCallbacks closing over the
// in-flight (call, taskID, ownerURI) projection and the granted capability set,
// stuffs it in the context, and the shared host-module shims dispatch to it.
//
// This is the one place the script's view of "the owner's data" is projected.
// hostfunc_test.go asserts the no-leakage invariant against it.

// maxTraceEntries / maxTraceEntryBytes bound the per-run hostcall trace (FR-019)
// so a script cannot DOS the audit row via log().
const (
	maxTraceEntries     = 64
	maxTraceEntryBytes  = 256
	maxSummaryBytes     = 512 // ABI: evidence.summary cap
	maxConsideredFields = 32  // ABI: evidence.considered_fields cap
)

// HostCallbacks is the per-call host surface. The closures are built by the
// Service over the sqlc queries; the wazero shims marshal memory in/out.
//
// A closure that returns an error traps the script (FR-007 / Q4): the runner
// converts to fail_closed_host_error rather than presenting a legitimate-looking
// empty read to the guest. HostErr captures the offending module/name for the
// audit row.
type HostCallbacks struct {
	// Grants is the manifest.reads set, used for defense-in-depth: even though
	// static validation already rejected undeclared imports, a host function
	// whose capability was not granted traps.
	Grants map[string]bool

	// CallJSON is the {tool_global_uri, payload, proposer_global_uri} projection
	// returned by call.get().
	CallJSON []byte

	// The five read closures. Each returns (bytes, ok, error). ok=false means
	// "no value" (returned to the guest as an empty ptr/len). A non-nil error
	// traps the script.
	ContactKnown func(ctx context.Context, addr string) (bool, error)
	Calendar     func(ctx context.Context, start, end string) ([]byte, error)
	TaskContext  func(ctx context.Context, key string) ([]byte, bool, error)
	OwnerRule    func(ctx context.Context, key string) ([]byte, bool, error)

	trace   *traceSink
	hostErr *HostError
	hostMu  sync.Mutex
}

// recordHostError stores the first host error seen during a run (subsequent
// ones are ignored — the first failure traps the script anyway).
func (h *HostCallbacks) recordHostError(module, name, sqlstate string) {
	h.hostMu.Lock()
	defer h.hostMu.Unlock()
	if h.hostErr == nil {
		h.hostErr = &HostError{Module: module, Name: name, SQLState: sqlstate}
	}
}

// traceSink is the bounded hostcall trace backing log() (FR-019).
type traceSink struct {
	mu      sync.Mutex
	entries []string
}

func (t *traceSink) append(msg string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if len(t.entries) >= maxTraceEntries {
		return // silently drop past the cap
	}
	if len(msg) > maxTraceEntryBytes {
		msg = truncateUTF8(msg, maxTraceEntryBytes)
	}
	t.entries = append(t.entries, msg)
}

func (t *traceSink) snapshot() []string {
	t.mu.Lock()
	defer t.mu.Unlock()
	out := make([]string, len(t.entries))
	copy(out, t.entries)
	return out
}

// hostCallbacksKey is the unexported context key carrying *HostCallbacks.
type hostCallbacksKey struct{}

func withHostCallbacks(ctx context.Context, hc *HostCallbacks) context.Context {
	return context.WithValue(ctx, hostCallbacksKey{}, hc)
}

func hostCallbacksFrom(ctx context.Context) *HostCallbacks {
	hc, _ := ctx.Value(hostCallbacksKey{}).(*HostCallbacks)
	return hc
}

// truncateUTF8 trims s to at most n bytes without splitting a multi-byte rune.
func truncateUTF8(s string, n int) string {
	if len(s) <= n {
		return s
	}
	// Back up to a rune boundary.
	for n > 0 && s[n]&0xC0 == 0x80 {
		n--
	}
	return s[:n]
}
