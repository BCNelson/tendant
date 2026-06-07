package graph_test

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/gatescript"
)

// --- minimal WASM section encoder (validate pipeline inspects sections only) -

func gsULEB(n int) []byte {
	var out []byte
	u := uint32(n)
	for {
		b := byte(u & 0x7F)
		u >>= 7
		if u != 0 {
			out = append(out, b|0x80)
		} else {
			return append(out, b)
		}
	}
}
func gsName(s string) []byte { return append(gsULEB(len(s)), []byte(s)...) }
func gsSec(id byte, body []byte) []byte {
	return append(append([]byte{id}, gsULEB(len(body))...), body...)
}

// gsModule builds a header + import + export module. Function imports come from
// `imports` ({module,name}); `exportFuncs` are the exported function names; a
// memory export is always included.
func gsModule(imports [][2]string, exportFuncs []string) []byte {
	var imp []byte
	for _, im := range imports {
		imp = append(imp, gsName(im[0])...)
		imp = append(imp, gsName(im[1])...)
		imp = append(imp, 0x00)
		imp = append(imp, gsULEB(0)...)
	}
	impSec := gsSec(2, append(gsULEB(len(imports)), imp...))

	exp := append(gsName("memory"), 0x02, 0x00)
	count := 1
	for i, fn := range exportFuncs {
		exp = append(exp, gsName(fn)...)
		exp = append(exp, 0x00)
		exp = append(exp, gsULEB(i)...)
		count++
	}
	expSec := gsSec(7, append(gsULEB(count), exp...))

	header := []byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00}
	return append(append(header, impSec...), expSec...)
}

func b64(b []byte) string { return base64.StdEncoding.EncodeToString(b) }

var stdExports = []string{"evaluate", "tendant_alloc", "tendant_dealloc"}

const sendEmailURI = "tendant://tools/send-email"

func validManifest() map[string]any {
	return map[string]any{
		"manifest_version": "1", "tool": sendEmailURI, "entrypoint": "evaluate",
		"reads": []any{"contacts"}, "egress": []any{},
		"limits": map[string]any{"timeout_ms": 250, "memory_pages": 64},
	}
}

func attachGateScriptGQL(t *testing.T, env *chainEnv, toolID uuid.UUID, wasm []byte, manifest map[string]any) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $w: Bytes!, $m: JSON!) {
		   attachGateScript(toolId: $id, wasm: $w, manifest: $m) { id version tier status }
		 }`,
		"variables": map[string]any{"id": toolID.String(), "w": b64(wasm), "m": manifest},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func setOwnerRuleGQL(t *testing.T, env *chainEnv, key, value string) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query":     `mutation($k: String!, $v: String!) { setOwnerRule(key: $k, value: $v) { key value } }`,
		"variables": map[string]any{"k": key, "v": value},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func compileAndAttachGateScriptGQL(t *testing.T, env *chainEnv, toolID uuid.UUID, source string, manifest map[string]any) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $s: String!, $m: JSON!) {
		   compileAndAttachGateScript(toolId: $id, source: $s, manifest: $m) { id version tier }
		 }`,
		"variables": map[string]any{"id": toolID.String(), "s": source, "m": manifest},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func disableGateScriptGQL(t *testing.T, env *chainEnv, toolID uuid.UUID) gqlResponse {
	t.Helper()
	body, err := json.Marshal(map[string]any{
		"query":     `mutation($id: ID!) { disableGateScript(toolId: $id) { id } }`,
		"variables": map[string]any{"id": toolID.String()},
	})
	require.NoError(t, err)
	return postGraphQL(t, env.handler, body)
}

func setBearer(t *testing.T, bearer string) {
	prev := testBearer
	testBearer = bearer
	t.Cleanup(func() { testBearer = prev })
}

func countRows(t *testing.T, env *chainEnv, sql string, args ...any) int {
	t.Helper()
	var n int
	require.NoError(t, env.pool.QueryRow(context.Background(), sql, args...).Scan(&n))
	return n
}

