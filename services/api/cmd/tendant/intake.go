package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/graph"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/connector"
	"github.com/bcnelson/tendant/services/api/internal/crypto"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// intakeWiring bundles the constructed intake-edge pieces main hands to the
// DBOS registration, the HTTP routes, and the GraphQL resolver.
type intakeWiring struct {
	registry  *connector.Registry
	disposer  *intake.Disposer
	credStore *intake.SealedCredentialStore
	refresher intake.RefresherFactory
	inbound   *connector.MemoryInboundQueue
	metrics   *intake.Metrics
}

// buildIntakeWiring constructs the connector registry (base set), the
// disposition router, and the credential store. The credential store is nil
// when TENDANT_CREDENTIALS_KEY is unset — credentialed connectors then surface
// the gap rather than crashing boot (zero-credential connectors still work).
func buildIntakeWiring(pool *pgxpool.Pool, q *db.Queries, dctx dbos.DBOSContext, cfg *config.Config) intakeWiring {
	inbound := &connector.MemoryInboundQueue{}
	registry := connector.NewRegistry()
	connector.RegisterBaseSet(registry, inbound)

	metrics := intake.NewMetrics()
	disposer := &intake.Disposer{
		Pool:    pool,
		DBOS:    dctx,
		Queries: q,
		// Triage is nil by default — llm_judge fails closed to PROPOSED with no
		// model call (NFR-003). Opt-in model wiring lands behind an env flag.
		Triage:  buildIntakeTriage(),
		Metrics: metrics,
	}

	var credStore *intake.SealedCredentialStore
	if sealer, err := crypto.NewFromBase64(cfg.Credentials.Key); err == nil {
		credStore = intake.NewSealedCredentialStore(q, sealer)
	} else {
		slog.Warn("intake: credentials.key not set — credentialed connectors (gmail) cannot poll", "err", err)
	}

	return intakeWiring{
		registry:  registry,
		disposer:  disposer,
		credStore: credStore,
		refresher: gmailRefresherFactory(cfg),
		inbound:   inbound,
		metrics:   metrics,
	}
}

// buildIntakeTriage selects the llm_judge triage seam. Default nil (secure:
// llm_judge holds PROPOSED with no model). The provider is intentionally not
// runtime-addressable (a connector cannot reroute inference).
func buildIntakeTriage() intake.TriageJudge {
	// Reserved for an opt-in model-backed triage judge (TENDANT_INTAKE_TRIAGE_*).
	// Left nil so the secure default holds until explicitly configured.
	return nil
}

// gmailRefresherFactory returns a RefresherFactory that builds a Gmail token
// refresher for connector_type "gmail" using TENDANT_GMAIL_CLIENT_ID/SECRET.
func gmailRefresherFactory(cfg *config.Config) intake.RefresherFactory {
	clientID := cfg.Intake.GmailClientID
	clientSecret := cfg.Intake.GmailClientSecret
	return func(connectorType string, _ uuid.UUID) intake.TokenRefresher {
		if connectorType != "gmail" {
			return nil
		}
		return &connector.GmailTokenRefresher{ClientID: clientID, ClientSecret: clientSecret}
	}
}

// connectorResolverDeps wires the GraphQL owner mutations to the registry +
// scheduler without graph importing connector/intake.
func (w intakeWiring) connectorResolverDeps() graph.ConnectorDeps {
	return graph.ConnectorDeps{
		HasType:        w.registry.Has,
		CreateSchedule: intake.CreateSchedule,
		DeleteSchedule: intake.DeleteSchedule,
	}
}

