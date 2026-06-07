package lifecycle

import "testing"

// T037 — accepted→dismissed is legal only under the intake-origin table.
func TestIsLegalIntake_AcceptedDismiss(t *testing.T) {
	// Owner-authored legality: accepted→dismissed is NOT a base edge.
	if IsLegal(StateAccepted, StateDismissed) {
		t.Fatal("accepted→dismissed must not be a base (owner-authored) edge")
	}
	// Intake-origin legality: accepted→dismissed IS permitted (enrich-only D5).
	if !IsLegalIntake(StateAccepted, StateDismissed) {
		t.Fatal("accepted→dismissed must be legal for intake-origin tasks")
	}
	// IsLegalIntake is a superset of IsLegal — every base edge stays legal.
	for from, tos := range legalEdges {
		for to := range tos {
			if !IsLegalIntake(from, to) {
				t.Fatalf("IsLegalIntake must keep base edge %s→%s legal", from, to)
			}
		}
	}
	// It does not open unrelated edges (e.g. done→accepted stays illegal).
	if IsLegalIntake(StateDone, StateAccepted) {
		t.Fatal("IsLegalIntake must not permit done→accepted")
	}
}
