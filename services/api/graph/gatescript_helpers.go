package graph

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/vektah/gqlparser/v2/gqlerror"

	"github.com/bcnelson/tendant/services/api/graph/model"
	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/ownerrule"
)

// gatescript_helpers.go holds the hand-written bodies behind the generated
// gatescript.resolvers.go stubs. All four mutations are owner-principal-only:
// they call auth.RequireOwner FIRST, before any DB write (FR-023).

// requireOwner maps auth.RequireOwner's sentinel to a PERMISSION_DENIED GraphQL
// error so a non-owner principal is refused before any DB write.
func (r *Resolver) requireOwner(ctx context.Context) (*auth.Principal, error) {
	p, err := auth.RequireOwner(ctx)
	if err != nil {
		return nil, gateError(ctx, "PERMISSION_DENIED", "owner principal required")
	}
	return p, nil
}

// attachGateScriptImpl is the BYO-`.wasm` path (FR-021) and the shared install
// pipeline that compileAndAttach reuses with a non-nil source.
func (r *Resolver) attachGateScriptImpl(ctx context.Context, toolID string, wasm []byte, manifest map[string]any, source *string) (*model.GateScript, error) {
	principal, err := r.requireOwner(ctx)
	if err != nil {
		return nil, err
	}
	tid, err := uuid.Parse(toolID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid toolId: %s", err)
	}
	toolRow, err := r.Queries.GetToolByID(ctx, tid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, gateError(ctx, "TOOL_UNKNOWN", "no tool with id "+toolID)
		}
		return nil, err
	}

	ceilings := gatescript.CeilingsFromEnv()

	// Parse + validate the manifest, then statically validate the module.
	rawManifest, _ := json.Marshal(manifest)
	parsed, perr := gatescript.ParseManifest(rawManifest)
	if perr != nil {
		return nil, r.rejectAttach(ctx, perr, tid, principal.GlobalURI, "")
	}
	manifestHash, _ := gatescript.ManifestHash(parsed)
	if verr := gatescript.ValidateModule(wasm, parsed, toolRow.GlobalUri, ceilings); verr != nil {
		return nil, r.rejectAttach(ctx, verr, tid, principal.GlobalURI, manifestHash)
	}

	tier := "byo_wasm"
	if source != nil {
		tier = "assemblyscript_in_app"
	}

	// Allocate the next version, insert (append-only), advance the pointer.
	version, err := r.Queries.NextGateScriptVersion(ctx, tid)
	if err != nil {
		return nil, err
	}
	row, err := r.Queries.CreateGateScript(ctx, db.CreateGateScriptParams{
		ToolID:              tid,
		Version:             version,
		Manifest:            rawManifest,
		ManifestHash:        manifestHash,
		Wasm:                wasm,
		Source:              source,
		Tier:                tier,
		AttachedByPrincipal: principal.GlobalURI,
	})
	if err != nil {
		return nil, err
	}
	if _, err := r.Queries.UpdateActiveScriptVersion(ctx, db.UpdateActiveScriptVersionParams{
		ID:                  tid,
		ActiveScriptVersion: &version,
	}); err != nil {
		return nil, err
	}

	// Owner-scoped audit (task_id NULL). source_hash is hashed by the caller
	// for Tier 1; nil for Tier 2.
	var sourceHash *string
	if source != nil {
		h := gatescript.SHA256Hex([]byte(*source))
		sourceHash = &h
	}
	var prevActive *int
	if toolRow.ActiveScriptVersion != nil {
		pv := int(*toolRow.ActiveScriptVersion)
		prevActive = &pv
	}
	_ = r.writeOwnerAudit(ctx, lifecycle.KindGateScriptAttached, principal.GlobalURI, lifecycle.GateScriptAttachedPayload{
		ScriptID: row.ID, ToolID: tid, Version: int(version), Tier: tier,
		ManifestHash: manifestHash, SourceHash: sourceHash, PreviousActiveVersion: prevActive,
	})

	toolModel := mapToolRow(&toolRow)
	return gateScriptModel(toolModel, row.ID, row.Version, row.Manifest, row.ManifestHash,
		row.Tier, row.Status, row.AttachedByPrincipal, row.AttachedAt, row.Source), nil
}

