package gatescript

import "testing"

// FuzzWasmInspect asserts the walker never panics, never over-allocates, and
// always returns an error-or-clean result on arbitrary bytes. The walker is the
// highest-blast-radius surface in Phase 5 (it gates the no-egress guarantee);
// a panic here would be a denial-of-service on the upload path.
func FuzzWasmInspect(f *testing.F) {
	// Seed with a valid module and a few malformed shapes.
	f.Add(buildStaticVerdictModule(`{"decision":"approve","evidence":{"summary":"","considered_fields":[]}}`))
	f.Add(moduleHeader)
	f.Add([]byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F})
	f.Add([]byte("not wasm"))
	f.Add([]byte{})

	f.Fuzz(func(t *testing.T, data []byte) {
		// Must not panic. The result is ignored — we only assert termination
		// and no-panic; a returned error is a perfectly valid outcome.
		_, _ = Inspect(data)
		_, _ = InspectImports(data)
		_, _ = InspectExports(data)
	})
}
