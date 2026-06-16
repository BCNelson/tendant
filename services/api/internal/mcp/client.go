// Package mcp is tendant's Model Context Protocol *client*: it lets the owner
// register external remote MCP servers (Streamable HTTP transport) and exposes
// each discovered upstream tool as a first-class, gated tendant tool. Every MCP
// tool becomes (a) a row in the `tools` table — so the universal gate has the
// owner-configured floor permissions it requires — and (b) an adapter in the
// in-process tool registry whose Execute performs an upstream `tools/call`.
//
// The client is hand-rolled over stdlib net/http (no SDK dependency), matching
// how internal/llm and the overseer providers speak to external services. It
// implements the four RPCs tendant needs — initialize, notifications/initialized,
// tools/list, tools/call — over the Streamable HTTP transport (MCP revision
// 2025-06-18): a single POST endpoint, an `Accept` header advertising both
// application/json and text/event-stream, an `Mcp-Session-Id` header lifecycle,
// and an `MCP-Protocol-Version` header on every post-initialize request.
package mcp

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
)

// ProtocolVersion is the MCP revision this client speaks. Sent in the initialize
// request and echoed on every subsequent request via the MCP-Protocol-Version
// header (the server may negotiate down; we record whatever it returns).
const ProtocolVersion = "2025-06-18"

// clientName / clientVersion identify tendant in the initialize handshake.
const (
	clientName    = "tendant"
	clientVersion = "1"
)

// Transport caps — defensive bounds on an untrusted upstream.
const (
	maxResponseBytes = 8 << 20 // 8 MiB per HTTP response body
	maxListPages     = 50      // tools/list pagination ceiling
)

// ErrSessionExpired is returned (internally) when the server answers 404 to a
// request carrying an Mcp-Session-Id — per the spec the client must re-init.
var ErrSessionExpired = errors.New("mcp: session expired")

// Auth is the credential a client presents on every request. v1 supports a
// single static header (e.g. Header="Authorization", Value="Bearer <token>").
// It is sealed at rest (internal/crypto) and never crosses the read surface.
// The OAuth-refresh path is a reserved follow-up (mirrors gmail's refresher).
type Auth struct {
	Header string `json:"header,omitempty"`
	Value  string `json:"value,omitempty"`
}

// ToolDescriptor is one entry from tools/list. InputSchema and Annotations are
// kept as raw JSON: tendant stores them verbatim (the gate is policy, not schema
// parsing) and surfaces annotations to the owner as *suggestions* only.
type ToolDescriptor struct {
	Name        string          `json:"name"`
	Title       string          `json:"title,omitempty"`
	Description string          `json:"description,omitempty"`
	InputSchema json.RawMessage `json:"inputSchema,omitempty"`
	Annotations json.RawMessage `json:"annotations,omitempty"`
}

// CallResult is the result of a tools/call. IsError flags an upstream tool-level
// error (distinct from a transport/protocol error); the adapter maps it to a
// bad outcome. Content is the raw content-block array; StructuredContent is the
// optional typed result.
type CallResult struct {
	Content           json.RawMessage `json:"content,omitempty"`
	StructuredContent json.RawMessage `json:"structuredContent,omitempty"`
	IsError           bool            `json:"isError,omitempty"`
}

// Client is a Streamable-HTTP MCP client bound to one server endpoint. It is safe
// for concurrent use; session state is mutex-guarded and re-established on expiry.
type Client struct {
	endpoint string
	http     *http.Client
	auth     Auth

	mu         sync.Mutex
	idSeq      int
	sessionID  string // assigned by the server at initialize (may be empty)
	negotiated string // protocol version the server returned
	ready      bool
}

// NewClient builds a client for endpoint with the given auth. A nil httpClient
// uses http.DefaultClient.
func NewClient(endpoint string, auth Auth, httpClient *http.Client) *Client {
	if httpClient == nil {
		httpClient = http.DefaultClient
	}
	return &Client{endpoint: endpoint, http: httpClient, auth: auth}
}

// NegotiatedVersion returns the protocol version the server agreed to, or "" if
// the session has not been established yet.
func (c *Client) NegotiatedVersion() string {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.negotiated
}

// --- JSON-RPC envelope -------------------------------------------------------

type rpcRequest struct {
	JSONRPC string `json:"jsonrpc"`
	ID      *int   `json:"id,omitempty"` // omitted for notifications
	Method  string `json:"method"`
	Params  any    `json:"params,omitempty"`
}

type rpcResponse struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id"`
	Result  json.RawMessage `json:"result"`
	Error   *rpcError       `json:"error"`
}

type rpcError struct {
	Code    int             `json:"code"`
	Message string          `json:"message"`
	Data    json.RawMessage `json:"data,omitempty"`
}

func (e *rpcError) Error() string { return fmt.Sprintf("mcp rpc error %d: %s", e.Code, e.Message) }

// --- Public RPCs -------------------------------------------------------------

