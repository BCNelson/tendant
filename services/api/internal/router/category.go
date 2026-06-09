package router

import (
	"encoding/json"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// StageBinding is a category's per-stage routing rule: a static agent shortlist
// and/or a dynamic eligibility expression. The two are ANDed when building the
// stage candidate set; either may be omitted (empty list = any agent for the
// stage; empty/absent expression = no extra filter).
type StageBinding struct {
	Agents      []string   `json:"agents"`
	Eligibility Expression `json:"eligibility"`
}

// resolveBinding finds the nearest stage binding for a category by walking from
// the category up its ancestors (parent_id). Returns the first ancestor that
// declares a binding for the stage. ok=false means no category in the chain
// binds this stage — the caller falls back to eligibility routing.
func resolveBinding(cats []db.TaskCategory, key string, stage db.AgentStage) (StageBinding, bool) {
	byID := make(map[uuid.UUID]db.TaskCategory, len(cats))
	byKey := make(map[string]db.TaskCategory, len(cats))
	for _, c := range cats {
		byID[c.ID] = c
		byKey[c.Key] = c
	}

	cur, ok := byKey[key]
	if !ok {
		return StageBinding{}, false
	}
	// Bounded by the number of categories: a cycle (shouldn't happen with a tree)
	// can't loop forever because we stop once we've visited every node.
	for range cats {
		if b, found := parseStageBinding(cur.StageBindings, stage); found {
			return b, true
		}
		if !cur.ParentID.Valid {
			break
		}
		parent, ok := byID[uuid.UUID(cur.ParentID.Bytes)]
		if !ok {
			break
		}
		cur = parent
	}
	return StageBinding{}, false
}

// parseStageBinding extracts the binding for a single stage from a category's
// stage_bindings jsonb. found=false when the stage isn't present (or the jsonb is
// malformed — conservative: treat as no binding so routing falls back).
func parseStageBinding(raw json.RawMessage, stage db.AgentStage) (StageBinding, bool) {
	if len(raw) == 0 {
		return StageBinding{}, false
	}
	var m map[string]json.RawMessage
	if err := json.Unmarshal(raw, &m); err != nil {
		return StageBinding{}, false
	}
	bRaw, ok := m[string(stage)]
	if !ok {
		return StageBinding{}, false
	}
	var b StageBinding
	if err := json.Unmarshal(bRaw, &b); err != nil {
		return StageBinding{}, false
	}
	return b, true
}

// filterByBinding builds the candidate set for a bound stage: an agent survives
// iff it is in the binding's agents shortlist (when non-empty) AND passes the
// binding's eligibility expression AND passes its own eligibility expression.
// The agent's own expression is always applied so a per-agent guard is never
// loosened by a category binding.
func filterByBinding(configs []db.AgentConfig, b StageBinding, f agent.StructuredFindings) []db.AgentConfig {
	allow := make(map[string]bool, len(b.Agents))
	for _, n := range b.Agents {
		allow[n] = true
	}
	var out []db.AgentConfig
	for _, c := range configs {
		if len(allow) > 0 && !allow[c.Name] {
			continue
		}
		if !Evaluate(b.Eligibility, f) {
			continue
		}
		if !Evaluate(ParseExpression(c.Eligibility), f) {
			continue
		}
		out = append(out, c)
	}
	return out
}
