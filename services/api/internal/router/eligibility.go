package router

import "encoding/json"

// Expression is the eligibility expression stored in agent_configs.eligibility.
// It is a boolean expression tree evaluated deterministically against
// StructuredFindings. An empty/nil Expression evaluates to true (always eligible).
type Expression struct {
	And  []Expression `json:"and,omitempty"`
	Or   []Expression `json:"or,omitempty"`
	Not  *Expression  `json:"not,omitempty"`
	Pred *Predicate   `json:"pred,omitempty"`
}

// Predicate is a leaf node in the expression tree.
type Predicate struct {
	Op    string          `json:"op"`    // "subset", "gte", "lte", "gt", "lt", "contains"
	Field string          `json:"field"` // "required_capabilities", "stakes_score", "category_hints", "entities"
	Value json.RawMessage `json:"value"` // type depends on op: []string, number, or string
}

// ParseExpression unmarshals a JSON eligibility expression.
// Returns an empty Expression (always-true) on nil/empty/malformed input.
func ParseExpression(raw json.RawMessage) Expression {
	if len(raw) == 0 || string(raw) == "{}" || string(raw) == "null" {
		return Expression{}
	}
	var expr Expression
	if err := json.Unmarshal(raw, &expr); err != nil {
		return Expression{} // malformed → always-true (conservative: prune nothing)
	}
	return expr
}
