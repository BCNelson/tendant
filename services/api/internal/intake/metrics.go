package intake

import (
	"sync"
	"time"
)

// rateWindow is the rolling window for the /healthz intake counters.
const rateWindow = time.Minute

// Metrics is a small rolling-window counter for intake observability — parity
// with the Phase-4 overseer rate field (FR / NFR). Goroutine-safe; no
// package-level state (CLAUDE.md). A nil *Metrics is a no-op, so callers can
// stay metrics-agnostic.
type Metrics struct {
	mu      sync.Mutex
	emitted []time.Time
	deduped []time.Time
	capped  []time.Time
	now     func() time.Time
}

// NewMetrics constructs a Metrics using the wall clock.
func NewMetrics() *Metrics { return &Metrics{now: time.Now} }

// kind selects which rolling bucket to record into — keeping the nil-receiver
// check in one place (taking &m.<bucket> in the caller would dereference a nil
// *Metrics before the guard could run).
type metricKind int

const (
	kindEmitted metricKind = iota
	kindDeduped
	kindCapped
)

func (m *Metrics) record(kind metricKind) {
	if m == nil {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	now := m.clock()
	switch kind {
	case kindEmitted:
		m.emitted = append(prune(m.emitted, now), now)
	case kindDeduped:
		m.deduped = append(prune(m.deduped, now), now)
	case kindCapped:
		m.capped = append(prune(m.capped, now), now)
	}
}

// RecordEmitted counts a freshly-persisted signal.
func (m *Metrics) RecordEmitted() { m.record(kindEmitted) }

// RecordDeduped counts a collided (deduped) emission.
func (m *Metrics) RecordDeduped() { m.record(kindDeduped) }

// RecordCapped counts an llm_judge item held by the per-poll cap.
func (m *Metrics) RecordCapped() { m.record(kindCapped) }

// Snapshot returns the per-last-minute counts.
func (m *Metrics) Snapshot() (emitted, deduped, capped int) {
	if m == nil {
		return 0, 0, 0
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	now := m.clock()
	m.emitted = prune(m.emitted, now)
	m.deduped = prune(m.deduped, now)
	m.capped = prune(m.capped, now)
	return len(m.emitted), len(m.deduped), len(m.capped)
}

func (m *Metrics) clock() time.Time {
	if m.now != nil {
		return m.now()
	}
	return time.Now()
}

// prune drops timestamps older than the rolling window.
func prune(ts []time.Time, now time.Time) []time.Time {
	cutoff := now.Add(-rateWindow)
	i := 0
	for i < len(ts) && ts[i].Before(cutoff) {
		i++
	}
	return ts[i:]
}
