package intake

import (
	"context"
	"fmt"
	"strings"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
)

// ScheduleName is the DBOS schedule name for a connector: intake:<connectorID>.
// One schedule exists iff the connector is enabled (research R1 / D2).
func ScheduleName(connectorID uuid.UUID) string {
	return "intake:" + connectorID.String()
}

// CreateSchedule registers a DBOS dynamic schedule for a connector. The cron
// spec must be non-blank (no framework-wide default cadence — enabling a
// connector with a blank schedule is rejected). The schedule is DB-backed and
// recovered on Launch, so it survives a crash by construction (SC-005).
func CreateSchedule(dctx dbos.DBOSContext, connectorID uuid.UUID, cron string) error {
	if strings.TrimSpace(cron) == "" {
		return fmt.Errorf("intake: a non-blank cron schedule is required to enable a connector")
	}
	name := ScheduleName(connectorID)
	// Idempotent: a schedule with this name may already live in the durable
	// workflow_schedules table (a prior boot's rehydration, or a re-enable).
	// dbos.CreateSchedule errors on the unique schedule_name, so skip when it
	// is already registered. (To change an existing connector's cadence,
	// disable then re-enable: DeleteSchedule clears the row first.)
	existing, err := dbos.GetSchedule(dctx, name)
	if err != nil {
		return fmt.Errorf("intake: check existing schedule %s: %w", name, err)
	}
	if existing != nil {
		return nil
	}
	return dbos.CreateSchedule(dctx, PollWorkflow, dbos.CreateScheduleRequest{
		ScheduleName: name,
		Schedule:     cron,
	}, dbos.WithScheduleContext(connectorID.String()))
}

// DeleteSchedule removes a connector's DBOS schedule (on disable).
func DeleteSchedule(dctx dbos.DBOSContext, connectorID uuid.UUID) error {
	return dbos.DeleteSchedule(dctx, ScheduleName(connectorID))
}

// RehydrateSchedules re-creates a schedule for every enabled connector on boot
// (after dbos.Launch). A connector with a blank schedule is skipped with a
// warning rather than aborting boot.
func RehydrateSchedules(ctx context.Context, dctx dbos.DBOSContext) error {
	d, err := loadPollDeps()
	if err != nil {
		return err
	}
	rows, err := d.queries.ListEnabledConnectorConfigs(ctx)
	if err != nil {
		return fmt.Errorf("list enabled connectors: %w", err)
	}
	for _, row := range rows {
		cron := ""
		if row.Schedule != nil {
			cron = *row.Schedule
		}
		if strings.TrimSpace(cron) == "" {
			continue // enabled-without-schedule shouldn't happen; skip defensively
		}
		if err := CreateSchedule(dctx, row.ID, cron); err != nil {
			return fmt.Errorf("rehydrate schedule for %s: %w", row.ID, err)
		}
	}
	return nil
}
