import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CreateTaskFn composes a new owner-authored task via the `createTask`
/// mutation. Only `title` is required; `description`, `priority` (one of
/// LOW/NORMAL/HIGH/URGENT — null → server default NORMAL), and `dueAt` (an
/// optional deadline) are all optional metadata.
typedef CreateTaskFn = Future<void> Function({
  required String title,
  String? description,
  String? priority,
  DateTime? dueAt,
});

/// createTaskProvider is a stub until the bootstrap layer overrides it against
/// the Ferry `CreateTask` operation (see core/bootstrap.dart). Without the
/// override it throws, matching completeTaskProvider's contract.
final createTaskProvider = FutureProvider<CreateTaskFn>(
  (ref) async => ({
    required String title,
    String? description,
    String? priority,
    DateTime? dueAt,
  }) async {
    throw UnimplementedError(
      'createTaskProvider not wired — override in core/bootstrap.dart',
    );
  },
);
