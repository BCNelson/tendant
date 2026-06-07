package gatescript

import (
	"context"
	"testing"
	"time"
)

// runner_wazero_test.go exercises the real wazero runner against hand-encoded
// WASM fixtures (no compiler available in CI). The fixtures implement the v1
// ABI: exported memory + tendant_alloc + tendant_dealloc + evaluate() -> i64
// (packed ptr<<32|len). evaluate returns a constant pointer to a JSON verdict
// placed via a data segment.

func newTestRunner(t *testing.T) *WazeroRunner {
	t.Helper()
	r, err := NewWazeroRunner(context.Background(), Ceilings{MaxTimeoutMs: 1000, MaxMemoryPages: 64})
	if err != nil {
		t.Fatalf("new runner: %v", err)
	}
	t.Cleanup(func() { _ = r.Close(context.Background()) })
	return r
}

func runFixture(t *testing.T, r *WazeroRunner, wasm []byte, timeoutMs int) ScriptVerdict {
	t.Helper()
	in := ScriptInput{
		WASM:         wasm,
		ManifestHash: "test",
		Manifest:     Manifest{Limits: ManifestLimits{TimeoutMs: timeoutMs, MemoryPages: 16}},
	}
	v, err := r.Run(context.Background(), in)
	if err != nil {
		t.Fatalf("run: %v", err)
	}
	return v
}

func TestWazeroRunner_TerminalVerdicts(t *testing.T) {
	r := newTestRunner(t)
	cases := []struct {
		json string
		want Verdict
	}{
		{`{"decision":"approve","evidence":{"summary":"ok","considered_fields":["payload.to"]}}`, VerdictApprove},
		{`{"decision":"deny","evidence":{"summary":"no","considered_fields":[]}}`, VerdictDeny},
		{`{"decision":"request_decision","evidence":{"summary":"ask","considered_fields":[]}}`, VerdictRequestDecision},
		{`{"decision":"agent_handoff","evidence":{"summary":"weigh","considered_fields":[]}}`, VerdictAgentHandoff},
	}
	for _, tc := range cases {
		t.Run(tc.json[18:24], func(t *testing.T) {
			v := runFixture(t, r, buildStaticVerdictModule(tc.json), 1000)
			if !v.RanToCompletion {
				t.Fatalf("expected ran-to-completion, got failure %q", v.FailureReason)
			}
			if v.Decision != tc.want {
				t.Fatalf("decision: want %v got %v", tc.want, v.Decision)
			}
		})
	}
}

func TestWazeroRunner_Approve_CarriesEvidence(t *testing.T) {
	r := newTestRunner(t)
	v := runFixture(t, r, buildStaticVerdictModule(
		`{"decision":"approve","evidence":{"summary":"benign","considered_fields":["payload.to","payload.body"]}}`), 1000)
	if v.Evidence.Summary != "benign" {
		t.Fatalf("summary: %q", v.Evidence.Summary)
	}
	if len(v.Evidence.ConsideredFields) != 2 {
		t.Fatalf("considered fields: %v", v.Evidence.ConsideredFields)
	}
}

func TestWazeroRunner_MalformedReturn_FailsClosed(t *testing.T) {
	r := newTestRunner(t)
	// The verdict region is non-JSON bytes.
	v := runFixture(t, r, buildStaticVerdictModule(`not json at all`), 1000)
	if v.RanToCompletion {
		t.Fatalf("expected fail-closed")
	}
	if v.FailureReason != FailureMalformedReturn {
		t.Fatalf("reason: want malformed_return got %q", v.FailureReason)
	}
	// Fail-closed always presents AgentHandoff to the gate (fall through to overseer).
	if v.Decision != VerdictAgentHandoff {
		t.Fatalf("decision: want agent_handoff got %v", v.Decision)
	}
}

func TestWazeroRunner_UnknownDecision_FailsClosed(t *testing.T) {
	r := newTestRunner(t)
	v := runFixture(t, r, buildStaticVerdictModule(`{"decision":"yolo","evidence":{"summary":"","considered_fields":[]}}`), 1000)
	if v.RanToCompletion || v.FailureReason != FailureMalformedReturn {
		t.Fatalf("expected malformed_return, got ran=%v reason=%q", v.RanToCompletion, v.FailureReason)
	}
}

func TestWazeroRunner_Trap_FailsClosed(t *testing.T) {
	r := newTestRunner(t)
	v := runFixture(t, r, buildTrapModule(), 1000)
	if v.RanToCompletion {
		t.Fatalf("expected fail-closed")
	}
	if v.FailureReason != FailureTrap {
		t.Fatalf("reason: want trap got %q", v.FailureReason)
	}
	if v.Decision != VerdictAgentHandoff {
		t.Fatalf("decision: want agent_handoff got %v", v.Decision)
	}
}

func TestWazeroRunner_Timeout_FailsClosedWithinDeadline(t *testing.T) {
	r := newTestRunner(t)
	start := time.Now()
	// Effective timeout = min(manifest 50ms, ceiling 1000ms) = 50ms.
	v := runFixture(t, r, buildLoopModule(), 50)
	elapsed := time.Since(start)
	if v.RanToCompletion {
		t.Fatalf("expected fail-closed timeout")
	}
	if v.FailureReason != FailureTimeout {
		t.Fatalf("reason: want timeout got %q", v.FailureReason)
	}
	// NFR-006: killed within the deadline + generous slack.
	if elapsed > 2*time.Second {
		t.Fatalf("timeout kill took too long: %v", elapsed)
	}
}
