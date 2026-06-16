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
// findings.structured.category to the single best-matching key. When a Matcher
// is configured it injects only the top-K categories most similar to taskText
// (semantic narrowing); otherwise — and on any matcher error / empty result — it
// degrades to the full taxonomy. Nil Queries, a load error, or an empty catalog
// degrades to the unmodified prompt (best-effort).
func (r *Runner) appendTaxonomy(ctx context.Context, systemPrompt, taskText string) string {
	if r.Matcher != nil && strings.TrimSpace(taskText) != "" {
		k := r.TriageTopK
		if k <= 0 {
			k = 10
		}
		if matches, err := r.Matcher.TopCategories(ctx, taskText, k); err == nil && len(matches) > 0 {
			var b strings.Builder
			b.WriteString(systemPrompt)
			b.WriteString("\n\n[TASK_CATEGORIES]\nClassify this task by setting findings.structured.category to the single best-matching key below (the most specific one that fits; these are the closest matches to this task). Use exactly one key, or leave it empty if none fit:\n")
			for _, m := range matches {
				writeCategoryLine(&b, m.Key, m.Label)
			}
			return b.String()
		}
		// matcher error or no matches → fall through to the full taxonomy.
	}
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
		writeCategoryLine(&b, c.Key, c.Label)
	}
	return b.String()
}

// writeCategoryLine renders one "- key — label" taxonomy entry.
func writeCategoryLine(b *strings.Builder, key, label string) {
	b.WriteString("- ")
	b.WriteString(key)
	if label != "" {
		b.WriteString(" — ")
		b.WriteString(label)
	}
	b.WriteString("\n")
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
	// Matcher, when set, narrows the triage taxonomy to the top-K nearest
	// categories (semantic embedding search). nil ⇒ inject the full taxonomy.
	Matcher    CategoryMatcher
	TriageTopK int // top-K for Matcher (0 ⇒ 10)
	MaxIter    int
	Budget     int // per-task gate-call budget (shared across stages in a task)
}

// CategoryMatch is one nearest category for triage narrowing (key + label).
type CategoryMatch struct {
	Key   string
	Label string
}

// CategoryMatcher returns the categories most semantically similar to a task's
// text. Implemented by internal/embedding (adapted in cmd/tendant) so the agent
// package stays decoupled from the embedding subsystem.
type CategoryMatcher interface {
	TopCategories(ctx context.Context, taskText string, k int) ([]CategoryMatch, error)
}

// RunConfig is the per-run context for a stage.
type RunConfig struct {
	Config    db.AgentConfig
	TaskID    uuid.UUID
	TaskTitle string
	TaskDesc  string
	Findings  json.RawMessage // current tasks.findings (input context)
}

// loopState is the serializable conversation state carried across a durable
// approval wait. The AgentStageWorkflow runs the loop in memoized segments: a
// segment ends either at completion (Done) or at a request_decision it cannot
// resolve inline, returning this state so the next segment resumes the exact
// conversation after the human's outcome is injected.
type loopState struct {
	Messages   []Message        `json:"messages"`
	Transcript []transcriptTurn `json:"transcript"`
	GateCalls  int              `json:"gate_calls"`
	Nudges     int              `json:"nudges"`
	TokensIn   int              `json:"tokens_in"`
	TokensOut  int              `json:"tokens_out"`
	Iter       int              `json:"iter"`
}

// pendingApproval is the tool call a segment stopped on (gate verdict
// request_decision) so the durable workflow can register it, wait, and inject
// the outcome before resuming.
type pendingApproval struct {
	ToolID  uuid.UUID       `json:"tool_id"`
	Name    string          `json:"name"`
	Payload json.RawMessage `json:"payload"`
}

// segmentInput drives one runSegment call. State nil ⇒ fresh start; otherwise
// resume from State, first injecting Injected as a tool_result observation.
type segmentInput struct {
	State    *loopState `json:"state,omitempty"`
	Injected string     `json:"injected,omitempty"`
}

// segmentResult is the outcome of one segment. Done ⇒ Result holds the terminal
// StageResult. Otherwise Pending holds the gated call and State the conversation
// to resume after the human outcome is injected.
type segmentResult struct {
	Done    bool             `json:"done"`
	Result  StageResult      `json:"result,omitempty"`
	Pending *pendingApproval `json:"pending,omitempty"`
	State   *loopState       `json:"state,omitempty"`
}

