// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.schema.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GGateScriptTier _$gGateScriptTierASSEMBLYSCRIPT_IN_APP =
    const GGateScriptTier._('ASSEMBLYSCRIPT_IN_APP');
const GGateScriptTier _$gGateScriptTierBYO_WASM =
    const GGateScriptTier._('BYO_WASM');

GGateScriptTier _$gGateScriptTierValueOf(String name) {
  switch (name) {
    case 'ASSEMBLYSCRIPT_IN_APP':
      return _$gGateScriptTierASSEMBLYSCRIPT_IN_APP;
    case 'BYO_WASM':
      return _$gGateScriptTierBYO_WASM;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GGateScriptTier> _$gGateScriptTierValues =
    BuiltSet<GGateScriptTier>(const <GGateScriptTier>[
  _$gGateScriptTierASSEMBLYSCRIPT_IN_APP,
  _$gGateScriptTierBYO_WASM,
]);

const GGateScriptStatus _$gGateScriptStatusACTIVE =
    const GGateScriptStatus._('ACTIVE');
const GGateScriptStatus _$gGateScriptStatusDISABLED =
    const GGateScriptStatus._('DISABLED');

GGateScriptStatus _$gGateScriptStatusValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$gGateScriptStatusACTIVE;
    case 'DISABLED':
      return _$gGateScriptStatusDISABLED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GGateScriptStatus> _$gGateScriptStatusValues =
    BuiltSet<GGateScriptStatus>(const <GGateScriptStatus>[
  _$gGateScriptStatusACTIVE,
  _$gGateScriptStatusDISABLED,
]);

const GTaskRelationKind _$gTaskRelationKindBLOCKS =
    const GTaskRelationKind._('BLOCKS');
const GTaskRelationKind _$gTaskRelationKindSUBTASK_OF =
    const GTaskRelationKind._('SUBTASK_OF');
const GTaskRelationKind _$gTaskRelationKindRELATED =
    const GTaskRelationKind._('RELATED');
const GTaskRelationKind _$gTaskRelationKindDUPLICATE_OF =
    const GTaskRelationKind._('DUPLICATE_OF');

GTaskRelationKind _$gTaskRelationKindValueOf(String name) {
  switch (name) {
    case 'BLOCKS':
      return _$gTaskRelationKindBLOCKS;
    case 'SUBTASK_OF':
      return _$gTaskRelationKindSUBTASK_OF;
    case 'RELATED':
      return _$gTaskRelationKindRELATED;
    case 'DUPLICATE_OF':
      return _$gTaskRelationKindDUPLICATE_OF;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GTaskRelationKind> _$gTaskRelationKindValues =
    BuiltSet<GTaskRelationKind>(const <GTaskRelationKind>[
  _$gTaskRelationKindBLOCKS,
  _$gTaskRelationKindSUBTASK_OF,
  _$gTaskRelationKindRELATED,
  _$gTaskRelationKindDUPLICATE_OF,
]);

const GTaskState _$gTaskStatePROPOSED = const GTaskState._('PROPOSED');
const GTaskState _$gTaskStateACCEPTED = const GTaskState._('ACCEPTED');
const GTaskState _$gTaskStateWAITING = const GTaskState._('WAITING');
const GTaskState _$gTaskStateEXECUTING = const GTaskState._('EXECUTING');
const GTaskState _$gTaskStateDONE = const GTaskState._('DONE');
const GTaskState _$gTaskStateDISMISSED = const GTaskState._('DISMISSED');
const GTaskState _$gTaskStateHALTED = const GTaskState._('HALTED');

GTaskState _$gTaskStateValueOf(String name) {
  switch (name) {
    case 'PROPOSED':
      return _$gTaskStatePROPOSED;
    case 'ACCEPTED':
      return _$gTaskStateACCEPTED;
    case 'WAITING':
      return _$gTaskStateWAITING;
    case 'EXECUTING':
      return _$gTaskStateEXECUTING;
    case 'DONE':
      return _$gTaskStateDONE;
    case 'DISMISSED':
      return _$gTaskStateDISMISSED;
    case 'HALTED':
      return _$gTaskStateHALTED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GTaskState> _$gTaskStateValues =
    BuiltSet<GTaskState>(const <GTaskState>[
  _$gTaskStatePROPOSED,
  _$gTaskStateACCEPTED,
  _$gTaskStateWAITING,
  _$gTaskStateEXECUTING,
  _$gTaskStateDONE,
  _$gTaskStateDISMISSED,
  _$gTaskStateHALTED,
]);

const GChainStage _$gChainStageCREATION = const GChainStage._('CREATION');
const GChainStage _$gChainStageTRIAGE = const GChainStage._('TRIAGE');
const GChainStage _$gChainStageEXPANSION = const GChainStage._('EXPANSION');
const GChainStage _$gChainStageEXECUTION = const GChainStage._('EXECUTION');
const GChainStage _$gChainStageCOMPLETION = const GChainStage._('COMPLETION');

GChainStage _$gChainStageValueOf(String name) {
  switch (name) {
    case 'CREATION':
      return _$gChainStageCREATION;
    case 'TRIAGE':
      return _$gChainStageTRIAGE;
    case 'EXPANSION':
      return _$gChainStageEXPANSION;
    case 'EXECUTION':
      return _$gChainStageEXECUTION;
    case 'COMPLETION':
      return _$gChainStageCOMPLETION;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GChainStage> _$gChainStageValues =
    BuiltSet<GChainStage>(const <GChainStage>[
  _$gChainStageCREATION,
  _$gChainStageTRIAGE,
  _$gChainStageEXPANSION,
  _$gChainStageEXECUTION,
  _$gChainStageCOMPLETION,
]);

const GAutonomyLevel _$gAutonomyLevelNONE = const GAutonomyLevel._('NONE');
const GAutonomyLevel _$gAutonomyLevelENRICH_ONLY =
    const GAutonomyLevel._('ENRICH_ONLY');
const GAutonomyLevel _$gAutonomyLevelPROPOSE =
    const GAutonomyLevel._('PROPOSE');
const GAutonomyLevel _$gAutonomyLevelEXECUTE_GATED =
    const GAutonomyLevel._('EXECUTE_GATED');
const GAutonomyLevel _$gAutonomyLevelEXECUTE_AUTO =
    const GAutonomyLevel._('EXECUTE_AUTO');

GAutonomyLevel _$gAutonomyLevelValueOf(String name) {
  switch (name) {
    case 'NONE':
      return _$gAutonomyLevelNONE;
    case 'ENRICH_ONLY':
      return _$gAutonomyLevelENRICH_ONLY;
    case 'PROPOSE':
      return _$gAutonomyLevelPROPOSE;
    case 'EXECUTE_GATED':
      return _$gAutonomyLevelEXECUTE_GATED;
    case 'EXECUTE_AUTO':
      return _$gAutonomyLevelEXECUTE_AUTO;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GAutonomyLevel> _$gAutonomyLevelValues =
    BuiltSet<GAutonomyLevel>(const <GAutonomyLevel>[
  _$gAutonomyLevelNONE,
  _$gAutonomyLevelENRICH_ONLY,
  _$gAutonomyLevelPROPOSE,
  _$gAutonomyLevelEXECUTE_GATED,
  _$gAutonomyLevelEXECUTE_AUTO,
]);

const GTaskPriority _$gTaskPriorityLOW = const GTaskPriority._('LOW');
const GTaskPriority _$gTaskPriorityNORMAL = const GTaskPriority._('NORMAL');
const GTaskPriority _$gTaskPriorityHIGH = const GTaskPriority._('HIGH');
const GTaskPriority _$gTaskPriorityURGENT = const GTaskPriority._('URGENT');

GTaskPriority _$gTaskPriorityValueOf(String name) {
  switch (name) {
    case 'LOW':
      return _$gTaskPriorityLOW;
    case 'NORMAL':
      return _$gTaskPriorityNORMAL;
    case 'HIGH':
      return _$gTaskPriorityHIGH;
    case 'URGENT':
      return _$gTaskPriorityURGENT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GTaskPriority> _$gTaskPriorityValues =
    BuiltSet<GTaskPriority>(const <GTaskPriority>[
  _$gTaskPriorityLOW,
  _$gTaskPriorityNORMAL,
  _$gTaskPriorityHIGH,
  _$gTaskPriorityURGENT,
]);

const GDevicePlatform _$gDevicePlatformIOS = const GDevicePlatform._('IOS');
const GDevicePlatform _$gDevicePlatformANDROID =
    const GDevicePlatform._('ANDROID');
const GDevicePlatform _$gDevicePlatformWEB = const GDevicePlatform._('WEB');

GDevicePlatform _$gDevicePlatformValueOf(String name) {
  switch (name) {
    case 'IOS':
      return _$gDevicePlatformIOS;
    case 'ANDROID':
      return _$gDevicePlatformANDROID;
    case 'WEB':
      return _$gDevicePlatformWEB;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GDevicePlatform> _$gDevicePlatformValues =
    BuiltSet<GDevicePlatform>(const <GDevicePlatform>[
  _$gDevicePlatformIOS,
  _$gDevicePlatformANDROID,
  _$gDevicePlatformWEB,
]);

const GGuidanceScope _$gGuidanceScopeGLOBAL = const GGuidanceScope._('GLOBAL');
const GGuidanceScope _$gGuidanceScopeAGENT = const GGuidanceScope._('AGENT');

GGuidanceScope _$gGuidanceScopeValueOf(String name) {
  switch (name) {
    case 'GLOBAL':
      return _$gGuidanceScopeGLOBAL;
    case 'AGENT':
      return _$gGuidanceScopeAGENT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GGuidanceScope> _$gGuidanceScopeValues =
    BuiltSet<GGuidanceScope>(const <GGuidanceScope>[
  _$gGuidanceScopeGLOBAL,
  _$gGuidanceScopeAGENT,
]);

const GAgentStage _$gAgentStageTRIAGE = const GAgentStage._('TRIAGE');
const GAgentStage _$gAgentStageEXPANSION = const GAgentStage._('EXPANSION');
const GAgentStage _$gAgentStageEXECUTION = const GAgentStage._('EXECUTION');

GAgentStage _$gAgentStageValueOf(String name) {
  switch (name) {
    case 'TRIAGE':
      return _$gAgentStageTRIAGE;
    case 'EXPANSION':
      return _$gAgentStageEXPANSION;
    case 'EXECUTION':
      return _$gAgentStageEXECUTION;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GAgentStage> _$gAgentStageValues =
    BuiltSet<GAgentStage>(const <GAgentStage>[
  _$gAgentStageTRIAGE,
  _$gAgentStageEXPANSION,
  _$gAgentStageEXECUTION,
]);

Serializer<GSetTaskCategoryInput> _$gSetTaskCategoryInputSerializer =
    _$GSetTaskCategoryInputSerializer();
Serializer<GGateScriptTier> _$gGateScriptTierSerializer =
    _$GGateScriptTierSerializer();
Serializer<GGateScriptStatus> _$gGateScriptStatusSerializer =
    _$GGateScriptStatusSerializer();
Serializer<GTaskRelationKind> _$gTaskRelationKindSerializer =
    _$GTaskRelationKindSerializer();
Serializer<GTaskState> _$gTaskStateSerializer = _$GTaskStateSerializer();
Serializer<GChainStage> _$gChainStageSerializer = _$GChainStageSerializer();
Serializer<GAutonomyLevel> _$gAutonomyLevelSerializer =
    _$GAutonomyLevelSerializer();
Serializer<GTaskPriority> _$gTaskPrioritySerializer =
    _$GTaskPrioritySerializer();
Serializer<GDevicePlatform> _$gDevicePlatformSerializer =
    _$GDevicePlatformSerializer();
Serializer<GGuidanceScope> _$gGuidanceScopeSerializer =
    _$GGuidanceScopeSerializer();
Serializer<GAgentStage> _$gAgentStageSerializer = _$GAgentStageSerializer();

class _$GSetTaskCategoryInputSerializer
    implements StructuredSerializer<GSetTaskCategoryInput> {
  @override
  final Iterable<Type> types = const [
    GSetTaskCategoryInput,
    _$GSetTaskCategoryInput
  ];
  @override
  final String wireName = 'GSetTaskCategoryInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetTaskCategoryInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.label;
    if (value != null) {
      result
        ..add('label')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.parent;
    if (value != null) {
      result
        ..add('parent')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.stageBindings;
    if (value != null) {
      result
        ..add('stageBindings')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.JsonObject)));
    }
    return result;
  }

  @override
  GSetTaskCategoryInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetTaskCategoryInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'label':
          result.label = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'parent':
          result.parent = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'stageBindings':
          result.stageBindings = serializers.deserialize(value,
              specifiedType: const FullType(_i1.JsonObject)) as _i1.JsonObject?;
          break;
      }
    }

    return result.build();
  }
}

class _$GGateScriptTierSerializer
    implements PrimitiveSerializer<GGateScriptTier> {
  @override
  final Iterable<Type> types = const <Type>[GGateScriptTier];
  @override
  final String wireName = 'GGateScriptTier';

  @override
  Object serialize(Serializers serializers, GGateScriptTier object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GGateScriptTier deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GGateScriptTier.valueOf(serialized as String);
}

class _$GGateScriptStatusSerializer
    implements PrimitiveSerializer<GGateScriptStatus> {
  @override
  final Iterable<Type> types = const <Type>[GGateScriptStatus];
  @override
  final String wireName = 'GGateScriptStatus';

  @override
  Object serialize(Serializers serializers, GGateScriptStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GGateScriptStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GGateScriptStatus.valueOf(serialized as String);
}

class _$GTaskRelationKindSerializer
    implements PrimitiveSerializer<GTaskRelationKind> {
  @override
  final Iterable<Type> types = const <Type>[GTaskRelationKind];
  @override
  final String wireName = 'GTaskRelationKind';

  @override
  Object serialize(Serializers serializers, GTaskRelationKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskRelationKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskRelationKind.valueOf(serialized as String);
}

class _$GTaskStateSerializer implements PrimitiveSerializer<GTaskState> {
  @override
  final Iterable<Type> types = const <Type>[GTaskState];
  @override
  final String wireName = 'GTaskState';

  @override
  Object serialize(Serializers serializers, GTaskState object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskState deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskState.valueOf(serialized as String);
}

class _$GChainStageSerializer implements PrimitiveSerializer<GChainStage> {
  @override
  final Iterable<Type> types = const <Type>[GChainStage];
  @override
  final String wireName = 'GChainStage';

  @override
  Object serialize(Serializers serializers, GChainStage object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GChainStage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GChainStage.valueOf(serialized as String);
}

class _$GAutonomyLevelSerializer
    implements PrimitiveSerializer<GAutonomyLevel> {
  @override
  final Iterable<Type> types = const <Type>[GAutonomyLevel];
  @override
  final String wireName = 'GAutonomyLevel';

  @override
  Object serialize(Serializers serializers, GAutonomyLevel object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GAutonomyLevel deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GAutonomyLevel.valueOf(serialized as String);
}

class _$GTaskPrioritySerializer implements PrimitiveSerializer<GTaskPriority> {
  @override
  final Iterable<Type> types = const <Type>[GTaskPriority];
  @override
  final String wireName = 'GTaskPriority';

  @override
  Object serialize(Serializers serializers, GTaskPriority object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskPriority deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskPriority.valueOf(serialized as String);
}

class _$GDevicePlatformSerializer
    implements PrimitiveSerializer<GDevicePlatform> {
  @override
  final Iterable<Type> types = const <Type>[GDevicePlatform];
  @override
  final String wireName = 'GDevicePlatform';

  @override
  Object serialize(Serializers serializers, GDevicePlatform object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GDevicePlatform deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GDevicePlatform.valueOf(serialized as String);
}

class _$GGuidanceScopeSerializer
    implements PrimitiveSerializer<GGuidanceScope> {
  @override
  final Iterable<Type> types = const <Type>[GGuidanceScope];
  @override
  final String wireName = 'GGuidanceScope';

  @override
  Object serialize(Serializers serializers, GGuidanceScope object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GGuidanceScope deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GGuidanceScope.valueOf(serialized as String);
}

class _$GAgentStageSerializer implements PrimitiveSerializer<GAgentStage> {
  @override
  final Iterable<Type> types = const <Type>[GAgentStage];
  @override
  final String wireName = 'GAgentStage';

  @override
  Object serialize(Serializers serializers, GAgentStage object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GAgentStage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GAgentStage.valueOf(serialized as String);
}

class _$GSetTaskCategoryInput extends GSetTaskCategoryInput {
  @override
  final String key;
  @override
  final String? label;
  @override
  final String? description;
  @override
  final String? parent;
  @override
  final _i1.JsonObject? stageBindings;

  factory _$GSetTaskCategoryInput(
          [void Function(GSetTaskCategoryInputBuilder)? updates]) =>
      (GSetTaskCategoryInputBuilder()..update(updates))._build();

  _$GSetTaskCategoryInput._(
      {required this.key,
      this.label,
      this.description,
      this.parent,
      this.stageBindings})
      : super._();
  @override
  GSetTaskCategoryInput rebuild(
          void Function(GSetTaskCategoryInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetTaskCategoryInputBuilder toBuilder() =>
      GSetTaskCategoryInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetTaskCategoryInput &&
        key == other.key &&
        label == other.label &&
        description == other.description &&
        parent == other.parent &&
        stageBindings == other.stageBindings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, parent.hashCode);
    _$hash = $jc(_$hash, stageBindings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetTaskCategoryInput')
          ..add('key', key)
          ..add('label', label)
          ..add('description', description)
          ..add('parent', parent)
          ..add('stageBindings', stageBindings))
        .toString();
  }
}

class GSetTaskCategoryInputBuilder
    implements Builder<GSetTaskCategoryInput, GSetTaskCategoryInputBuilder> {
  _$GSetTaskCategoryInput? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _parent;
  String? get parent => _$this._parent;
  set parent(String? parent) => _$this._parent = parent;

  _i1.JsonObject? _stageBindings;
  _i1.JsonObject? get stageBindings => _$this._stageBindings;
  set stageBindings(_i1.JsonObject? stageBindings) =>
      _$this._stageBindings = stageBindings;

  GSetTaskCategoryInputBuilder();

  GSetTaskCategoryInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _description = $v.description;
      _parent = $v.parent;
      _stageBindings = $v.stageBindings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetTaskCategoryInput other) {
    _$v = other as _$GSetTaskCategoryInput;
  }

  @override
  void update(void Function(GSetTaskCategoryInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetTaskCategoryInput build() => _build();

  _$GSetTaskCategoryInput _build() {
    final _$result = _$v ??
        _$GSetTaskCategoryInput._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GSetTaskCategoryInput', 'key'),
          label: label,
          description: description,
          parent: parent,
          stageBindings: stageBindings,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GBytes extends GBytes {
  @override
  final String value;

  factory _$GBytes([void Function(GBytesBuilder)? updates]) =>
      (GBytesBuilder()..update(updates))._build();

  _$GBytes._({required this.value}) : super._();
  @override
  GBytes rebuild(void Function(GBytesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GBytesBuilder toBuilder() => GBytesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GBytes && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GBytes')..add('value', value))
        .toString();
  }
}

class GBytesBuilder implements Builder<GBytes, GBytesBuilder> {
  _$GBytes? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GBytesBuilder();

  GBytesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GBytes other) {
    _$v = other as _$GBytes;
  }

  @override
  void update(void Function(GBytesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GBytes build() => _build();

  _$GBytes _build() {
    final _$result = _$v ??
        _$GBytes._(
          value:
              BuiltValueNullFieldError.checkNotNull(value, r'GBytes', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTime extends GTime {
  @override
  final String value;

  factory _$GTime([void Function(GTimeBuilder)? updates]) =>
      (GTimeBuilder()..update(updates))._build();

  _$GTime._({required this.value}) : super._();
  @override
  GTime rebuild(void Function(GTimeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTimeBuilder toBuilder() => GTimeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTime && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTime')..add('value', value))
        .toString();
  }
}

class GTimeBuilder implements Builder<GTime, GTimeBuilder> {
  _$GTime? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GTimeBuilder();

  GTimeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTime other) {
    _$v = other as _$GTime;
  }

  @override
  void update(void Function(GTimeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTime build() => _build();

  _$GTime _build() {
    final _$result = _$v ??
        _$GTime._(
          value:
              BuiltValueNullFieldError.checkNotNull(value, r'GTime', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
