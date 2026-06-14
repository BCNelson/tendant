package tools

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
)

// fakeTool is a minimal Tool used to exercise the registry.
type fakeTool struct {
	uri        string
	idempotent bool
	executed   int
	lastKey    string
}

func (f *fakeTool) GlobalURI() string { return f.uri }

func (f *fakeTool) Execute(ctx context.Context, _ json.RawMessage) (Result, error) {
	f.executed++
	f.lastKey = IdempotencyKey(ctx)
	return Result{Provider: "fake"}, nil
}

func (f *fakeTool) Idempotent(_ context.Context, _ json.RawMessage) bool { return f.idempotent }

func TestRegistry_RegisterAndLookup(t *testing.T) {
	r := NewRegistry()
	tool := &fakeTool{uri: "tendant://tools/fake"}
	r.Register(tool)

	got, ok := r.ByGlobalURI("tendant://tools/fake")
	if !ok {
		t.Fatalf("ByGlobalURI: tool not found after Register")
	}
	if got.GlobalURI() != tool.uri {
		t.Fatalf("ByGlobalURI: got %q, want %q", got.GlobalURI(), tool.uri)
	}

	if _, ok := r.ByGlobalURI("tendant://tools/missing"); ok {
		t.Fatalf("ByGlobalURI: unexpectedly found an unregistered URI")
	}
}

func TestRegistry_RegisterReplaces(t *testing.T) {
	r := NewRegistry()
	first := &fakeTool{uri: "tendant://tools/dup"}
	second := &fakeTool{uri: "tendant://tools/dup"}
	r.Register(first)
	r.Register(second)

	got, _ := r.ByGlobalURI("tendant://tools/dup")
	if got != second {
		t.Fatalf("Register: second registration did not replace the first")
	}
}

func TestRegistry_Execute(t *testing.T) {
	r := NewRegistry()
	tool := &fakeTool{uri: "tendant://tools/fake"}
	r.Register(tool)

	res, err := r.Execute(context.Background(), "tendant://tools/fake", json.RawMessage(`{}`))
	if err != nil {
		t.Fatalf("Execute: unexpected error: %v", err)
	}
	if res.Provider != "fake" {
		t.Fatalf("Execute: got provider %q, want %q", res.Provider, "fake")
	}
	if tool.executed != 1 {
		t.Fatalf("Execute: tool ran %d times, want 1", tool.executed)
	}
}

func TestRegistry_ExecuteUnknown(t *testing.T) {
	r := NewRegistry()
	_, err := r.Execute(context.Background(), "tendant://tools/missing", json.RawMessage(`{}`))
	if !errors.Is(err, ErrUnknownTool) {
		t.Fatalf("Execute: got error %v, want ErrUnknownTool", err)
	}
}

func TestIdempotencyKey_RoundTrip(t *testing.T) {
	if got := IdempotencyKey(context.Background()); got != "" {
		t.Fatalf("IdempotencyKey: empty ctx returned %q, want \"\"", got)
	}

	ctx := WithIdempotencyKey(context.Background(), "decision-123")
	if got := IdempotencyKey(ctx); got != "decision-123" {
		t.Fatalf("IdempotencyKey: got %q, want %q", got, "decision-123")
	}
}

// TestExecute_ReceivesIdempotencyKey proves the key set on ctx reaches Execute.
func TestExecute_ReceivesIdempotencyKey(t *testing.T) {
	r := NewRegistry()
	tool := &fakeTool{uri: "tendant://tools/fake"}
	r.Register(tool)

	ctx := WithIdempotencyKey(context.Background(), "decision-abc")
	if _, err := r.Execute(ctx, "tendant://tools/fake", json.RawMessage(`{}`)); err != nil {
		t.Fatalf("Execute: unexpected error: %v", err)
	}
	if tool.lastKey != "decision-abc" {
		t.Fatalf("Execute: tool saw idempotency key %q, want %q", tool.lastKey, "decision-abc")
	}
}
