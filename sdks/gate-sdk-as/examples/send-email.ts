// send-email.ts — the canonical example gate script (AssemblyScript / Tier 1).
//
// Policy: unknown recipient → ask the owner; body mentions money → hand off to
// the overseer; otherwise approve. Compile with:
//
//   npx asc examples/send-email.ts --target release --use abort= --use Date.now=
//
// or upload the source directly via compileAndAttachGateScript.

import { call, contacts, verdict, Verdict } from "../assembly/index";

// Re-export the ABI memory-management functions from the ENTRY module so asc
// emits them as WASM exports (asc only exports the entry file's exports, and
// the host needs tendant_alloc to hand call.get()/owner.rule()/etc. data to the
// guest). Every gate-script entry must include this line.
export { tendant_alloc, tendant_dealloc } from "../assembly/index";

// A tiny field extractor — the concrete call is {tool_global_uri, payload, ...}.
// A production SDK ships a JSON reader; this keeps the example dependency-free.
function field(json: string, key: string): string {
  const needle = "\"" + key + "\":\"";
  const i = json.indexOf(needle);
  if (i < 0) return "";
  const start = i + needle.length;
  const end = json.indexOf("\"", start);
  if (end < 0) return "";
  return json.substring(start, end);
}

export function evaluate(): Verdict {
  const c = call.get();
  const to = field(c, "to");
  if (!contacts.isKnown(to)) {
    return verdict.requestDecision("recipient " + to + " is not a known contact");
  }
  const body = field(c, "body");
  if (body.includes("$")) {
    return verdict.agentHandoff("message mentions money — overseer should weigh it");
  }
  return verdict.approve();
}
