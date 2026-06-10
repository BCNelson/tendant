import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gql/ast.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_websocket_link/gql_websocket_link.dart';

import '../auth/auth_link.dart';
import '../auth/session_store.dart';
import '../server/server_address.dart';

/// _fallbackBase is the per-platform default origin used only when no server
/// address has been resolved yet (the router gates the app onto the
/// server-address screen before any request runs, so this is a safety net for
/// tests and edge cases). On Android it uses the emulator loopback alias
/// `10.0.2.2`; elsewhere `localhost`.
String _fallbackBase() {
  if (kIsWeb) return Uri.base.origin;
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

/// graphqlEndpointProvider derives the GraphQL HTTP endpoint from the resolved
/// [serverAddressProvider] base origin (`<base>/graphql`). Tests may still
/// override it directly to point at a stub.
final graphqlEndpointProvider = Provider<String>((ref) {
  final base = ref.watch(serverAddressProvider).baseUrl ?? _fallbackBase();
  return '$base/graphql';
});

/// graphqlWsEndpointProvider mirrors the above for the WebSocket transport.
final graphqlWsEndpointProvider = Provider<String>((ref) {
  final http = ref.watch(graphqlEndpointProvider);
  return http.replaceFirst(RegExp('^http'), 'ws');
});

/// _isSubscription returns true when the operation document declares a
/// subscription, so the split link routes it over the WebSocket transport.
bool _isSubscription(Request request) => request
    .operation.document.definitions
    .whereType<OperationDefinitionNode>()
    .any((d) => d.type == OperationType.subscription);

/// ferryClientProvider builds the Ferry Client wiring HTTP, WS, auth, and
/// the normalized in-memory cache. Subscriptions route through the WS link
/// (graphql-transport-ws); HTTP queries / mutations route through HttpLink.
final ferryClientProvider = Provider<Client>((ref) {
  String? token() => ref.read(sessionTokenProvider);

  // On a server-side session invalidation (revoked / DB reset), drop the stored
  // token. The router listens to sessionTokenProvider and redirects to pairing.
  // Idempotent: once cleared, the guard makes repeated UNAUTHORIZED errors
  // (every in-flight query fails at once) no-ops.
  void handleUnauthorized() {
    if (ref.read(sessionTokenProvider) == null) return;
    ref.read(sessionStoreProvider).clear();
    ref.read(sessionTokenProvider.notifier).state = null;
  }

  final httpLink = HttpLink(ref.watch(graphqlEndpointProvider));
  // The server speaks the `graphql-transport-ws` subprotocol (see
  // services/api/internal/server/server.go). Use TransportWebSocketLink — it
  // advertises that subprotocol in the handshake and, unlike the legacy
  // WebSocketLink, tears subscriptions down via sink.close() rather than
  // addError-on-a-closed-controller (which surfaced as unhandled
  // "Cannot add event after closing" exceptions on navigation/disconnect).
  final wsEndpoint = ref.watch(graphqlWsEndpointProvider);
  final wsLink = TransportWebSocketLink(
    TransportWsClientOptions(
      socketMaker: WebSocketMaker.url(() => wsEndpoint),
      // Auth rides the connection_init payload, read freshly per (re)connect
      // so a re-paired token is picked up without rebuilding the client.
      connectionParams: () => <String, Object?>{
        if (token() != null) 'authorization': 'Bearer ${token()}',
      },
      // Recover live subscriptions across transient network drops (the legacy
      // link defaulted to autoReconnect: true).
      retryAttempts: 5,
    ),
  );
  final transportLink = Link.split(_isSubscription, wsLink, httpLink);
  final link = Link.from([
    UnauthorizedLink(handleUnauthorized),
    AuthLink(token),
    transportLink,
  ]);
  // GraphQL is never served from cache. Ferry's built-in query default is
  // CacheFirst, which surfaced stale reads — and the normalized cache's
  // identical-value dedup is what forced the subscription `tick` workarounds in
  // bootstrap.dart. This app's freshness comes from network round-trips plus the
  // live subscriptions; durable offline writes ride the Drift outbox, not this
  // cache. So make NoCache the single, app-wide default: every query, mutation,
  // and subscription resolves from the link and neither reads nor writes the
  // normalized store. New operations inherit this — no per-request fetchPolicy.
  return Client(
    link: link,
    defaultFetchPolicies: const {
      OperationType.query: FetchPolicy.NoCache,
      OperationType.mutation: FetchPolicy.NoCache,
      OperationType.subscription: FetchPolicy.NoCache,
    },
  );
});
