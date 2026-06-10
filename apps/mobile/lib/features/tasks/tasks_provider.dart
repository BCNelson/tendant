import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasks_models.dart';

/// rawTasksProvider fetches the task list for a server-side `TaskState` filter
/// (null = no filter / every state). Keyed by the *server query*, not the UI
/// filter, so "Active" and "All" (which both issue the unfiltered query) share
/// one fetch and one cache and can never diverge. Stubbed here; the bootstrap
/// layer overrides it against the Ferry `Tasks` query.
final rawTasksProvider =
    FutureProvider.family<List<TaskRef>, String?>((ref, serverState) async {
  return const [];
});

/// tasksListProvider resolves the current tasks for a [TasksFilter]. It is a
/// pure derivation over [rawTasksProvider] keyed by the filter's server state,
/// so `active` and `all` read the same underlying fetch; `active` then hides
/// terminal tasks client-side (the server `state` arg is single-valued, so
/// "in-flight" can't be expressed as one server filter). Not overridden in
/// bootstrap — only the underlying `rawTasksProvider` is.
final tasksListProvider =
    FutureProvider.family<List<TaskRef>, TasksFilter>((ref, filter) async {
  final raw = await ref.watch(rawTasksProvider(filter.serverStateName).future);
  if (filter == TasksFilter.active) {
    return [for (final t in raw) if (!t.isTerminal) t];
  }
  return raw;
});

/// allTasksChangedProvider emits a monotonically increasing tick whenever any
/// task changes (the `taskChanged` subscription with no taskId). The Tasks view
/// listens to it to refresh the list live as agents start/finish stages and
/// tasks advance. The value is a distinct counter — not `void` — because
/// Riverpod suppresses `ref.listen` callbacks for repeat-equal `AsyncData`, so
/// a constant value would only ever trigger the first refresh and then go
/// stale. Stubbed here; the bootstrap layer overrides it against the Ferry
/// subscription.
final allTasksChangedProvider = StreamProvider<int>((ref) async* {
  // No emissions until overridden in the bootstrap layer.
});

/// taskDetailProvider resolves the full detail (header + stage slots + findings
/// + activity timeline) for one task. Stubbed; the bootstrap layer overrides it
/// against the Ferry `TaskDetail` query.
final taskDetailProvider =
    FutureProvider.family<TaskDetail?, String>((ref, id) async {
  return null;
});

/// UpdateTaskMetadataFn edits a task's owner-set metadata after creation.
/// `priority` is one of LOW/NORMAL/HIGH/URGENT; `dueAt` null clears any
/// existing deadline ("replace" semantics, matching the server mutation).
typedef UpdateTaskMetadataFn = Future<void> Function(
  String taskId, {
  required String priority,
  DateTime? dueAt,
});

/// updateTaskMetadataProvider exposes the `updateTaskMetadata` mutation.
/// Stubbed here; the bootstrap layer overrides it against the Ferry op.
final updateTaskMetadataProvider = FutureProvider<UpdateTaskMetadataFn>(
  (ref) async => (_, {required String priority, DateTime? dueAt}) async {
    throw UnimplementedError(
      'updateTaskMetadataProvider not wired — override in core/bootstrap.dart',
    );
  },
);
