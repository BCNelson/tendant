# Research: Phase 5 — Gate Scripts (the Untrusted-Code Surface)

## R1. WASM runtime — wazero, wasmtime-go, wasmer-go, or in-house?

**Decision**: `github.com/tetratelabs/wazero` v1.8.x (pinned). One new Go dep; justified in plan.md Constitution Check.

**Rationale**:
- **Pure Go, no CGo.** Phases 0–4 are CGo-free. Introducing CGo would break the project's `flake.nix`-based reproducible builds, the cross-compile story (`go build -C services/api`), and the static-binary container image. Principle-level constraint, not a preference.
- **Production-stable.** wazero v1.x has been used in production by Tailscale, InfluxDB, dapr's components, and many others. Tetrate actively maintains it; security advisories are handled via GitHub Security Advisories.
- **Sufficient for principle IX.** wazero supports the two resource bounds Phase 5 needs: execution-timeout via context cancellation (which closes the module), and linear-memory cap via `wazero.NewRuntimeConfig().WithMemoryLimitPages(N)`.
- **No fuel metering, by design.** Instruction-precise fuel metering would require CGo (wasmtime does it; wazero does not). The Phase-5 design accepts a wall-clock timeout as the only termination bound for bounded read-only scripts. This is explicit in the spec.
- **Embeds well into the existing Go server.** No process boundary, no IPC.

