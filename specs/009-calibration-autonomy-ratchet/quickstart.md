# Quickstart: Calibration & the Earned-Autonomy Ratchet

Walks the five exit criteria. Assumes a running core (`make up`), an owner session, and the
Phase-3 `send-email` tool. Calibration knobs lowered for a fast demo:

```sh
export TENDANT_CALIBRATION_MATURATION=5s        # tiny veto window for the demo
export TENDANT_CALIBRATION_WINDOW_N=10
export TENDANT_CALIBRATION_RATIO=0.90
export TENDANT_CALIBRATION_MIN_SAMPLE=5
export TENDANT_CALIBRATION_DEMOTION_DECREMENT=0.25
export TENDANT_CALIBRATION_SWEEP_CRON="* * * * *"   # every minute
make up
```

---

## Exit 1 — A routine earns autonomy (owner-gated promotion)

1. Compose the **same floor-clearing routine** repeatedly — `send-email` to a **known contact**,
   no spend, no secret (so the floor never trips). Approve each as owner. Each completion records a
   `tool_outcomes` row `outcome=clean` with the routine fingerprint and `matured_at = at + 5s`.

   ```graphql
   mutation { proposeToolCall(taskId:"…", toolGlobalUri:"local://tool/send-email",
     payload:{ to:"known@friend.example", subject:"hi", body:"…" }) { id } }
   # …approveArtifact each…  (repeat ≥ MIN_SAMPLE=5, ≥ RATIO clean)
   ```

2. Wait `> 5s` (outcomes mature) and for the next sweep tick. The sweep finds the routine's
   matured-clean ratio ≥ 0.90 over the last 10 and emits a `PromotionProposal` into the inbox.

   ```graphql
   query { inbox(first:10) { __typename
     ... on PromotionProposal { id tool{ globalUri rung } fromLevel toLevel evidence } } }
   # evidence: { routine:"send-email → known contact", window_n:10, matured_clean:9, ratio:0.9, min_sample:5 }
   ```

3. Accept it (owner):

   ```graphql
   mutation { respondToPromotion(proposalId:"…", accept:true) { globalUri rung } }
   # → rung: EXECUTE_AUTO   (trust_score jumped into the auto band; a live grant exists for this routine)
   ```

4. Compose the **same routine** again → **auto-approves** (no pending decision created):

   ```graphql
   mutation { proposeToolCall(taskId:"…", toolGlobalUri:"local://tool/send-email",
     payload:{ to:"known@friend.example", subject:"again", body:"…" }) { id } }
   # dispatches without an ApprovalRequest; tool_outcome recorded clean
   ```

5. **Still floor-checked**: compose a variant that trips the floor (e.g. a spend, or a stranger
   recipient under `irreversible_third_party: stranger_recipient`) → an `ApprovalRequest` is created
   despite `EXECUTE_AUTO` (Exit 4).

---

## Exit 2 — One bad signal reflexively demotes (no proposal, no approval)

Any one of:

```graphql
# (a) owner flags a completed action
mutation { flagOutcome(taskId:"…", toolId:"…", reason:"wrong recipient") { rung } }   # → EXECUTE_GATED
# (b) owner cancels the task the tool acted under
mutation { cancelTask(taskId:"…") { id } }                                            # demotes each acting tool
# (c) the tool's dispatch errors  → a bad outcome is recorded → automatic demotion
```

Each immediately: `trust_score -= 0.25` (clamped at baseline 0.5 → drops out of `EXECUTE_AUTO`) and
**revokes the routine's grant**. No `PromotionProposal`, no approval. The same routine now gates
again. Verify via `Tool.rung` → `EXECUTE_GATED` and `taskChanged`.

---

## Exit 3 — Retroactive veto on an un-matured action stops it buying a rung

1. Record one clean outcome and **immediately** (within the 5s window, before `matured_at`) flag it:

   ```graphql
   mutation { flagOutcome(taskId:"…", toolId:"…", reason:"actually bad") { rung } }
   ```

2. The row flips `outcome → bad`, so the matured-clean predicate excludes it **forever**. Drive the
   sweep: the routine does **not** cross the threshold on that outcome's strength — no proposal is
   emitted. (Confirms the maturation window gives the veto time to land — FR-004.)

---

## Exit 4 — No track record beats the floor

With the routine at `EXECUTE_AUTO` (Exit 1), compose a clearly floor-tripping call:

```graphql
mutation { proposeToolCall(taskId:"…", toolGlobalUri:"local://tool/send-email",
  payload:{ to:"stranger@unknown.example", subject:"…", body:"…" }) { id } }
# floor clause irreversible_third_party=stranger_recipient TRIPS → ApprovalRequest, not auto-approve
```

The gate consults the floor **before** the autonomy band; no trust score auto-approves a
floor-tripping call (Constitution III / FR-011 / SC-004).

---

## Exit 5 — Intake dismissals tune what gets proposed (the intake half)

1. With a connector enabled (Phase 7), dismiss several proposed items from that source with reasons:

   ```graphql
   mutation { dismissProposedTask(taskId:"…", reason:"never relevant") { id } }   # ×N
   ```

2. The connector's **effective** thresholds tighten (higher confidence floor / lower stakes
   ceiling) as a function of recent dismissal count. A subsequent comparable `rich_event` that
   *previously* would have auto-accepted is now held `PROPOSED`.

3. For an ambiguous item routed to `llm_judge`, the triage stage receives the accumulated dismissal
   reasons as a labeled `[DISMISSAL_HISTORY]` section (weighed as evidence, never obeyed). Confirm
   the item is judged more skeptically (held/dismissed).

---

## Observability

```sh
curl -fsS localhost:8080/healthz | jq .calibration
# { "proposals_emitted_per_minute": …, "demotions_per_minute": …,
#   "outcomes_matured_per_minute": …, "maturation_window": "5s", "open_proposals": … }
```

## Self-escalation is impossible (Exit 1 corollary / US5)

As an **agent** (non-owner) principal, `respondToPromotion` is refused before any DB write:

```graphql
mutation { respondToPromotion(proposalId:"…", accept:true) { rung } }   # → PERMISSION_DENIED
```

Only the owner principal raises a rung. There is no other path (NFR-004).
