import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/inbox/inbox_page.dart';

void main() {
  testWidgets('AgentAssignment tile renders the title and ask', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InboxTile(
            item: const InboxItemRef(
              id: 'a1',
              typename: 'AgentAssignment',
              title: 'Buy milk',
              subtitle: 'TRIAGE',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('TRIAGE'), findsOneWidget);
    // Decision placeholder should NOT appear.
    expect(find.text('Decision (Phase 3)'), findsNothing);
  });

  testWidgets('PendingDecision tile renders the Phase 3 placeholder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InboxTile(
            item: const InboxItemRef(
              id: 'd1',
              typename: 'ApprovalRequest',
              title: 'unused',
              subtitle: 'approve',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Decision (Phase 3)'), findsOneWidget);
    expect(find.text('unused'), findsNothing);
  });
}
