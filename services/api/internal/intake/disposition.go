package intake

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
)

// Conservative defaults (NFR-003): an untuned connector holds ambiguous
// rich_events for sign-off — a high confidence floor and a low stakes ceiling
// mean "auto-accept only when very sure AND low-stakes".
const (
	DefaultConfidenceFloor = 0.85
	DefaultStakesCeiling   = 0.30
	DefaultLLMJudgePerPoll = 5
)

// DispositionRules is the core-interpreted dial parsed from a connector's
// disposition_rules jsonb. force_rules/judge_rules are connector-interpreted
// and not modeled here.
type DispositionRules struct {
	ConfidenceFloor float64 `json:"confidence_floor"`
	StakesCeiling   float64 `json:"stakes_ceiling"`
	LLMJudgePerPoll int     `json:"llm_judge_per_poll"`
}

// ParseDispositionRules reads the dial from jsonb, applying conservative
// defaults for any absent/zero field.
func ParseDispositionRules(raw json.RawMessage) DispositionRules {
	r := DispositionRules{
		ConfidenceFloor: DefaultConfidenceFloor,
		StakesCeiling:   DefaultStakesCeiling,
		LLMJudgePerPoll: DefaultLLMJudgePerPoll,
	}
	if len(raw) == 0 {
		return r
	}
	var parsed DispositionRules
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return r // malformed rules ⇒ conservative defaults (fail-closed)
	}
	if parsed.ConfidenceFloor > 0 {
		r.ConfidenceFloor = parsed.ConfidenceFloor
	}
	if parsed.StakesCeiling > 0 {
		r.StakesCeiling = parsed.StakesCeiling
	}
	if parsed.LLMJudgePerPoll > 0 {
		r.LLMJudgePerPoll = parsed.LLMJudgePerPoll
	}
	return r
}

// Outcome values recorded on the disposition_applied audit.
const (
	OutcomeForced     = "forced"
	OutcomeAutoAccept = "auto_accept"
	OutcomeProposed   = "proposed"
)

// DisposeResult reports what the router did with one signal.
type DisposeResult struct {
	TaskID       uuid.UUID
	Outcome      string // OutcomeForced | OutcomeAutoAccept | OutcomeProposed
	ModelInvoked bool   // llm_judge that actually called the triage model
	Surfaced     bool   // false when llm_judge is-task=false (no task surfaced)
}

// CapCounter bounds llm_judge model fan-out within one poll (FR-014a / D6).
type CapCounter struct {
	limit     int
	forwarded int
}

// NewCapCounter constructs a counter with the given per-poll limit.
func NewCapCounter(limit int) *CapCounter {
	if limit <= 0 {
		limit = DefaultLLMJudgePerPoll
	}
	return &CapCounter{limit: limit}
}

// take reports whether another llm_judge model call is within budget, and if
// so consumes one slot.
func (c *CapCounter) take() bool {
	if c.forwarded >= c.limit {
		return false
	}
	c.forwarded++
	return true
}

func (c *CapCounter) count() int { return c.forwarded }
func (c *CapCounter) cap() int   { return c.limit }

// Disposer routes a persisted signal to a task (or holds it PROPOSED) per its
// disposition — the privacy/cost firewall. It owns no per-poll state; the
// CapCounter is threaded by the poll loop.
type Disposer struct {
	Pool    *pgxpool.Pool
	DBOS    dbos.DBOSContext
	Queries *db.Queries
	// Triage is the llm_judge model seam. Nil ⇒ llm_judge fails closed to
	// PROPOSED with no model call (the secure default).
	Triage TriageJudge
	// Metrics is the rolling-window observability counter (nil ⇒ no-op).
	Metrics *Metrics
}