// TestGateScript_OwnerOnly is SC-008 / NFR-003: only Principal.Kind == "user"
// can attach, disable, or set owner rules; a bot is refused before any DB write.
func TestGateScript_OwnerOnly(t *testing.T) {
	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	validWasm := gsModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports)

	// Bot is denied on all three mutations, DB unchanged.
	botBearer, _ := issueBotBearer(t, env)
	setBearer(t, botBearer)

	before := countRows(t, env, `SELECT count(*) FROM gate_scripts`)
	resp := attachGateScriptGQL(t, env, toolID, validWasm, validManifest())
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	resp = disableGateScriptGQL(t, env, toolID)
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	resp = setOwnerRuleGQL(t, env, "k", "v")
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	// compileAndAttachGateScript is owner-only too — the bot is refused BEFORE
	// the asc compile is even attempted (PERMISSION_DENIED, not COMPILE_FAILED).
	resp = compileAndAttachGateScriptGQL(t, env, toolID, "export function evaluate(): u64 { return 0; }", validManifest())
	require.Equal(t, "PERMISSION_DENIED", errorCode(t, resp.Errors))

	require.Equal(t, before, countRows(t, env, `SELECT count(*) FROM gate_scripts`), "DB must be unchanged after denied attach")
	require.Equal(t, 0, countRows(t, env, `SELECT count(*) FROM owner_rules`), "no owner rule from a denied set")
}

// TestGateScript_Attach_OwnerHappyAndReject covers SC-007 (Tier-2 attach) and
// SC-003 (undeclared-import rejected + gate_script_rejected audit).
func TestGateScript_Attach_OwnerHappyAndReject(t *testing.T) {
	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	setBearer(t, issueOwnerBearer(t, env))

	// Happy path: a granted import passes; row stored, version 1, active advances.
	validWasm := gsModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports)
	resp := attachGateScriptGQL(t, env, toolID, validWasm, validManifest())
	require.Empty(t, resp.Errors, "expected attach success: %s", resp.Errors)

	tool, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.NotNil(t, tool.ActiveScriptVersion)
	require.Equal(t, int32(1), *tool.ActiveScriptVersion)
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM gate_scripts WHERE tool_id=$1`, toolID))
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM audit_messages WHERE kind='gate_script_attached'`))

	// Undeclared import: external_fetch with reads=[call.args] → INVALID_MANIFEST.
	badManifest := validManifest()
	badManifest["reads"] = []any{"call.args"}
	badWasm := gsModule([][2]string{{"tendant", "external_fetch"}}, stdExports)
	resp = attachGateScriptGQL(t, env, toolID, badWasm, badManifest)
	require.Equal(t, "INVALID_MANIFEST", errorCode(t, resp.Errors))
	// No new gate_scripts row; a gate_script_rejected audit row landed (task_id NULL).
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM gate_scripts WHERE tool_id=$1`, toolID))
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM audit_messages WHERE kind='gate_script_rejected' AND task_id IS NULL`))

	// tool_mismatch: manifest.tool points elsewhere.
	mismatch := validManifest()
	mismatch["tool"] = "tendant://tools/other"
	resp = attachGateScriptGQL(t, env, toolID, validWasm, mismatch)
	require.Equal(t, "INVALID_MANIFEST", errorCode(t, resp.Errors))
}

