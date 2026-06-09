import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';

/// AuthLink prepends `Authorization: Bearer <token>` to outbound requests
/// when a token is present. For subscription operations, gql_websocket_link
/// reads the same token from the connection_init payload constructed at the
/// Ferry client level — see `client.dart` for that wiring.
class AuthLink extends Link {
  AuthLink(this.tokenProvider);

  /// Function returning the current bearer token, or null if unpaired.
  final String? Function() tokenProvider;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final token = tokenProvider();
    final updated = token == null
        ? request
        : request.updateContextEntry<HttpLinkHeaders>(
            (entry) => HttpLinkHeaders(
              headers: <String, String>{
                ...?entry?.headers,
                'Authorization': 'Bearer $token',
              },
            ),
          );
    return forward!(updated);
  }
}

/// UnauthorizedLink watches responses for the server's canonical
/// `UNAUTHORIZED` GraphQL error (extensions.code) and invokes [onUnauthorized]
/// once it sees one — e.g. when the device's session was revoked or the server
/// database was reset out from under a still-"paired" app. The callback clears
/// the stored token so the router can bounce the user back to pairing.
class UnauthorizedLink extends Link {
  UnauthorizedLink(this.onUnauthorized);

  final void Function() onUnauthorized;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return forward!(request).map((response) {
      final errors = response.errors;
      if (errors != null &&
          errors.any((e) => e.extensions?['code'] == 'UNAUTHORIZED')) {
        onUnauthorized();
      }
      return response;
    });
  }
}
