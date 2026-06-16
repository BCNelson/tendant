package agent

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// mockGate implements GateEvaluator for tests.
type mockGate struct {
	verdict GateVerdict
	err     error
	calls   int
}

func (g *mockGate) EvaluateCall(_ context.Context, _, _ uuid.UUID, _ json.RawMessage) (GateVerdict, error) {
	g.calls++
	return g.verdict, g.err
}

// mockDispatcher implements ToolDispatcher for tests.
type mockDispatcher struct {
	result string
	err    error
	calls  int
}

func (d *mockDispatcher) Dispatch(_ context.Context, _, _ uuid.UUID, _ json.RawMessage) (string, error) {
	d.calls++
	return d.result, d.err
}

// mockAuditor records audit writes.
type mockAuditor struct {
	entries []auditEntry
}

type auditEntry struct {
	TaskID  uuid.UUID
	Kind    string
	Payload any
}

func (a *mockAuditor) WriteAudit(_ context.Context, taskID uuid.UUID, kind string, payload any) error {
	a.entries = append(a.entries, auditEntry{TaskID: taskID, Kind: kind, Payload: payload})
	return nil
}

func (a *mockAuditor) hasKind(kind string) bool {
	for _, e := range a.entries {
		if e.Kind == kind {
			return true
		}
	}
	return false
}

func TestRunner_HostilePromptOffAllowlist(t *testing.T) {
	// The hostile prompt instructs the model to call "secret-tool" which is NOT
	// in the allowlist. The LogAgentClient is scripted to propose that call.
	auditor := &mockAuditor{}

	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{
				Content: "",
				ToolCalls: []ToolCall{
					{ID: "call-1", Name: "off-limits-tool", Payload: `{"secret": true}`},
				},
			},
			// After refusal, agent gives up and returns findings.
			{
				Content:   `{"findings":{"structured":{"category_hints":["hostile"],"stakes_score":9,"entities":[],"required_capabilities":[]},"free_text":"attempted off-allowlist"}}`,
				ToolCalls: nil,
			},
		},
	}

	// Runner with only "send-email" in allowlist.
	runner := &Runner{
		Client:     client,
		Gate:       &mockGate{verdict: GateVerdict{Decision: "approve"}},
		Dispatcher: &mockDispatcher{result: `{"ok": true}`},
		Auditor:    auditor,
		Queries:    nil, // resolveAllowlist is bypassed in this test
		MaxIter:    10,
		Budget:     100,
	}

	// Manually set up the test by calling Run with a config that has an empty
	// allowlist (no tools). We'll test the refusal path directly.
	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "hostile-agent",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`[]`), // empty allowlist
		},
		TaskID:    uuid.New(),
		TaskTitle: "Test task",
	}

	// Override resolveAllowlist by using an empty allowlist — any tool call will
	// be refused because idMap is empty.
	result, err := runWithResolvedTools(runner, ctx(t), rc, nil, nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	// Should complete (not fail-close) because the agent recovers after refusal.
	if result.FailCloseToHuman {
		t.Error("should not fail-close; agent recovered")
	}

	// Must have audited the refusal.
	if !auditor.hasKind("agent_call_refused") {
		t.Error("expected agent_call_refused audit entry")
	}
}

