# Version info from git
VERSION := `git describe --tags --always 2>/dev/null || echo "dev"`
COMMIT := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
BUILD_DATE := `date -u +%Y-%m-%dT%H:%M:%SZ`
LDFLAGS := "-X main.version=" + VERSION + " -X main.commit=" + COMMIT + " -X main.buildDate=" + BUILD_DATE

# Compile the Flutter web app and stage it into the Go embed directory
# (services/api/internal/webui/dist). The contents are git-ignored; the
# server embeds whatever is present at `go build` time (placeholder otherwise).
# --pwa-strategy=none: emit no caching service worker (only the self-
# unregistering stub). Freshness is owned by the server's ETag + Cache-Control
# headers (services/api/internal/webui/webui.go), not a client-side SW.
# (Filename fingerprinting via scripts/fingerprint-web.mjs is deferred — the
# script exists but is intentionally not wired into the build yet.)
build-web:
    cd apps/mobile && flutter pub get
    cd apps/mobile && flutter build web --release --base-href / --pwa-strategy=none
    find services/api/internal/webui/dist -mindepth 1 ! -name .gitignore -delete
    cp -r apps/mobile/build/web/. services/api/internal/webui/dist/

# Build the binary with the web UI embedded.
build: generate build-web
    go build -C services/api -ldflags '{{LDFLAGS}}' -o ../../tendant ./cmd/tendant

# Build the binary without the web UI (fast Go-only loop; serves placeholder).
build-go: generate
    go build -C services/api -ldflags '{{LDFLAGS}}' -o ../../tendant ./cmd/tendant

# (private) Assert the devenv Postgres is reachable. Does NOT start anything —
# run `devenv up` yourself in another terminal (it owns Postgres + the core).
_pg:
    #!/usr/bin/env bash
    set -euo pipefail
    if pg_isready -h 127.0.0.1 -p 5432 -q 2>/dev/null; then exit 0; fi
    echo "ERROR: Postgres not reachable on 127.0.0.1:5432 — run 'devenv up' in another terminal." >&2
    exit 1

# Pull the fast, tool-calling Ollama models referenced by tendant.dev.toml
# (the two chat models for the overseer/agent + the embedding model for triage).
# `devenv up` wires the core's overseer to a local Ollama; pull these first.
ollama-models:
    ollama pull llama3.2:3b
    ollama pull qwen2.5:3b
    ollama pull nomic-embed-text

