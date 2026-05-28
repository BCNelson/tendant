import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/connectivity.dart';
import '../../core/offline/floor_rail.dart';

/// FloorRelevantStubPage is a debug-only screen exercising the floor rail.
/// When offline + a floor-relevant action is attempted, the rail refuses
/// (no outbox row created). When online, the (stubbed) mutation is sent
/// and Phase 2's server returns NOT_YET_AVAILABLE — surfaced as a polite
/// error banner.
class FloorRelevantStubPage extends ConsumerWidget {
  const FloorRelevantStubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug-only page.')),
      );
    }
    final online = ref.watch(connectivityProvider).value ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: floor-relevant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(online ? 'ONLINE' : 'OFFLINE'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _attempt(context, ref, online),
              child: const Text('Submit (approveArtifact stub)'),
            ),
          ],
        ),
      ),
    );
  }

  void _attempt(BuildContext context, WidgetRef ref, bool online) {
    if (classify('approveArtifact') == WriteClass.floorRelevant && !online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Floor-relevant actions require a network connection. '
            'This draft is not saved.',
          ),
        ),
      );
      return;
    }
    // Online: in Phase 2 the server returns NOT_YET_AVAILABLE.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'approveArtifact returns NOT_YET_AVAILABLE in Phase 2.',
        ),
      ),
    );
  }
}
