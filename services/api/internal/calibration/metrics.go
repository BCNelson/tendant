package calibration

import (
	"sync"
	"time"
)

// rateWindow is the rolling window for the /healthz calibration counters.
const rateWindow = time.Minute

// Metrics is a rolling-window counter for calibration observability (research
// R13), mirroring internal/intake.Metrics. Goroutine-safe; a nil *Metrics is a
// no-op so callers stay metrics-agnostic. open_proposals is a gauge the sweep
// refreshes each run; maturation_window is a static echo of the configured knob.
type Metrics struct {
	mu               sync.Mutex
	proposals        []time.Time
	demotions        []time.Time
	outcomes         []time.Time
	openProposals    int
	maturationWindow string
	now              func() time.Time
}

// NewMetrics constructs a Metrics with the wall clock. window is the static
// maturation-window echo for the /healthz block.
func NewMetrics(window time.Duration) *Metrics {
	return &Metrics{now: time.Now, maturationWindow: window.String()}
}

type metricKind int

const (
	kindProposal metricKind = iota
	kindDemotion
	kindOutcome
)

func (m *Metrics) record(kind metricKind) {
	if m == nil {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	now := m.clock()
	switch kind {
	case kindProposal:
		m.proposals = append(prune(m.proposals, now), now)
	case kindDemotion:
		m.demotions = append(prune(m.demotions, now), now)
	case kindOutcome:
		m.outcomes = append(prune(m.outcomes, now), now)
	}
}

// RecordProposalEmitted counts a PromotionProposal the sweep emitted.
func (m *Metrics) RecordProposalEmitted() { m.record(kindProposal) }

// RecordDemotion counts a reflexive demotion.
func (m *Metrics) RecordDemotion() { m.record(kindDemotion) }

// RecordOutcomeMatured counts a matured-outcome observation (recorded as the
// sweep tallies the ledger — a throughput signal for inferred-clean honesty).
func (m *Metrics) RecordOutcomeMatured() { m.record(kindOutcome) }

// SetOpenProposals refreshes the open-proposals gauge (called by the sweep).
func (m *Metrics) SetOpenProposals(n int) {
	if m == nil {
		return
	}
	m.mu.Lock()
	m.openProposals = n
	m.mu.Unlock()
}

// CalibrationSnapshot returns the per-last-minute counts + the open-proposals
// gauge + the static maturation window, for /healthz.
func (m *Metrics) CalibrationSnapshot() (proposals, demotions, matured, openProposals int, window string) {
	if m == nil {
		return 0, 0, 0, 0, ""
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	now := m.clock()
	m.proposals = prune(m.proposals, now)
	m.demotions = prune(m.demotions, now)
	m.outcomes = prune(m.outcomes, now)
	return len(m.proposals), len(m.demotions), len(m.outcomes), m.openProposals, m.maturationWindow
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
