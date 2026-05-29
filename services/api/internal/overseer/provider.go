package overseer

import (
	"context"
	"errors"
)

// Provider is the model-call seam, mirroring internal/push.Provider. The
// Gateway holds one active Provider for its process lifetime — provider
// selection is a deploy-time choice (TENDANT_OVERSEER_PROVIDER), not a
// runtime-addressable knob.
type Provider interface {
	// Name returns the canonical provider name written into audit
	// (`"log" | "anthropic" | "openai"`). Used for cost-table lookup.
	Name() string

	// Call dispatches one structured-output request. Implementations MUST
	// return ErrProviderTransient (wrapped) for any error the Gateway
	// should treat as a transient outage; the Gateway fail-closes either
	// way but distinguishes them in audit reasoning.
	Call(ctx context.Context, prompt PromptPayload) (RawResponse, error)
}

// PromptPayload is the labeled-slot output of prompt.Serialize. Providers
// map slots onto their native APIs (Anthropic: system + user content;
// OpenAI: role=system + role=user). The struct boundary is what makes
// payload data structurally incapable of impersonating owner instructions.
type PromptPayload struct {
	SystemPreamble    string // fixed text shipped with the package
	OwnerInstructions string // [OWNER_INSTRUCTIONS] slot
	ToolMetadata      string // [TOOL_METADATA] slot (name + global_uri + permissions JSON)
	ConcreteCall      string // [CONCRETE_CALL] slot — JSON-stringified payload
}

// RawResponse is what a Provider hands back; the Gateway translates this
// into OverseerVerdict (attaching cost from the pricing table). Verdict
// MUST be one of "approve" | "request_decision"; anything else is treated
// as malformed_model_response.
type RawResponse struct {
	Verdict   string
	Evidence  Evidence
	ModelID   string
	TokensIn  int
	TokensOut int
}

// ErrProviderTransient is the sentinel wrapped by Provider implementations
// for transient errors (network, 5xx, timeout). The Gateway fail-closes on
// any provider error; this sentinel lets the gateway emit a distinct
// audit reason ("gateway_error") for transient vs. structural problems.
var ErrProviderTransient = errors.New("overseer: provider transient error")
