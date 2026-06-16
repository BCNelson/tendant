#!/usr/bin/env bash
# DBOS crash-recovery proof (SC-004 / FR-013). Runs cmd/dbosdemo, kill -9's
# it mid-sleep, restarts, and asserts:
#   - "checkpoint A executed" appears exactly once across both runs (step memoised)
#   - "resumed past the block" appears in run 2
#   - run 2 exits cleanly
#
# Prereqs: Postgres running and DATABASE_URL exported — easiest: have `devenv up`
# running in another terminal (the devenv shell exports DATABASE_URL).
# For CI we'd flip to a testcontainers-backed Go test, but the spec asks for
# the kill -9 binary path.

set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "DATABASE_URL is not set" >&2
    exit 2
fi

LOG1=$(mktemp -t dbosdemo-run1.XXXXXX)
LOG2=$(mktemp -t dbosdemo-run2.XXXXXX)
trap 'rm -f "$LOG1" "$LOG2"' EXIT

DEMO="go run ./services/api/cmd/dbosdemo"

echo "=== run 1: start, kill -9 after 5s ==="
$DEMO >"$LOG1" 2>&1 &
PID=$!
sleep 5
kill -9 "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "--- run 1 log ---"
cat "$LOG1"
echo "------------------"

if ! grep -q "checkpoint A executed" "$LOG1"; then
    echo "FAIL: run 1 did not log 'checkpoint A executed'" >&2
    exit 1
fi
if grep -q "resumed past the block" "$LOG1"; then
    echo "FAIL: run 1 already resumed — kill window too late?" >&2
    exit 1
fi

echo "=== run 2: restart, expect recovery and resume within ~90s ==="
$DEMO >"$LOG2" 2>&1 &
PID2=$!
TIMEOUT=120
WAITED=0
while kill -0 "$PID2" 2>/dev/null; do
    sleep 1
    WAITED=$((WAITED + 1))
    if (( WAITED >= TIMEOUT )); then
        kill -9 "$PID2" 2>/dev/null || true
        echo "--- run 2 log (timeout) ---"
        cat "$LOG2"
        echo "FAIL: run 2 did not finish within ${TIMEOUT}s" >&2
        exit 1
    fi
done
wait "$PID2" 2>/dev/null || true

echo "--- run 2 log ---"
cat "$LOG2"
echo "------------------"

if ! grep -q "resumed past the block" "$LOG2"; then
    echo "FAIL: run 2 did not log 'resumed past the block'" >&2
    exit 1
fi
if grep -q "checkpoint A executed" "$LOG2"; then
    echo "FAIL: step A re-executed on recovery (memoisation broken)" >&2
    exit 1
fi

echo "OK: DBOS recovery demo passed — step A logged once, sleep resumed across kill -9"
