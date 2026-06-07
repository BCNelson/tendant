package gatescript

import "fmt"

// validate.go is the shared static-validation pipeline for both authoring tiers
// (FR-010 – FR-013). It is the property that lets us claim — structurally, not
// probabilistically — that a script cannot reach a capability it did not
// declare. The import-section walk runs BEFORE the module is ever instantiated;
// an undeclared import is rejected without being run.
//
// v1HostFunctions is the complete set of (module="tendant") function names the
// host implements. An import naming anything else fails undeclared_import.
var v1HostFunctions = func() map[string]bool {
	m := map[string]bool{"log": true}
	for fn := range hostFnToRead {
		m[fn] = true
	}
	return m
}()

// allowedExportFuncs is the set of function names a module may export (FR-011 +
// abi.md "forbidden exports"). Exactly one must be "evaluate"; the two memory-
// management functions are permitted; any other exported function is rejected.
var allowedExportFuncs = map[string]bool{
	"evaluate":        true,
	"tendant_alloc":   true,
	"tendant_dealloc": true,
}

// ValidateModule runs the full static pipeline on a candidate (wasm, manifest)
// for a target tool. It performs NO I/O and NEVER instantiates the module. A
// failure is a *RejectError carrying the structured reason for the audit row +
// GraphQL error. Order matches plan.md §Architectural shape.
func ValidateModule(wasm []byte, m Manifest, toolGlobalURI string, c Ceilings) error {
	// Grammar + ceilings (manifest-only checks).
	if err := ValidateManifest(m, toolGlobalURI, c); err != nil {
		return err
	}

	// Size cap (FR-012).
	if len(wasm) > c.MaxModuleBytes {
		return reject(ReasonModuleTooLarge,
			fmt.Sprintf("module is %d bytes, max is %d", len(wasm), c.MaxModuleBytes),
			map[string]any{"actual_bytes": len(wasm), "max_bytes": c.MaxModuleBytes})
	}

	// Parse the import + export sections defensively.
	shape, err := Inspect(wasm)
	if err != nil {
		return reject(ReasonMalformedManifest, "wasm parse: "+err.Error(), nil)
	}

	// Build the granted-capability set from the manifest.
	granted := make(map[string]bool, len(m.Reads))
	for _, r := range m.Reads {
		granted[r] = true
	}

	// Import-section walk: every imported function must be a v1 host function in
	// module "tendant", AND (unless it is the always-available log sink) covered
	// by manifest.reads. Anything else is rejected — including WASI and `env`.
	for _, imp := range shape.Imports {
		if imp.Kind != extFunc {
			// Only function imports are part of the host ABI; a table/memory/
			// global import is not something the host provides.
			return reject(ReasonUndeclaredImport,
				fmt.Sprintf("non-function import %q.%q", imp.Module, imp.Name),
				map[string]any{"rejected_import": imp.Module + "." + imp.Name})
		}
		if imp.Module != HostModule || !v1HostFunctions[imp.Name] {
			return reject(ReasonUndeclaredImport,
				fmt.Sprintf("import %q.%q is not a v1 host function", imp.Module, imp.Name),
				map[string]any{"rejected_import": imp.Module + "." + imp.Name, "allowed": m.Reads})
		}
		if alwaysAllowedHostFns[imp.Name] {
			continue // log requires no reads entry
		}
		readCap := hostFnToRead[imp.Name]
		if !granted[readCap] {
			return reject(ReasonUndeclaredImport,
				fmt.Sprintf("import %q.%q requires reads %q, not declared", imp.Module, imp.Name, readCap),
				map[string]any{"rejected_import": imp.Module + "." + imp.Name, "required_read": readCap, "allowed": m.Reads})
		}
	}

	// Export-section walk: exactly one exported function named "evaluate"; the
	// only other permitted function exports are the memory-management pair. A
	// memory export is allowed (any name). Any other function export → mismatch.
	evaluateCount := 0
	for _, exp := range shape.Exports {
		if exp.Kind != extFunc {
			continue // memory / table / global exports are allowed
		}
		if exp.Name == "evaluate" {
			evaluateCount++
			continue
		}
		if !allowedExportFuncs[exp.Name] {
			return reject(ReasonEntrypointMismatch,
				fmt.Sprintf("unexpected exported function %q (only evaluate + memory-management exports allowed)", exp.Name),
				map[string]any{"unexpected_export": exp.Name})
		}
	}
	if evaluateCount != 1 {
		return reject(ReasonEntrypointMismatch,
			fmt.Sprintf("module must export exactly one function named evaluate, found %d", evaluateCount), nil)
	}

	return nil
}
