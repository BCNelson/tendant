package gate

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// stubLookup implements PrincipalLookup with a static set.
type stubLookup struct {
	known map[string]bool
	err   error
}

func (s *stubLookup) IsKnownPrincipal(_ context.Context, uri string) (bool, error) {
	if s.err != nil {
		return false, s.err
	}
	return s.known[uri], nil
}

// permsJSON marshals a Permissions value to the jsonb shape sqlc returns.
func permsJSON(t *testing.T, p Permissions) json.RawMessage {
	t.Helper()
	raw, err := json.Marshal(p)
	if err != nil {
		t.Fatalf("marshal permissions: %v", err)
	}
	return raw
}

// payloadJSON helper.
func payloadJSON(t *testing.T, m map[string]any) json.RawMessage {
	t.Helper()
	raw, err := json.Marshal(m)
	if err != nil {
		t.Fatalf("marshal payload: %v", err)
	}
	return raw
}

func TestDefaultGate_ReadOnlyShortCircuit(t *testing.T) {
	t.Parallel()
	g := NewDefaultGate(&stubLookup{})
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{ReadOnly: true})}
	call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: payloadJSON(t, map[string]any{"recipient": "stranger@x"})}

	v, err := g.Evaluate(context.Background(), call, tool)
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionApprove {
		t.Fatalf("want Approve, got %s", v.Decision)
	}
}

func TestDefaultGate_FloorTrips(t *testing.T) {
	t.Parallel()
	knownOwner := "tendant://principals/owner"
	lookup := &stubLookup{known: map[string]bool{knownOwner: true}}
	g := NewDefaultGate(lookup)

	cases := []struct {
		name        string
		perms       Permissions
		payload     map[string]any
		wantClause  string
		wantTripped bool
	}{
		{
			name:        "spend trips",
			perms:       Permissions{Spend: true, Irreversible: "never"},
			payload:     map[string]any{"to": knownOwner},
			wantClause:  "spend",
			wantTripped: true,
		},
		{
			name:        "irreversible always trips",
			perms:       Permissions{Irreversible: "always"},
			payload:     map[string]any{"to": knownOwner},
			wantClause:  "irreversible_third_party",
			wantTripped: true,
		},
		{
			name:        "stranger recipient trips (alias 'to')",
			perms:       Permissions{Irreversible: "stranger_recipient"},
			payload:     map[string]any{"to": "stranger@example.com"},
			wantClause:  "irreversible_third_party",
			wantTripped: true,
		},
		{
			name:        "stranger recipient trips (canonical 'recipient')",
			perms:       Permissions{Irreversible: "stranger_recipient"},
			payload:     map[string]any{"recipient": "stranger@example.com"},
			wantClause:  "irreversible_third_party",
			wantTripped: true,
		},
		{
			name:        "known principal does not trip irreversible",
			perms:       Permissions{Irreversible: "stranger_recipient"},
			payload:     map[string]any{"to": knownOwner},
			wantTripped: false,
		},
		{
			name:        "missing recipient with stranger_recipient mode fails closed",
			perms:       Permissions{Irreversible: "stranger_recipient"},
			payload:     map[string]any{},
			wantClause:  "irreversible_third_party",
			wantTripped: true,
		},
		{
			name:        "secret disclosure trips when class matches",
			perms:       Permissions{Irreversible: "never", SecretClasses: []string{"credentials"}},
			payload:     map[string]any{"disclosure_class": "credentials"},
			wantClause:  "secret_disclosure",
			wantTripped: true,
		},
		{
			name:        "secret disclosure does not trip when class differs",
			perms:       Permissions{Irreversible: "never", SecretClasses: []string{"credentials"}},
			payload:     map[string]any{"disclosure_class": "trivia"},
			wantTripped: false,
		},
		{
			name:        "unknown irreversible mode fails closed",
			perms:       Permissions{Irreversible: "bogus_mode"},
			payload:     map[string]any{"to": knownOwner},
			wantClause:  "irreversible_third_party",
			wantTripped: true,
		},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			tool := &db.Tool{Permissions: permsJSON(t, tc.perms)}
			call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: payloadJSON(t, tc.payload)}

			v, err := g.Evaluate(context.Background(), call, tool)
			if err != nil {
				t.Fatalf("evaluate: %v", err)
			}
			if tc.wantTripped && v.Decision != DecisionRequestDecision {
				t.Fatalf("want RequestDecision, got %s", v.Decision)
			}
			if !tc.wantTripped && v.Decision == DecisionApprove {
				t.Fatalf("did not expect Approve in Phase 3 (no overseer yet); got Approve")
			}
			if tc.wantClause != "" {
				var ctx map[string]any
				if err := json.Unmarshal(v.Context, &ctx); err != nil {
					t.Fatalf("decode context: %v", err)
				}
				if got, _ := ctx["clause"].(string); got != tc.wantClause {
					t.Fatalf("clause=%q want %q (ctx=%s)", got, tc.wantClause, string(v.Context))
				}
			}
		})
	}
}

func TestDefaultGate_NoOverseerFallthrough(t *testing.T) {
	t.Parallel()
	// Graded call that does NOT trip the floor must still escalate in Phase
	// 3, because no overseer is wired. Phase 4 replaces this stub.
	knownOwner := "tendant://principals/owner"
	lookup := &stubLookup{known: map[string]bool{knownOwner: true}}
	g := NewDefaultGate(lookup)
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{Irreversible: "stranger_recipient"})}
	call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: payloadJSON(t, map[string]any{"to": knownOwner})}

	v, err := g.Evaluate(context.Background(), call, tool)
	if err != nil {
		t.Fatalf("evaluate: %v", err)
	}
	if v.Decision != DecisionRequestDecision {
		t.Fatalf("want RequestDecision (no overseer yet), got %s", v.Decision)
	}
}

func TestDefaultGate_LookupErrorFailsClosed(t *testing.T) {
	t.Parallel()
	lookup := &stubLookup{err: errors.New("db down")}
	g := NewDefaultGate(lookup)
	tool := &db.Tool{Permissions: permsJSON(t, Permissions{Irreversible: "stranger_recipient"})}
	call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: payloadJSON(t, map[string]any{"to": "x@y"})}

	if _, err := g.Evaluate(context.Background(), call, tool); err == nil {
		t.Fatalf("expected error from lookup, got nil")
	}
}

func TestDefaultGate_NilGuards(t *testing.T) {
	t.Parallel()
	g := NewDefaultGate(&stubLookup{})
	if _, err := g.Evaluate(context.Background(), nil, &db.Tool{}); err == nil {
		t.Fatalf("expected error for nil call")
	}
	if _, err := g.Evaluate(context.Background(), &ToolCall{}, nil); err == nil {
		t.Fatalf("expected error for nil tool")
	}
}
