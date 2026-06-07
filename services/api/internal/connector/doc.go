// Package connector is the trusted source-adapter seam, shaped exactly like
// internal/push: an interface plus a registry of named implementations.
//
// A Connector talks to one kind of external source (Gmail, an RSS feed, an
// inbound webhook) and, on Run, emits normalized PotentialTaskSignals through
// the supplied emit callback. The connector is the privacy firewall — it
// chooses what each signal's Payload carries; the core never sees raw source
// content beyond that.
//
// The base set ships in two tiers, mirroring the push APNs/FCM precedent
// ("stubs ready for real credentials"):
//
//   - Fully implemented, zero-credential, E2E-tested: webhook-in, rss.
//   - OAuth exemplar: gmail (token refresh + list/get over stdlib net/http,
//     live call behind a fetcher seam so tests inject a fake).
//   - Stub providers (LogProvider-style, emit nothing): calendar, imap.
//     imap's lack of a stdlib client is the one deferred dep-approval flag.
//
// A new source is one file in this package plus a registry entry — and zero
// changes to internal/intake (Constitution Principle I, by construction).
package connector
