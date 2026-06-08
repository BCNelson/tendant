package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

// bedrockClient invokes models on AWS Bedrock's runtime
// (POST /model/{modelId}/invoke), signed with SigV4. It targets the
// Anthropic-family models on Bedrock — the dominant Bedrock use case for an
// app like this — by reusing the Anthropic Messages body shape with
// `anthropic_version: bedrock-2023-05-31` and no `model` field (the model is
// in the URL). Credentials come from the Connection (static keys or STS).
type bedrockClient struct {
	httpClient *http.Client
	baseURL    string // default https://bedrock-runtime.{region}.amazonaws.com
	model      string
	region     string
	creds      sigv4Creds
	timeout    time.Duration
	nowFn      func() time.Time
}

func newBedrockClient(conn Connection) (*bedrockClient, error) {
	if conn.Model == "" {
		return nil, fmt.Errorf("bedrock: Model required (e.g. anthropic.claude-3-5-sonnet-20241022-v2:0)")
	}
	if conn.Region == "" {
		return nil, fmt.Errorf("bedrock: Region required")
	}
	if conn.AccessKeyID == "" || conn.SecretAccessKey == "" {
		return nil, fmt.Errorf("bedrock: AccessKeyID and SecretAccessKey required")
	}
	base := firstNonEmpty(conn.BaseURL, "https://bedrock-runtime."+conn.Region+".amazonaws.com")
	timeout := conn.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	hc := conn.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: timeout}
	}
	return &bedrockClient{
		httpClient: hc,
		baseURL:    base,
		model:      conn.Model,
		region:     conn.Region,
		creds: sigv4Creds{
			AccessKeyID:     conn.AccessKeyID,
			SecretAccessKey: conn.SecretAccessKey,
			SessionToken:    conn.SessionToken,
		},
		timeout: timeout,
		nowFn:   time.Now,
	}, nil
}

func (c *bedrockClient) Provider() string { return "bedrock" }
func (c *bedrockClient) Model() string    { return c.model }

func (c *bedrockClient) Chat(ctx context.Context, req Request) (Response, error) {
	model := firstNonEmpty(req.Model, c.model)

	// Bedrock's Anthropic body == Messages body minus `model`, plus
	// `anthropic_version`. Build the shared body then re-marshal as a map so
	// we can drop "model" and add the version field.
	base := buildAnthropicBody(req, model)
	payload := map[string]any{
		"anthropic_version": "bedrock-2023-05-31",
		"max_tokens":        base.MaxTokens,
		"messages":          base.Messages,
	}
	if base.System != "" {
		payload["system"] = base.System
	}
	if len(base.Tools) > 0 {
		payload["tools"] = base.Tools
	}
	if base.ToolChoice != nil {
		payload["tool_choice"] = base.ToolChoice
	}

	raw, err := json.Marshal(payload)
	if err != nil {
		return Response{}, fmt.Errorf("bedrock: marshal request: %w", err)
	}

	endpoint := c.baseURL + "/model/" + url.PathEscape(model) + "/invoke"
	reqCtx, cancel := context.WithTimeout(ctx, c.timeout)
	defer cancel()
	httpReq, err := http.NewRequestWithContext(reqCtx, http.MethodPost, endpoint, bytes.NewReader(raw))
	if err != nil {
		return Response{}, fmt.Errorf("bedrock: build request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Accept", "application/json")
	signV4(httpReq, raw, c.creds, "bedrock", c.region, c.nowFn())

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return Response{}, fmt.Errorf("%w: bedrock POST: %v", ErrTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return Response{}, fmt.Errorf("%w: bedrock read body: %v", ErrTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Response{}, fmt.Errorf("%w: bedrock status=%d body=%s", ErrTransient, resp.StatusCode, string(respBody))
	}

	// The invoke response body is the Anthropic Messages response shape.
	out, err := parseAnthropicBody(respBody, model)
	if err != nil {
		return Response{}, err
	}
	out.Model = model // Bedrock omits model in the body; keep the requested id.
	return out, nil
}
