package push_test

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/push"
)

func TestLogProviderEmitsOnlyExpectedFields(t *testing.T) {
	t.Parallel()
	var buf bytes.Buffer
	h := slog.NewJSONHandler(&buf, &slog.HandlerOptions{Level: slog.LevelInfo})
	prev := slog.Default()
	slog.SetDefault(slog.New(h))
	defer slog.SetDefault(prev)

	p := push.LogProvider{}
	err := p.Send(context.Background(), "tok-1", db.DevicePlatformIos, push.PushBody{
		DeepLinkID:   "deep-1",
		GenericTitle: "tendant",
	})
	require.NoError(t, err)

	var rec map[string]any
	require.NoError(t, json.Unmarshal(bytes.TrimSpace(buf.Bytes()), &rec))
	// SC-003: the structured record carries the bookkeeping fields plus
	// exactly token / platform / title / deep_link_id. Nothing else from
	// the body shape ever leaves.
	wantKeys := map[string]bool{
		"time": true, "level": true, "msg": true,
		"token": true, "platform": true, "title": true, "deep_link_id": true,
	}
	for k := range rec {
		if !wantKeys[k] {
			t.Fatalf("unexpected key in LogProvider record: %q (record=%v)", k, rec)
		}
	}
	require.Equal(t, "tok-1", rec["token"])
	require.Equal(t, "ios", rec["platform"])
	require.Equal(t, "tendant", rec["title"])
	require.Equal(t, "deep-1", rec["deep_link_id"])
}

func TestSelectorPick(t *testing.T) {
	t.Parallel()
	log := push.LogProvider{}

	// Fallback when both real providers are nil.
	s := push.Selector{Log: log}
	require.Equal(t, "LogProvider", s.Pick(db.DevicePlatformIos).Name())
	require.Equal(t, "LogProvider", s.Pick(db.DevicePlatformAndroid).Name())
	require.Equal(t, "LogProvider", s.Pick(db.DevicePlatformWeb).Name())
	require.Equal(t, "LogProvider", s.Name())

	// With both real providers, route per platform.
	fakeA := &fakeNamedProvider{name: "APNs"}
	fakeF := &fakeNamedProvider{name: "FCM"}
	s = push.Selector{APNs: fakeA, FCM: fakeF, Log: log}
	require.Equal(t, "APNs", s.Pick(db.DevicePlatformIos).Name())
	require.Equal(t, "FCM", s.Pick(db.DevicePlatformAndroid).Name())
	require.Equal(t, "FCM", s.Pick(db.DevicePlatformWeb).Name())
	require.Equal(t, "APNs+FCM", s.Name())
}

func TestShouldPush(t *testing.T) {
	t.Parallel()
	owner := "local://principal/owner"

	require.True(t, push.ShouldPush(push.InboxRow{Kind: "pending_decision"}))
	require.True(t, push.ShouldPush(push.InboxRow{Kind: "agent_assignment", ToPrincipal: &owner}))
	require.False(t, push.ShouldPush(push.InboxRow{Kind: "agent_assignment", ToPrincipal: nil}))
	empty := ""
	require.False(t, push.ShouldPush(push.InboxRow{Kind: "agent_assignment", ToPrincipal: &empty}))
	require.False(t, push.ShouldPush(push.InboxRow{Kind: "task_state_changed"}))
}

type fakeNamedProvider struct {
	name string
}

func (f *fakeNamedProvider) Name() string                  { return f.name }
func (f *fakeNamedProvider) IsTokenInvalid(err error) bool { return false }
func (f *fakeNamedProvider) Send(_ context.Context, _ string, _ db.DevicePlatform, _ push.PushBody) error {
	return nil
}
