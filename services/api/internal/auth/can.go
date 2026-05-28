package auth

import (
	"context"
	"log/slog"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TaskRef is the pre-load reference shape used when a resolver authorizes
// before loading the typed entity.
type TaskRef struct{ ID uuid.UUID }

// SessionRef is the pre-load reference shape for session-scoped actions.
type SessionRef struct{ ID uuid.UUID }

// AssignmentRef is the pre-load reference shape for assignment-scoped actions.
type AssignmentRef struct{ ID uuid.UUID }

// DecisionRef is the pre-load reference shape for pending-decision-scoped
// actions.
type DecisionRef struct{ ID uuid.UUID }

// Can is the central authorization decision point. Phase 2 has one owner; the
// owner can do anything against locally-owned data. The signature is the
// federation seam — Phase 3+ enriches the rule set without callers changing.
//
// Target shape support: *db.Task, *db.AgentAssignment, *db.PendingDecision,
// *db.Tool, *db.Session, TaskRef, SessionRef, AssignmentRef, DecisionRef.
// Unknown target types return false and log at warn (so adding a new target
// type without a corresponding clause is loud).
func Can(ctx context.Context, p *Principal, action string, target any) bool {
	if p == nil {
		return false
	}
	switch target.(type) {
	case *db.Task, *db.AgentAssignment, *db.PendingDecision, *db.Tool, *db.Session,
		TaskRef, SessionRef, AssignmentRef, DecisionRef,
		db.Task, db.AgentAssignment, db.PendingDecision, db.Tool, db.Session:
		return true
	case nil:
		// Some resolver-level actions (e.g., "list inbox") have no per-row
		// target — the action verb is enough. Allow for an authenticated
		// owner.
		return true
	default:
		slog.Warn("auth.Can: unrecognized target type", "action", action, "target_type", typeName(target))
		return false
	}
}

func typeName(v any) string {
	if v == nil {
		return "<nil>"
	}
	return slog.AnyValue(v).String()
}
