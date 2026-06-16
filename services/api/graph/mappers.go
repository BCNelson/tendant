package graph

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// TaskAlreadyTerminalCode is the GraphQL error code returned by completeTask
// / cancelTask when the task is already in a terminal state (Phase 1 Q5).
const TaskAlreadyTerminalCode = "TASK_ALREADY_TERMINAL"

// defaultPageSize is the page size used when the client omits `first` on
// `tasks(...)`. Lives here so gqlgen regen of *.resolvers.go doesn't quarantine it.
const defaultPageSize = 50

// mapUser builds the GraphQL viewer User from a sqlc Principal row.
func mapUser(p *db.Principal) *model.User {
	return &model.User{
		ID:          p.ID.String(),
		GlobalURI:   p.GlobalUri,
		DisplayName: p.DisplayName,
	}
}

// mapTask builds the GraphQL Task from a sqlc Task row.
func mapTask(t *db.Task) (*model.Task, error) {
	return mapTaskWithAutonomy(t, model.AutonomyLevelNone)
}

// mapTaskWithAutonomy builds the GraphQL Task with a pre-computed autonomy level.
func mapTaskWithAutonomy(t *db.Task, autonomy model.AutonomyLevel) (*model.Task, error) {
	out := &model.Task{
		ID:           t.ID.String(),
		GlobalURI:    t.GlobalUri,
		ShortID:      int(t.ShortID),
		Title:        t.Title,
		Description:  t.Description,
		State:        upperTaskState(t.State),
		CurrentStage: upperChainStage(t.CurrentStage),
		Autonomy:     autonomy,
		Priority:     upperTaskPriority(t.Priority),
		CreatedAt:    t.CreatedAt,
		Workflow:     nil,
	}
	if t.EditedAt.Valid {
		ts := t.EditedAt.Time
		out.EditedAt = &ts
	}
	if t.DueAt.Valid {
		ts := t.DueAt.Time
		out.DueAt = &ts
	}
	if err := unmarshalJSON(t.Provenance, &out.Provenance); err != nil {
		return nil, fmt.Errorf("provenance: %w", err)
	}
	if err := unmarshalJSON(t.ContextRefs, &out.ContextRefs); err != nil {
		return nil, fmt.Errorf("context_refs: %w", err)
	}
	if err := unmarshalJSON(t.Findings, &out.Findings); err != nil {
		return nil, fmt.Errorf("findings: %w", err)
	}
	return out, nil
}

func unmarshalJSON(raw []byte, dst *map[string]any) error {
	if len(raw) == 0 {
		return nil
	}
	return json.Unmarshal(raw, dst)
}

// mapAgentConfigSummary builds the GraphQL AgentConfigSummary from a sqlc row.
func mapAgentConfigSummary(cfg db.AgentConfig) *model.AgentConfigSummary {
	out := &model.AgentConfigSummary{
		ID:      cfg.ID.String(),
		Name:    cfg.Name,
		Stage:   model.AgentStage(strings.ToUpper(string(cfg.Stage))),
		IsHuman: cfg.IsHuman,
		Origin:  string(cfg.Origin),
		Version: int(cfg.Version),
	}
	if cfg.Model != nil {
		out.Model = cfg.Model
	}
	return out
}

// mapAssignment builds the GraphQL AgentAssignment from a sqlc row. `task`
// and `fromAgent` are lazy field resolvers, so this skips them.
func mapAssignment(a *db.AgentAssignment) (*model.AgentAssignment, error) {
	out := &model.AgentAssignment{
		ID:        a.ID.String(),
		Stage:     upperChainStage(a.Stage),
		Ask:       a.Ask,
		CreatedAt: a.CreatedAt,
	}
	if a.ResolvedAt.Valid {
		ts := a.ResolvedAt.Time
		out.ResolvedAt = &ts
	}
	if err := unmarshalJSON(a.GatheredContext, &out.GatheredContext); err != nil {
		return nil, fmt.Errorf("gathered_context: %w", err)
	}
	return out, nil
}

// DB enums are lowercase; GraphQL enums are uppercase. The conversions below
// rely on a 1:1 name mapping (see data-model.md §State/stage values).

func upperTaskState(s db.TaskState) model.TaskState {
	return model.TaskState(strings.ToUpper(string(s)))
}

func upperChainStage(s db.ChainStage) model.ChainStage {
	return model.ChainStage(strings.ToUpper(string(s)))
}

func upperTaskPriority(p db.TaskPriority) model.TaskPriority {
	return model.TaskPriority(strings.ToUpper(string(p)))
}

// lowerTaskPriority maps a GraphQL TaskPriority (uppercase) to the db enum
// (lowercase). nil → 'normal' (the create-screen default).
func lowerTaskPriority(p *model.TaskPriority) db.TaskPriority {
	if p == nil {
		return db.TaskPriorityNormal
	}
	return db.TaskPriority(strings.ToLower(string(*p)))
}

func lowerTaskStateFilter(s *model.TaskState) *db.TaskState {
	if s == nil {
		return nil
	}
	v := db.TaskState(strings.ToLower(string(*s)))
	return &v
}

// Cursor format: base64("<RFC3339Nano createdAt>|<uuid>"). Pagination is keyset
// over (created_at DESC, id DESC).

func encodeCursor(createdAt time.Time, id uuid.UUID) string {
	raw := createdAt.UTC().Format(time.RFC3339Nano) + "|" + id.String()
	return base64.StdEncoding.EncodeToString([]byte(raw))
}

func decodeCursor(s string) (time.Time, uuid.UUID, error) {
	raw, err := base64.StdEncoding.DecodeString(s)
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("decode cursor: %w", err)
	}
	parts := strings.SplitN(string(raw), "|", 2)
	if len(parts) != 2 {
		return time.Time{}, uuid.Nil, fmt.Errorf("malformed cursor")
	}
	ts, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("cursor timestamp: %w", err)
	}
	id, err := uuid.Parse(parts[1])
	if err != nil {
		return time.Time{}, uuid.Nil, fmt.Errorf("cursor id: %w", err)
	}
	return ts, id, nil
}
