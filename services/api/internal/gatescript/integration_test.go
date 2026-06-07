package gatescript

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// integration_test.go exercises the full Service path (load active script →
// build host projection → real WazeroRunner → verdict) against a testcontainers
// Postgres, using the production ExampleApproveModule so a real WASM module runs
// end-to-end. It also covers US5 determinism (NFR-005b): the same read-only
// inputs always produce the same verdict.

func TestExampleModule_ValidatesAndRuns(t *testing.T) {
	const tool = "tendant://tools/x"
	wasm := ExampleApproveModule()
	m := ExampleManifest(tool)

	require.NoError(t, ValidateModule(wasm, m, tool, DefaultCeilings()),
		"the shipped example module must pass static validation")

	r, err := NewWazeroRunner(context.Background(), DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = r.Close(context.Background()) })

	v, err := r.Run(context.Background(), ScriptInput{WASM: wasm, ManifestHash: "x", Manifest: m})
	require.NoError(t, err)
	require.True(t, v.RanToCompletion)
	require.Equal(t, VerdictApprove, v.Decision)
}

func TestService_ExampleModule_RunsAndIsDeterministic(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)

	_, err := pool.Exec(ctx, `INSERT INTO principals (id, global_uri, kind, display_name)
		VALUES (gen_random_uuid(), $1, 'user', 'owner')`, ownerURI)
	require.NoError(t, err)

	const toolURI = "tendant://tools/x"
	toolID := uuid.New()
	_, err = pool.Exec(ctx, `INSERT INTO tools (id, global_uri, name, rung, permissions)
		VALUES ($1, $2, 'x', 'execute_gated', '{}')`, toolID, toolURI)
	require.NoError(t, err)

	// Install the example module as version 1 + point the tool at it.
	wasm := ExampleApproveModule()
	manifest := ExampleManifest(toolURI)
	rawManifest, _ := json.Marshal(manifest)
	hash, _ := ManifestHash(manifest)
	ver, err := q.NextGateScriptVersion(ctx, toolID)
	require.NoError(t, err)
	_, err = q.CreateGateScript(ctx, db.CreateGateScriptParams{
		ToolID: toolID, Version: ver, Manifest: rawManifest, ManifestHash: hash,
		Wasm: wasm, Tier: "byo_wasm", AttachedByPrincipal: ownerURI,
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

	in := EvalContext{TaskID: uuid.New(), ToolID: toolID, ToolGlobalURI: toolURI, Payload: []byte(`{"to":"x"}`)}
	sv1, ran1, err := svc.Evaluate(ctx, in, &tool)
	require.NoError(t, err)
	require.True(t, ran1)
	require.True(t, sv1.RanToCompletion)
	require.Equal(t, VerdictApprove, sv1.Decision)
	require.Equal(t, int(ver), sv1.ScriptVersion)

	// Determinism: a second run over the same read-only inputs is identical.
	sv2, ran2, err := svc.Evaluate(ctx, in, &tool)
	require.NoError(t, err)
	require.True(t, ran2)
	require.Equal(t, sv1.Decision, sv2.Decision)
	require.Equal(t, AuditVerdict(sv1.Decision, sv1.FailureReason), AuditVerdict(sv2.Decision, sv2.FailureReason))

	// Stats reflects the two evaluations.
	evals, _ := svc.Stats()
	require.Equal(t, 2, evals)
}
