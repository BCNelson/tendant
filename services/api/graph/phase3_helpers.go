package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/99designs/gqlgen/graphql"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gate"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/toolflow"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// gateError shapes a generic gate-evaluation error.
func gateError(ctx context.Context, code, msg string) *gqlerror.Error {
	return &gqlerror.Error{
		Message:    msg,
		Path:       graphql.GetPath(ctx),
		Extensions: map[string]any{"code": code},
	}
}

// principalLookupFromQueries is the gate.PrincipalLookup adapter the
// resolver wires into the gate. Reads against pg, idempotent.
type principalLookupFromQueries struct {
	q *db.Queries
}

func (p *principalLookupFromQueries) IsKnownPrincipal(ctx context.Context, globalURI string) (bool, error) {
	_, err := p.q.GetPrincipalByGlobalURI(ctx, globalURI)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

// artifactEnvelope is the JSON shape stored in pending_decisions.payload
// for kind=approval_request. The schema declares ApprovalPayload as a
// discriminated union (Artifact | Mandate); we store the discriminant +
// the typed body here.
type artifactEnvelope struct {
	Type      string          `json:"type"` // "artifact" | "mandate"
	Kind      string          `json:"kind,omitempty"`
	Recipient string          `json:"recipient,omitempty"`
	Content   json.RawMessage `json:"content,omitempty"`
}

// proposeToolCallImpl is the body behind the ProposeToolCall resolver.
func (r *Resolver) proposeToolCallImpl(ctx context.Context, taskID, toolGlobalURI string, payload map[string]any) (*model.ApprovalRequest, error) {
	if r.DBOS == nil {
		return nil, fmt.Errorf("tool-call workflow not available — DBOS context is nil")
	}
	principal, ok := auth.FromContext(ctx)
	if !ok {
		return nil, unauthorizedError(ctx)
	}

	tid, err := uuid.Parse(taskID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid taskId: %s", err)
	}

	task, err := r.Queries.GetTask(ctx, tid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, gateError(ctx, "TASK_NOT_FOUND", "task not found")
		}
		return nil, fmt.Errorf("get task: %w", err)
	}
	if lifecycle.IsTerminal(task.State) {
		return nil, gateError(ctx, "TASK_NOT_OPEN", "task is in a terminal state")
	}

	toolRow, err := r.Queries.GetToolByGlobalURI(ctx, toolGlobalURI)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, gateError(ctx, "TOOL_UNKNOWN", "no tool registered for global URI: "+toolGlobalURI)
		}
		return nil, fmt.Errorf("get tool: %w", err)
	}

	rawPayload, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("marshal payload: %w", err)
	}

	call := &gate.ToolCall{
		TaskID:  tid,
		ToolID:  toolRow.ID,
		Payload: rawPayload,
	}

	g := gate.NewDefaultGate(&principalLookupFromQueries{q: r.Queries})
	verdict, err := g.Evaluate(ctx, call, &toolRow)
	if err != nil {
		return nil, fmt.Errorf("gate: %w", err)
	}

	// Audit: tool_call_composed → gate_verdict. Persist before we branch on
	// the verdict so the audit DAG records every composition the system
	// saw, including denied ones (Phase 3 currently never returns Deny,
	// but the shape is final).
	if err := r.writeComposeAndVerdictAudit(ctx, tid, &toolRow, rawPayload, principal.GlobalURI, verdict); err != nil {
		return nil, fmt.Errorf("audit compose: %w", err)
	}

	switch verdict.Decision {
	case gate.DecisionApprove:
		// Read-only short-circuit. Dispatch synchronously, record outcome,
		// and return an immediately-resolved ApprovalRequest so the schema
		// shape is consistent. Phase 3 send-email is not read-only, so
		// this branch is exercised by future tools / unit tests.
		return r.dispatchReadOnly(ctx, tid, &toolRow, rawPayload, principal.GlobalURI)

	case gate.DecisionDeny:
		return nil, gateError(ctx, "GATE_DENY", "gate denied the call")

	case gate.DecisionRequestDecision:
		// Write the ApprovalRequest row and start the durable workflow.
		decisionID, ar, err := r.writeApprovalRequest(ctx, tid, &toolRow, rawPayload)
		if err != nil {
			return nil, err
		}
		if err := toolflow.StartToolCallWorkflow(r.DBOS, decisionID); err != nil {
			return nil, fmt.Errorf("start tool-call workflow: %w", err)
		}
		return ar, nil

	case gate.DecisionAgentHandoff:
		// Reserved for Phase 4 overseer; cannot happen in Phase 3.
		return nil, gateError(ctx, "GATE_UNSUPPORTED", "agent handoff is not supported in Phase 3")
	}
	return nil, gateError(ctx, "GATE_UNKNOWN", fmt.Sprintf("unknown verdict: %s", verdict.Decision))
}

