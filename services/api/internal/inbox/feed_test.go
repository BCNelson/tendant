package inbox_test

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/inbox"
)

// createTaskWith builds a task with explicit state / priority / optional
// deadline so the ranked-feed tests can drive the blended urgency score.
func createTaskWith(t *testing.T, q *db.Queries, state db.TaskState, priority db.TaskPriority, dueAt *time.Time) uuid.UUID {
	t.Helper()
	id := uuid.New()
	var due pgtype.Timestamptz
	if dueAt != nil {
		due = pgtype.Timestamptz{Time: *dueAt, Valid: true}
	}
	_, err := q.CreateTask(context.Background(), db.CreateTaskParams{
		ID:           id,
		GlobalUri:    "local://task/" + id.String(),
		Title:        "t",
		State:        state,
		CurrentStage: db.ChainStageCreation,
		Priority:     priority,
		DueAt:        due,
	})
	require.NoError(t, err)
	return id
}

func insertDecision(t *testing.T, q *db.Queries, taskID uuid.UUID) {
	t.Helper()
	_, err := q.InsertPendingDecision(context.Background(), db.InsertPendingDecisionParams{
		TaskID:  taskID,
		Kind:    db.DecisionKindApprovalRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)
}

// TestListFeed_RankingAndActionableFilter proves three things at once: PROPOSED
// tasks join the feed as first-class items, the actionable-only filter drops
// items on terminal tasks, and rows come back ordered by descending blended
// urgency (priority + deadline proximity).
func TestListFeed_RankingAndActionableFilter(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	now := time.Now().UTC()
	overdue := now.Add(-2 * time.Hour)
	inThreeDays := now.Add(72 * time.Hour)

	// PROPOSED + urgent + overdue → highest score (the action item is the task).
	aUrgent := createTaskWith(t, q, db.TaskStateProposed, db.TaskPriorityUrgent, &overdue)
	// PROPOSED + low + no deadline → lowest score.
	bLow := createTaskWith(t, q, db.TaskStateProposed, db.TaskPriorityLow, nil)
	// ACCEPTED + normal + due in 3 days, surfaced via a pending decision → middle.
	cMid := createTaskWith(t, q, db.TaskStateAccepted, db.TaskPriorityNormal, &inThreeDays)
	insertDecision(t, q, cMid)
	// DONE task with an open decision → must be filtered out (not actionable).
	dDone := createTaskWith(t, q, db.TaskStateDone, db.TaskPriorityUrgent, &overdue)
	insertDecision(t, q, dDone)

	items, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	require.Len(t, items, 3, "the done task's decision must be filtered out")

	// Ordered by score DESC.
	for i := 1; i < len(items); i++ {
		require.GreaterOrEqual(t, items[i-1].Score, items[i].Score, "feed must be ranked by score DESC")
	}

	// Head is the urgent overdue proposed task, surfaced as a "task" kind.
	require.Equal(t, "task", items[0].Kind)
	require.Equal(t, aUrgent, items[0].TaskID)
	// Tail is the low/no-deadline proposed task.
	require.Equal(t, bLow, items[len(items)-1].TaskID)

	// The done task never appears.
	for _, it := range items {
		require.NotEqual(t, dDone, it.TaskID)
	}

	// Assemble resolves the proposed task into a full Task row.
	assembled, err := inbox.Assemble(ctx, q, items)
	require.NoError(t, err)
	var sawActionableTask bool
	for _, a := range assembled {
		if a.Kind == "task" {
			sawActionableTask = true
			require.NotNil(t, a.Task)
			require.Equal(t, db.TaskStateProposed, a.Task.State)
		}
	}
	require.True(t, sawActionableTask)
}

// TestListFeed_FeedbackRequestOnDoneTaskSurfaces guards the post-completion
// feedback loop: a feedback_request decision is opened *after* its task reaches
// DONE, so the actionable-only terminal-state filter must exempt it (other
// decision kinds on terminal tasks stay filtered, proven by the sibling test).
func TestListFeed_FeedbackRequestOnDoneTaskSurfaces(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	now := time.Now().UTC()

	// DONE task carrying an open feedback_request → must surface despite the
	// task being terminal.
	doneWithFeedback := createTaskWith(t, q, db.TaskStateDone, db.TaskPriorityNormal, nil)
	_, err := q.InsertPendingDecision(ctx, db.InsertPendingDecisionParams{
		TaskID:  doneWithFeedback,
		Kind:    db.DecisionKindFeedbackRequest,
		Payload: json.RawMessage(`{}`),
	})
	require.NoError(t, err)

	// DONE task carrying an open approval_request → must stay filtered.
	doneWithApproval := createTaskWith(t, q, db.TaskStateDone, db.TaskPriorityNormal, nil)
	insertDecision(t, q, doneWithApproval)

	items, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)

	var sawFeedback, sawApproval bool
	for _, it := range items {
		if it.TaskID == doneWithFeedback {
			sawFeedback = true
		}
		if it.TaskID == doneWithApproval {
			sawApproval = true
		}
	}
	require.True(t, sawFeedback, "feedback_request on a DONE task must surface in the feed")
	require.False(t, sawApproval, "approval_request on a DONE task must remain filtered")
}

