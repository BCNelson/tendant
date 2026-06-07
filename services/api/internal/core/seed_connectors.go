package core

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"

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
