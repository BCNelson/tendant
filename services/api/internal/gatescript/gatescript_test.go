package gatescript

import (
	"errors"
	"testing"
)

// --- manifest hashing + validation (pure Go) --------------------------------

func sampleManifest() Manifest {
	return Manifest{
		ManifestVersion: "1",
		Tool:            "tendant://tools/send-email",
		Entrypoint:      "evaluate",
		Reads:           []string{"call.args", "contacts"},
		Egress:          []string{},
		Limits:          ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}
}

func TestManifestHash_Deterministic(t *testing.T) {
	m := sampleManifest()
	h1, err := ManifestHash(m)
	if err != nil {
		t.Fatalf("hash: %v", err)
	}
	h2, err := ManifestHash(m)
	if err != nil {
		t.Fatalf("hash: %v", err)
	}
	if h1 != h2 {
		t.Fatalf("hash not deterministic: %s != %s", h1, h2)
	}
	if len(h1) != 64 {
		t.Fatalf("expected 64-hex-char sha256, got %d", len(h1))
	}
	// A different limit changes the hash.
	m2 := m
	m2.Limits.TimeoutMs = 500
	h3, _ := ManifestHash(m2)
	if h3 == h1 {
		t.Fatalf("hash collision across distinct manifests")
	}
}

func TestValidateManifest(t *testing.T) {
	c := DefaultCeilings()
	tool := "tendant://tools/send-email"

	cases := []struct {
		name    string
		mutate  func(*Manifest)
		wantOK  bool
		wantRsn RejectReason
	}{
		{"happy", func(*Manifest) {}, true, ""},
		{"bad version", func(m *Manifest) { m.ManifestVersion = "2" }, false, ReasonVersionUnsupported},
		{"bad entrypoint", func(m *Manifest) { m.Entrypoint = "main" }, false, ReasonMalformedManifest},
		{"egress not empty", func(m *Manifest) { m.Egress = []string{"external_fetch"} }, false, ReasonEgressNotEmpty},
		{"tool mismatch", func(m *Manifest) { m.Tool = "tendant://tools/other" }, false, ReasonToolMismatch},
		{"unknown capability", func(m *Manifest) { m.Reads = []string{"external_fetch"} }, false, ReasonUnknownCapability},
		{"timeout over ceiling", func(m *Manifest) { m.Limits.TimeoutMs = c.MaxTimeoutMs + 1 }, false, ReasonTimeoutExceeds},
		{"memory over ceiling", func(m *Manifest) { m.Limits.MemoryPages = c.MaxMemoryPages + 1 }, false, ReasonMemoryExceeds},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			m := sampleManifest()
			tc.mutate(&m)
			err := ValidateManifest(m, tool, c)
			if tc.wantOK {
				if err != nil {
					t.Fatalf("expected ok, got %v", err)
				}
				return
			}
			var re *RejectError
			if !errors.As(err, &re) {
				t.Fatalf("expected *RejectError, got %v", err)
			}
			if re.Reason != tc.wantRsn {
				t.Fatalf("reason: want %s got %s", tc.wantRsn, re.Reason)
			}
		})
	}
}

func TestEffectiveBounds_MinOfManifestAndCeiling(t *testing.T) {
	c := Ceilings{MaxTimeoutMs: 1000, MaxMemoryPages: 256}
	m := sampleManifest() // 250ms / 64 pages
	if got := m.EffectiveTimeoutMs(c); got != 250 {
		t.Fatalf("timeout: want 250 got %d", got)
	}
	if got := m.EffectiveMemoryPages(c); got != 64 {
		t.Fatalf("memory: want 64 got %d", got)
	}
	// An over-permissive manifest is clamped to the ceiling.
	m.Limits.TimeoutMs = 99999
	if got := m.EffectiveTimeoutMs(c); got != 1000 {
		t.Fatalf("timeout clamp: want 1000 got %d", got)
	}
}

// --- WASM walker (pure Go) --------------------------------------------------

// wasm byte-builders for hand-constructing minimal valid modules.
func leb128(n uint32) []byte {
	var out []byte
	for {
		b := byte(n & 0x7F)
		n >>= 7
		if n != 0 {
			out = append(out, b|0x80)
		} else {
			out = append(out, b)
			return out
		}
	}
}

func wasmName(s string) []byte { return append(leb128(uint32(len(s))), []byte(s)...) }

func section(id byte, body []byte) []byte {
	return append(append([]byte{id}, leb128(uint32(len(body)))...), body...)
}

var wasmHeader = []byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00}

// buildModule assembles a module with one func import (tendant.<imp>) and one
// func export named <exp>.
func buildModule(imp, exp string) []byte {
	// import section: count=1; module, name, kind=func(0x00), typeidx=0
	var importBody []byte
	importBody = append(importBody, leb128(1)...)
	importBody = append(importBody, wasmName("tendant")...)
	importBody = append(importBody, wasmName(imp)...)
	importBody = append(importBody, 0x00)         // extFunc
	importBody = append(importBody, leb128(0)...) // typeidx

	// export section: count=1; name, kind=func(0x00), idx=0
	var exportBody []byte
	exportBody = append(exportBody, leb128(1)...)
	exportBody = append(exportBody, wasmName(exp)...)
	exportBody = append(exportBody, 0x00)         // extFunc
	exportBody = append(exportBody, leb128(0)...) // funcidx

	out := append([]byte{}, wasmHeader...)
	out = append(out, section(2, importBody)...)
	out = append(out, section(7, exportBody)...)
	return out
}

func TestInspect_ImportsAndExports(t *testing.T) {
	mod := buildModule("contacts.isKnown", "evaluate")
	shape, err := Inspect(mod)
	if err != nil {
		t.Fatalf("inspect: %v", err)
	}
	if len(shape.Imports) != 1 || shape.Imports[0].Module != "tendant" || shape.Imports[0].Name != "contacts.isKnown" {
		t.Fatalf("imports: %+v", shape.Imports)
	}
	if shape.Imports[0].Kind != extFunc {
		t.Fatalf("import kind: %x", shape.Imports[0].Kind)
	}
	if len(shape.Exports) != 1 || shape.Exports[0].Name != "evaluate" {
		t.Fatalf("exports: %+v", shape.Exports)
	}
}

func TestInspect_RejectsMalformed(t *testing.T) {
	cases := []struct {
		name string
		in   []byte
	}{
		{"empty", nil},
		{"bad magic", []byte{0x01, 0x02, 0x03, 0x04, 0x01, 0x00, 0x00, 0x00}},
		{"bad version", []byte{0x00, 0x61, 0x73, 0x6D, 0x99, 0x00, 0x00, 0x00}},
		{"truncated section", append(append([]byte{}, wasmHeader...), 0x02, 0x7F)}, // import section claims 127 bytes
		{"header only is ok-empty", wasmHeader},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			_, err := Inspect(tc.in)
			if tc.name == "header only is ok-empty" {
				if err != nil {
					t.Fatalf("header-only module should parse, got %v", err)
				}
				return
			}
			if err == nil {
				t.Fatalf("expected error for %s", tc.name)
			}
		})
	}
}
