package tools

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
)

// SendEmailGlobalURI is the stable identity of the Phase 3 send-email tool.
const SendEmailGlobalURI = "tendant://tools/send-email"

// SendEmailPayload is the v1 shape of a send-email call. Kept intentionally
// minimal: one recipient, one subject, one body. Multi-recipient and
// templating wait for a later phase.
type SendEmailPayload struct {
	To      string `json:"to"`
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

// Validate enforces the v1 shape. Empty `to` is a misconfiguration; the
// tool rejects it rather than letting the provider silently no-op.
func (p SendEmailPayload) Validate() error {
	if p.To == "" {
		return fmt.Errorf("send-email: payload.to is required")
	}
	if p.Subject == "" {
		return fmt.Errorf("send-email: payload.subject is required")
	}
	return nil
}

// EmailProvider is the seam to whatever actually delivers the message.
// Mirrors internal/push.Provider — Phase 3 ships LogProvider only; real
// SMTP/HTTP providers slot in for Phase 7 (credentials at rest).
type EmailProvider interface {
	Send(ctx context.Context, p SendEmailPayload) (Result, error)
}

// SendEmail implements Tool by delegating to an EmailProvider.
type SendEmail struct {
	Provider EmailProvider
}

// NewSendEmail wires the tool with the given provider. nil provider
// defaults to a LogProvider so dev / CI / tests work without configuration.
func NewSendEmail(p EmailProvider) *SendEmail {
	if p == nil {
		p = LogProvider{Logger: slog.Default()}
	}
	return &SendEmail{Provider: p}
}

// GlobalURI satisfies Tool.
func (s *SendEmail) GlobalURI() string { return SendEmailGlobalURI }

// Execute unmarshals + validates + delegates. Errors from the provider
// surface to the workflow, which records an outcome=bad row.
func (s *SendEmail) Execute(ctx context.Context, payload json.RawMessage) (Result, error) {
	var p SendEmailPayload
	if err := json.Unmarshal(payload, &p); err != nil {
		return Result{}, fmt.Errorf("send-email: unmarshal payload: %w", err)
	}
	if err := p.Validate(); err != nil {
		return Result{}, err
	}
	return s.Provider.Send(ctx, p)
}

// LogProvider writes a structured log line and returns success. It is the
// default in dev / CI; production deployments swap in a real provider once
// credentials are wired (Phase 7).
type LogProvider struct {
	Logger *slog.Logger
}

// Send records the intended message and returns a clean Result.
func (l LogProvider) Send(_ context.Context, p SendEmailPayload) (Result, error) {
	logger := l.Logger
	if logger == nil {
		logger = slog.Default()
	}
	logger.Info("tools.send_email.dispatch",
		"provider", "log",
		"to", p.To,
		"subject", p.Subject,
		"body_len", len(p.Body),
	)
	detail, _ := json.Marshal(map[string]string{"to": p.To, "subject": p.Subject})
	return Result{Provider: "log", Detail: detail}, nil
}
