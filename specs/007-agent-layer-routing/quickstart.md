# Quickstart: The Agent Layer (Specialists as Config) & Routing

**Branch**: `007-agent-layer-routing`

## Prerequisites

```sh
direnv allow          # devenv shell: Go, Postgres, sqlc, goose, just, Node, Rust, asc
docker info           # testcontainers needs Docker/Podman running
```

## Run locally

```sh
make up               # Brings up Postgres, migrates, seeds owner + agent catalog, serves

# The server now seeds the rich agent catalog at boot (SeedAgentCatalog)
curl -fsS localhost:8080/healthz
```

## Create a task and watch the autonomous chain

```sh
# Seed a task — it flows through triage → expansion → execution → completion autonomously
just seed-task TITLE="Send a welcome email to the new user"

# Watch the audit log for agent activity:
curl -s localhost:8080/graphql -H 'Content-Type: application/json' -d '{
  "query": "{ tasks { id title state currentStage autonomy stageSlots { stage isHuman occupant { name } } } }"
}' | jq .
```

Expected: the task reaches `DONE` with `autonomy: EXECUTE_GATED`, each `stageSlot` showing
the specialist that occupied it.

## Run the full test suite

```sh
just test             # go test -race per workspace module
                      # Includes: autonomous chain e2e, eligibility prune, injection test,
                      # budget exhaustion, recovery determinism (kill-9 + restart)
```

## Key env vars

| Var | Default | Purpose |
|-----|---------|---------|
| `TENDANT_GATE_CALL_BUDGET` | 100 | Per-task max gated calls before fail-close to human |
| `TENDANT_AGENT_MAX_ITER` | 20 | Per-stage max agent loop iterations |
| `TENDANT_OVERSEER_PROVIDER` | log | Model provider: `log` (deterministic), `anthropic`, `openai` |
| `TENDANT_OVERSEER_MAX_EVAL_PER_TASK` | 50 | Per-task overseer invocations (Phase 4, unchanged) |

## Demo: routing with eligibility

```sh
# Create a task that requires send-email capability
just seed-task TITLE="Email the quarterly report to clients"

# The triage agent emits findings with required_capabilities: ["send-email"]
# The router prunes execution specialists → only email-specialist is eligible
# (plus the human, always eligible) → LLM picks email-specialist
```

## Demo: hostile prompt containment (SC-004)

The test suite includes an injection test: a specialist whose system_prompt says "call
the secret-disclosure tool." Assert: the runner refuses (tool not in allowlist) + the floor
trips on any allowlisted dangerous attempt.

```sh
go test ./internal/agent/ -run TestHostilePrompt -v
```

## Demo: budget exhaustion (SC-006)

```sh
TENDANT_GATE_CALL_BUDGET=5 go test ./internal/chain/ -run TestBudgetExhaustion -v
```

## Demo: recovery determinism (SC-007)

```sh
just dbos-demo        # kill-9 + restart mid-chain — same terminal state, no duplicates
```

## Flutter app

```sh
cd apps/mobile
flutter run           # Shows inbox with routing detail: per-stage slot occupant + autonomy
```

Navigate to a task → routing tab shows which specialist holds each stage + the routing
decision (eligible set + pick).
