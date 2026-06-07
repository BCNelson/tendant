package calibration

import (
	"encoding/json"
	"testing"

	"github.com/bcnelson/tendant/services/api/internal/tools"
)

const sendEmail = tools.SendEmailGlobalURI

func fp(payload string) string {
	return Fingerprint(sendEmail, json.RawMessage(payload))
}

func TestFingerprintEquivalentCallsShare(t *testing.T) {
	// Same recipient + no attachments; different subject/body → same routine.
	a := fp(`{"to":"known@friend.example","subject":"hi","body":"one"}`)
	b := fp(`{"to":"known@friend.example","subject":"different","body":"a much longer body"}`)
	if a != b {
		t.Fatalf("equivalent calls should share a fingerprint: %s != %s", a, b)
	}
	// Same domain, different known address → same routine (domain-level coarseness).
	c := fp(`{"to":"other@friend.example","subject":"hi","body":"x"}`)
	if a != c {
		t.Fatalf("same-domain recipients should share a fingerprint: %s != %s", a, c)
	}
}

func TestFingerprintStrangerRecipientDiffers(t *testing.T) {
	known := fp(`{"to":"known@friend.example","subject":"hi"}`)
	stranger := fp(`{"to":"someone@unknown.example","subject":"hi"}`)
	if known == stranger {
		t.Fatalf("a different-domain recipient must be a different routine")
	}
}

func TestFingerprintAttachmentDiffers(t *testing.T) {
	plain := fp(`{"to":"known@friend.example","subject":"hi"}`)
	withAtt := fp(`{"to":"known@friend.example","subject":"hi","attachments":["a.pdf"]}`)
	if plain == withAtt {
		t.Fatalf("adding an attachment must be a different routine")
	}
	emptyAtt := fp(`{"to":"known@friend.example","subject":"hi","attachments":[]}`)
	if plain != emptyAtt {
		t.Fatalf("an empty attachments array is not an attachment; should match plain")
	}
}

func TestFingerprintDeterministic(t *testing.T) {
	p := `{"to":"known@friend.example","subject":"hi","body":"x"}`
	first := fp(p)
	for i := 0; i < 100; i++ {
		if fp(p) != first {
			t.Fatalf("fingerprint is not deterministic")
		}
	}
}

func TestFingerprintDefaultToolKeysPresenceOnly(t *testing.T) {
	const otherTool = "local://tool/other"
	// Same key set, different scalar values → same routine (values excluded).
	a := Fingerprint(otherTool, json.RawMessage(`{"x":1,"y":"foo"}`))
	b := Fingerprint(otherTool, json.RawMessage(`{"y":"bar","x":2}`))
	if a != b {
		t.Fatalf("default fingerprint should key on key-presence only: %s != %s", a, b)
	}
	// A different key set → different routine.
	c := Fingerprint(otherTool, json.RawMessage(`{"x":1,"z":3}`))
	if a == c {
		t.Fatalf("a different key set must differ")
	}
	// A different tool URI → different routine even with the same shape.
	if Fingerprint("local://tool/another", json.RawMessage(`{"x":1,"y":"foo"}`)) == a {
		t.Fatalf("different tool URI must differ")
	}
}
