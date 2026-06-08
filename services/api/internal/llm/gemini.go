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

// geminiClient speaks the Google Generative Language API
// (POST /v1beta/models/{model}:generateContent). Function calling maps onto
// tendant's Tool/ToolCall via functionDeclarations + functionCall parts.
type geminiClient struct {
	httpClient *http.Client
	baseURL    string
	apiKey     string
	model      string
	timeout    time.Duration
}

func newGeminiClient(conn Connection) (*geminiClient, error) {
	base := firstNonEmpty(conn.BaseURL, "https://generativelanguage.googleapis.com")
	model := firstNonEmpty(conn.Model, "gemini-2.0-flash")
	timeout := conn.Timeout
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	hc := conn.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: timeout}
	}
	return &geminiClient{
		httpClient: hc,
		baseURL:    base,
		apiKey:     conn.APIKey,
		model:      model,
		timeout:    timeout,
	}, nil
}

func (c *geminiClient) Provider() string { return "gemini" }
func (c *geminiClient) Model() string    { return c.model }

type geminiReq struct {
	SystemInstruction *geminiContent      `json:"system_instruction,omitempty"`
	Contents          []geminiContent     `json:"contents"`
	Tools             []geminiToolWrapper `json:"tools,omitempty"`
	ToolConfig        *geminiToolConfig   `json:"tool_config,omitempty"`
	GenerationConfig  *geminiGenConfig    `json:"generationConfig,omitempty"`
}

type geminiContent struct {
	Role  string       `json:"role,omitempty"`
	Parts []geminiPart `json:"parts"`
}

type geminiPart struct {
	Text         string             `json:"text,omitempty"`
	FunctionCall *geminiFunctionDef `json:"functionCall,omitempty"`
}

type geminiFunctionDef struct {
	Name string          `json:"name"`
	Args json.RawMessage `json:"args,omitempty"`
}

type geminiToolWrapper struct {
	FunctionDeclarations []geminiFnDecl `json:"function_declarations"`
}

type geminiFnDecl struct {
	Name        string         `json:"name"`
	Description string         `json:"description,omitempty"`
	Parameters  map[string]any `json:"parameters,omitempty"`
}

type geminiToolConfig struct {
	FunctionCallingConfig geminiFCC `json:"function_calling_config"`
}

type geminiFCC struct {
	Mode                 string   `json:"mode"`
	AllowedFunctionNames []string `json:"allowed_function_names,omitempty"`
}

type geminiGenConfig struct {
	MaxOutputTokens int `json:"maxOutputTokens,omitempty"`
}

type geminiResp struct {
	Candidates []struct {
		Content geminiContent `json:"content"`
	} `json:"candidates"`
	UsageMetadata struct {
		PromptTokenCount     int `json:"promptTokenCount"`
		CandidatesTokenCount int `json:"candidatesTokenCount"`
	} `json:"usageMetadata"`
}

func (c *geminiClient) Chat(ctx context.Context, req Request) (Response, error) {
	model := firstNonEmpty(req.Model, c.model)

	body := geminiReq{}
	if req.System != "" {
		body.SystemInstruction = &geminiContent{Parts: []geminiPart{{Text: req.System}}}
	}
	for _, m := range req.Messages {
		body.Contents = append(body.Contents, geminiContent{
			Role:  geminiRole(m.Role),
			Parts: []geminiPart{{Text: m.Content}},
		})
	}
	if len(req.Tools) > 0 {
		decls := make([]geminiFnDecl, 0, len(req.Tools))
		for _, t := range req.Tools {
			decls = append(decls, geminiFnDecl{Name: t.Name, Description: t.Description, Parameters: t.Schema})
		}
		body.Tools = []geminiToolWrapper{{FunctionDeclarations: decls}}
	}
	if req.ForceTool != "" {
		body.ToolConfig = &geminiToolConfig{FunctionCallingConfig: geminiFCC{
			Mode:                 "ANY",
			AllowedFunctionNames: []string{req.ForceTool},
		}}
	}
	if req.MaxTokens > 0 {
		body.GenerationConfig = &geminiGenConfig{MaxOutputTokens: req.MaxTokens}
	}

	raw, err := json.Marshal(body)
	if err != nil {
		return Response{}, fmt.Errorf("gemini: marshal request: %w", err)
	}

	endpoint := c.baseURL + "/v1beta/models/" + url.PathEscape(model) + ":generateContent"
	reqCtx, cancel := context.WithTimeout(ctx, c.timeout)
	defer cancel()
	httpReq, err := http.NewRequestWithContext(reqCtx, http.MethodPost, endpoint, bytes.NewReader(raw))
	if err != nil {
		return Response{}, fmt.Errorf("gemini: build request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("x-goog-api-key", c.apiKey)

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return Response{}, fmt.Errorf("%w: gemini POST: %v", ErrTransient, err)
	}
	defer func() { _ = resp.Body.Close() }()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return Response{}, fmt.Errorf("%w: gemini read body: %v", ErrTransient, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return Response{}, fmt.Errorf("%w: gemini status=%d body=%s", ErrTransient, resp.StatusCode, string(respBody))
	}

	var decoded geminiResp
	if err := json.Unmarshal(respBody, &decoded); err != nil {
		return Response{}, fmt.Errorf("%w: gemini decode: %v", ErrTransient, err)
	}

	out := Response{
		Model:     model,
		TokensIn:  decoded.UsageMetadata.PromptTokenCount,
		TokensOut: decoded.UsageMetadata.CandidatesTokenCount,
	}
	if len(decoded.Candidates) > 0 {
		for _, p := range decoded.Candidates[0].Content.Parts {
			if p.FunctionCall != nil {
				args := string(p.FunctionCall.Args)
				if args == "" {
					args = "{}"
				}
				out.ToolCalls = append(out.ToolCalls, ToolCall{
					Name:      p.FunctionCall.Name,
					Arguments: args,
				})
			}
			out.Content += p.Text
		}
	}
	return out, nil
}

// geminiRole maps neutral roles onto Gemini roles ("user"/"model").
func geminiRole(role string) string {
	if role == "assistant" {
		return "model"
	}
	return "user"
}
