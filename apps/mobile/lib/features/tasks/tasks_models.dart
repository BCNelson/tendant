/// Presentation-layer models for the Tasks view — all current tasks plus a
/// live read on which agent (or the human) is occupying each chain stage.
library;

import '../routing/routing_models.dart' show AgentStageView;

/// TasksFilter drives the Tasks list. `active` (the default) hides terminal
/// tasks client-side (the server `state` arg is single-valued, so "in-flight"
/// can't be expressed as one filter); the per-state values map straight to the
/// server filter.
enum TasksFilter {
  active,
  all,
  proposed,
  accepted,
  waiting,
  executing,
  done,
  dismissed,
  halted,
}

extension TasksFilterLabel on TasksFilter {
  String get label {
    switch (this) {
      case TasksFilter.active:
        return 'Active';
      case TasksFilter.all:
        return 'All';
      case TasksFilter.proposed:
        return 'Proposed';
      case TasksFilter.accepted:
        return 'Accepted';
      case TasksFilter.waiting:
        return 'Waiting';
      case TasksFilter.executing:
        return 'Executing';
      case TasksFilter.done:
        return 'Done';
      case TasksFilter.dismissed:
        return 'Dismissed';
      case TasksFilter.halted:
        return 'Halted';
    }
  }
}

/// One stage's occupancy as rendered in the Tasks list. `isHuman` true means the
/// owner holds the stage; otherwise `occupantName` names the specialist (null
/// until the stage is reached).
class TaskStageOccupancy {
  final AgentStageView stage;
  final bool isHuman;
  final String? occupantName;
  final String? occupantModel;

  const TaskStageOccupancy({
    required this.stage,
    required this.isHuman,
    this.occupantName,
    this.occupantModel,
  });

  bool get isOccupied => isHuman || occupantName != null;
}

/// TaskRef is the lightweight shape the tasks provider hands to the UI.
class TaskRef {
  final String id;
  final String title;
  final String state; // TaskState, e.g. EXECUTING
  final String currentStage; // ChainStage, e.g. EXECUTION
  final String autonomy; // AutonomyLevel
  final bool hasOpenAssignment;
  final List<TaskStageOccupancy> stageSlots;

  const TaskRef({
    required this.id,
    required this.title,
    required this.state,
    required this.currentStage,
    required this.autonomy,
    required this.hasOpenAssignment,
    required this.stageSlots,
  });

  bool get isTerminal =>
      state == 'DONE' || state == 'DISMISSED' || state == 'HALTED';

  /// The slot for the stage the task currently occupies, when that stage is an
  /// agent-occupiable one (CREATION / COMPLETION have no slot → null).
  TaskStageOccupancy? get activeSlot {
    final cs = currentStage.toLowerCase();
    for (final s in stageSlots) {
      if (s.stage.name == cs) return s;
    }
    return null;
  }
}

/// One row of a task's audit DAG — an agent run, a tool-call step, a stage
/// advance, etc. `detail` is the raw typed payload for the kind.
class ActivityEventRef {
  final String id;
  final String kind;
  final String at; // ISO-8601 timestamp string
  final String actor;
  final String? inReplyTo;
  final Map<String, dynamic> detail;

  const ActivityEventRef({
    required this.id,
    required this.kind,
    required this.at,
    required this.actor,
    this.inReplyTo,
    this.detail = const {},
  });
}

/// Full detail for one task: header, stage occupancy, the agent output
/// (findings), and the complete activity timeline.
class TaskDetail {
  final String id;
  final String title;
  final String? description;
  final String state;
  final String currentStage;
  final String autonomy;
  final Map<String, dynamic> findings;
  final List<TaskStageOccupancy> stageSlots;
  final List<ActivityEventRef> activity;

  const TaskDetail({
    required this.id,
    required this.title,
    this.description,
    required this.state,
    required this.currentStage,
    required this.autonomy,
    required this.findings,
    required this.stageSlots,
    required this.activity,
  });
}
