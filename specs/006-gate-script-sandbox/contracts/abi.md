# Gate-Script WASM ABI v1

The host-guest calling convention every Tendant gate script targets. Stable for `manifest_version: "1"`. Bumping the manifest version is the only path to a breaking ABI change.

The wire shape is **pointer/length over linear memory**, compatible with the Extism PDK convention (we do not depend on Extism, but compatibility means a future migration is mechanical).

## Module / function namespace

All host functions live in the WASM import module **`tendant`**. The host walks the WASM import section before instantiation and rejects any module whose imports name an `(module, name)` pair the v1 host does not implement, OR whose `manifest.reads` does not cover the import. See `manifest.v1.json` for the `reads` ↔ host-function mapping.

## Memory model

The guest exports a WASM memory instance (per Extism PDK convention; the AssemblyScript and Rust SDKs do this automatically). The host reads guest memory via wazero's `Memory.Read(offset, length)` and writes via `Memory.Write(offset, []byte)`.

The guest exports two memory-management functions (the SDKs hide these):

```
(func $tendant_alloc (param $size i32) (result i32))   ;; returns ptr
(func $tendant_dealloc (param $ptr i32) (param $size i32))
```

The host calls `tendant_alloc` to write input into the guest before each host-function return; the guest calls `tendant_dealloc` after consuming the input (or the SDK does on its behalf).

## Entrypoint

The guest exports exactly one function with this signature:

```
(func $evaluate (result i64))
```

The returned `i64` is a packed `(ptr, len)` — high 32 bits are the pointer into linear memory, low 32 bits are the byte length. The host reads `len` bytes from `ptr`, parses as JSON, and unmarshals into `ScriptVerdict`.

If `evaluate` traps, exceeds the timeout, or returns malformed JSON, the runner converts to `ScriptVerdict{Decision: AgentHandoff, FailureReason: …}` per FR-007.

## Verdict JSON shape

The bytes pointed to by the `evaluate` return are UTF-8 JSON of this shape:

```json
{
  "decision": "approve" | "deny" | "request_decision" | "agent_handoff",
  "evidence": {
    "summary": "string (≤ 512 bytes after UTF-8 truncation)",
    "considered_fields": ["string", ...]
  }
}
```

- `decision` MUST be one of the four enum values. Any other value is `malformed_return`.
- `evidence.summary` is the human-readable reason text. The host length-caps it at 512 UTF-8 bytes (extra is silently truncated to keep the audit row bounded).
- `evidence.considered_fields` lists the payload field paths the script weighed. Bounded at 32 entries; extra silently dropped.

The host does NOT read any other fields. SDKs are free to include extra fields for forward-compat; v1 host ignores them.

## Host functions (v1)

All host functions are read-only, side-effect-free (except `log`), and bounded by the per-call execution timeout. A host-function error (Postgres timeout, connection drop) traps the script per FR-007 (the runner converts to `fail_closed_host_error`).

### `call.get() -> (ptr, len)` — read

Requires `manifest.reads` contains `"call.args"`.

Returns the concrete tool call as JSON via the pointer/length convention. The host writes the JSON into a fresh guest allocation; the guest is responsible for `tendant_dealloc` after consuming it.

```json
{
  "tool_global_uri": "tendant://tools/send-email",
  "payload": { ... },          // the original ToolCall.Payload, byte-for-byte
  "proposer_global_uri": "tendant://principals/owner"
}
```

### `contacts.isKnown(addr_ptr: i32, addr_len: i32) -> i32` — read

Requires `manifest.reads` contains `"contacts"`.

Returns `1` if `addr` matches a `principals.global_uri` OR an address in a prior `tool_outcomes(outcome=clean)` row for any of this owner's tools. Returns `0` otherwise. Address validation errors return `0` (per FR-015 — "false is the safe default").

### `calendar.query(window_start_ptr: i32, window_start_len: i32, window_end_ptr: i32, window_end_len: i32) -> (ptr, len)` — read

Requires `manifest.reads` contains `"calendar"`.

The `window_start` and `window_end` arguments are RFC 3339 timestamps. The host **clamps** the window to `[now, now + TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS)` (30 days default) per FR-016 — out-of-range bounds are silently truncated, not errored.

Returns a JSON array of `{start: rfc3339, end: rfc3339, title: string}` triples:

