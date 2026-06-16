import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'inbox_provider.dart';
import '../tasks/tasks_provider.dart' show allTasksChangedProvider;

/// InboxPage renders the ranked action feed — a single, urgency-sorted stream
/// of everything that needs the owner: PROPOSED tasks (accept/dismiss inline),
/// approvals, assignments, feedback, and (read-only) questions/promotions.
/// It paginates with infinite scroll and refreshes live on `inboxEntryArrived`.
class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger the next page when within ~400px of the bottom.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(inboxFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Any new inbox entry → refresh the ranked feed so it appears live (this
    // re-pins the ranking clock and re-sorts).
    ref.listen(inboxArrivedProvider, (_, __) {
      ref.read(inboxFeedProvider.notifier).refresh();
    });
    // Belt-and-suspenders: also refresh on ANY task/assignment/decision change.
    // The targeted `inboxEntryArrived` re-derives each item server-side and
    // emits nothing when it can't construct one (e.g. a decision kind it
    // doesn't map) — which silently drops the live update until a manual
    // refresh. The all-changes signal (taskChanged with no id matches the
    // task/assignment/decision topics) isn't gated that way, so it reliably
    // ticks and the authoritative feed refetch then shows the new item.
    ref.listen(allTasksChangedProvider, (_, __) {
      ref.read(inboxFeedProvider.notifier).refresh();
    });

    final feed = ref.watch(inboxFeedProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(inboxFeedProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'inbox-fab',
        tooltip: 'New task',
        onPressed: () => context.push('/create-task'),
        child: const Icon(Icons.add),
      ),
      body: feed.when(
        data: (state) {
          if (state.entries.isEmpty) {
            return const _EmptyFeed();
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(inboxFeedProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scroll,
              itemCount: state.entries.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= state.entries.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return InboxEntryCard(entry: state.entries[i]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          const Text('Nothing needs you right now.'),
        ],
      ),
    );
  }
}

/// InboxEntryCard dispatches one ranked entry on its `messageType`. ActionableTask
/// entries carry inline Accept / Dismiss; the rest render a generic card that
/// taps through to its detail surface (and marks itself read on the way).
class InboxEntryCard extends ConsumerWidget {
  const InboxEntryCard({super.key, required this.entry});

  final InboxEntryRef entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entry.isActionableTask) {
      return _ActionableTaskCard(entry: entry);
    }
    return _GenericInboxCard(entry: entry);
  }
}

/// _GenericInboxCard renders a non-actionable inbox message: an unread dot until
/// read, tap-through to the type's detail surface (firing markInboxRead), and
/// swipe-to-dismiss backed by dismissInboxMessage.
class _GenericInboxCard extends ConsumerStatefulWidget {
  const _GenericInboxCard({required this.entry});
  final InboxEntryRef entry;

  @override
  ConsumerState<_GenericInboxCard> createState() => _GenericInboxCardState();
}

class _GenericInboxCardState extends ConsumerState<_GenericInboxCard> {
  late bool _read = !widget.entry.unread;

  // messageType → (leading icon, detail route). A null route means read-only
  // (agent_question / promotion_proposal, until their action surfaces land).
  (IconData, VoidCallback?) _leadingAndTap() {
    final e = widget.entry;
    if (e.isApprovalRequest) {
      return (Icons.outbox, () => context.push('/approval/${e.itemId}'));
    }
    if (e.isFeedbackRequest) {
      return (
        Icons.rate_review_outlined,
        () => context.push('/feedback/${e.itemId}')
      );
    }
    if (e.isAssignment) {
      return (Icons.assignment, () => context.push('/inbox/${e.itemId}'));
    }
    return (Icons.lock_outline, null);
  }

  String _fallbackTitle() {
    final e = widget.entry;
    if (e.isApprovalRequest) return 'Approval';
    if (e.isFeedbackRequest) return 'Feedback';
    return 'Item';
  }

  void _markReadOnce() {
    if (_read) return;
    setState(() => _read = true);
    ref.read(inboxStateMutatorProvider).markRead(widget.entry.entryId);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final (icon, baseTap) = _leadingAndTap();
    final onTap = baseTap == null
        ? null
        : () {
            _markReadOnce();
            baseTap();
          };

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _UrgencyLeading(urgency: e.urgency, icon: icon),
        title: Row(
          children: [
            if (!_read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                e.title.isEmpty ? _fallbackTitle() : e.titleWithTag,
                style:
                    _read ? null : const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: Text(e.subtitle),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        enabled: onTap != null,
        onTap: onTap,
      ),
    );

    return Dismissible(
      key: ValueKey('inbox-${e.entryId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.archive_outlined),
      ),
      onDismissed: (_) {
        // Update the data source synchronously (avoids the Dismissible assert),
        // then persist the dismiss server-side.
        ref.read(inboxFeedProvider.notifier).removeEntry(e.entryId);
        ref.read(inboxStateMutatorProvider).dismiss(e.entryId);
      },
      child: card,
    );
  }
}

class _ActionableTaskCard extends ConsumerStatefulWidget {
  const _ActionableTaskCard({required this.entry});
  final InboxEntryRef entry;

  @override
  ConsumerState<_ActionableTaskCard> createState() =>
      _ActionableTaskCardState();
}

class _ActionableTaskCardState extends ConsumerState<_ActionableTaskCard> {
  bool _busy = false;

  Future<void> _run(
      Future<bool> Function(ProposedTaskMutator) op, String okMsg) async {
    final taskId = widget.entry.taskId;
    if (taskId == null) return;
    setState(() => _busy = true);
    final ok = await op(ref.read(proposedTaskMutatorProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? okMsg : 'Something went wrong. Try again.')),
    );
    if (ok) {
      await ref.read(inboxFeedProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _UrgencyLeading(
                  urgency: e.urgency, icon: Icons.flag_outlined),
              title: Text(e.title.isEmpty ? 'New task' : e.titleWithTag),
              subtitle: _ProposedSubtitle(entry: e),
              onTap: () => context.push('/tasks/${e.taskId}'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run((m) => m.dismiss(e.taskId!), 'Dismissed'),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run((m) => m.accept(e.taskId!), 'Accepted'),
                  child: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposedSubtitle extends StatelessWidget {
  const _ProposedSubtitle({required this.entry});
  final InboxEntryRef entry;

  @override
  Widget build(BuildContext context) {
    final parts = <String>['Proposed'];
    final pr = entry.priority;
    if (pr != null && pr.toUpperCase() != 'NORMAL') {
      parts.add(pr.toLowerCase());
    }
    final due = entry.dueAt;
    if (due != null) {
      parts.add('due ${_relativeDue(due)}');
    }
    return Text(parts.join(' · '));
  }

  String _relativeDue(DateTime due) {
    final diff = due.difference(DateTime.now());
    if (diff.isNegative) return 'overdue';
    if (diff.inHours < 24) return 'today';
    if (diff.inDays < 7) return 'in ${diff.inDays}d';
    return '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
  }
}

/// _UrgencyLeading shows the leading icon over a small urgency-tinted dot so
/// the ranked order is legible at a glance.
class _UrgencyLeading extends StatelessWidget {
  const _UrgencyLeading({required this.urgency, required this.icon});
  final double urgency;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The blended score tops out well above 400 for urgent/overdue; map to a
    // coarse hot→cool tint.
    final Color tint;
    if (urgency >= 500) {
      tint = scheme.error;
    } else if (urgency >= 300) {
      tint = scheme.tertiary;
    } else {
      tint = scheme.primary;
    }
    return CircleAvatar(
      backgroundColor: tint.withValues(alpha: 0.15),
      child: Icon(icon, color: tint),
    );
  }
}
