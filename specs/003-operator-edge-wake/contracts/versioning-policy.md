# Tendant Contract-Versioning Policy

**Status**: Locked in Phase 2 (`specs/003-operator-edge-wake/spec.md`, Clarification Q1).
**Scope**: All five of tendant's long-lived versioned contracts.
**Authority**: This policy supersedes any ad-hoc convention; deviations require explicit owner approval.

---

## The five versioned contracts

This policy governs all of:

1. **Operator-edge GraphQL** (`services/api/graph/schema.graphqls`, anchored in `specs/003-operator-edge-wake/contracts/graphql.v1.graphqls`).
2. **Intake potential-task signal** (intake pipeline → core; lands in Phase 7).
3. **MCP tool contract** (core ↔ MCP tools; lands progressively from Phase 3).
4. **Gate-script ABI / manifest** (core ↔ WASM gate scripts; lands in Phase 3).
5. **Federation sub-agent message protocol** (local sub-agent ↔ remote household; lands in Phase 10+).

Alternative clients and community extensions target these contracts for years. Contract stability is a first-order concern (Principle VII, CC-2).

---

## The three change paths

Every proposed change MUST be classifiable into exactly one of three paths.

### Path 1 — Additive (the default)

Lands within the current version. No client breaks.

**Permitted**:
- New types, interfaces, unions, enums, scalars.
- New fields on existing types.
- New optional arguments on existing fields or mutations.
- New enum values *if* clients are required to handle unknown values gracefully (the contract MUST document this requirement).
- New union members *if* clients are required to handle unknown variants gracefully (same documentation requirement).
- New subscriptions, queries, mutations.

**Forbidden** (those are path 2 or 3):
- Renaming any existing symbol.
- Removing any existing symbol.
- Changing the type of any existing field or argument.
- Making an existing optional argument required.
- Making an existing nullable field non-nullable.

### Path 2 — Field deprecation

For retiring something. Lands within the current version *but* requires a window before removal.

**Procedure**:
1. **Announce**: mark the field/argument/enum value/type with `@deprecated(reason: "...")` (GraphQL native; for other contracts, add a documented deprecation marker). This is a path-1 additive change.
2. **Wait**: the deprecated symbol MUST remain functional for **at least one minor release** between the deprecation announcement and removal.
3. **Add the replacement** (if any) via path 1.
4. **Remove**: in a later release, delete the deprecated symbol. The removal commit MUST cite the deprecation commit and confirm the window has elapsed.

For non-GraphQL contracts (MCP, manifest, federation message), the deprecation marker is a documented field on the contract record (e.g., `"deprecated": true, "deprecation_reason": "...", "deprecated_since": "v1.3.0"`).

### Path 3 — Versioned endpoint

For changes that cannot be expressed as path 1 + path 2. **Rare, deliberate, owner-approved.**

**Procedure**:
1. Introduce a new versioned endpoint or contract artifact alongside the current one (e.g., `/graphql/v2`, `tool-contract-v2.proto`, `gate-script-abi-v2.wit`).
2. The new version MAY make breaking changes relative to the previous version.
3. The prior version MUST remain available for a **documented retirement window**, default **6 months from the new version's GA**.
4. Both versions ship the deprecation marker on the prior version's manifest entry (where applicable).
5. Removal of the prior version is itself a path-3 event and requires explicit owner approval at retirement time.

**Path-3 changes require**:
- An owner-approved RFC documenting why path 1 + path 2 was insufficient.
- A migration guide for clients.
- A test fixture demonstrating both versions running side-by-side during the retirement window.

---

## The PR checkbox

Every PR that touches one of the five contracts MUST state the path in the description:

```
Contract version path (choose one):
- [ ] Path 1 — Additive (no rename/remove/retype of existing symbols)
- [ ] Path 2 — Deprecation (adds @deprecated; cite future removal target)
- [ ] Path 3 — Versioned endpoint (cite owner-approved RFC)
```

A PR with neither box checked is incomplete. A PR that claims path 1 but in fact renames or removes a symbol is a process violation; the reviewer rejects it.

---

## Reviewer test

Given a proposed change `X` to one of the five contracts, the reviewer asks:

1. Does `X` add a new symbol without modifying any existing one? → **Path 1**.
2. Does `X` mark something as deprecated, without removing it yet? → **Path 1** (deprecation marker is itself additive metadata).
3. Does `X` remove a previously-deprecated symbol whose window has elapsed? → **Path 2**.
4. Does `X` rename, remove without prior deprecation, or break-retype an existing symbol? → **Path 3** (requires RFC + retirement window for the prior version).

Any uncertainty resolves to "ask the owner" — never "ship it and see."

---

## The pre-consumer carve-out (one-time)

A contract that has **not yet been consumed by any client** MAY accept a single non-additive change without invoking path 3, *iff* explicitly owner-approved at the time. This is the carve-out used for the `TaskState.ELIGIBLE → WAITING` rename in Phase 1 (recorded in `specs/002-task-lifecycle-chain/plan.md` Constitution Check row VII).

The carve-out is **strictly one-time per contract**: once *any* client has been observed to pull a contract, no further pre-consumer rename is permitted, even on previously-unused symbols within it. From the first pull onward, paths 1 / 2 / 3 are the only options.

---

## Reference from the contract source

Every contract source file MUST contain a comment header pointing to this policy. For the operator-edge GraphQL, `services/api/graph/schema.graphqls` opens with:

```graphql
# Tendant operator-edge GraphQL — v1.
# Versioning policy: ../../specs/003-operator-edge-wake/contracts/versioning-policy.md
```

For non-GraphQL contracts, an equivalent reference lives in the contract artifact's header or accompanying README.

---

## Living document — but not casually

This policy is itself versioned. Material amendments (anything that changes the meaning of paths 1 / 2 / 3, or removes the pre-consumer carve-out) require an owner-approved amendment commit, summarized in the `CLAUDE.md` change log and cited in the relevant `plan.md`. Clarifications and wording changes are unrestricted.

**Version**: 1.0.0 (initial — Phase 2). **Ratified**: 2026-05-28.
