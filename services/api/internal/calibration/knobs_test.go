package calibration

import (
	"testing"
	"time"
)

type fakeKnobs struct {
	maturation time.Duration
	windowN    int
	ratio      float64
	minSample  int
	demotion   float64
}

func (f fakeKnobs) CalibrationMaturation() time.Duration  { return f.maturation }
func (f fakeKnobs) CalibrationWindowN() int               { return f.windowN }
func (f fakeKnobs) CalibrationRatio() float64             { return f.ratio }
func (f fakeKnobs) CalibrationMinSample() int             { return f.minSample }
func (f fakeKnobs) CalibrationDemotionDecrement() float64 { return f.demotion }

// TestEngineKnobs_LiveOverride proves the Engine reads tunables from Knobs when
// set (live override) and from the boot cfg when not.
func TestEngineKnobs_LiveOverride(t *testing.T) {
	boot := Config{Maturation: 24 * time.Hour, WindowN: 50, Ratio: 0.9, MinSample: 20, DemotionDecrement: 0.25}

	// No Knobs → boot cfg.
	e := &Engine{cfg: boot}
	if got := e.Config(); got.Ratio != 0.9 || got.WindowN != 50 || got.Maturation != 24*time.Hour {
		t.Fatalf("without Knobs, Config()=%+v want boot", got)
	}

	// Knobs set → live values win.
	e.Knobs = fakeKnobs{maturation: time.Hour, windowN: 5, ratio: 0.5, minSample: 3, demotion: 0.4}
	got := e.Config()
	if got.Ratio != 0.5 || got.WindowN != 5 || got.MinSample != 3 ||
		got.DemotionDecrement != 0.4 || got.Maturation != time.Hour {
		t.Fatalf("with Knobs, Config()=%+v want live overrides", got)
	}
}
