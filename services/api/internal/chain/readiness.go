package chain

import (
	"context"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// EvaluateReadiness reports whether a task has met the predicate that allows
// the chain to advance from ACCEPTED to EXECUTING at the
// EXPANSION→EXECUTION boundary (FR-019, data-model §State machine).
//
// Phase 1 stub: always returns true. The seam exists so Phase 7 can wire the
// real predicate (Open Question Q1 in the spec). Expected future signature
// likely takes `tasks.findings` and external readiness signals as inputs.
func EvaluateReadiness(_ context.Context, _ *db.Queries, _ uuid.UUID) (bool, error) {
	return true, nil
}
