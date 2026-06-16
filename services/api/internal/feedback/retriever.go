package feedback

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// Retriever is the feedback agent's read-only window onto what happened during a
// completed task. Digest builds the compact context block front-loaded into every
// turn; the four detail methods back the on-demand context tools (each returns a
// JSON string fed straight back to the model as a tool_result). All methods are
// side-effect-free reads — the feedback agent can look, never act.
type Retriever interface {
	Digest(ctx context.Context, taskID uuid.UUID) (TaskContext, error)
	ToolOutcomes(ctx context.Context, taskID uuid.UUID) (string, error)
	AgentTranscript(ctx context.Context, taskID uuid.UUID) (string, error)
	AuditTrail(ctx context.Context, taskID uuid.UUID) (string, error)
	ExistingGuidance(ctx context.Context) (string, error)
}

// Context-tool names. Stable identifiers: exposed to the model as tool names,
// recorded in DecisionPayload.ContextConsulted, and surfaced in the Flutter UI.
const (
	ToolGetToolOutcomes     = "get_task_outcomes"
	ToolGetAgentTranscript  = "get_agent_transcript"
	ToolGetTaskAudit        = "get_task_audit"
	ToolGetExistingGuidance = "get_existing_guidance"
)

// TaskContext is the compact, front-loaded digest of a completed task. It is
// cheap to compute and small enough to prepend to every feedback turn; the heavy
// detail (full transcripts, full audit DAG, raw payloads) is left to the tools.
type TaskContext struct {
	ToolsRun       int      `json:"tools_run"`
	ToolsFlagged   int      `json:"tools_flagged"`
	AgentStages    []string `json:"agent_stages"`
	HandoffReason  string   `json:"handoff_reason,omitempty"`
	ActiveGuidance []string `json:"active_guidance"`
	Summary        string   `json:"summary"`
}

// dbRetriever is the production Retriever, backed by sqlc queries.
type dbRetriever struct {
	q *db.Queries
}

// NewDBRetriever builds the DB-backed Retriever. A nil *db.Queries yields a
// retriever whose reads error — callers guard on a nil Retriever instead.
func NewDBRetriever(q *db.Queries) Retriever { return &dbRetriever{q: q} }

// Digest assembles the compact context block from the audit DAG, the tool
// outcomes, and the active standing guidance. Best-effort by construction: a
// failed sub-read leaves that slice of the digest empty rather than failing the
// whole turn.
func (r *dbRetriever) Digest(ctx context.Context, taskID uuid.UUID) (TaskContext, error) {
	var tc TaskContext

	outcomes, err := r.q.ListToolOutcomesForTask(ctx, taskID)
	if err != nil {
		return tc, fmt.Errorf("list tool outcomes: %w", err)
	}
	tc.ToolsRun = len(outcomes)
	for i := range outcomes {
		if outcomes[i].Outcome == db.ToolOutcomeKindBad {
			tc.ToolsFlagged++
		}
	}

	audits, err := r.q.ListAuditForTask(ctx, taskID)
	if err != nil {
		return tc, fmt.Errorf("list audit for task: %w", err)
	}
	stageSeen := map[string]bool{}
	for i := range audits {
		a := &audits[i]
		switch a.Kind {
		case lifecycle.KindAgentRunFinished:
			if stage := stringField(a.Payload, "stage"); stage != "" && !stageSeen[stage] {
				stageSeen[stage] = true
				tc.AgentStages = append(tc.AgentStages, stage)
			}
		case lifecycle.KindAgentHandoff:
			if reason := stringField(a.Payload, "reason"); reason != "" {
				tc.HandoffReason = reason // last one wins (most recent handoff)
			}
		}
	}

	guidance, err := r.q.ListAllActiveGuidance(ctx)
	if err != nil {
		return tc, fmt.Errorf("list active guidance: %w", err)
	}
	for i := range guidance {
		tc.ActiveGuidance = append(tc.ActiveGuidance, guidance[i].Note)
	}

	tc.Summary = summarize(&tc)
	return tc, nil
}

// summarize renders the one-line human digest shown in the UI and seed.
func summarize(tc *TaskContext) string {
	var b strings.Builder
	fmt.Fprintf(&b, "%d tool call(s)", tc.ToolsRun)
	if tc.ToolsFlagged > 0 {
		fmt.Fprintf(&b, " (%d flagged bad)", tc.ToolsFlagged)
	}
	if len(tc.AgentStages) > 0 {
		fmt.Fprintf(&b, "; agent stages: %s", strings.Join(tc.AgentStages, ", "))
	}
	if tc.HandoffReason != "" {
		b.WriteString("; handed off to a human")
	}
	if n := len(tc.ActiveGuidance); n > 0 {
		fmt.Fprintf(&b, "; %d active guidance note(s)", n)
	}
	return b.String()
}

