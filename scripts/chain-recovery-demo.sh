#!/usr/bin/env bash
# Phase 1 chain recovery proof (US3 / FR-011 / SC-003). Brings up the
# tendant core, creates a task via the createTask GraphQL mutation, waits
# until the TRIAGE assignment is open, kill -9's the process, brings the
# core back up, then completeTasks the assignment and asserts the chain
# advanced exactly once.
#
# Prereqs: Postgres reachable via $DATABASE_URL; the binary in this repo
# must build (`just build`).

set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "DATABASE_URL is not set" >&2
    exit 2
fi

LOG1=$(mktemp -t chain-recovery-run1.XXXXXX)
LOG2=$(mktemp -t chain-recovery-run2.XXXXXX)
trap 'rm -f "$LOG1" "$LOG2"' EXIT

CORE="go run ./services/api/cmd/tendant"
GRAPHQL="http://localhost:8080/graphql"

graphql_post() {
    # $1 = json body
    curl -fsS -X POST -H 'Content-Type: application/json' -d "$1" "$GRAPHQL"
}

# Apply migrations once before either run.
echo "=== applying migrations + seeding (run 0) ==="
go run ./services/api/cmd/tendant seed -title="recovery-seed" >/dev/null
echo "(migrations + owner seed done)"

echo "=== run 1: start core, create task, pause on TRIAGE, kill -9 ==="
$CORE >"$LOG1" 2>&1 &
PID=$!

# Wait for healthz.
TIMEOUT=20
WAITED=0
until curl -fsS http://localhost:8080/healthz >/dev/null 2>&1; do
    sleep 0.5
    WAITED=$((WAITED + 1))
    if (( WAITED > TIMEOUT * 2 )); then
        echo "FAIL: run 1 healthz never came up" >&2
        kill -9 "$PID" 2>/dev/null || true
        cat "$LOG1"
        exit 1
    fi
done

# Create a task.
TASK_RESPONSE=$(graphql_post '{"query":"mutation { createTask(title: \"recovery demo\") { id state currentStage } }"}')
TASK_ID=$(echo "$TASK_RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
if [[ -z "$TASK_ID" ]]; then
    echo "FAIL: createTask did not return an id: $TASK_RESPONSE" >&2
    kill -9 "$PID" 2>/dev/null || true
    cat "$LOG1"
    exit 1
fi
echo "task_id=$TASK_ID"

# Poll until openAssignment.stage == TRIAGE.
WAITED=0
while true; do
    STAGE_RESP=$(graphql_post "{\"query\":\"query { task(id: \\\"$TASK_ID\\\") { openAssignment { stage id } } }\"}")
    if echo "$STAGE_RESP" | grep -q '"stage":"TRIAGE"'; then
        break
    fi
    sleep 0.5
    WAITED=$((WAITED + 1))
    if (( WAITED > 30 )); then
        echo "FAIL: TRIAGE assignment never opened: $STAGE_RESP" >&2
        kill -9 "$PID" 2>/dev/null || true
        cat "$LOG1"
        exit 1
    fi
done

ASSIGNMENT_ID_BEFORE=$(echo "$STAGE_RESP" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
echo "triage assignment_id=$ASSIGNMENT_ID_BEFORE"

# kill -9 the process — no chance for graceful shutdown.
kill -9 "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
echo "(run 1 killed)"

echo "=== run 2: restart core, expect recovery, advance chain ==="
$CORE >"$LOG2" 2>&1 &
PID2=$!

WAITED=0
until curl -fsS http://localhost:8080/healthz >/dev/null 2>&1; do
    sleep 0.5
    WAITED=$((WAITED + 1))
    if (( WAITED > 40 )); then
        echo "FAIL: run 2 healthz never came up" >&2
        kill -9 "$PID2" 2>/dev/null || true
        cat "$LOG2"
        exit 1
    fi
done

# Verify the assignment row is the SAME id.
STAGE_RESP2=$(graphql_post "{\"query\":\"query { task(id: \\\"$TASK_ID\\\") { openAssignment { stage id } } }\"}")
ASSIGNMENT_ID_AFTER=$(echo "$STAGE_RESP2" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
if [[ "$ASSIGNMENT_ID_BEFORE" != "$ASSIGNMENT_ID_AFTER" ]]; then
    echo "FAIL: recovery created a new assignment (before=$ASSIGNMENT_ID_BEFORE after=$ASSIGNMENT_ID_AFTER)" >&2
    kill -9 "$PID2" 2>/dev/null || true
    cat "$LOG2"
    exit 1
fi
echo "(same assignment_id survived restart)"

# Give the recovered Recv a moment to settle before sending.
sleep 1

# Resolve the slot. The chain should advance to EXPANSION.
COMPLETE_RESP=$(graphql_post "{\"query\":\"mutation { completeTask(taskId: \\\"$TASK_ID\\\", result: {}) { id state currentStage } }\"}")
if echo "$COMPLETE_RESP" | grep -q '"errors"'; then
    echo "FAIL: completeTask returned errors: $COMPLETE_RESP" >&2
    kill -9 "$PID2" 2>/dev/null || true
    cat "$LOG2"
    exit 1
fi

WAITED=0
while true; do
    NEXT_RESP=$(graphql_post "{\"query\":\"query { task(id: \\\"$TASK_ID\\\") { openAssignment { stage } } }\"}")
    if echo "$NEXT_RESP" | grep -q '"stage":"EXPANSION"'; then
        break
    fi
    sleep 0.5
    WAITED=$((WAITED + 1))
    if (( WAITED > 30 )); then
        echo "FAIL: EXPANSION assignment never opened: $NEXT_RESP" >&2
        kill -9 "$PID2" 2>/dev/null || true
        cat "$LOG2"
        exit 1
    fi
done

kill -TERM "$PID2" 2>/dev/null || true
wait "$PID2" 2>/dev/null || true

echo "OK: chain recovery survived kill -9; TRIAGE → EXPANSION advanced cleanly"
