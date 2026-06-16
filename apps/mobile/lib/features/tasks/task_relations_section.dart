import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'tasks_models.dart';
import 'tasks_provider.dart';

/// TaskRelationsSection renders a task's place in the task graph: who blocks it,
/// what it blocks, its parent/subtasks, related links, and duplicate links —
/// each a tappable tile that deep-links to that task, with inline removal. An
/// "Add" affordance opens the relation composer.
class TaskRelationsSection extends ConsumerWidget {
  const TaskRelationsSection({super.key, required this.task});

  final TaskDetail task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = <Widget>[
      _RelationGroup(
        label: 'Blocked by',
        icon: Icons.block,
        links: task.blockedBy,
        // edge: blocker --blocks--> this
        onRemove: (l) => _remove(ref, from: l.id, to: task.id, kind: 'BLOCKS'),
      ),
      _RelationGroup(
        label: 'Blocks',
        icon: Icons.front_hand,
        links: task.blocks,
        // edge: this --blocks--> other
        onRemove: (l) => _remove(ref, from: task.id, to: l.id, kind: 'BLOCKS'),
      ),
      if (task.parent != null)
        _RelationGroup(
          label: 'Parent',
          icon: Icons.account_tree,
          links: [task.parent!],
          // edge: this --subtask_of--> parent
          onRemove: (l) =>
              _remove(ref, from: task.id, to: l.id, kind: 'SUBTASK_OF'),
        ),
      _RelationGroup(
        label: 'Subtasks',
        icon: Icons.list_alt,
        links: task.subtasks,
        // edge: child --subtask_of--> this
        onRemove: (l) =>
            _remove(ref, from: l.id, to: task.id, kind: 'SUBTASK_OF'),
      ),
      _RelationGroup(
        label: 'Related',
        icon: Icons.link,
        links: task.related,
        // related is stored in one direction only — try both on removal.
        onRemove: (l) => _removeRelated(ref, task.id, l.id),
      ),
      if (task.duplicateOf != null)
        _RelationGroup(
          label: 'Duplicate of',
          icon: Icons.copy_all,
          links: [task.duplicateOf!],
          // edge: this --duplicate_of--> canonical
          onRemove: (l) =>
              _remove(ref, from: task.id, to: l.id, kind: 'DUPLICATE_OF'),
        ),
      _RelationGroup(
        label: 'Duplicates',
        icon: Icons.content_copy,
        links: task.duplicates,
        // edge: dup --duplicate_of--> this
        onRemove: (l) =>
            _remove(ref, from: l.id, to: task.id, kind: 'DUPLICATE_OF'),
      ),
    ];

    final nonEmpty = groups.whereType<_RelationGroup>().where((g) =>
        g.links.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Dependencies & relations',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              onPressed: () => _showAddRelation(context, ref, task),
            ),
          ],
        ),
        if (nonEmpty.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('No relations yet.'),
          )
        else
          ...nonEmpty,
      ],
    );
  }

  Future<void> _remove(
    WidgetRef ref, {
    required String from,
    required String to,
    required String kind,
  }) async {
    final remove = await ref.read(removeTaskRelationProvider.future);
    await remove(fromTaskId: from, toTaskId: to, kind: kind);
    ref.invalidate(taskDetailProvider(task.id));
  }

  // A related edge is stored in whichever direction it was created; delete both
  // possibilities (DeleteTaskRelation is a no-op when no row matches).
  Future<void> _removeRelated(WidgetRef ref, String a, String b) async {
    final remove = await ref.read(removeTaskRelationProvider.future);
    await remove(fromTaskId: a, toTaskId: b, kind: 'RELATED');
    await remove(fromTaskId: b, toTaskId: a, kind: 'RELATED');
    ref.invalidate(taskDetailProvider(task.id));
  }

  Future<void> _showAddRelation(
      BuildContext context, WidgetRef ref, TaskDetail task) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AddRelationSheet(task: task),
      ),
    );
  }
}

class _RelationGroup extends StatelessWidget {
  const _RelationGroup({
    required this.label,
    required this.icon,
    required this.links,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final List<TaskLinkRef> links;
  final Future<void> Function(TaskLinkRef) onRemove;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        for (final l in links)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Icon(icon, size: 20),
            title: Text('#${l.shortId}  ${l.title}',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(l.state.toLowerCase()),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              onPressed: () => onRemove(l),
            ),
            onTap: () => context.push('/tasks/${l.id}'),
          ),
      ],
    );
  }
}

/// One option in the relation composer — a label phrased from the viewed task's
/// perspective, the server enum wire name, and whether the edge runs from the
/// chosen task back to the viewed task (reverse).
class _RelationOption {
  const _RelationOption(this.label, this.kind, this.reverse);
  final String label;
  final String kind; // server TaskRelationKind wire name
  final bool reverse; // true: chosen --kind--> this; false: this --kind--> chosen
}

const _relationOptions = <_RelationOption>[
  _RelationOption('Is blocked by', 'BLOCKS', true),
  _RelationOption('Blocks', 'BLOCKS', false),
  _RelationOption('Is a subtask of', 'SUBTASK_OF', false),
  _RelationOption('Has subtask', 'SUBTASK_OF', true),
  _RelationOption('Is related to', 'RELATED', false),
  _RelationOption('Is a duplicate of', 'DUPLICATE_OF', false),
  _RelationOption('Has duplicate', 'DUPLICATE_OF', true),
];

class _AddRelationSheet extends ConsumerStatefulWidget {
  const _AddRelationSheet({required this.task});
  final TaskDetail task;

  @override
  ConsumerState<_AddRelationSheet> createState() => _AddRelationSheetState();
}

class _AddRelationSheetState extends ConsumerState<_AddRelationSheet> {
  _RelationOption _option = _relationOptions.first;
  final _search = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _add(String otherId) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final add = await ref.read(addTaskRelationProvider.future);
      final from = _option.reverse ? otherId : widget.task.id;
      final to = _option.reverse ? widget.task.id : otherId;
      await add(fromTaskId: from, toTaskId: to, kind: _option.kind);
      ref.invalidate(taskDetailProvider(widget.task.id));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksListProvider(TasksFilter.all));
    final query = _search.text.trim().toLowerCase();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add relation', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('This task (#${widget.task.shortId})',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          DropdownButtonFormField<_RelationOption>(
            initialValue: _option,
            decoration: const InputDecoration(labelText: 'Relationship'),
            items: [
              for (final o in _relationOptions)
                DropdownMenuItem(value: o, child: Text(o.label)),
            ],
            onChanged: (v) =>
                setState(() => _option = v ?? _relationOptions.first),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Find task',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            height: 280,
            child: tasks.when(
              data: (list) {
                final candidates = [
                  for (final t in list)
                    if (t.id != widget.task.id &&
                        (query.isEmpty ||
                            t.title.toLowerCase().contains(query) ||
                            '#${t.shortId}'.contains(query)))
                      t,
                ];
                if (candidates.isEmpty) {
                  return const Center(child: Text('No matching tasks.'));
                }
                return ListView(
                  children: [
                    for (final t in candidates)
                      ListTile(
                        dense: true,
                        title: Text('#${t.shortId}  ${t.title}',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(t.state.toLowerCase()),
                        enabled: !_saving,
                        onTap: () => _add(t.id),
                      ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