// TestGateScript_E2E_ApproveSkipsOverseer is the US1 end-to-end (SC-001): a
// real WASM gate script (the production ExampleApproveModule, executed by the
// wired WazeroRunner) returns Approve for a benign call to a known recipient;
// the overseer is NEVER consulted; the tool dispatches and a clean outcome +
// exactly one gate_script_evaluated audit row land.
func TestGateScript_E2E_ApproveSkipsOverseer(t *testing.T) {
	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	owner, err := env.queries.GetViewer(context.Background())
	require.NoError(t, err)

	setBearer(t, issueOwnerBearer(t, env))

	// Attach the runnable approve-everything example module (imports nothing,
	// so reads=[] in its manifest; validManifest's reads is a legal superset).
	resp := attachGateScriptGQL(t, env, toolID, gatescript.ExampleApproveModule(), validManifest())
	require.Empty(t, resp.Errors, "attach example: %s", resp.Errors)

	// Propose a benign send to the OWNER (a known principal → floor does not
	// trip → the script runs). Script returns Approve → auto-dispatch.
	taskID := createTaskGQL(t, env, "gate-script e2e")
	_ = proposeToolCallGQL(t, env, taskID, sendEmailURI, map[string]any{
		"to": owner.GlobalUri, "subject": "hi", "body": "hope your day is going well",
	})

	// The approve path auto-dispatches via the durable workflow — poll for it.
	pollUntilToolOutcome(t, env, taskID)

	// Exactly one clean outcome; one gate_script_evaluated row (verdict approve);
	// and crucially NO overseer_evaluated row — the LLM was skipped.
	require.Equal(t, 1, countRows(t, env,
		`SELECT count(*) FROM tool_outcomes WHERE task_id=$1 AND outcome='clean'`, taskID))
	require.Equal(t, 1, countRows(t, env,
		`SELECT count(*) FROM audit_messages WHERE task_id=$1 AND kind='gate_script_evaluated' AND payload->>'verdict'='approve'`, taskID))
	require.Equal(t, 0, countRows(t, env,
		`SELECT count(*) FROM audit_messages WHERE task_id=$1 AND kind='overseer_evaluated'`, taskID),
		"overseer must be skipped when the script approves")
}

// TestGateScript_E2E_RequestDecisionLinksEvaluation is the US1 scenario-3 +
// T055 path: a script's RequestDecision raises an ApprovalRequest, the overseer
// is skipped, and the gate_script_evaluated audit row is stamped with the
// decision id (what ApprovalRequest.gateScriptEvaluation resolves on).
func TestGateScript_E2E_RequestDecisionLinksEvaluation(t *testing.T) {
	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	owner, err := env.queries.GetViewer(context.Background())
	require.NoError(t, err)
	setBearer(t, issueOwnerBearer(t, env))

	resp := attachGateScriptGQL(t, env, toolID, gatescript.ExampleRequestDecisionModule(), validManifest())
	require.Empty(t, resp.Errors, "attach: %s", resp.Errors)

	taskID := createTaskGQL(t, env, "gate-script request-decision e2e")
	decisionID := proposeToolCallGQL(t, env, taskID, sendEmailURI, map[string]any{
		"to": owner.GlobalUri, "subject": "hi", "body": "hello",
	})

	// The gate_script_evaluated row carries verdict=request_decision and the
	// decision id — the link ApprovalRequest.gateScriptEvaluation resolves on.
	require.Equal(t, 1, countRows(t, env,
		`SELECT count(*) FROM audit_messages WHERE task_id=$1 AND kind='gate_script_evaluated'
		   AND payload->>'verdict'='request_decision' AND payload->>'decision_id'=$2`,
		taskID, decisionID.String()))
	// Overseer skipped (RequestDecision from the script is terminal).
	require.Equal(t, 0, countRows(t, env,
		`SELECT count(*) FROM audit_messages WHERE task_id=$1 AND kind='overseer_evaluated'`, taskID))
}

const tier1Source = `
import { call, contacts, verdict, Verdict } from "@tendant/gate-sdk";
function fieldOf(json: string, key: string): string {
  const n = "\"" + key + "\":\""; const i = json.indexOf(n); if (i < 0) return "";
  const s = i + n.length; const e = json.indexOf("\"", s); return e < 0 ? "" : json.substring(s, e);
}
export function evaluate(): Verdict {
  const c = call.get();
  if (!contacts.isKnown(fieldOf(c, "to"))) return verdict.requestDecision("unknown recipient");
  return verdict.approve();
}`

