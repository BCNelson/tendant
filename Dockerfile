FROM --platform=$BUILDPLATFORM golang:1.23 AS builder
WORKDIR /app
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
ARG VERSION=dev
ARG COMMIT=unknown
ARG BUILD_DATE=unknown
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
    -ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.buildDate=${BUILD_DATE}" \
    -o /out/tendant ./cmd/tendant

# :nonroot runs as UID/GID 65532.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /out/tendant /tendant
ENTRYPOINT ["/tendant"]