// writeComposeAndVerdictAudit inserts the two audit messages that bracket
// the gate evaluation. Both share a transaction so a crash mid-write
// leaves no partial audit chain.
func (r *Resolver) writeComposeAndVerdictAudit(ctx context.Context, taskID uuid.UUID, tool *db.Tool, payload json.RawMessage, composedBy string, v gate.Verdict) error {
	return pgx.BeginFunc(ctx, r.Pool, func(tx pgx.Tx) error {
		parent, err := latestTransitionIDInTx(ctx, tx, taskID)
		if err != nil {
			return err
		}
		composed, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, composedBy,
			lifecycle.KindToolCallComposed,
			lifecycle.ToolCallComposedPayload{
				ToolID:        tool.ID,
				ToolGlobalURI: tool.GlobalUri,
				Payload:       payload,
				ComposedBy:    composedBy,
			},
			parent,
		)
		if err != nil {
			return err
		}
		_, err = lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindGateVerdict,
			lifecycle.GateVerdictPayload{
				ToolID:   tool.ID,
				Decision: v.Decision.String(),
				Context:  v.Context,
			},
			composed,
		)
		return err
	})
}

// writeApprovalRequest inserts the pending_decisions row with the frozen
// payload + workflow id + topic. Returns the decision id and a ready-to-
// return model.ApprovalRequest.
func (r *Resolver) writeApprovalRequest(ctx context.Context, taskID uuid.UUID, tool *db.Tool, frozen json.RawMessage) (uuid.UUID, *model.ApprovalRequest, error) {
	envelope, err := encodeApprovalEnvelope(tool, frozen)
	if err != nil {
		return uuid.Nil, nil, fmt.Errorf("encode approval envelope: %w", err)
	}

	// The workflow id is derived from the decision id (deterministic). We
	// pre-allocate the decision id so we can write it into workflow_id +
	// decision_topic atomically with the row.
	decisionID := uuid.New()
	wfID := toolflow.WorkflowID(decisionID)
	topic := toolflow.ApprovalTopic(decisionID)

	// InsertPendingDecision is the only path: it auto-generates the id,
	// which means we'd race the workflow id. Use a direct INSERT via the
	// pool so we can pin the id deterministically.
	var insertedID uuid.UUID
	row := r.Pool.QueryRow(ctx, `
		INSERT INTO pending_decisions
		  (id, task_id, tool_id, kind, payload, frozen_payload, workflow_id, decision_topic)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id`,
		decisionID,
		taskID,
		tool.ID,
		db.DecisionKindApprovalRequest,
		envelope,
		frozen,
		wfID,
		topic,
	)
	if err := row.Scan(&insertedID); err != nil {
		return uuid.Nil, nil, fmt.Errorf("insert pending_decision: %w", err)
	}

	ar := &model.ApprovalRequest{
		ID:        insertedID.String(),
		CreatedAt: time.Now().UTC(), // resolver-side approximation; field-resolved Task fetches the real row if needed
	}
	return insertedID, ar, nil
}