// TestListFeed_KeysetStabilityPinnedClock walks the whole feed in pages against
// a single pinned clock and asserts every item appears exactly once — and that
// a high-urgency row inserted mid-scroll does NOT gate-crash later pages (its
// score sits above the pinned cursor), but does surface on a fresh scroll.
func TestListFeed_KeysetStabilityPinnedClock(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	now := time.Now().UTC()
	original := make(map[uuid.UUID]bool, 5)
	for i := 0; i < 5; i++ {
		pr := db.TaskPriorityNormal
		if i%2 == 1 {
			pr = db.TaskPriorityLow
		}
		id := createTaskWith(t, q, db.TaskStateProposed, pr, nil)
		original[id] = true
		time.Sleep(2 * time.Millisecond) // stagger created_at for a stable id/age order
	}

	seen := map[uuid.UUID]bool{}
	var injected uuid.UUID
	cursor := ""
	pages := 0
	for {
		page, next, err := inbox.ListFeed(ctx, q, owner.GlobalUri, cursor, 2, now)
		require.NoError(t, err)
		for _, it := range page {
			require.False(t, seen[it.ID], "no item may appear on two pages")
			seen[it.ID] = true
		}
		pages++
		require.Less(t, pages, 10, "pagination must terminate")

		// After the first page, inject an URGENT task. Its score (~400) is far
		// above any normal/low row, so the pinned keyset must exclude it from
		// the remaining pages of this session.
		if pages == 1 {
			injected = createTaskWith(t, q, db.TaskStateProposed, db.TaskPriorityUrgent, nil)
		}
		if next == "" {
			break
		}
		cursor = next
	}

	require.Len(t, seen, 5, "the session must yield exactly the 5 pre-existing items")
	require.False(t, seen[injected], "a high-urgency mid-scroll arrival must not appear until a fresh cursor")

	// A fresh scroll (new pinned clock) includes the injected row — at the top,
	// since urgent outranks every normal/low item.
	fresh, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, time.Now().UTC())
	require.NoError(t, err)
	require.Len(t, fresh, 6)
	require.Equal(t, injected, fresh[0].ID, "the urgent arrival ranks first on a fresh scroll")
}

// TestBlendedUrgency_Pure checks the Go mirror of the SQL score is monotonic in
// the dimensions that matter.
func TestBlendedUrgency_Pure(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 1, 1, 12, 0, 0, 0, time.UTC)
	created := now.Add(-1 * time.Hour)
	overdue := now.Add(-1 * time.Hour)
	soon := now.Add(12 * time.Hour)       // <24h bucket
	week := now.Add(72 * time.Hour)       // <7d bucket
	later := now.Add(30 * 24 * time.Hour) // outside all buckets

	require.Greater(t,
		inbox.BlendedUrgency("urgent", &overdue, 0, created, now),
		inbox.BlendedUrgency("low", nil, 0, created, now),
		"urgent+overdue must outrank low+no-deadline")

	require.Greater(t,
		inbox.BlendedUrgency("normal", &soon, 0, created, now),
		inbox.BlendedUrgency("normal", &week, 0, created, now),
		"closer deadlines score higher")

	require.Equal(t,
		inbox.BlendedUrgency("normal", &later, 0, created, now),
		inbox.BlendedUrgency("normal", nil, 0, created, now),
		"a deadline beyond 7 days adds nothing")

	s0 := inbox.BlendedUrgency("normal", nil, 0, created, now)
	s1 := inbox.BlendedUrgency("normal", nil, 1, created, now)
	require.InDelta(t, 100.0, s1-s0, 0.0001, "stakes_hint scales by 100")
}

// TestBlendedUrgency_SQLParity guards against the Go mirror drifting from the
// SQL score expression: the score returned by ListFeed must match BlendedUrgency
// computed over the same row + pinned clock (stakes 0 — no intake signal).
func TestBlendedUrgency_SQLParity(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	q, owner := setupInboxDB(t)

	due := time.Now().UTC().Add(10 * time.Hour) // <24h bucket
	id := createTaskWith(t, q, db.TaskStateProposed, db.TaskPriorityHigh, &due)
	time.Sleep(20 * time.Millisecond) // let age be > 0 in both formulas
	now := time.Now().UTC()

	items, _, err := inbox.ListFeed(ctx, q, owner.GlobalUri, "", 50, now)
	require.NoError(t, err)
	var sqlScore float64
	var found bool
	for _, it := range items {
		if it.ID == id {
			sqlScore, found = it.Score, true
		}
	}
	require.True(t, found)

	task, err := q.GetTask(ctx, id)
	require.NoError(t, err)
	goScore := inbox.BlendedUrgency("high", &due, 0, task.CreatedAt, now)
	require.InDelta(t, goScore, sqlScore, 0.01, "Go BlendedUrgency must match the SQL score")
}
