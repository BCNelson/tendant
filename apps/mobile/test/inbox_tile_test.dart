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
    expect(find.text('Decision (Phase 4+)'), findsNothing);
  });

  testWidgets('non-actionable decision renders the read-only placeholder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InboxTile(
            item: const InboxItemRef(
              id: 'd1',
              typename: 'PromotionProposal',
              title: 'unused',
              subtitle: 'EXECUTE_GATED → EXECUTE_AUTO',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Decision (Phase 4+)'), findsOneWidget);
    expect(find.text('unused'), findsNothing);
  });

  testWidgets('FeedbackRequest tile is actionable, not the placeholder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InboxTile(
            item: const InboxItemRef(
              id: 'f1',
              typename: 'FeedbackRequest',
              title: 'Feedback: Buy milk',
              subtitle: 'How did this task go? Tap to chat.',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Feedback: Buy milk'), findsOneWidget);
    expect(find.text('How did this task go? Tap to chat.'), findsOneWidget);
    // Must be actionable, not the read-only placeholder.
    expect(find.text('Decision (Phase 4+)'), findsNothing);
  });
}
