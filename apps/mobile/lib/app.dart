import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/routes.dart';
import 'core/sync/refetch_coordinator.dart';

class TendantApp extends ConsumerWidget {
  const TendantApp({super.key, this.initialSession});

  final String? initialSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider(initialSession));
    // The refetch coordinator is the realtime reliability backstop: it
    // reconciles the active read models on app-foreground and on
    // offline→online (websocket reconnect). See refetch_coordinator.dart.
    return RealtimeRefetchCoordinator(
      child: MaterialApp.router(
        title: 'tendant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        routerConfig: router,
      ),
    );
  }
}
