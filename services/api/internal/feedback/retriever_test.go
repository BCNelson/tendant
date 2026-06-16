package feedback

import (
	"context"
	"strings"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/core"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/lifecycle"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

func TestDBRetriever_Digest(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	dsn := pool.Config().ConnConfig.ConnString()
	require.NoError(t, db.Migrate(ctx, dsn))
	q := db.New(pool)
	require.NoError(t, core.SeedOwner(ctx, q))
	require.NoError(t, tools.SeedSendEmail(ctx, q))
	tool, err := q.GetToolByGlobalURI(ctx, tools.SendEmailGlobalURI)
	require.NoError(t, err)
	task, err := core.CreateTask(ctx, pool, nil, "send the report", "to the team")
	require.NoError(t, err)

	// Two tool outcomes under the task: one clean, one flagged bad.
	for _, oc := range []db.ToolOutcomeKind{db.ToolOutcomeKindClean, db.ToolOutcomeKindBad} {
		_, err := q.InsertToolOutcome(ctx, db.InsertToolOutcomeParams{
			ToolID: tool.ID, TaskID: task.ID, Outcome: oc,
		})
		require.NoError(t, err)
	}

	// An agent run + a handoff in the audit DAG.
	writeAudit(t, pool, task.ID, lifecycle.KindAgentRunFinished, map[string]any{
		"stage": "execution", "messages": []any{},
	})
	writeAudit(t, pool, task.ID, lifecycle.KindAgentHandoff, map[string]any{
		"stage": "execution", "reason": "needs a human to sign the document",
	})

	// An existing active guidance note.
	_, err = q.InsertActiveAgentGuidance(ctx, db.InsertActiveAgentGuidanceParams{
		Note:         "Always confirm the recipient list.",
		Scope:        "global",
		SourceTaskID: pgtype.UUID{Bytes: task.ID, Valid: true},
	})
	require.NoError(t, err)

	r := NewDBRetriever(q)

	dig, err := r.Digest(ctx, task.ID)
	require.NoError(t, err)
	require.Equal(t, 2, dig.ToolsRun)
	require.Equal(t, 1, dig.ToolsFlagged)
	require.Contains(t, dig.AgentStages, "execution")
	require.Equal(t, "needs a human to sign the document", dig.HandoffReason)
	require.Len(t, dig.ActiveGuidance, 1)
	require.NotEmpty(t, dig.Summary)

	// The detail tools return JSON that names the real tool + guidance.
	outcomes, err := r.ToolOutcomes(ctx, task.ID)
	require.NoError(t, err)
	require.True(t, strings.Contains(outcomes, "send-email") || strings.Contains(outcomes, tool.Name),
		"outcomes should name the tool: %s", outcomes)
	require.Contains(t, outcomes, "bad")

	guidance, err := r.ExistingGuidance(ctx)
	require.NoError(t, err)
	require.Contains(t, guidance, "confirm the recipient list")
}

// writeAudit inserts one audit row with the given kind + payload via the same
// helper production code uses.
func writeAudit(t *testing.T, pool *pgxpool.Pool, taskID uuid.UUID, kind string, payload any) {
	t.Helper()
	ctx := context.Background()
	require.NoError(t, pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		_, err := lifecycle.WriteAuditMessage(ctx, tx, taskID, lifecycle.SystemActorURI, kind, payload, uuid.Nil)
		return err
	}))
}