// EnsureSession performs the initialize handshake if it has not run yet (or was
// invalidated by an expired session). Safe to call before every operation.
func (c *Client) EnsureSession(ctx context.Context) error {
	c.mu.Lock()
	ready := c.ready
	c.mu.Unlock()
	if ready {
		return nil
	}
	return c.initialize(ctx)
}

func (c *Client) initialize(ctx context.Context) error {
	params := map[string]any{
		"protocolVersion": ProtocolVersion,
		"capabilities":    map[string]any{},
		"clientInfo":      map[string]any{"name": clientName, "version": clientVersion},
	}
	// initialize must not carry a session id; send it directly (not via call,
	// which would recurse into EnsureSession).
	resp, err := c.do(ctx, "initialize", params, true)
	if err != nil {
		return fmt.Errorf("mcp initialize: %w", err)
	}
	var out struct {
		ProtocolVersion string `json:"protocolVersion"`
	}
	if len(resp.Result) > 0 {
		_ = json.Unmarshal(resp.Result, &out)
	}
	c.mu.Lock()
	if out.ProtocolVersion != "" {
		c.negotiated = out.ProtocolVersion
	} else {
		c.negotiated = ProtocolVersion
	}
	c.ready = true
	c.mu.Unlock()

	// notifications/initialized completes the handshake (no id, expect 202).
	if err := c.notify(ctx, "notifications/initialized", nil); err != nil {
		c.mu.Lock()
		c.ready = false
		c.mu.Unlock()
		return fmt.Errorf("mcp initialized notification: %w", err)
	}
	return nil
}

// ListTools returns every tool the server advertises, following cursor
// pagination up to maxListPages.
func (c *Client) ListTools(ctx context.Context) ([]ToolDescriptor, error) {
	if err := c.EnsureSession(ctx); err != nil {
		return nil, err
	}
	var all []ToolDescriptor
	cursor := ""
	for page := 0; page < maxListPages; page++ {
		var params any
		if cursor != "" {
			params = map[string]any{"cursor": cursor}
		}
		resp, err := c.call(ctx, "tools/list", params)
		if err != nil {
			return nil, fmt.Errorf("mcp tools/list: %w", err)
		}
		var out struct {
			Tools      []ToolDescriptor `json:"tools"`
			NextCursor string           `json:"nextCursor"`
		}
		if err := json.Unmarshal(resp.Result, &out); err != nil {
			return nil, fmt.Errorf("mcp tools/list decode: %w", err)
		}
		all = append(all, out.Tools...)
		if out.NextCursor == "" {
			return all, nil
		}
		cursor = out.NextCursor
	}
	return all, fmt.Errorf("mcp tools/list: exceeded %d pages", maxListPages)
}

// CallTool invokes one tool. args is the frozen call payload (used verbatim as
// the call arguments); meta, when non-empty, is sent as the request `_meta`
// (tendant forwards the decision-id idempotency key there).
func (c *Client) CallTool(ctx context.Context, name string, args json.RawMessage, meta map[string]any) (CallResult, error) {
	if err := c.EnsureSession(ctx); err != nil {
		return CallResult{}, err
	}
	params := map[string]any{"name": name}
	if len(args) > 0 {
		params["arguments"] = args
	} else {
		params["arguments"] = map[string]any{}
	}
	if len(meta) > 0 {
		params["_meta"] = meta
	}
	resp, err := c.call(ctx, "tools/call", params)
	if err != nil {
		return CallResult{}, fmt.Errorf("mcp tools/call %s: %w", name, err)
	}
	var out CallResult
	if err := json.Unmarshal(resp.Result, &out); err != nil {
		return CallResult{}, fmt.Errorf("mcp tools/call decode: %w", err)
	}
	return out, nil
}

// --- Transport ---------------------------------------------------------------

// call posts a request and transparently re-initializes + retries once on an
// expired session.
func (c *Client) call(ctx context.Context, method string, params any) (*rpcResponse, error) {
	resp, err := c.do(ctx, method, params, false)
	if errors.Is(err, ErrSessionExpired) {
		c.mu.Lock()
		c.ready = false
		c.sessionID = ""
		c.mu.Unlock()
		if rerr := c.initialize(ctx); rerr != nil {
			return nil, rerr
		}
		return c.do(ctx, method, params, false)
	}
	return resp, err
}

// notify posts a JSON-RPC notification (no id); the server answers 202.
func (c *Client) notify(ctx context.Context, method string, params any) error {
	body, err := json.Marshal(rpcRequest{JSONRPC: "2.0", Method: method, Params: params})
	if err != nil {
		return err
	}
	httpResp, err := c.post(ctx, body)
	if err != nil {
		return err
	}
	defer func() { _ = httpResp.Body.Close() }()
	c.captureSession(httpResp)
	if httpResp.StatusCode == http.StatusOK || httpResp.StatusCode == http.StatusAccepted {
		return nil
	}
	return c.statusError(httpResp)
}

