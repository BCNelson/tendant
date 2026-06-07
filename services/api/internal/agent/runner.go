package agent

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// GateEvaluator is the interface the runner uses to gate tool calls.
// It mirrors the gate package's interface to avoid circular imports.
type GateEvaluator interface {
	EvaluateCall(ctx context.Context, taskID, toolID uuid.UUID, payload json.RawMessage) (GateVerdict, error)
}

// GateVerdict represents the outcome of a gate evaluation.
type GateVerdict struct {
	Decision          string // "approve", "deny", "request_decision"
	PendingDecisionID *uuid.UUID
}

// ToolDispatcher dispatches an approved tool call and returns the outcome.
type ToolDispatcher interface {
	Dispatch(ctx context.Context, taskID, toolID uuid.UUID, payload json.RawMessage) (string, error)
}

// AuditWriter writes audit messages for the agent layer.
type AuditWriter interface {
	WriteAudit(ctx context.Context, taskID uuid.UUID, kind string, payload any) error
}

// Runner is the one trusted agent loop. Every specialist is a parameterization
// of this runner via AgentConfig — the loop logic never changes per specialist.
type Runner struct {
	Client     AgentModelClient
	Gate       GateEvaluator
	Dispatcher ToolDispatcher
	Auditor    AuditWriter
	Queries    *db.Queries
	MaxIter    int
	Budget     int // per-task gate-call budget (shared across stages in a task)
}

// RunConfig is the per-run context for a stage.
type RunConfig struct {
	Config    db.AgentConfig
	TaskID    uuid.UUID
	TaskTitle string
	TaskDesc  string
	Findings  json.RawMessage // current tasks.findings (input context)
}

// Run executes the plan→act→observe loop for a single stage.
func (r *Runner) Run(ctx context.Context, rc RunConfig) (StageResult, error) {
	// Resolve allowlist to concrete tools.
	allowedTools, allowedIDs, err := r.resolveAllowlist(ctx, rc.Config.ToolAllowlist)
	if err != nil {
		return StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}, fmt.Errorf("resolve allowlist: %w", err)
	}

	// Build system prompt from config.
	systemPrompt := ""
	if rc.Config.SystemPrompt != nil {
		systemPrompt = *rc.Config.SystemPrompt
	}

	model := ""
	if rc.Config.Model != nil {
		model = *rc.Config.Model
	}

	// Audit start.
	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_run_started", map[string]any{
			"config_id":   rc.Config.ID,
			"config_name": rc.Config.Name,
			"stage":       rc.Config.Stage,
		})
	}

	// Initialize conversation with task context.
	messages := []Message{
		{Role: "user", Content: buildTaskPrompt(rc)},
	}

	var gateCallCount int
	var totalTokensIn, totalTokensOut int

	for iter := range r.MaxIter {
		_ = iter

		resp, chatErr := r.Client.Chat(ctx, ChatRequest{
			Model:    model,
			System:   systemPrompt,
			Messages: messages,
			Tools:    allowedTools,
		})
		if chatErr != nil {
			slog.ErrorContext(ctx, "agent: model call failed", "err", chatErr, "iter", iter)
			return StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}, nil
		}
		totalTokensIn += resp.TokensIn
		totalTokensOut += resp.TokensOut

		// No tool calls → agent is done, extract StageResult.
		if len(resp.ToolCalls) == 0 {
			result := parseStageResult(resp.Content)
			r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut)
			return result, nil
		}

		// Process tool calls.
		messages = append(messages, Message{Role: "assistant", Content: resp.Content})

		for _, tc := range resp.ToolCalls {
			// Allowlist enforcement: refuse tools not in the allowlist.
			toolID, inAllowlist := allowedIDs[tc.Name]
			if !inAllowlist {
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_call_refused", map[string]any{
						"tool_name": tc.Name,
						"reason":    "not_in_allowlist",
					})
				}
				messages = append(messages, Message{
					Role:    "tool_result",
					Content: fmt.Sprintf(`{"error": "tool '%s' is not in your allowlist"}`, tc.Name),
				})
				continue
			}

			// Budget check.
			gateCallCount++
			if gateCallCount > r.Budget {
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "budget_exhausted", map[string]any{
						"budget":     r.Budget,
						"calls_made": gateCallCount,
						"stage":      rc.Config.Stage,
					})
				}
				return StageResult{FailCloseToHuman: true, FailReason: "budget_exhausted"}, nil
			}

			// Gate evaluation.
			verdict, gErr := r.Gate.EvaluateCall(ctx, rc.TaskID, toolID, json.RawMessage(tc.Payload))
			if gErr != nil {
				messages = append(messages, Message{
					Role:    "tool_result",
					Content: `{"error": "gate evaluation failed"}`,
				})
				continue
			}

			switch verdict.Decision {
			case "approve":
				// Dispatch the tool.
				outcome, dErr := r.Dispatcher.Dispatch(ctx, rc.TaskID, toolID, json.RawMessage(tc.Payload))
				if dErr != nil {
					messages = append(messages, Message{
						Role:    "tool_result",
						Content: fmt.Sprintf(`{"error": "%s"}`, dErr.Error()),
					})
				} else {
					messages = append(messages, Message{
						Role:    "tool_result",
						Content: outcome,
					})
				}

			case "request_decision":
				// Fail-close to human — a decision is needed.
				r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut)
				return StageResult{
					FailCloseToHuman: true,
					FailReason:       "request_decision",
				}, nil

			case "deny":
				messages = append(messages, Message{
					Role:    "tool_result",
					Content: `{"error": "tool call denied by gate"}`,
				})
			}
		}
	}

	// Max iterations reached.
	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "max_iterations_reached", map[string]any{
			"task_id":    rc.TaskID,
			"stage":      rc.Config.Stage,
			"iterations": r.MaxIter,
		})
	}
	return StageResult{FailCloseToHuman: true, FailReason: "max_iterations"}, nil
}

