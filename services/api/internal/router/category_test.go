package router

import (
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// buildTree returns a small category tree:
//
//	communication               (binds expansion → [general-expander])
//	communication/email         (binds execution → {agents:[email-specialist], elig: stakes<=6})
//	engineering                 (binds execution → {agents:[code-executor]})
func buildTree() []db.TaskCategory {
	commID := uuid.New()
	return []db.TaskCategory{
		{
			ID:            commID,
			Key:           "communication",
			Label:         "Communication",
			StageBindings: json.RawMessage(`{"expansion":{"agents":["general-expander"]}}`),
		},
		{
			ID:            uuid.New(),
			Key:           "communication/email",
			ParentID:      pgtype.UUID{Bytes: commID, Valid: true},
			Label:         "Email",
			StageBindings: json.RawMessage(`{"execution":{"agents":["email-specialist"],"eligibility":{"pred":{"op":"lte","field":"stakes_score","value":6}}}}`),
		},
		{
			ID:            uuid.New(),
			Key:           "engineering",
			Label:         "Engineering",
			StageBindings: json.RawMessage(`{"execution":{"agents":["code-executor"]}}`),
		},
	}
}

func cfg(name, elig string) db.AgentConfig {
	if elig == "" {
		elig = "{}"
	}
	return db.AgentConfig{ID: uuid.New(), Name: name, Eligibility: json.RawMessage(elig)}
}

func TestResolveBinding(t *testing.T) {
	tree := buildTree()

	tests := []struct {
		name      string
		key       string
		stage     db.AgentStage
		wantFound bool
		wantAgent string // first agent in the resolved binding (when found)
	}{
		{"leaf own binding", "communication/email", db.AgentStageExecution, true, "email-specialist"},
		{"leaf inherits parent", "communication/email", db.AgentStageExpansion, true, "general-expander"},
		{"no binding for stage", "engineering", db.AgentStageExpansion, false, ""},
		{"unknown category", "does/not/exist", db.AgentStageExecution, false, ""},
		{"root own binding", "communication", db.AgentStageExpansion, true, "general-expander"},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			b, found := resolveBinding(tree, tc.key, tc.stage)
			if found != tc.wantFound {
				t.Fatalf("found = %v, want %v", found, tc.wantFound)
			}
			if found && (len(b.Agents) == 0 || b.Agents[0] != tc.wantAgent) {
				t.Fatalf("agents = %v, want first %q", b.Agents, tc.wantAgent)
			}
		})
	}
}

func TestFilterByBinding(t *testing.T) {
	email := cfg("email-specialist", "")
	sms := cfg("sms-specialist", "")
	general := cfg("general-executor", "")
	// An agent with its own guard that the task does NOT satisfy.
	guarded := cfg("guarded", `{"pred":{"op":"subset","field":"required_capabilities","value":["never"]}}`)
	configs := []db.AgentConfig{email, sms, general, guarded}

	names := func(cs []db.AgentConfig) []string {
		out := make([]string, len(cs))
		for i, c := range cs {
			out[i] = c.Name
		}
		return out
	}

	tests := []struct {
		name     string
		binding  StageBinding
		findings agent.StructuredFindings
		want     []string
	}{
		{
			name:    "static list only",
			binding: StageBinding{Agents: []string{"email-specialist", "sms-specialist"}},
			want:    []string{"email-specialist", "sms-specialist"},
		},
		{
			name:     "expression only includes",
			binding:  StageBinding{Eligibility: ParseExpression(json.RawMessage(`{"pred":{"op":"lte","field":"stakes_score","value":6}}`))},
			findings: agent.StructuredFindings{StakesScore: 3},
			// guarded fails its own eligibility, so excluded even though the binding expr passes.
			want: []string{"email-specialist", "sms-specialist", "general-executor"},
		},
		{
			name:     "expression only excludes all",
			binding:  StageBinding{Eligibility: ParseExpression(json.RawMessage(`{"pred":{"op":"lte","field":"stakes_score","value":6}}`))},
			findings: agent.StructuredFindings{StakesScore: 9},
			want:     nil,
		},
		{
			name:     "list AND expression combined — pass",
			binding:  StageBinding{Agents: []string{"email-specialist"}, Eligibility: ParseExpression(json.RawMessage(`{"pred":{"op":"lte","field":"stakes_score","value":6}}`))},
			findings: agent.StructuredFindings{StakesScore: 4},
			want:     []string{"email-specialist"},
		},
		{
			name:     "list AND expression combined — expression fails",
			binding:  StageBinding{Agents: []string{"email-specialist"}, Eligibility: ParseExpression(json.RawMessage(`{"pred":{"op":"lte","field":"stakes_score","value":6}}`))},
			findings: agent.StructuredFindings{StakesScore: 8},
			want:     nil,
		},
		{
			name:    "agent own guard excludes from list",
			binding: StageBinding{Agents: []string{"guarded", "email-specialist"}},
			want:    []string{"email-specialist"},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got := names(filterByBinding(configs, tc.binding, tc.findings))
			if len(got) != len(tc.want) {
				t.Fatalf("got %v, want %v", got, tc.want)
			}
			for i := range got {
				if got[i] != tc.want[i] {
					t.Fatalf("got %v, want %v", got, tc.want)
				}
			}
		})
	}
}
