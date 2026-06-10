package embedding_test

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

func TestOpenAIEmbedder_Embed(t *testing.T) {
	var gotPath string
	var gotBody map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotPath = r.URL.Path
		body, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(body, &gotBody)
		// Return vectors out of order to prove index-sorting.
		_, _ = w.Write([]byte(`{"data":[{"index":1,"embedding":[0.3,0.4]},{"index":0,"embedding":[0.1,0.2]}]}`))
	}))
	defer srv.Close()

	e := embedding.NewEmbedder(embedding.Config{Provider: "openai", Model: "m", BaseURL: srv.URL, Dimension: 2})
	require.NotNil(t, e)
	vecs, err := e.Embed(context.Background(), []string{"a", "b"})
	require.NoError(t, err)
	require.Equal(t, "/embeddings", gotPath)
	require.Equal(t, "m", gotBody["model"])
	require.Len(t, vecs, 2)
	require.Equal(t, []float32{0.1, 0.2}, vecs[0]) // re-ordered by index
	require.Equal(t, []float32{0.3, 0.4}, vecs[1])
}

func TestOpenAIEmbedder_Transient(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer srv.Close()
	e := embedding.NewEmbedder(embedding.Config{Provider: "openai", BaseURL: srv.URL})
	_, err := e.Embed(context.Background(), []string{"x"})
	require.ErrorIs(t, err, embedding.ErrTransient)
}

func TestNewEmbedder_DisabledProviders(t *testing.T) {
	require.Nil(t, embedding.NewEmbedder(embedding.Config{Provider: ""}))
	require.Nil(t, embedding.NewEmbedder(embedding.Config{Provider: "log"}))
	require.NotNil(t, embedding.NewEmbedder(embedding.Config{Provider: "openai"}))
}

func TestOpenAIEmbedder_CountMismatch(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte(`{"data":[{"index":0,"embedding":[0.1]}]}`))
	}))
	defer srv.Close()
	e := embedding.NewEmbedder(embedding.Config{Provider: "openai", BaseURL: srv.URL})
	_, err := e.Embed(context.Background(), []string{"a", "b"})
	require.Error(t, err)
	require.False(t, errors.Is(err, embedding.ErrTransient)) // structural, not transient
}
