import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/core/offline/outbox.dart';

void main() {
  test('enqueue stores a row; remove deletes it', () async {
    final db = OutboxDb(NativeDatabase.memory());
    expect(await db.count(), 0);

    final id = await db.enqueue(
      op: 'dismissProposedTask',
      targetId: 't1',
      argsJson: '{"reason":"manual"}',
    );
    expect(id, isPositive);
    expect(await db.count(), 1);

    final rows = await db.list();
    expect(rows.single.op, 'dismissProposedTask');
    expect(rows.single.targetId, 't1');

    await db.remove(id);
    expect(await db.count(), 0);
  });

  test('list is ordered by created_at ASC', () async {
    final db = OutboxDb(NativeDatabase.memory());
    await db.enqueue(op: 'a', targetId: 't1', argsJson: '{}');
    await Future.delayed(const Duration(milliseconds: 5));
    await db.enqueue(op: 'b', targetId: 't2', argsJson: '{}');

    final rows = await db.list();
    expect(rows.first.op, 'a');
    expect(rows.last.op, 'b');
  });
}
