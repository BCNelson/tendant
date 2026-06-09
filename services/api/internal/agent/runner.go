package agent

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// HandoffToolName is the built-in tool every agent may call to escalate a task
// to a human when it cannot honestly complete the work with the tools it has.
// It is injected into every Chat request regardless of the agent's allowlist
// and is never dispatched or gated — calling it ends the agent loop with a
// fail-close so the chain opens a human assignment.
const HandoffToolName = "handoff_to_human"

// handoffToolDef is the synthetic tool definition presented to the model. The
// description is the behavioural lever: it tells the model to hand off rather
// than fabricate a completion it cannot actually perform.
var handoffToolDef = ToolDef{
	Name: HandoffToolName,
	Description: "Hand this task off to a human. Call this — instead of reporting the work as done — " +
		"whenever you cannot honestly complete it with the tools available to you: the task needs an " +
		"action you have no tool for (placing a phone call, signing a document, visiting a location), " +
		"requires information you cannot obtain, or is ambiguous in a way only the owner can resolve. " +
		"Never claim you performed an action that you did not actually perform via a tool call.",
	Schema: `{"type":"object","properties":{"reason":{"type":"string",` +
		`"description":"One or two sentences: what you were asked to do, and specifically why you cannot complete it."}},` +
		`"required":["reason"]}`,
}

// appendGuidance appends active owner-feedback guidance for this agent config
// (global + agent-scoped) to the system prompt under a labeled section. Nil
// Queries or a load error degrades to the unmodified prompt (best-effort).
func (r *Runner) appendGuidance(ctx context.Context, agentConfigID uuid.UUID, systemPrompt string) string {
	if r.Queries == nil {
		return systemPrompt
	}
	notes, err := r.Queries.ActiveGuidanceForAgent(ctx, pgtype.UUID{Bytes: agentConfigID, Valid: true})
	if err != nil || len(notes) == 0 {
		return systemPrompt
	}
	var b strings.Builder
	b.WriteString(systemPrompt)
	b.WriteString("\n\n[OWNER_FEEDBACK]\nStanding guidance from the owner, distilled from past task feedback — follow it:\n")
	for _, n := range notes {
		b.WriteString("- ")
		b.WriteString(n)
		b.WriteString("\n")
	}
	return b.String()
}

