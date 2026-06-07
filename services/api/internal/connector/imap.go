package connector

import (
	"context"
	"log/slog"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

const connectorTypeIMAP = "imap"

// IMAPStub registers the imap connector type with a stub body.
//
// DEFERRED DEPENDENCY (research R2): a real IMAP connector needs an IMAP client
// library (e.g. github.com/emersion/go-imap) — there is no stdlib IMAP client.
// That is a NEW dependency requiring owner approval, deferred past this phase.
// Until then imap is a registered type whose Run emits nothing. The Gmail
// connector covers the "real mailbox" demo path over stdlib net/http. Filling
// this in later is one file + the dep approval — zero core changes.
type IMAPStub struct{}

// NewIMAPStub constructs the stub connector.
func NewIMAPStub() *IMAPStub { return &IMAPStub{} }

// Type implements Connector.
func (*IMAPStub) Type() string { return connectorTypeIMAP }

// Run logs intent and emits nothing (pending the deferred IMAP client dep).
func (*IMAPStub) Run(_ context.Context, cfg ConnectorConfig, _ intake.EmitFunc) error {
	slog.Info("connector.imap.stub", "connector_id", cfg.ConnectorID, "note", "stub: real IMAP client is a deferred dependency (research R2)")
	return nil
}
