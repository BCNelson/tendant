import 'package:flutter_riverpod/flutter_riverpod.dart';

/// inboxArrivedProvider emits whenever a new inbox item arrives (the
/// `inboxItemArrived` subscription). The Inbox view listens to it and refetches
/// the list live, mirroring how the Tasks view uses `allTasksChangedProvider`.
/// Stubbed here; the bootstrap layer overrides it against the Ferry
/// subscription.
final inboxArrivedProvider = StreamProvider<void>((ref) async* {
  // No emissions until overridden in the bootstrap layer.
});
