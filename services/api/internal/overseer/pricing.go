package overseer

// ModelPricing is the per-million-token cost in cents. Floats keep
// fractional cents (e.g. $0.00125/Mtok = 0.125 cents/Mtok) honest.
type ModelPricing struct {
	CentsPerMillionInput  float64
	CentsPerMillionOutput float64
}

// pricing is the package-level lookup: provider -> model_id -> ModelPricing.
// Phase 4 ships only the models that are actually wired today; unknown
// combos return 0 from EstimateCostUSD (gateway still records the audit row).
//
// Numbers reflect public list pricing at Phase 4 ship time; tune by editing
// this table — no migration, no schema change.
var pricing = map[string]map[string]ModelPricing{
	"log": {
		"log": {CentsPerMillionInput: 0, CentsPerMillionOutput: 0},
	},
	"anthropic": {
		"claude-sonnet-4-6": {CentsPerMillionInput: 300, CentsPerMillionOutput: 1500},
	},
	"openai": {
		"gpt-4.1-mini": {CentsPerMillionInput: 40, CentsPerMillionOutput: 160},
	},
	"gemini": {
		"gemini-2.0-flash": {CentsPerMillionInput: 10, CentsPerMillionOutput: 40},
	},
	"bedrock": {
		"anthropic.claude-3-5-sonnet-20241022-v2:0": {CentsPerMillionInput: 300, CentsPerMillionOutput: 1500},
	},
}

// EstimateCostUSD returns the estimated cost in USD for one evaluation.
// Unknown provider/model combos return 0 — the audit row still lands,
// just without a cost estimate. Callers must NOT use a zero return as a
// "free" signal; check the (provider, modelID) pair separately if that
// distinction matters.
func EstimateCostUSD(provider, modelID string, tokensIn, tokensOut int) float64 {
	models, ok := pricing[provider]
	if !ok {
		return 0
	}
	p, ok := models[modelID]
	if !ok {
		return 0
	}
	inUSD := float64(tokensIn) * p.CentsPerMillionInput / 1_000_000 / 100
	outUSD := float64(tokensOut) * p.CentsPerMillionOutput / 1_000_000 / 100
	return inUSD + outUSD
}
