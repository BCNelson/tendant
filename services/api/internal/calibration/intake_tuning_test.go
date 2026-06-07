package calibration_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

func TestIntakeTunerTightensWithDismissals(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)

	connectorID := uuid.New()
	_, err := pool.Exec(ctx, `INSERT INTO connector_configs (id, connector_type, filter, disposition_rules, enabled)
		VALUES ($1, 'webhook-in', '{}', '{}', true)`, connectorID)
	require.NoError(t, err)

	const reason = "never relevant"
	const n = 4
	for i := 0; i < n; i++ {
		signalID := uuid.New()
		_, err := pool.Exec(ctx, `INSERT INTO intake_signals
			(id, signal_version, connector_id, idempotency_key, provenance, payload, disposition)
			VALUES ($1, 'v1', $2, $3, '{}', '{}', 'rich_event')`,
			signalID, connectorID, fmt.Sprintf("key-%d", i))
		require.NoError(t, err)

		taskID := uuid.New()
		_, err = pool.Exec(ctx, `INSERT INTO tasks
			(id, global_uri, title, state, current_stage, provenance, intake_signal_id)
			VALUES ($1, $2, 'dismissed item', 'dismissed', 'creation', '{}', $3)`,
			taskID, "local://task/"+taskID.String(), signalID)
		require.NoError(t, err)

		_, err = pool.Exec(ctx, `INSERT INTO audit_messages (id, task_id, from_principal, kind, payload)
			VALUES (gen_random_uuid(), $1, 'local://principal/owner', 'state_transition',
			        jsonb_build_object('from','proposed','to','dismissed','reason',$2::text))`,
			taskID, reason)
		require.NoError(t, err)
	}

	tuner := calibration.NewIntakeTuner(pool, q, 0.05)

	// A connector with no dismissals keeps the base thresholds.
	emptyConnector := uuid.New()
	floor0, ceil0 := tuner.EffectiveThresholds(ctx, emptyConnector, 0.85, 0.30)
	require.InDelta(t, 0.85, floor0, 1e-9)
	require.InDelta(t, 0.30, ceil0, 1e-9)

	// The dismissed connector tightens: higher floor, lower ceiling.
	floorN, ceilN := tuner.EffectiveThresholds(ctx, connectorID, 0.85, 0.30)
	require.Greater(t, floorN, 0.85, "floor should rise with dismissals")
	require.Less(t, ceilN, 0.30, "ceiling should fall with dismissals")

	// The dismissal reasons surface for the [DISMISSAL_HISTORY] triage section.
	history := tuner.DismissalHistory(ctx, connectorID)
	require.NotEmpty(t, history)
	require.Contains(t, history, reason)
}
