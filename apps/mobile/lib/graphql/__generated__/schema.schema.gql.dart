// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i1;
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i3;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'schema.schema.gql.g.dart';

abstract class GSetTaskCategoryInput
    implements Built<GSetTaskCategoryInput, GSetTaskCategoryInputBuilder> {
  GSetTaskCategoryInput._();

  factory GSetTaskCategoryInput(
          [void Function(GSetTaskCategoryInputBuilder b) updates]) =
      _$GSetTaskCategoryInput;

  String get key;
  String? get label;
  String? get description;
  String? get parent;
  _i1.JsonObject? get stageBindings;
  static Serializer<GSetTaskCategoryInput> get serializer =>
      _$gSetTaskCategoryInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GSetTaskCategoryInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetTaskCategoryInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GSetTaskCategoryInput.serializer,
        json,
      );
}

abstract class GBytes implements Built<GBytes, GBytesBuilder> {
  GBytes._();

  factory GBytes([String? value]) =>
      _$GBytes((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GBytes> get serializer =>
      _i3.DefaultScalarSerializer<GBytes>(
          (Object serialized) => GBytes((serialized as String?)));
}

class GGateScriptTier extends EnumClass {
  const GGateScriptTier._(String name) : super(name);

  static const GGateScriptTier ASSEMBLYSCRIPT_IN_APP =
      _$gGateScriptTierASSEMBLYSCRIPT_IN_APP;

  static const GGateScriptTier BYO_WASM = _$gGateScriptTierBYO_WASM;

  static Serializer<GGateScriptTier> get serializer =>
      _$gGateScriptTierSerializer;

  static BuiltSet<GGateScriptTier> get values => _$gGateScriptTierValues;

  static GGateScriptTier valueOf(String name) => _$gGateScriptTierValueOf(name);
}

class GGateScriptStatus extends EnumClass {
  const GGateScriptStatus._(String name) : super(name);

  static const GGateScriptStatus ACTIVE = _$gGateScriptStatusACTIVE;

  static const GGateScriptStatus DISABLED = _$gGateScriptStatusDISABLED;

  static Serializer<GGateScriptStatus> get serializer =>
      _$gGateScriptStatusSerializer;

  static BuiltSet<GGateScriptStatus> get values => _$gGateScriptStatusValues;

  static GGateScriptStatus valueOf(String name) =>
      _$gGateScriptStatusValueOf(name);
}

abstract class GTime implements Built<GTime, GTimeBuilder> {
  GTime._();

  factory GTime([String? value]) =>
      _$GTime((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GTime> get serializer => _i3.DefaultScalarSerializer<GTime>(
      (Object serialized) => GTime((serialized as String?)));
}

class GTaskState extends EnumClass {
  const GTaskState._(String name) : super(name);

  static const GTaskState PROPOSED = _$gTaskStatePROPOSED;

  static const GTaskState ACCEPTED = _$gTaskStateACCEPTED;

  static const GTaskState WAITING = _$gTaskStateWAITING;

  static const GTaskState EXECUTING = _$gTaskStateEXECUTING;

  static const GTaskState DONE = _$gTaskStateDONE;

  static const GTaskState DISMISSED = _$gTaskStateDISMISSED;

  static const GTaskState HALTED = _$gTaskStateHALTED;

  static Serializer<GTaskState> get serializer => _$gTaskStateSerializer;

  static BuiltSet<GTaskState> get values => _$gTaskStateValues;

  static GTaskState valueOf(String name) => _$gTaskStateValueOf(name);
}

class GChainStage extends EnumClass {
  const GChainStage._(String name) : super(name);

  static const GChainStage CREATION = _$gChainStageCREATION;

  static const GChainStage TRIAGE = _$gChainStageTRIAGE;

  static const GChainStage EXPANSION = _$gChainStageEXPANSION;

  static const GChainStage EXECUTION = _$gChainStageEXECUTION;

  static const GChainStage COMPLETION = _$gChainStageCOMPLETION;

  static Serializer<GChainStage> get serializer => _$gChainStageSerializer;

  static BuiltSet<GChainStage> get values => _$gChainStageValues;

  static GChainStage valueOf(String name) => _$gChainStageValueOf(name);
}

class GAutonomyLevel extends EnumClass {
  const GAutonomyLevel._(String name) : super(name);

  static const GAutonomyLevel NONE = _$gAutonomyLevelNONE;

  static const GAutonomyLevel ENRICH_ONLY = _$gAutonomyLevelENRICH_ONLY;

  static const GAutonomyLevel PROPOSE = _$gAutonomyLevelPROPOSE;

  static const GAutonomyLevel EXECUTE_GATED = _$gAutonomyLevelEXECUTE_GATED;

  static const GAutonomyLevel EXECUTE_AUTO = _$gAutonomyLevelEXECUTE_AUTO;

  static Serializer<GAutonomyLevel> get serializer =>
      _$gAutonomyLevelSerializer;

  static BuiltSet<GAutonomyLevel> get values => _$gAutonomyLevelValues;

  static GAutonomyLevel valueOf(String name) => _$gAutonomyLevelValueOf(name);
}

class GTaskPriority extends EnumClass {
  const GTaskPriority._(String name) : super(name);

  static const GTaskPriority LOW = _$gTaskPriorityLOW;

  static const GTaskPriority NORMAL = _$gTaskPriorityNORMAL;

  static const GTaskPriority HIGH = _$gTaskPriorityHIGH;

  static const GTaskPriority URGENT = _$gTaskPriorityURGENT;

  static Serializer<GTaskPriority> get serializer => _$gTaskPrioritySerializer;

  static BuiltSet<GTaskPriority> get values => _$gTaskPriorityValues;

  static GTaskPriority valueOf(String name) => _$gTaskPriorityValueOf(name);
}

class GDevicePlatform extends EnumClass {
  const GDevicePlatform._(String name) : super(name);

  static const GDevicePlatform IOS = _$gDevicePlatformIOS;

  static const GDevicePlatform ANDROID = _$gDevicePlatformANDROID;

  static const GDevicePlatform WEB = _$gDevicePlatformWEB;

  static Serializer<GDevicePlatform> get serializer =>
      _$gDevicePlatformSerializer;

  static BuiltSet<GDevicePlatform> get values => _$gDevicePlatformValues;

  static GDevicePlatform valueOf(String name) => _$gDevicePlatformValueOf(name);
}

class GGuidanceScope extends EnumClass {
  const GGuidanceScope._(String name) : super(name);

  static const GGuidanceScope GLOBAL = _$gGuidanceScopeGLOBAL;

  static const GGuidanceScope AGENT = _$gGuidanceScopeAGENT;

  static Serializer<GGuidanceScope> get serializer =>
      _$gGuidanceScopeSerializer;

  static BuiltSet<GGuidanceScope> get values => _$gGuidanceScopeValues;

  static GGuidanceScope valueOf(String name) => _$gGuidanceScopeValueOf(name);
}

class GAgentStage extends EnumClass {
  const GAgentStage._(String name) : super(name);

  static const GAgentStage TRIAGE = _$gAgentStageTRIAGE;

  static const GAgentStage EXPANSION = _$gAgentStageEXPANSION;

  static const GAgentStage EXECUTION = _$gAgentStageEXECUTION;

  static Serializer<GAgentStage> get serializer => _$gAgentStageSerializer;

  static BuiltSet<GAgentStage> get values => _$gAgentStageValues;

  static GAgentStage valueOf(String name) => _$gAgentStageValueOf(name);
}

const Map<String, Set<String>> possibleTypesMap = {
  'PendingDecision': {
    'ApprovalRequest',
    'AgentQuestion',
    'PromotionProposal',
    'FeedbackRequest',
  },
  'Principal': {
    'User',
    'Bot',
  },
  'ApprovalPayload': {
    'Artifact',
    'Mandate',
  },
  'InboxItem': {
    'ApprovalRequest',
    'AgentQuestion',
    'PromotionProposal',
    'AgentAssignment',
    'FeedbackRequest',
    'ActionableTask',
  },
};
