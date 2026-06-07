package connector

import (
	"context"
	"log/slog"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

const connectorTypeCalendar = "calendar"

// CalendarStub registers the calendar connector type with a LogProvider-style
// stub body (the internal/push APNs/FCM precedent): the credential seam is in
// place, but Run emits nothing this phase. Completable with zero core changes
// when the Calendar REST path lands (research R3) — there is no task_events
// table yet to source from.
type CalendarStub struct{}

// NewCalendarStub constructs the stub connector.
func NewCalendarStub() *CalendarStub { return &CalendarStub{} }

// Type implements Connector.
func (*CalendarStub) Type() string { return connectorTypeCalendar }

// Run logs intent and emits nothing.
func (*CalendarStub) Run(_ context.Context, cfg ConnectorConfig, _ intake.EmitFunc) error {
	slog.Info("connector.calendar.stub", "connector_id", cfg.ConnectorID, "note", "stub: emits nothing this phase")
	return nil
}
