// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_changed_subscription.data.gql.g.dart';

abstract class GTaskChangedData
    implements Built<GTaskChangedData, GTaskChangedDataBuilder> {
  GTaskChangedData._();

  factory GTaskChangedData([void Function(GTaskChangedDataBuilder b) updates]) =
      _$GTaskChangedData;

  static void _initializeBuilder(GTaskChangedDataBuilder b) =>
      b..G__typename = 'Subscription';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTaskChangedData_taskChanged get taskChanged;
  static Serializer<GTaskChangedData> get serializer =>
      _$gTaskChangedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData.serializer,
        json,
      );
}

abstract class GTaskChangedData_taskChanged
    implements
        Built<GTaskChangedData_taskChanged,
            GTaskChangedData_taskChangedBuilder> {
  GTaskChangedData_taskChanged._();

  factory GTaskChangedData_taskChanged(
          [void Function(GTaskChangedData_taskChangedBuilder b) updates]) =
      _$GTaskChangedData_taskChanged;

  static void _initializeBuilder(GTaskChangedData_taskChangedBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  _i2.GAutonomyLevel get autonomy;
  _i2.GTaskPriority get priority;
  _i2.GTime? get dueAt;
  GTaskChangedData_taskChanged_openAssignment? get openAssignment;
  BuiltList<GTaskChangedData_taskChanged_stageSlots> get stageSlots;
  static Serializer<GTaskChangedData_taskChanged> get serializer =>
      _$gTaskChangedDataTaskChangedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData_taskChanged.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData_taskChanged? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData_taskChanged.serializer,
        json,
      );
}

abstract class GTaskChangedData_taskChanged_openAssignment
    implements
        Built<GTaskChangedData_taskChanged_openAssignment,
            GTaskChangedData_taskChanged_openAssignmentBuilder> {
  GTaskChangedData_taskChanged_openAssignment._();

  factory GTaskChangedData_taskChanged_openAssignment(
      [void Function(GTaskChangedData_taskChanged_openAssignmentBuilder b)
          updates]) = _$GTaskChangedData_taskChanged_openAssignment;

  static void _initializeBuilder(
          GTaskChangedData_taskChanged_openAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GTaskChangedData_taskChanged_openAssignment>
      get serializer => _$gTaskChangedDataTaskChangedOpenAssignmentSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData_taskChanged_openAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData_taskChanged_openAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData_taskChanged_openAssignment.serializer,
        json,
      );
}

abstract class GTaskChangedData_taskChanged_stageSlots
    implements
        Built<GTaskChangedData_taskChanged_stageSlots,
            GTaskChangedData_taskChanged_stageSlotsBuilder> {
  GTaskChangedData_taskChanged_stageSlots._();

  factory GTaskChangedData_taskChanged_stageSlots(
      [void Function(GTaskChangedData_taskChanged_stageSlotsBuilder b)
          updates]) = _$GTaskChangedData_taskChanged_stageSlots;

  static void _initializeBuilder(
          GTaskChangedData_taskChanged_stageSlotsBuilder b) =>
      b..G__typename = 'StageSlot';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GAgentStage get stage;
  bool get isHuman;
  GTaskChangedData_taskChanged_stageSlots_occupant? get occupant;
  static Serializer<GTaskChangedData_taskChanged_stageSlots> get serializer =>
      _$gTaskChangedDataTaskChangedStageSlotsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData_taskChanged_stageSlots.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData_taskChanged_stageSlots? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData_taskChanged_stageSlots.serializer,
        json,
      );
}

abstract class GTaskChangedData_taskChanged_stageSlots_occupant
    implements
        Built<GTaskChangedData_taskChanged_stageSlots_occupant,
            GTaskChangedData_taskChanged_stageSlots_occupantBuilder> {
  GTaskChangedData_taskChanged_stageSlots_occupant._();

  factory GTaskChangedData_taskChanged_stageSlots_occupant(
      [void Function(GTaskChangedData_taskChanged_stageSlots_occupantBuilder b)
          updates]) = _$GTaskChangedData_taskChanged_stageSlots_occupant;

  static void _initializeBuilder(
          GTaskChangedData_taskChanged_stageSlots_occupantBuilder b) =>
      b..G__typename = 'AgentConfigSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  String? get model;
  static Serializer<GTaskChangedData_taskChanged_stageSlots_occupant>
      get serializer =>
          _$gTaskChangedDataTaskChangedStageSlotsOccupantSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData_taskChanged_stageSlots_occupant.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData_taskChanged_stageSlots_occupant? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData_taskChanged_stageSlots_occupant.serializer,
        json,
      );
}
