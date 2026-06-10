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
  String get title;
  String? get description;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  _i2.GAutonomyLevel get autonomy;
  _i2.GTaskPriority get priority;
  _i2.GTime? get dueAt;
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
