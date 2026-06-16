package graph

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require
// here.

import (
	"github.com/dbos-inc/dbos-transact-golang/dbos"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/config"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/feedback"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/overseer"
	"github.com/bcnelson/tendant/services/api/internal/push"
	"github.com/bcnelson/tendant/services/api/internal/realtime"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// Resolver is the gqlgen root resolver. Dependencies hang off the struct (no
// package-level state — CLAUDE.md convention).
//
// DBOS, Dispatcher, PushQueueName, and PushSelector are nil-able / zero-value
// for the Phase 0-style smoke tests that don't drive subscriptions or push.
// Overseer and ToolRegistry are nil-able for Phase 3 tests that don't drive
// the auto-approve path; production wiring always sets them.
type Resolver struct {
	Pool            *pgxpool.Pool
	Queries         *db.Queries
	DBOS            dbos.DBOSContext
	Dispatcher      *realtime.Dispatcher
	PushSelector    push.Selector
	PushQueueName   string
	Password        *auth.PasswordState
	Overseer        overseer.Grader
	ToolRegistry    *tools.Registry
	ScriptEvaluator gatescript.ScriptEvaluator
	Connectors      ConnectorDeps       // Phase 7 — owner connector mutations
	Mcp             McpDeps             // MCP client edge — owner mcp-server mutations
	Calibrator      *calibration.Engine // Phase 8 — flagOutcome + cancel demotion; nil in pre-Phase-8 tests

	// Post-completion feedback — the conversational converser the
	// sendFeedbackMessage resolver uses to reply. nil ⇒ stub replies.
	FeedbackConverser feedback.Converser

	// Layered config — admin configKeys/setConfigEntry. ConfigOverlay is the
	// DB-side override cache (nil-safe); ConfigSnapshot is the boot env/file/default
	// resolution used to report effective values. Both nil in pre-config tests.
	ConfigOverlay  *config.Overlay
	ConfigSnapshot *config.Config
}
