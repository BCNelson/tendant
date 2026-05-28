// Package chain owns the DBOS chain workflow that walks a task through the
// fixed linear sequence CREATION → TRIAGE → EXPANSION → EXECUTION → COMPLETION.
// In Phase 1 every occupied stage routes to the human; Phase 6 swaps the
// router for one that consults autonomy + agent eligibility.
package chain

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// Agent is the routing output for a given stage. Phase 1 always returns
// {IsHuman: true, PrincipalID: nil}.
type Agent struct {
	IsHuman     bool
	PrincipalID *uuid.UUID
}

// Router picks an agent for a given stage. The findings argument is the
// current tasks.findings JSON blob — unused in Phase 1, plumbed for Phase 6.
type Router interface {
	Select(ctx context.Context, stage lifecycle.ChainStage, findings json.RawMessage) Agent
}

// HumanOnlyRouter is the Phase 1 stub: every occupied stage goes to the
// human. Phase 6 replaces it with the real router.
type HumanOnlyRouter struct{}

// Select returns the human agent regardless of stage or findings.
func (HumanOnlyRouter) Select(_ context.Context, _ lifecycle.ChainStage, _ json.RawMessage) Agent {
	return Agent{IsHuman: true}
}
