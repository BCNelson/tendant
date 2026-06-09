import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateController;
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/inbox/inbox_page.dart';

void main() {
  testWidgets('inbox rebuilds when a new tile arrives via the stream',
      (tester) async {
    final controller = StateController<List<InboxItemRef>>(const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inboxItemsProvider.overrideWith((ref) async {
            // Yield the latest snapshot from the controller.
            return controller.state;
          }),
        ],
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    // The provider resolves on a microtask; settle past the loading frame.
    await tester.pumpAndSettle();
    expect(find.text('No items.'), findsOneWidget);

    // Emulate the subscription delivering a new item.
    controller.state = const [
      InboxItemRef(
        id: 'a1',
        typename: 'AgentAssignment',
        title: 'New task',
        subtitle: 'TRIAGE',
      ),
    ];
    // Invalidate to force the provider to re-resolve.
    // Force a rebuild by retriggering the provider through ProviderScope.
    final ctx = tester.element(find.byType(InboxPage));
    ProviderScope.containerOf(ctx).invalidate(inboxItemsProvider);
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsOneWidget);
  });
}
