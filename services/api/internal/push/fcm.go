package push

import (
	"context"
	"errors"
	"fmt"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// FCM is the Android / Web push provider. Construct via NewFCM with the
// Firebase Admin credentials in env (GOOGLE_APPLICATION_CREDENTIALS +
// TENDANT_FCM_PROJECT_ID). Phase 2 ships the *seam*; the real
// `firebase.google.com/go/v4/messaging` call lands when the dep is added.
type FCM struct {
	ProjectID           string
	CredentialsJSONPath string
}

func (FCM) Name() string { return "FCM" }

func (FCM) IsTokenInvalid(err error) bool {
	return errors.Is(err, ErrTokenInvalid)
}

// Send sends an FCM v1 push. The Phase 2 stub returns ErrTransient when
// unconfigured; the real client (Firebase Admin SDK) wires in when the
// `firebase.google.com/go/v4` dependency lands.
func (f FCM) Send(ctx context.Context, token string, platform db.DevicePlatform, body PushBody) error {
	if f.ProjectID == "" || f.CredentialsJSONPath == "" {
		return fmt.Errorf("%w: FCM not configured (set GOOGLE_APPLICATION_CREDENTIALS, TENDANT_FCM_PROJECT_ID)", ErrTransient)
	}
	// The real send body would be:
	//   {
	//     "message": {
	//       "token": token,
	//       "notification": {"title": body.GenericTitle, "body": ""},
	//       "data": {"deep_link_id": body.DeepLinkID},
	//       "android": {"priority": "HIGH"},
	//       "apns": {"headers": {"apns-priority": "10"}},
	//       "webpush": {"headers": {"Urgency": "high"}}
	//     }
	//   }
	// Implementation pending `firebase.google.com/go/v4` dependency add.
	return ErrTransient
}
