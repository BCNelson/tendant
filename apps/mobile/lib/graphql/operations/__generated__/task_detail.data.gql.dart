// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i3;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_detail.data.gql.g.dart';

abstract class GTaskDetailData
    implements Built<GTaskDetailData, GTaskDetailDataBuilder> {
  GTaskDetailData._();

  factory GTaskDetailData([void Function(GTaskDetailDataBuilder b) updates]) =
      _$GTaskDetailData;

  static void _initializeBuilder(GTaskDetailDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTaskDetailData_task? get task;
  static Serializer<GTaskDetailData> get serializer =>
      _$gTaskDetailDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData.serializer,
        json,
      );
}

abstract class GTaskDetailData_task
    implements Built<GTaskDetailData_task, GTaskDetailData_taskBuilder> {
  GTaskDetailData_task._();

  factory GTaskDetailData_task(
          [void Function(GTaskDetailData_taskBuilder b) updates]) =
      _$GTaskDetailData_task;

  static void _initializeBuilder(GTaskDetailData_taskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  String? get description;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  _i2.GAutonomyLevel get autonomy;
  _i2.GTaskPriority get priority;
  _i2.GTime? get dueAt;
  _i2.GTime? get startsAt;
  double? get rank;
  bool get blocked;
  BuiltList<GTaskDetailData_task_blockedBy> get blockedBy;
  BuiltList<GTaskDetailData_task_blocks> get blocks;
  GTaskDetailData_task_parent? get parent;
  BuiltList<GTaskDetailData_task_subtasks> get subtasks;
  BuiltList<GTaskDetailData_task_related> get related;
  GTaskDetailData_task_duplicateOf? get duplicateOf;
  BuiltList<GTaskDetailData_task_duplicates> get duplicates;
  _i3.JsonObject? get findings;
  BuiltList<GTaskDetailData_task_stageSlots> get stageSlots;
  BuiltList<GTaskDetailData_task_activity> get activity;
  static Serializer<GTaskDetailData_task> get serializer =>
      _$gTaskDetailDataTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_blockedBy
    implements
        Built<GTaskDetailData_task_blockedBy,
            GTaskDetailData_task_blockedByBuilder>,
        GTaskLink {
  GTaskDetailData_task_blockedBy._();

  factory GTaskDetailData_task_blockedBy(
          [void Function(GTaskDetailData_task_blockedByBuilder b) updates]) =
      _$GTaskDetailData_task_blockedBy;

  static void _initializeBuilder(GTaskDetailData_task_blockedByBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_blockedBy> get serializer =>
      _$gTaskDetailDataTaskBlockedBySerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_blockedBy.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_blockedBy? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_blockedBy.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_blocks
    implements
        Built<GTaskDetailData_task_blocks, GTaskDetailData_task_blocksBuilder>,
        GTaskLink {
  GTaskDetailData_task_blocks._();

  factory GTaskDetailData_task_blocks(
          [void Function(GTaskDetailData_task_blocksBuilder b) updates]) =
      _$GTaskDetailData_task_blocks;

  static void _initializeBuilder(GTaskDetailData_task_blocksBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_blocks> get serializer =>
      _$gTaskDetailDataTaskBlocksSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_blocks.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_blocks? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_blocks.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_parent
    implements
        Built<GTaskDetailData_task_parent, GTaskDetailData_task_parentBuilder>,
        GTaskLink {
  GTaskDetailData_task_parent._();

  factory GTaskDetailData_task_parent(
          [void Function(GTaskDetailData_task_parentBuilder b) updates]) =
      _$GTaskDetailData_task_parent;

  static void _initializeBuilder(GTaskDetailData_task_parentBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_parent> get serializer =>
      _$gTaskDetailDataTaskParentSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_parent.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_parent? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_parent.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_subtasks
    implements
        Built<GTaskDetailData_task_subtasks,
            GTaskDetailData_task_subtasksBuilder>,
        GTaskLink {
  GTaskDetailData_task_subtasks._();

  factory GTaskDetailData_task_subtasks(
          [void Function(GTaskDetailData_task_subtasksBuilder b) updates]) =
      _$GTaskDetailData_task_subtasks;

  static void _initializeBuilder(GTaskDetailData_task_subtasksBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_subtasks> get serializer =>
      _$gTaskDetailDataTaskSubtasksSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_subtasks.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_subtasks? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_subtasks.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_related
    implements
        Built<GTaskDetailData_task_related,
            GTaskDetailData_task_relatedBuilder>,
        GTaskLink {
  GTaskDetailData_task_related._();

  factory GTaskDetailData_task_related(
          [void Function(GTaskDetailData_task_relatedBuilder b) updates]) =
      _$GTaskDetailData_task_related;

  static void _initializeBuilder(GTaskDetailData_task_relatedBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_related> get serializer =>
      _$gTaskDetailDataTaskRelatedSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_related.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_related? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_related.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_duplicateOf
    implements
        Built<GTaskDetailData_task_duplicateOf,
            GTaskDetailData_task_duplicateOfBuilder>,
        GTaskLink {
  GTaskDetailData_task_duplicateOf._();

  factory GTaskDetailData_task_duplicateOf(
          [void Function(GTaskDetailData_task_duplicateOfBuilder b) updates]) =
      _$GTaskDetailData_task_duplicateOf;

  static void _initializeBuilder(GTaskDetailData_task_duplicateOfBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_duplicateOf> get serializer =>
      _$gTaskDetailDataTaskDuplicateOfSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_duplicateOf.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_duplicateOf? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_duplicateOf.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_duplicates
    implements
        Built<GTaskDetailData_task_duplicates,
            GTaskDetailData_task_duplicatesBuilder>,
        GTaskLink {
  GTaskDetailData_task_duplicates._();

  factory GTaskDetailData_task_duplicates(
          [void Function(GTaskDetailData_task_duplicatesBuilder b) updates]) =
      _$GTaskDetailData_task_duplicates;

  static void _initializeBuilder(GTaskDetailData_task_duplicatesBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskDetailData_task_duplicates> get serializer =>
      _$gTaskDetailDataTaskDuplicatesSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_duplicates.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_duplicates? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_duplicates.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_stageSlots
    implements
        Built<GTaskDetailData_task_stageSlots,
            GTaskDetailData_task_stageSlotsBuilder> {
  GTaskDetailData_task_stageSlots._();

  factory GTaskDetailData_task_stageSlots(
          [void Function(GTaskDetailData_task_stageSlotsBuilder b) updates]) =
      _$GTaskDetailData_task_stageSlots;

  static void _initializeBuilder(GTaskDetailData_task_stageSlotsBuilder b) =>
      b..G__typename = 'StageSlot';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GAgentStage get stage;
  bool get isHuman;
  GTaskDetailData_task_stageSlots_occupant? get occupant;
  static Serializer<GTaskDetailData_task_stageSlots> get serializer =>
      _$gTaskDetailDataTaskStageSlotsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_stageSlots.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_stageSlots? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_stageSlots.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_stageSlots_occupant
    implements
        Built<GTaskDetailData_task_stageSlots_occupant,
            GTaskDetailData_task_stageSlots_occupantBuilder> {
  GTaskDetailData_task_stageSlots_occupant._();

  factory GTaskDetailData_task_stageSlots_occupant(
      [void Function(GTaskDetailData_task_stageSlots_occupantBuilder b)
          updates]) = _$GTaskDetailData_task_stageSlots_occupant;

  static void _initializeBuilder(
          GTaskDetailData_task_stageSlots_occupantBuilder b) =>
      b..G__typename = 'AgentConfigSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  String? get model;
  static Serializer<GTaskDetailData_task_stageSlots_occupant> get serializer =>
      _$gTaskDetailDataTaskStageSlotsOccupantSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_stageSlots_occupant.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_stageSlots_occupant? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_stageSlots_occupant.serializer,
        json,
      );
}

abstract class GTaskDetailData_task_activity
    implements
        Built<GTaskDetailData_task_activity,
            GTaskDetailData_task_activityBuilder> {
  GTaskDetailData_task_activity._();

  factory GTaskDetailData_task_activity(
          [void Function(GTaskDetailData_task_activityBuilder b) updates]) =
      _$GTaskDetailData_task_activity;

  static void _initializeBuilder(GTaskDetailData_task_activityBuilder b) =>
      b..G__typename = 'ActivityEvent';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get kind;
  _i2.GTime get at;
  String get actor;
  String? get inReplyTo;
  _i3.JsonObject? get detail;
  static Serializer<GTaskDetailData_task_activity> get serializer =>
      _$gTaskDetailDataTaskActivitySerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailData_task_activity.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailData_task_activity? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailData_task_activity.serializer,
        json,
      );
}

abstract class GTaskLink {
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  _i2.GTaskState get state;
  Map<String, dynamic> toJson();
}

abstract class GTaskLinkData
    implements Built<GTaskLinkData, GTaskLinkDataBuilder>, GTaskLink {
  GTaskLinkData._();

  factory GTaskLinkData([void Function(GTaskLinkDataBuilder b) updates]) =
      _$GTaskLinkData;

  static void _initializeBuilder(GTaskLinkDataBuilder b) =>
      b..G__typename = 'Task';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  int get shortId;
  @override
  String get title;
  @override
  _i2.GTaskState get state;
  static Serializer<GTaskLinkData> get serializer => _$gTaskLinkDataSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskLinkData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskLinkData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskLinkData.serializer,
        json,
      );
}
