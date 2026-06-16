package graph

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
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
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gate"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
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

// grantLookupFromQueries is the gate.RoutineGrantLookup adapter backing the
// Phase-8 autonomy layer with LiveGrantExists. Read-only, idempotent.
type grantLookupFromQueries struct {
	q *db.Queries
}

func (g *grantLookupFromQueries) HasLiveGrant(ctx context.Context, toolID uuid.UUID, fingerprint string) (bool, error) {
	return g.q.LiveGrantExists(ctx, db.LiveGrantExistsParams{ToolID: toolID, RoutineFingerprint: fingerprint})
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
	// An MCP-backed tool whose upstream definition has vanished (or whose server
	// was removed) is retired: its adapter is deregistered, so a dispatch would
	// fail. Reject composition up front rather than gating a call we can't run.
	if toolRow.RetiredAt.Valid {
		return nil, gateError(ctx, "TOOL_RETIRED", "tool is retired (its MCP server is gone or no longer advertises it): "+toolGlobalURI)
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

	// Phase 4/5: construct the gate with the resolver's wired overseer (nil
	// in Phase 3 tests) and the Layer-3 script evaluator (nil when no script
	// layer is wired). Order is fixed: read-only → floor → script → overseer.
	g := gate.NewDefaultGateWithOverseer(&principalLookupFromQueries{q: r.Queries}, r.Overseer)
	g.Script = r.ScriptEvaluator
	// Phase 8: back the autonomy layer's grant lookup with LiveGrantExists. The
	// gate stays pure (no direct DB) — this is the injected seam.
	g.Grants = &grantLookupFromQueries{q: r.Queries}
	verdict, err := g.Evaluate(ctx, call, &toolRow)
	if err != nil {
		return nil, fmt.Errorf("gate: %w", err)
	}

	// Pre-allocate a decision id so the auto-approve and request-decision
	// branches can write a consistent decision_id into the overseer_evaluated
	// audit payload. The Approve branch reuses it for the synthetic
	// pending_decisions row that drives the existing ToolCallWorkflow.
	decisionID := uuid.New()

	// Audit: tool_call_composed → gate_verdict [→ overseer_evaluated].
	// Persist before we branch on the verdict so the audit DAG records every
	// composition the system saw, including denied ones (Phase 4 still
	// never returns Deny, but the shape is final).
	if err := r.writeComposeVerdictOverseerAudit(ctx, tid, &toolRow, rawPayload, principal.GlobalURI, verdict, decisionID); err != nil {
		return nil, fmt.Errorf("audit compose: %w", err)
	}

	switch verdict.Decision {
	case gate.DecisionApprove:
		// Four distinct Approve sources:
		//   (a) read-only short-circuit (perms.read_only=true): Phase 3
		//       fall-through; no overseer/script verdict carried.
		//   (b) overseer-approve: Phase 4 auto-approve path.
		//   (c) script-approve: Phase 5 — a gate script returned Approve and
		//       the floor stayed silent.
		//   (d) autonomy-approve: Phase 8 — the tool is EXECUTE_AUTO and the
		//       routine has a live grant (the floor cleared).
		// (b)/(c)/(d) all auto-dispatch so the clean outcome + audit land via
		// the existing workflow; only the read-only short-circuit is special.
		if isReadOnlyApprove(verdict) {
			return r.dispatchReadOnly(ctx, tid, &toolRow, rawPayload, principal.GlobalURI)
		}
		ar, err := r.writeAutoApprovedAndDispatch(ctx, tid, &toolRow, rawPayload, principal.GlobalURI, decisionID, autoApproveReason(verdict))
		if err != nil {
			return nil, err
		}
		return ar, nil

	case gate.DecisionDeny:
		// Phase 5: a gate script's terminal Deny. Record a denied_by_script
		// tool_outcome + audit (overseer never consulted), then surface the
		// deny as a GraphQL error (a denied call produces no ApprovalRequest).
		if verdict.ScriptVerdict != nil {
			if derr := r.writeDeniedByScript(ctx, tid, &toolRow); derr != nil {
				return nil, fmt.Errorf("record denied_by_script: %w", derr)
			}
		}
		return nil, gateError(ctx, "GATE_DENY", "gate script denied the call")

	case gate.DecisionRequestDecision:
		// Write the ApprovalRequest row (with pre-allocated decision_id) and
		// start the durable workflow.
		ar, err := r.writeApprovalRequestWithID(ctx, tid, &toolRow, rawPayload, decisionID)
		if err != nil {
			return nil, err
		}
		if err := toolflow.StartToolCallWorkflow(r.DBOS, decisionID); err != nil {
			return nil, fmt.Errorf("start tool-call workflow: %w", err)
		}
		return ar, nil

	case gate.DecisionAgentHandoff:
		// Reserved for Phase 6 sub-agents.
		return nil, gateError(ctx, "GATE_UNSUPPORTED", "agent handoff is not supported in Phase 4")
	}
	return nil, gateError(ctx, "GATE_UNKNOWN", fmt.Sprintf("unknown verdict: %s", verdict.Decision))
}

// writeComposeVerdictOverseerAudit inserts the audit messages bracketing
// the gate evaluation: tool_call_composed → gate_verdict, plus (when the
// overseer was consulted) overseer_evaluated chained to gate_verdict. All
// in one transaction so a crash mid-write leaves no partial audit chain.
//
// decisionID, when non-Nil, is recorded in the overseer_evaluated payload's
// evidence.decision_id so ApprovalRequest.overseerEvaluation can locate
// the row. The Approve path passes the pre-allocated id too — Phase 8
// calibration treats auto-approves and human-approves symmetrically.
func (r *Resolver) writeComposeVerdictOverseerAudit(ctx context.Context, taskID uuid.UUID, tool *db.Tool, payload json.RawMessage, composedBy string, v gate.Verdict, decisionID uuid.UUID) error {
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
		gateVerdictID, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindGateVerdict,
			lifecycle.GateVerdictPayload{
				ToolID:   tool.ID,
				Decision: v.Decision.String(),
				Context:  v.Context,
			},
			composed,
		)
		if err != nil {
			return err
		}

		// Phase 5: gate_script_evaluated, chained to gate_verdict, when a script
		// ran (FR-035). The overseer row (if any) then chains to THIS row so the
		// DAG reflects script → overseer hand-off.
		chainParent := gateVerdictID
		if v.ScriptVerdict != nil {
			scriptPayload := gatescript.AuditPayload(*v.ScriptVerdict)
			// Stamp the pre-allocated decision id so
			// ApprovalRequest.gateScriptEvaluation can locate this row when the
			// script's RequestDecision raised an approval.
			scriptPayload["decision_id"] = decisionID.String()
			scriptID, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
				lifecycle.KindGateScriptEvaluated,
				scriptPayload,
				gateVerdictID,
			)
			if err != nil {
				return err
			}
			chainParent = scriptID
		}

		// Phase 4: overseer_evaluated, chained to gate_script_evaluated (or
		// gate_verdict when no script ran), only when the overseer was actually
		// consulted (non-nil verdict).
		if v.OverseerVerdict != nil {
			ownerHash := hashOwnerInstructions(tool.OverseerInstructions)
			payloadMap := overseer.AuditPayload(v.OverseerVerdict, decisionID, ownerHash)
			if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
				lifecycle.KindOverseerEvaluated, payloadMap, chainParent); err != nil {
				return err
			}
		}
		return nil
	})
}

