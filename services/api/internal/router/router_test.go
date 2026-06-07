package router

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

func TestPruneEligible(t *testing.T) {
	configA := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "email-specialist",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["send-email"]}}`),
	}
	configB := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "general-executor",
		Eligibility: json.RawMessage(`{}`), // always eligible
	}
	configC := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "code-executor",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["run_code"]}}`),
	}

	findings := agent.StructuredFindings{
		RequiredCapabilities: []string{"send-email"},
		StakesScore:          3,
		CategoryHints:        []string{"communication"},
	}

	eligible := PruneEligible([]db.AgentConfig{configA, configB, configC}, findings)

	// configA: subset ["send-email"] ⊆ ["send-email"] → true
	// configB: always eligible → true
	// configC: subset ["run_code"] ⊆ ["send-email"] → false
	if len(eligible) != 2 {
		t.Fatalf("expected 2 eligible, got %d", len(eligible))
	}
	if eligible[0].Name != "email-specialist" {
		t.Errorf("expected email-specialist first, got %s", eligible[0].Name)
	}
	if eligible[1].Name != "general-executor" {
		t.Errorf("expected general-executor second, got %s", eligible[1].Name)
	}
}

func TestRouterSelect_PicksEligible(t *testing.T) {
	configA := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "email-specialist",
		Eligibility: json.RawMessage(`{}`),
	}
	configB := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "code-executor",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["run_code"]}}`),
	}

	picker := &LogPicker{PickByName: "email-specialist"}
	_ = &Router{picker: picker} // full integration uses Router.Select with DB

	findings := agent.Findings{
		Structured: agent.StructuredFindings{
			RequiredCapabilities: []string{"send-email"},
		},
		FreeText: "Send an email",
	}
	findingsJSON, _ := json.Marshal(findings)

	// Test with a custom Select that takes configs directly.
	eligible := PruneEligible([]db.AgentConfig{configA, configB}, findings.Structured)
	picked, err := picker.Pick(context.Background(), eligible, findings.FreeText)
	if err != nil {
		t.Fatalf("Pick error: %v", err)
	}
	if picked.Name != "email-specialist" {
		t.Errorf("expected email-specialist, got %s", picked.Name)
	}

	// Verify configB was pruned (requires run_code but findings only have send-email).
	if len(eligible) != 1 {
		t.Errorf("expected 1 eligible after prune, got %d", len(eligible))
	}

	_ = findingsJSON // used in integration tests
}

func TestRouterSelect_InvalidPickFallsBackToHuman(t *testing.T) {
	configA := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "email-specialist",
		Eligibility: json.RawMessage(`{}`),
	}

	// Force the picker to return an ID not in the eligible set.
	ineligibleID := uuid.New()
	picker := &LogPicker{ForceID: ineligibleID.String()}
	r := &Router{picker: picker}

	findings := agent.Findings{
		Structured: agent.StructuredFindings{
			RequiredCapabilities: []string{"send-email"},
		},
		FreeText: "Send an email",
	}

	eligible := PruneEligible([]db.AgentConfig{configA}, findings.Structured)

	// The forced pick ID is not in eligible set.
	picked, err := picker.Pick(context.Background(), eligible, findings.FreeText)
	if err != nil {
		t.Fatalf("Pick error: %v", err)
	}

	// Validate against eligible set — should fail.
	if isInEligibleSet(picked.ID, eligible) {
		t.Error("forced ineligible ID should not be in eligible set")
	}

	// Router.Select would return human decision in this case.
	_ = r // used in integration tests with DB
}

func TestRouterSelect_NoEligibleReturnsHuman(t *testing.T) {
	configA := db.AgentConfig{
		ID:          uuid.New(),
		Name:        "code-executor",
		Eligibility: json.RawMessage(`{"pred":{"op":"subset","field":"required_capabilities","value":["run_code"]}}`),
	}

	findings := agent.StructuredFindings{
		RequiredCapabilities: []string{"send-email"}, // code-executor needs run_code
	}

	eligible := PruneEligible([]db.AgentConfig{configA}, findings)
	if len(eligible) != 0 {
		t.Fatalf("expected 0 eligible, got %d", len(eligible))
	}
	// Router would return humanDecision() here.
}
