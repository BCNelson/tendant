import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasks_models.dart';

/// tasksListProvider resolves the current tasks for a [TasksFilter]. Stubbed
/// here; the bootstrap layer overrides it against the Ferry `Tasks` query.
final tasksListProvider =
    FutureProvider.family<List<TaskRef>, TasksFilter>((ref, filter) async {
  return const [];
});

/// allTasksChangedProvider emits whenever any task changes (the `taskChanged`
/// subscription with no taskId). The Tasks view listens to it to refresh the
/// list live as agents start/finish stages and tasks advance. Stubbed here; the
/// bootstrap layer overrides it against the Ferry subscription.
final allTasksChangedProvider = StreamProvider<void>((ref) async* {
  // No emissions until overridden in the bootstrap layer.
});

/// taskDetailProvider resolves the full detail (header + stage slots + findings
/// + activity timeline) for one task. Stubbed; the bootstrap layer overrides it
/// against the Ferry `TaskDetail` query.
final taskDetailProvider =
    FutureProvider.family<TaskDetail?, String>((ref, id) async {
  return null;
});
