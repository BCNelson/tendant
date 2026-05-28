import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// DeepLinkRouter resolves push-tap → in-app route. The router instance is
/// injected via deepLinkRouterProvider so messaging.dart doesn't depend on
/// router internals.
class DeepLinkRouter {
  DeepLinkRouter(this._router);

  final GoRouter _router;

  void routeToInboxItem(String id) {
    _router.push('/inbox/$id');
  }
}

/// deepLinkRouterProvider is overridden once the GoRouter is constructed in
/// routes.dart. Reading it before that override is a programming error.
final deepLinkRouterProvider = Provider<DeepLinkRouter>(
  (ref) => throw UnimplementedError('deepLinkRouterProvider not initialized'),
);
