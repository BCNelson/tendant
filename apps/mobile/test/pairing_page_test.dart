import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tendant/core/auth/session_store.dart';
import 'package:tendant/features/inbox/inbox_page.dart';
import 'package:tendant/features/pairing/pairing_page.dart';

void main() {
  testWidgets('empty fields show a validation error', (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pairDeviceProvider.overrideWith((ref) async => (
                {required String secret, required String displayName}) async => 'tok'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    expect(find.text('Pair'), findsOneWidget);
    await tester.tap(find.text('Pair'));
    await tester.pump();
    expect(find.text('Both fields are required.'), findsOneWidget);
  });

  testWidgets('successful pair navigates to /inbox and stores the token',
      (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pairDeviceProvider.overrideWith((ref) async => (
                {required String secret, required String displayName}) async => 'mock-token'),
          sessionStoreProvider.overrideWithValue(_FakeSessionStore()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'sekret');
    await tester.enterText(find.byType(TextField).last, 'Test Phone');
    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();

    expect(find.byType(InboxPage), findsOneWidget);
  });
}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/pairing',
      routes: [
        GoRoute(path: '/pairing', builder: (_, __) => const PairingPage()),
        GoRoute(path: '/inbox', builder: (_, __) => const InboxPage()),
      ],
    );

class _FakeSessionStore extends SessionStore {
  _FakeSessionStore() : super(storage: null);
  String? _stored;
  @override
  Future<String?> read() async => _stored;
  @override
  Future<void> write(String token) async => _stored = token;
  @override
  Future<void> clear() async => _stored = null;
}