**Alternatives**:
- *`github.com/bytecodealliance/wasmtime-go`*: rejected — CGo wrapper of Bytecode Alliance's wasmtime. Would diverge from the existing pure-Go posture; would break the `flake.nix` build.
- *`github.com/wasmerio/wasmer-go`*: rejected — unmaintained (last meaningful commit 2024-Q1; security posture unclear).
- *In-house WASM interpreter*: rejected — months of work, sandbox surface far less hardened than wazero's, blast radius of a bug far higher.
- *Process-isolate via `os.exec` to a separate WASM-runner binary*: rejected — adds a process boundary, an IPC surface, and a binary deploy artifact for no security gain (wazero's sandbox is already the strong primitive).

## R2. WASM ABI — custom pointer/length, Extism Go SDK, or WASI?

**Decision**: A small (~200-LOC) custom ABI compatible with Extism's wire convention, built directly on top of `wazero`. No Extism Go SDK dependency. No WASI imports.

**Rationale**:
- **Extism Go SDK pulls wasmtime.** Extism's official Go host SDK (`github.com/extism/go-sdk`) defaults to wasmtime under the hood; the wazero backend is a secondary option and not the path Extism's docs emphasize. Pulling Extism would re-introduce CGo by default or require careful runtime-selection plumbing that's almost the same code as just writing the ABI directly.
- **The wire is tiny.** Pointer/length over linear memory is a 4-byte-pair calling convention. The host side allocates a region, writes input, calls `evaluate` (which returns a 64-bit packed `(ptr, len)` to the verdict JSON), then reads the verdict back. The host code is ~200 LOC; equivalent guest-side code is what `sdks/gate-sdk-as/abi.ts` and `sdks/gate-sdk-rust/src/abi.rs` provide.
- **Extism wire compatibility.** Keeping the wire compatible means future migration to the Extism SDK (if it matures with a first-class wazero backend) is mechanical. We do not depend on Extism; we are *compatible* with it.
- **No WASI.** WASI brings filesystem and clock host functions in by default. The spec demands deny-by-default capabilities. The simplest way to satisfy that is to never instantiate WASI imports — the host wires exactly the six host functions per FR-014–FR-019, plus the `log` sink, and nothing else.

**Alternatives**:
- *`github.com/extism/go-sdk`*: rejected for the CGo reason above; reconsider when Extism's wazero backend is the documented default.
- *WASI Preview 1*: rejected — admits filesystem/clock/random; the spec's deny-by-default capability model is incompatible with WASI's "everything-on" defaults.
- *Component Model*: rejected — wazero v1.x does not implement the Component Model in a stable way; v2 is forthcoming but not pinned. Too forward-looking for Phase 5.

## R3. AssemblyScript compiler hosting — vendored `asc` on QuickJS-on-wazero, native `asc`, or third-party API?

**Decision**: Vendor `asc.wasm` and `quickjs.wasm` as binary assets via `go:embed`; run them inside the same wazero runtime that runs gate scripts. `asc` is the AssemblyScript compiler bundle; QuickJS is the JS engine that runs `asc` (which is itself a JS program). Both are compiled to WASM ahead of vendoring; the in-tree build recipe (`VENDORED.md`) makes the artifacts reproducible.

**Rationale**:
- **Treat the compiler as untrusted code under the same discipline.** Principle IX says untrusted code runs sandboxed. `asc` is JS code from the AssemblyScript project; QuickJS is a JS engine. Both are vetted, but the cheapest way to remove them as a trust risk is to put them in the same wazero sandbox the gate scripts live in. The compiler input (source) crosses the sandbox boundary inward; the compiler output (`.wasm` + diagnostics) crosses outward; nothing else.
- **No new Go dep.** The compiler is a binary asset, not a Go module. `go:embed` pulls it into the binary at build time.
- **Reproducible.** The `asc-vN-quickjs-vM` build recipe in `VENDORED.md` produces byte-identical artifacts. CI verifies SHA256.
- **Bounded by its own caps.** The asc-sandbox enforces `TENDANT_ASC_MAX_COMPILE_MS` (5000 default) and `TENDANT_ASC_MAX_MEMORY_PAGES` (2048 default) — generous enough for the example script (~150 ms / ~30 MB resident) and small enough to fence a runaway compile.

**Alternatives**:
- *Native `asc` via Node.js subprocess*: rejected — adds a Node runtime to the deploy artifact, fights the static-binary container image story, introduces a process boundary, and circumvents principle IX (the compiler would not be sandboxed by wazero).
- *Third-party compile API (paid SaaS)*: rejected — adds an external dependency on the critical path; would leak owner source code off-premise; would charge per compile.
- *Pre-compile AssemblyScript source at the client (Flutter)*: rejected — the spec says "server-side compile from source is the artifact of record" because a client-submitted binary is never trusted for untrusted authors. Client-side compile would defeat the whole property.
- *Javy / QuickJS-in-WASM for direct TypeScript authoring*: deferred. The spec lists this as a future Tier-3 if AssemblyScript's TS-gap proves too sharp for authors. Phase 5 monitors author friction; it does not preempt the fallback.

## R4. Manifest canonicalization — JCS, sorted-keys, or hash-of-raw-bytes?

**Decision**: Pure-Go canonical JSON: sorted keys, no whitespace, no escaping beyond what `encoding/json` does by default, RFC 8785-shaped subset. Implementation in `internal/gatescript/manifest.go` is ~50 LOC; no JCS library dep.

**Rationale**:
- **Hashing the raw bytes would let formatting differences (whitespace, key order) produce different hashes for semantically-identical manifests.** That would defeat the audit-row claim that `manifest_hash` identifies a manifest.
- **Manifest has no float fields.** RFC 8785's hardest case (float canonicalization) does not apply to Phase 5 manifests, so the implementation is straightforward.
- **Stdlib-only.** `encoding/json` + a small key-sorter via a custom `MarshalJSON` pass. No new dep.
- **Compatible with future strictness.** If a future capability adds a float field, we adopt a JCS-compliant float serializer at that point; the framing of canonicalization is already in place.

**Alternatives**:
- *Use `github.com/gibson042/canonicaljson-go` or similar JCS library*: rejected — new dep for a 50-LOC problem.
- *Hash the raw bytes*: rejected — semantic stability matters more than implementation simplicity here.
- *Hash a Go-struct round-trip via `encoding/gob`*: rejected — gob is not stable across Go versions, and is not language-portable (a Rust author cannot reproduce the hash from outside the host).

## R5. Audit `task_id` strategy — nullable + CHECK, sentinel UUID, separate table, or slog-only?

**Decision**: Migration 00005 relaxes `audit_messages.task_id` to nullable AND adds a `CHECK` constraint admitting NULL only for the four new owner-scoped kinds (`gate_script_rejected`, `gate_script_attached`, `gate_script_disabled`, `owner_rule_set`). Decision recorded in spec Q3; here we document the rejected alternatives.

**Rationale**:
- Keeps the audit DAG as the **single trust backbone** (principle VI). Calibration queries (Phase 8) and observability stay on one table.
- Preserves the per-task `NOT NULL` invariant for all prior kinds via the CHECK. Future audit kinds that *should* be task-scoped will fail-loudly until added to the CHECK; this is intended (fail-loud beats silent drift).
- Owner-scoped events become queryable alongside per-task events with a single index pattern (`audit_messages` ordered by `at`).

**Alternatives**:
- *Sentinel UUID (all-zeros) meaning "owner-scope"*: rejected — sentinels age poorly. Every consumer must remember to filter; a forgotten filter silently mis-attributes an owner event to a synthetic task.
- *Parallel `owner_audit_messages` table*: rejected — forks the audit DAG. Every calibration / observability query would have to UNION two tables. The schema delta is heavier and the carrying cost is higher.
- *slog only, no audit row*: rejected — rejection-of-untrusted-upload is exactly the kind of security-relevant event the audit DAG should preserve. slog is not queryable post-facto without external machinery.

## R6. `.wasm` blob storage — Postgres `bytea`, S3-compatible, or local-disk-+-pointer?

**Decision**: Postgres `bytea` column on `gate_scripts.wasm`.

**Rationale**:
- **Postgres-only constraint** (Technology Constraints). Adding S3/MinIO/etc. would require a constitutional amendment.
- Size is bounded by `TENDANT_GATESCRIPT_MAX_MODULE_BYTES` (1 MiB default) — well within bytea's comfort zone (Postgres handles bytea cleanly up to ~1 GB per row; the TOAST'd storage path is fine at 1 MiB).
- Single transaction with `audit_messages` write — no two-phase commit between blob store and metadata.
- Backups are unified: `pg_dump` captures everything.

