package router

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// LLMPicker uses the AgentModelClient to pick among eligible specialists.
type LLMPicker struct {
	client agent.AgentModelClient
	model  string
}

// NewLLMPicker creates a picker backed by an LLM.
func NewLLMPicker(client agent.AgentModelClient, model string) *LLMPicker {
	return &LLMPicker{client: client, model: model}
}

// Pick asks the LLM to select one specialist from the eligible set.
func (p *LLMPicker) Pick(ctx context.Context, eligible []db.AgentConfig, freeText string) (*db.AgentConfig, error) {
	if len(eligible) == 1 {
		// Only one option — no LLM call needed.
		return &eligible[0], nil
	}

	// Build the prompt.
	system := "You are a routing assistant. From the eligible specialists below, select the single best fit for " +
		"this task stage based on how well each specialist's described capabilities match what the task needs. " +
		"Prefer a specialist whose focus clearly covers the task; when none is a clear fit, choose the most " +
		"general-purpose option rather than forcing a narrow specialist. Respond with ONLY a JSON object and " +
		"nothing else: {\"config_id\": \"<uuid>\"}, where the uuid is one of the listed specialist ids."

	candidates := make([]map[string]string, 0, len(eligible))
	for _, cfg := range eligible {
		c := map[string]string{
			"id":   cfg.ID.String(),
			"name": cfg.Name,
		}
		if cfg.SystemPrompt != nil {
			// Truncate long prompts for the router.
			prompt := *cfg.SystemPrompt
			if len(prompt) > 200 {
				prompt = prompt[:200] + "..."
			}
			c["description"] = prompt
		}
		candidates = append(candidates, c)
	}
	candidatesJSON, _ := json.Marshal(candidates)

	userMsg := fmt.Sprintf("Task context:\n%s\n\nEligible specialists:\n%s\n\nPick the best specialist. Respond with {\"config_id\": \"<uuid>\"}.",
		freeText, string(candidatesJSON))

	resp, err := p.client.Chat(ctx, agent.ChatRequest{
		Model:  p.model,
		System: system,
		Messages: []agent.Message{
			{Role: "user", Content: userMsg},
		},
		Tools: nil, // no tools for the router
	})
	if err != nil {
		return nil, fmt.Errorf("router LLM call: %w", err)
	}

	// Parse the pick.
	picked, err := parsePick(resp.Content, eligible)
	if err != nil {
		slog.WarnContext(ctx, "router: failed to parse LLM pick", "content", resp.Content, "err", err)
		return nil, err
	}
	return picked, nil
}

func parsePick(content string, eligible []db.AgentConfig) (*db.AgentConfig, error) {
	var pick struct {
		ConfigID string `json:"config_id"`
	}
	if err := json.Unmarshal([]byte(content), &pick); err != nil {
		return nil, fmt.Errorf("parse pick JSON: %w", err)
	}
	if pick.ConfigID == "" {
		return nil, fmt.Errorf("empty config_id in pick")
	}

	id, err := uuid.Parse(pick.ConfigID)
	if err != nil {
		return nil, fmt.Errorf("invalid UUID in pick: %w", err)
	}

	for i := range eligible {
		if eligible[i].ID == id {
			return &eligible[i], nil
		}
	}
	return nil, fmt.Errorf("picked config_id %s not in eligible set", id)
}

// LogPicker is a deterministic picker for tests. It always picks the first
// eligible config, or can be configured to pick by name or return an error.
type LogPicker struct {
	PickByName string // if set, picks the config with this name
	ForceError error  // if set, always returns this error
	ForceID    string // if set, returns this ID (may be ineligible — tests rejection)
}

// Pick returns a deterministic selection for tests.
func (p *LogPicker) Pick(_ context.Context, eligible []db.AgentConfig, _ string) (*db.AgentConfig, error) {
	if p.ForceError != nil {
		return nil, p.ForceError
	}

	if p.ForceID != "" {
		id, err := uuid.Parse(p.ForceID)
		if err != nil {
			return nil, err
		}
		// Return a fake config with that ID (may not be in eligible set — tests validation).
		return &db.AgentConfig{ID: id, Name: "forced"}, nil
	}

	if p.PickByName != "" {
		for i := range eligible {
			if eligible[i].Name == p.PickByName {
				return &eligible[i], nil
			}
		}
	}

	// Default: pick first.
	if len(eligible) > 0 {
		return &eligible[0], nil
	}
	return nil, fmt.Errorf("no eligible configs")
}