// webhookIngressHandler accepts an inbound delivery for a webhook-in connector
// and queues it for the next poll. POST /intake/webhook/{connectorID} with a
// JSON body shaped like connector.InboundItem.
func webhookIngressHandler(inbound *connector.MemoryInboundQueue) http.Handler {
	return http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {
		if req.Method != http.MethodPost {
			http.Error(rw, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		connectorID := chi.URLParam(req, "*")
		if _, err := uuid.Parse(strings.Trim(connectorID, "/")); err != nil {
			http.Error(rw, "invalid connector id in path", http.StatusBadRequest)
			return
		}
		body, err := io.ReadAll(io.LimitReader(req.Body, 1<<20))
		if err != nil {
			http.Error(rw, "read body", http.StatusBadRequest)
			return
		}
		var item connector.InboundItem
		if err := json.Unmarshal(body, &item); err != nil {
			http.Error(rw, "invalid JSON body", http.StatusBadRequest)
			return
		}
		if item.IdempotencyKey == "" {
			http.Error(rw, "idempotency_key is required", http.StatusBadRequest)
			return
		}
		inbound.Push(item)
		rw.WriteHeader(http.StatusAccepted)
	})
}

// oauthCallbackHandler completes the OAuth code exchange for a connector and
// seals the token bundle into source_credentials (research R7). The provider
// redirects here with ?code=...&state=<connectorID>. Gmail only this phase.
func oauthCallbackHandler(credStore *intake.SealedCredentialStore, cfg *config.Config) http.Handler {
	return http.HandlerFunc(func(rw http.ResponseWriter, req *http.Request) {
		connectorType := strings.Trim(chi.URLParam(req, "*"), "/")
		if connectorType != "gmail" {
			http.Error(rw, "unsupported connector type for oauth callback", http.StatusBadRequest)
			return
		}
		if credStore == nil {
			http.Error(rw, "credential store not configured (TENDANT_CREDENTIALS_KEY unset)", http.StatusServiceUnavailable)
			return
		}
		code := req.URL.Query().Get("code")
		state := req.URL.Query().Get("state")
		connectorID, err := uuid.Parse(state)
		if err != nil {
			http.Error(rw, "invalid state (expected connector id)", http.StatusBadRequest)
			return
		}
		if code == "" {
			http.Error(rw, "missing code", http.StatusBadRequest)
			return
		}
		bundle, err := exchangeGmailCode(req.Context(), code, cfg)
		if err != nil {
			slog.Error("intake.oauth.exchange_failed", "connector_id", connectorID, "err", err)
			http.Error(rw, "code exchange failed", http.StatusBadGateway)
			return
		}
		if err := credStore.Upsert(req.Context(), connectorID, bundle); err != nil {
			http.Error(rw, "seal credentials failed", http.StatusInternalServerError)
			return
		}
		slog.Info("intake.oauth.sealed", "connector_id", connectorID, "connector_type", connectorType)
		_, _ = rw.Write([]byte("connected; you may close this window."))
	})
}

// exchangeGmailCode exchanges an authorization code for a token bundle at the
// Google token endpoint over stdlib net/http (no oauth2 dependency).
func exchangeGmailCode(ctx context.Context, code string, cfg *config.Config) (intake.TokenBundle, error) {
	form := url.Values{
		"client_id":     {cfg.Intake.GmailClientID},
		"client_secret": {cfg.Intake.GmailClientSecret},
		"code":          {code},
		"grant_type":    {"authorization_code"},
		"redirect_uri":  {cfg.Intake.GmailRedirectURL},
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://oauth2.googleapis.com/token", strings.NewReader(form.Encode()))
	if err != nil {
		return intake.TokenBundle{}, err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return intake.TokenBundle{}, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
		return intake.TokenBundle{}, fmt.Errorf("token endpoint status %d: %s", resp.StatusCode, string(b))
	}
	var out struct {
		AccessToken  string `json:"access_token"`
		RefreshToken string `json:"refresh_token"`
		ExpiresIn    int    `json:"expires_in"`
		TokenType    string `json:"token_type"`
		Scope        string `json:"scope"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return intake.TokenBundle{}, err
	}
	bundle := intake.TokenBundle{
		AccessToken:  out.AccessToken,
		RefreshToken: out.RefreshToken,
		TokenType:    out.TokenType,
	}
	if out.ExpiresIn > 0 {
		bundle.ExpiresAt = time.Now().Add(time.Duration(out.ExpiresIn) * time.Second)
	}
	if out.Scope != "" {
		bundle.Scopes = strings.Fields(out.Scope)
	}
	return bundle, nil
}
