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
  /// The server-side `TaskState` enum name this filter maps to, or null when the
  /// filter issues an unfiltered query. `active` and `all` both map to null —
  /// they share one fetch, and `active` hides terminal tasks client-side — so
  /// the two views can never diverge. The per-state filters map straight to the
  /// matching server enum name. (Ferry-free twin of bootstrap's `_serverState`.)
  String? get serverStateName {
    switch (this) {
      case TasksFilter.active:
      case TasksFilter.all:
        return null;
      case TasksFilter.proposed:
        return 'PROPOSED';
      case TasksFilter.accepted:
        return 'ACCEPTED';
      case TasksFilter.waiting:
        return 'WAITING';
      case TasksFilter.executing:
        return 'EXECUTING';
      case TasksFilter.done:
        return 'DONE';
      case TasksFilter.dismissed:
        return 'DISMISSED';
      case TasksFilter.halted:
        return 'HALTED';
    }
  }

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
  final int shortId; // short, human-facing task number (#N), distinct from id
  final String title;
  final String state; // TaskState, e.g. EXECUTING
  final String currentStage; // ChainStage, e.g. EXECUTION
  final String autonomy; // AutonomyLevel
  final bool hasOpenAssignment;
  final List<TaskStageOccupancy> stageSlots;

  const TaskRef({
    required this.id,
    required this.shortId,
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

/// TaskLinkRef is a lightweight reference to a task on the other end of a
/// relation edge (blocker, subtask, parent, related, duplicate). Just enough to
/// render a tappable tile that deep-links to that task's detail page.
class TaskLinkRef {
  final String id;
  final int shortId;
  final String title;
  final String state;

  const TaskLinkRef({
    required this.id,
    required this.shortId,
    required this.title,
    required this.state,
  });
}

/// The four directed task↔task relation kinds (server `TaskRelationKind`).
enum TaskRelationKind { blocks, subtaskOf, related, duplicateOf }

extension TaskRelationKindWire on TaskRelationKind {
  /// The server enum name (e.g. BLOCKS, SUBTASK_OF).
  String get wire {
    switch (this) {
      case TaskRelationKind.blocks:
        return 'BLOCKS';
      case TaskRelationKind.subtaskOf:
        return 'SUBTASK_OF';
      case TaskRelationKind.related:
        return 'RELATED';
      case TaskRelationKind.duplicateOf:
        return 'DUPLICATE_OF';
    }
  }

  /// Human-facing label for the add-relation picker, phrased as "this task ___
  /// the chosen task" (the edge is from this task → the chosen task).
  String get pickerLabel {
    switch (this) {
      case TaskRelationKind.blocks:
        return 'Blocks';
      case TaskRelationKind.subtaskOf:
        return 'Is a subtask of';
      case TaskRelationKind.related:
        return 'Is related to';
      case TaskRelationKind.duplicateOf:
        return 'Is a duplicate of';
    }
  }
}

/// Full detail for one task: header, scheduling, the task-graph relations, stage
/// occupancy, the agent output (findings), and the complete activity timeline.
class TaskDetail {
  final String id;
  final int shortId; // short, human-facing task number (#N), distinct from id
  final String title;
  final String? description;
  final String state;
  final String currentStage;
  final String autonomy;
  final String priority; // TaskPriority, e.g. NORMAL
  final DateTime? dueAt; // optional deadline (local time)
  final DateTime? startsAt; // optional earliest-start, gates eligibility
  final double? rank; // optional manual ordering weight (lower sorts first)
  final bool blocked; // unmet blockers or a future startsAt
  final List<TaskLinkRef> blockedBy; // must clear before this task can execute
  final List<TaskLinkRef> blocks; // tasks this task blocks
  final TaskLinkRef? parent; // parent task, if this is a subtask
  final List<TaskLinkRef> subtasks; // child subtasks
  final List<TaskLinkRef> related; // non-blocking related tasks
  final TaskLinkRef? duplicateOf; // canonical task this one duplicates
  final List<TaskLinkRef> duplicates; // tasks marked duplicates of this one
  final Map<String, dynamic> findings;
  final List<TaskStageOccupancy> stageSlots;
  final List<ActivityEventRef> activity;

  const TaskDetail({
    required this.id,
    required this.shortId,
    required this.title,
    this.description,
    required this.state,
    required this.currentStage,
    required this.autonomy,
    this.priority = 'NORMAL',
    this.dueAt,
    this.startsAt,
    this.rank,
    this.blocked = false,
    this.blockedBy = const [],
    this.blocks = const [],
    this.parent,
    this.subtasks = const [],
    this.related = const [],
    this.duplicateOf,
    this.duplicates = const [],
    required this.findings,
    required this.stageSlots,
    required this.activity,
  });
}