// TestGateScript_CompileAndAttach_Tier1 is the SC-006 Tier-1 round-trip: the
// owner submits AssemblyScript source, the server compiles it (subprocess asc
// backend) through the SAME static-validation pipeline as Tier 2, stores it with
// tier=assemblyscript_in_app + source, and advances the active version. Skipped
// unless `asc` is on PATH (run in devenv / `nix shell nixpkgs#assemblyscript`).
func TestGateScript_CompileAndAttach_Tier1(t *testing.T) {
	comp, err := gatescript.NewSubprocessASCCompiler()
	if err != nil {
		t.Skip("asc not on PATH — run inside devenv or `nix shell nixpkgs#assemblyscript`")
	}
	gatescript.SetASCCompiler(comp.Compile)

	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	setBearer(t, issueOwnerBearer(t, env))

	manifest := validManifest()
	manifest["reads"] = []any{"call.args", "contacts"} // the source imports call.get + contacts.isKnown

	body, err := json.Marshal(map[string]any{
		"query": `mutation($id: ID!, $s: String!, $m: JSON!) {
		   compileAndAttachGateScript(toolId: $id, source: $s, manifest: $m) { id version tier }
		 }`,
		"variables": map[string]any{"id": toolID.String(), "s": tier1Source, "m": manifest},
	})
	require.NoError(t, err)
	resp := postGraphQL(t, env.handler, body)
	require.Empty(t, resp.Errors, "compileAndAttach: %s", resp.Errors)

	tool, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.NotNil(t, tool.ActiveScriptVersion)
	require.Equal(t, int32(1), *tool.ActiveScriptVersion)
	// Stored as Tier 1 with source populated.
	require.Equal(t, 1, countRows(t, env,
		`SELECT count(*) FROM gate_scripts WHERE tool_id=$1 AND tier='assemblyscript_in_app' AND source IS NOT NULL`, toolID))
	require.Equal(t, 1, countRows(t, env,
		`SELECT count(*) FROM audit_messages WHERE kind='gate_script_attached' AND payload->>'tier'='assemblyscript_in_app'`))
}

// TestGateScript_DisableAndOwnerRule exercises the owner-happy disable + the
// owner_rule_set audit + NO_ACTIVE_SCRIPT.
func TestGateScript_DisableAndOwnerRule(t *testing.T) {
	env := newChainEnv(t)
	toolID := sendEmailToolID(t, env)
	setBearer(t, issueOwnerBearer(t, env))

	// setOwnerRule happy path + audit.
	resp := setOwnerRuleGQL(t, env, "max_email_size_kb", "250")
	require.Empty(t, resp.Errors, "%s", resp.Errors)
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM owner_rules WHERE key='max_email_size_kb'`))
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM audit_messages WHERE kind='owner_rule_set' AND task_id IS NULL`))

	// disableGateScript with no active script → NO_ACTIVE_SCRIPT.
	resp = disableGateScriptGQL(t, env, toolID)
	require.Equal(t, "NO_ACTIVE_SCRIPT", errorCode(t, resp.Errors))

	// Attach then disable → pointer cleared, prior row disabled, audit lands.
	validWasm := gsModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports)
	require.Empty(t, attachGateScriptGQL(t, env, toolID, validWasm, validManifest()).Errors)
	require.Empty(t, disableGateScriptGQL(t, env, toolID).Errors)

	tool, err := env.queries.GetToolByID(context.Background(), toolID)
	require.NoError(t, err)
	require.Nil(t, tool.ActiveScriptVersion, "pointer cleared after disable")
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM gate_scripts WHERE tool_id=$1 AND status='disabled'`, toolID))
	require.Equal(t, 1, countRows(t, env, `SELECT count(*) FROM audit_messages WHERE kind='gate_script_disabled'`))
}
