import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing_models.dart';
import 'routing_provider.dart';

/// Read-only page showing per-stage slot occupants and routing decisions.
///
/// Phase 6: displays which specialist (or the human) holds each occupied stage
/// for a given task, plus the derived autonomy level.
class RoutingDetailPage extends ConsumerWidget {
  final String taskId;

  const RoutingDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(taskStageSlotsProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: const Text('Routing')),
      body: slotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (slots) => _buildSlotList(slots),
      ),
    );
  }

  Widget _buildSlotList(List<StageSlotView> slots) {
    if (slots.isEmpty) {
      return const Center(
        child: Text('No routing data available yet.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) => _SlotCard(slot: slots[index]),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final StageSlotView slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final stageName = slot.stage.name.toUpperCase();
    final occupantLabel = slot.isHuman
        ? 'Human (owner)'
        : slot.occupant?.name ?? 'Unknown specialist';
    final icon = slot.isHuman ? Icons.person : Icons.smart_toy;
    final color = slot.isHuman ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(stageName),
        subtitle: Text(occupantLabel),
        trailing: slot.isHuman
            ? const Chip(label: Text('Human'))
            : Chip(
                label: Text(slot.occupant?.origin ?? 'core'),
                backgroundColor: Colors.green.shade50,
              ),
      ),
    );
  }
}
