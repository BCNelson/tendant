package overseer

import (
	"context"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// DefaultMaxEvalPerTask is the fail-closed per-task overseer-evaluation
// budget. Owner-tunable via TENDANT_OVERSEER_MAX_EVAL_PER_TASK; 50 is
// chosen so even a pathologically chatty Phase-6 sub-agent loop is
// bounded before fail-closing.
const DefaultMaxEvalPerTask = 50

// Gateway is the only addressable Grader implementation. An agent cannot
// reroute inference at runtime because the platform model gateway is the
// only path: provider is selected at boot from env (TENDANT_OVERSEER_PROVIDER)
// and stays constant for the process lifetime.
type Gateway struct {
	provider       Provider
	queries        *db.Queries
	maxEvalPerTask int
	modelID        string

	rateMu     sync.Mutex
	rateWindow []time.Time
}

// NewGateway constructs the Gateway. queries is required (for the cap
// query); provider is required (LogProvider is the deterministic
// default). maxEvalPerTask <= 0 falls back to DefaultMaxEvalPerTask.
// modelID is the per-provider model identifier written into audit and
// used for cost estimation; the LogProvider ignores it and writes "log".
func NewGateway(provider Provider, queries *db.Queries, maxEvalPerTask int, modelID string) *Gateway {
	if maxEvalPerTask <= 0 {
		maxEvalPerTask = DefaultMaxEvalPerTask
	}
	return &Gateway{
		provider:       provider,
		queries:        queries,
		maxEvalPerTask: maxEvalPerTask,
		modelID:        modelID,
	}
}

// RatePerMinute returns the count of evaluations in the rolling 60-second
// window. Surfaced by /healthz under "overseer.evaluations_per_minute".
// Observability only — not enforcement (FR-010).
func (g *Gateway) RatePerMinute() int {
	g.rateMu.Lock()
	defer g.rateMu.Unlock()
	g.trimWindowLocked(time.Now())
	return len(g.rateWindow)
}

func (g *Gateway) trimWindowLocked(now time.Time) {
	cutoff := now.Add(-60 * time.Second)
	keep := g.rateWindow[:0]
	for _, t := range g.rateWindow {
		if t.After(cutoff) {
			keep = append(keep, t)
		}
	}
	g.rateWindow = keep
}

func (g *Gateway) recordEval(now time.Time) {
	g.rateMu.Lock()
	defer g.rateMu.Unlock()
	g.trimWindowLocked(now)
	g.rateWindow = append(g.rateWindow, now)
}

// Grade implements Grader. The flow:
//
//	(1) Count audit rows for kind=overseer_evaluated on this task; if
//	    >= cap, return DecisionRequestDecision with
//	    Reason="per_task_eval_cap_exceeded" — do NOT call the provider.
//	(2) Serialize input into PromptPayload (pure function; no I/O).
//	(3) Call provider.Call; on any error, fail-closed
//	    DecisionRequestDecision with Reason="gateway_error".
//	(4) Validate verdict ∈ {"approve", "request_decision"}; on parse
//	    failure, fail-closed with Reason="malformed_model_response".
//	(5) Compute estimated cost via the in-package pricing table.
//	(6) Append now to the rate window (observability).
//	(7) Return — the resolver writes the audit row alongside the
//	    gate_verdict row, chaining via in_reply_to.
//
// The Gateway never writes audit; the resolver owns audit so the chain
// (tool_call_composed → gate_verdict → overseer_evaluated → ...) commits
// atomically and the timeline is consistent.
func (g *Gateway) Grade(ctx context.Context, in *OverseerInput) (OverseerVerdict, error) {
	provider := g.provider
	if provider == nil {
		slog.Warn("overseer.Gateway.no_provider", "task_id", in.TaskID)
		return OverseerVerdict{
			Decision: DecisionRequestDecision,
			Reason:   "gateway_error",
			Provider: "",
			ModelID:  g.modelID,
			Evidence: Evidence{Summary: "overseer gateway has no provider configured"},
		}, nil
	}

	// (1) per-task cap.
	count, err := g.queries.CountOverseerEvalsForTask(ctx, in.TaskID)
	if err != nil {
		slog.Warn("overseer.Gateway.cap_query_failed", "err", err, "task_id", in.TaskID)
		return OverseerVerdict{
			Decision: DecisionRequestDecision,
			Reason:   "gateway_error",
			Provider: provider.Name(),
			ModelID:  g.modelID,
			Evidence: Evidence{
				Summary:          fmt.Sprintf("overseer gateway: cap-count query failed: %v", err),
				ConsideredFields: []string{},
			},
		}, nil
	}
	if int(count) >= g.maxEvalPerTask {
		slog.Info("overseer.gateway.cap_exceeded",
			"task_id", in.TaskID, "current_count", count, "cap", g.maxEvalPerTask)
		return OverseerVerdict{
			Decision: DecisionRequestDecision,
			Reason:   "per_task_eval_cap_exceeded",
			Provider: provider.Name(),
			ModelID:  g.modelID,
			Evidence: Evidence{
				Summary:          fmt.Sprintf("per-task overseer evaluation cap exceeded (count=%d cap=%d)", count, g.maxEvalPerTask),
				ConsideredFields: []string{},
			},
		}, nil
	}

	// (2) serialize prompt.
	prompt := Serialize(in)

	// (3) call provider.
	resp, err := provider.Call(ctx, prompt)
	if err != nil {
		slog.Warn("overseer.gateway.provider_error", "err", err, "task_id", in.TaskID, "provider", provider.Name())
		return OverseerVerdict{
			Decision: DecisionRequestDecision,
			Reason:   "gateway_error",
			Provider: provider.Name(),
			ModelID:  g.modelID,
			Evidence: Evidence{
				Summary:          fmt.Sprintf("overseer provider error: %v", err),
				ConsideredFields: []string{},
			},
		}, nil
	}

	// (4) parse verdict.
	var decision Decision
	switch resp.Verdict {
	case "approve":
		decision = DecisionApprove
	case "request_decision":
		decision = DecisionRequestDecision
	default:
		slog.Warn("overseer.gateway.malformed_response",
			"verdict", resp.Verdict, "task_id", in.TaskID, "provider", provider.Name())
		return OverseerVerdict{
			Decision: DecisionRequestDecision,
			Reason:   "malformed_model_response",
			Provider: provider.Name(),
			ModelID:  firstNonEmpty(resp.ModelID, g.modelID),
			Evidence: Evidence{
				Summary:          fmt.Sprintf("provider returned unexpected verdict: %q", resp.Verdict),
				ConsideredFields: []string{},
			},
			TokensIn:  resp.TokensIn,
			TokensOut: resp.TokensOut,
		}, nil
	}

	// (5) cost estimate.
	modelID := firstNonEmpty(resp.ModelID, g.modelID)
	cost := EstimateCostUSD(provider.Name(), modelID, resp.TokensIn, resp.TokensOut)

	// (6) observability.
	g.recordEval(time.Now())

	return OverseerVerdict{
		Decision:         decision,
		Evidence:         resp.Evidence,
		ModelID:          modelID,
		Provider:         provider.Name(),
		TokensIn:         resp.TokensIn,
		TokensOut:        resp.TokensOut,
		EstimatedCostUSD: cost,
	}, nil
}

// AuditPayload builds the JSON payload for the overseer_evaluated audit
// row from a verdict and the matched decision id (uuid.Nil when no
// decision is involved, e.g. an Approve verdict's read-only auto-dispatch
// path). Centralised so the resolver and tests agree on shape.
//
// Takes a pointer to avoid copying the verdict struct; callers MUST NOT
// pass nil.
func AuditPayload(v *OverseerVerdict, decisionID uuid.UUID, ownerInstructionsHash string) map[string]any {
	evidence := map[string]any{
		"summary":           v.Evidence.Summary,
		"considered_fields": v.Evidence.ConsideredFields,
	}
	if v.Reason != "" {
		evidence["reason"] = v.Reason
	}
	if decisionID != uuid.Nil {
		evidence["decision_id"] = decisionID.String()
	}
	return map[string]any{
		"verdict":                 verdictStringForAudit(v),
		"model_id":                v.ModelID,
		"provider":                v.Provider,
		"owner_instructions_hash": ownerInstructionsHash,
		"evidence":                evidence,
		"tokens_in":               v.TokensIn,
		"tokens_out":              v.TokensOut,
		"estimated_cost_usd":      v.EstimatedCostUSD,
	}
}

// verdictStringForAudit maps the verdict surface to the strings expected
// in audit payloads (data-model.md kind="overseer_evaluated"):
//   - approve / request_decision (happy paths)
//   - fail_closed_request_decision (gateway_error / malformed_model_response)
//   - fail_closed_per_task_cap (per_task_eval_cap_exceeded)
func verdictStringForAudit(v *OverseerVerdict) string {
	switch v.Reason {
	case "per_task_eval_cap_exceeded":
		return "fail_closed_per_task_cap"
	case "gateway_error", "malformed_model_response":
		return "fail_closed_request_decision"
	}
	return v.Decision.String()
}

func firstNonEmpty(a, b string) string {
	if a != "" {
		return a
	}
	return b
}
