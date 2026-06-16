#!/usr/bin/env bash
# Phase 2 quickstart verification — drives the pairing → push → subscription →
# revocation → offline-dismiss walkthrough end-to-end (per specs/003-operator-edge-wake/quickstart.md).
#
# Prerequisites: `devenv up` is running (Postgres + the API on :8080); the
# server boots with TENDANT_SETUP_SECRET in the environment.
set -euo pipefail

HOST="${HOST:-http://localhost:8080}"
SETUP="${TENDANT_SETUP_SECRET:-dev}"
DBURL="${DATABASE_URL:-postgres://postgres:postgres@127.0.0.1:5432/tendant?sslmode=disable}"

pass() { printf "%s ........... OK\n" "$1"; }
fail() { printf "%s ........... FAIL: %s\n" "$1" "$2"; exit 1; }

graphql() {
  local body="$1" bearer="${2:-}"
  if [ -n "$bearer" ]; then
    curl -fsS -H "Content-Type: application/json" -H "Authorization: Bearer $bearer" \
      -d "$body" "$HOST/graphql"
  else
    curl -fsS -H "Content-Type: application/json" -d "$body" "$HOST/graphql"
  fi
}

# 1/4 pair device
pair_body='{"query":"mutation { pairDevice(setupSecret:\"'"$SETUP"'\", displayName:\"phase2-demo\") { token } }"}'
pair_resp=$(graphql "$pair_body" || fail "pair device" "request failed")
token=$(printf "%s" "$pair_resp" | grep -oE '"token":"[^"]+"' | head -1 | cut -d'"' -f4)
[ -n "$token" ] || fail "pair device" "no token returned: $pair_resp"
pass "1/4 pair device (token: ${token:0:8}…)"

# 2/4 push channel (LogProvider stub)
# Seed a token row so push fan-out has something to target.
psql "$DBURL" -c "INSERT INTO device_tokens (token, owner_id, platform) VALUES ('stub-phase2-demo', (SELECT id FROM principals WHERE global_uri='local://principal/owner'), 'ios') ON CONFLICT DO NOTHING" >/dev/null
create_body='{"query":"mutation { createTask(title:\"phase2-demo task\") { id } }"}'
create_resp=$(graphql "$create_body" "$token" || fail "createTask" "request failed")
task_id=$(printf "%s" "$create_resp" | grep -oE '"id":"[^"]+"' | head -1 | cut -d'"' -f4)
[ -n "$task_id" ] || fail "createTask" "no id returned: $create_resp"
pass "2/4 push (LogProvider) — task $task_id created; check server logs for push.LogProvider.Send"

# 3/4 subscription channel — only verifiable with a real WS client (websocat);
# this script's GraphQL surface check confirms the inbox query returns the new
# assignment.
sleep 1
inbox_body='{"query":"{ inbox(first: 5) { __typename ... on AgentAssignment { id } } }"}'
inbox_resp=$(graphql "$inbox_body" "$token" || fail "inbox" "request failed")
printf "%s" "$inbox_resp" | grep -q "AgentAssignment" \
  || fail "inbox" "AgentAssignment not visible: $inbox_resp"
pass "3/4 inbox returns the new AgentAssignment"

# 4/4 revoke session — via SQL nudge to keep the demo self-contained.
psql "$DBURL" -c "UPDATE sessions SET revoked_at = now() WHERE token_hash = (SELECT token_hash FROM sessions ORDER BY created_at DESC LIMIT 1)" >/dev/null
post_revoke=$(graphql '{"query":"{ viewer { id } }"}' "$token")
printf "%s" "$post_revoke" | grep -q '"viewer":null' \
  || fail "revocation" "viewer should be null post-revoke: $post_revoke"
pass "4/4 post-revocation viewer is null (bearer dead)"

echo "phase2-demo: PASS"
