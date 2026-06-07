package calibration

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// pgxAudit writes one task-scoped audit row in its own tx, linked to the task's
// latest transition. Used by the sweep, which is not already inside a request tx.
func pgxAudit(ctx context.Context, pool *pgxpool.Pool, taskID uuid.UUID, kind string, payload any) error {
	return pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		parent, err := latestTransitionInTx(ctx, tx, taskID)
		if err != nil {
			return err
		}
		_, err = lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, kind, payload, parent)
		return err
	})
}
