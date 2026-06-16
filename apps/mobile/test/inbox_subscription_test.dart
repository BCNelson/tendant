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
    final arrivals = StreamController<int>.broadcast();
    var tick = 0;
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
        messageType: 'agent_assignment',
        itemId: 'a1',
        title: 'New task',
        subtitle: 'TRIAGE',
      ),
    ];
    arrivals.add(++tick);
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsOneWidget);

    // A SECOND entry lands. This is the regression guard: each arrival carries
    // a distinct tick, so Riverpod's repeat-equal AsyncData suppression cannot
    // swallow the follow-up refresh (the bug was mapping every event to a
    // constant `void`, which refreshed only on the first arrival).
    entries = const [
      InboxEntryRef(
        entryId: 'a2',
        kind: 'agent_assignment',
        urgency: 220,
        messageType: 'agent_assignment',
        itemId: 'a2',
        title: 'Second task',
        subtitle: 'TRIAGE',
      ),
    ];
    arrivals.add(++tick);
    await tester.pumpAndSettle();

    expect(find.text('Second task'), findsOneWidget);
    expect(find.text('New task'), findsNothing);
  });
}
