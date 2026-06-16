package tools

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
)

// stubTool is a minimal Tool for registry tests: it records its dispatch and
// returns a fixed Result tagged with its URI.
type stubTool struct {
	uri      string
	executed bool
}

func (s *stubTool) GlobalURI() string { return s.uri }
func (s *stubTool) Execute(_ context.Context, _ json.RawMessage) (Result, error) {
	s.executed = true
	return Result{Provider: s.uri}, nil
}
func (s *stubTool) Idempotent(_ context.Context, _ json.RawMessage) bool { return true }

func TestRegistry_RegisterAndLookup(t *testing.T) {
	r := NewRegistry()
	tool := &stubTool{uri: "tendant://tools/stub"}
	r.Register(tool)

	got, ok := r.ByGlobalURI("tendant://tools/stub")
	if !ok {
		t.Fatal("ByGlobalURI() ok = false, want true")
	}
	if got.GlobalURI() != tool.uri {
		t.Fatalf("ByGlobalURI() = %q, want %q", got.GlobalURI(), tool.uri)
	}

	if _, ok := r.ByGlobalURI("tendant://tools/missing"); ok {
		t.Fatal("ByGlobalURI(missing) ok = true, want false")
	}
}

func TestRegistry_RegisterIsIdempotent(t *testing.T) {
	// Re-registering the same URI replaces the prior entry — this is what makes
	// boot-time registration safe across restarts.
	r := NewRegistry()
	first := &stubTool{uri: "tendant://tools/stub"}
	second := &stubTool{uri: "tendant://tools/stub"}
	r.Register(first)
	r.Register(second)

	got, ok := r.ByGlobalURI("tendant://tools/stub")
	if !ok {
		t.Fatal("ByGlobalURI() ok = false, want true")
	}
	if got != second {
		t.Fatal("re-Register did not replace the prior tool")
	}
}

func TestRegistry_Execute(t *testing.T) {
	r := NewRegistry()
	tool := &stubTool{uri: "tendant://tools/stub"}
	r.Register(tool)

	res, err := r.Execute(context.Background(), "tendant://tools/stub", json.RawMessage(`{}`))
	if err != nil {
		t.Fatalf("Execute() error = %v, want nil", err)
	}
	if !tool.executed {
		t.Fatal("Execute() did not dispatch to the registered tool")
	}
	if res.Provider != tool.uri {
		t.Fatalf("Execute() Result.Provider = %q, want %q", res.Provider, tool.uri)
	}
}

func TestRegistry_ExecuteUnknownTool(t *testing.T) {
	r := NewRegistry()
	_, err := r.Execute(context.Background(), "tendant://tools/missing", json.RawMessage(`{}`))
	if !errors.Is(err, ErrUnknownTool) {
		t.Fatalf("Execute(unknown) error = %v, want ErrUnknownTool", err)
	}
}