// Run executes the plan→act→observe loop for a single stage synchronously. It
// preserves the historical contract: a gate verdict of request_decision (which
// it cannot durably wait on inline) becomes a fail-close to human. The durable
// AgentStageWorkflow path instead drives runSegment directly and waits.
func (r *Runner) Run(ctx context.Context, rc RunConfig) (StageResult, error) {
	seg, err := r.runSegment(ctx, rc, segmentInput{})
	if err != nil {
		return StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}, err
	}
	if seg.Pending != nil {
		// No durable waiter available in the synchronous path — fail-close to
		// human exactly as before.
		return StageResult{FailCloseToHuman: true, FailReason: "request_decision"}, nil
	}
	return seg.Result, nil
}

// runSegment runs the agent loop until it either finishes (Done) or stops on a
// request_decision it can't resolve inline. On a fresh start (in.State == nil)
// it does full setup and the agent_run_started audit; on resume it restores the
// conversation from in.State and injects in.Injected as a tool_result first.
func (r *Runner) runSegment(ctx context.Context, rc RunConfig, in segmentInput) (segmentResult, error) {
	// Resolve allowlist to concrete tools.
	allowedTools, allowedIDs, err := r.resolveAllowlist(ctx, rc.Config.ToolAllowlist)
	if err != nil {
		return segmentResult{Done: true, Result: StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}}, fmt.Errorf("resolve allowlist: %w", err)
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

	// Names of every tool actually offered to the model this run. Used to
	// recover a tool call a model emitted as plain JSON text in its content
	// (see extractToolCallsFromContent) — only objects naming one of these are
	// recovered, so a normal findings answer is never misread as a call.
	knownTools := make(map[string]bool, len(modelTools))
	for _, t := range modelTools {
		knownTools[t.Name] = true
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
		taskText := rc.TaskTitle
		if rc.TaskDesc != "" {
			taskText += "\n" + rc.TaskDesc
		}
		systemPrompt = r.appendTaxonomy(ctx, systemPrompt, taskText)
	}

	model := ""
	if rc.Config.Model != nil {
		model = *rc.Config.Model
	}

	// Conversation state: fresh on the first segment, restored from in.State on a
	// resume after a durable approval wait. `messages` is the model-facing
	// history; `transcript` is the persisted record (also carries the system
	// prompt, the final assistant answer, and per-turn tool calls) so the UI can
	// show what the model actually said, not just token counts.
	var messages []Message
	var transcript []transcriptTurn
	var gateCallCount, nudgeCount, totalTokensIn, totalTokensOut, startIter int

	// recordToolResult appends a tool observation to both the model-facing
	// messages and the persisted transcript.
	recordToolResult := func(content string) {
		messages = append(messages, Message{Role: "tool_result", Content: content})
		transcript = append(transcript, transcriptTurn{Role: "tool_result", Content: content})
	}

	if in.State == nil {
		// Fresh start. Audit the run open exactly once.
		if r.Auditor != nil {
			_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_run_started", map[string]any{
				"config_id":   rc.Config.ID,
				"config_name": rc.Config.Name,
				"stage":       rc.Config.Stage,
			})
		}
		userPrompt := buildTaskPrompt(rc)
		messages = []Message{{Role: "user", Content: userPrompt}}
		transcript = make([]transcriptTurn, 0, 8)
		if systemPrompt != "" {
			transcript = append(transcript, transcriptTurn{Role: "system", Content: systemPrompt})
		}
		transcript = append(transcript, transcriptTurn{Role: "user", Content: userPrompt})
	} else {
		// Resume after a durable approval wait: restore the conversation and
		// inject the human outcome (the tool result, or a synthetic
		// human_no_response observation) before continuing the loop.
		messages = in.State.Messages
		transcript = in.State.Transcript
		gateCallCount = in.State.GateCalls
		nudgeCount = in.State.Nudges
		totalTokensIn = in.State.TokensIn
		totalTokensOut = in.State.TokensOut
		startIter = in.State.Iter
		if in.Injected != "" {
			recordToolResult(in.Injected)
		}
	}

	for iter := startIter; iter < r.MaxIter; iter++ {
		resp, chatErr := r.Client.Chat(ctx, ChatRequest{
			Model:    model,
			System:   systemPrompt,
			Messages: messages,
			Tools:    modelTools,
		})
		if chatErr != nil {
			slog.ErrorContext(ctx, "agent: model call failed", "err", chatErr, "iter", iter)
			return segmentResult{Done: true, Result: StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}}, nil
		}
		totalTokensIn += resp.TokensIn
		totalTokensOut += resp.TokensOut

		// Recover a tool call the model emitted as JSON text in its content
		// instead of a structured tool_calls entry (common with small/local
		// models). Without this an honest handoff_to_human — or any offered
		// tool — reads as a finished stage result and the task wrongly completes.
		if len(resp.ToolCalls) == 0 {
			if recovered := extractToolCallsFromContent(resp.Content, knownTools); len(recovered) > 0 {
				resp.ToolCalls = recovered
				resp.Content = ""
			}
		}

		// Record the assistant turn (content + any proposed tool calls) before
		// branching, so the final answer is captured even on the early exit.
		assistantTurn := transcriptTurn{Role: "assistant", Content: resp.Content}
		for _, tc := range resp.ToolCalls {
			assistantTurn.ToolCalls = append(assistantTurn.ToolCalls,
				transcriptToolCall{Name: tc.Name, Payload: tc.Payload})
		}
		transcript = append(transcript, assistantTurn)

		// No usable tool call. Before accepting the content as a finished
		// result, check whether it nonetheless looks like a botched tool-call
		// attempt the recovery above could not salvage — a hallucinated/unknown
		// tool name, malformed call JSON, or a wrapper syntax we don't parse.
		// If so, don't let it pass as a completion: audit it and nudge the model
		// to re-emit a proper structured call, up to a small cap. Past the cap
		// (or when the content is a genuine answer) we fall through to the normal
		// done-path so the model isn't trapped in a nudge loop.
		if len(resp.ToolCalls) == 0 {
			if detail, suspected := suspectedToolCallAttempt(resp.Content, knownTools); suspected && nudgeCount < maxToolCallNudges {
				nudgeCount++
				slog.WarnContext(ctx, "agent: suspected failed tool-call attempt; nudging",
					"stage", rc.Config.Stage, "detail", detail, "nudge", nudgeCount)
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_suspected_tool_attempt", map[string]any{
						"stage":  rc.Config.Stage,
						"detail": detail,
						"nudge":  nudgeCount,
					})
				}
				messages = append(messages, Message{Role: "assistant", Content: resp.Content})
				recordToolResult(toolCallNudgeMessage)
				continue
			}

			// Genuine completion → extract StageResult.
			result := parseStageResult(resp.Content)
			r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, transcript)
			return segmentResult{Done: true, Result: result}, nil
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
				return segmentResult{Done: true, Result: StageResult{
					FailCloseToHuman: true,
					FailReason:       "agent_handoff",
					HandoffReason:    reason,
				}}, nil
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
				return segmentResult{Done: true, Result: StageResult{FailCloseToHuman: true, FailReason: "budget_exhausted"}}, nil
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
				// A human decision is needed. Stop the segment here and hand the
				// gated call up to the durable workflow, which registers the
				// approval, waits, and resumes runSegment with the outcome
				// injected. The synchronous Run() wrapper turns this into a
				// fail-close, preserving the historical inline behavior.
				return segmentResult{
					Pending: &pendingApproval{
						ToolID:  toolID,
						Name:    tc.Name,
						Payload: json.RawMessage(tc.Payload),
					},
					State: &loopState{
						Messages:   messages,
						Transcript: transcript,
						GateCalls:  gateCallCount,
						Nudges:     nudgeCount,
						TokensIn:   totalTokensIn,
						TokensOut:  totalTokensOut,
						Iter:       iter,
					},
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
	return segmentResult{Done: true, Result: StageResult{FailCloseToHuman: true, FailReason: "max_iterations"}}, nil
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

// maxToolCallNudges bounds how many times one stage run will nudge the model to
// re-emit a malformed/unrecoverable tool-call attempt as a proper structured
// call before giving up and letting the loop terminate normally. Kept small so
// a model that repeats the same broken output can't burn the whole iteration
// budget on nudges.
const maxToolCallNudges = 2

// toolCallNudgeMessage is the corrective tool_result fed back to a model that
// appears to have tried to call a tool but produced no valid call. It is
// stage-agnostic: execution agents fall back to handoff_to_human, assess/enrich
// stages fall back to emitting findings — both are "your stage's instructions".
const toolCallNudgeMessage = `It looks like you tried to call a tool, but it was not a valid tool call, so nothing was executed. ` +
	`If you want to use a tool, re-issue it as a proper tool call using only the tools available to you — do not write the call as plain text. ` +
	`If you cannot proceed with the available tools, follow your stage's instructions for that case.`

// toolCallMarkers are wrapper/markup tokens models emit when they intend a tool
// call but don't produce a structured tool_calls entry. Their presence in
// otherwise-final content is a strong signal a tool call was attempted and
// dropped. Matched case-insensitively.
var toolCallMarkers = []string{
	"<tool_call>", "</tool_call>", "tool_call", "<function", "function_call",
	"<|python_tag|>", "```tool_code", "```tool", "[tool_call]", "functools[",
}

// suspectedToolCallAttempt reports whether final assistant content — one that
// produced no usable tool call, structured or recovered — nonetheless looks like
// a botched tool-call attempt: a hallucinated/unknown tool name, malformed call
// JSON, or a tool-call wrapper syntax we don't parse. It is intentionally
// conservative so a normal findings answer or plain prose never trips it (the
// JSON probe requires both a "name" and an argument bag, which a findings object
// lacks). The returned string is a short human-readable detail for the audit
// trail. Callers should run this only after extractToolCallsFromContent failed.
func suspectedToolCallAttempt(content string, known map[string]bool) (string, bool) {
	trimmed := strings.TrimSpace(content)
	if trimmed == "" {
		return "", false
	}
	lower := strings.ToLower(trimmed)
	for _, marker := range toolCallMarkers {
		if strings.Contains(lower, marker) {
			return "tool-call markup in content: " + marker, true
		}
	}
	// A JSON object naming a tool with an argument bag is a call. Recovery runs
	// first, so if we're here the name is one we did NOT offer (hallucinated).
	for _, candidate := range toolCallJSONCandidates(trimmed) {
		var probe struct {
			Name       string          `json:"name"`
			Parameters json.RawMessage `json:"parameters"`
			Arguments  json.RawMessage `json:"arguments"`
		}
		if err := json.Unmarshal([]byte(candidate), &probe); err != nil {
			continue
		}
		if probe.Name != "" && (len(probe.Parameters) > 0 || len(probe.Arguments) > 0) {
			return "json tool call to unknown tool '" + probe.Name + "'", true
		}
	}
	// Call scaffolding that name-drops an offered tool but failed both structured
	// parsing and JSON recovery (e.g. truncated or comma-broken JSON).
	if strings.Contains(lower, `"name"`) && (strings.Contains(lower, `"parameters"`) || strings.Contains(lower, `"arguments"`)) {
		for name := range known {
			if name != "" && strings.Contains(trimmed, name) {
				return "malformed tool call referencing '" + name + "'", true
			}
		}
	}
	return "", false
}

// extractToolCallsFromContent recovers a tool call that a model emitted as JSON
// text in its message content instead of as a structured tool_calls entry.
// Small / local models (e.g. Ollama-served llama3.2) frequently do this, which
// would otherwise make the runner mistake an honest handoff_to_human — or any
// offered tool — for a finished stage result and silently complete a task the
// agent meant to escalate. Only objects whose "name" matches a tool actually
// offered to the model (known) are recovered, so a genuine {"findings":...}
// answer is never misread as a call. Returns nil when no known tool call is
// present. The model's call shape varies ("parameters" vs "arguments"); both
// are accepted, and a missing/empty argument object becomes "{}".
func extractToolCallsFromContent(content string, known map[string]bool) []ToolCall {
	for _, candidate := range toolCallJSONCandidates(content) {
		var probe struct {
			Name       string          `json:"name"`
			Parameters json.RawMessage `json:"parameters"`
			Arguments  json.RawMessage `json:"arguments"`
		}
		if err := json.Unmarshal([]byte(candidate), &probe); err != nil {
			continue
		}
		if probe.Name == "" || !known[probe.Name] {
			continue
		}
		payload := probe.Parameters
		if len(payload) == 0 {
			payload = probe.Arguments
		}
		if len(payload) == 0 {
			payload = json.RawMessage("{}")
		}
		return []ToolCall{{Name: probe.Name, Payload: string(payload)}}
	}
	return nil
}

// toolCallJSONCandidates yields progressively more permissive JSON slices of a
// model's content to probe for a tool-call object: the trimmed content, the
// same with a surrounding markdown code fence removed, and the first
// brace-delimited {...} substring (handles a call wrapped in prose).
func toolCallJSONCandidates(content string) []string {
	trimmed := strings.TrimSpace(content)
	if trimmed == "" {
		return nil
	}
	candidates := []string{trimmed}
	if fenced := stripCodeFence(trimmed); fenced != trimmed {
		candidates = append(candidates, fenced)
	}
	if start := strings.IndexByte(trimmed, '{'); start >= 0 {
		if end := strings.LastIndexByte(trimmed, '}'); end > start {
			if inner := trimmed[start : end+1]; inner != trimmed {
				candidates = append(candidates, inner)
			}
		}
	}
	return candidates
}

// stripCodeFence removes a single leading ```/```json fence and trailing ```
// from s, returning s unchanged when it is not fenced.
func stripCodeFence(s string) string {
	if !strings.HasPrefix(s, "```") {
		return s
	}
	s = strings.TrimPrefix(s, "```")
	if nl := strings.IndexByte(s, '\n'); nl >= 0 {
		// Drop the optional language tag on the opening fence line (e.g. "json").
		if lang := strings.TrimSpace(s[:nl]); lang == "" || !strings.ContainsAny(lang, "{}") {
			s = s[nl+1:]
		}
	}
	s = strings.TrimSuffix(strings.TrimRight(s, " \n\t"), "```")
	return strings.TrimSpace(s)
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
