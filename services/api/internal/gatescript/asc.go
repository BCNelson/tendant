package gatescript

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
)

// asc.go is the Tier-1 server-compile seam (FR-022/FR-026). Two backends plug in
// here via SetASCCompiler:
//
//   - Subprocess (asc_subprocess.go): shells out to the `asc` binary. Active when
//     the operator sets TENDANT_ASC_BACKEND=subprocess and `asc` is on PATH
//     (the devenv shell ships it). Functional and tested. NOT sandboxed — the
//     compiler runs as a host subprocess, so it is opt-in, not the default.
//   - Sandboxed asc-on-QuickJS-on-wazero (internal/gatescript/asc/): the
//     principle-IX-ideal that runs the compiler under the same wazero discipline
//     as gate scripts. Pending the vendored asc.wasm/quickjs.wasm binaries
//     (see asc/VENDORED.md) — this is the production-hardening target.
//
// With NO backend installed, this seam reports COMPILE_UNAVAILABLE so
// compileAndAttachGateScript fails loudly rather than silently. The Tier-2
// attachGateScript path (BYO .wasm) is fully functional regardless.

// Diag is one compiler diagnostic surfaced in the COMPILE_FAILED error payload.
type Diag struct {
	File     string `json:"file"`
	Line     int    `json:"line"`
	Col      int    `json:"col"`
	Severity string `json:"severity"`
	Msg      string `json:"msg"`
}

// ErrASCUnavailable is returned when the vendored asc compiler is not built into
// this binary (US6 vendoring pending).
var ErrASCUnavailable = errors.New("server-side AssemblyScript compile is unavailable in this build (asc binaries not vendored)")

// ascCompiler is the swappable backend. Defaults to the unavailable stub; US6
// replaces it with the wazero-hosted asc sandbox.
var ascCompiler func(ctx context.Context, source string) ([]byte, []Diag, error) = func(context.Context, string) ([]byte, []Diag, error) {
	return nil, nil, ErrASCUnavailable
}

// CompileAssemblyScript compiles AssemblyScript source to a gate-script `.wasm`.
func CompileAssemblyScript(ctx context.Context, source string) ([]byte, []Diag, error) {
	return ascCompiler(ctx, source)
}

// SetASCCompiler installs a real compiler backend (called from US6 wiring).
func SetASCCompiler(fn func(ctx context.Context, source string) ([]byte, []Diag, error)) {
	if fn != nil {
		ascCompiler = fn
	}
}

// SHA256Hex is the canonical sha256-hex used for source hashing in audit rows.
func SHA256Hex(b []byte) string {
	sum := sha256.Sum256(b)
	return hex.EncodeToString(sum[:])
}
