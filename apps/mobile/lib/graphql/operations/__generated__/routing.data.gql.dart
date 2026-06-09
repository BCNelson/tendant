// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'routing.data.gql.g.dart';

abstract class GTaskStageSlotsData
    implements Built<GTaskStageSlotsData, GTaskStageSlotsDataBuilder> {
  GTaskStageSlotsData._();

  factory GTaskStageSlotsData(
          [void Function(GTaskStageSlotsDataBuilder b) updates]) =
      _$GTaskStageSlotsData;

  static void _initializeBuilder(GTaskStageSlotsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTaskStageSlotsData_task? get task;
  static Serializer<GTaskStageSlotsData> get serializer =>
      _$gTaskStageSlotsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskStageSlotsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskStageSlotsData.serializer,
        json,
      );
}

abstract class GTaskStageSlotsData_task
    implements
        Built<GTaskStageSlotsData_task, GTaskStageSlotsData_taskBuilder> {
  GTaskStageSlotsData_task._();

  factory GTaskStageSlotsData_task(
          [void Function(GTaskStageSlotsData_taskBuilder b) updates]) =
      _$GTaskStageSlotsData_task;

  static void _initializeBuilder(GTaskStageSlotsData_taskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  BuiltList<GTaskStageSlotsData_task_stageSlots> get stageSlots;
  static Serializer<GTaskStageSlotsData_task> get serializer =>
      _$gTaskStageSlotsDataTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskStageSlotsData_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsData_task? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskStageSlotsData_task.serializer,
        json,
      );
}

abstract class GTaskStageSlotsData_task_stageSlots
    implements
        Built<GTaskStageSlotsData_task_stageSlots,
            GTaskStageSlotsData_task_stageSlotsBuilder> {
  GTaskStageSlotsData_task_stageSlots._();

  factory GTaskStageSlotsData_task_stageSlots(
      [void Function(GTaskStageSlotsData_task_stageSlotsBuilder b)
          updates]) = _$GTaskStageSlotsData_task_stageSlots;

  static void _initializeBuilder(
          GTaskStageSlotsData_task_stageSlotsBuilder b) =>
      b..G__typename = 'StageSlot';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GAgentStage get stage;
  bool get isHuman;
  GTaskStageSlotsData_task_stageSlots_occupant? get occupant;
  static Serializer<GTaskStageSlotsData_task_stageSlots> get serializer =>
      _$gTaskStageSlotsDataTaskStageSlotsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskStageSlotsData_task_stageSlots.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsData_task_stageSlots? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskStageSlotsData_task_stageSlots.serializer,
        json,
      );
}

abstract class GTaskStageSlotsData_task_stageSlots_occupant
    implements
        Built<GTaskStageSlotsData_task_stageSlots_occupant,
            GTaskStageSlotsData_task_stageSlots_occupantBuilder> {
  GTaskStageSlotsData_task_stageSlots_occupant._();

  factory GTaskStageSlotsData_task_stageSlots_occupant(
      [void Function(GTaskStageSlotsData_task_stageSlots_occupantBuilder b)
          updates]) = _$GTaskStageSlotsData_task_stageSlots_occupant;

  static void _initializeBuilder(
          GTaskStageSlotsData_task_stageSlots_occupantBuilder b) =>
      b..G__typename = 'AgentConfigSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  _i2.GAgentStage get stage;
  bool get isHuman;
  String? get model;
  String get origin;
  int get version;
  static Serializer<GTaskStageSlotsData_task_stageSlots_occupant>
      get serializer => _$gTaskStageSlotsDataTaskStageSlotsOccupantSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskStageSlotsData_task_stageSlots_occupant.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsData_task_stageSlots_occupant? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskStageSlotsData_task_stageSlots_occupant.serializer,
        json,
      );
}

abstract class GAgentConfigsData
    implements Built<GAgentConfigsData, GAgentConfigsDataBuilder> {
  GAgentConfigsData._();

  factory GAgentConfigsData(
          [void Function(GAgentConfigsDataBuilder b) updates]) =
      _$GAgentConfigsData;

  static void _initializeBuilder(GAgentConfigsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GAgentConfigsData_agentConfigs> get agentConfigs;
  static Serializer<GAgentConfigsData> get serializer =>
      _$gAgentConfigsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentConfigsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentConfigsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentConfigsData.serializer,
        json,
      );
}

abstract class GAgentConfigsData_agentConfigs
    implements
        Built<GAgentConfigsData_agentConfigs,
            GAgentConfigsData_agentConfigsBuilder> {
  GAgentConfigsData_agentConfigs._();

  factory GAgentConfigsData_agentConfigs(
          [void Function(GAgentConfigsData_agentConfigsBuilder b) updates]) =
      _$GAgentConfigsData_agentConfigs;

  static void _initializeBuilder(GAgentConfigsData_agentConfigsBuilder b) =>
      b..G__typename = 'AgentConfigSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  _i2.GAgentStage get stage;
  bool get isHuman;
  String? get model;
  String get origin;
  int get version;
  static Serializer<GAgentConfigsData_agentConfigs> get serializer =>
      _$gAgentConfigsDataAgentConfigsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentConfigsData_agentConfigs.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentConfigsData_agentConfigs? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentConfigsData_agentConfigs.serializer,
        json,
      );
}
