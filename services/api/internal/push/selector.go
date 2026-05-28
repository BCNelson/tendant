package push

import "github.com/bcnelson/tendant/services/api/internal/db"

// Selector routes platform → provider. If APNs and FCM are both nil, every
// platform routes to Log (fallback for dev / CI / single-household
// no-credentials boot per FR-018).
type Selector struct {
	APNs Provider
	FCM  Provider
	Log  Provider
}

// Pick returns the provider for the platform. Falls back to Log when neither
// real provider is configured.
func (s Selector) Pick(platform db.DevicePlatform) Provider {
	if s.APNs == nil && s.FCM == nil {
		return s.Log
	}
	switch platform {
	case db.DevicePlatformIos:
		if s.APNs != nil {
			return s.APNs
		}
	case db.DevicePlatformAndroid, db.DevicePlatformWeb:
		if s.FCM != nil {
			return s.FCM
		}
	}
	return s.Log
}

// Name returns the human-readable name of the configured stack, for boot
// logging (e.g., "APNs+FCM", "FCM", "LogProvider").
func (s Selector) Name() string {
	switch {
	case s.APNs != nil && s.FCM != nil:
		return "APNs+FCM"
	case s.APNs != nil:
		return "APNs"
	case s.FCM != nil:
		return "FCM"
	}
	return "LogProvider"
}
