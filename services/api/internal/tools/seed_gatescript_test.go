package tools_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// seed_gatescript_test.go proves the boot-time example seeder (which runs in
// runServe on first deploy when TENDANT_SEED_EXAMPLE_GATE_SCRIPT=true) attaches a
// script that actually validates AND runs — so the documented demo works on the
// first deploy, not just compiles.
func TestSeedExampleGateScript_AttachesRunnableScript(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))
	q := db.New(pool)
	require.NoError(t, tools.SeedSendEmail(ctx, q))

	// Off by default: no script attached.
	t.Setenv("TENDANT_SEED_EXAMPLE_GATE_SCRIPT", "")
	require.NoError(t, tools.SeedExampleGateScript(ctx, q))
	tool, err := q.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	require.Nil(t, tool.ActiveScriptVersion, "seeder must be a no-op when disabled")

	// Enabled: attaches version 1.
	t.Setenv("TENDANT_SEED_EXAMPLE_GATE_SCRIPT", "true")
	require.NoError(t, tools.SeedExampleGateScript(ctx, q))
	tool, err = q.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	require.NotNil(t, tool.ActiveScriptVersion)
	require.Equal(t, int32(1), *tool.ActiveScriptVersion)

	// Idempotent: a second boot does not attach a duplicate.
	require.NoError(t, tools.SeedExampleGateScript(ctx, q))
	var count int
	require.NoError(t, pool.QueryRow(ctx, `SELECT count(*) FROM gate_scripts WHERE tool_id=$1`, tool.ID).Scan(&count))
	require.Equal(t, 1, count, "re-running the seeder must not attach a second version")

	// The seeded script actually RUNS in the production runner → approve.
	runner, err := gatescript.NewWazeroRunner(ctx, gatescript.DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = runner.Close(ctx) })
	svc := gatescript.NewService(runner, q, gatescript.DefaultCeilings(), "tendant://principals/owner")

	sv, ran, err := svc.Evaluate(ctx, gatescript.EvalContext{
		TaskID:        uuid.New(),
		ToolID:        tool.ID,
		ToolGlobalURI: tools.SendEmailGlobalURI,
		Payload:       []byte(`{"to":"x","body":"hi"}`),
	}, &tool)
	require.NoError(t, err)
	require.True(t, ran, "the seeded script must be active and run")
	require.True(t, sv.RanToCompletion, "seeded script failed: %q", sv.FailureReason)
	require.Equal(t, gatescript.VerdictApprove, sv.Decision)
}
