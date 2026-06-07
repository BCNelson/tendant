package router

import (
	"encoding/json"
	"strings"

	"github.com/bcnelson/tendant/services/api/internal/agent"
)

// Evaluate evaluates an eligibility expression against structured findings.
// Returns true if the expression is satisfied. An empty expression is always true.
// Returns false on any evaluation error (conservative: prune toward human).
func Evaluate(expr Expression, findings agent.StructuredFindings) bool {
	return evalExpr(expr, findings)
}

func evalExpr(expr Expression, f agent.StructuredFindings) bool {
	// Empty expression (no And/Or/Not/Pred) = always true.
	if len(expr.And) == 0 && len(expr.Or) == 0 && expr.Not == nil && expr.Pred == nil {
		return true
	}

	if len(expr.And) > 0 {
		for _, sub := range expr.And {
			if !evalExpr(sub, f) {
				return false
			}
		}
		return true
	}

	if len(expr.Or) > 0 {
		for _, sub := range expr.Or {
			if evalExpr(sub, f) {
				return true
			}
		}
		return false
	}

	if expr.Not != nil {
		return !evalExpr(*expr.Not, f)
	}

	if expr.Pred != nil {
		return evalPred(*expr.Pred, f)
	}

	return true
}

func evalPred(p Predicate, f agent.StructuredFindings) bool {
	switch p.Op {
	case "subset":
		return evalSubset(p, f)
	case "gte", "gt", "lte", "lt":
		return evalThreshold(p, f)
	case "contains":
		return evalContains(p, f)
	default:
		return false // unknown op → conservative
	}
}

// evalSubset: config's required capabilities must be a subset of findings.required_capabilities.
func evalSubset(p Predicate, f agent.StructuredFindings) bool {
	if p.Field != "required_capabilities" {
		return false
	}
	var required []string
	if err := json.Unmarshal(p.Value, &required); err != nil {
		return false
	}
	available := toSet(f.RequiredCapabilities)
	for _, cap := range required {
		if !available[cap] {
			return false
		}
	}
	return true
}

// evalThreshold: numeric comparison on stakes_score.
func evalThreshold(p Predicate, f agent.StructuredFindings) bool {
	if p.Field != "stakes_score" {
		return false
	}
	var threshold float64
	if err := json.Unmarshal(p.Value, &threshold); err != nil {
		return false
	}
	switch p.Op {
	case "gte":
		return f.StakesScore >= threshold
	case "gt":
		return f.StakesScore > threshold
	case "lte":
		return f.StakesScore <= threshold
	case "lt":
		return f.StakesScore < threshold
	default:
		return false
	}
}

// evalContains: set-membership on category_hints or entities.
func evalContains(p Predicate, f agent.StructuredFindings) bool {
	var needle string
	if err := json.Unmarshal(p.Value, &needle); err != nil {
		return false
	}
	needle = strings.ToLower(needle)

	switch p.Field {
	case "category_hints":
		for _, hint := range f.CategoryHints {
			if strings.ToLower(hint) == needle {
				return true
			}
		}
		return false
	case "entities":
		for _, ent := range f.Entities {
			if strings.ToLower(ent.Name) == needle || strings.ToLower(ent.Type) == needle {
				return true
			}
		}
		return false
	default:
		return false
	}
}

func toSet(items []string) map[string]bool {
	s := make(map[string]bool, len(items))
	for _, item := range items {
		s[item] = true
	}
	return s
}
