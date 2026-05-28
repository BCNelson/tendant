package push

// InboxRow carries the minimum information ShouldPush needs to gate. The
// chain workflow assembles this struct from the source row before calling.
type InboxRow struct {
	Kind        string // "pending_decision" | "agent_assignment"
	ToPrincipal *string
}

// ShouldPush returns the urgency-gate verdict for an inbox row per FR-016.
//
// Phase 2 conservative rule:
//   - pending_decision → always urgent.
//   - agent_assignment → urgent IFF the assignment is directed (to_principal
//     is non-null).
//   - anything else → false (informational state changes don't push).
//
// Phase 3+ can tighten via additional rules without callers changing.
func ShouldPush(row InboxRow) bool {
	switch row.Kind {
	case "pending_decision":
		return true
	case "agent_assignment":
		return row.ToPrincipal != nil && *row.ToPrincipal != ""
	}
	return false
}
