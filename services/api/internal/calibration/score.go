package calibration

// Trust-score ↔ band math (research R1/R2). Pure; table-tested.
//
// Bands:
//
//	NONE          score == 0.0          (owner-set only — tool disabled)
//	EXECUTE_GATED [baseline, auto)      (always gate — the un-promoted default)
//	EXECUTE_AUTO  [auto, 1.0]           (auto-approve eligible; per-routine grant still required)
const (
	// Baseline is mid-EXECUTE_GATED and the demotion clamp floor.
	Baseline = 0.5
	// AutoThreshold is the EXECUTE_AUTO band entry.
	AutoThreshold = 0.8
)

// Level is the discrete band derived from the continuous score. Values match
// the db tools.rung text cache so callers can sync the cache and map to the
// GraphQL AutonomyLevel without importing graph/model.
type Level string

const (
	LevelNone         Level = "none"
	LevelExecuteGated Level = "execute_gated"
	LevelExecuteAuto  Level = "execute_auto"
)

// Band derives the autonomy band from a trust score.
func Band(score float64) Level {
	switch {
	case score <= 0.0:
		return LevelNone
	case score >= AutoThreshold:
		return LevelExecuteAuto
	default:
		return LevelExecuteGated
	}
}

// PromoteTo returns the score a tool jumps to when the owner accepts a promotion
// into the EXECUTE_AUTO band — never lowering an already-higher score.
func PromoteTo(current float64) float64 {
	if current > AutoThreshold {
		return current
	}
	return AutoThreshold
}

// Demote returns the score after one bad signal: a proportional slide clamped at
// the EXECUTE_GATED baseline (Constitution IV asymmetry; never below baseline by
// reflexive demotion — only the owner reaches NONE).
func Demote(current, decrement float64) float64 {
	next := current - decrement
	if next < Baseline {
		return Baseline
	}
	return next
}
