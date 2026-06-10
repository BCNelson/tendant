package embedding

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sort"
	"time"
)

// openAIEmbedder speaks the OpenAI `/v1/embeddings` protocol, the de-facto
// standard also served by Ollama, vLLM, LM Studio, Together, etc. The operator
// points BaseURL at the right host.
type openAIEmbedder struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	model      string
	dimension  int
}

func newOpenAIEmbedder(cfg Config) *openAIEmbedder {
	base := cfg.BaseURL
	if base == "" {
		base = "https://api.openai.com/v1"
	}
	model := cfg.Model
	if model == "" {
		model = "text-embedding-3-small"
	}
	return &openAIEmbedder{
		httpClient: &http.Client{Timeout: 30 * time.Second},
		baseURL:    base,
		apiKey:     cfg.APIKey,
		model:      model,
		dimension:  cfg.Dimension,
	}
}

func (e *openAIEmbedder) Provider() string { return "openai" }
func (e *openAIEmbedder) Model() string    { return e.model }
func (e *openAIEmbedder) Dimension() int   { return e.dimension }

type openAIEmbedReq struct {
	Model string   `json:"model"`
	Input []string `json:"input"`
}

type openAIEmbedResp struct {
	Data []struct {
		Index     int       `json:"index"`
		Embedding []float32 `json:"embedding"`
	} `json:"data"`
}

func (e *openAIEmbedder) Embed(ctx context.Context, texts []string) ([][]float32, error) {
	if len(texts) == 0 {
		return nil, nil
	}
	body, err := json.Marshal(openAIEmbedReq{Model: e.model, Input: texts})
	if err != nil {
		return nil, fmt.Errorf("embedding: marshal request: %w", err)
	}
	url := e.baseURL + "/embeddings"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("embedding: new request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if e.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+e.apiKey)
	}

	resp, err := e.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("embedding: %w: %v", ErrTransient, err)
	}
	defer resp.Body.Close()
	raw, err := io.ReadAll(io.LimitReader(resp.Body, 64<<20))
	if err != nil {
		return nil, fmt.Errorf("embedding: %w: read body: %v", ErrTransient, err)
	}
	if resp.StatusCode >= 500 || resp.StatusCode == http.StatusTooManyRequests {
		return nil, fmt.Errorf("embedding: %w: status %d: %s", ErrTransient, resp.StatusCode, truncate(raw))
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("embedding: status %d: %s", resp.StatusCode, truncate(raw))
	}

	var parsed openAIEmbedResp
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return nil, fmt.Errorf("embedding: %w: decode body: %v", ErrTransient, err)
	}
	if len(parsed.Data) != len(texts) {
		return nil, fmt.Errorf("embedding: expected %d vectors, got %d", len(texts), len(parsed.Data))
	}
	// The API returns each datum with its input index; sort to guarantee order.
	sort.Slice(parsed.Data, func(i, j int) bool { return parsed.Data[i].Index < parsed.Data[j].Index })
	out := make([][]float32, len(parsed.Data))
	for i, d := range parsed.Data {
		if len(d.Embedding) == 0 {
			return nil, fmt.Errorf("embedding: empty vector at index %d", i)
		}
		out[i] = d.Embedding
	}
	return out, nil
}

func truncate(b []byte) string {
	const max = 512
	if len(b) > max {
		return string(b[:max]) + "…"
	}
	return string(b)
}