// compileAndAttachGateScriptImpl (FR-022). Server-side AssemblyScript compile
// runs inside the vendored asc-on-wazero sandbox (US6). When that sandbox is
// not built into this binary the mutation returns COMPILE_UNAVAILABLE rather
// than silently failing.
func (r *Resolver) compileAndAttachGateScriptImpl(ctx context.Context, toolID, source string, manifest map[string]any) (*model.GateScript, error) {
	if _, err := r.requireOwner(ctx); err != nil {
		return nil, err
	}
	wasm, diags, cerr := gatescript.CompileAssemblyScript(ctx, source)
	if cerr != nil {
		return nil, &gqlerror.Error{
			Message:    "AssemblyScript compile failed: " + cerr.Error(),
			Extensions: map[string]any{"code": "COMPILE_FAILED", "diagnostics": diags},
		}
	}
	return r.attachGateScriptImpl(ctx, toolID, wasm, manifest, &source)
}

// disableGateScriptImpl (FR-024): clear the pointer, disable the prior row.
func (r *Resolver) disableGateScriptImpl(ctx context.Context, toolID string) (*model.Tool, error) {
	principal, err := r.requireOwner(ctx)
	if err != nil {
		return nil, err
	}
	tid, err := uuid.Parse(toolID)
	if err != nil {
		return nil, gqlerror.Errorf("invalid toolId: %s", err)
	}
	toolRow, err := r.Queries.GetToolByID(ctx, tid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, gateError(ctx, "TOOL_UNKNOWN", "no tool with id "+toolID)
		}
		return nil, err
	}
	if toolRow.ActiveScriptVersion == nil {
		return nil, gateError(ctx, "NO_ACTIVE_SCRIPT", "tool has no active gate script")
	}
	prior := *toolRow.ActiveScriptVersion

	updated, err := r.Queries.ClearActiveScriptVersion(ctx, tid)
	if err != nil {
		return nil, err
	}
	if err := r.Queries.DisableGateScriptVersion(ctx, db.DisableGateScriptVersionParams{
		ToolID: tid, Version: prior,
	}); err != nil {
		return nil, err
	}
	_ = r.writeOwnerAudit(ctx, lifecycle.KindGateScriptDisabled, principal.GlobalURI, lifecycle.GateScriptDisabledPayload{
		ToolID: tid, PriorActiveVersion: int(prior),
	})
	return mapToolRow(&updated), nil
}

// setOwnerRuleImpl (FR-018): owner-only upsert + owner_rule_set audit.
func (r *Resolver) setOwnerRuleImpl(ctx context.Context, key, value string) (*model.OwnerRule, error) {
	principal, err := r.requireOwner(ctx)
	if err != nil {
		return nil, err
	}
	if key == "" || len(key) > 64 || len(value) > 1024 {
		return nil, gateError(ctx, "INVALID_RULE", "key must be 1-64 chars and value ≤ 1024 chars")
	}
	prev, err := ownerrule.New(r.Queries).Set(ctx, principal.GlobalURI, key, value)
	if err != nil {
		return nil, err
	}
	_ = r.writeOwnerAudit(ctx, lifecycle.KindOwnerRuleSet, principal.GlobalURI, lifecycle.OwnerRuleSetPayload{
		Key: key, PreviousValue: prev, NewValue: value,
	})
	return &model.OwnerRule{Key: key, Value: value, UpdatedAt: time.Now().UTC()}, nil
}

// toolActiveGateScriptImpl resolves Tool.activeGateScript.
func (r *Resolver) toolActiveGateScriptImpl(ctx context.Context, obj *model.Tool) (*model.GateScript, error) {
	tid, err := uuid.Parse(obj.ID)
	if err != nil {
		return nil, nil
	}
	row, err := r.Queries.GetActiveGateScript(ctx, tid)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return gateScriptModel(obj, row.ID, row.Version, row.Manifest, row.ManifestHash,
		row.Tier, row.Status, row.AttachedByPrincipal, row.AttachedAt, row.Source), nil
}

// toolGateScriptsImpl resolves Tool.gateScripts (newest-first, clamped paging).
func (r *Resolver) toolGateScriptsImpl(ctx context.Context, obj *model.Tool, limit, offset *int) ([]*model.GateScript, error) {
	tid, err := uuid.Parse(obj.ID)
	if err != nil {
		return nil, nil
	}
	lim := int32(20)
	if limit != nil && *limit > 0 {
		lim = int32(*limit)
		if lim > 100 {
			lim = 100
		}
	}
	off := int32(0)
	if offset != nil && *offset > 0 {
		off = int32(*offset)
	}
	rows, err := r.Queries.ListGateScriptsByTool(ctx, db.ListGateScriptsByToolParams{
		ToolID: tid, Limit: lim, Offset: off,
	})
	if err != nil {
		return nil, err
	}
	out := make([]*model.GateScript, 0, len(rows))
	for _, row := range rows {
		out = append(out, gateScriptModel(obj, row.ID, row.Version, row.Manifest, row.ManifestHash,
			row.Tier, row.Status, row.AttachedByPrincipal, row.AttachedAt, row.Source))
	}
	return out, nil
}

