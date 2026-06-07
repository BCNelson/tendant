//! tendant-gate-sdk — Rust SDK for authoring Tendant gate scripts.
//!
//! A gate script is sandboxed, read-only, bounded WASM that inspects a pending
//! graded tool call and returns one of four terminal verdicts. This crate
//! provides typed wrappers for the six read-only host functions and the four
//! verdict constructors. Build for `wasm32-unknown-unknown`:
//!
//! ```sh
//! cargo build --target wasm32-unknown-unknown --release
//! ```

pub mod abi;

use abi::{read_packed, unpack_len, unpack_ptr, write_string};

// --- Host imports (module "tendant") ---------------------------------------

#[link(wasm_import_module = "tendant")]
extern "C" {
    #[link_name = "call.get"]
    fn host_call_get() -> u64;
    #[link_name = "contacts.isKnown"]
    fn host_contacts_is_known(ptr: u32, len: u32) -> u32;
    #[link_name = "calendar.query"]
    fn host_calendar_query(s_ptr: u32, s_len: u32, e_ptr: u32, e_len: u32) -> u64;
    #[link_name = "task.context"]
    fn host_task_context(ptr: u32, len: u32) -> u64;
    #[link_name = "owner.rule"]
    fn host_owner_rule(ptr: u32, len: u32) -> u64;
    #[link_name = "log"]
    fn host_log(ptr: u32, len: u32);
}

fn call_host_str(f: unsafe extern "C" fn(u32, u32) -> u64, arg: &str) -> String {
    let p = write_string(arg);
    unsafe { read_packed(f(unpack_ptr(p), unpack_len(p))) }
}

// --- Typed host-function wrappers ------------------------------------------

pub mod call {
    use super::*;
    /// The concrete-call JSON: `{tool_global_uri, payload, proposer_global_uri}`.
    pub fn get() -> String {
        unsafe { read_packed(host_call_get()) }
    }
}

pub mod contacts {
    use super::*;
    pub fn is_known(addr: &str) -> bool {
        let p = write_string(addr);
        unsafe { host_contacts_is_known(unpack_ptr(p), unpack_len(p)) == 1 }
    }
}

pub mod calendar {
    use super::*;
    /// A JSON array of `{start,end,title}`. The window is clamped by the host.
    pub fn query(window_start: &str, window_end: &str) -> String {
        let s = write_string(window_start);
        let e = write_string(window_end);
        unsafe {
            read_packed(host_calendar_query(
                unpack_ptr(s),
                unpack_len(s),
                unpack_ptr(e),
                unpack_len(e),
            ))
        }
    }
}

pub mod task {
    use super::*;
    /// The value of a task-context key, or "" when unset.
    pub fn context(key: &str) -> String {
        call_host_str(host_task_context, key)
    }
}

pub mod owner {
    use super::*;
    /// An owner-authored rule value, or "" when unset.
    pub fn rule(key: &str) -> String {
        call_host_str(host_owner_rule, key)
    }
}

pub fn log(msg: &str) {
    let p = write_string(msg);
    unsafe { host_log(unpack_ptr(p), unpack_len(p)) }
}

// --- Verdicts ---------------------------------------------------------------

/// Verdict is the packed (ptr,len) i64 the exported `evaluate` returns. The four
/// constructors serialize the verdict JSON into guest memory and return the pack.
pub type Verdict = u64;

fn escape_json(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\\"").replace('\n', "\\n")
}

fn emit(decision: &str, summary: &str) -> Verdict {
    let json = format!(
        "{{\"decision\":\"{}\",\"evidence\":{{\"summary\":\"{}\",\"considered_fields\":[]}}}}",
        decision,
        escape_json(summary)
    );
    write_string(&json)
}

/// Verdict constructors. Idiomatic Rust naming per FR-044.
pub struct VerdictBuilder;

impl VerdictBuilder {
    pub fn approve() -> Verdict {
        emit("approve", "ok")
    }
    pub fn deny(reason: &str) -> Verdict {
        emit("deny", reason)
    }
    pub fn request_decision(reason: &str) -> Verdict {
        emit("request_decision", reason)
    }
    pub fn agent_handoff(reason: &str) -> Verdict {
        emit("agent_handoff", reason)
    }
}

// Convenience free functions mirroring the AssemblyScript `verdict.*` namespace.
pub mod verdict {
    use super::{Verdict, VerdictBuilder};
    pub fn approve() -> Verdict {
        VerdictBuilder::approve()
    }
    pub fn deny(reason: &str) -> Verdict {
        VerdictBuilder::deny(reason)
    }
    pub fn request_decision(reason: &str) -> Verdict {
        VerdictBuilder::request_decision(reason)
    }
    pub fn agent_handoff(reason: &str) -> Verdict {
        VerdictBuilder::agent_handoff(reason)
    }
}