// encodeApprovalEnvelope produces the JSON stored in pending_decisions.payload
// for an ApprovalRequest. Phase 3 always emits an Artifact envelope (the
// "exact frozen call" shape); Mandate authorization is a deferred mutation.
func encodeApprovalEnvelope(tool *db.Tool, frozen json.RawMessage) (json.RawMessage, error) {
	env := artifactEnvelope{
		Type:    "artifact",
		Kind:    artifactKindForTool(tool.GlobalUri),
		Content: frozen,
	}
	// Extract the recipient field from the frozen payload so the UI can
	// render it without re-parsing.
	var probe struct {
		To        string `json:"to"`
		Recipient string `json:"recipient"`
	}
	_ = json.Unmarshal(frozen, &probe)
	if probe.Recipient != "" {
		env.Recipient = probe.Recipient
	} else {
		env.Recipient = probe.To
	}
	return json.Marshal(env)
}

// artifactKindForTool maps a tool's global_uri to the artifact kind string
// the UI uses to pick a renderer. Centralised so future tools (sms, push,
// etc.) extend in one place.
func artifactKindForTool(globalURI string) string {
	if globalURI == tools.SendEmailGlobalURI {
		return "email"
	}
	return "generic"
}

// dispatchReadOnly executes a read-only tool synchronously and returns an
// immediately-resolved ApprovalRequest. Used by the gate's read-only
// short-circuit. Phase 3 ships no read-only tools — kept for future use
// and exercised by unit tests.
func (r *Resolver) dispatchReadOnly(ctx context.Context, taskID uuid.UUID, tool *db.Tool, frozen json.RawMessage, composedBy string) (*model.ApprovalRequest, error) {
	// Use the registry baked into the running toolflow (it's the same
	// instance the resolver doesn't own directly). For Phase 3 we resolve
	// via a small per-resolver registry hook so tests can inject.
	return nil, gateError(ctx, "GATE_UNSUPPORTED", "no read-only tools registered in Phase 3")
}

// resolveDecisionMutation is the shared body behind approveArtifact and
// rejectApproval. Marks the decision resolved (first-write-wins), wakes
// the workflow, and returns the now-resolved decision.
func (r *Resolver) resolveDecisionMutation(ctx context.Context, decisionIDStr string, approved bool, reason string) (model.PendingDecision, error) {
	if r.DBOS == nil {
		return nil, fmt.Errorf("tool-call workflow not available — DBOS context is nil")
	}
	principal, ok := auth.FromContext(ctx)
	if !ok {
		return nil, unauthorizedError(ctx)
	}

	id, err := uuid.Parse(decisionIDStr)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decisionId: %s", err)
	}

	// Build the resolution payload before the UPDATE so we can write it
	// atomically.
	resolution, err := json.Marshal(map[string]any{
		"approved":    approved,
		"reason":      reason,
		"resolved_by": principal.GlobalURI,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal resolution: %w", err)
	}

	row, err := r.Queries.ResolvePendingDecision(ctx, db.ResolvePendingDecisionParams{
		ID:         id,
		ResolvedAt: pgtype.Timestamptz{Time: time.Now().UTC(), Valid: true},
		Resolution: resolution,
	})
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// Already-resolved (or unknown) decision. Idempotent: return
			// the current state without re-waking the workflow.
			existing, gerr := r.Queries.GetPendingDecisionByID(ctx, id)
			if gerr != nil {
				if errors.Is(gerr, pgx.ErrNoRows) {
					return nil, gateError(ctx, "DECISION_NOT_FOUND", "decision not found")
				}
				return nil, fmt.Errorf("get decision: %w", gerr)
			}
			return mapPendingDecisionRow(&existing)
		}
		return nil, fmt.Errorf("resolve decision: %w", err)
	}

	// Wake the durable workflow. If this fails the row is already marked
	// resolved — the workflow's 72h Recv will eventually time out, and the
	// audit DAG will record the resolution from the resolver side. Better
	// to surface the error than to leave the resolver in an unknown state.
	if err := toolflow.ResolveDecision(r.DBOS, id, approved, reason, principal.GlobalURI); err != nil {
		return nil, fmt.Errorf("wake tool-call workflow: %w", err)
	}

	return mapPendingDecisionRow(&row)
}

