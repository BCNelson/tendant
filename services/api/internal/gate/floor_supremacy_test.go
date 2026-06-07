package gate

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"github.com/bcnelson/tendant/services/api/internal/calibration"
	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// TestFloorSupremacy_AutoBandNeverBeatsFloor proves the Phase-8 autonomy layer
// can never auto-approve a floor-tripping call, regardless of trust score or a
// live grant (Constitution III / FR-011 / NFR-002 / SC-004). It also asserts the
// ordering invariant: the grant lookup is NOT consulted before the floor.
func TestFloorSupremacy_AutoBandNeverBeatsFloor(t *testing.T) {
	cases := []struct {
		name    string
		perms   Permissions
		payload string
		lookup  *stubLookup
	}{
		{
			name:    "spend",
			perms:   Permissions{Spend: true},
			payload: `{"to":"known@friend.example"}`,
			lookup:  &stubLookup{},
		},
		{
			name:    "stranger_recipient",
			perms:   Permissions{Irreversible: "stranger_recipient"},
			payload: `{"to":"stranger@unknown.example"}`,
			lookup:  &stubLookup{}, // recipient not known ⇒ floor trips
		},
		{
			name:    "secret_disclosure",
			perms:   Permissions{SecretClasses: []string{"ssn"}},
			payload: `{"to":"known@friend.example","disclosure_class":"ssn"}`,
			lookup:  &stubLookup{},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			call := &ToolCall{TaskID: uuid.New(), ToolID: uuid.New(), Payload: []byte(tc.payload)}
			fp := calibration.Fingerprint(tools.SendEmailGlobalURI, call.Payload)
			tool := &db.Tool{
				GlobalUri:   tools.SendEmailGlobalURI,
				Permissions: permsJSON(t, tc.perms),
				TrustScore:  1.0, // maximally trusted — must not matter
			}
			grants := &grantStub{live: map[string]bool{fp: true}} // a live grant — must not matter
			g := NewDefaultGate(tc.lookup)
			g.Grants = grants

			v, err := g.Evaluate(context.Background(), call, tool)
			if err != nil {
				t.Fatalf("evaluate: %v", err)
			}
			if v.Decision != DecisionRequestDecision {
				t.Fatalf("floor-tripping call must RequestDecision despite EXECUTE_AUTO, got %s", v.Decision)
			}
			if grants.called {
				t.Fatalf("the grant lookup must NOT be consulted before the floor (ordering invariant)")
			}
		})
	}
}
