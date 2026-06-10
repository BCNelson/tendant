# Version info from git
VERSION := `git describe --tags --always 2>/dev/null || echo "dev"`
COMMIT := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
BUILD_DATE := `date -u +%Y-%m-%dT%H:%M:%SZ`
LDFLAGS := "-X main.version=" + VERSION + " -X main.commit=" + COMMIT + " -X main.buildDate=" + BUILD_DATE

# Compile the Flutter web app and stage it into the Go embed directory
# (services/api/internal/webui/dist). The contents are git-ignored; the
# server embeds whatever is present at `go build` time (placeholder otherwise).
build-web:
    cd apps/mobile && flutter pub get
    cd apps/mobile && flutter build web --release --base-href /
    find services/api/internal/webui/dist -mindepth 1 ! -name .gitignore -delete
    cp -r apps/mobile/build/web/. services/api/internal/webui/dist/

# Build the binary with the web UI embedded.
build: generate build-web
    go build -C services/api -ldflags '{{LDFLAGS}}' -o ../../tendant ./cmd/tendant

# Build the binary without the web UI (fast Go-only loop; serves placeholder).
build-go: generate
    go build -C services/api -ldflags '{{LDFLAGS}}' -o ../../tendant ./cmd/tendant

# Run the binary
run: build
    ./tendant

# (private) Ensure the devenv Postgres is accepting connections, starting it
# detached via process-compose if needed. Run `devenv up` yourself in another
# terminal for the full foreground process view.
_pg:
    #!/usr/bin/env bash
    set -euo pipefail
    if pg_isready -h 127.0.0.1 -p 5432 -q 2>/dev/null; then
        echo "postgres already running"
        exit 0
    fi
    echo "starting devenv postgres (detached)…"
    devenv up -D postgres >/dev/null 2>&1 || true
    for _ in $(seq 1 60); do
        if pg_isready -h 127.0.0.1 -p 5432 -q 2>/dev/null; then
            echo "postgres ready"; exit 0
        fi
        sleep 0.5
    done
    echo "ERROR: postgres did not become ready — run 'devenv up' in another terminal." >&2
    exit 1

# Bring up Postgres (devenv) + the core (boots, migrates, seeds, serves
# /graphql). Overseer uses the deterministic LogProvider — see `just dev` for
# the full local stack wired to Ollama.
up: _pg
    go run -C services/api ./cmd/tendant

# Run the full local stack: devenv Postgres + the core wired to a local Ollama
# via tendant.dev.toml. Pull the models first with `just ollama-models`. If
# Ollama is down the overseer falls back to the LogProvider (the app still runs).
dev: _pg
    @if ! curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then \
        echo "WARNING: Ollama not reachable at http://localhost:11434"; \
        echo "  Start it ('ollama serve') and pull models ('just ollama-models')."; \
        echo "  Until then the overseer falls back to the deterministic LogProvider."; \
    fi
    go run -C services/api ./cmd/tendant serve --config {{justfile_directory()}}/tendant.dev.toml

# Pull the fast, tool-calling Ollama models referenced by tendant.dev.toml
# (the two chat models for the overseer/agent + the embedding model for triage).
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

# Stop the core. Tearing down the devenv Postgres is `devenv processes stop
# postgres` (or Ctrl-C the `devenv up` terminal); wipe its data for a clean
# re-migrate with `rm -rf .devenv/state/postgres`.
down:
    -pkill -f "go-build.*tendant" 2>/dev/null || true
    -pkill -f "exe/tendant" 2>/dev/null || true
    -docker compose down -v 2>/dev/null || true

# Reset the local database: stop the core, stop + wipe the devenv Postgres state
# dir, then start a fresh Postgres. The next `just up` re-runs goose migrations
# and re-seeds the owner from scratch. DESTRUCTIVE — drops all local data.
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
    echo "starting fresh postgres…"
    just _pg
    echo "database reset — run 'just up' to migrate + seed."

# Seed a Task via the in-process CreateTask path (TITLE=... override).
seed-task TITLE="hello":
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
