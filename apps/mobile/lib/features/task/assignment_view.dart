import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../inbox/inbox_provider.dart' show inboxFeedProvider;

/// AssignmentDetail is the shape the page consumes — populated by the
/// generated Ferry AgentAssignment query in T065.
class AssignmentDetail {
  const AssignmentDetail({
    required this.id,
    required this.taskId,
    required this.ask,
  });

  final String id;
  final String taskId;
  final String ask;
}

/// assignmentProvider is overridden by tests and wired against the Ferry
/// AgentAssignment(id:) query at app boot (T065).
final assignmentProvider =
    FutureProvider.family<AssignmentDetail?, String>((ref, id) async => null);

/// completeTaskProvider is overridden by tests and wired against the Ferry
/// CompleteTask mutation at app boot.
typedef CompleteTaskFn = Future<void> Function(String taskId);

final completeTaskProvider = FutureProvider<CompleteTaskFn>(
  (ref) async => (_) async {
    throw UnimplementedError(
      'completeTaskProvider not wired — override in main/app bootstrap',
    );
  },
);

class AssignmentView extends ConsumerStatefulWidget {
  const AssignmentView({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<AssignmentView> createState() => _AssignmentViewState();
}

class _AssignmentViewState extends ConsumerState<AssignmentView> {
  bool _completing = false;
  String? _error;

  Future<void> _complete(AssignmentDetail a) async {
    setState(() {
      _completing = true;
      _error = null;
    });
    try {
      final fn = await ref.read(completeTaskProvider.future);
      await fn(a.taskId);
      // Drop this just-completed assignment from the cached inbox so it
      // doesn't reappear when we navigate back. The backend closes the
      // assignment synchronously, so the refetch will exclude it.
      ref.invalidate(inboxFeedProvider);
      if (mounted) context.go('/inbox');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asn = ref.watch(assignmentProvider(widget.assignmentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment')),
      body: asn.when(
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Assignment not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Ask', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(a.ask),
                const Spacer(),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _completing ? null : () => _complete(a),
                  child: Text(_completing ? 'Completing…' : 'Complete'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
