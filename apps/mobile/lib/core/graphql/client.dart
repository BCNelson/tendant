import 'dart:async';
import 'dart:math';

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
import '../../graphql/__generated__/schema.schema.gql.dart' show possibleTypesMap;

/// wsReconnectSignalProvider fires once whenever the subscription websocket
/// (re)connects AFTER its initial connection. The refetch coordinator listens
/// to it and reconciles the read models: the server's pg_notify is NOT durable,
/// so events that fired while the socket was down are not replayed on
/// resubscribe — a reconnect must be followed by a refetch to catch arrivals
/// missed during the gap. Closed with the ProviderScope.
final wsReconnectSignalProvider = Provider<StreamController<void>>((ref) {
  final controller = StreamController<void>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

/// _cappedBackoff is the websocket reconnect wait: exponential but capped at
/// ~16s with jitter, so an extended outage doesn't push the next reconnect
/// minutes/hours away (the package default doubles unbounded). Paired with a
/// very high retryAttempts so the socket reconnects effectively forever instead
/// of erroring out after a handful of blips (the old retryAttempts: 5 left the
/// subscription permanently dead until a manual page refresh).
Future<void> _cappedBackoff(int retries) async {
  final exp = retries.clamp(0, 4); // cap the exponent: 1,2,4,8,16 (×1000ms)
  final base = 1000 * (1 << exp);
  final jitter = Random().nextInt(500);
  await Future<void>.delayed(Duration(milliseconds: base + jitter));
}

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
  final reconnectSignal = ref.watch(wsReconnectSignalProvider);
  // Skip the very first `connected` (initial connect, not a reconnect); every
  // subsequent one means the socket dropped and came back — fire the signal so
  // the refetch coordinator reconciles arrivals missed while it was down.
  var hasConnectedOnce = false;
  final wsLink = TransportWebSocketLink(
    TransportWsClientOptions(
      socketMaker: WebSocketMaker.url(() => wsEndpoint),
      // Auth rides the connection_init payload, read freshly per (re)connect
      // so a re-paired token is picked up without rebuilding the client.
      connectionParams: () => <String, Object?>{
        if (token() != null) 'authorization': 'Bearer ${token()}',
      },
      // Reconnect effectively forever (mobile networks blip constantly). The
      // old retryAttempts: 5 made the client ERROR OUT after 5 abnormal
      // closures and stop reconnecting — the subscription then stayed dead
      // until a manual page refresh, which is the "item didn't show up until I
      // refreshed" bug. Pair the high cap with a capped backoff.
      retryAttempts: 1 << 30,
      retryWait: _cappedBackoff,
      eventHandlers: [
        TransportWsEventHandler<void>(
          connected: (_, __) {
            if (hasConnectedOnce) {
              if (!reconnectSignal.isClosed) reconnectSignal.add(null);
            }
            hasConnectedOnce = true;
          },
        ),
      ],
    ),
  );
  final transportLink = Link.split(_isSubscription, wsLink, httpLink);
  final link = Link.from([
    UnauthorizedLink(handleUnauthorized),
    AuthLink(token),
    transportLink,
  ]);
  // The normalized cache is the client's single source of truth (gold-standard
  // GraphQL). `possibleTypesMap` (generated) lets it normalize the InboxItem
  // union and the PendingDecision/Principal interfaces by id. Every entity with
  // an `id` is keyed automatically, so a data-carrying subscription push merges
  // into the same record a query reads — and any watching request re-emits with
  // no tick counter and no manual refetch.
  final cache = Cache(possibleTypes: possibleTypesMap);
  return Client(
    link: link,
    cache: cache,
    defaultFetchPolicies: const {
      // Render instantly from cache, then revalidate over the network. A
      // watched query also re-emits whenever a referenced entity changes in the
      // cache (e.g. from a subscription merge) — this is what makes realtime
      // updates automatic instead of relying on event delivery.
      OperationType.query: FetchPolicy.CacheAndNetwork,
      // Mutations always hit the network; their full responses write through to
      // the cache so the read models update.
      OperationType.mutation: FetchPolicy.NetworkOnly,
      // Subscription pushes are merged into the cache by id.
      OperationType.subscription: FetchPolicy.CacheAndNetwork,
    },
  );
});
