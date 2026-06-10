import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'tasks_models.dart';
import 'tasks_provider.dart';

/// TasksPage renders all current tasks with a live read on which agent (or the
/// human) is working each task right now. It refreshes automatically as the
/// `taskChanged` subscription fires (agent run start/finish, stage advance,
/// completion). The state filter defaults to Active (in-flight tasks only).
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  // Default to All: agents auto-complete tasks within seconds, so an Active-only
  // default shows an empty list in steady state (every task is already DONE).
  TasksFilter _filter = TasksFilter.all;

  @override
  Widget build(BuildContext context) {
    // Any task change → refetch the underlying list so the live agent view
    // stays current. Invalidate `rawTasksProvider` (the network layer); the
    // derived `tasksListProvider` views rebuild from it consistently.
    ref.listen(allTasksChangedProvider, (_, __) {
      ref.invalidate(rawTasksProvider);
    });

    final tasks = ref.watch(tasksListProvider(_filter));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<TasksFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            initialValue: _filter,
            onSelected: (f) => setState(() => _filter = f),
            itemBuilder: (_) => [
              for (final f in TasksFilter.values)
                PopupMenuItem(value: f, child: Text(f.label)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(rawTasksProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasks-fab',
        tooltip: 'New task',
        onPressed: () => context.push('/create-task'),
        child: const Icon(Icons.add),
      ),
      body: tasks.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text('No ${_filter.label.toLowerCase()} tasks.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(rawTasksProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => TaskTile(task: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// TaskTile renders one task row: a leading icon for who's working it (a running
/// specialist, the human, or terminal/idle), the title, a stage · agent
/// subtitle, and a state pill.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final TaskRef task;

  @override
  Widget build(BuildContext context) {
    final slot = task.activeSlot;
    final running = !task.isTerminal && slot != null && slot.isOccupied;

    // Leading icon: a running specialist, the human, a terminal check, or idle.
    final IconData icon;
    final Color? iconColor;
    if (task.isTerminal) {
      icon = Icons.check_circle_outline;
      iconColor = Colors.grey;
    } else if (running && slot.isHuman) {
      icon = Icons.person;
      iconColor = Theme.of(context).colorScheme.primary;
    } else if (running) {
      icon = Icons.smart_toy;
      iconColor = Theme.of(context).colorScheme.primary;
    } else {
      icon = Icons.radio_button_unchecked;
      iconColor = null;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(task.title),
      subtitle: Text(_subtitle(task, slot)),
      trailing: _StatePill(state: task.state),
      onTap: () => context.push('/tasks/${task.id}'),
    );
  }

  String _subtitle(TaskRef task, TaskStageOccupancy? slot) {
    final stage = task.currentStage;
    if (task.isTerminal) return stage;
    if (slot == null) return stage;
    if (slot.isHuman) return '$stage · waiting on you';
    if (slot.occupantName != null) {
      return '$stage · ${slot.occupantName}';
    }
    return stage;
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool terminal =
        state == 'DONE' || state == 'DISMISSED' || state == 'HALTED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: terminal ? scheme.surfaceContainerHighest : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        state,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
