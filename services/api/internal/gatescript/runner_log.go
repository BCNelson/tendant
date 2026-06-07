package gatescript

import (
	"context"
	"log/slog"
	"os"
	"strings"
)

// LogRunner is the deterministic CI default Runner (mirrors
// internal/overseer.LogProvider). It never spins up wazero: it returns Approve
// unless TENDANT_GATESCRIPT_LOG_DENY_PATTERN is set and matches the concrete
// call JSON, in which case it returns RequestDecision. This keeps unit and
// integration tests deterministic without a real WASM runtime in the harness.
type LogRunner struct {
	// DenyPattern, when non-empty, flips the verdict to RequestDecision for any
	// concrete call whose JSON contains the substring.
	DenyPattern string
}

// NewLogRunner reads the deny pattern from the environment.
func NewLogRunner() *LogRunner {
	return &LogRunner{DenyPattern: os.Getenv("TENDANT_GATESCRIPT_LOG_DENY_PATTERN")}
}

// Run implements Runner.
func (r *LogRunner) Run(_ context.Context, in ScriptInput) (ScriptVerdict, error) {
	decision := VerdictApprove
	matched := false
	if r.DenyPattern != "" && strings.Contains(string(in.ConcreteCall), r.DenyPattern) {
		decision = VerdictRequestDecision
		matched = true
	}
	slog.Info("gatescript.LogRunner.run",
		"script_id", in.ScriptID,
		"version", in.ScriptVersion,
		"manifest_hash", in.ManifestHash,
		"decision", decision.String(),
		"deny_pattern_matched", matched,
	)
	summary := "log runner: approve (deterministic stub)"
	if matched {
		summary = "log runner: deny pattern matched — request decision"
	}
	return ScriptVerdict{
		Decision: decision,
		Evidence: Evidence{
			Summary:          summary,
			ConsideredFields: []string{},
			HostcallTrace:    []string{},
		},
		RanToCompletion: true,
	}, nil
}

// Ensure LogRunner satisfies Runner.
var _ Runner = (*LogRunner)(nil)
