import 'package:drift/drift.dart';

part 'outbox.g.dart';

/// OutboxEntries is the on-device queue of low-stakes writes that ran offline.
/// On reconnect, outbox_flush.dart replays each entry against the Ferry
/// client. Last-write-wins per research R8.
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get op => text()();
  TextColumn get targetId => text()();
  TextColumn get argsJson => text()();
  IntColumn get createdAt => integer()();
}

@DriftDatabase(tables: [OutboxEntries])
class OutboxDb extends _$OutboxDb {
  OutboxDb(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> enqueue({
    required String op,
    required String targetId,
    required String argsJson,
  }) {
    return into(outboxEntries).insert(
      OutboxEntriesCompanion.insert(
        op: op,
        targetId: targetId,
        argsJson: argsJson,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<List<OutboxEntry>> list() =>
      (select(outboxEntries)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<int> remove(int id) =>
      (delete(outboxEntries)..where((t) => t.id.equals(id))).go();

  Future<int> count() async {
    final c = countAll();
    final row = await (selectOnly(outboxEntries)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }
}
