package config

import "time"

// Live resolves tunable values at read time so consumers pick up runtime config
// changes (DB overlay writes) without a restart. The DB overlay wins; otherwise
// the boot snapshot value is returned. All methods are safe on a nil overlay
// (they return the snapshot value) and on a nil *Live (they return zero values),
// so callers can hold an optional *Live.
//
// Subsystems take a small interface that *Live structurally satisfies (e.g.
// calibration.Knobs) or a bound method value (e.g. overseer Gateway's cap fn),
// keeping them decoupled from this package.
type Live struct {
	snap *Config
	ov   *Overlay
}

// NewLive binds the boot snapshot and the DB overlay into a read-time resolver.
func NewLive(snap *Config, ov *Overlay) *Live {
	return &Live{snap: snap, ov: ov}
}

// OverseerMaxEvalPerTask is the live per-task overseer evaluation cap.
func (l *Live) OverseerMaxEvalPerTask() int {
	if l == nil {
		return 0
	}
	return l.ov.IntOr("overseer.max_eval_per_task", l.snap.Overseer.MaxEvalPerTask)
}

// CalibrationMaturation is the live per-row clean-outcome veto window.
func (l *Live) CalibrationMaturation() time.Duration {
	if l == nil {
		return 0
	}
	return l.ov.DurationOr("calibration.maturation", l.snap.Calibration.Maturation)
}

// CalibrationWindowN is the live rolling count window for the matured-clean ratio.
func (l *Live) CalibrationWindowN() int {
	if l == nil {
		return 0
	}
	return l.ov.IntOr("calibration.window_n", l.snap.Calibration.WindowN)
}

// CalibrationRatio is the live matured-clean fraction required to promote.
func (l *Live) CalibrationRatio() float64 {
	if l == nil {
		return 0
	}
	return l.ov.Float64Or("calibration.ratio", l.snap.Calibration.Ratio)
}

// CalibrationMinSample is the live minimum matured sample before eligibility.
func (l *Live) CalibrationMinSample() int {
	if l == nil {
		return 0
	}
	return l.ov.IntOr("calibration.min_sample", l.snap.Calibration.MinSample)
}

// CalibrationDemotionDecrement is the live trust-score decrement per bad signal.
func (l *Live) CalibrationDemotionDecrement() float64 {
	if l == nil {
		return 0
	}
	return l.ov.Float64Or("calibration.demotion_decrement", l.snap.Calibration.DemotionDecrement)
}

// CalibrationIntakeTightenK is the live per-dismissal tightening coefficient.
func (l *Live) CalibrationIntakeTightenK() float64 {
	if l == nil {
		return 0
	}
	return l.ov.Float64Or("calibration.intake_tighten_k", l.snap.Calibration.IntakeTightenK)
}

// Default HITL timeouts, returned when *Live is nil so a caller holding an
// optional resolver still gets the safe (today's) behavior rather than a
// zero-duration "no timeout". An explicit "0" overlay value is the only way to
// disable a timeout.
const (
	defaultApprovalTimeout = 72 * time.Hour
	defaultStageTimeout    = 72 * time.Hour
	defaultFeedbackTimeout = 168 * time.Hour
	defaultQuestionTimeout = 72 * time.Hour
)

// HITLApprovalTimeout is the live tool-call approval wait window (0 = none).
func (l *Live) HITLApprovalTimeout() time.Duration {
	if l == nil {
		return defaultApprovalTimeout
	}
	return l.ov.DurationOr("hitl.approval_timeout", l.snap.HITL.ApprovalTimeout)
}

// HITLStageTimeout is the live human chain-stage slot wait window (0 = none).
func (l *Live) HITLStageTimeout() time.Duration {
	if l == nil {
		return defaultStageTimeout
	}
	return l.ov.DurationOr("hitl.stage_timeout", l.snap.HITL.StageTimeout)
}

// HITLFeedbackTimeout is the live feedback-request wait window (0 = none).
func (l *Live) HITLFeedbackTimeout() time.Duration {
	if l == nil {
		return defaultFeedbackTimeout
	}
	return l.ov.DurationOr("hitl.feedback_timeout", l.snap.HITL.FeedbackTimeout)
}

// HITLQuestionTimeout is the live agent-question wait window (0 = none).
func (l *Live) HITLQuestionTimeout() time.Duration {
	if l == nil {
		return defaultQuestionTimeout
	}
	return l.ov.DurationOr("hitl.question_timeout", l.snap.HITL.QuestionTimeout)
}

// LogLevel is the live log level (debug|info|warn|error).
func (l *Live) LogLevel() string {
	if l == nil {
		return "info"
	}
	return l.ov.StringOr("log.level", l.snap.Log.Level)
}
