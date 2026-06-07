# @tendant/gate-sdk (AssemblyScript)

Author **Tendant gate scripts** — sandboxed, read-only, bounded WASM that inspects a pending graded tool call and returns one of four terminal verdicts.

```ts
import { call, contacts, verdict, Verdict } from "@tendant/gate-sdk";

export function evaluate(): Verdict {
  const c = call.get();
  if (!contacts.isKnown(field(c, "to"))) return verdict.requestDecision("unknown recipient");
  if (field(c, "body").includes("$")) return verdict.agentHandoff("mentions money");
  return verdict.approve();
}
```

## Verdicts

| Constructor | Meaning |
|---|---|
| `verdict.approve()` | Advisory approve — the hard-rule floor still sits above you. |
| `verdict.deny(reason)` | Terminal — the gate denies dispatch. |
| `verdict.requestDecision(reason)` | Ask the owner; the overseer is not consulted. |
| `verdict.agentHandoff(reason)` | Fall through to the overseer with `reason` as evidence. |

## Host functions (read-only)

`call.get()`, `contacts.isKnown(addr)`, `calendar.query(start, end)`, `task.context(key)`, `owner.rule(key)`, `log(msg)`.

Each (except `log`) must be declared in your manifest's `reads` array — see `contracts/manifest.v1.json`. An undeclared import is rejected at upload, before the module is ever run.

## Required: re-export the memory functions

`asc` only emits the **entry file's** exports, and the host needs `tendant_alloc`
to hand `call.get()` / `owner.rule()` / etc. data to your script. So every gate
script entry must include:

```ts
export { tendant_alloc, tendant_dealloc } from "@tendant/gate-sdk";
```

(The in-app `compileAndAttachGateScript` pipeline appends this for you.)

## Building

```sh
npx asc assembly/index.ts --target release --use abort= --use Date.now= -o gate.wasm
```

The `--use abort= --use Date.now=` flags keep the emitted module from importing the `env` module (rejected by static validation). Or skip the local build entirely and upload the source via `compileAndAttachGateScript`.

## ABI

See `specs/006-gate-script-sandbox/contracts/abi.md`. The SDK hides the pointer/length marshalling and the `tendant_alloc`/`tendant_dealloc`/`evaluate` exports.