func (r *Runner) resolveAllowlist(ctx context.Context, allowlistRaw json.RawMessage) ([]ToolDef, map[string]uuid.UUID, error) {
	var toolIDs []uuid.UUID
	if err := json.Unmarshal(allowlistRaw, &toolIDs); err != nil {
		return nil, nil, fmt.Errorf("parse tool_allowlist: %w", err)
	}

	defs := make([]ToolDef, 0, len(toolIDs))
	idMap := make(map[string]uuid.UUID, len(toolIDs))

	for _, tid := range toolIDs {
		tool, err := r.Queries.GetToolByID(ctx, tid)
		if err != nil {
			slog.WarnContext(ctx, "agent: tool in allowlist not found", "tool_id", tid, "err", err)
			continue
		}
		defs = append(defs, ToolDef{
			Name:      tool.Name,
			GlobalURI: tool.GlobalUri,
			Schema:    "", // tools don't store schema yet
		})
		idMap[tool.Name] = tool.ID
	}
	return defs, idMap, nil
}

func (r *Runner) auditFinish(ctx context.Context, rc RunConfig, iterations, tokensIn, tokensOut int) {
	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_run_finished", map[string]any{
			"config_id":  rc.Config.ID,
			"stage":      rc.Config.Stage,
			"iterations": iterations,
			"tokens_in":  tokensIn,
			"tokens_out": tokensOut,
		})
	}
}

func buildTaskPrompt(rc RunConfig) string {
	prompt := fmt.Sprintf("Task: %s\n", rc.TaskTitle)
	if rc.TaskDesc != "" {
		prompt += fmt.Sprintf("Description: %s\n", rc.TaskDesc)
	}
	if len(rc.Findings) > 0 && string(rc.Findings) != "{}" {
		prompt += fmt.Sprintf("Current findings: %s\n", string(rc.Findings))
	}
	prompt += "\nComplete your stage's work. When done, respond with a JSON object containing your findings:\n"
	prompt += `{"findings": {"structured": {"category_hints": [...], "stakes_score": N, "entities": [...], "required_capabilities": [...]}, "free_text": "..."}}`
	return prompt
}

func parseStageResult(content string) StageResult {
	// Try to parse as JSON with findings.
	var wrapper struct {
		Findings    *Findings       `json:"findings"`
		ContextRefs json.RawMessage `json:"context_refs"`
	}
	if err := json.Unmarshal([]byte(content), &wrapper); err == nil && wrapper.Findings != nil {
		return StageResult{
			Findings:    wrapper.Findings,
			ContextRefs: wrapper.ContextRefs,
		}
	}

	// Fallback: wrap the content as free_text.
	return StageResult{
		Findings: &Findings{
			Structured: StructuredFindings{
				CategoryHints: []string{"general"},
				StakesScore:   1,
			},
			FreeText: content,
		},
	}
}
