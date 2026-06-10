package embedding_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

func newEmbedderTo(url string) embedding.Embedder {
	return embedding.NewEmbedder(embedding.Config{Provider: "openai", Model: "m", BaseURL: url})
}

func TestEmbed_EmptyInput(t *testing.T) {
	// No server should be hit for empty input.
	e := embedding.NewEmbedder(embedding.Config{Provider: "openai", BaseURL: "http://127.0.0.1:0"})
	vecs, err := e.Embed(context.Background(), nil)
	require.NoError(t, err)
	require.Nil(t, vecs)
}

func TestEmbed_RateLimitIsTransient(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusTooManyRequests)
	}))
	defer srv.Close()
	_, err := newEmbedderTo(srv.URL).Embed(context.Background(), []string{"x"})
	require.ErrorIs(t, err, embedding.ErrTransient)
}

func TestEmbed_ClientErrorIsStructural(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "bad request", http.StatusBadRequest)
	}))
	defer srv.Close()
	_, err := newEmbedderTo(srv.URL).Embed(context.Background(), []string{"x"})
	require.Error(t, err)
	require.NotErrorIs(t, err, embedding.ErrTransient, "4xx is a structural error, not transient")
}

func TestEmbed_MalformedBodyIsTransient(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte("not json"))
	}))
	defer srv.Close()
	_, err := newEmbedderTo(srv.URL).Embed(context.Background(), []string{"x"})
	require.ErrorIs(t, err, embedding.ErrTransient)
}

func TestEmbed_EmptyVectorIsError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"data":[{"index":0,"embedding":[]}]}`))
	}))
	defer srv.Close()
	_, err := newEmbedderTo(srv.URL).Embed(context.Background(), []string{"x"})
	require.Error(t, err)
}

func TestEmbed_LongErrorBodyTruncated(t *testing.T) {
	long := strings.Repeat("E", 1000)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(long))
	}))
	defer srv.Close()
	_, err := newEmbedderTo(srv.URL).Embed(context.Background(), []string{"x"})
	require.Error(t, err)
	require.Contains(t, err.Error(), "…", "long provider error body is truncated")
	require.Less(t, len(err.Error()), 700, "truncated, not the full 1000-char body")
}

func TestEmbed_AuthorizationHeader(t *testing.T) {
	var gotAuth string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotAuth = r.Header.Get("Authorization")
		_, _ = w.Write([]byte(`{"data":[{"index":0,"embedding":[0.1]}]}`))
	}))
	defer srv.Close()

	withKey := embedding.NewEmbedder(embedding.Config{Provider: "openai", BaseURL: srv.URL, APIKey: "secret"})
	_, err := withKey.Embed(context.Background(), []string{"x"})
	require.NoError(t, err)
	require.Equal(t, "Bearer secret", gotAuth)

	// No key ⇒ no Authorization header.
	gotAuth = "unset"
	noKey := newEmbedderTo(srv.URL)
	_, err = noKey.Embed(context.Background(), []string{"x"})
	require.NoError(t, err)
	require.Empty(t, gotAuth)
}
