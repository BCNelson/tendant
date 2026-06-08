package llm

import (
	"fmt"
	"net/http"
	"sort"
	"strings"
	"sync"
	"time"
)

// Connection is one named, configured endpoint. The same Provider may appear
// under many Connections (e.g. two OpenAI-compatible backends with different
// BaseURLs/models), each addressable by Name.
type Connection struct {
	Name     string // unique key in a Registry
	Provider string // "openai" | "anthropic" | "gemini" | "bedrock" | "log"
	BaseURL  string // optional; provider default when empty
	Model    string // default model id for this connection
	APIKey   string // resolved secret (Bearer/x-api-key/x-goog-api-key)

	// Bedrock (AWS SigV4) credentials.
	Region          string
	AccessKeyID     string
	SecretAccessKey string
	SessionToken    string

	Timeout time.Duration // per-request timeout; 0 ⇒ 30s

	// HTTPClient overrides the transport (tests / shared pools). Optional.
	HTTPClient *http.Client
}

// NewClient builds a Client for one Connection. The provider name is matched
// case-insensitively; an unknown provider is an error.
func NewClient(conn Connection) (Client, error) {
	switch strings.ToLower(strings.TrimSpace(conn.Provider)) {
	case "openai", "openai-compatible", "azure", "ollama", "openrouter":
		return newOpenAIClient(conn)
	case "anthropic":
		return newAnthropicClient(conn)
	case "gemini", "google":
		return newGeminiClient(conn)
	case "bedrock", "aws-bedrock":
		return newBedrockClient(conn)
	case "log", "":
		return newLogClient(conn), nil
	default:
		return nil, fmt.Errorf("llm: unknown provider %q for connection %q", conn.Provider, conn.Name)
	}
}

// Registry holds named Clients. It is built once at boot and read concurrently;
// the immutable-after-build shape keeps inference routing fixed (an agent
// cannot mint a new connection at runtime).
type Registry struct {
	mu      sync.RWMutex
	clients map[string]Client
	conns   map[string]Connection
}

// NewRegistry returns an empty Registry.
func NewRegistry() *Registry {
	return &Registry{clients: map[string]Client{}, conns: map[string]Connection{}}
}

// Register builds the Client for conn and stores it under conn.Name. A blank
// name or duplicate registration is an error.
func (r *Registry) Register(conn Connection) error {
	name := strings.TrimSpace(conn.Name)
	if name == "" {
		return fmt.Errorf("llm: connection name required")
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, dup := r.clients[name]; dup {
		return fmt.Errorf("llm: duplicate connection name %q", name)
	}
	client, err := NewClient(conn)
	if err != nil {
		return err
	}
	r.clients[name] = client
	r.conns[name] = conn
	return nil
}

// Get returns the Client registered under name.
func (r *Registry) Get(name string) (Client, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	c, ok := r.clients[name]
	return c, ok
}

// Connection returns the Connection spec registered under name.
func (r *Registry) Connection(name string) (Connection, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	c, ok := r.conns[name]
	return c, ok
}

// Names returns the registered connection names, sorted.
func (r *Registry) Names() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	out := make([]string, 0, len(r.clients))
	for n := range r.clients {
		out = append(out, n)
	}
	sort.Strings(out)
	return out
}
