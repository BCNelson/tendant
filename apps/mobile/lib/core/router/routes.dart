import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/inbox/inbox_page.dart';
import '../../features/pairing/pairing_page.dart';
import '../../features/task/assignment_view.dart';
import '../auth/session_store.dart';

/// routerProvider constructs the GoRouter, seeded with the initial session
/// token (so the first render knows whether to land on /pairing or /inbox).
final routerProvider = Provider.family<GoRouter, String?>((ref, initialSession) {
  // Track the current token in shared state so the redirect can react.
  ref.read(sessionTokenProvider.notifier).state = initialSession;

  return GoRouter(
    initialLocation: initialSession == null ? '/pairing' : '/inbox',
    redirect: (context, state) {
      final hasToken = ref.read(sessionTokenProvider) != null;
      final goingToPairing = state.matchedLocation == '/pairing';
      if (!hasToken && !goingToPairing) return '/pairing';
      if (hasToken && goingToPairing) return '/inbox';
      return null;
    },
    routes: [
      GoRoute(
        path: '/pairing',
        builder: (_, __) => const PairingPage(),
      ),
      GoRoute(
        path: '/inbox',
        builder: (_, __) => const InboxPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                AssignmentView(assignmentId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
