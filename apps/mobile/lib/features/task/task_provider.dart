import 'package:flutter_riverpod/flutter_riverpod.dart';

/// taskChangedProvider watches taskChanged(taskId) and emits each event.
/// The bootstrap layer overrides it against the Ferry subscription.
final taskChangedProvider =
    StreamProvider.family<dynamic, String>((ref, taskId) async* {
  // No emissions until the bootstrap layer overrides this provider.
});
