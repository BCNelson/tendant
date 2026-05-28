package push

import (
	"context"
	"errors"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ErrTransient signals that the provider attempt failed but a retry may
// succeed (e.g., APNs 5xx, FCM unavailable). The DBOS queue retry envelope
// catches this and re-runs the step.
var ErrTransient = errors.New("push: transient provider error")

// ErrTokenInvalid signals the provider rejected the token as permanently
// invalid (e.g., APNs Unregistered, FCM registration-token-not-registered).
// The fan-out worker prunes the row.
var ErrTokenInvalid = errors.New("push: token invalid")

// Provider is the per-platform send seam. Concrete implementations ship in
// `apns.go`, `fcm.go`, `log_provider.go`.
type Provider interface {
	Send(ctx context.Context, token string, platform db.DevicePlatform, body PushBody) error
	// IsTokenInvalid is provided as a convenience for callers that want to
	// classify provider-specific errors without unwrapping sentinels by
	// hand. Implementations may return true on `errors.Is(err, ErrTokenInvalid)`.
	IsTokenInvalid(err error) bool
	// Name is a stable identifier for logs / boot announce.
	Name() string
}
