# Version info from git
VERSION := `git describe --tags --always 2>/dev/null || echo "dev"`
COMMIT := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
BUILD_DATE := `date -u +%Y-%m-%dT%H:%M:%SZ`
LDFLAGS := "-X main.version=" + VERSION + " -X main.commit=" + COMMIT + " -X main.buildDate=" + BUILD_DATE

# Build the binary
build: generate
    go build -ldflags '{{LDFLAGS}}' -o tendant ./cmd/tendant

# Run the binary
run: build
    ./tendant

# Run all Go tests with coverage
test:
    go test -race -count=1 -timeout=300s -coverprofile=coverage.out -covermode=atomic ./cmd/... ./internal/...
    go tool cover -func=coverage.out

# Coverage HTML report at coverage.html (filtered via .coverignore if present)
coverage: test
    @if [ -f .coverignore ]; then \
        pattern=$(grep -v '^#' .coverignore | grep -v '^$' | paste -sd'|' -); \
        grep -v -E "$pattern" coverage.out > coverage.filtered && mv coverage.filtered coverage.out; \
    fi
    go tool cover -html=coverage.out -o coverage.html
    @echo "Coverage report: coverage.html"

# Lint
lint:
    golangci-lint run ./cmd/... ./internal/...

# Format
fmt:
    gofmt -w .
    goimports -w .

# Tidy modules
tidy:
    go mod tidy

# Regenerate sqlc code
generate:
    cd internal/db && sqlc generate

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