// do builds a request, posts it, and decodes the single matching JSON-RPC
// response (handling both application/json and text/event-stream bodies). When
// allowNoSession is false and the server 404s a session-bearing request, it
// returns ErrSessionExpired.
func (c *Client) do(ctx context.Context, method string, params any, allowNoSession bool) (*rpcResponse, error) {
	c.mu.Lock()
	c.idSeq++
	id := c.idSeq
	c.mu.Unlock()

	body, err := json.Marshal(rpcRequest{JSONRPC: "2.0", ID: &id, Method: method, Params: params})
	if err != nil {
		return nil, err
	}
	httpResp, err := c.post(ctx, body)
	if err != nil {
		return nil, err
	}
	defer func() { _ = httpResp.Body.Close() }()
	c.captureSession(httpResp)

	if httpResp.StatusCode == http.StatusNotFound && !allowNoSession {
		return nil, ErrSessionExpired
	}
	if httpResp.StatusCode != http.StatusOK {
		return nil, c.statusError(httpResp)
	}

	ct := httpResp.Header.Get("Content-Type")
	limited := io.LimitReader(httpResp.Body, maxResponseBytes)
	if strings.HasPrefix(ct, "text/event-stream") {
		return c.readSSEResponse(limited, id)
	}
	return decodeRPCResponse(limited, id)
}

// post issues the HTTP POST with the MCP headers set.
func (c *Client) post(ctx context.Context, body []byte) (*http.Response, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.endpoint, bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json, text/event-stream")
	req.Header.Set("MCP-Protocol-Version", ProtocolVersion)
	c.mu.Lock()
	sid := c.sessionID
	c.mu.Unlock()
	if sid != "" {
		req.Header.Set("Mcp-Session-Id", sid)
	}
	if c.auth.Header != "" && c.auth.Value != "" {
		req.Header.Set(c.auth.Header, c.auth.Value)
	}
	return c.http.Do(req)
}

// captureSession records the Mcp-Session-Id header the server assigns at (and
// after) initialization.
func (c *Client) captureSession(resp *http.Response) {
	if sid := resp.Header.Get("Mcp-Session-Id"); sid != "" {
		c.mu.Lock()
		c.sessionID = sid
		c.mu.Unlock()
	}
}

func (c *Client) statusError(resp *http.Response) error {
	snippet, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
	return fmt.Errorf("mcp: http status %d: %s", resp.StatusCode, strings.TrimSpace(string(snippet)))
}

// decodeRPCResponse parses a single JSON object body and validates the id +
// surfaces an rpc error.
func decodeRPCResponse(r io.Reader, wantID int) (*rpcResponse, error) {
	var resp rpcResponse
	if err := json.NewDecoder(r).Decode(&resp); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}
	return validateRPCResponse(&resp, wantID)
}

// readSSEResponse scans an SSE body for the JSON-RPC response whose id matches
// the request, skipping any server-initiated requests/notifications interleaved
// before it.
func (c *Client) readSSEResponse(r io.Reader, wantID int) (*rpcResponse, error) {
	sc := bufio.NewScanner(r)
	sc.Buffer(make([]byte, 0, 64*1024), maxResponseBytes)
	var data strings.Builder
	flush := func() (*rpcResponse, bool, error) {
		if data.Len() == 0 {
			return nil, false, nil
		}
		raw := data.String()
		data.Reset()
		var resp rpcResponse
		if err := json.Unmarshal([]byte(raw), &resp); err != nil {
			// Not a JSON-RPC payload we understand (e.g. a comment frame); skip.
			return nil, false, nil
		}
		if len(resp.ID) == 0 || string(resp.ID) == "null" {
			return nil, false, nil // server-initiated request/notification
		}
		var gotID int
		if err := json.Unmarshal(resp.ID, &gotID); err != nil || gotID != wantID {
			return nil, false, nil
		}
		v, err := validateRPCResponse(&resp, wantID)
		return v, true, err
	}
	for sc.Scan() {
		line := sc.Text()
		switch {
		case line == "":
			if resp, done, err := flush(); done || err != nil {
				return resp, err
			}
		case strings.HasPrefix(line, "data:"):
			data.WriteString(strings.TrimPrefix(strings.TrimPrefix(line, "data:"), " "))
		default:
			// id:, event:, retry:, or a comment line — ignored.
		}
	}
	if err := sc.Err(); err != nil {
		return nil, fmt.Errorf("read sse stream: %w", err)
	}
	if resp, done, err := flush(); done || err != nil {
		return resp, err
	}
	return nil, fmt.Errorf("mcp: sse stream closed without a response for id %d", wantID)
}

func validateRPCResponse(resp *rpcResponse, wantID int) (*rpcResponse, error) {
	if resp.Error != nil {
		return nil, resp.Error
	}
	if len(resp.ID) > 0 && string(resp.ID) != "null" {
		var gotID int
		if err := json.Unmarshal(resp.ID, &gotID); err == nil && gotID != wantID {
			return nil, fmt.Errorf("mcp: response id %d does not match request id %d", gotID, wantID)
		}
	}
	return resp, nil
}
