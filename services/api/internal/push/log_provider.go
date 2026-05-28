package push

import (
	"context"
	"log/slog"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// LogProvider stands in when no real provider is configured (FR-018). Its
// Send emits a single structured slog line with token, platform, generic
// title, and deep-link id — and *nothing else*. SC-003's content-leak
// verification reads back the captured slog record and asserts the field
// set exactly.
type LogProvider struct{}

func (LogProvider) Name() string                  { return "LogProvider" }
func (LogProvider) IsTokenInvalid(err error) bool { return false }

func (LogProvider) Send(ctx context.Context, token string, platform db.DevicePlatform, body PushBody) error {
	slog.Info("push.LogProvider.Send",
		"token", token,
		"platform", string(platform),
		"title", body.GenericTitle,
		"deep_link_id", body.DeepLinkID,
	)
	return nil
}