# Run the Flutter client with hot reload against the local API on :8080.
# With no DEVICE it lists the available devices and prompts you to pick one;
# pass DEVICE=chrome | linux | macos | <device-id> to skip the prompt. The
# server URL is baked in with --dart-define (the app's build-time override
# channel, so it reaches even targets that can't inherit the shell env); web
# ignores it and uses its serving origin. If you select an Android emulator the
# host-loopback alias is substituted automatically. SERVER_URL defaults to the
# devenv TENDANT_SERVER_URL. Run `just app-codegen` once on a fresh checkout.
app DEVICE="" SERVER_URL=env_var_or_default("TENDANT_SERVER_URL", "http://localhost:8080"):
    #!/usr/bin/env bash
    set -euo pipefail
    cd apps/mobile
    device="{{DEVICE}}"
    server_url="{{SERVER_URL}}"
    if [[ -z "$device" ]]; then
        flutter devices || true
        mapfile -t ids < <(flutter devices --machine 2>/dev/null \
            | grep -oE '"id"[[:space:]]*:[[:space:]]*"[^"]*"' \
            | sed -E 's/.*"([^"]*)"$/\1/')
        if [[ ${#ids[@]} -eq 0 ]]; then
            echo "No devices found — start an emulator/simulator or plug in a device." >&2
            exit 1
        fi
        echo
        PS3="Run on which device? (number) "
        select choice in "${ids[@]}"; do
            [[ -n "${choice:-}" ]] && { device="$choice"; break; }
            echo "Invalid selection — enter a listed number."
        done
    fi
    # Android emulators can't see the host's localhost; rewrite it to the
    # host-loopback alias (unless SERVER_URL was overridden to something else).
    if [[ "$device" == emulator-* && "$server_url" == "http://localhost:8080" ]]; then
        server_url="${TENDANT_ANDROID_SERVER_URL:-http://10.0.2.2:8080}"
    fi
    echo "→ flutter run -d $device  (TENDANT_SERVER_URL=$server_url)"
    exec flutter run -d "$device" --dart-define=TENDANT_SERVER_URL="$server_url"

# Run the Flutter client on an Android emulator, baking in the host-loopback
# alias so the app reaches the core running on your machine. SERVER_URL defaults
# to the devenv TENDANT_ANDROID_SERVER_URL (http://10.0.2.2:8080). Override
# DEVICE with your AVD id from `flutter devices` if it isn't emulator-5554.
app-android DEVICE="emulator-5554" SERVER_URL=env_var_or_default("TENDANT_ANDROID_SERVER_URL", "http://10.0.2.2:8080"):
    cd apps/mobile && flutter run -d {{DEVICE}} --dart-define=TENDANT_SERVER_URL={{SERVER_URL}}

# Like `just app`, but ALSO mirror everything the app prints to
# apps/mobile/flutter-run.log (gitignored via *.log) so Claude / other tools can
# read the running app's logs without launching it themselves. Runs `just app`
# under script(1) so it keeps a pty — the device picker and interactive hot
# reload (press r / R) still work. Linux/macOS: needs util-linux `script` (-c).
app-log DEVICE="" SERVER_URL=env_var_or_default("TENDANT_SERVER_URL", "http://localhost:8080"):
    script -q -e -f -c 'just app "{{DEVICE}}" "{{SERVER_URL}}"' apps/mobile/flutter-run.log

# Generate the Flutter GraphQL (ferry) + Drift code via build_runner. Required
# once on a fresh checkout, and after editing apps/mobile/lib/graphql/*.graphql.
app-codegen:
    cd apps/mobile && flutter pub get
    cd apps/mobile && dart run build_runner build --delete-conflicting-outputs

# Stop any stray core processes left behind (the live-reloading core normally
# stops when you Ctrl-C the `devenv up` terminal). Tearing down the devenv
# Postgres is `devenv processes stop postgres`; wipe its data for a clean
# re-migrate with `rm -rf .devenv/state/postgres` (or `just reset-db`).
down:
    -pkill -f "go-build.*tendant" 2>/dev/null || true
    -pkill -f "exe/tendant" 2>/dev/null || true
    -docker compose down -v 2>/dev/null || true

# Reset the local database: stop the core, stop + wipe the devenv Postgres state
# dir. Restart is yours — run `devenv up` afterward; it re-runs goose migrations
# and re-seeds the owner from scratch. DESTRUCTIVE — drops all local data. Run
# this with the `devenv up` terminal stopped (it holds the data dir otherwise).
reset-db: down
    #!/usr/bin/env bash
    set -euo pipefail
    echo "stopping devenv postgres…"
    devenv processes stop postgres >/dev/null 2>&1 || true
    # Give it a moment to release the data dir before we delete it.
    for _ in $(seq 1 20); do
        pg_isready -h 127.0.0.1 -p 5432 -q 2>/dev/null || break
        sleep 0.5
    done
    echo "wiping postgres state dir (.devenv/state/postgres)…"
    rm -rf .devenv/state/postgres
    echo "database reset — run 'devenv up' to start Postgres, migrate + seed."

# Seed a Task via the in-process CreateTask path (TITLE=... override). Needs the
# devenv Postgres up (run `devenv up`); _pg asserts it before we connect.
seed-task TITLE="hello": _pg
    go run -C services/api ./cmd/tendant seed --title="{{TITLE}}"

# Run all Go tests with coverage across the workspace (per-module — go test
# ./... won't traverse a go.work root).
test:
    cd services/api && go test -race -count=1 -timeout=600s -coverprofile=../../coverage.out -covermode=atomic ./...
    cd db && go test -race -count=1 -timeout=600s ./... || true
    go tool cover -func=coverage.out

# Coverage HTML report at coverage.html (filtered via .coverignore if present)
coverage: test
    @if [ -f .coverignore ]; then \
        pattern=$(grep -v '^#' .coverignore | grep -v '^$' | paste -sd'|' -); \
        grep -v -E "$pattern" coverage.out > coverage.filtered && mv coverage.filtered coverage.out; \
    fi
    go tool cover -html=coverage.out -o coverage.html
    @echo "Coverage report: coverage.html"

# Lint per-module (golangci-lint doesn't traverse go.work from the root).
lint:
    cd services/api && golangci-lint run ./...
    cd db && golangci-lint run ./...

# Format
fmt:
    gofmt -w .
    goimports -w .

# Tidy modules + workspace sync.
tidy:
    cd services/api && go mod tidy
    cd db && go mod tidy
    go work sync

# Regenerate sqlc + gqlgen code (committed; CI checks drift).
generate:
    cd services/api && sqlc generate
    cd services/api && go run github.com/99designs/gqlgen generate
    just gen-config-docs
    just sync-flutter-schema

# Regenerate the config reference from internal/config/keys.go (committed; CI
# checks drift).
gen-config-docs:
    cd services/api && go run ./cmd/gen-config-docs ../../docs/configuration-reference.md

# Mirror the live GraphQL schema into the Flutter app for ferry codegen.
# The server splits its SDL across graph/*.graphqls (schema + config +
# connector + gatescript); ferry wants one file, so concatenate them all.
# CI runs the same and asserts no diff (drift gate).
sync-flutter-schema:
    node scripts/flatten-schema.mjs apps/mobile/lib/graphql/schema.graphql services/api/graph/*.graphqls

# Run the DBOS recovery demo (kill -9 + restart, assert exactly-once).
dbos-demo:
    bash scripts/dbos-recovery-demo.sh

# Phase 2 end-to-end verification (pair → push → subscription → revoke).
phase2-demo:
    bash scripts/phase2-demo.sh

# Build container image (uses Dockerfile multi-stage)
docker-build:
    docker build \
        --build-arg VERSION={{VERSION}} \
        --build-arg COMMIT={{COMMIT}} \
        --build-arg BUILD_DATE={{BUILD_DATE}} \
        -t tendant:{{VERSION}} \
        -t tendant:latest \
        .

# Clean build artifacts
clean:
    rm -f tendant coverage.out coverage.html
    find services/api/internal/webui/dist -mindepth 1 ! -name .gitignore -delete 2>/dev/null || true
