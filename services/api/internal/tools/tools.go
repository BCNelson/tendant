// Package tools is the tendant-side action edge. The Tool interface, the
// Registry, and the per-call idempotency-key plumbing now live in the
// reusable agentkit framework (github.com/bcnelson/tendant/agentkit/tools);
// this package re-exports them as aliases so every existing importer keeps
// working unchanged, and adds tendant's concrete tools (send-email) plus the
// boot-time seed/registration glue.
//
// The split is the framework/app boundary: the registry mechanics are generic
// and framework-owned; the SMTP-speaking send-email tool and the schema-aware
// seeder are application code and stay here.
package tools

import (
	agentkittools "github.com/bcnelson/tendant/agentkit/tools"
)

// Framework action-edge types, re-exported from agentkit/tools. These are type
// aliases (not new types), so a tendant Tool implementation satisfies the
// framework interface and Results/Registries flow across the boundary without
// conversion.
type (
	// Result is what a Tool returns after a successful dispatch.
	Result = agentkittools.Result
	// Tool is the action-edge abstraction implemented by every capability.
	Tool = agentkittools.Tool
	// Registry maps global_uri → Tool.
	Registry = agentkittools.Registry
)

// Framework registry/idempotency helpers, re-exported from agentkit/tools.
var (
	// NewRegistry returns an empty registry.
	NewRegistry = agentkittools.NewRegistry
	// WithIdempotencyKey returns a context carrying a stable idempotency key.
	WithIdempotencyKey = agentkittools.WithIdempotencyKey
	// IdempotencyKey returns the idempotency key set on ctx, or "".
	IdempotencyKey = agentkittools.IdempotencyKey
	// ErrUnknownTool is returned when a global_uri matches no registered tool.
	ErrUnknownTool = agentkittools.ErrUnknownTool
)
