import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CreateTaskFn composes a new owner-authored task via the `createTask`
/// mutation. `description` is optional (null/empty → no description).
typedef CreateTaskFn = Future<void> Function({
  required String title,
  String? description,
});

/// createTaskProvider is a stub until the bootstrap layer overrides it against
/// the Ferry `CreateTask` operation (see core/bootstrap.dart). Without the
/// override it throws, matching completeTaskProvider's contract.
final createTaskProvider = FutureProvider<CreateTaskFn>(
  (ref) async => ({required String title, String? description}) async {
    throw UnimplementedError(
      'createTaskProvider not wired — override in core/bootstrap.dart',
    );
  },
);