// ToolOutcomes returns the per-tool outcome rows (with tool name/URI resolved),
// as a JSON array string for a tool_result.
func (r *dbRetriever) ToolOutcomes(ctx context.Context, taskID uuid.UUID) (string, error) {
	outcomes, err := r.q.ListToolOutcomesForTask(ctx, taskID)
	if err != nil {
		return "", fmt.Errorf("list tool outcomes: %w", err)
	}
	type outRow struct {
		Tool        string `json:"tool"`
		ToolURI     string `json:"tool_uri"`
		Outcome     string `json:"outcome"`
		Fingerprint string `json:"routine_fingerprint,omitempty"`
		At          string `json:"at"`
	}
	names := map[uuid.UUID]db.Tool{}
	rows := make([]outRow, 0, len(outcomes))
	for i := range outcomes {
		o := &outcomes[i]
		tool, ok := names[o.ToolID]
		if !ok {
			if t, terr := r.q.GetToolByID(ctx, o.ToolID); terr == nil {
				tool = t
				names[o.ToolID] = t
			}
		}
		row := outRow{
			Tool:    tool.Name,
			ToolURI: tool.GlobalUri,
			Outcome: string(o.Outcome),
			At:      o.At.UTC().Format("2006-01-02T15:04:05Z"),
		}
		if o.RoutineFingerprint != nil {
			row.Fingerprint = *o.RoutineFingerprint
		}
		rows = append(rows, row)
	}
	return marshalTool(map[string]any{"outcomes": rows})
}

// AgentTranscript returns each agent stage's plan→act→observe transcript (the
// agent_run_finished payloads), as a JSON array string.
func (r *dbRetriever) AgentTranscript(ctx context.Context, taskID uuid.UUID) (string, error) {
	audits, err := r.q.ListAuditForTask(ctx, taskID)
	if err != nil {
		return "", fmt.Errorf("list audit for task: %w", err)
	}
	runs := make([]json.RawMessage, 0, 4)
	for i := range audits {
		if audits[i].Kind == lifecycle.KindAgentRunFinished {
			runs = append(runs, audits[i].Payload)
		}
	}
	return marshalTool(map[string]any{"runs": runs})
}

// AuditTrail returns the full task audit DAG as a compact {kind, at, payload}
// array string, oldest-first (the order ListAuditForTask returns).
func (r *dbRetriever) AuditTrail(ctx context.Context, taskID uuid.UUID) (string, error) {
	audits, err := r.q.ListAuditForTask(ctx, taskID)
	if err != nil {
		return "", fmt.Errorf("list audit for task: %w", err)
	}
	type auditRow struct {
		Kind    string          `json:"kind"`
		At      string          `json:"at"`
		Payload json.RawMessage `json:"payload"`
	}
	rows := make([]auditRow, 0, len(audits))
	for i := range audits {
		a := &audits[i]
		rows = append(rows, auditRow{
			Kind:    a.Kind,
			At:      a.At.UTC().Format("2006-01-02T15:04:05Z"),
			Payload: a.Payload,
		})
	}
	return marshalTool(map[string]any{"audit": rows})
}

// ExistingGuidance returns every active standing-guidance note (global + agent-
// scoped) so the agent can build on and avoid duplicating what already exists.
func (r *dbRetriever) ExistingGuidance(ctx context.Context) (string, error) {
	guidance, err := r.q.ListAllActiveGuidance(ctx)
	if err != nil {
		return "", fmt.Errorf("list active guidance: %w", err)
	}
	type noteRow struct {
		Scope string `json:"scope"`
		Note  string `json:"note"`
	}
	rows := make([]noteRow, 0, len(guidance))
	for i := range guidance {
		rows = append(rows, noteRow{Scope: guidance[i].Scope, Note: guidance[i].Note})
	}
	return marshalTool(map[string]any{"guidance": rows})
}

// marshalTool serializes a tool result, returning a JSON error object string
// rather than an error so a serialization hiccup still yields a usable
// tool_result (the model can carry on).
func marshalTool(v any) (string, error) {
	b, err := json.Marshal(v)
	if err != nil {
		return `{"error":"failed to serialize context"}`, nil
	}
	return string(b), nil
}

// stringField extracts a top-level string field from a JSON object payload,
// returning "" when absent or unparseable.
func stringField(payload []byte, key string) string {
	var m map[string]json.RawMessage
	if json.Unmarshal(payload, &m) != nil {
		return ""
	}
	raw, ok := m[key]
	if !ok {
		return ""
	}
	var s string
	if json.Unmarshal(raw, &s) != nil {
		return ""
	}
	return s
}
