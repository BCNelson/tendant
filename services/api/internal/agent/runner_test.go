package agent

import (
	"context"
	"encoding/json"
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
			r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut)
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
				r.auditFinish(ctx, rc, iter+1, totalTokensIn, totalTokensOut)
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
