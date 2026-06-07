package calibration

import "testing"

func TestBand(t *testing.T) {
	tests := []struct {
		name  string
		score float64
		want  Level
	}{
		{"zero is NONE", 0.0, LevelNone},
		{"just above zero is gated", 0.01, LevelExecuteGated},
		{"baseline is gated", Baseline, LevelExecuteGated},
		{"mid-gated", 0.7, LevelExecuteGated},
		{"just below auto is gated", AutoThreshold - 0.001, LevelExecuteGated},
		{"auto threshold is auto", AutoThreshold, LevelExecuteAuto},
		{"high is auto", 0.95, LevelExecuteAuto},
		{"max is auto", 1.0, LevelExecuteAuto},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Band(tt.score); got != tt.want {
				t.Fatalf("Band(%v) = %q, want %q", tt.score, got, tt.want)
			}
		})
	}
}

func TestBandNoneOnlyAtZero(t *testing.T) {
	// NONE is owner-set only — no positive score derives to NONE.
	for s := 0.001; s < 1.0; s += 0.05 {
		if Band(s) == LevelNone {
			t.Fatalf("Band(%v) = NONE; NONE must be reachable only at 0.0", s)
		}
	}
}

func TestPromoteTo(t *testing.T) {
	tests := []struct {
		current, want float64
	}{
		{Baseline, AutoThreshold},      // gated → auto band entry
		{0.7, AutoThreshold},           // mid-gated → auto
		{AutoThreshold, AutoThreshold}, // already at threshold
		{0.95, 0.95},                   // already above — never lowered
	}
	for _, tt := range tests {
		if got := PromoteTo(tt.current); got != tt.want {
			t.Fatalf("PromoteTo(%v) = %v, want %v", tt.current, got, tt.want)
		}
		if Band(PromoteTo(tt.current)) != LevelExecuteAuto {
			t.Fatalf("PromoteTo(%v) did not land in EXECUTE_AUTO band", tt.current)
		}
	}
}

func TestDemoteClampsAtBaseline(t *testing.T) {
	// One demotion from a freshly-promoted tool drops it out of the auto band…
	dropped := Demote(AutoThreshold, DefaultDemotionDecrement)
	if Band(dropped) != LevelExecuteGated {
		t.Fatalf("Demote(%v) band = %q, want execute_gated", AutoThreshold, Band(dropped))
	}
	// …but never below the baseline, no matter how many times.
	score := AutoThreshold
	for i := 0; i < 10; i++ {
		score = Demote(score, DefaultDemotionDecrement)
	}
	if score < Baseline {
		t.Fatalf("Demote slid below baseline: %v < %v", score, Baseline)
	}
	if score != Baseline {
		t.Fatalf("repeated demotion should settle at baseline, got %v", score)
	}
}
