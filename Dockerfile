# --- Stage 1: build the Flutter web bundle ----------------------------------
# Web output is plain HTML/JS/wasm, so this stage is platform-independent and
# runs once regardless of TARGETPLATFORM. The version tag tracks devenv's
# flutter (3.41.x); bump both together.
FROM --platform=$BUILDPLATFORM ghcr.io/cirruslabs/flutter:3.41.6 AS webbuilder
WORKDIR /app
COPY apps/mobile/ ./
# Codegen is not required: the app's lib/ code does not import generated ferry
# types (the data layer uses overridable stub providers), so a plain build is
# enough and avoids a build_runner step.
RUN flutter pub get && flutter build web --release --base-href /

# --- Stage 2: build the Go binary with the web bundle embedded --------------
FROM --platform=$BUILDPLATFORM golang:1.25 AS builder
WORKDIR /app
# Copy workspace skeleton first so module resolution can be cached separately.
COPY go.work go.work.sum* ./
COPY db/go.mod db/
COPY services/api/go.mod services/api/go.sum* services/api/
RUN cd services/api && go mod download
COPY . .
# Drop the compiled web bundle into the //go:embed directory before building.
COPY --from=webbuilder /app/build/web/ services/api/internal/webui/dist/
ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -C services/api \
    -ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.buildDate=${BUILD_DATE}" \
    -o /out/tendant ./cmd/tendant

# --- Stage 3: minimal runtime image -----------------------------------------
# :nonroot runs as UID/GID 65532.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /out/tendant /tendant
ENTRYPOINT ["/tendant"]
