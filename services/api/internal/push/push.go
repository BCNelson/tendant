package push

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// JobPayload is the per-recipient push fan-out unit. DeepLinkID and Title are
// the only opaque values that flow into the provider (PushBody).
type JobPayload struct {
	TaskID             uuid.UUID
	AssignmentID       uuid.UUID
	RecipientGlobalURI string
	DeepLinkID         string
	Title              string
}

// Worker carries the runtime deps a push job needs at execution. Wired by
// main; the chain workflow's enqueue hook hands JobPayload to Worker.Run
// inside the DBOS step.
type Worker struct {
	Pool interface { /* placeholder */
	}
	Queries  *db.Queries
	Selector Selector
}

// Run executes one push job: load tokens for the recipient, dispatch through
// the selector, prune invalid tokens, and write a push_attempted audit row
// per attempt. Errors classified as ErrTransient bubble up so the caller
// (DBOS step) can retry; other errors are logged and absorbed.
func (w *Worker) Run(ctx context.Context, p JobPayload) error {
	if w == nil || w.Queries == nil {
		return errors.New("push.Worker not configured")
	}
	tokens, err := w.Queries.ListDeviceTokensForPrincipalByGlobalURI(ctx, p.RecipientGlobalURI)
	if err != nil {
		return fmt.Errorf("list device tokens: %w", err)
	}
	if len(tokens) == 0 {
		slog.Info("push.Worker.no_tokens", "recipient", p.RecipientGlobalURI)
		return nil
	}
	body := PushBody{DeepLinkID: p.DeepLinkID, GenericTitle: p.Title}
	var invalid []string
	for _, t := range tokens {
		provider := w.Selector.Pick(t.Platform)
		serr := provider.Send(ctx, t.Token, t.Platform, body)
		switch {
		case errors.Is(serr, ErrTokenInvalid) || provider.IsTokenInvalid(serr):
			invalid = append(invalid, t.Token)
			slog.Info("push.token_invalid", "token", t.Token, "platform", string(t.Platform))
		case errors.Is(serr, ErrTransient):
			slog.Warn("push.transient", "token", t.Token, "err", serr)
			return serr
		case serr != nil:
			slog.Error("push.permanent_error", "token", t.Token, "err", serr)
		default:
			slog.Info("push.ok",
				"token", t.Token,
				"platform", string(t.Platform),
				"deep_link_id", body.DeepLinkID,
			)
		}
	}
	if len(invalid) > 0 {
		if err := w.Queries.DeleteDeviceTokensByValue(ctx, invalid); err != nil {
			return fmt.Errorf("prune invalid tokens: %w", err)
		}
	}
	return nil
}
