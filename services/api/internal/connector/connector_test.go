package connector_test

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/connector"
	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// fakeDoer returns a canned HTTP response body for any request.
type fakeDoer struct {
	status int
	body   string
}

func (f fakeDoer) Do(*http.Request) (*http.Response, error) {
	status := f.status
	if status == 0 {
		status = http.StatusOK
	}
	return &http.Response{
		StatusCode: status,
		Body:       io.NopCloser(strings.NewReader(f.body)),
		Header:     make(http.Header),
	}, nil
}

// collect runs a connector and gathers every emitted signal.
func collect(t *testing.T, c connector.Connector, cfg connector.ConnectorConfig) []intake.PotentialTaskSignal {
	t.Helper()
	var got []intake.PotentialTaskSignal
	err := c.Run(context.Background(), cfg, func(s intake.PotentialTaskSignal) error {
		got = append(got, s)
		return nil
	})
	require.NoError(t, err)
	return got
}

// T028 — rss fixture feed → one forced_task signal with provenance.
func TestRSS_EmitsForcedTaskWithProvenance(t *testing.T) {
	feed := `<?xml version="1.0"?>
<rss version="2.0"><channel><title>Releases</title>
  <item><title>v1.2.0</title><link>https://x/1</link><guid>guid-1</guid><description>notes</description></item>
</channel></rss>`
	c := connector.NewRSS(fakeDoer{body: feed})
	cid := uuid.New()
	cfg := connector.ConnectorConfig{
		ConnectorID:   cid,
		ConnectorType: "rss",
		Filter:        json.RawMessage(`{"feed":"https://example.com/releases.xml"}`),
	}
	got := collect(t, c, cfg)
	require.Len(t, got, 1)
	require.Equal(t, intake.DispositionForcedTask, got[0].Disposition)
	require.Equal(t, intake.SignalVersion, got[0].SignalVersion)
	require.Contains(t, got[0].Provenance.RawRef, "guid-1")
	require.NotEmpty(t, got[0].IdempotencyKey)
}

// T028b — rss disposition override via filter.
func TestRSS_DispositionOverride(t *testing.T) {
	feed := `<rss version="2.0"><channel><title>News</title>
	  <item><title>headline</title><guid>g</guid></item></channel></rss>`
	c := connector.NewRSS(fakeDoer{body: feed})
	cfg := connector.ConnectorConfig{
		ConnectorID: uuid.New(),
		Filter:      json.RawMessage(`{"feed":"https://f","disposition":"llm_judge"}`),
	}
	got := collect(t, c, cfg)
	require.Len(t, got, 1)
	require.Equal(t, intake.DispositionLLMJudge, got[0].Disposition)
}

// T047 — an unchanged RSS item across polls keeps the same idempotency key.
func TestRSS_StableIdempotencyKey(t *testing.T) {
	feed := `<rss version="2.0"><channel><title>F</title><item><title>t</title><guid>stable</guid></item></channel></rss>`
	cfg := connector.ConnectorConfig{ConnectorID: uuid.New(), Filter: json.RawMessage(`{"feed":"https://f"}`)}
	a := collect(t, connector.NewRSS(fakeDoer{body: feed}), cfg)
	b := collect(t, connector.NewRSS(fakeDoer{body: feed}), cfg)
	require.Equal(t, a[0].IdempotencyKey, b[0].IdempotencyKey)
}

// T029 — webhook-in inbound item → one signal.
func TestWebhookIn_EmitsQueuedItem(t *testing.T) {
	queue := &connector.MemoryInboundQueue{}
	queue.Push(connector.InboundItem{
		IdempotencyKey: "evt-1",
		Payload:        json.RawMessage(`{"title":"hook"}`),
		RawRef:         "webhook:evt-1",
		Reason:         "inbound delivery",
	})
	c := connector.NewWebhookIn(queue)
	got := collect(t, c, connector.ConnectorConfig{ConnectorID: uuid.New()})
	require.Len(t, got, 1)
	require.Equal(t, "evt-1", got[0].IdempotencyKey)
	require.Equal(t, intake.DispositionForcedTask, got[0].Disposition) // default
	// Queue is drained — a second run emits nothing.
	require.Empty(t, collect(t, c, connector.ConnectorConfig{ConnectorID: uuid.New()}))
}

// T030 — gmail with a faked messageFetcher (list/get → emit).
func TestGmail_FakeFetcher(t *testing.T) {
	fetcher := &fakeFetcher{
		ids: []string{"m1"},
		msgs: map[string]connector.GmailMessage{
			"m1": {ID: "m1", From: "billing@acme.com", Subject: "Invoice", Snippet: "due"},
		},
	}
	c := connector.NewGmail(fetcher)
	cfg := connector.ConnectorConfig{
		ConnectorID:   uuid.New(),
		ConnectorType: "gmail",
		Filter:        json.RawMessage(`{"query":"from:billing@acme.com"}`),
		Credentials:   staticCreds{token: "tok"},
	}
	got := collect(t, c, cfg)
	require.Len(t, got, 1)
	require.Equal(t, "m1", got[0].IdempotencyKey)
	require.Contains(t, got[0].Provenance.RawRef, "gmail:message/m1")
	require.Equal(t, "tok", fetcher.sawToken)
}

// T019 — calendar/imap stubs emit nothing.
func TestStubs_EmitNothing(t *testing.T) {
	cfg := connector.ConnectorConfig{ConnectorID: uuid.New()}
	require.Empty(t, collect(t, connector.NewCalendarStub(), cfg))
	require.Empty(t, collect(t, connector.NewIMAPStub(), cfg))
}

// --- fakes ------------------------------------------------------------------

type fakeFetcher struct {
	ids      []string
	msgs     map[string]connector.GmailMessage
	sawToken string
}

func (f *fakeFetcher) List(_ context.Context, accessToken, _ string) ([]string, error) {
	f.sawToken = accessToken
	return f.ids, nil
}

func (f *fakeFetcher) Get(_ context.Context, _, id string) (connector.GmailMessage, error) {
	return f.msgs[id], nil
}

type staticCreds struct{ token string }

func (s staticCreds) Token(context.Context) (intake.TokenBundle, error) {
	return intake.TokenBundle{AccessToken: s.token}, nil
}
