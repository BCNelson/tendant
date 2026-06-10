import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/inbox/inbox_page.dart';
import 'package:tendant/features/inbox/inbox_provider.dart';

void main() {
  testWidgets('inbox refreshes the ranked feed when an entry arrives',
      (tester) async {
    // Mutable backing list the fetcher reads; the arrival stream drives the
    // refetch that re-pins the clock and re-ranks.
    var entries = const <InboxEntryRef>[];
    final arrivals = StreamController<void>.broadcast();
    addTearDown(arrivals.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inboxFeedFetcherProvider.overrideWithValue(
            (after) async => InboxFeedResult(entries: entries),
          ),
          inboxArrivedProvider.overrideWith((ref) => arrivals.stream),
        ],
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nothing needs you right now.'), findsOneWidget);

    // A new entry lands; the arrival event triggers a feed refresh.
    entries = const [
      InboxEntryRef(
        entryId: 'a1',
        kind: 'agent_assignment',
        urgency: 210,
        typename: 'AgentAssignment',
        itemId: 'a1',
        title: 'New task',
        subtitle: 'TRIAGE',
      ),
    ];
    arrivals.add(null);
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsOneWidget);
  });
}
