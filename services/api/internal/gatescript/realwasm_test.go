package gatescript

import (
	"context"
	"encoding/json"
	"os"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// realwasm_test.go runs a REAL AssemblyScript-compiled gate script (built from
// sdks/gate-sdk-as/examples/send-email.ts via `asc`, committed as a fixture)
// through the full Service → WazeroRunner → host-call path. Unlike the
// hand-encoded fixtures (which make no host calls), this exercises call.get()
// and contacts.isKnown() end-to-end — proving the SDK, the ABI, the host-module
// memory marshalling (tendant_alloc round-trip), and the runner all interoperate
// with a production compiler's output. This is the strongest Tier-1 proof.

func TestService_RealAssemblyScriptModule(t *testing.T) {
	wasm, err := os.ReadFile("testdata/send_email_as.wasm")
	require.NoError(t, err)

	const toolURI = "tendant://tools/send-email"
	manifest := Manifest{
		ManifestVersion: "1", Tool: toolURI, Entrypoint: "evaluate",
		Reads: []string{"call.args", "contacts"}, Egress: []string{},
		Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}

	// The compiled module must pass static validation (imports ⊆ reads;
	// evaluate + tendant_alloc/dealloc + memory exports).
	require.NoError(t, ValidateModule(wasm, manifest, toolURI, DefaultCeilings()),
		"the asc-compiled example must pass static validation")

	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)

	// Seed the owner principal — it is a "known contact" for contacts.isKnown.
	_, err = pool.Exec(ctx, `INSERT INTO principals (id, global_uri, kind, display_name)
		VALUES (gen_random_uuid(), $1, 'user', 'owner')`, ownerURI)
	require.NoError(t, err)

	toolID := uuid.New()
	_, err = pool.Exec(ctx, `INSERT INTO tools (id, global_uri, name, rung, permissions)
		VALUES ($1, $2, 'send-email', 'execute_gated', '{}')`, toolID, toolURI)
	require.NoError(t, err)

	rawManifest, _ := json.Marshal(manifest)
	hash, _ := ManifestHash(manifest)
	ver, err := q.NextGateScriptVersion(ctx, toolID)
	require.NoError(t, err)
	_, err = q.CreateGateScript(ctx, db.CreateGateScriptParams{
		ToolID: toolID, Version: ver, Manifest: rawManifest, ManifestHash: hash,
		Wasm: wasm, Tier: "assemblyscript_in_app", AttachedByPrincipal: ownerURI,
	})
	require.NoError(t, err)
	_, err = q.UpdateActiveScriptVersion(ctx, db.UpdateActiveScriptVersionParams{ID: toolID, ActiveScriptVersion: &ver})
	require.NoError(t, err)

	runner, err := NewWazeroRunner(ctx, DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = runner.Close(ctx) })
	svc := NewService(runner, q, DefaultCeilings(), ownerURI)
	tool, err := q.GetToolByID(ctx, toolID)
	require.NoError(t, err)

	run := func(payload map[string]any) ScriptVerdict {
		raw, _ := json.Marshal(payload)
		sv, ran, err := svc.Evaluate(ctx, EvalContext{
			TaskID: uuid.New(), ToolID: toolID, ToolGlobalURI: toolURI, Payload: raw,
		}, &tool)
		require.NoError(t, err)
		require.True(t, ran)
		require.True(t, sv.RanToCompletion, "script must run to completion, got %q", sv.FailureReason)
		return sv
	}

	t.Run("known recipient, benign body → approve", func(t *testing.T) {
		sv := run(map[string]any{"to": ownerURI, "subject": "hi", "body": "hope your day is going well"})
		require.Equal(t, VerdictApprove, sv.Decision)
	})

	t.Run("known recipient, money mention → agent_handoff", func(t *testing.T) {
		sv := run(map[string]any{"to": ownerURI, "subject": "loan", "body": "can you send me $500?"})
		require.Equal(t, VerdictAgentHandoff, sv.Decision)
	})

	t.Run("unknown recipient → request_decision", func(t *testing.T) {
		sv := run(map[string]any{"to": "stranger@external.example", "subject": "hi", "body": "hello"})
		require.Equal(t, VerdictRequestDecision, sv.Decision)
	})
}
