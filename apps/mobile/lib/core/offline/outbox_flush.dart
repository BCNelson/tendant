import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity.dart';
import 'outbox.dart';

/// outboxDbProvider holds the drift database. Bootstrap-time override wires
/// a real OutboxDb (with NativeDatabase) when the app starts; tests can
/// override with an in-memory executor.
final outboxDbProvider = Provider<OutboxDb>(
  (ref) => throw UnimplementedError('outboxDbProvider must be overridden at app bootstrap'),
);

/// outboxFlushHandler is the per-mutation replay function. Bootstrap injects
/// the Ferry-backed implementation.
typedef OutboxReplay = Future<void> Function(OutboxEntry entry);

final outboxReplayProvider = Provider<OutboxReplay>(
  (ref) => (_) async => throw UnimplementedError('outboxReplayProvider must be overridden'),
);

/// startOutboxFlush listens on the connectivity provider and replays entries
/// in created_at order when the device transitions to online.
void startOutboxFlush(WidgetRef ref) {
  ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
    next.whenData((online) async {
      if (!online) return;
      final db = ref.read(outboxDbProvider);
      final replay = ref.read(outboxReplayProvider);
      final entries = await db.list();
      for (final e in entries) {
        try {
          await replay(e);
          await db.remove(e.id);
        } catch (_) {
          // Keep the row for the next online tick; transient errors retry.
        }
      }
    });
  });
}
