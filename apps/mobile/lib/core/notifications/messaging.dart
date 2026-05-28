import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'deep_link.dart';

/// messagingProvider exposes the FirebaseMessaging instance. Pairing wires
/// onTokenRefresh → registerDeviceToken; the inbox tile tap from a push
/// payload routes via deep_link.dart.
final messagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

/// initializeMessaging hooks the three platform callbacks: foreground
/// (onMessage), tap-while-backgrounded (onMessageOpenedApp), and cold-launch
/// (getInitialMessage). All three converge on routeToInboxItem(deepLinkID).
Future<void> initializeMessaging(WidgetRef ref) async {
  if (kIsWeb) {
    return; // Web push wiring is best-effort; out-of-scope for Phase 2.
  }
  final messaging = ref.read(messagingProvider);

  FirebaseMessaging.onMessage.listen((message) {
    _routeIfHasDeepLink(ref, message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _routeIfHasDeepLink(ref, message);
  });
  final initial = await messaging.getInitialMessage();
  if (initial != null) {
    _routeIfHasDeepLink(ref, initial);
  }
}

void _routeIfHasDeepLink(WidgetRef ref, RemoteMessage message) {
  final id = message.data['deep_link_id'] as String?;
  if (id == null || id.isEmpty) return;
  ref.read(deepLinkRouterProvider).routeToInboxItem(id);
}