// appendTaxonomy appends the available task-category taxonomy (key — label) to a
// triage agent's system prompt under a labeled section, instructing it to set
// findings.structured.category to the single best-matching key. Nil Queries, a
// load error, or an empty catalog degrades to the unmodified prompt (best-effort).
func (r *Runner) appendTaxonomy(ctx context.Context, systemPrompt string) string {
	if r.Queries == nil {
		return systemPrompt
	}
	cats, err := r.Queries.ListTaskCategories(ctx)
	if err != nil || len(cats) == 0 {
		return systemPrompt
	}
	var b strings.Builder
	b.WriteString(systemPrompt)
	b.WriteString("\n\n[TASK_CATEGORIES]\nClassify this task by setting findings.structured.category to the single best-matching key below (the most specific one that fits). Use exactly one key, or leave it empty if none fit:\n")
	for _, c := range cats {
		b.WriteString("- ")
		b.WriteString(c.Key)
		if c.Label != "" {
			b.WriteString(" — ")
			b.WriteString(c.Label)
		}
		b.WriteString("\n")
	}
	return b.String()
}

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

	// Only execution agents see the built-in handoff tool, on top of their
	// allowlist. Triage and expansion only assess/enrich the task and perform no
	// outward action — they have nothing to honestly hand off, so exposing the
	// tool only invites spurious escalations. When present it is deliberately NOT
	// added to allowedIDs: it is never dispatched or gated — calling it ends the
	// loop with a fail-close. A fresh slice avoids mutating the allowlist's
	// backing array.
	modelTools := make([]ToolDef, 0, len(allowedTools)+1)
	modelTools = append(modelTools, allowedTools...)
	if rc.Config.Stage == db.AgentStageExecution {
		modelTools = append(modelTools, handoffToolDef)
	}

	// Build system prompt from config, then append any owner feedback guidance
	// (global + this-agent active notes) under a labeled [OWNER_FEEDBACK]
	// section. The notes are owner-accepted verbatim text (see internal/feedback).
	systemPrompt := ""
	if rc.Config.SystemPrompt != nil {
		systemPrompt = *rc.Config.SystemPrompt
	}
	systemPrompt = r.appendGuidance(ctx, rc.Config.ID, systemPrompt)

	// Triage is the categorizer: give it the available task-category taxonomy so
	// it can classify the task by setting findings.structured.category. Downstream
	// stages route by that category; other stages don't classify, so they don't
	// need the list.
	if rc.Config.Stage == db.AgentStageTriage {
		systemPrompt = r.appendTaxonomy(ctx, systemPrompt)
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

	// Initialize conversation with task context. `messages` is the model-facing
	// history; `transcript` is the persisted record (also carries the system
	// prompt, the final assistant answer, and per-turn tool calls) so the UI can
	// show what the model actually said, not just token counts.
	userPrompt := buildTaskPrompt(rc)
	messages := []Message{
		{Role: "user", Content: userPrompt},
	}
	transcript := make([]transcriptTurn, 0, 8)
	if systemPrompt != "" {
		transcript = append(transcript, transcriptTurn{Role: "system", Content: systemPrompt})
	}
	transcript = append(transcript, transcriptTurn{Role: "user", Content: userPrompt})

	// recordToolResult appends a tool observation to both the model-facing
	// messages and the persisted transcript.
	recordToolResult := func(content string) {
		messages = append(messages, Message{Role: "tool_result", Content: content})
		transcript = append(transcript, transcriptTurn{Role: "tool_result", Content: content})
	}

	var gateCallCount int
	var totalTokensIn, totalTokensOut int

	for iter := range r.MaxIter {
		_ = iter

		resp, chatErr := r.Client.Chat(ctx, ChatRequest{
			Model:    model,
			System:   systemPrompt,
			Messages: messages,
			Tools:    modelTools,
		})
		if chatErr != nil {
			slog.ErrorContext(ctx, "agent: model call failed", "err", chatErr, "iter", iter)
			return StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}, nil
		}
		totalTokensIn += resp.TokensIn
		totalTokensOut += resp.TokensOut

		// Record the assistant turn (content + any proposed tool calls) before
		// branching, so the final answer is captured even on the early exit.
		assistantTurn := transcriptTurn{Role: "assistant", Content: resp.Content}
		for _, tc := range resp.ToolCalls {
			assistantTurn.ToolCalls = append(assistantTurn.ToolCalls,
				transcriptToolCall{Name: tc.Name, Payload: tc.Payload})
		}
		transcript = append(transcript, assistantTurn)

		// No tool calls → agent is done, extract StageResult.
		if len(resp.ToolCalls) == 0 {
			result := parseStageResult(resp.Content)
			r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, transcript)
			return result, nil
		}

		// Process tool calls.
		messages = append(messages, Message{Role: "assistant", Content: resp.Content})

		for _, tc := range resp.ToolCalls {
			// Built-in handoff: the agent is honestly declining to complete the
			// work. Handled before the allowlist/budget/gate — it is never
			// dispatched. End the loop with a fail-close so the chain opens a
			// human assignment carrying the agent's reason.
			if tc.Name == HandoffToolName {
				reason := parseHandoffReason(tc.Payload)
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_handoff", map[string]any{
						"stage":  rc.Config.Stage,
						"reason": reason,
					})
				}
				r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, transcript)
				return StageResult{
					FailCloseToHuman: true,
					FailReason:       "agent_handoff",
					HandoffReason:    reason,
				}, nil
			}

			// Allowlist enforcement: refuse tools not in the allowlist.
			toolID, inAllowlist := allowedIDs[tc.Name]
			if !inAllowlist {
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_call_refused", map[string]any{
						"tool_name": tc.Name,
						"reason":    "not_in_allowlist",
					})
				}
				recordToolResult(fmt.Sprintf(`{"error": "tool '%s' is not in your allowlist"}`, tc.Name))
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
				recordToolResult(`{"error": "gate evaluation failed"}`)
				continue
			}

			switch verdict.Decision {
			case "approve":
				// Dispatch the tool.
				outcome, dErr := r.Dispatcher.Dispatch(ctx, rc.TaskID, toolID, json.RawMessage(tc.Payload))
				if dErr != nil {
					recordToolResult(fmt.Sprintf(`{"error": "%s"}`, dErr.Error()))
				} else {
					recordToolResult(outcome)
				}

			case "request_decision":
				// Fail-close to human — a decision is needed.
				r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, transcript)
				return StageResult{
					FailCloseToHuman: true,
					FailReason:       "request_decision",
				}, nil

			case "deny":
				recordToolResult(`{"error": "tool call denied by gate"}`)
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

