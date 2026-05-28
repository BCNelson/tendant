import 'package:ferry/ferry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_websocket_link/gql_websocket_link.dart';

import '../auth/auth_link.dart';
import '../auth/session_store.dart';

/// graphqlEndpointProvider lets tests override the HTTP/WS endpoint without
/// rebuilding the entire client. Default targets the Android emulator
/// loopback alias.
final graphqlEndpointProvider = Provider<String>((ref) => 'http://10.0.2.2:8080/graphql');

/// graphqlWsEndpointProvider mirrors the above for the WebSocket transport.
final graphqlWsEndpointProvider = Provider<String>((ref) {
  final http = ref.watch(graphqlEndpointProvider);
  return http.replaceFirst(RegExp('^http'), 'ws');
});

/// ferryClientProvider builds the Ferry Client wiring HTTP, WS, auth, and
/// the normalized in-memory cache. Subscriptions route through the WS link
/// (graphql-transport-ws); HTTP queries / mutations route through HttpLink.
final ferryClientProvider = Provider<Client>((ref) {
  final tokenGetter = () => ref.read(sessionTokenProvider);
  final httpLink = HttpLink(ref.watch(graphqlEndpointProvider));
  final wsLink = WebSocketLink(
    ref.watch(graphqlWsEndpointProvider),
    initialPayload: () => <String, dynamic>{
      if (tokenGetter() != null) 'authorization': 'Bearer ${tokenGetter()}',
    },
  );
  final transportLink = Link.split(
    (request) => request.operation.document.definitions.any(
      (def) => def is dynamic && def.toString().contains('OperationType.subscription'),
    ),
    wsLink,
    httpLink,
  );
  final link = Link.from([AuthLink(tokenGetter), transportLink]);
  return Client(link: link);
});
