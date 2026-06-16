// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i3;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'agent_assignment.data.gql.g.dart';

abstract class GAgentAssignmentData
    implements Built<GAgentAssignmentData, GAgentAssignmentDataBuilder> {
  GAgentAssignmentData._();

  factory GAgentAssignmentData(
          [void Function(GAgentAssignmentDataBuilder b) updates]) =
      _$GAgentAssignmentData;

  static void _initializeBuilder(GAgentAssignmentDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GAgentAssignmentData_agentAssignment? get agentAssignment;
  static Serializer<GAgentAssignmentData> get serializer =>
      _$gAgentAssignmentDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentAssignmentData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentAssignmentData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentAssignmentData.serializer,
        json,
      );
}

abstract class GAgentAssignmentData_agentAssignment
    implements
        Built<GAgentAssignmentData_agentAssignment,
            GAgentAssignmentData_agentAssignmentBuilder> {
  GAgentAssignmentData_agentAssignment._();

  factory GAgentAssignmentData_agentAssignment(
      [void Function(GAgentAssignmentData_agentAssignmentBuilder b)
          updates]) = _$GAgentAssignmentData_agentAssignment;

  static void _initializeBuilder(
          GAgentAssignmentData_agentAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GChainStage get stage;
  String get ask;
  _i3.JsonObject? get gatheredContext;
  _i2.GTime get createdAt;
  GAgentAssignmentData_agentAssignment_task get task;
  static Serializer<GAgentAssignmentData_agentAssignment> get serializer =>
      _$gAgentAssignmentDataAgentAssignmentSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentAssignmentData_agentAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentAssignmentData_agentAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentAssignmentData_agentAssignment.serializer,
        json,
      );
}

abstract class GAgentAssignmentData_agentAssignment_task
    implements
        Built<GAgentAssignmentData_agentAssignment_task,
            GAgentAssignmentData_agentAssignment_taskBuilder> {
  GAgentAssignmentData_agentAssignment_task._();

  factory GAgentAssignmentData_agentAssignment_task(
      [void Function(GAgentAssignmentData_agentAssignment_taskBuilder b)
          updates]) = _$GAgentAssignmentData_agentAssignment_task;

  static void _initializeBuilder(
          GAgentAssignmentData_agentAssignment_taskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  String? get description;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  static Serializer<GAgentAssignmentData_agentAssignment_task> get serializer =>
      _$gAgentAssignmentDataAgentAssignmentTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentAssignmentData_agentAssignment_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentAssignmentData_agentAssignment_task? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentAssignmentData_agentAssignment_task.serializer,
        json,
      );
}
