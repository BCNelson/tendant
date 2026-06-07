import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing_models.dart';

/// Provider for task stage slots. Returns the list of stage slots for a task.
///
/// Phase 6: backed by the `Task.stageSlots` GraphQL field once ferry codegen
/// is wired. For now uses a stub that returns empty until the query is generated.
final taskStageSlotsProvider =
    FutureProvider.family<List<StageSlotView>, String>((ref, taskId) async {
  // TODO: Wire to ferry-generated GraphQL query for Task.stageSlots.
  // For now, return empty (the schema field exists but the client query
  // needs ferry codegen to be run against the updated schema).
  return [];
});

/// Provider for the agent config catalog.
final agentConfigsProvider =
    FutureProvider.family<List<AgentConfigView>, AgentStageView?>(
        (ref, stage) async {
  // TODO: Wire to ferry-generated GraphQL query for agentConfigs(stage:).
  return [];
});
