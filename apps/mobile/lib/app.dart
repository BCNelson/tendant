import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/routes.dart';

class TendantApp extends ConsumerWidget {
  const TendantApp({super.key, this.initialSession});

  final String? initialSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider(initialSession));
    return MaterialApp.router(
      title: 'tendant',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}
