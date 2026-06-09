// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCompleteTaskVars> _$gCompleteTaskVarsSerializer =
    _$GCompleteTaskVarsSerializer();

class _$GCompleteTaskVarsSerializer
    implements StructuredSerializer<GCompleteTaskVars> {
  @override
  final Iterable<Type> types = const [GCompleteTaskVars, _$GCompleteTaskVars];
  @override
  final String wireName = 'GCompleteTaskVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCompleteTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.result;
    if (value != null) {
      result
        ..add('result')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.JsonObject)));
    }
    return result;
  }

  @override
  GCompleteTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTaskVarsBuilder();

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
        case 'result':
          result.result = serializers.deserialize(value,
              specifiedType: const FullType(_i1.JsonObject)) as _i1.JsonObject?;
          break;
      }
    }

    return result.build();
  }
}

class _$GCompleteTaskVars extends GCompleteTaskVars {
  @override
  final String taskId;
  @override
  final _i1.JsonObject? result;

  factory _$GCompleteTaskVars(
          [void Function(GCompleteTaskVarsBuilder)? updates]) =>
      (GCompleteTaskVarsBuilder()..update(updates))._build();

  _$GCompleteTaskVars._({required this.taskId, this.result}) : super._();
  @override
  GCompleteTaskVars rebuild(void Function(GCompleteTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTaskVarsBuilder toBuilder() =>
      GCompleteTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTaskVars &&
        taskId == other.taskId &&
        result == other.result;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, result.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCompleteTaskVars')
          ..add('taskId', taskId)
          ..add('result', result))
        .toString();
  }
}

class GCompleteTaskVarsBuilder
    implements Builder<GCompleteTaskVars, GCompleteTaskVarsBuilder> {
  _$GCompleteTaskVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  _i1.JsonObject? _result;
  _i1.JsonObject? get result => _$this._result;
  set result(_i1.JsonObject? result) => _$this._result = result;

  GCompleteTaskVarsBuilder();

  GCompleteTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _result = $v.result;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCompleteTaskVars other) {
    _$v = other as _$GCompleteTaskVars;
  }

  @override
  void update(void Function(GCompleteTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTaskVars build() => _build();

  _$GCompleteTaskVars _build() {
    final _$result = _$v ??
        _$GCompleteTaskVars._(
          taskId: BuiltValueNullFieldError.checkNotNull(
              taskId, r'GCompleteTaskVars', 'taskId'),
          result: result,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
