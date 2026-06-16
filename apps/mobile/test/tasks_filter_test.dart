import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/tasks/tasks_models.dart';
import 'package:tendant/features/tasks/tasks_provider.dart';

TaskRef _task(String id, String state) => TaskRef(
      id: id,
      shortId: 1,
      title: 'task-$id',
      state: state,
      currentStage: 'EXECUTION',
      autonomy: 'NONE',
      hasOpenAssignment: false,
      stageSlots: const [],
    );

void main() {
  // A list mixing in-flight and terminal tasks, as the unfiltered server query
  // (state == null) returns it. "Active" and "All" derive from this one list.
  final mixed = [
    _task('a', 'PROPOSED'),
    _task('b', 'EXECUTING'),
    _task('c', 'DONE'),
    _task('d', 'WAITING'),
    _task('e', 'DISMISSED'),
    _task('f', 'HALTED'),
  ];

  ProviderContainer containerWith(List<TaskRef> raw) => ProviderContainer(
        overrides: [
          // Both `active` and `all` map to serverStateName == null, so this one
          // override backs both views — proving they share a single stream.
          rawTasksProvider.overrideWith((ref, serverState) => Stream.value(raw)),
        ],
      );

  test('All returns the full unfiltered list', () async {
    final c = containerWith(mixed);
    addTearDown(c.dispose);

    // Keep the stream alive (Riverpod 3 disposes unlistened providers) and
    // await its first emission before reading the derived view.
    c.listen(rawTasksProvider(null), (_, __) {});
    await c.read(rawTasksProvider(null).future);
    final all = c.read(tasksListProvider(TasksFilter.all)).requireValue;
    expect(all.map((t) => t.id), ['a', 'b', 'c', 'd', 'e', 'f']);
  });

  test('Active returns exactly the non-terminal subset', () async {
    final c = containerWith(mixed);
    addTearDown(c.dispose);

    c.listen(rawTasksProvider(null), (_, __) {});
    await c.read(rawTasksProvider(null).future);
    final active = c.read(tasksListProvider(TasksFilter.active)).requireValue;
    expect(active.map((t) => t.id), ['a', 'b', 'd']);
    expect(active.every((t) => !t.isTerminal), isTrue);
  });

  test('Active is always a subset of All (the regression invariant)', () async {
    final c = containerWith(mixed);
    addTearDown(c.dispose);

    c.listen(rawTasksProvider(null), (_, __) {});
    await c.read(rawTasksProvider(null).future);
    final all = c.read(tasksListProvider(TasksFilter.all)).requireValue;
    final active = c.read(tasksListProvider(TasksFilter.active)).requireValue;

    final allIds = all.map((t) => t.id).toSet();
    for (final t in active) {
      expect(allIds, contains(t.id),
          reason: 'task ${t.id} is in Active but missing from All');
    }
  });

  test('active and all map to the same server query key', () {
    expect(TasksFilter.active.serverStateName, isNull);
    expect(TasksFilter.all.serverStateName, isNull);
    expect(TasksFilter.done.serverStateName, 'DONE');
    expect(TasksFilter.proposed.serverStateName, 'PROPOSED');
  });
}
