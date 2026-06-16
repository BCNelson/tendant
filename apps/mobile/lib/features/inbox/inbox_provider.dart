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
    required this.messageType,
    required this.itemId,
    required this.title,
    required this.subtitle,
    this.unread = false,
    this.taskId,
    this.priority,
    this.dueAt,
    this.taskState,
  });

  final String entryId; // InboxEntry.id == inbox_messages.id
  final String kind; // pending_decision | agent_assignment | task
  final double urgency; // blended ranking score (descending)

  /// The fine-grained inbox_messages discriminator — the single value the UI
  /// dispatches a detail surface on: approval_request | agent_question |
  /// promotion_proposal | feedback_request | agent_assignment | actionable_task.
  final String messageType;
  final String itemId;
  final String title;
  final String subtitle;

  /// Per-message state: true when inbox_messages.read_at is still null.
  final bool unread;

  // ActionableTask inline-action metadata (null for the other kinds).
  final String? taskId;
  final String? priority;
  final DateTime? dueAt;
  final String? taskState;

  bool get isActionableTask => messageType == 'actionable_task';
  bool get isAssignment => messageType == 'agent_assignment';
  bool get isApprovalRequest => messageType == 'approval_request';
  bool get isFeedbackRequest => messageType == 'feedback_request';
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

  /// Optimistically drop one entry from the in-memory feed (swipe-to-dismiss).
  /// Updating the data source synchronously keeps Dismissible from asserting on
  /// the next rebuild; the server dismiss + next refresh make it durable.
  void removeEntry(String entryId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      entries: current.entries.where((e) => e.entryId != entryId).toList(),
    ));
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

/// Per-message inbox state writes (read / dismiss) on the first-class
/// inbox_messages row. These are local-state-only and low-stakes — they do not
/// touch the underlying decision — so they bypass the offline approval floor.
abstract class InboxStateMutator {
  Future<void> markRead(String messageId);
  Future<bool> dismiss(String messageId);
}

/// No-op default so widget tests render without a backend; bootstrap overrides
/// it with the Ferry-backed implementation.
final inboxStateMutatorProvider = Provider<InboxStateMutator>(
  (ref) => const _NoopInboxStateMutator(),
);

class _NoopInboxStateMutator implements InboxStateMutator {
  const _NoopInboxStateMutator();
  @override
  Future<void> markRead(String messageId) async {}
  @override
  Future<bool> dismiss(String messageId) async => false;
}
