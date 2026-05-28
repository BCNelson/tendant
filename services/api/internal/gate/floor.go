package gate

import (
	"context"
	"encoding/json"
	"fmt"
)

// Permissions is the per-tool advanced-rule-set "permissions" half. Phase 3
// reads four fields; future phases may add more (the JSON is open).
//
//   - ReadOnly: short-circuits the gate to Approve.
//   - Spend:    floor clause 1.
//   - Irreversible: floor clause 2 mode — "stranger_recipient" | "always" | "never".
//   - SecretClasses: floor clause 3 — if any class here matches the payload's
//     `disclosure_class`, the floor trips.
type Permissions struct {
	ReadOnly      bool     `json:"read_only"`
	Spend         bool     `json:"spend"`
	Irreversible  string   `json:"irreversible_third_party"`
	SecretClasses []string `json:"secret_classes"`
}

func parsePermissions(raw json.RawMessage) (Permissions, error) {
	var p Permissions
	if len(raw) == 0 || string(raw) == "null" {
		return p, nil
	}
	if err := json.Unmarshal(raw, &p); err != nil {
		return p, fmt.Errorf("unmarshal permissions: %w", err)
	}
	return p, nil
}

// FloorContext explains which clause tripped, for audit + UI surfacing.
type FloorContext struct {
	Clause string `json:"clause,omitempty"`
	Detail string `json:"detail,omitempty"`
}

// Floor is the categorical hard-rule floor. Three clauses, evaluated in
// order; first trip wins. Pure function of (ToolCall, Permissions,
// principal-lookup) — no I/O beyond the lookup seam.
type Floor struct {
	Principals PrincipalLookup
}

// NewFloor returns a Floor backed by the given principal lookup. lookup may
// be nil — in which case the "stranger_recipient" mode degrades to "always"
// (fail-closed: treat unknown lookup as a tripped floor).
func NewFloor(lookup PrincipalLookup) *Floor {
	return &Floor{Principals: lookup}
}

// payloadFields captures the fields the floor reads from the tool call
// payload. Tools whose payloads don't include `recipient` or
// `disclosure_class` simply have those clauses evaluate to false.
type payloadFields struct {
	Recipient       string `json:"recipient"`
	To              string `json:"to"` // common alias used by send-email
	DisclosureClass string `json:"disclosure_class"`
}

func (p payloadFields) recipient() string {
	if p.Recipient != "" {
		return p.Recipient
	}
	return p.To
}

// Check returns (tripped, context, err). tripped=true means the gate MUST
// escalate to RequestDecision regardless of any downstream layer.
func (f *Floor) Check(ctx context.Context, call *ToolCall, perms Permissions) (bool, FloorContext, error) {
	if call == nil {
		return false, FloorContext{}, fmt.Errorf("floor: nil call")
	}

	var fields payloadFields
	if len(call.Payload) > 0 {
		// Best-effort decode; missing fields are simply zero values.
		_ = json.Unmarshal(call.Payload, &fields)
	}

	// Clause 1: SPEND. Trips if the tool declares spend=true. (Per-call
	// amount thresholds are a Phase-5 gate-script concern; the floor's job
	// is the categorical guarantee.)
	if perms.Spend {
		return true, FloorContext{Clause: "spend", Detail: "tool.permissions.spend=true"}, nil
	}

	// Clause 2: IRREVERSIBLE THIRD-PARTY EFFECT. Modes:
	//
	//   "never"               — never trips.
	//   "always"              — always trips (e.g. a future broadcast-sms).
	//   "stranger_recipient"  — trips if payload.recipient is not in
	//                           principals.global_uri.
	//   ""                    — empty / unset behaves as "never".
	switch perms.Irreversible {
	case "", "never":
		// no-op
	case "always":
		return true, FloorContext{Clause: "irreversible_third_party", Detail: "mode=always"}, nil
	case "stranger_recipient":
		recipient := fields.recipient()
		if recipient == "" {
			// No recipient field on a tool that declares this mode is a
			// configuration smell; fail-closed.
			return true, FloorContext{
				Clause: "irreversible_third_party",
				Detail: "missing payload.recipient",
			}, nil
		}
		if f.Principals == nil {
			// No lookup wired — fail-closed: assume stranger.
			return true, FloorContext{
				Clause: "irreversible_third_party",
				Detail: "no principal lookup wired; recipient=" + recipient,
			}, nil
		}
		known, lerr := f.Principals.IsKnownPrincipal(ctx, recipient)
		if lerr != nil {
			return true, FloorContext{
				Clause: "irreversible_third_party",
				Detail: "principal lookup failed: " + lerr.Error(),
			}, lerr
		}
		if !known {
			return true, FloorContext{
				Clause: "irreversible_third_party",
				Detail: "recipient=" + recipient + " is not a known principal",
			}, nil
		}
	default:
		return true, FloorContext{
			Clause: "irreversible_third_party",
			Detail: "unknown mode: " + perms.Irreversible,
		}, nil
	}

	// Clause 3: SECRET DISCLOSURE. If the call payload's disclosure_class
	// matches any class the tool lists as "must not be disclosed without
	// per-call approval," trip. Sub-agents (Phase 9) will exercise this;
	// the wiring lands now so the floor's shape is final.
	if fields.DisclosureClass != "" && len(perms.SecretClasses) > 0 {
		for _, cls := range perms.SecretClasses {
			if cls == fields.DisclosureClass {
				return true, FloorContext{
					Clause: "secret_disclosure",
					Detail: "disclosure_class=" + cls,
				}, nil
			}
		}
	}

	return false, FloorContext{}, nil
}