// hashOwnerInstructions returns the sha256-hex of the owner-authored
// instructions string at gate-entry time. Used in audit so a later
// calibration job can detect when instructions changed without
// duplicating the text across tables.
func hashOwnerInstructions(p *string) string {
	if p == nil {
		return ""
	}
	sum := sha256.Sum256([]byte(*p))
	return hex.EncodeToString(sum[:])
}

// isReadOnlyApprove reports whether an Approve verdict came from the read-only
// short-circuit (the only Approve that must NOT auto-dispatch a side-effecting
// call — it has no real effect). Discriminated by the gate's context layer.
func isReadOnlyApprove(v gate.Verdict) bool {
	if v.OverseerVerdict != nil || v.ScriptVerdict != nil {
		return false
	}
	var c struct {
		Layer string `json:"layer"`
	}
	_ = json.Unmarshal(v.Context, &c)
	return c.Layer == "read_only_short_circuit"
}

// autoApproveReason maps an Approve verdict to the resolution reason recorded in
// the audit DAG, distinguishing the auto-approve sources.
func autoApproveReason(v gate.Verdict) string {
	switch {
	case v.OverseerVerdict != nil:
		return "overseer-approved"
	case v.ScriptVerdict != nil:
		return "script-approved"
	default:
		var c struct {
			Layer string `json:"layer"`
		}
		_ = json.Unmarshal(v.Context, &c)
		if c.Layer == "autonomy" {
			return "autonomy-approved"
		}
		return "auto-approved"
	}
}

// writeApprovalRequestWithID inserts the pending_decisions row with the
// frozen payload + workflow id + topic at a CALLER-supplied id (Phase 4
// pre-allocates the id so the overseer_evaluated audit can reference it).
// Returns a ready-to-return model.ApprovalRequest.
func (r *Resolver) writeApprovalRequestWithID(ctx context.Context, taskID uuid.UUID, tool *db.Tool, frozen json.RawMessage, decisionID uuid.UUID) (*model.ApprovalRequest, error) {
	envelope, err := encodeApprovalEnvelope(tool, frozen)
	if err != nil {
		return nil, fmt.Errorf("encode approval envelope: %w", err)
	}

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
		return nil, fmt.Errorf("insert pending_decision: %w", err)
	}

	ar := &model.ApprovalRequest{
		ID:        insertedID.String(),
		CreatedAt: time.Now().UTC(), // resolver-side approximation; field-resolved Task fetches the real row if needed
	}
	return ar, nil
}

