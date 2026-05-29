package overseer

import (
	"context"
	"encoding/json"
	"log/slog"
	"os"
	"regexp"
	"sort"
	"sync"
)

// LogProvider is the deterministic, network-free default Provider. It's the
// only Provider used in CI (`just test`) — fixed token counts and zero cost
// keep audit fixtures stable.
//
// Verdict policy: returns "approve" unless TENDANT_OVERSEER_LOG_DENY_PATTERN
// (a Go regexp, empty = never matches) matches the [CONCRETE_CALL] JSON; on
// match returns "request_decision". Evidence.ConsideredFields enumerates the
// top-level payload keys whose value the deny pattern matched against (so
// US2's hostile-framing test can assert which fields were weighted).
type LogProvider struct {
	denyPattern *regexp.Regexp
	mu          sync.Mutex
	callCount   int // exposed via Calls() for tests
}

// NewLogProvider reads TENDANT_OVERSEER_LOG_DENY_PATTERN from env at boot.
// An empty value (the default) means "never deny" — every benign call
// auto-approves. A malformed regex is a fatal startup error in real
// services (callers panic at boot); from a non-main caller, we log and
// fall back to "never deny" so tests don't crash on bad env.
func NewLogProvider() *LogProvider {
	raw := os.Getenv("TENDANT_OVERSEER_LOG_DENY_PATTERN")
	if raw == "" {
		return &LogProvider{}
	}
	re, err := regexp.Compile(raw)
	if err != nil {
		slog.Warn("overseer.LogProvider.compile_deny_pattern_failed", "pattern", raw, "err", err)
		return &LogProvider{}
	}
	return &LogProvider{denyPattern: re}
}

// NewLogProviderWithPattern is a test seam — bypass env. Pass nil for the
// default (never deny).
func NewLogProviderWithPattern(re *regexp.Regexp) *LogProvider {
	return &LogProvider{denyPattern: re}
}

// Name reports the provider name written into audit.
func (p *LogProvider) Name() string { return "log" }

// Calls returns the number of times Call has been invoked. Test-only seam
// used by US1's per-task-cap regression to assert the gateway short-circuits
// without dispatching to the provider.
func (p *LogProvider) Calls() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.callCount
}

// Call evaluates the prompt deterministically against denyPattern. Synthetic
// token counts (10 in, 5 out) keep audit fixtures stable; the gateway maps
// these through pricing.EstimateCostUSD which returns 0 for ("log", "log").
func (p *LogProvider) Call(_ context.Context, prompt PromptPayload) (RawResponse, error) {
	p.mu.Lock()
	p.callCount++
	p.mu.Unlock()

	considered := consideredFieldsFromCall(prompt.ConcreteCall, p.denyPattern)

	verdict := "approve"
	summary := "log provider default verdict — no deny pattern match"
	if p.denyPattern != nil && p.denyPattern.MatchString(prompt.ConcreteCall) {
		verdict = "request_decision"
		summary = "log provider escalation — deny pattern matched concrete call"
	}

	slog.Info("overseer.LogProvider.evaluate",
		"model_id", "log",
		"provider", "log",
		"verdict", verdict,
		"tokens_in", 10,
		"tokens_out", 5,
		"considered_fields", considered,
	)

	return RawResponse{
		Verdict: verdict,
		Evidence: Evidence{
			Summary:          summary,
			ConsideredFields: considered,
		},
		ModelID:   "log",
		TokensIn:  10,
		TokensOut: 5,
	}, nil
}

// consideredFieldsFromCall returns ["payload.<key>"] for every top-level key
// in the concrete-call JSON whose value the deny pattern matched against.
// When denyPattern is nil (the default), returns all top-level keys so the
// audit row still records which fields the overseer weighed.
//
// Robustness: malformed JSON returns an empty slice rather than erroring —
// the gateway carries on; the model verdict still lands.
func consideredFieldsFromCall(concrete string, denyPattern *regexp.Regexp) []string {
	if concrete == "" {
		return []string{}
	}
	var m map[string]any
	if err := json.Unmarshal([]byte(concrete), &m); err != nil {
		return []string{}
	}
	keys := make([]string, 0, len(m))
	for k, v := range m {
		switch denyPattern {
		case nil:
			keys = append(keys, "payload."+k)
		default:
			vs := stringifyValue(v)
			if denyPattern.MatchString(vs) {
				keys = append(keys, "payload."+k)
			}
		}
	}
	sort.Strings(keys)
	return keys
}

// stringifyValue collapses any JSON value into a string the deny pattern
// can match against. Scalars stringify directly; composites JSON-marshal.
func stringifyValue(v any) string {
	switch x := v.(type) {
	case string:
		return x
	case nil:
		return ""
	default:
		raw, _ := json.Marshal(v)
		return string(raw)
	}
}