// Dispose handles one persisted signal. connectorType labels the connector
// principal in audits. rules is the parsed dial; capState bounds llm_judge fan
// -out across the poll.
//
// Idempotency (crash-safety): if a task already exists for this signal (a crash
// landed the task but not the processed mark), Dispose marks it processed and
// returns without creating a duplicate.
func (d *Disposer) Dispose(ctx context.Context, sig db.IntakeSignal, connectorType string, rules DispositionRules, capState *CapCounter) (DisposeResult, error) {
	if existing, err := d.Queries.GetTaskByIntakeSignal(ctx, pgtype.UUID{Bytes: sig.ID, Valid: true}); err == nil {
		if perr := d.markProcessed(ctx, sig.ID); perr != nil {
			return DisposeResult{}, perr
		}
		return DisposeResult{TaskID: existing.ID, Outcome: OutcomeProposed, Surfaced: true}, nil
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return DisposeResult{}, fmt.Errorf("check existing task for signal: %w", err)
	}
	switch sig.Disposition {
	case db.SignalDispositionForcedTask:
		return d.forcedTask(ctx, sig, connectorType)
	case db.SignalDispositionRichEvent:
		return d.richEvent(ctx, sig, connectorType, rules)
	case db.SignalDispositionLlmJudge:
		return d.llmJudge(ctx, sig, connectorType, rules, capState)
	default:
		// Unknown disposition ⇒ fail-closed to PROPOSED (defensive; the enum
		// and signal.Validate already reject unknown strings upstream).
		return d.holdProposed(ctx, sig, connectorType)
	}
}

// connectorPrincipal returns the audit from_principal for this signal.
func connectorPrincipal(sig db.IntakeSignal, connectorType string) string {
	var cid uuid.UUID
	if sig.ConnectorID.Valid {
		cid = sig.ConnectorID.Bytes
	}
	return ConnectorPrincipalURI(connectorType, cid)
}

// writeTaskAudit writes one task-scoped audit row in its own tx and marks the
// signal processed in the same tx (so disposition is atomic with its record).
func (d *Disposer) writeTaskAudit(ctx context.Context, signalID, taskID uuid.UUID, from, kind string, payload any) error {
	tx, err := d.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin audit tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, from, kind, payload, uuid.Nil); err != nil {
		return fmt.Errorf("audit %s: %w", kind, err)
	}
	if err := db.New(tx).MarkSignalProcessed(ctx, signalID); err != nil {
		return fmt.Errorf("mark signal processed: %w", err)
	}
	return tx.Commit(ctx)
}

// forcedTask (US1): "this IS a task." Create an accepted task directly, skip
// the is-task judgment, attach the chain. No model.
func (d *Disposer) forcedTask(ctx context.Context, sig db.IntakeSignal, connectorType string) (DisposeResult, error) {
	from := connectorPrincipal(sig, connectorType)
	created, err := core.CreateTaskFromSignal(ctx, d.Pool, d.DBOS, sig.ID,
		deriveTitle(sig.Payload, sig.Provenance), sig.Provenance, lifecycle.StateAccepted)
	if err != nil {
		return DisposeResult{}, fmt.Errorf("forced_task create: %w", err)
	}
	if err := d.writeTaskAudit(ctx, sig.ID, created.ID, from, lifecycle.KindDispositionApplied,
		lifecycle.DispositionAppliedPayload{
			Disposition: string(db.SignalDispositionForcedTask),
			Outcome:     OutcomeForced,
			SignalID:    sig.ID.String(),
		}); err != nil {
		return DisposeResult{}, err
	}
	return DisposeResult{TaskID: created.ID, Outcome: OutcomeForced, Surfaced: true}, nil
}

// richEvent (US2): apply the dial. Auto-accept iff confidence ≥ floor AND
// stakes ≤ ceiling (both present and in range); else hold PROPOSED. A
// missing/out-of-range axis fails closed to PROPOSED (FR-015 / NFR-003).
func (d *Disposer) richEvent(ctx context.Context, sig db.IntakeSignal, connectorType string, rules DispositionRules) (DisposeResult, error) {
	from := connectorPrincipal(sig, connectorType)
	conf, stakes, ok := validRichAxes(sig)
	if ok && conf >= rules.ConfidenceFloor && stakes <= rules.StakesCeiling {
		// Auto-accept ⇒ enrich-only task (derived posture; D5). accepted + chain.
		created, err := core.CreateTaskFromSignal(ctx, d.Pool, d.DBOS, sig.ID,
			deriveTitle(sig.Payload, sig.Provenance), sig.Provenance, lifecycle.StateAccepted)
		if err != nil {
			return DisposeResult{}, fmt.Errorf("rich_event auto-accept create: %w", err)
		}
		// intake_auto_accepted (task-scope) records the cleared thresholds.
		if err := d.writeTaskAuditNoMark(ctx, created.ID, from, lifecycle.KindIntakeAutoAccepted,
			lifecycle.IntakeAutoAcceptedPayload{
				Confidence:      conf,
				StakesHint:      stakes,
				ConfidenceFloor: rules.ConfidenceFloor,
				StakesCeiling:   rules.StakesCeiling,
			}); err != nil {
			return DisposeResult{}, err
		}
		if err := d.writeTaskAudit(ctx, sig.ID, created.ID, from, lifecycle.KindDispositionApplied,
			lifecycle.DispositionAppliedPayload{
				Disposition: string(db.SignalDispositionRichEvent),
				Outcome:     OutcomeAutoAccept,
				SignalID:    sig.ID.String(),
			}); err != nil {
			return DisposeResult{}, err
		}
		return DisposeResult{TaskID: created.ID, Outcome: OutcomeAutoAccept, Surfaced: true}, nil
	}
	// Fail either axis (or missing/out-of-range) ⇒ hold PROPOSED.
	return d.holdProposed(ctx, sig, connectorType)
}

