package connector

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/bcnelson/tendant/services/api/internal/intake"
)

const connectorTypeGmail = "gmail"

// gmailFilter is the connector-side coarse filter: a Gmail search query and the
// disposition matched messages carry (default forced_task).
type gmailFilter struct {
	Query       string `json:"query"`
	Disposition string `json:"disposition"`
}

// GmailMessage is the normalized subset a Gmail message contributes to a
// signal payload — the connector is the privacy firewall, so this is all that
// can ever reach a model (via llm_judge).
type GmailMessage struct {
	ID      string `json:"id"`
	From    string `json:"from"`
	Subject string `json:"subject"`
	Snippet string `json:"snippet"`
}

// messageFetcher is the live-call seam (research R3): tests inject a fake; the
// default httpGmailFetcher talks to the Gmail REST API over stdlib net/http.
type messageFetcher interface {
	List(ctx context.Context, accessToken, query string) ([]string, error)
	Get(ctx context.Context, accessToken, id string) (GmailMessage, error)
}

// Gmail is the OAuth-exemplar connector. It reads via the messageFetcher seam
// and authenticates with the access token from cfg.Credentials (refreshed in
// the credential accessor when near expiry — research R7). Idempotency key =
// the Gmail message id.
type Gmail struct {
	fetcher messageFetcher
}

// NewGmail constructs the connector. A nil fetcher uses the default HTTP fetcher.
func NewGmail(fetcher messageFetcher) *Gmail {
	if fetcher == nil {
		fetcher = &httpGmailFetcher{doer: http.DefaultClient}
	}
	return &Gmail{fetcher: fetcher}
}

// Type implements Connector.
func (*Gmail) Type() string { return connectorTypeGmail }

// Run lists matching messages, gets each, and emits one signal per message.
func (c *Gmail) Run(ctx context.Context, cfg ConnectorConfig, emit intake.EmitFunc) error {
	if cfg.Credentials == nil {
		return fmt.Errorf("gmail: no credentials configured for connector %s", cfg.ConnectorID)
	}
	bundle, err := cfg.Credentials.Token(ctx)
	if err != nil {
		return fmt.Errorf("gmail: load credentials: %w", err)
	}

	var f gmailFilter
	if len(cfg.Filter) > 0 {
		if err := json.Unmarshal(cfg.Filter, &f); err != nil {
			return fmt.Errorf("gmail: parse filter: %w", err)
		}
	}
	disposition := f.Disposition
	if disposition == "" {
		disposition = intake.DispositionForcedTask
	}

	ids, err := c.fetcher.List(ctx, bundle.AccessToken, f.Query)
	if err != nil {
		return fmt.Errorf("gmail: list messages: %w", err)
	}
	for _, id := range ids {
		if err := ctx.Err(); err != nil {
			return err
		}
		msg, err := c.fetcher.Get(ctx, bundle.AccessToken, id)
		if err != nil {
			return fmt.Errorf("gmail: get message %s: %w", id, err)
		}
		payload, err := json.Marshal(map[string]string{
			"subject": msg.Subject,
			"from":    msg.From,
			"snippet": msg.Snippet,
		})
		if err != nil {
			return fmt.Errorf("gmail: marshal payload: %w", err)
		}
		sig := intake.PotentialTaskSignal{
			SignalVersion:  intake.SignalVersion,
			SourceID:       sourceID(connectorTypeGmail, cfg.ConnectorID),
			IdempotencyKey: msg.ID,
			Provenance: intake.Provenance{
				RawRef: fmt.Sprintf("gmail:message/%s", msg.ID),
				Reason: fmt.Sprintf("matched filter: %s", f.Query),
			},
			Payload:     payload,
			Disposition: disposition,
		}
		if err := emit(sig); err != nil {
			return err
		}
	}
	return nil
}

// --- Default HTTP fetcher (Gmail REST over stdlib net/http). -----------------

