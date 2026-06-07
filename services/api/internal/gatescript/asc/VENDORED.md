# Vendored AssemblyScript compiler (asc) — provenance & rebuild recipe

Tier-1 in-app authoring (`compileAndAttachGateScript`) compiles AssemblyScript
source to a gate-script `.wasm` **server-side, inside the same wazero sandbox
that runs gate scripts** (principle IX — the compiler is treated as untrusted
code too). To do that the server embeds two binary WASM assets:

| File | What | Version |
|---|---|---|
| `quickjs.wasm` | QuickJS JS engine compiled to WASM (WASI) | `2024-01-13` |
| `asc.wasm` | The AssemblyScript compiler bundle (`assemblyscript@0.27.31`) runnable on QuickJS | `0.27.31` |

## Status

**These binaries are NOT yet vendored in this checkout.** Until they are, the
Tier-1 server-compile path returns `COMPILE_FAILED` (`ErrASCUnavailable`); the
seam lives at `internal/gatescript/asc.go` (`CompileAssemblyScript` /
`SetASCCompiler`). The **Tier-2** path (`attachGateScript`, BYO `.wasm`) is fully
functional without these binaries — authors compile AssemblyScript or Rust
locally and upload the `.wasm`.

## Rebuild recipe (when adding the binaries)

```sh
# 1. QuickJS → WASM (WASI). Use the quickjs-ng build or the wasi-sdk port.
#    Pin the commit; record its SHA256 below.
#    Output: quickjs.wasm

# 2. Bundle asc to a single JS file, then run it under QuickJS to self-host.
npm i assemblyscript@0.27.31
npx esbuild node_modules/assemblyscript/dist/asc.js \
  --bundle --format=esm --platform=neutral --outfile=asc.bundle.js
#    Convert asc.bundle.js to a QuickJS-runnable module (qjsc) → asc.wasm

# 3. Drop quickjs.wasm + asc.wasm into this directory and record SHA256s:
sha256sum quickjs.wasm asc.wasm
```

## SHA256 (fill on vendoring)

```
quickjs.wasm  <sha256>
asc.wasm      <sha256>
```

CI MUST re-verify these SHA256s on every build, and the binaries MUST be
rebuilt+code-reviewed on every `asc` minor bump (FR-028). When present, wire the
real compiler with:

```go
// internal/gatescript/asc/sandbox.go
func init() { gatescript.SetASCCompiler(Compile) }   // Compile pipes source → quickjs+asc → wasm
```

The sandbox enforces its own bounds: `TENDANT_ASC_MAX_COMPILE_MS` (5000),
`TENDANT_ASC_MAX_MEMORY_PAGES` (2048); a compile exceeding either returns
`COMPILE_FAILED(reason: "sandbox_timeout" | "sandbox_memory_cap")`.
