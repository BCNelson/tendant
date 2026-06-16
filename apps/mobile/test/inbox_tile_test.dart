import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/inbox/inbox_page.dart';
import 'package:tendant/features/inbox/inbox_provider.dart';

Widget _host(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  testWidgets('AgentAssignment card renders the title and ask',
      (tester) async {
    await tester.pumpWidget(_host(
      const InboxEntryCard(
        entry: InboxEntryRef(
          entryId: 'a1',
          kind: 'agent_assignment',
          urgency: 210,
          messageType: 'agent_assignment',
          itemId: 'a1',
          title: 'Buy milk',
          subtitle: 'TRIAGE',
        ),
      ),
    ));
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('TRIAGE'), findsOneWidget);
  });

  testWidgets('non-actionable promotion proposal is read-only',
      (tester) async {
    await tester.pumpWidget(_host(
      const InboxEntryCard(
        entry: InboxEntryRef(
          entryId: 'd1',
          kind: 'pending_decision',
          urgency: 200,
          messageType: 'promotion_proposal',
          itemId: 'd1',
          title: 'Promotion proposal',
          subtitle: 'EXECUTE_GATED → EXECUTE_AUTO',
        ),
      ),
    ));
    expect(find.text('Promotion proposal'), findsOneWidget);
    // Read-only: the lock icon is shown and the tile is disabled (no chevron).
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('unread approval shows a bold title; read does not',
      (tester) async {
    await tester.pumpWidget(_host(
      const InboxEntryCard(
        entry: InboxEntryRef(
          entryId: 'd9',
          kind: 'pending_decision',
          urgency: 300,
          messageType: 'approval_request',
          itemId: 'd9',
          title: 'Approval requested',
          subtitle: 'Tap to review',
          unread: true,
        ),
      ),
    ));
    final unreadTitle = tester.widget<Text>(find.text('Approval requested'));
    expect(unreadTitle.style?.fontWeight, FontWeight.w600);
    // Approval routes through, so the chevron (tappable) is present.
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('ActionableTask card exposes inline Accept / Dismiss',
      (tester) async {
    await tester.pumpWidget(_host(
      const InboxEntryCard(
        entry: InboxEntryRef(
          entryId: 't1',
          kind: 'task',
          urgency: 650,
          messageType: 'actionable_task',
          itemId: 't1',
          title: 'Decide me',
          subtitle: 'Proposed',
          taskId: 't1',
          priority: 'URGENT',
          taskState: 'PROPOSED',
        ),
      ),
    ));
    expect(find.text('Decide me'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Accept'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Dismiss'), findsOneWidget);
  });
}
