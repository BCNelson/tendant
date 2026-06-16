package tools

import (
	"context"
	"encoding/json"
	"errors"
	"testing"
)

// fakeEmailProvider records the last payload it was handed and returns a
// configurable Result / error. Deterministic, no I/O — the whole point of the
// EmailProvider seam is to let tests drive Execute without touching SMTP.
type fakeEmailProvider struct {
	called bool
	got    SendEmailPayload
	result Result
	err    error
}

func (f *fakeEmailProvider) Send(_ context.Context, p SendEmailPayload) (Result, error) {
	f.called = true
	f.got = p
	return f.result, f.err
}

func TestSendEmail_GlobalURI(t *testing.T) {
	s := NewSendEmail(&fakeEmailProvider{})
	if got := s.GlobalURI(); got != SendEmailGlobalURI {
		t.Fatalf("GlobalURI() = %q, want %q", got, SendEmailGlobalURI)
	}
}

func TestSendEmail_Idempotent_AlwaysFalse(t *testing.T) {
	// Documents the recovery-guard contract: the default LogProvider performs no
	// dedup, so the workflow must guard re-dispatch. The answer is constant
	// regardless of ctx key or payload.
	s := NewSendEmail(&fakeEmailProvider{})
	ctx := context.Background()
	if s.Idempotent(ctx, json.RawMessage(`{"to":"a@b.c"}`)) {
		t.Fatal("Idempotent() = true, want false")
	}
	if s.Idempotent(WithIdempotencyKey(ctx, "key-123"), nil) {
		t.Fatal("Idempotent() with key = true, want false")
	}
}

func TestNewSendEmail_NilProviderDefaultsToLog(t *testing.T) {
	s := NewSendEmail(nil)
	if s.Provider == nil {
		t.Fatal("NewSendEmail(nil).Provider is nil, want a default LogProvider")
	}
	if _, ok := s.Provider.(LogProvider); !ok {
		t.Fatalf("default provider is %T, want LogProvider", s.Provider)
	}
}

func TestSendEmail_Execute(t *testing.T) {
	providerErr := errors.New("smtp: connection refused")

	tests := []struct {
		name        string
		payload     string
		providerRes Result
		providerErr error
		wantCalled  bool   // did Execute reach the provider?
		wantErr     bool   // did Execute return an error?
		wantTo      string // expected payload.To delivered to the provider (when called)
	}{
		{
			name:        "valid payload delegates to provider",
			payload:     `{"to":"alice@example.com","subject":"hi","body":"there"}`,
			providerRes: Result{Provider: "fake", Detail: json.RawMessage(`{"id":"1"}`)},
			wantCalled:  true,
			wantErr:     false,
			wantTo:      "alice@example.com",
		},
		{
			name:       "malformed JSON errors before provider",
			payload:    `{"to":`,
			wantCalled: false,
			wantErr:    true,
		},
		{
			name:       "missing to fails validation before provider",
			payload:    `{"subject":"hi","body":"there"}`,
			wantCalled: false,
			wantErr:    true,
		},
		{
			name:       "missing subject fails validation before provider",
			payload:    `{"to":"alice@example.com","body":"there"}`,
			wantCalled: false,
			wantErr:    true,
		},
		{
			name:        "provider error surfaces verbatim",
			payload:     `{"to":"alice@example.com","subject":"hi","body":"there"}`,
			providerErr: providerErr,
			wantCalled:  true,
			wantErr:     true,
			wantTo:      "alice@example.com",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			fake := &fakeEmailProvider{result: tt.providerRes, err: tt.providerErr}
			s := NewSendEmail(fake)

			res, err := s.Execute(context.Background(), json.RawMessage(tt.payload))

			if tt.wantErr && err == nil {
				t.Fatal("Execute() error = nil, want non-nil")
			}
			if !tt.wantErr && err != nil {
				t.Fatalf("Execute() error = %v, want nil", err)
			}
			if fake.called != tt.wantCalled {
				t.Fatalf("provider called = %v, want %v", fake.called, tt.wantCalled)
			}
			if tt.wantCalled && fake.got.To != tt.wantTo {
				t.Fatalf("provider got To = %q, want %q", fake.got.To, tt.wantTo)
			}
			// On the surfaced-provider-error case, the error must be the
			// provider's own (this is what the workflow records as outcome=bad).
			if tt.providerErr != nil && !errors.Is(err, providerErr) {
				t.Fatalf("Execute() error = %v, want it to wrap provider error", err)
			}
			// On success, the provider's Result passes through untouched.
			if !tt.wantErr && res.Provider != tt.providerRes.Provider {
				t.Fatalf("Execute() Result.Provider = %q, want %q", res.Provider, tt.providerRes.Provider)
			}
		})
	}
}

func TestSendEmailPayload_Validate(t *testing.T) {
	tests := []struct {
		name    string
		payload SendEmailPayload
		wantErr bool
	}{
		{"valid", SendEmailPayload{To: "a@b.c", Subject: "s", Body: "b"}, false},
		{"empty body is allowed", SendEmailPayload{To: "a@b.c", Subject: "s"}, false},
		{"missing to", SendEmailPayload{Subject: "s"}, true},
		{"missing subject", SendEmailPayload{To: "a@b.c"}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.payload.Validate()
			if tt.wantErr != (err != nil) {
				t.Fatalf("Validate() error = %v, wantErr = %v", err, tt.wantErr)
			}
		})
	}
}

func TestLogProvider_Send(t *testing.T) {
	// The LogProvider is the deterministic dev/CI default: it always returns a
	// clean Result tagged "log", reads the idempotency key off ctx, and emits a
	// detail object echoing to+subject.
	lp := LogProvider{}
	ctx := WithIdempotencyKey(context.Background(), "decision-abc")

	res, err := lp.Send(ctx, SendEmailPayload{To: "a@b.c", Subject: "s", Body: "body"})
	if err != nil {
		t.Fatalf("Send() error = %v, want nil", err)
	}
	if res.Provider != "log" {
		t.Fatalf("Result.Provider = %q, want \"log\"", res.Provider)
	}
	var detail map[string]string
	if err := json.Unmarshal(res.Detail, &detail); err != nil {
		t.Fatalf("Result.Detail is not a JSON object: %v", err)
	}
	if detail["to"] != "a@b.c" || detail["subject"] != "s" {
		t.Fatalf("Result.Detail = %v, want to=a@b.c subject=s", detail)
	}
}