func TestRunner_BenignToolCall(t *testing.T) {
	toolID := uuid.New()
	gate := &mockGate{verdict: GateVerdict{Decision: "approve"}}
	dispatcher := &mockDispatcher{result: `{"sent": true}`}
	auditor := &mockAuditor{}

	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{
				ToolCalls: []ToolCall{
					{ID: "call-1", Name: "send-email", Payload: `{"to":"user@example.com"}`},
				},
			},
			{
				Content:   `{"findings":{"structured":{"category_hints":["email"],"stakes_score":3,"entities":[],"required_capabilities":["send-email"]},"free_text":"email sent"}}`,
				ToolCalls: nil,
			},
		},
	}

	runner := &Runner{
		Client:     client,
		Gate:       gate,
		Dispatcher: dispatcher,
		Auditor:    auditor,
		MaxIter:    10,
		Budget:     100,
	}

	tools := []ToolDef{{Name: "send-email", GlobalURI: "tendant:tool:send-email"}}
	idMap := map[string]uuid.UUID{"send-email": toolID}

	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "email-specialist",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`["` + toolID.String() + `"]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Send email",
	}

	result, err := runWithResolvedTools(runner, ctx(t), rc, tools, idMap)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if result.FailCloseToHuman {
		t.Error("should not fail-close for benign call")
	}
	if gate.calls != 1 {
		t.Errorf("expected 1 gate call, got %d", gate.calls)
	}
	if dispatcher.calls != 1 {
		t.Errorf("expected 1 dispatch, got %d", dispatcher.calls)
	}
	if result.Findings == nil {
		t.Fatal("expected findings in result")
	}
	if result.Findings.FreeText != "email sent" {
		t.Errorf("unexpected free_text: %s", result.Findings.FreeText)
	}
}

// TestRunner_HandoffToHuman covers the honest-output path: an agent that cannot
// complete the task calls the built-in handoff_to_human tool. The runner must
// fail-close to human (not fabricate a completion), record an agent_handoff
// audit row, and surface the agent's stated reason on the StageResult. The
// handoff tool is exercised through the real Runner.Run (the loop that injects
// and special-cases it), with an empty allowlist so resolveAllowlist needs no DB.
func TestRunner_HandoffToHuman(t *testing.T) {
	auditor := &mockAuditor{}
	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{
				ToolCalls: []ToolCall{
					{ID: "call-1", Name: HandoffToolName, Payload: `{"reason":"this task needs a phone call and I have no tool for that"}`},
				},
			},
		},
	}

	runner := &Runner{
		Client:     client,
		Gate:       &mockGate{verdict: GateVerdict{Decision: "approve"}},
		Dispatcher: &mockDispatcher{result: `{"ok":true}`},
		Auditor:    auditor,
		Queries:    nil, // empty allowlist ⇒ resolveAllowlist never touches the DB
		MaxIter:    10,
		Budget:     100,
	}

	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "general-executor",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`[]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Call the dentist to reschedule",
	}

	result, err := runner.Run(ctx(t), rc)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if !result.FailCloseToHuman {
		t.Error("handoff must fail-close to human, not complete")
	}
	if result.FailReason != "agent_handoff" {
		t.Errorf("FailReason = %q, want agent_handoff", result.FailReason)
	}
	if result.HandoffReason == "" || !containsStr(result.HandoffReason, "phone call") {
		t.Errorf("HandoffReason did not carry the agent's reason: %q", result.HandoffReason)
	}
	if result.Findings != nil {
		t.Error("handoff must not emit findings (no fabricated completion)")
	}
	if !auditor.hasKind("agent_handoff") {
		t.Error("expected agent_handoff audit entry")
	}
	// The dispatcher must never be reached — handoff is not a dispatchable tool.
	if d, ok := runner.Dispatcher.(*mockDispatcher); ok && d.calls != 0 {
		t.Errorf("dispatcher called %d times; handoff must not dispatch", d.calls)
	}
}

