package agent

import "encoding/json"

// Findings is the output a stage-agent writes to tasks.findings.
// Structured binds deterministic eligibility; FreeText feeds the LLM router.
type Findings struct {
	Structured StructuredFindings `json:"structured"`
	FreeText   string             `json:"free_text"`
}

// StructuredFindings is the v1 normative schema. Eligibility may only bind to
// these four fields; extra keys are ignored.
type StructuredFindings struct {
	CategoryHints        []string `json:"category_hints"`
	StakesScore          float64  `json:"stakes_score"`
	Entities             []Entity `json:"entities"`
	RequiredCapabilities []string `json:"required_capabilities"`
}

// Entity is an identified entity within a task's context.
type Entity struct {
	Name string `json:"name"`
	Type string `json:"type"` // "person", "org", "service", etc.
}

// StageResult is the runner's output for a single stage.
type StageResult struct {
	Findings         *Findings       `json:"findings,omitempty"`
	ContextRefs      json.RawMessage `json:"context_refs,omitempty"` // expansion only
	FailCloseToHuman bool            `json:"fail_close_to_human"`
	FailReason       string          `json:"fail_reason,omitempty"` // "budget_exhausted", "max_iterations", "gateway_error"
}