const gmailAPIBase = "https://gmail.googleapis.com/gmail/v1/users/me"

type httpGmailFetcher struct {
	doer httpDoer
}

func (h *httpGmailFetcher) List(ctx context.Context, accessToken, query string) ([]string, error) {
	u := gmailAPIBase + "/messages?maxResults=25"
	if query != "" {
		u += "&q=" + url.QueryEscape(query)
	}
	var out struct {
		Messages []struct {
			ID string `json:"id"`
		} `json:"messages"`
	}
	if err := h.getJSON(ctx, u, accessToken, &out); err != nil {
		return nil, err
	}
	ids := make([]string, 0, len(out.Messages))
	for _, m := range out.Messages {
		ids = append(ids, m.ID)
	}
	return ids, nil
}

func (h *httpGmailFetcher) Get(ctx context.Context, accessToken, id string) (GmailMessage, error) {
	u := fmt.Sprintf("%s/messages/%s?format=metadata&metadataHeaders=From&metadataHeaders=Subject", gmailAPIBase, id)
	var out struct {
		ID      string `json:"id"`
		Snippet string `json:"snippet"`
		Payload struct {
			Headers []struct {
				Name  string `json:"name"`
				Value string `json:"value"`
			} `json:"headers"`
		} `json:"payload"`
	}
	if err := h.getJSON(ctx, u, accessToken, &out); err != nil {
		return GmailMessage{}, err
	}
	msg := GmailMessage{ID: out.ID, Snippet: out.Snippet}
	for _, hdr := range out.Payload.Headers {
		switch strings.ToLower(hdr.Name) {
		case "from":
			msg.From = hdr.Value
		case "subject":
			msg.Subject = hdr.Value
		}
	}
	return msg, nil
}

func (h *httpGmailFetcher) getJSON(ctx context.Context, u, accessToken string, dst any) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, http.NoBody)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+accessToken)
	resp, err := h.doer.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return fmt.Errorf("gmail api status %d: %s", resp.StatusCode, string(body))
	}
	return json.NewDecoder(resp.Body).Decode(dst)
}

// --- OAuth token refresh (Google token endpoint over net/http). --------------

const googleTokenEndpoint = "https://oauth2.googleapis.com/token"

// GmailTokenRefresher exchanges a refresh token for a fresh access token at the
// Google token endpoint. It implements intake.TokenRefresher; main wires it
// into the credential accessor for gmail connectors.
type GmailTokenRefresher struct {
	ClientID     string
	ClientSecret string
	Doer         httpDoer
}

// Refresh implements intake.TokenRefresher.
func (g *GmailTokenRefresher) Refresh(ctx context.Context, refreshToken string) (intake.TokenBundle, error) {
	doer := g.Doer
	if doer == nil {
		doer = http.DefaultClient
	}
	form := url.Values{
		"client_id":     {g.ClientID},
		"client_secret": {g.ClientSecret},
		"refresh_token": {refreshToken},
		"grant_type":    {"refresh_token"},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, googleTokenEndpoint, strings.NewReader(form.Encode()))
	if err != nil {
		return intake.TokenBundle{}, err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := doer.Do(req)
	if err != nil {
		return intake.TokenBundle{}, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return intake.TokenBundle{}, fmt.Errorf("google token endpoint status %d: %s", resp.StatusCode, string(body))
	}
	var out struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
		TokenType   string `json:"token_type"`
		Scope       string `json:"scope"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return intake.TokenBundle{}, err
	}
	bundle := intake.TokenBundle{
		AccessToken: out.AccessToken,
		TokenType:   out.TokenType,
	}
	if out.ExpiresIn > 0 {
		bundle.ExpiresAt = time.Now().Add(time.Duration(out.ExpiresIn) * time.Second)
	}
	if out.Scope != "" {
		bundle.Scopes = strings.Fields(out.Scope)
	}
	return bundle, nil
}