// writeAutoApprovedAndDispatch is the overseer-Approve path. Writes the
// pending_decisions row with a system-authored resolution populated up
// front (so it never shows in the inbox), starts the tool-call workflow
// with the pre-allocated decision_id, and immediately Sends a synthetic
// approval to wake it. The existing toolflow.ToolCallWorkflow handles
// dispatch + outcome audit; resolved_by=system distinguishes auto-approve
// from human-approve in the audit DAG.
func (r *Resolver) writeAutoApprovedAndDispatch(ctx context.Context, taskID uuid.UUID, tool *db.Tool, frozen json.RawMessage, composedBy string, decisionID uuid.UUID, reason string) (*model.ApprovalRequest, error) {
	envelope, err := encodeApprovalEnvelope(tool, frozen)
	if err != nil {
		return nil, fmt.Errorf("encode approval envelope: %w", err)
	}

	wfID := toolflow.WorkflowID(decisionID)
	topic := toolflow.ApprovalTopic(decisionID)

	resolution, err := json.Marshal(map[string]any{
		"approved":    true,
		"reason":      reason,
		"resolved_by": lifecycle.SystemActorURI,
	})
	if err != nil {
		return nil, fmt.Errorf("marshal auto-resolution: %w", err)
	}

	var insertedID uuid.UUID
	row := r.Pool.QueryRow(ctx, `
		INSERT INTO pending_decisions
		  (id, task_id, tool_id, kind, payload, frozen_payload, workflow_id, decision_topic,
		   resolved_at, resolution)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now(), $9)
		RETURNING id`,
		decisionID, taskID, tool.ID, db.DecisionKindApprovalRequest,
		envelope, frozen, wfID, topic, resolution,
	)
	if err := row.Scan(&insertedID); err != nil {
		return nil, fmt.Errorf("insert auto-approved pending_decision: %w", err)
	}

	// Start the workflow and immediately Send the synthetic approval.
	// DBOS persists the Send until a Recv matches, so the workflow's Recv
	// (started below) will wake regardless of ordering.
	if err := toolflow.StartToolCallWorkflow(r.DBOS, decisionID); err != nil {
		return nil, fmt.Errorf("start auto-approve workflow: %w", err)
	}
	if err := toolflow.ResolveDecision(r.DBOS, decisionID, true, reason, lifecycle.SystemActorURI); err != nil {
		return nil, fmt.Errorf("send synthetic approval: %w", err)
	}

	_ = composedBy // composed-by is recorded by writeComposeVerdictOverseerAudit already
	return &model.ApprovalRequest{
		ID:        insertedID.String(),
		CreatedAt: time.Now().UTC(),
	}, nil
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

// writeDeniedByScript records a gate script's terminal Deny: a
// tool_outcomes(denied_by_script) row + a tool_outcome_recorded audit message.
// No dispatch, no ApprovalRequest. The gate_script_evaluated row was already
// written by writeComposeVerdictOverseerAudit.
func (r *Resolver) writeDeniedByScript(ctx context.Context, taskID uuid.UUID, tool *db.Tool) error {
	return pgx.BeginFunc(ctx, r.Pool, func(tx pgx.Tx) error {
		q := db.New(tx)
		parent, err := latestTransitionIDInTx(ctx, tx, taskID)
		if err != nil {
			return err
		}
		// denied_by_script never matures and never counts toward promotion:
		// matured_at + routine_fingerprint stay NULL.
		outcome, err := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
			ToolID:  tool.ID,
			TaskID:  taskID,
			Outcome: db.ToolOutcomeKindDeniedByScript,
		})
		if err != nil {
			return fmt.Errorf("insert denied_by_script outcome: %w", err)
		}
		_, err = lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI,
			lifecycle.KindToolOutcomeRecorded,
			lifecycle.ToolOutcomeRecordedPayload{
				ToolID:    tool.ID,
				OutcomeID: outcome.ID,
				Outcome:   string(db.ToolOutcomeKindDeniedByScript),
			},
			parent,
		)
		return err
	})
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
		ID:        t.ID.String(),
		GlobalURI: t.GlobalUri,
		Name:      t.Name,
		// Phase 8: rung is DERIVED from the continuous trust_score band, not read
		// from the (now cache-only) rung text column.
		Rung:                 mapRung(string(calibration.Band(t.TrustScore))),
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
