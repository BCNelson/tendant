# tendant-gate-sdk (Rust)

Author **Tendant gate scripts** in Rust — sandboxed, read-only, bounded WASM that inspects a pending graded tool call and returns one of four terminal verdicts.

```rust
use tendant_gate_sdk::{call, contacts, verdict, Verdict};

#[no_mangle]
pub extern "C" fn evaluate() -> Verdict {
    let c = call::get();
    if !contacts::is_known(&field(&c, "to")) {
        return verdict::request_decision("unknown recipient");
    }
    if field(&c, "body").contains('$') {
        return verdict::agent_handoff("mentions money");
    }
    verdict::approve()
}
```

## Add the dep

```sh
cargo add tendant-gate-sdk@^0.1
```

## Verdicts

`verdict::approve()`, `verdict::deny(reason)`, `verdict::request_decision(reason)`, `verdict::agent_handoff(reason)`.

`approve` is **advisory** — the hard-rule floor sits above every script and downgrades a floor-tripping call to `request_decision` regardless of what you return.

## Host functions (read-only)

`call::get()`, `contacts::is_known(addr)`, `calendar::query(start, end)`, `task::context(key)`, `owner::rule(key)`, `log(msg)`.

Each (except `log`) must appear in your manifest's `reads` array — an undeclared import is rejected at upload, before the module runs.

## Build & upload

```sh
cargo build --target wasm32-unknown-unknown --release
# upload target/wasm32-unknown-unknown/release/<crate>.wasm via attachGateScript
```

## ABI

See `specs/006-gate-script-sandbox/contracts/abi.md`. The crate hides the pointer/length marshalling and the `tendant_alloc`/`tendant_dealloc`/`evaluate` exports.
