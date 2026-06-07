// Package ascsdk vendors the AssemblyScript gate-script SDK (the published
// @tendant/gate-sdk assembly sources) into the server binary so the Tier-1
// server-compile path (compileAndAttachGateScript) can make the SDK resolvable
// to `asc` without a network fetch — "the vendored asc compile pipeline bundles
// the SDK at the pinned version" (FR-043). Keep these in sync with
// sdks/gate-sdk-as/assembly/ on every SDK bump.
package ascsdk

import _ "embed"

//go:embed assembly/index.ts
var indexTS []byte

//go:embed assembly/abi.ts
var abiTS []byte

// Files returns the SDK module files keyed by their basename. The server writes
// them into a build directory as `tendant_gate_sdk/{index.ts,abi.ts}` and
// rewrites author imports of "@tendant/gate-sdk" to "./tendant_gate_sdk/index".
func Files() map[string][]byte {
	return map[string][]byte{
		"index.ts": indexTS,
		"abi.ts":   abiTS,
	}
}
