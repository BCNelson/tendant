package chain

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// EvaluateReadiness reports whether a task has met the predicate that allows
// the chain to advance from ACCEPTED to EXECUTING at the readiness gate
// (FR-019, data-model §State machine).
//
// A task is ready when BOTH hold:
//   - it has no unmet blockers — every 'blocks' edge into it points at a task
//     that has reached a terminal state (done/dismissed/halted); and
//   - its start date, if any, has arrived (starts_at <= now).
//
// When either fails the chain parks the task in WAITING and blocks until a
// blocker resolves (a wake Send) or the start date passes (the wait timeout).
func EvaluateReadiness(ctx context.Context, q *db.Queries, taskID uuid.UUID) (bool, error) {
	unmet, err := q.CountUnmetBlockers(ctx, taskID)
	if err != nil {
		return false, fmt.Errorf("count unmet blockers: %w", err)
	}
	if unmet > 0 {
		return false, nil
	}
	task, err := q.GetTask(ctx, taskID)
	if err != nil {
		return false, fmt.Errorf("get task for readiness: %w", err)
	}
	if task.StartsAt.Valid && task.StartsAt.Time.After(time.Now()) {
		return false, nil
	}
	return true, nil
}

// readinessWaitHint returns how long the readiness gate should park before
// re-evaluating when a task is NOT ready. If the only thing holding the task is
// a future start date, the hint is the time until that date (capped). Otherwise
// (unmet blockers) it returns the cap, so the gate periodically re-checks even
// if a wake Send is missed. Floored so a just-passed start date still yields a
// positive, finite wait.
func readinessWaitHint(ctx context.Context, q *db.Queries, taskID uuid.UUID) time.Duration {
	if task, err := q.GetTask(ctx, taskID); err == nil && task.StartsAt.Valid {
		if d := time.Until(task.StartsAt.Time); d > 0 && d < BlockedReevalInterval {
			if d < time.Second {
				return time.Second
			}
			return d
		}
	}
	return BlockedReevalInterval
}
