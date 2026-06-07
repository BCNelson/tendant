//! send-email.rs — the canonical example gate script (Rust / Tier 2).
//!
//! Policy: unknown recipient → ask the owner; body mentions money → hand off to
//! the overseer; otherwise approve. Build:
//!
//!   cargo build --target wasm32-unknown-unknown --release --example send-email
//!
//! then upload the produced .wasm via attachGateScript.

use tendant_gate_sdk::{call, contacts, verdict, Verdict};

// A tiny field extractor — the concrete call is {tool_global_uri, payload, ...}.
fn field(json: &str, key: &str) -> String {
    let needle = format!("\"{}\":\"", key);
    if let Some(i) = json.find(&needle) {
        let start = i + needle.len();
        if let Some(end) = json[start..].find('"') {
            return json[start..start + end].to_string();
        }
    }
    String::new()
}

#[no_mangle]
pub extern "C" fn evaluate() -> Verdict {
    let c = call::get();
    let to = field(&c, "to");
    if !contacts::is_known(&to) {
        return verdict::request_decision(&format!("recipient {to} is not a known contact"));
    }
    if field(&c, "body").contains('$') {
        return verdict::agent_handoff("message mentions money — overseer should weigh it");
    }
    verdict::approve()
}
