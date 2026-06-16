package chain

import "time"

// Timeouts supplies the per-flow durable human-wait windows at read time, so an
// owner's DB-overlay change takes effect without a restart. *config.Live
// satisfies it structurally (its HITL*Timeout methods), mirroring the
// calibration.Knobs pattern; this package stays decoupled from internal/config.
//
// A zero duration from any method means "no timeout" (wait forever). The
// resolver helpers below tolerate a nil Timeouts by falling back to the legacy
// 72h budget, so a caller (or test) that wires no Timeouts keeps today's
// behavior rather than accidentally waiting forever.
type Timeouts interface {
	HITLApprovalTimeout() time.Duration
	HITLStageTimeout() time.Duration
	HITLFeedbackTimeout() time.Duration
	HITLQuestionTimeout() time.Duration
}

// ApprovalTimeoutOr returns t.HITLApprovalTimeout(), or HumanSlotTimeout when t
// is nil.
func ApprovalTimeoutOr(t Timeouts) time.Duration {
	if t == nil {
		return HumanSlotTimeout
	}
	return t.HITLApprovalTimeout()
}

// StageTimeoutOr returns t.HITLStageTimeout(), or HumanSlotTimeout when t is nil.
func StageTimeoutOr(t Timeouts) time.Duration {
	if t == nil {
		return HumanSlotTimeout
	}
	return t.HITLStageTimeout()
}

// FeedbackTimeoutOr returns t.HITLFeedbackTimeout(), or HumanSlotTimeout when t
// is nil.
func FeedbackTimeoutOr(t Timeouts) time.Duration {
	if t == nil {
		return HumanSlotTimeout
	}
	return t.HITLFeedbackTimeout()
}

// QuestionTimeoutOr returns t.HITLQuestionTimeout(), or HumanSlotTimeout when t
// is nil.
func QuestionTimeoutOr(t Timeouts) time.Duration {
	if t == nil {
		return HumanSlotTimeout
	}
	return t.HITLQuestionTimeout()
}
