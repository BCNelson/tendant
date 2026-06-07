package gatescript

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/require"
)

// validate_more_test.go covers the nuanced ValidateModule paths beyond the
// NFR-002 rejection table: the manifest-is-an-upper-bound semantics, the
// always-allowed log sink, and the export-contract corner cases.

func baseManifestFor(tool string, reads ...string) Manifest {
	if reads == nil {
		reads = []string{}
	}
	return Manifest{
		ManifestVersion: "1", Tool: tool, Entrypoint: "evaluate",
		Reads: reads, Egress: []string{},
		Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}
}

const tool = "tendant://tools/send-email"

func TestValidateModule_LogNeedsNoReads(t *testing.T) {
	// log is a bounded sink — importable with an empty reads set.
	wasm := validationModule([][2]string{{"tendant", "log"}}, stdExports)
	require.NoError(t, ValidateModule(wasm, baseManifestFor(tool), tool, DefaultCeilings()))
}

func TestValidateModule_ManifestIsUpperBound(t *testing.T) {
	// A module that imports FEWER host functions than the manifest grants is
	// accepted — reads is a ceiling, not an equality (US3 scenario 3).
	wasm := validationModule([][2]string{{"tendant", "contacts.isKnown"}}, stdExports)
	m := baseManifestFor(tool, "call.args", "contacts", "owner.rule")
	require.NoError(t, ValidateModule(wasm, m, tool, DefaultCeilings()))
}

func TestValidateModule_NonFunctionImportRejected(t *testing.T) {
	// A table/memory/global import (even from the tendant module) is not part of
	// the host ABI → undeclared_import. Build an import section by hand with a
	// memory import.
	memImport := concat(name("tendant"), name("mem"), []byte{0x02, 0x00, 0x01})
	importSec := sec(2, vec(1, memImport))
	exportSec := sec(7, vec(4, concat(
		name("memory"), []byte{0x02, 0x00},
		name("evaluate"), []byte{0x00}, uLEB(0),
		name("tendant_alloc"), []byte{0x00}, uLEB(1),
		name("tendant_dealloc"), []byte{0x00}, uLEB(2),
	)))
	wasm := concat(moduleHeader, importSec, exportSec)

	err := ValidateModule(wasm, baseManifestFor(tool), tool, DefaultCeilings())
	var re *RejectError
	require.ErrorAs(t, err, &re)
	require.Equal(t, ReasonUndeclaredImport, re.Reason)
}

func TestValidateModule_ExportContract(t *testing.T) {
	cases := []struct {
		name        string
		exportFuncs []string
		wantOK      bool
		wantRsn     RejectReason
	}{
		{"exactly one evaluate + mem mgmt", stdExports, true, ""},
		{"evaluate only (no mem mgmt) is allowed", []string{"evaluate"}, true, ""},
		{"two evaluate exports", []string{"evaluate", "evaluate"}, false, ReasonEntrypointMismatch},
		{"no evaluate export", []string{"tendant_alloc", "tendant_dealloc"}, false, ReasonEntrypointMismatch},
		{"unexpected extra func export", append(append([]string{}, stdExports...), "sneaky"), false, ReasonEntrypointMismatch},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			wasm := validationModule(nil, tc.exportFuncs)
			err := ValidateModule(wasm, baseManifestFor(tool), tool, DefaultCeilings())
			if tc.wantOK {
				require.NoError(t, err)
				return
			}
			var re *RejectError
			require.True(t, errors.As(err, &re), "want *RejectError, got %v", err)
			require.Equal(t, tc.wantRsn, re.Reason)
		})
	}
}

func TestValidateModule_MemoryNamedEvaluateIsNotTheEntrypoint(t *testing.T) {
	// A MEMORY export named "evaluate" must NOT satisfy the function-entrypoint
	// requirement (the validator counts only function exports named evaluate).
	exportSec := sec(7, vec(1, concat(name("evaluate"), []byte{0x02, 0x00}))) // mem export named evaluate
	wasm := concat(moduleHeader, exportSec)
	err := ValidateModule(wasm, baseManifestFor(tool), tool, DefaultCeilings())
	var re *RejectError
	require.ErrorAs(t, err, &re)
	require.Equal(t, ReasonEntrypointMismatch, re.Reason)
}

func TestValidateModule_SizeCapBoundary(t *testing.T) {
	wasm := validationModule([][2]string{{"tendant", "log"}}, stdExports)
	c := DefaultCeilings()

	// Exactly at the cap: accepted.
	c.MaxModuleBytes = len(wasm)
	require.NoError(t, ValidateModule(wasm, baseManifestFor(tool), tool, c))

	// One byte under: rejected as module_too_large.
	c.MaxModuleBytes = len(wasm) - 1
	err := ValidateModule(wasm, baseManifestFor(tool), tool, c)
	var re *RejectError
	require.ErrorAs(t, err, &re)
	require.Equal(t, ReasonModuleTooLarge, re.Reason)
}
