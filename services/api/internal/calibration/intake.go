package calibration

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// intakeLookback bounds the dismissal window the tuner reads (a recent-history
// signal, not all-time).
const intakeLookback = 30 * 24 * time.Hour

// maxTighten caps how far dismissals can move a threshold, so a noisy source
// can't drive the floor/ceiling to absurd values.
const maxTighten = 0.3

// dismissalHistoryCap bounds how many reasons feed the [DISMISSAL_HISTORY]
// triage section.
const dismissalHistoryCap = 10

// IntakeTuner reads dismissals (derived, no new stored state — NFR-003 / R9) to
// (1) tighten effective disposition thresholds and (2) surface dismissal reasons
// to the triage seam as labeled evidence. It satisfies intake.ThresholdTuner.
type IntakeTuner struct {
	queries *db.Queries
	k       float64
	now     func() time.Time
}

// NewIntakeTuner constructs a tuner. k is the per-dismissal tightening
// coefficient (Config.IntakeTightenK).
func NewIntakeTuner(pool *pgxpool.Pool, q *db.Queries, k float64) *IntakeTuner {
	return &IntakeTuner{queries: q, k: k, now: time.Now}
}

// EffectiveThresholds returns the dismissal-adjusted confidence floor and stakes
// ceiling for a connector: the floor rises and the ceiling falls with recent
// dismissal volume (bounded). On any error it returns the base values unchanged
// (fail-safe: tuning never loosens, and a read failure never blocks intake).
func (t *IntakeTuner) EffectiveThresholds(ctx context.Context, connectorID uuid.UUID, baseFloor, baseCeiling float64) (floor, ceiling float64) {
	n := t.dismissalCount(ctx, connectorID)
	tighten := t.k * float64(n)
	if tighten > maxTighten {
		tighten = maxTighten
	}
	floor = baseFloor + tighten
	if floor > 1.0 {
		floor = 1.0
	}
	ceiling = baseCeiling - tighten
	if ceiling < 0.0 {
		ceiling = 0.0
	}
	return floor, ceiling
}

// DismissalHistory returns the connector's recent dismissal reasons (newest
// first, capped), for the [DISMISSAL_HISTORY] triage section.
func (t *IntakeTuner) DismissalHistory(ctx context.Context, connectorID uuid.UUID) []string {
	rows, err := t.dismissals(ctx, connectorID)
	if err != nil {
		return nil
	}
	out := make([]string, 0, len(rows))
	for _, row := range rows {
		reason := reasonString(row.Reason)
		if reason == "" {
			continue
		}
		out = append(out, reason)
		if len(out) >= dismissalHistoryCap {
			break
		}
	}
	return out
}

func (t *IntakeTuner) dismissalCount(ctx context.Context, connectorID uuid.UUID) int {
	rows, err := t.dismissals(ctx, connectorID)
	if err != nil {
		return 0
	}
	return len(rows)
}

func (t *IntakeTuner) dismissals(ctx context.Context, connectorID uuid.UUID) ([]db.DismissalsByConnectorRow, error) {
	if t.queries == nil {
		return nil, fmt.Errorf("intake tuner: no queries")
	}
	return t.queries.DismissalsByConnector(ctx, db.DismissalsByConnectorParams{
		ConnectorID: pgtype.UUID{Bytes: connectorID, Valid: true},
		At:          t.clock().Add(-intakeLookback),
	})
}

func (t *IntakeTuner) clock() time.Time {
	if t.now != nil {
		return t.now()
	}
	return time.Now()
}

// reasonString narrows the sqlc interface{} reason column (jsonb ->> text) to a
// string.
func reasonString(v interface{}) string {
	switch s := v.(type) {
	case string:
		return s
	case *string:
		if s != nil {
			return *s
		}
	case []byte:
		return string(s)
	}
	return ""
}