// gateScriptEvaluationImpl resolves ApprovalRequest.gateScriptEvaluation: the
// gate_script_evaluated audit row stamped with this decision's id. Returns nil
// when the approval was floor- or overseer-raised (not script-originated).
func (r *Resolver) gateScriptEvaluationImpl(ctx context.Context, obj *model.ApprovalRequest) (*model.GateScriptEvaluation, error) {
	row, err := r.Queries.GateScriptEvaluatedForDecision(ctx, obj.ID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	var p struct {
		Verdict       string `json:"verdict"`
		ScriptID      string `json:"script_id"`
		ScriptVersion int    `json:"script_version"`
		ManifestHash  string `json:"manifest_hash"`
		Evidence      struct {
			Summary          string   `json:"summary"`
			ConsideredFields []string `json:"considered_fields"`
			Hostcalls        []string `json:"hostcalls"`
		} `json:"evidence"`
	}
	if err := json.Unmarshal(row.Payload, &p); err != nil {
		return nil, err
	}
	considered := p.Evidence.ConsideredFields
	if considered == nil {
		considered = []string{}
	}
	hostcalls := p.Evidence.Hostcalls
	if hostcalls == nil {
		hostcalls = []string{}
	}
	return &model.GateScriptEvaluation{
		Verdict:          p.Verdict,
		Summary:          p.Evidence.Summary,
		ConsideredFields: considered,
		HostcallTrace:    hostcalls,
		ScriptID:         p.ScriptID,
		ScriptVersion:    p.ScriptVersion,
		ManifestHash:     p.ManifestHash,
		At:               row.At,
	}, nil
}

// --- mapping + audit helpers ------------------------------------------------

func gateScriptModel(tool *model.Tool, id uuid.UUID, version int32, manifest json.RawMessage,
	manifestHash, tier, status, attachedBy string, attachedAt time.Time, source *string) *model.GateScript {
	var m map[string]any
	_ = json.Unmarshal(manifest, &m)
	return &model.GateScript{
		ID:                  id.String(),
		Tool:                tool,
		Version:             int(version),
		Manifest:            m,
		ManifestHash:        manifestHash,
		Tier:                gateScriptTier(tier),
		Status:              gateScriptStatus(status),
		AttachedByPrincipal: attachedBy,
		AttachedAt:          attachedAt,
		Source:              source,
		// wasm is an opt-in heavy field; omitted here to avoid pulling MiB
		// blobs into list/active queries (FR-029).
	}
}

func gateScriptTier(s string) model.GateScriptTier {
	if s == "assemblyscript_in_app" {
		return model.GateScriptTierAssemblyscriptInApp
	}
	return model.GateScriptTierByoWasm
}

func gateScriptStatus(s string) model.GateScriptStatus {
	if s == "disabled" {
		return model.GateScriptStatusDisabled
	}
	return model.GateScriptStatusActive
}

// rejectAttach writes the gate_script_rejected audit row (task_id NULL, FR-036)
// and returns the mapped GraphQL error. The audit lands even though the upload
// errors — rejection of untrusted code is a security-relevant event.
func (r *Resolver) rejectAttach(ctx context.Context, err error, toolID uuid.UUID, principal, manifestHash string) error {
	var re *gatescript.RejectError
	if !errors.As(err, &re) {
		return err
	}
	var detail json.RawMessage
	if re.Detail != nil {
		detail, _ = json.Marshal(re.Detail)
	}
	_ = r.writeOwnerAudit(ctx, lifecycle.KindGateScriptRejected, principal, lifecycle.GateScriptRejectedPayload{
		Reason: string(re.Reason), ManifestHash: manifestHash, ToolID: toolID,
		AttemptedByPrincipal: principal, Detail: detail,
	})
	code := "INVALID_MANIFEST"
	if re.Reason == gatescript.ReasonModuleTooLarge {
		code = "MODULE_TOO_LARGE"
	}
	return &gqlerror.Error{
		Message:    re.Error(),
		Extensions: map[string]any{"code": code, "reason": string(re.Reason), "detail": re.Detail},
	}
}

// writeOwnerAudit writes a single owner-scoped audit row (task_id NULL) in its
// own transaction. Owner-scoped kinds form their own per-owner chain via
// from_principal + at ordering, so in_reply_to is left nil.
func (r *Resolver) writeOwnerAudit(ctx context.Context, kind, fromPrincipal string, payload any) error {
	return pgx.BeginFunc(ctx, r.Pool, func(tx pgx.Tx) error {
		_, err := lifecycle.WriteAuditMessage(ctx, tx, uuid.Nil, fromPrincipal, kind, payload, uuid.Nil)
		return err
	})
}