**Alternatives**:
- *Object storage (S3, MinIO)*: rejected — violates Postgres-only constraint.
- *Local-disk path + pointer in DB*: rejected — splits durability between filesystem and DB; backups become custom; ephemeral container filesystems make the design unsound.
- *Postgres Large Objects (`lo`)*: rejected — `bytea` is simpler at this size; `lo` is for objects > 100 MB.

## R7. wazero module compile cache strategy

**Decision**: A single per-process `wazero.CompilationCache` injected into the `wazero.Runtime` at boot. Keyed by `manifest_hash` (deterministic across attaches of identical bytes). Stored in memory; not persisted across restarts.

**Rationale**:
- **wazero compile is the per-call hot path.** Without caching, every `proposeToolCall` would pay ~20 ms compiling the same module. With caching, first call pays ~20 ms; subsequent calls instantiate from the cached compiled module in ~5 ms.
- **Per-process is fine.** A deploy restarts the cache; the first few calls after deploy bump p95, but the cache warms quickly and steady-state behaviour returns. Acceptable trade.
- **Memory-bounded.** Cache is bounded by `TENDANT_GATESCRIPT_COMPILE_CACHE_MB` (default 256). LRU eviction.

**Alternatives**:
- *No cache*: rejected — would make every call expensive and miss NFR-001 instantiation target.
- *Filesystem-backed cache*: deferred. wazero supports this via `CompilationCacheWithDir`. Phase 5 ships the in-memory variant; a future operational tuning can opt into filesystem persistence to skip the post-deploy warm-up.
- *Per-script lifetime instantiate-once*: rejected — wazero's per-call instantiation is the safety pattern (a fresh linear memory per call prevents cross-call state leaks); we should not optimize that away.

## R8. Host-function error semantics — trap, safe-default, or typed error?

**Decision**: Trap the script via wazero context cancellation; runner returns `ScriptVerdict{Decision: AgentHandoff, RanToCompletion: false, FailureReason: "host_error"}` and the gate falls through to the overseer with `ScriptEvidence = nil`. Decision recorded in spec Q4.

**Rationale**:
- **A host-side error is operationally indistinguishable from infrastructure unreliability** (DB drop, Postgres SQLSTATE 53, connection pool exhaustion). Surfacing it to the script as a legitimate empty read would conflate "this contact does not exist" with "we don't know whether this contact exists."
- The same fail-open-to-overseer path FR-007 already defines for timeouts and memory caps; treating host errors identically means one runner code path covers all script-runtime failures.
- The `gate_script_evaluated` audit row records the host module + name + Postgres SQLSTATE for observability (FR-035 extended), so the operations team can see *why* the trap happened without the script having to handle it.

**Alternatives**:
- *Safe-default return (false / null / empty)*: rejected per Q4 — biases toward `RequestDecision` (conservatively OK), but masks the real failure from observability and makes the script's verdict logic harder to reason about.
- *Typed error to script via a per-call error code*: rejected — pushes infra-error handling into untrusted script code, exactly where it shouldn't be. Multiplies author cognitive load with zero safety benefit.

## R9. Resumable / suspending scripts — why not?

**Decision**: Phase-5 scripts are bounded run-to-completion classifiers; they MUST NOT suspend or resume. All unbounded waiting happens in the surrounding gate workflow *after* the script returns.

**Rationale**:
- **Durability is a property of the gate, not the script.** The gate is a DBOS workflow; it can replay. The script is non-durable inside it (FR-006) — host calls are not memoized as DBOS steps. A resumable script would have to be promoted to a DBOS workflow itself, with all the engine-side bookkeeping that implies.
- **Resumable scripts would let a community module hold a workflow open indefinitely.** A buggy or hostile resumable script could starve the gate. Bounded run-to-completion makes that class of bug impossible.
- **The four terminal verdicts are a strict subset of any resumable design.** Adding resumability later, if a real use case appears, is a strict superset that does not break v1 scripts.