```json
[
  { "start": "2026-06-01T09:00:00Z", "end": "2026-06-01T10:00:00Z", "title": "1:1" }
]
```

### `task.context(key_ptr: i32, key_len: i32) -> (ptr, len)` — read

Requires `manifest.reads` contains `"task.context"`.

Returns the value of the named key from the current task's `tasks.context jsonb` map. Unknown keys return an empty `(ptr=0, len=0)` (per FR-017 — "null").

### `owner.rule(key_ptr: i32, key_len: i32) -> (ptr, len)` — read

Requires `manifest.reads` contains `"owner.rule"`.

Returns the value of the named owner rule from the `owner_rules` table, keyed `(owner_global_uri, key)`. Unknown keys return an empty `(ptr=0, len=0)`.

### `log(msg_ptr: i32, msg_len: i32) -> ()` — sink

Always available; **does NOT require a `manifest.reads` entry** (per FR-019 — "bounded sink, not a read").

Appends `msg` (truncated to 256 UTF-8 bytes) to the per-run hostcall trace. The trace is capped at 64 entries; subsequent `log` calls are silently dropped (per FR-019). The trace surfaces in `ScriptVerdict.Evidence.HostcallTrace` and is recorded in the `gate_script_evaluated` audit row.

## Forbidden imports

A script's WASM import section may name **only** the v1 host functions above, in module `tendant`. Anything else — WASI (`wasi_snapshot_preview1`), the asc-runtime (`env`), or any host function not in the manifest's `reads` — fails static validation at upload with `INVALID_MANIFEST(reason: "undeclared_import" | "unknown_capability")`.

The WASM **`env`** module (commonly imported by emitted AssemblyScript code for `abort`, `console.log`, `Date.now`) is **not** supported. The Tendant AssemblyScript SDK compiles with `--use abort=` and `--use Date.now=` flags so emitted modules do not reference `env`. Tier-2 BYO authors must match this discipline.

## Forbidden exports

A script's WASM export section MUST contain:

- exactly one **function** exported as `evaluate` with signature `() -> i64`;
- the memory and the two memory-management functions (`tendant_alloc`, `tendant_dealloc`).

Any other exported function fails static validation with `INVALID_MANIFEST(reason: "entrypoint_mismatch")`.

## SDK quickstarts

### AssemblyScript (`@tendant/gate-sdk` ≥ 0.1.0)

```ts
import { call, contacts, verdict, Verdict } from "@tendant/gate-sdk";

export function evaluate(): Verdict {
  const c = call.get();
  const to = c.args.getString("to");
  if (!contacts.isKnown(to)) {
    return verdict.requestDecision(`recipient ${to} is not a known contact`);
  }
  if (c.args.getString("body").includes("$")) {
    return verdict.agentHandoff("message mentions money — overseer should weigh it");
  }
  return verdict.approve();
}
```

Build: `npx asc assembly/index.ts --target release --use abort= --use Date.now=`. Or upload `assembly/index.ts` directly via `compileAndAttachGateScript`.

### Rust (`tendant-gate-sdk` ≥ 0.1.0)

```rust
use tendant_gate_sdk::{call, contacts, Verdict};

#[no_mangle]
pub extern "C" fn evaluate() -> Verdict {
    let c = call::get();
    let to = c.args.get_string("to");
    if !contacts::is_known(&to) {
        return Verdict::request_decision(format!("unknown recipient {to}"));
    }
    if c.args.get_string("body").contains('$') {
        return Verdict::agent_handoff("mentions money");
    }
    Verdict::approve()
}
```

Build: `cargo build --target wasm32-unknown-unknown --release`. Upload `target/wasm32-unknown-unknown/release/<crate>.wasm` via `attachGateScript`.

## Versioning

This document describes ABI **v1** (`manifest_version: "1"`). A breaking change — adding a host-function signature, changing the verdict JSON shape, dropping a memory-management function — requires:

1. Bumping `manifest_version` to `"2"` in `manifest.v1.json` → `manifest.v2.json`.
2. Updating the host to accept both v1 and v2 manifests (transition period).
3. Deprecating v1 with a documented sunset window per the Phase-2 contract-versioning policy.

Additive changes — new host functions behind new `reads` entries — are minor (no version bump); existing v1 scripts continue to work because they did not declare the new `reads` entry and so do not import it.
