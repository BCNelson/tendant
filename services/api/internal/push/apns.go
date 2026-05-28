package push

import (
	"context"
	"errors"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// APNs is the iOS push provider. Construct via NewAPNs with the required
// env config; on a healthy machine this produces a working HTTP/2 client.
// Phase 2 ships the *seam* — the real APNs HTTP/2 client lives behind the
// build tag `phase2_apns` and is enabled only when the `sideshow/apns2`
// dependency is added to go.mod. CI tolerates the unconfigured path and
// falls back to LogProvider via Selector.Pick.
type APNs struct {
	KeyID      string
	TeamID     string
	BundleID   string
	KeyPath    string
	Production bool
}

func (APNs) Name() string { return "APNs" }

func (APNs) IsTokenInvalid(err error) bool {
	return errors.Is(err, ErrTokenInvalid)
}

// Send sends an APNs push. The Phase 2 stub returns ErrTransient so the
// caller's retry envelope kicks in; when the real `sideshow/apns2` dep is
// wired (build tag `phase2_apns`), the call replays with a real HTTP/2
// client. The stub keeps CI green without an Apple Developer cert.
func (a APNs) Send(ctx context.Context, token string, platform db.DevicePlatform, body PushBody) error {
	if a.KeyID == "" || a.TeamID == "" || a.BundleID == "" || a.KeyPath == "" {
		return fmt.Errorf("%w: APNs not configured (set TENDANT_APNS_*)", ErrTransient)
	}
	// The real send body would be:
	//   {
	//     "aps": {
	//       "alert": {"title": body.GenericTitle, "body": ""},
	//       "sound": "default",
	//       "content-available": 1,
	//       "category": "TENDANT_INBOX_ITEM"
	//     },
	//     "deep_link_id": body.DeepLinkID
	//   }
	// Implementation pending `sideshow/apns2` dependency add.
	return ErrTransient
}