// TestRunner_HandoffEmittedAsContent reproduces the real-world break: a small /
// local model (e.g. Ollama llama3.2:3b) emits the handoff_to_human call as JSON
// text in its message content instead of a structured tool_calls entry. Before
// the content-fallback recovery the runner read this as a finished stage result
// and silently completed a task the agent meant to escalate. The runner must
// recover the call and fail-close to a human, exactly as if it had arrived
// structured.
func TestRunner_HandoffEmittedAsContent(t *testing.T) {
	auditor := &mockAuditor{}
	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{
				// Verbatim shape observed in the DB: tool call as content, no tool_calls.
				Content: `{"name":"handoff_to_human","parameters":{"reason":"this task needs a phone call and I have no tool for that"}}`,
			},
		},
	}

	runner := &Runner{
		Client:     client,
		Gate:       &mockGate{verdict: GateVerdict{Decision: "approve"}},
		Dispatcher: &mockDispatcher{result: `{"ok":true}`},
		Auditor:    auditor,
		Queries:    nil, // empty allowlist ⇒ resolveAllowlist never touches the DB
		MaxIter:    10,
		Budget:     100,
	}

	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "general-executor",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`[]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Call the dentist to reschedule",
	}

	result, err := runner.Run(ctx(t), rc)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if !result.FailCloseToHuman {
		t.Error("content-emitted handoff must fail-close to human, not complete")
	}
	if result.FailReason != "agent_handoff" {
		t.Errorf("FailReason = %q, want agent_handoff", result.FailReason)
	}
	if result.HandoffReason == "" || !containsStr(result.HandoffReason, "phone call") {
		t.Errorf("HandoffReason did not carry the agent's reason: %q", result.HandoffReason)
	}
	if result.Findings != nil {
		t.Error("content-emitted handoff must not be misread as findings")
	}
	if !auditor.hasKind("agent_handoff") {
		t.Error("expected agent_handoff audit entry")
	}
}

// TestRunner_ContentFindingsNotMisreadAsToolCall guards the fallback's
// precision: a normal findings answer (no "name" of an offered tool) must still
// be treated as a completed stage result, never recovered as a call.
func TestRunner_ContentFindingsNotMisreadAsToolCall(t *testing.T) {
	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{Content: `{"findings":{"structured":{"stakes_score":2},"free_text":"done"}}`},
		},
	}
	runner := &Runner{
		Client:  client,
		Gate:    &mockGate{verdict: GateVerdict{Decision: "approve"}},
		Auditor: &mockAuditor{},
		MaxIter: 10,
		Budget:  100,
	}
	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "general-executor",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`[]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Summarize the notes",
	}

	result, err := runner.Run(ctx(t), rc)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.FailCloseToHuman {
		t.Error("a normal findings answer must not fail-close to human")
	}
	if result.Findings == nil {
		t.Fatal("expected findings to be parsed from the completion")
	}
}

