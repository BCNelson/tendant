package overseer

import "testing"

// TestGatewayCapPerTask_LiveOverride proves the per-task eval cap is read live
// from MaxEvalFn when it returns a positive value, else the boot cap.
func TestGatewayCapPerTask_LiveOverride(t *testing.T) {
	g := NewGateway(NewLogProvider(), nil, 50, "log")

	if g.capPerTask() != 50 {
		t.Fatalf("boot cap = %d, want 50", g.capPerTask())
	}

	g.MaxEvalFn = func() int { return 7 }
	if g.capPerTask() != 7 {
		t.Fatalf("live cap = %d, want 7", g.capPerTask())
	}

	// A non-positive live value falls back to the boot cap (fail-safe).
	g.MaxEvalFn = func() int { return 0 }
	if g.capPerTask() != 50 {
		t.Fatalf("cap with zero fn = %d, want 50 fallback", g.capPerTask())
	}
}
