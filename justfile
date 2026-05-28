# Version info from git
VERSION := `git describe --tags --always 2>/dev/null || echo "dev"`
COMMIT := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
BUILD_DATE := `date -u +%Y-%m-%dT%H:%M:%SZ`
LDFLAGS := "-X main.version=" + VERSION + " -X main.commit=" + COMMIT + " -X main.buildDate=" + BUILD_DATE

# Build the binary
build: generate
    go build -C services/api -ldflags '{{LDFLAGS}}' -o ../../tendant ./cmd/tendant

# Run the binary
run: build
    ./tendant

# Bring up Postgres + the core (boots, migrates, seeds, serves /graphql).
# Uses the in-shell devenv Postgres if active; falls back to docker compose.
up:
    @if pg_isready -h 127.0.0.1 -p 5432 -q 2>/dev/null; then \
        echo "postgres already running"; \
    else \
        echo "starting postgres via docker compose"; \
        docker compose up -d postgres; \
        until pg_isready -h 127.0.0.1 -p 5432 -q; do sleep 0.5; done; \
    fi
    go run -C services/api ./cmd/tendant

# Stop the core and tear down Postgres + its volume so the next `up`
# re-migrates from clean (SC-001 idempotency).
down:
    -pkill -f "go-build.*tendant" 2>/dev/null || true
    -pkill -f "exe/tendant" 2>/dev/null || true
    docker compose down -v 2>/dev/null || true

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

# Run the DBOS recovery demo (kill -9 + restart, assert exactly-once).
dbos-demo:
    bash scripts/dbos-recovery-demo.sh

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