// TestRunner_NudgesSuspectedFailedToolCall covers the failed-tool-call filter:
// when a model emits something that looks like a tool call but names a tool we
// never offered (hallucinated), the runner must NOT accept it as a completion —
// it audits the attempt, nudges the model, and on the model's corrected retry
// proceeds normally (here the retry is a clean findings answer).
func TestRunner_NudgesSuspectedFailedToolCall(t *testing.T) {
	auditor := &mockAuditor{}
	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			// First turn: a botched call to a tool that was never offered.
			{Content: `{"name":"write_poem","arguments":{"topic":"fire"}}`},
			// Second turn (after the nudge): a proper findings completion.
			{Content: `{"findings":{"structured":{"stakes_score":1},"free_text":"poem written"}}`},
		},
	}
	runner := &Runner{
		Client:  client,
		Gate:    &mockGate{verdict: GateVerdict{Decision: "approve"}},
		Auditor: auditor,
		MaxIter: 10,
		Budget:  100,
	}
	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "general-executor",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`[]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Write a poem about fire",
	}

	result, err := runner.Run(ctx(t), rc)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !auditor.hasKind("agent_suspected_tool_attempt") {
		t.Error("expected an agent_suspected_tool_attempt audit entry")
	}
	if result.FailCloseToHuman {
		t.Error("model recovered on retry; should not fail-close")
	}
	if result.Findings == nil || result.Findings.FreeText != "poem written" {
		t.Errorf("expected the corrected completion to be parsed, got %+v", result.Findings)
	}
}

func TestSuspectedToolCallAttempt(t *testing.T) {
	known := map[string]bool{"send_email": true, HandoffToolName: true}
	cases := []struct {
		name    string
		content string
		want    bool
	}{
		{"hallucinated json call", `{"name":"write_poem","arguments":{"x":1}}`, true},
		{"tool_call markup", "<tool_call>{\"name\":\"x\"}</tool_call>", true},
		{"python tag", "<|python_tag|>send_email(...)", true},
		{"fenced tool_code", "```tool_code\nsend_email()\n```", true},
		{"malformed referencing known", `{"name": "send_email", "parameters": {`, true},
		{"normal findings", `{"findings":{"structured":{"stakes_score":1},"free_text":"ok"}}`, false},
		{"plain prose", "I have completed the task and sent the summary.", false},
		{"empty", "   ", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			_, got := suspectedToolCallAttempt(tc.content, known)
			if got != tc.want {
				t.Errorf("suspectedToolCallAttempt(%q) = %v, want %v", tc.content, got, tc.want)
			}
		})
	}
}

func containsStr(s, sub string) bool { return strings.Contains(s, sub) }

func TestRunner_FloorTripsRequestDecision(t *testing.T) {
	decisionID := uuid.New()
	gate := &mockGate{verdict: GateVerdict{Decision: "request_decision", PendingDecisionID: &decisionID}}
	auditor := &mockAuditor{}

	client := &LogAgentClient{
		Fixtures: []ChatResponse{
			{
				ToolCalls: []ToolCall{
					{ID: "call-1", Name: "send-email", Payload: `{"to":"stranger","amount":"$5000"}`},
				},
			},
		},
	}

	toolID := uuid.New()
	runner := &Runner{
		Client:     client,
		Gate:       gate,
		Dispatcher: &mockDispatcher{},
		Auditor:    auditor,
		MaxIter:    10,
		Budget:     100,
	}

	tools := []ToolDef{{Name: "send-email", GlobalURI: "tendant:tool:send-email"}}
	idMap := map[string]uuid.UUID{"send-email": toolID}

	rc := RunConfig{
		Config: db.AgentConfig{
			ID:            uuid.New(),
			Name:          "email-specialist",
			Stage:         "execution",
			ToolAllowlist: json.RawMessage(`["` + toolID.String() + `"]`),
		},
		TaskID:    uuid.New(),
		TaskTitle: "Send money",
	}

	result, err := runWithResolvedTools(runner, ctx(t), rc, tools, idMap)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if !result.FailCloseToHuman {
		t.Error("expected fail-close on RequestDecision")
	}
	if result.FailReason != "request_decision" {
		t.Errorf("expected reason 'request_decision', got '%s'", result.FailReason)
	}
}

// runWithResolvedTools bypasses resolveAllowlist for unit tests, running the
// loop directly with pre-resolved tools and ID map.
func runWithResolvedTools(r *Runner, ctx context.Context, rc RunConfig, tools []ToolDef, idMap map[string]uuid.UUID) (StageResult, error) {
	if tools == nil {
		tools = []ToolDef{}
	}
	if idMap == nil {
		idMap = map[string]uuid.UUID{}
	}

	systemPrompt := ""
	if rc.Config.SystemPrompt != nil {
		systemPrompt = *rc.Config.SystemPrompt
	}
	model := ""
	if rc.Config.Model != nil {
		model = *rc.Config.Model
	}

	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_run_started", map[string]any{
			"config_id":   rc.Config.ID,
			"config_name": rc.Config.Name,
			"stage":       rc.Config.Stage,
		})
	}

	messages := []Message{{Role: "user", Content: buildTaskPrompt(rc)}}
	var gateCallCount int
	var totalTokensIn, totalTokensOut int

	for iter := range r.MaxIter {
		_ = iter
		resp, chatErr := r.Client.Chat(ctx, ChatRequest{
			Model: model, System: systemPrompt, Messages: messages, Tools: tools,
		})
		if chatErr != nil {
			return StageResult{FailCloseToHuman: true, FailReason: "gateway_error"}, nil
		}
		totalTokensIn += resp.TokensIn
		totalTokensOut += resp.TokensOut

		if len(resp.ToolCalls) == 0 {
			result := parseStageResult(resp.Content)
			r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, nil)
			return result, nil
		}

		messages = append(messages, Message{Role: "assistant", Content: resp.Content})
		for _, tc := range resp.ToolCalls {
			toolID, inAllowlist := idMap[tc.Name]
			if !inAllowlist {
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "agent_call_refused", map[string]any{
						"tool_name": tc.Name, "reason": "not_in_allowlist",
					})
				}
				messages = append(messages, Message{Role: "tool_result", Content: `{"error":"not in allowlist"}`})
				continue
			}
			gateCallCount++
			if gateCallCount > r.Budget {
				if r.Auditor != nil {
					_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "budget_exhausted", map[string]any{
						"budget": r.Budget, "calls_made": gateCallCount, "stage": rc.Config.Stage,
					})
				}
				return StageResult{FailCloseToHuman: true, FailReason: "budget_exhausted"}, nil
			}
			verdict, gErr := r.Gate.EvaluateCall(ctx, rc.TaskID, toolID, json.RawMessage(tc.Payload))
			if gErr != nil {
				messages = append(messages, Message{Role: "tool_result", Content: `{"error":"gate error"}`})
				continue
			}
			switch verdict.Decision {
			case "approve":
				outcome, dErr := r.Dispatcher.Dispatch(ctx, rc.TaskID, toolID, json.RawMessage(tc.Payload))
				if dErr != nil {
					messages = append(messages, Message{Role: "tool_result", Content: `{"error":"dispatch error"}`})
				} else {
					messages = append(messages, Message{Role: "tool_result", Content: outcome})
				}
			case "request_decision":
				r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut, nil)
				return StageResult{FailCloseToHuman: true, FailReason: "request_decision"}, nil
			case "deny":
				messages = append(messages, Message{Role: "tool_result", Content: `{"error":"denied"}`})
			}
		}
	}

	if r.Auditor != nil {
		_ = r.Auditor.WriteAudit(ctx, rc.TaskID, "max_iterations_reached", map[string]any{
			"task_id": rc.TaskID, "stage": rc.Config.Stage, "iterations": r.MaxIter,
		})
	}
	return StageResult{FailCloseToHuman: true, FailReason: "max_iterations"}, nil
}

func ctx(t *testing.T) context.Context {
	t.Helper()
	return context.Background()
}

// recordingClient captures the tools presented to the model on the first Chat
// call, then returns a no-tool-call completion so the loop ends immediately.
type recordingClient struct {
	tools []ToolDef
}

func (c *recordingClient) Chat(_ context.Context, req ChatRequest) (ChatResponse, error) {
	if c.tools == nil {
		c.tools = req.Tools
	}
	return ChatResponse{Content: `{"findings":{}}`, TokensIn: 1, TokensOut: 1}, nil
}

func (c *recordingClient) hasTool(name string) bool {
	for _, t := range c.tools {
		if t.Name == name {
			return true
		}
	}
	return false
}

// TestRunner_HandoffToolOnlyForExecution proves the built-in handoff_to_human
// tool is presented to the model only for execution-stage agents. Triage and
// expansion agents assess/enrich and perform no outward action, so they must
// not even see the handoff tool.
func TestRunner_HandoffToolOnlyForExecution(t *testing.T) {
	cases := []struct {
		stage      db.AgentStage
		wantInList bool
	}{
		{db.AgentStageTriage, false},
		{db.AgentStageExpansion, false},
		{db.AgentStageExecution, true},
	}
	for _, tc := range cases {
		t.Run(string(tc.stage), func(t *testing.T) {
			client := &recordingClient{}
			runner := &Runner{
				Client:  client,
				Auditor: &mockAuditor{},
				Queries: nil, // empty allowlist ⇒ no DB access
				MaxIter: 1,
				Budget:  10,
			}
			rc := RunConfig{
				Config: db.AgentConfig{
					ID:            uuid.New(),
					Name:          "agent-" + string(tc.stage),
					Stage:         tc.stage,
					ToolAllowlist: json.RawMessage(`[]`),
				},
				TaskID:    uuid.New(),
				TaskTitle: "x",
			}
			if _, err := runner.Run(ctx(t), rc); err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got := client.hasTool(HandoffToolName); got != tc.wantInList {
				t.Errorf("stage %s: handoff tool presented = %v, want %v", tc.stage, got, tc.wantInList)
			}
		})
	}
}
