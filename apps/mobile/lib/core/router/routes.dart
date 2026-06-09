import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/approval/approval_detail_page.dart';
import '../../features/feedback/feedback_detail_page.dart';
import '../../features/inbox/inbox_page.dart';
import '../../features/pairing/pairing_page.dart';
import '../../features/routing/routing_detail_page.dart';
import '../../features/server/server_address_page.dart';
import '../../features/settings/settings_screens.dart';
import '../../features/task/assignment_view.dart';
import '../../features/task/create_task_page.dart';
import '../../features/tasks/tasks_page.dart';
import '../../features/tasks/task_detail_page.dart';
import '../auth/session_store.dart';
import '../server/server_address.dart';
import 'root_shell.dart';

/// routerProvider constructs the GoRouter, seeded with the initial session
/// token (so the first render knows whether to land on /pairing or /inbox).
/// The server address (resolved at boot into [serverAddressProvider]) gates
/// everything: an unconfigured app lands on /server first.
final routerProvider = Provider.family<GoRouter, String?>((ref, initialSession) {
  // sessionTokenProvider is seeded via a ProviderScope override in main.dart —
  // a provider must not mutate another during build, so we only read here.
  final hasServer = ref.read(serverAddressProvider).isConfigured;
  final initialLocation = !hasServer
      ? '/server'
      : (initialSession == null ? '/pairing' : '/inbox');

  // Re-run redirect whenever the session token changes. This is what bounces
  // the app to /pairing the moment the token is cleared (e.g. the ferry client
  // dropped it after an UNAUTHORIZED response from a server-side session reset).
  final refresh = ValueNotifier<int>(0);
  ref.listen<String?>(sessionTokenProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // No server yet → force the address screen and let it through.
      if (!ref.read(serverAddressProvider).isConfigured) {
        return loc == '/server' ? null : '/server';
      }
      // Configured: /server is reachable as the settings editor, never bounced.
      if (loc == '/server') return null;

      final hasToken = ref.read(sessionTokenProvider) != null;
      final goingToPairing = loc == '/pairing';
      if (!hasToken && !goingToPairing) return '/pairing';
      if (hasToken && goingToPairing) return '/inbox';
      return null;
    },
    routes: [
      GoRoute(
        path: '/server',
        builder: (_, __) => const ServerAddressPage(),
      ),
      GoRoute(
        path: '/pairing',
        builder: (_, __) => const PairingPage(),
      ),
      // Authenticated area — Inbox + Tasks tabs under a shared bottom nav.
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (_, __) => const InboxPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => AssignmentView(
                        assignmentId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, __) => const TasksPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        TaskDetailPage(taskId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Manual task composition (createTask mutation).
      GoRoute(
        path: '/create-task',
        builder: (_, __) => const CreateTaskPage(),
      ),
      // Phase 3 — approval detail page for ApprovalRequest items.
      GoRoute(
        path: '/approval/:id',
        builder: (_, state) =>
            ApprovalDetailPage(decisionId: state.pathParameters['id']!),
      ),
      // Post-completion feedback conversation for FeedbackRequest items.
      GoRoute(
        path: '/feedback/:id',
        builder: (_, state) =>
            FeedbackDetailPage(decisionId: state.pathParameters['id']!),
      ),
      // Phase 6 — read-only routing/specialist view per task.
      GoRoute(
        path: '/routing/:taskId',
        builder: (_, state) =>
            RoutingDetailPage(taskId: state.pathParameters['taskId']!),
      ),
      // Owner settings — config registry + connectors.
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsHomePage(),
        routes: [
          GoRoute(
            path: 'config',
            builder: (_, __) => const ConfigScreen(),
          ),
          GoRoute(
            path: 'connectors',
            builder: (_, __) => const ConnectorsScreen(),
          ),
        ],
      ),
    ],
  );
});
