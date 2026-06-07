package calibration

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"sort"
	"strings"

	"github.com/bcnelson/tendant/services/api/internal/tools"
)

// Fingerprint is the deterministic, pure per-routine equivalence key (research
// R3). It is recorded on each tool_outcomes row and recomputed at gate time for
// auto-approval matching — so the two MUST agree for the same call. It depends
// ONLY on the tool URI and a per-tool *salient shape* of the payload, never on
// volatile text (subject/body) or external state.
//
// v1 salient mappings:
//
//   - send-email: recipient class (presence + domain) + attachment presence.
//     The recipient *domain* (not the full address, not the body/subject) is
//     coarse enough to accumulate a sample yet fine enough that a stranger at a
//     different domain — or an added attachment — is a DIFFERENT routine that
//     still gates. Keying on domain rather than identity keeps the floor's
//     stranger_recipient clause the backstop.
//   - default (other tools): the tool URI + the sorted set of top-level scalar
//     key *names* present (values excluded).
func Fingerprint(toolGlobalURI string, payload json.RawMessage) string {
	salient := salientShape(toolGlobalURI, payload)
	// Canonicalize: stable JSON of {tool, salient}. salient is built from
	// sorted keys so the encoding is deterministic.
	canonical, _ := json.Marshal(map[string]any{
		"tool":    toolGlobalURI,
		"salient": salient,
	})
	sum := sha256.Sum256(canonical)
	return hex.EncodeToString(sum[:8]) // 16 hex chars — ample for O(10s) routines/tool
}

// salientShape returns the per-tool salient field map. Built from sorted keys so
// json.Marshal is deterministic (Go maps marshal with sorted keys).
func salientShape(toolGlobalURI string, payload json.RawMessage) map[string]any {
	var m map[string]any
	if len(payload) > 0 {
		_ = json.Unmarshal(payload, &m)
	}
	if toolGlobalURI == tools.SendEmailGlobalURI {
		return sendEmailSalient(m)
	}
	return defaultSalient(m)
}

// sendEmailSalient keys on recipient presence + domain + attachment presence.
func sendEmailSalient(m map[string]any) map[string]any {
	recipient := stringField(m, "recipient")
	if recipient == "" {
		recipient = stringField(m, "to")
	}
	domain := ""
	hasRecipient := recipient != ""
	if at := strings.LastIndex(recipient, "@"); at >= 0 && at+1 < len(recipient) {
		domain = strings.ToLower(recipient[at+1:])
	}
	return map[string]any{
		"has_recipient":    hasRecipient,
		"recipient_domain": domain,
		"has_attachments":  hasAttachments(m),
	}
}

// defaultSalient = the sorted set of top-level scalar key names present (values
// excluded). Nested objects/arrays are noted by name only.
func defaultSalient(m map[string]any) map[string]any {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return map[string]any{"keys": keys}
}

func stringField(m map[string]any, key string) string {
	if v, ok := m[key].(string); ok {
		return v
	}
	return ""
}

// hasAttachments reports whether the payload carries a non-empty attachments
// field (array or object). A trivially-present-but-empty array counts as none.
func hasAttachments(m map[string]any) bool {
	for _, k := range []string{"attachments", "attachment"} {
		switch v := m[k].(type) {
		case []any:
			if len(v) > 0 {
				return true
			}
		case map[string]any:
			if len(v) > 0 {
				return true
			}
		case string:
			if v != "" {
				return true
			}
		}
	}
	return false
}
