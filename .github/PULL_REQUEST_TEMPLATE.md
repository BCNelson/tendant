## Summary

<!-- 1-3 bullet points describing what this PR changes and why. -->

## Test plan

- [ ] `just test` passes locally (Docker required for testcontainers)
- [ ] `just lint` passes
- [ ] Manual verification: <describe what you ran>

## Contract changes

If this PR touches any of the five long-lived versioned contracts
(`services/api/graph/schema.graphqls`, intake potential-task signal,
MCP tool contract, gate-script ABI/manifest, federation message
protocol), check exactly **one** path below per the
[contract-versioning policy](../specs/003-operator-edge-wake/contracts/versioning-policy.md):

- [ ] **Path 1 — Additive only** (new types/fields/enum values/optional arguments; no existing field renamed, removed, or retyped within this version).
- [ ] **Path 2 — Field deprecation** (`@deprecated(reason: "...")` directive added; the field remains functional for at least one minor release; removal lands in a *different* future PR).
- [ ] **Path 3 — Versioned endpoint** (breaking change that cannot be expressed additively; introduces a new versioned endpoint and keeps the old one available for the documented retirement window; requires explicit owner approval).
- [ ] **N/A** — this PR does not touch any of the five contracts.

Reviewers reject PRs that don't pick a path.
