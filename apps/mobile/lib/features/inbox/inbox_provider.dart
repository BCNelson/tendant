import 'package:flutter_riverpod/flutter_riverpod.dart';

/// InboxEntryRef is the lightweight, ranked shape the feed hands to the UI.
/// It flattens an `InboxEntry { urgency, kind, item }` envelope plus the
/// per-type fields the cards need (and, for ActionableTask, the metadata that
/// drives the inline accept/dismiss action).
class InboxEntryRef {
  const InboxEntryRef({
    required this.entryId,
    required this.kind,
    required this.urgency,
    required this.typename,
    required this.itemId,
    required this.title,
    required this.subtitle,
    this.taskId,
    this.priority,
    this.dueAt,
    this.taskState,
  });

  final String entryId; // InboxEntry.id
  final String kind; // pending_decision | agent_assignment | task
  final double urgency; // blended ranking score (descending)
  final String typename; // item __typename
  final String itemId;
  final String title;
  final String subtitle;

  // ActionableTask inline-action metadata (null for the other kinds).
  final String? taskId;
  final String? priority;
  final DateTime? dueAt;
  final String? taskState;

  bool get isActionableTask => typename == 'ActionableTask';
  bool get isAssignment => typename == 'AgentAssignment';
  bool get isApprovalRequest => typename == 'ApprovalRequest';
  bool get isFeedbackRequest => typename == 'FeedbackRequest';
}

/// One page of the ranked feed: the entries plus the opaque keyset cursor for
/// the next page (null = last page).
class InboxFeedResult {
  const InboxFeedResult({required this.entries, this.nextCursor});
  final List<InboxEntryRef> entries;
  final String? nextCursor;
}

typedef InboxFeedFetcher = Future<InboxFeedResult> Function(String? after);

/// Overridden in the bootstrap layer with the Ferry-backed page fetch. The
/// default is a no-op so any test that watches the feed renders empty rather
/// than throwing.
final inboxFeedFetcherProvider = Provider<InboxFeedFetcher>(
  (ref) => (_) async => const InboxFeedResult(entries: []),
);

/// Accumulated feed state across paged fetches.
class InboxFeedState {
  const InboxFeedState({
    required this.entries,
    this.nextCursor,
    this.loadingMore = false,
  });

  final List<InboxEntryRef> entries;
  final String? nextCursor;
  final bool loadingMore;

  bool get hasMore => nextCursor != null;

  InboxFeedState copyWith({
    List<InboxEntryRef>? entries,
    String? nextCursor,
    bool? loadingMore,
  }) =>
      InboxFeedState(
        entries: entries ?? this.entries,
        nextCursor: nextCursor ?? this.nextCursor,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Paginating, ranked inbox feed. build() fetches page 1 (re-pinning the
/// server ranking clock); loadMore() appends the next keyset page against the
/// pinned clock carried in the cursor.
class InboxFeedController extends AsyncNotifier<InboxFeedState> {
  @override
  Future<InboxFeedState> build() async {
    final fetch = ref.watch(inboxFeedFetcherProvider);
    final page = await fetch(null);
    return InboxFeedState(entries: page.entries, nextCursor: page.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final fetch = ref.read(inboxFeedFetcherProvider);
      final page = await fetch(current.nextCursor);
      state = AsyncData(InboxFeedState(
        entries: [...current.entries, ...page.entries],
        nextCursor: page.nextCursor,
      ));
    } catch (_) {
      // Keep the page already loaded; just clear the in-flight flag.
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  /// Re-fetch page 1 from scratch (re-pins the clock, re-ranks). Used on live
  /// arrival and manual refresh.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final inboxFeedProvider =
    AsyncNotifierProvider<InboxFeedController, InboxFeedState>(
  InboxFeedController.new,
);

/// inboxArrivedProvider emits a monotonically increasing tick whenever a new
/// inbox entry arrives (the `inboxEntryArrived` subscription). The Inbox view
/// listens to it and refreshes the ranked feed live. The value is a distinct
/// counter — not `void` — because Riverpod suppresses `ref.listen` callbacks
/// for repeat-equal `AsyncData`, so a constant value would only ever trigger
/// the first refresh and then go stale. Stubbed here; bootstrap overrides it
/// against the Ferry subscription.
final inboxArrivedProvider = StreamProvider<int>((ref) async* {
  // No emissions until overridden in the bootstrap layer.
});

/// Inline accept/dismiss for PROPOSED tasks surfaced as ActionableTask cards.
/// Both mutations are classified `lowStakes` by the offline floor rail.
abstract class ProposedTaskMutator {
  Future<bool> accept(String taskId);
  Future<bool> dismiss(String taskId, {String? reason});
}

final proposedTaskMutatorProvider = Provider<ProposedTaskMutator>(
  (ref) => throw UnimplementedError('overridden in bootstrap'),
);
