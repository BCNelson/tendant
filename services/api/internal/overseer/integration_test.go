package overseer_test

// Integration coverage for User Story 1 + User Story 2 lives in the graph
// package (services/api/graph/overseer_integration_test.go) because the
// scenario walks GraphQL mutations end-to-end and reuses the chainEnv
// harness. Keeping the integration tests next to the resolver harness
// avoids duplicating the boot machinery.
//
// The internal/overseer package's unit + table-driven tests live in
// gateway_test.go, prompt_test.go, log_provider_test.go (Phase 4 US2),
// and pricing_test.go.
