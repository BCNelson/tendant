/// View models for the Phase 6 routing/specialist read-only views.
///
/// These are presentation-layer types, separate from ferry-generated types.

enum AgentStageView { triage, expansion, execution }

class AgentConfigView {
  final String id;
  final String name;
  final AgentStageView stage;
  final bool isHuman;
  final String? model;
  final String origin;
  final int version;

  const AgentConfigView({
    required this.id,
    required this.name,
    required this.stage,
    required this.isHuman,
    this.model,
    required this.origin,
    required this.version,
  });
}

class StageSlotView {
  final AgentStageView stage;
  final AgentConfigView? occupant;
  final bool isHuman;

  const StageSlotView({
    required this.stage,
    this.occupant,
    required this.isHuman,
  });
}

class RoutingDecisionView {
  final AgentStageView stage;
  final List<AgentConfigView> eligibleSet;
  final AgentConfigView? picked;
  final bool pickedHuman;

  const RoutingDecisionView({
    required this.stage,
    required this.eligibleSet,
    this.picked,
    required this.pickedHuman,
  });
}
