FROM --platform=$BUILDPLATFORM golang:1.25 AS builder
WORKDIR /app
# Copy workspace skeleton first so module resolution can be cached separately.
COPY go.work go.work.sum* ./
COPY db/go.mod db/
COPY services/api/go.mod services/api/go.sum* services/api/
RUN cd services/api && go mod download
COPY . .
ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -C services/api \
    -ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.buildDate=${BUILD_DATE}" \
    -o /out/tendant ./cmd/tendant

# :nonroot runs as UID/GID 65532.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /out/tendant /tendant
ENTRYPOINT ["/tendant"]
