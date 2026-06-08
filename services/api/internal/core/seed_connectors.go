package core

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ExampleWebhookConnectorID is the deterministic id of the seeded example
// connector, so the seed is idempotent across boots and the webhook ingress
// route has a stable path for the demo (POST /intake/webhook/<this id>).
var ExampleWebhookConnectorID = uuid.MustParse("00000000-0000-0000-0000-00000000c001")

// SeedExampleConnector upserts a single enabled webhook-in connector so US1–US3
// can be demoed without the owner mutations (T023). webhook-in is chosen
// because it needs no credentials and no external fetch — its poll drains an
// in-memory queue, so a seeded-enabled connector is a harmless no-op until a
// delivery is pushed to the ingress route. The boot-time RehydrateSchedules
// then creates its DBOS schedule.
//
// Idempotent: re-running upserts the same row and re-enables it.
func SeedExampleConnector(ctx context.Context, q *db.Queries) error {
	schedule := "0 * * * * *" // every minute (6-field cron, seconds-leading)
	rules, _ := json.Marshal(map[string]any{
		"confidence_floor":   0.85,
		"stakes_ceiling":     0.30,
		"llm_judge_per_poll": 5,
	})
	if _, err := q.UpsertConnectorConfig(ctx, db.UpsertConnectorConfigParams{
		ID:               ExampleWebhookConnectorID,
		ConnectorType:    "webhook-in",
		Filter:           json.RawMessage(`{}`),
		Schedule:         &schedule,
		DispositionRules: rules,
	}); err != nil {
		return err
	}
	if _, err := q.SetConnectorEnabled(ctx, db.SetConnectorEnabledParams{
		ID:      ExampleWebhookConnectorID,
		Enabled: true,
	}); err != nil {
		return err
	}
	return nil
}

// ReconcileConnectors reconciles connector_configs from config. When defs is
// empty it falls back to SeedExampleConnector (prior boot behavior). When the
// file defines connectors, each is upserted by its (stable) id and its enabled
// flag set. Non-destructive: connectors the file omits are left untouched.
func ReconcileConnectors(ctx context.Context, q *db.Queries, defs []config.ConnectorDef) error {
	if len(defs) == 0 {
		return SeedExampleConnector(ctx, q)
	}
	for _, d := range defs {
		id, err := uuid.Parse(d.ID)
		if err != nil {
			return fmt.Errorf("connector %q: invalid id: %w", d.ID, err)
		}
		if d.Type == "" {
			return fmt.Errorf("connector %s: missing type", d.ID)
		}
		filter := json.RawMessage(`{}`)
		if d.Filter != nil {
			b, err := json.Marshal(d.Filter)
			if err != nil {
				return fmt.Errorf("connector %s: marshal filter: %w", d.ID, err)
			}
			filter = b
		}
		rules := json.RawMessage(`{}`)
		if d.DispositionRules != nil {
			b, err := json.Marshal(d.DispositionRules)
			if err != nil {
				return fmt.Errorf("connector %s: marshal disposition_rules: %w", d.ID, err)
			}
			rules = b
		}
		var schedule *string
		if d.Schedule != "" {
			s := d.Schedule
			schedule = &s
		}
		if _, err := q.UpsertConnectorConfig(ctx, db.UpsertConnectorConfigParams{
			ID:               id,
			ConnectorType:    d.Type,
			Filter:           filter,
			Schedule:         schedule,
			DispositionRules: rules,
		}); err != nil {
			return fmt.Errorf("connector %s: upsert: %w", d.ID, err)
		}
		if _, err := q.SetConnectorEnabled(ctx, db.SetConnectorEnabledParams{
			ID:      id,
			Enabled: d.Enabled,
		}); err != nil {
			return fmt.Errorf("connector %s: set enabled: %w", d.ID, err)
		}
	}
	return nil
}