// llmJudge (US3): subject to the per-poll cap. Within cap, create a PROPOSED
// task and hand the normalized payload to the triage model (is-task/shape).
// Over cap, hold PROPOSED with no model call (llm_judge_capped). is-task=false
// ⇒ mark processed, no surfaced task (audited).
func (d *Disposer) llmJudge(ctx context.Context, sig db.IntakeSignal, connectorType string, rules DispositionRules, capState *CapCounter) (DisposeResult, error) {
	from := connectorPrincipal(sig, connectorType)
	if capState == nil {
		capState = NewCapCounter(rules.LLMJudgePerPoll)
	}
	if d.Triage == nil || !capState.take() {
		// Over cap or no model wired ⇒ PROPOSED, NO model call.
		if d.Triage != nil {
			// Cap exceeded: record the pre-task cap event (connector-scoped).
			if err := d.writeConnectorAudit(ctx, sig, connectorType, lifecycle.KindLLMJudgeCapped,
				lifecycle.LLMJudgeCappedPayload{
					ConnectorID: connectorIDString(sig),
					Cap:         capState.cap(),
					Count:       capState.count(),
				}); err != nil {
				return DisposeResult{}, err
			}
			d.Metrics.RecordCapped()
		}
		return d.holdProposed(ctx, sig, connectorType)
	}

	verdict, err := d.Triage.Judge(ctx, sig.Payload)
	if err != nil {
		// Model error ⇒ fail closed to PROPOSED (no surfaced model verdict).
		return d.holdProposed(ctx, sig, connectorType)
	}
	isTask := verdict.IsTask
	if !isTask {
		// is-task=false ⇒ no surfaced task; record llm_judge_invoked is the
		// audit trail. The pre-task signal is marked processed.
		if err := d.markProcessed(ctx, sig.ID); err != nil {
			return DisposeResult{}, err
		}
		// Record the invocation as a connector-scoped audit (no task to attach).
		if err := d.writeConnectorAudit(ctx, sig, connectorType, lifecycle.KindLLMJudgeInvoked,
			lifecycle.LLMJudgeInvokedPayload{SignalID: sig.ID.String(), IsTask: &isTask}); err != nil {
			return DisposeResult{}, err
		}
		return DisposeResult{Outcome: OutcomeProposed, ModelInvoked: true, Surfaced: false}, nil
	}

	title := verdict.Title
	if title == "" {
		title = deriveTitle(sig.Payload, sig.Provenance)
	}
	created, err := core.CreateTaskFromSignal(ctx, d.Pool, d.DBOS, sig.ID, title, sig.Provenance, lifecycle.StateProposed)
	if err != nil {
		return DisposeResult{}, fmt.Errorf("llm_judge create: %w", err)
	}
	if err := d.writeTaskAuditNoMark(ctx, created.ID, from, lifecycle.KindLLMJudgeInvoked,
		lifecycle.LLMJudgeInvokedPayload{SignalID: sig.ID.String(), IsTask: &isTask}); err != nil {
		return DisposeResult{}, err
	}
	if err := d.writeTaskAudit(ctx, sig.ID, created.ID, from, lifecycle.KindDispositionApplied,
		lifecycle.DispositionAppliedPayload{
			Disposition: string(db.SignalDispositionLlmJudge),
			Outcome:     OutcomeProposed,
			SignalID:    sig.ID.String(),
		}); err != nil {
		return DisposeResult{}, err
	}
	return DisposeResult{TaskID: created.ID, Outcome: OutcomeProposed, ModelInvoked: true, Surfaced: true}, nil
}