**Alternatives**:
- *DBOS-backed resumable scripts*: deferred. The gate workflow already provides everything resumable scripts would need; if branch-on-the-human script logic is ever needed, the design becomes "the script returns a `BranchOnHuman` verdict carrying script state; the workflow waits; on wake, the script re-runs with the state and the human's answer." Out of scope.

## R10. SDK distribution — in-repo only, in-repo + published, or spec-stub?

**Decision**: In-repo at `sdks/gate-sdk-as/` and `sdks/gate-sdk-rust/`, AND published to npm (`@tendant/gate-sdk`) and crates.io (`tendant-gate-sdk`). Initial published version `0.1.0`. CI release workflow publishes on `gate-sdk-v*` tags. Decision recorded in spec Q1.

**Rationale**:
- Tier-2 BYO `.wasm` authors need to import the SDK to write a real script; without public publishing the BYO story is documentation-only and Story 7 is not end-to-end demonstrable.
- The SDK is small (~300 LOC AS, ~250 LOC Rust). Versioning machinery is light: semver pinned at `0.1.0` initial; SDK minor/patch bumps are independent of `manifest_version` (`"1"`).
- In-repo presence lets the SDK evolve lockstep with the host (a host-side host-function signature change is the same PR as the SDK-side wrapper change).
- The asc-sandbox bundles the npm package at the pinned version, so Tier-1 authors are insulated from npm at runtime.

**Alternatives**:
- *In-repo only, no public publishing*: rejected — would block Tier 2's external author story.
- *Spec-stub only, full SDK deferred to Phase 10*: rejected — would defeat the SC-007 Tier-2 round-trip exit criterion.

## R11. Postgres trigger for `gate_scripts` append-only

**Decision**: A `BEFORE UPDATE` trigger on `gate_scripts` rejecting any UPDATE that touches a column other than `status`. Implementation:

```sql
CREATE OR REPLACE FUNCTION gate_scripts_block_immutable_columns()
RETURNS trigger AS $$
BEGIN
  IF NEW.tool_id      IS DISTINCT FROM OLD.tool_id      OR
     NEW.version      IS DISTINCT FROM OLD.version      OR
     NEW.manifest     IS DISTINCT FROM OLD.manifest     OR
     NEW.manifest_hash IS DISTINCT FROM OLD.manifest_hash OR
     NEW.wasm         IS DISTINCT FROM OLD.wasm         OR
     NEW.source       IS DISTINCT FROM OLD.source       OR
     NEW.tier         IS DISTINCT FROM OLD.tier         OR
     NEW.attached_by_principal IS DISTINCT FROM OLD.attached_by_principal OR
     NEW.attached_at  IS DISTINCT FROM OLD.attached_at  OR
     NEW.id           IS DISTINCT FROM OLD.id
  THEN
    RAISE EXCEPTION 'gate_scripts rows are append-only modulo status; column update rejected';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Rationale**:
- **Schema-enforced append-only, not convention-enforced** (FR-025 demands this). A trigger means even a manual SQL edit at the prompt cannot quietly mutate a stored module's bytes after evaluation — preserves the audit invariant that every past `gate_script_evaluated` row is reproducible against the exact bytes it ran.
- **Lets the `status` column flip** for `disableGateScript` (FR-024); everything else is locked.
- **Future migrations that recreate `gate_scripts` must re-create the trigger.** Migration 00005's SQL leaves the trigger definition adjacent to the table definition; a `migrations/CONVENTIONS.md` note documents the requirement.

**Alternatives**:
- *Application-level enforcement (no trigger)*: rejected — convention-only, easy to violate by accident.
- *Row-level security policies*: rejected — RLS is for *who* can read/write, not *what* columns can change. Trigger is the right primitive.

## R12. Why no within-run read-snapshot consistency in v1?

For sub-second scripts a script's host calls during `evaluate()` read live data. A long-running script could, in theory, see `contacts.isKnown(addr)` flip mid-run if a write lands in the same window. Phase 5 does not promise within-run snapshot consistency.

**Rationale**:
- At sub-second script latencies (NFR-001 is 400 ms p95), the race window is small and the write rate is low — single-household deployments have minutes-between-writes, not concurrent writes.
- A `serializable` Postgres transaction wrapping the script would slow every call and serialize the entire gate.
- Phase-7 enrichment writes are not fast enough today to race; if they ever become so, a per-run read-snapshot is a future enhancement.

This is recorded as **Out of Scope** in the spec; the research note here is just to make the rationale persist for the future-enhancement decision.