// transcriptTurn is one entry in the persisted LLM conversation: a system /
// user / assistant / tool_result message. Assistant turns also carry any tool
// calls the model proposed. Serialized into the agent_run_finished audit
// payload under "messages".
type transcriptTurn struct {
	Role      string               `json:"role"`
	Content   string               `json:"content,omitempty"`
	ToolCalls []transcriptToolCall `json:"tool_calls,omitempty"`
}

type transcriptToolCall struct {
	Name    string `json:"name"`
	Payload string `json:"payload,omitempty"`
}

func (r *Runner) auditFinish(ctx context.Context, rc RunConfig, iterations, tokensIn, tokensOut int, transcript []transcriptTurn) {
	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_run_finished", map[string]any{
			"config_id":  rc.Config.ID,
			"stage":      rc.Config.Stage,
			"iterations": iterations,
			"tokens_in":  tokensIn,
			"tokens_out": tokensOut,
			"messages":   transcript,
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
	const findingsShape = `{"findings": {"structured": {"category_hints": [...], "stakes_score": N, "entities": [...], "required_capabilities": [...]}, "free_text": "..."}}`

	// The completion contract is stage-specific. Triage and expansion only
	// assess/enrich the task and emit findings — they perform no outward action,
	// so they must NOT hand off merely because the task will later need a
	// capability they lack (that belongs in required_capabilities). Only
	// execution agents actually act, so only they get the tool-honesty + handoff
	// contract. A stage-agnostic handoff instruction made triage hand off on
	// every task whose eventual execution needed a tool.
	if rc.Config.Stage == db.AgentStageExecution {
		prompt += "\nCarry out the task using ONLY the tools available to you, then end in exactly one of two " +
			"honest ways:\n"
		prompt += "1. If you genuinely performed the work via tool calls that succeeded, respond with a JSON " +
			"object containing your findings:\n"
		prompt += findingsShape + "\n"
		prompt += "2. If you cannot complete it with the tools available to you — it needs an action you have no " +
			"tool for (a phone call, signing a document), information you cannot obtain, or a decision only the " +
			"owner can make — call the handoff_to_human tool with a brief reason.\n"
		prompt += "Honesty rule: only report an action as done if you actually performed it by calling a tool and " +
			"saw a successful result. Never describe work you did not do."
		return prompt
	}

	prompt += "\nDo your stage's work: assess and enrich this task. You are NOT executing the task and are NOT " +
		"expected to perform any outward action here. When done, respond with a JSON object containing your " +
		"findings:\n"
	prompt += findingsShape + "\n"
	prompt += "If the task will eventually need a capability or tool that does not exist yet, that is normal — " +
		"record it in required_capabilities. Always produce your assessment from the information available; " +
		"escalation to a human is not your job at this stage."
	return prompt
}

// parseHandoffReason extracts the agent's stated reason from the handoff tool
// payload, falling back to a generic message when absent or unparseable.
func parseHandoffReason(payload string) string {
	var p struct {
		Reason string `json:"reason"`
	}
	_ = json.Unmarshal([]byte(payload), &p)
	if reason := strings.TrimSpace(p.Reason); reason != "" {
		return reason
	}
	return "agent handed off without a stated reason"
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
