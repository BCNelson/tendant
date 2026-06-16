import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../graphql/client.dart' show wsReconnectSignalProvider;
import '../offline/connectivity.dart';
import '../../features/inbox/inbox_provider.dart';
import '../../features/tasks/tasks_provider.dart';

/// RealtimeRefetchCoordinator is the reliability backstop for the live data
/// layer. The websocket + normalized cache deliver updates on the happy path;
/// this widget closes the gaps a mobile socket can't: it re-fetches the active
/// read models on (a) app foreground and (b) an offline→online transition
/// (which is also when the websocket reconnects).
///
/// Because every query is CacheAndNetwork, a refetch renders instantly from
/// cache and reconciles in the background — so a dropped event, a buffer-
/// overflow termination, or a backgrounded socket self-heals on the next
/// resume/reconnect rather than leaving the UI permanently stale.
class RealtimeRefetchCoordinator extends ConsumerStatefulWidget {
  const RealtimeRefetchCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RealtimeRefetchCoordinator> createState() =>
      _RealtimeRefetchCoordinatorState();
}

class _RealtimeRefetchCoordinatorState
    extends ConsumerState<RealtimeRefetchCoordinator> {
  AppLifecycleListener? _lifecycle;
  StreamSubscription<void>? _wsReconnectSub;

  @override
  void initState() {
    super.initState();
    // App returns to the foreground: the socket was likely torn down by the OS
    // while backgrounded, so reconcile current state immediately.
    _lifecycle = AppLifecycleListener(onResume: _reconcile);

    // Offline → online: the websocket is reconnecting; reconcile whatever it
    // missed while the link was down.
    ref.listenManual<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      final wasOnline = prev?.value ?? false;
      final isOnline = next.value ?? false;
      if (!wasOnline && isOnline) _reconcile();
    });

    // Websocket reconnected (covers blips that aren't a connectivity change —
    // the common "arrival missed until refresh" gap). pg_notify isn't durable,
    // so resubscribe doesn't replay; refetch to catch what fired while down.
    _wsReconnectSub =
        ref.read(wsReconnectSignalProvider).stream.listen((_) => _reconcile());
  }

  /// Invalidate the live read models so they re-fetch. Only providers currently
  /// in use actually recompute; entity-level freshness keeps flowing through
  /// the cache regardless. List membership/order (which the cache can't derive)
  /// is what this refetch reconciles.
  void _reconcile() {
    ref.invalidate(rawTasksProvider);
    ref.invalidate(taskDetailProvider);
    ref.invalidate(inboxFeedProvider);
  }

  @override
  void dispose() {
    _wsReconnectSub?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
