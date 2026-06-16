package agent

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Converse is the Runner's second entry point: one structured-output turn of a
// human-paced conversation, as opposed to Run's autonomous plan→act→observe
// loop. It powers config-driven conversational agents (the post-completion
// feedback agent is the first) that must (1) optionally pull read-only context
// on demand, then (2) emit a single forced structured answer. Each Converse call
// produces exactly one agent turn — the caller persists it, waits for the human,
// and calls Converse again with the extended history.
//
// Converse shares the Runner's system-prompt assembly (config prompt +
// [OWNER_FEEDBACK] guidance) and model resolution with Run, so a conversational
// agent is configured exactly like a specialist (an agent_configs row), but it
// never touches the Gate/Dispatcher — its context tools are read-only reads
// dispatched through a ReadOnlyToolset, never gated catalog tools.

// ReadOnlyToolset dispatches a Converse run's read-only context tools by name.
// ok is false for a name that is not one of this run's context tools (so the
// gather loop ignores a hallucinated/unoffered call rather than acting on it).
type ReadOnlyToolset interface {
	Dispatch(ctx context.Context, name string, taskID uuid.UUID) (result string, ok bool)
}

const (
	defaultConverseGather = 4
	defaultConverseTokens = 512
)

// ConverseConfig parameterizes a single conversational structured-output turn.
type ConverseConfig struct {
	Config   db.AgentConfig // owns the system prompt + model, like any specialist
	TaskID   uuid.UUID      // scopes the read-only context tools
	Messages []Message      // the seed + prior conversation turns (caller-built)
	// OutputTool is the forced structured-output tool the model fills in to speak
	// (e.g. feedback's {reply, draft_guidance}). It is offered in the gather phase
	// too, so the model may answer early; it is the only tool offered at finalize.
	OutputTool ToolDef
	// ContextTools are the read-only deep-dive tools offered during the gather
	// phase. Empty (or a nil Toolset) skips the gather phase entirely.
	ContextTools []ToolDef
	Toolset      ReadOnlyToolset
	// ValidOutput, when set, gates an early return during the gather phase: an
	// OutputTool call is only accepted as the answer if its arguments validate
	// (e.g. decode to a non-empty {reply, draft_guidance}); otherwise the loop
	// keeps gathering and finalizes. nil ⇒ accept any non-empty arguments.
	ValidOutput func(args string) bool
	MaxGather   int // gather rounds (0 ⇒ default)
	MaxTokens   int // per-call reply cap (0 ⇒ default)
}

// ConverseResult is one produced agent turn. Response is the terminal model
// response (the forced-output call, or a gather-phase early answer); the caller
// decodes its domain-specific shape. Consulted lists the context tools dispatched
// this turn (for audit + UI).
type ConverseResult struct {
	Response  ChatResponse
	Consulted []string
	TokensIn  int
	TokensOut int
}

