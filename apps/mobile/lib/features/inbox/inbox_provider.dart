import 'package:flutter_riverpod/flutter_riverpod.dart';

/// inboxStreamProvider is the live inbox feed. The bootstrap layer overrides
/// it with the Ferry inbox query + InboxItemArrived subscription (T077).
/// Until codegen lands the override is a no-op (single empty-list emission)
/// so the UI is still testable.
final inboxStreamProvider = StreamProvider<List<dynamic>>((ref) async* {
  yield const [];
});
