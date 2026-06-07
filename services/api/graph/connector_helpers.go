package graph

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// ConnectorDeps is the owner-mutation wiring for the Phase-7 connector
// resolvers. main supplies the func values (registry membership test +
// schedule create/delete) so the graph package imports neither
// internal/connector nor internal/intake.
type ConnectorDeps struct {
	// HasType reports whether a connector_type is registered (rejects unknown
	// types before any DB write — SC-008).
	HasType func(connectorType string) bool
	// CreateSchedule registers the per-connector DBOS schedule on enable.
	CreateSchedule func(dctx dbos.DBOSContext, connectorID uuid.UUID, cron string) error
	// DeleteSchedule removes the per-connector DBOS schedule on disable.
	DeleteSchedule func(dctx dbos.DBOSContext, connectorID uuid.UUID) error
}

// configured reports whether the connector wiring is present.
func (d ConnectorDeps) configured() bool {
	return d.HasType != nil && d.CreateSchedule != nil && d.DeleteSchedule != nil
}

// mapConnector projects a connector_configs row into the GraphQL model. The
// config map mirrors what setConnectorConfig accepts; credentials never appear.
func mapConnector(row *db.ConnectorConfig) *model.Connector {
	config := map[string]any{
		"connector_type": row.ConnectorType,
		"enabled":        row.Enabled,
	}
	if row.Schedule != nil {
		config["schedule"] = *row.Schedule
	}
	if len(row.Filter) > 0 {
		var f any
		if json.Unmarshal(row.Filter, &f) == nil {
			config["filter"] = f
		}
	}
	if len(row.DispositionRules) > 0 {
		var dr any
		if json.Unmarshal(row.DispositionRules, &dr) == nil {
			config["disposition_rules"] = dr
		}
	}
	return &model.Connector{
		ID:            row.ID.String(),
		ConnectorType: row.ConnectorType,
		Enabled:       row.Enabled,
		Config:        config,
	}
}

// jsonbFromConfig marshals a sub-object of the config map to jsonb, defaulting
// to "{}" when absent.
func jsonbFromConfig(config map[string]any, key string) (json.RawMessage, error) {
	v, ok := config[key]
	if !ok || v == nil {
		return json.RawMessage("{}"), nil
	}
	raw, err := json.Marshal(v)
	if err != nil {
		return nil, err
	}
	return raw, nil
}

// setConnectorConfigImpl upserts the connector_configs row after validating the
// connector_type against the registry.
func (r *mutationResolver) setConnectorConfigImpl(ctx context.Context, id uuid.UUID, config map[string]any) (*model.Connector, error) {
	connectorType, _ := config["connector_type"].(string)
	if connectorType == "" {
		return nil, gqlerror.Errorf("config.connector_type is required")
	}
	if !r.Connectors.HasType(connectorType) {
		return nil, &gqlerror.Error{
			Message:    "unknown connector_type: " + connectorType,
			Extensions: map[string]any{"code": "CONNECTOR_TYPE_UNKNOWN"},
		}
	}
	filter, err := jsonbFromConfig(config, "filter")
	if err != nil {
		return nil, gqlerror.Errorf("invalid filter: %s", err)
	}
	rules, err := jsonbFromConfig(config, "disposition_rules")
	if err != nil {
		return nil, gqlerror.Errorf("invalid disposition_rules: %s", err)
	}
	var schedule *string
	if s, ok := config["schedule"].(string); ok && strings.TrimSpace(s) != "" {
		schedule = &s
	}
	row, err := r.Queries.UpsertConnectorConfig(ctx, db.UpsertConnectorConfigParams{
		ID:               id,
		ConnectorType:    connectorType,
		Filter:           filter,
		Schedule:         schedule,
		DispositionRules: rules,
	})
	if err != nil {
		return nil, err
	}
	return mapConnector(&row), nil
}

// enableConnectorImpl flips the enabled flag and (de)registers the schedule.
func (r *mutationResolver) enableConnectorImpl(ctx context.Context, id uuid.UUID, enabled bool) (*model.Connector, error) {
	row, err := r.Queries.GetConnectorConfig(ctx, id)
	if err != nil {
		return nil, gqlerror.Errorf("connector not found: %s", err)
	}
	if enabled {
		cron := ""
		if row.Schedule != nil {
			cron = *row.Schedule
		}
		if strings.TrimSpace(cron) == "" {
			return nil, gqlerror.Errorf("a valid cron schedule is required to enable a connector")
		}
		if err := r.Connectors.CreateSchedule(r.DBOS, id, cron); err != nil {
			return nil, gqlerror.Errorf("create schedule: %s", err)
		}
	} else {
		if err := r.Connectors.DeleteSchedule(r.DBOS, id); err != nil {
			return nil, gqlerror.Errorf("delete schedule: %s", err)
		}
	}
	updated, err := r.Queries.SetConnectorEnabled(ctx, db.SetConnectorEnabledParams{ID: id, Enabled: enabled})
	if err != nil {
		return nil, err
	}
	return mapConnector(&updated), nil
}
