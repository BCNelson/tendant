package router

import (
	"encoding/json"
	"testing"

	"github.com/bcnelson/tendant/services/api/internal/agent"
)

func TestEvaluate_EmptyExpression(t *testing.T) {
	// Empty expression = always true.
	expr := Expression{}
	f := agent.StructuredFindings{}
	if !Evaluate(expr, f) {
		t.Error("empty expression should be true")
	}
}

func TestEvaluate_Subset(t *testing.T) {
	expr := Expression{
		Pred: &Predicate{
			Op:    "subset",
			Field: "required_capabilities",
			Value: json.RawMessage(`["send-email"]`),
		},
	}

	tests := []struct {
		name     string
		findings agent.StructuredFindings
		want     bool
	}{
		{
			name:     "capability present",
			findings: agent.StructuredFindings{RequiredCapabilities: []string{"send-email", "web_search"}},
			want:     true,
		},
		{
			name:     "capability absent",
			findings: agent.StructuredFindings{RequiredCapabilities: []string{"web_search"}},
			want:     false,
		},
		{
			name:     "empty findings capabilities",
			findings: agent.StructuredFindings{RequiredCapabilities: nil},
			want:     false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Evaluate(expr, tt.findings); got != tt.want {
				t.Errorf("Evaluate() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestEvaluate_Threshold(t *testing.T) {
	tests := []struct {
		name  string
		op    string
		val   float64
		score float64
		want  bool
	}{
		{"gte pass", "gte", 5, 7, true},
		{"gte fail", "gte", 5, 3, false},
		{"gte edge", "gte", 5, 5, true},
		{"lt pass", "lt", 5, 3, true},
		{"lt fail", "lt", 5, 7, false},
		{"gt pass", "gt", 5, 6, true},
		{"gt fail", "gt", 5, 5, false},
		{"lte pass", "lte", 5, 5, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			valJSON, _ := json.Marshal(tt.val)
			expr := Expression{
				Pred: &Predicate{Op: tt.op, Field: "stakes_score", Value: valJSON},
			}
			f := agent.StructuredFindings{StakesScore: tt.score}
			if got := Evaluate(expr, f); got != tt.want {
				t.Errorf("Evaluate() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestEvaluate_Contains(t *testing.T) {
	expr := Expression{
		Pred: &Predicate{
			Op:    "contains",
			Field: "category_hints",
			Value: json.RawMessage(`"multi_step"`),
		},
	}

	tests := []struct {
		name  string
		hints []string
		want  bool
	}{
		{"present", []string{"simple", "multi_step"}, true},
		{"absent", []string{"simple"}, false},
		{"case insensitive", []string{"Multi_Step"}, true},
		{"empty", nil, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			f := agent.StructuredFindings{CategoryHints: tt.hints}
			if got := Evaluate(expr, f); got != tt.want {
				t.Errorf("Evaluate() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestEvaluate_And(t *testing.T) {
	expr := Expression{
		And: []Expression{
			{Pred: &Predicate{Op: "subset", Field: "required_capabilities", Value: json.RawMessage(`["send-email"]`)}},
			{Pred: &Predicate{Op: "gte", Field: "stakes_score", Value: json.RawMessage(`3`)}},
		},
	}

	f1 := agent.StructuredFindings{RequiredCapabilities: []string{"send-email"}, StakesScore: 5}
	if !Evaluate(expr, f1) {
		t.Error("AND: both true should pass")
	}

	f2 := agent.StructuredFindings{RequiredCapabilities: []string{"send-email"}, StakesScore: 1}
	if Evaluate(expr, f2) {
		t.Error("AND: one false should fail")
	}
}

func TestEvaluate_Or(t *testing.T) {
	expr := Expression{
		Or: []Expression{
			{Pred: &Predicate{Op: "contains", Field: "category_hints", Value: json.RawMessage(`"email"`)}},
			{Pred: &Predicate{Op: "contains", Field: "category_hints", Value: json.RawMessage(`"communication"`)}},
		},
	}

	f1 := agent.StructuredFindings{CategoryHints: []string{"email"}}
	if !Evaluate(expr, f1) {
		t.Error("OR: first true should pass")
	}

	f2 := agent.StructuredFindings{CategoryHints: []string{"coding"}}
	if Evaluate(expr, f2) {
		t.Error("OR: none true should fail")
	}
}

func TestEvaluate_Not(t *testing.T) {
	expr := Expression{
		Not: &Expression{
			Pred: &Predicate{Op: "gte", Field: "stakes_score", Value: json.RawMessage(`8`)},
		},
	}

	f1 := agent.StructuredFindings{StakesScore: 5}
	if !Evaluate(expr, f1) {
		t.Error("NOT: inner false should be true")
	}

	f2 := agent.StructuredFindings{StakesScore: 9}
	if Evaluate(expr, f2) {
		t.Error("NOT: inner true should be false")
	}
}

func TestEvaluate_MalformedInput(t *testing.T) {
	// Malformed value JSON → false (conservative).
	expr := Expression{
		Pred: &Predicate{Op: "subset", Field: "required_capabilities", Value: json.RawMessage(`not json`)},
	}
	f := agent.StructuredFindings{RequiredCapabilities: []string{"anything"}}
	if Evaluate(expr, f) {
		t.Error("malformed value should evaluate to false")
	}
}

func TestParseExpression_EmptyInputs(t *testing.T) {
	tests := []struct {
		name  string
		input json.RawMessage
	}{
		{"nil", nil},
		{"empty", json.RawMessage("")},
		{"empty object", json.RawMessage("{}")},
		{"null", json.RawMessage("null")},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			expr := ParseExpression(tt.input)
			// Should be always-true.
			if !Evaluate(expr, agent.StructuredFindings{}) {
				t.Error("parsed empty input should be always-true")
			}
		})
	}
}
