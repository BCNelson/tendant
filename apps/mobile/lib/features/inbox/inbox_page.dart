import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// InboxPage renders the unified inbox of AgentAssignment + PendingDecision
/// items. Phase 2 only renders AgentAssignment tiles as actionable; the
/// three PendingDecision kinds render a read-only "Decision (Phase 3)"
/// placeholder per spec FR-022.
class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No items.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];
              return InboxTile(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// InboxItemRef is the lightweight in-memory shape the inbox provider hands
/// to InboxTile. The provider populates it from generated Ferry ops in
/// T065.
class InboxItemRef {
  const InboxItemRef({
    required this.id,
    required this.typename,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String typename;
  final String title;
  final String subtitle;

  bool get isAssignment => typename == 'AgentAssignment';
}

class InboxTile extends StatelessWidget {
  const InboxTile({super.key, required this.item});

  final InboxItemRef item;

  @override
  Widget build(BuildContext context) {
    if (!item.isAssignment) {
      return ListTile(
        leading: const Icon(Icons.lock_outline),
        title: const Text('Decision (Phase 3)'),
        subtitle: Text(item.subtitle),
        enabled: false,
      );
    }
    return ListTile(
      leading: const Icon(Icons.assignment),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      onTap: () => context.push('/inbox/${item.id}'),
    );
  }
}

/// inboxItemsProvider is overridden by tests and wired against the Ferry
/// Inbox query at app boot (T065).
final inboxItemsProvider =
    FutureProvider<List<InboxItemRef>>((ref) async => const []);
