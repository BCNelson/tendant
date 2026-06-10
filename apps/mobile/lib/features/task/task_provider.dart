import 'package:flutter_riverpod/flutter_riverpod.dart';

/// taskChangedProvider watches taskChanged(taskId) and emits a monotonically
/// increasing tick per event. The value is a distinct counter — not the event
/// payload — because Riverpod suppresses `ref.listen` callbacks for
/// repeat-equal `AsyncData`, so two byte-identical payloads would drop the
/// second refresh. The bootstrap layer overrides it against the Ferry
/// subscription.
final taskChangedProvider =
    StreamProvider.family<int, String>((ref, taskId) async* {
  // No emissions until the bootstrap layer overrides this provider.
});
