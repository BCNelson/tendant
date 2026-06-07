package calibration

import "time"

// Default knob values (research R6 / R12). All overridable by env in
// cmd/tendant/main.go.
const (
	DefaultMaturation        = 24 * time.Hour
	DefaultWindowN           = 50
	DefaultRatio             = 0.90
	DefaultMinSample         = 20
	DefaultDemotionDecrement = 0.25
	DefaultSweepCron         = "0 * * * *"
	DefaultIntakeTightenK    = 0.02
)

// Config carries the tunable knobs for the calibration subsystem. Zero values
// are NOT safe — construct via DefaultConfig and override fields, or use the
// env loader in main.
type Config struct {
	// Maturation is the per-row veto window: matured_at = at + Maturation.
	Maturation time.Duration
	// WindowN is the rolling count-based window for the matured-clean ratio.
	WindowN int
	// Ratio is the matured-clean fraction (over the last WindowN) required to
	// propose a promotion.
	Ratio float64
	// MinSample is the minimum matured sample before a routine is eligible.
	MinSample int
	// DemotionDecrement is subtracted from the trust score on each bad signal.
	DemotionDecrement float64
	// SweepCron is the DBOS schedule cadence for the promotion sweep.
	SweepCron string
	// IntakeTightenK is the per-dismissal threshold-tightening coefficient.
	IntakeTightenK float64
}

// DefaultConfig returns the conservative defaults (research R6/R12).
func DefaultConfig() Config {
	return Config{
		Maturation:        DefaultMaturation,
		WindowN:           DefaultWindowN,
		Ratio:             DefaultRatio,
		MinSample:         DefaultMinSample,
		DemotionDecrement: DefaultDemotionDecrement,
		SweepCron:         DefaultSweepCron,
		IntakeTightenK:    DefaultIntakeTightenK,
	}
}
