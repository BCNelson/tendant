// @tendant/gate-sdk — AssemblyScript SDK for authoring Tendant gate scripts.
//
// A gate script is sandboxed, read-only, bounded WASM that inspects a pending
// graded tool call and returns one of four terminal verdicts. This SDK provides
// typed wrappers for the six read-only host functions and the four verdict
// constructors. Compile with `--use abort= --use Date.now=` so the emitted
// module does not import the `env` module (rejected by static validation).

import { writeString, readString, unpackPtr, unpackLen, pack } from "./abi";

export { tendant_alloc, tendant_dealloc } from "./abi";

// --- Host imports (module "tendant") ---------------------------------------

// @ts-ignore: decorator
@external("tendant", "call.get")
declare function host_call_get(): u64;
// @ts-ignore: decorator
@external("tendant", "contacts.isKnown")
declare function host_contacts_isKnown(ptr: u32, len: u32): u32;
// @ts-ignore: decorator
@external("tendant", "calendar.query")
declare function host_calendar_query(sPtr: u32, sLen: u32, ePtr: u32, eLen: u32): u64;
// @ts-ignore: decorator
@external("tendant", "task.context")
declare function host_task_context(ptr: u32, len: u32): u64;
// @ts-ignore: decorator
@external("tendant", "owner.rule")
declare function host_owner_rule(ptr: u32, len: u32): u64;
// @ts-ignore: decorator
@external("tendant", "log")
declare function host_log(ptr: u32, len: u32): void;

// readPacked materializes a host (ptr,len) return into a string.
function readPacked(packed: u64): string {
  return readString(unpackPtr(packed), unpackLen(packed));
}

function callHostStr(fn: (p: u32, l: u32) => u64, arg: string): string {
  const packed = writeString(arg);
  return readPacked(fn(unpackPtr(packed), unpackLen(packed)));
}

// --- Typed host-function wrappers ------------------------------------------

export namespace call {
  // get returns the raw concrete-call JSON: {tool_global_uri, payload, proposer_global_uri}.
  export function get(): string { return readPacked(host_call_get()); }
}

export namespace contacts {
  export function isKnown(addr: string): bool {
    const p = writeString(addr);
    return host_contacts_isKnown(unpackPtr(p), unpackLen(p)) == 1;
  }
}

export namespace calendar {
  // query returns a JSON array of {start,end,title}. The window is clamped by the host.
  export function query(windowStart: string, windowEnd: string): string {
    const s = writeString(windowStart);
    const e = writeString(windowEnd);
    return readPacked(host_calendar_query(unpackPtr(s), unpackLen(s), unpackPtr(e), unpackLen(e)));
  }
}

export namespace task {
  // context returns the value of a task-context key, or "" when unset.
  export function context(key: string): string { return callHostStr(host_task_context, key); }
}

export namespace owner {
  // rule returns an owner-authored rule value, or "" when unset.
  export function rule(key: string): string { return callHostStr(host_owner_rule, key); }
}

export function log(msg: string): void {
  const p = writeString(msg);
  host_log(unpackPtr(p), unpackLen(p));
}

// --- Verdicts ---------------------------------------------------------------
//
// Verdict is the packed (ptr,len) i64 the exported evaluate() returns. The four
// constructors serialize the verdict JSON into guest memory and return the pack.

export type Verdict = u64;

function escapeJSON(s: string): string {
  return s.replaceAll("\\", "\\\\").replaceAll("\"", "\\\"").replaceAll("\n", "\\n");
}

function emit(decision: string, summary: string): Verdict {
  const json = "{\"decision\":\"" + decision + "\",\"evidence\":{\"summary\":\"" +
    escapeJSON(summary) + "\",\"considered_fields\":[]}}";
  return writeString(json);
}

export namespace verdict {
  // approve is advisory — the floor sits above it; safe to return for benign calls.
  export function approve(): Verdict { return emit("approve", "ok"); }
  // deny is terminal — the gate denies dispatch (records denied_by_script).
  export function deny(reason: string): Verdict { return emit("deny", reason); }
  // requestDecision asks the owner to decide; the overseer is NOT consulted.
  export function requestDecision(reason: string): Verdict { return emit("request_decision", reason); }
  // agentHandoff falls through to the overseer with this summary as evidence.
  export function agentHandoff(reason: string): Verdict { return emit("agent_handoff", reason); }
}

// help the unused-import checker / re-export pack for advanced authors.
export { pack };
