package graph

import "github.com/bcnelson/tendant/services/api/internal/auth"

// RegisterOperatorEdgeAuth populates the auth registry with one (type, field)
// entry per operator-edge field in the Phase 2 SDL. Called from the boot
// wiring after gqlgen builds the executable schema; the registry's
// AssertCovers(...) call panics if any field is missing.
//
// Phase 2 owner-only: every action verb resolves through Can() to "allow".
// Phase 3+ enriches the action surface; the registry shape stays stable.
func RegisterOperatorEdgeAuth(r *auth.Registry) {
	// Query
	r.MustRegister("Query", "viewer", "view", "Principal")
	r.MustRegister("Query", "task", "view", "Task")
	r.MustRegister("Query", "tasks", "view", "Task")
	r.MustRegister("Query", "inbox", "view", "InboxItem")
	r.MustRegister("Query", "pendingDecision", "view", "PendingDecision")
	r.MustRegister("Query", "agentAssignment", "view", "AgentAssignment")
	r.MustRegister("Query", "sessions", "view", "Session")

	// Mutation — Phase 1 baseline.
	r.MustRegister("Mutation", "createTask", "create", "Task")
	r.MustRegister("Mutation", "completeTask", "complete", "AgentAssignment")
	r.MustRegister("Mutation", "cancelTask", "cancel", "Task")
	r.MustRegister("Mutation", "acceptProposedTask", "accept", "Task")
	r.MustRegister("Mutation", "dismissProposedTask", "dismiss", "Task")

	// Mutation — Phase 2 sessions + device tokens + stubbed decisions.
	r.MustRegister("Mutation", "pairDevice", "pair_device", "Principal")
	r.MustRegister("Mutation", "revokeSession", "revoke_session", "Session")
	r.MustRegister("Mutation", "registerDeviceToken", "register_device", "Principal")
	r.MustRegister("Mutation", "unregisterDeviceToken", "register_device", "Principal")
	r.MustRegister("Mutation", "approveArtifact", "decide", "PendingDecision")
	r.MustRegister("Mutation", "rejectApproval", "decide", "PendingDecision")
	r.MustRegister("Mutation", "answerQuestion", "decide", "PendingDecision")
	r.MustRegister("Mutation", "decidePromotion", "decide", "PendingDecision")

	// Mutation — Phase 3 gate composition surface.
	r.MustRegister("Mutation", "proposeToolCall", "propose_tool_call", "Task")

	// Subscription
	r.MustRegister("Subscription", "inboxItemArrived", "view", "InboxItem")
	r.MustRegister("Subscription", "taskChanged", "view", "Task")
	r.MustRegister("Subscription", "notificationReceived", "view", "Notification")
}

// OperatorEdgeRequiredFields enumerates the (type, field) pairs every
// authenticated operator-edge resolver must cover.
func OperatorEdgeRequiredFields() []auth.FieldKey {
	return []auth.FieldKey{
		{TypeName: "Query", FieldName: "viewer"},
		{TypeName: "Query", FieldName: "task"},
		{TypeName: "Query", FieldName: "tasks"},
		{TypeName: "Query", FieldName: "inbox"},
		{TypeName: "Query", FieldName: "pendingDecision"},
		{TypeName: "Query", FieldName: "agentAssignment"},
		{TypeName: "Query", FieldName: "sessions"},
		{TypeName: "Mutation", FieldName: "createTask"},
		{TypeName: "Mutation", FieldName: "completeTask"},
		{TypeName: "Mutation", FieldName: "cancelTask"},
		{TypeName: "Mutation", FieldName: "acceptProposedTask"},
		{TypeName: "Mutation", FieldName: "dismissProposedTask"},
		{TypeName: "Mutation", FieldName: "pairDevice"},
		{TypeName: "Mutation", FieldName: "revokeSession"},
		{TypeName: "Mutation", FieldName: "registerDeviceToken"},
		{TypeName: "Mutation", FieldName: "unregisterDeviceToken"},
		{TypeName: "Mutation", FieldName: "approveArtifact"},
		{TypeName: "Mutation", FieldName: "rejectApproval"},
		{TypeName: "Mutation", FieldName: "answerQuestion"},
		{TypeName: "Mutation", FieldName: "decidePromotion"},
		{TypeName: "Mutation", FieldName: "proposeToolCall"},
		{TypeName: "Subscription", FieldName: "inboxItemArrived"},
		{TypeName: "Subscription", FieldName: "taskChanged"},
		{TypeName: "Subscription", FieldName: "notificationReceived"},
	}
}
