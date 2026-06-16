import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasks_models.dart';

/// rawTasksProvider streams the task list for a server-side `TaskState` filter
/// (null = no filter / every state). Keyed by the *server query*, not the UI
/// filter, so "Active" and "All" (which both issue the unfiltered query) share
/// one fetch and one cache and can never diverge. It is a Stream because the
/// bootstrap override watches the Ferry `Tasks` request against the normalized
/// cache (CacheAndNetwork): it emits cached rows instantly, then the network
/// result, then re-emits automatically whenever a referenced Task changes in
/// the cache (e.g. a `taskChanged` subscription merge) — so agent stage moves
/// and state transitions surface live with no manual refetch. List *membership*
/// (a brand-new task) still arrives via the signal-driven invalidate in the
/// Tasks view. Stubbed here; bootstrap overrides it.
final rawTasksProvider =
    StreamProvider.family<List<TaskRef>, String?>((ref, serverState) {
  return Stream.value(const <TaskRef>[]);
});

/// tasksListProvider resolves the current tasks for a [TasksFilter]. It is a
/// pure derivation over [rawTasksProvider] keyed by the filter's server state,
/// so `active` and `all` read the same underlying stream; `active` then hides
/// terminal tasks client-side (the server `state` arg is single-valued, so
/// "in-flight" can't be expressed as one server filter). Passes through the
/// underlying AsyncValue (loading/error preserved). Not overridden in
/// bootstrap — only the underlying `rawTasksProvider` is.
final tasksListProvider =
    Provider.family<AsyncValue<List<TaskRef>>, TasksFilter>((ref, filter) {
  final raw = ref.watch(rawTasksProvider(filter.serverStateName));
  return raw.whenData((list) {
    if (filter == TasksFilter.active) {
      return [for (final t in list) if (!t.isTerminal) t];
    }
    return list;
  });
});

/// allTasksChangedProvider emits a monotonically increasing tick whenever any
/// task changes (the `taskChanged` subscription with no taskId). Two jobs: it
/// keeps the data-carrying subscription alive so each change merges into the
/// normalized cache (driving [rawTasksProvider]'s automatic re-emit), and the
/// Tasks view listens to it to invalidate for list *membership* (new tasks).
/// The value is a distinct counter so Riverpod doesn't suppress repeat-equal
/// `AsyncData`. Stubbed here; the bootstrap layer overrides it.
final allTasksChangedProvider = StreamProvider<int>((ref) async* {
  // No emissions until overridden in the bootstrap layer.
});

/// taskDetailProvider streams the full detail (header + stage slots + findings
/// + activity timeline) for one task from the normalized cache. Header/stage
/// fields re-emit automatically on a `taskChanged` merge; the activity timeline
/// (a list) refreshes via the signal-driven invalidate in the detail view.
/// Stubbed; the bootstrap layer overrides it against the Ferry `TaskDetail`
/// request.
final taskDetailProvider =
    StreamProvider.family<TaskDetail?, String>((ref, id) {
  return Stream.value(null);
});

/// UpdateTaskMetadataFn edits a task's owner-set metadata after creation.
/// `priority` is one of LOW/NORMAL/HIGH/URGENT; `dueAt`/`startsAt`/`rank` null
/// clears the corresponding field ("replace" semantics, matching the server
/// mutation — the form always sends the desired final state).
typedef UpdateTaskMetadataFn = Future<void> Function(
  String taskId, {
  required String priority,
  DateTime? dueAt,
  DateTime? startsAt,
  double? rank,
});

/// updateTaskMetadataProvider exposes the `updateTaskMetadata` mutation.
/// Stubbed here; the bootstrap layer overrides it against the Ferry op.
final updateTaskMetadataProvider = FutureProvider<UpdateTaskMetadataFn>(
  (ref) async => (
    _, {
    required String priority,
    DateTime? dueAt,
    DateTime? startsAt,
    double? rank,
  }) async {
    throw UnimplementedError(
      'updateTaskMetadataProvider not wired — override in core/bootstrap.dart',
    );
  },
);

/// AddTaskRelationFn adds a directed relation `fromTaskId --kind--> toTaskId`
/// via the `addTaskRelation` mutation. `kind` is the server enum wire name
/// (BLOCKS / SUBTASK_OF / RELATED / DUPLICATE_OF). Throws on server rejection
/// (self-link, duplicate, cycle, second parent/canonical).
typedef AddTaskRelationFn = Future<void> Function({
  required String fromTaskId,
  required String toTaskId,
  required String kind,
});

/// addTaskRelationProvider exposes `addTaskRelation`. Stubbed; bootstrap
/// overrides it against the Ferry op.
final addTaskRelationProvider = FutureProvider<AddTaskRelationFn>(
  (ref) async => ({
    required String fromTaskId,
    required String toTaskId,
    required String kind,
  }) async {
    throw UnimplementedError(
      'addTaskRelationProvider not wired — override in core/bootstrap.dart',
    );
  },
);

/// RemoveTaskRelationFn removes a directed relation via `removeTaskRelation`.
typedef RemoveTaskRelationFn = Future<void> Function({
  required String fromTaskId,
  required String toTaskId,
  required String kind,
});

/// removeTaskRelationProvider exposes `removeTaskRelation`. Stubbed; bootstrap
/// overrides it against the Ferry op.
final removeTaskRelationProvider = FutureProvider<RemoveTaskRelationFn>(
  (ref) async => ({
    required String fromTaskId,
    required String toTaskId,
    required String kind,
  }) async {
    throw UnimplementedError(
      'removeTaskRelationProvider not wired — override in core/bootstrap.dart',
    );
  },
);