// holdProposed creates a PROPOSED task (no chain) and records
// disposition_applied(outcome=proposed).
func (d *Disposer) holdProposed(ctx context.Context, sig db.IntakeSignal, connectorType string) (DisposeResult, error) {
	from := connectorPrincipal(sig, connectorType)
	created, err := core.CreateTaskFromSignal(ctx, d.Pool, d.DBOS, sig.ID,
		deriveTitle(sig.Payload, sig.Provenance), sig.Provenance, lifecycle.StateProposed)
	if err != nil {
		return DisposeResult{}, fmt.Errorf("hold proposed create: %w", err)
	}
	if err := d.writeTaskAudit(ctx, sig.ID, created.ID, from, lifecycle.KindDispositionApplied,
		lifecycle.DispositionAppliedPayload{
			Disposition: string(sig.Disposition),
			Outcome:     OutcomeProposed,
			SignalID:    sig.ID.String(),
		}); err != nil {
		return DisposeResult{}, err
	}
	return DisposeResult{TaskID: created.ID, Outcome: OutcomeProposed, Surfaced: true}, nil
}

// writeTaskAuditNoMark writes a task-scoped audit without marking the signal
// processed (used for the auxiliary audits that precede the final
// disposition_applied write that does the marking).
func (d *Disposer) writeTaskAuditNoMark(ctx context.Context, taskID uuid.UUID, from, kind string, payload any) error {
	tx, err := d.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin audit tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, from, kind, payload, uuid.Nil); err != nil {
		return fmt.Errorf("audit %s: %w", kind, err)
	}
	return tx.Commit(ctx)
}

// writeConnectorAudit writes a pre-task (NULL task_id) connector-scoped audit
// and marks the signal processed atomically.
func (d *Disposer) writeConnectorAudit(ctx context.Context, sig db.IntakeSignal, connectorType, kind string, payload any) error {
	from := connectorPrincipal(sig, connectorType)
	tx, err := d.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin audit tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := lifecycle.WriteAuditMessage(ctx, tx, uuid.Nil, from, kind, payload, uuid.Nil); err != nil {
		return fmt.Errorf("audit %s: %w", kind, err)
	}
	if err := db.New(tx).MarkSignalProcessed(ctx, sig.ID); err != nil {
		return fmt.Errorf("mark signal processed: %w", err)
	}
	return tx.Commit(ctx)
}

func (d *Disposer) markProcessed(ctx context.Context, signalID uuid.UUID) error {
	return d.Queries.MarkSignalProcessed(ctx, signalID)
}

// validRichAxes returns the confidence/stakes axes and whether both are
// present and in [0,1].
func validRichAxes(sig db.IntakeSignal) (conf, stakes float64, ok bool) {
	if sig.Confidence == nil || sig.StakesHint == nil {
		return 0, 0, false
	}
	conf, stakes = *sig.Confidence, *sig.StakesHint
	if conf < 0 || conf > 1 || stakes < 0 || stakes > 1 {
		return 0, 0, false
	}
	return conf, stakes, true
}

func connectorIDString(sig db.IntakeSignal) string {
	if sig.ConnectorID.Valid {
		return uuid.UUID(sig.ConnectorID.Bytes).String()
	}
	return ""
}

// deriveTitle pulls a human title from the connector-normalized payload,
// preferring title/subject/summary, falling back to the provenance reason.
func deriveTitle(payload, provenance json.RawMessage) string {
	var m map[string]any
	if err := json.Unmarshal(payload, &m); err == nil {
		for _, k := range []string{"title", "subject", "summary", "name"} {
			if v, ok := m[k].(string); ok && v != "" {
				return v
			}
		}
	}
	var p Provenance
	if err := json.Unmarshal(provenance, &p); err == nil && p.Reason != "" {
		return p.Reason
	}
	return "Intake task"
}