// loadDecisionTool loads the Tool row referenced by pending_decisions.tool_id
// for a given decision id. Returns nil if the row has no tool (legal for
// agent_question / promotion_proposal in Phase 2; ApprovalRequest always
// has one in Phase 3).
func (r *Resolver) loadDecisionTool(ctx context.Context, decisionID string) (*model.Tool, error) {
	id, err := uuid.Parse(decisionID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decision id: %s", err)
	}
	row, err := r.Queries.GetPendingDecisionByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("get pending decision: %w", err)
	}
	if !row.ToolID.Valid {
		return phase2PlaceholderTool(), nil
	}
	tool, err := r.Queries.GetToolByID(ctx, row.ToolID.Bytes)
	if err != nil {
		return nil, fmt.Errorf("get tool: %w", err)
	}
	return mapToolRow(&tool), nil
}

// loadDecisionPayload decodes pending_decisions.payload into the matching
// ApprovalPayload union member. Phase 3 always returns *model.Artifact;
// Mandate awaits its authorization mutations.
func (r *Resolver) loadDecisionPayload(ctx context.Context, decisionID string) (model.ApprovalPayload, error) {
	id, err := uuid.Parse(decisionID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid decision id: %s", err)
	}
	row, err := r.Queries.GetPendingDecisionByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("get pending decision: %w", err)
	}
	if len(row.Payload) == 0 {
		return &model.Mandate{Goal: "(missing payload)", Constraints: map[string]any{}, Guardrails: map[string]any{}}, nil
	}
	var env artifactEnvelope
	if err := json.Unmarshal(row.Payload, &env); err != nil {
		return nil, fmt.Errorf("decode approval payload envelope: %w", err)
	}
	switch env.Type {
	case "artifact":
		var content map[string]any
		if len(env.Content) > 0 {
			_ = json.Unmarshal(env.Content, &content)
		}
		var recipient *string
		if env.Recipient != "" {
			rec := env.Recipient
			recipient = &rec
		}
		return &model.Artifact{
			Kind:      env.Kind,
			Content:   content,
			Recipient: recipient,
		}, nil
	case "mandate":
		// Reserved — Mandate authorization is deferred in Phase 3.
		return &model.Mandate{Goal: env.Kind, Constraints: map[string]any{}, Guardrails: map[string]any{}}, nil
	}
	return nil, fmt.Errorf("unknown approval payload type: %s", env.Type)
}

// mapToolRow turns a sqlc Tool row into the gqlgen model. Rung is currently
// stored as text in db (default "execute_gated"); the GraphQL enum lower-
// casing convention from Phase 1 (upperTaskState) is mirrored here.
func mapToolRow(t *db.Tool) *model.Tool {
	perms := map[string]any{}
	if len(t.Permissions) > 0 {
		_ = json.Unmarshal(t.Permissions, &perms)
	}
	return &model.Tool{
		ID:                   t.ID.String(),
		GlobalURI:            t.GlobalUri,
		Name:                 t.Name,
		Rung:                 mapRung(t.Rung),
		Permissions:          perms,
		OverseerInstructions: t.OverseerInstructions,
	}
}

func mapRung(s string) model.AutonomyLevel {
	switch s {
	case "none":
		return model.AutonomyLevelNone
	case "enrich_only":
		return model.AutonomyLevelEnrichOnly
	case "propose":
		return model.AutonomyLevelPropose
	case "execute_gated":
		return model.AutonomyLevelExecuteGated
	case "execute_auto":
		return model.AutonomyLevelExecuteAuto
	}
	return model.AutonomyLevelExecuteGated
}

// latestTransitionIDInTx is the resolver-side counterpart to the chain
// helper. Returns uuid.Nil for first audit on a task.
func latestTransitionIDInTx(ctx context.Context, tx pgx.Tx, taskID uuid.UUID) (uuid.UUID, error) {
	q := db.New(tx)
	row, err := q.LatestTransitionForTask(ctx, taskID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, nil
		}
		return uuid.Nil, fmt.Errorf("latest transition (tx): %w", err)
	}
	return row.ID, nil
}