// Converse runs one structured-output turn: an optional read-only gather loop,
// then a forced-output finalize. It never gates or dispatches catalog tools.
func (r *Runner) Converse(ctx context.Context, cc ConverseConfig) (ConverseResult, error) {
	systemPrompt := ""
	if cc.Config.SystemPrompt != nil {
		systemPrompt = *cc.Config.SystemPrompt
	}
	// Same guidance injection as the autonomous loop: global + this-agent active
	// owner feedback under [OWNER_FEEDBACK]. nil Queries degrades to the bare prompt.
	systemPrompt = r.appendGuidance(ctx, cc.Config.ID, systemPrompt)

	model := ""
	if cc.Config.Model != nil {
		model = *cc.Config.Model
	}
	maxTokens := cc.MaxTokens
	if maxTokens <= 0 {
		maxTokens = defaultConverseTokens
	}
	maxGather := cc.MaxGather
	if maxGather <= 0 {
		maxGather = defaultConverseGather
	}

	msgs := append([]Message{}, cc.Messages...)
	var consulted []string
	var tokensIn, tokensOut int

	// Gather phase: let the agent pull deeper read-only context on demand. Only
	// runs when a Toolset + context tools are wired. Results are threaded back as
	// plain alternating user/assistant text turns (not the structured tool-result
	// channel) so the loop is portable across Anthropic's strict-alternation and
	// OpenAI's tool-call-id requirements alike.
	if cc.Toolset != nil && len(cc.ContextTools) > 0 {
		gatherTools := append(append([]ToolDef{}, cc.ContextTools...), cc.OutputTool)
		seen := map[string]bool{}
		for range maxGather {
			resp, err := r.Client.Chat(ctx, ChatRequest{
				Model: model, System: systemPrompt, Messages: msgs,
				Tools: gatherTools, MaxTokens: maxTokens,
			})
			if err != nil {
				break // degrade: skip the gather phase, finalize below
			}
			tokensIn += resp.TokensIn
			tokensOut += resp.TokensOut
			// The agent may produce its structured output directly during gather.
			if args, ok := outputToolArgs(resp, cc.OutputTool.Name); ok {
				if cc.ValidOutput == nil || cc.ValidOutput(args) {
					return ConverseResult{Response: resp, Consulted: consulted, TokensIn: tokensIn, TokensOut: tokensOut}, nil
				}
			}
			names, results := collectContext(ctx, resp, cc, seen)
			if len(names) == 0 {
				break // no fresh context tool called → finalize
			}
			consulted = append(consulted, names...)
			req := strings.TrimSpace(resp.Content)
			if req == "" {
				req = "(Reviewing the task context: " + strings.Join(names, ", ") + ")"
			}
			msgs = append(msgs,
				Message{Role: "assistant", Content: req},
				Message{Role: "user", Content: results},
			)
		}
	}

	// Finalize: force the structured output tool — the reliable channel, including
	// for OpenAI-compatible endpoints (Ollama) via json_object.
	resp, err := r.Client.Chat(ctx, ChatRequest{
		Model: model, System: systemPrompt, Messages: msgs,
		Tools:          []ToolDef{cc.OutputTool},
		ForceTool:      cc.OutputTool.Name,
		ResponseFormat: "json_object",
		MaxTokens:      maxTokens,
	})
	if err != nil {
		return ConverseResult{}, fmt.Errorf("converse finalize inference: %w", err)
	}
	tokensIn += resp.TokensIn
	tokensOut += resp.TokensOut
	return ConverseResult{Response: resp, Consulted: consulted, TokensIn: tokensIn, TokensOut: tokensOut}, nil
}

// outputToolArgs returns the arguments of the first call to the named output
// tool in a response, with ok false when absent or its arguments are blank.
func outputToolArgs(resp ChatResponse, name string) (args string, ok bool) {
	for _, tc := range resp.ToolCalls {
		if tc.Name == name && strings.TrimSpace(tc.Payload) != "" {
			return tc.Payload, true
		}
	}
	return "", false
}

// collectContext dispatches the fresh context-tool calls in a response through
// the Toolset, returning the names freshly consulted (deduped via seen) and the
// joined result block to feed back. The output tool and already-seen tools are
// skipped, so re-requesting the same context yields no progress and the gather
// loop falls through to finalize rather than spinning.
func collectContext(ctx context.Context, resp ChatResponse, cc ConverseConfig, seen map[string]bool) (names []string, results string) {
	var b strings.Builder
	for _, tc := range resp.ToolCalls {
		if tc.Name == cc.OutputTool.Name || seen[tc.Name] {
			continue
		}
		out, ok := cc.Toolset.Dispatch(ctx, tc.Name, cc.TaskID)
		if !ok {
			continue
		}
		seen[tc.Name] = true
		names = append(names, tc.Name)
		fmt.Fprintf(&b, "[CONTEXT:%s]\n%s\n\n", tc.Name, out)
	}
	return names, strings.TrimSpace(b.String())
}
