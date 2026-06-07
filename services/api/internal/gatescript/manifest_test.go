package gatescript

import (
	"errors"
	"testing"
)

// validationModule hand-builds a module with only import + export sections —
// enough for ValidateModule (which inspects sections, never instantiates).
// imports is a list of {module, name}; exportFuncs is the exported function
// names; a memory export is always included.
func validationModule(imports [][2]string, exportFuncs []string) []byte {
	var impBody []byte
	for _, im := range imports {
		impBody = append(impBody, name(im[0])...)
		impBody = append(impBody, name(im[1])...)
		impBody = append(impBody, 0x00)       // func import kind
		impBody = append(impBody, uLEB(0)...) // typeidx 0
	}
	impSec := sec(2, vec(len(imports), impBody))

	var expBody []byte
	count := 1
	expBody = append(expBody, name("memory")...)
	expBody = append(expBody, 0x02, 0x00) // memory export, idx 0
	for i, fn := range exportFuncs {
		expBody = append(expBody, name(fn)...)
		expBody = append(expBody, 0x00)               // func export kind
		expBody = append(expBody, uLEB(uint64(i))...) // func idx
		count++
	}
	expSec := sec(7, vec(count, expBody))

	return concat(moduleHeader, impSec, expSec)
}

var stdExports = []string{"evaluate", "tendant_alloc", "tendant_dealloc"}

// TestValidateModule_NFR002 enumerates every static-validation rejection reason
// plus the happy path. This is the load-bearing security test (NFR-002 / SC-003).
func TestValidateModule_NFR002(t *testing.T) {
	tool := "tendant://tools/send-email"
	base := func() Manifest {
		return Manifest{
			ManifestVersion: "1", Tool: tool, Entrypoint: "evaluate",
			Reads: []string{"contacts"}, Egress: []string{},
			Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
		}
	}

	cases := []struct {
		name     string
		wasm     []byte
		manifest Manifest
		ceilings Ceilings
		wantOK   bool
		wantRsn  RejectReason
	}{
		{
			name:     "happy: granted import, std exports",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: base(), ceilings: DefaultCeilings(), wantOK: true,
		},
		{
			name:     "happy: log needs no reads entry",
			wasm:     validationModule([][2]string{{"tendant", "log"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Reads = []string{}; return m }(),
			ceilings: DefaultCeilings(), wantOK: true,
		},
		{
			name:     "undeclared_import: external_fetch is not a v1 host fn",
			wasm:     validationModule([][2]string{{"tendant", "external_fetch"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Reads = []string{"call.args"}; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonUndeclaredImport,
		},
		{
			name:     "undeclared_import: granted-set does not cover the import",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Reads = []string{"call.args"}; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonUndeclaredImport,
		},
		{
			name:     "undeclared_import: WASI is forbidden",
			wasm:     validationModule([][2]string{{"wasi_snapshot_preview1", "fd_write"}}, stdExports),
			manifest: base(), ceilings: DefaultCeilings(), wantRsn: ReasonUndeclaredImport,
		},
		{
			name:     "undeclared_import: env module is forbidden",
			wasm:     validationModule([][2]string{{"env", "abort"}}, stdExports),
			manifest: base(), ceilings: DefaultCeilings(), wantRsn: ReasonUndeclaredImport,
		},
		{
			name:     "entrypoint_mismatch: an extra exported function",
			wasm:     validationModule(nil, []string{"evaluate", "tendant_alloc", "tendant_dealloc", "sneaky"}),
			manifest: base(), ceilings: DefaultCeilings(), wantRsn: ReasonEntrypointMismatch,
		},
		{
			name:     "entrypoint_mismatch: no evaluate export",
			wasm:     validationModule(nil, []string{"tendant_alloc", "tendant_dealloc"}),
			manifest: base(), ceilings: DefaultCeilings(), wantRsn: ReasonEntrypointMismatch,
		},
		{
			name:     "module_too_large",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: base(),
			ceilings: func() Ceilings { c := DefaultCeilings(); c.MaxModuleBytes = 8; return c }(),
			wantRsn:  ReasonModuleTooLarge,
		},
		{
			name:     "tool_mismatch",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Tool = "tendant://tools/other"; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonToolMismatch,
		},
		{
			name:     "unknown_capability",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Reads = []string{"bogus"}; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonUnknownCapability,
		},
		{
			name:     "manifest_version_unsupported",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.ManifestVersion = "2"; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonVersionUnsupported,
		},
		{
			name:     "egress_not_empty",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Egress = []string{"external_fetch"}; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonEgressNotEmpty,
		},
		{
			name:     "timeout_exceeds_ceiling",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Limits.TimeoutMs = 99999; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonTimeoutExceeds,
		},
		{
			name:     "memory_exceeds_ceiling",
			wasm:     validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports),
			manifest: func() Manifest { m := base(); m.Limits.MemoryPages = 99999; return m }(),
			ceilings: DefaultCeilings(), wantRsn: ReasonMemoryExceeds,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			err := ValidateModule(tc.wasm, tc.manifest, tool, tc.ceilings)
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
				t.Fatalf("reason: want %s got %s (%s)", tc.wantRsn, re.Reason, re.Message)
			}
		})
	}
}
