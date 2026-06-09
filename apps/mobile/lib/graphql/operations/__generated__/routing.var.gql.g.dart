// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskStageSlotsVars> _$gTaskStageSlotsVarsSerializer =
    _$GTaskStageSlotsVarsSerializer();
Serializer<GAgentConfigsVars> _$gAgentConfigsVarsSerializer =
    _$GAgentConfigsVarsSerializer();

class _$GTaskStageSlotsVarsSerializer
    implements StructuredSerializer<GTaskStageSlotsVars> {
  @override
  final Iterable<Type> types = const [
    GTaskStageSlotsVars,
    _$GTaskStageSlotsVars
  ];
  @override
  final String wireName = 'GTaskStageSlotsVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskStageSlotsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GTaskStageSlotsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskStageSlotsVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'taskId':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GAgentConfigsVarsSerializer
    implements StructuredSerializer<GAgentConfigsVars> {
  @override
  final Iterable<Type> types = const [GAgentConfigsVars, _$GAgentConfigsVars];
  @override
  final String wireName = 'GAgentConfigsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GAgentConfigsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.stage;
    if (value != null) {
      result
        ..add('stage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GAgentStage)));
    }
    return result;
  }

  @override
  GAgentConfigsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentConfigsVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAgentStage))
              as _i2.GAgentStage?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskStageSlotsVars extends GTaskStageSlotsVars {
  @override
  final String taskId;

  factory _$GTaskStageSlotsVars(
          [void Function(GTaskStageSlotsVarsBuilder)? updates]) =>
      (GTaskStageSlotsVarsBuilder()..update(updates))._build();

  _$GTaskStageSlotsVars._({required this.taskId}) : super._();
  @override
  GTaskStageSlotsVars rebuild(
          void Function(GTaskStageSlotsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskStageSlotsVarsBuilder toBuilder() =>
      GTaskStageSlotsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskStageSlotsVars && taskId == other.taskId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskStageSlotsVars')
          ..add('taskId', taskId))
        .toString();
  }
}

class GTaskStageSlotsVarsBuilder
    implements Builder<GTaskStageSlotsVars, GTaskStageSlotsVarsBuilder> {
  _$GTaskStageSlotsVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  GTaskStageSlotsVarsBuilder();

  GTaskStageSlotsVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskStageSlotsVars other) {
    _$v = other as _$GTaskStageSlotsVars;
  }

  @override
  void update(void Function(GTaskStageSlotsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskStageSlotsVars build() => _build();

  _$GTaskStageSlotsVars _build() {
    final _$result = _$v ??
        _$GTaskStageSlotsVars._(
          taskId: BuiltValueNullFieldError.checkNotNull(
              taskId, r'GTaskStageSlotsVars', 'taskId'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAgentConfigsVars extends GAgentConfigsVars {
  @override
  final _i2.GAgentStage? stage;

  factory _$GAgentConfigsVars(
          [void Function(GAgentConfigsVarsBuilder)? updates]) =>
      (GAgentConfigsVarsBuilder()..update(updates))._build();

  _$GAgentConfigsVars._({this.stage}) : super._();
  @override
  GAgentConfigsVars rebuild(void Function(GAgentConfigsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentConfigsVarsBuilder toBuilder() =>
      GAgentConfigsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentConfigsVars && stage == other.stage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAgentConfigsVars')
          ..add('stage', stage))
        .toString();
  }
}

class GAgentConfigsVarsBuilder
    implements Builder<GAgentConfigsVars, GAgentConfigsVarsBuilder> {
  _$GAgentConfigsVars? _$v;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  GAgentConfigsVarsBuilder();

  GAgentConfigsVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentConfigsVars other) {
    _$v = other as _$GAgentConfigsVars;
  }

  @override
  void update(void Function(GAgentConfigsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentConfigsVars build() => _build();

  _$GAgentConfigsVars _build() {
    final _$result = _$v ??
        _$GAgentConfigsVars._(
          stage: stage,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
