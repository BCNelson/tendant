// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_metadata.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GUpdateTaskMetadataVars> _$gUpdateTaskMetadataVarsSerializer =
    _$GUpdateTaskMetadataVarsSerializer();

class _$GUpdateTaskMetadataVarsSerializer
    implements StructuredSerializer<GUpdateTaskMetadataVars> {
  @override
  final Iterable<Type> types = const [
    GUpdateTaskMetadataVars,
    _$GUpdateTaskMetadataVars
  ];
  @override
  final String wireName = 'GUpdateTaskMetadataVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUpdateTaskMetadataVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
      'priority',
      serializers.serialize(object.priority,
          specifiedType: const FullType(_i1.GTaskPriority)),
    ];
    Object? value;
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTime)));
    }
    return result;
  }

  @override
  GUpdateTaskMetadataVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateTaskMetadataVarsBuilder();

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
        case 'priority':
          result.priority = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GTaskPriority))!
              as _i1.GTaskPriority;
          break;
        case 'dueAt':
          result.dueAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GTime))! as _i1.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateTaskMetadataVars extends GUpdateTaskMetadataVars {
  @override
  final String taskId;
  @override
  final _i1.GTaskPriority priority;
  @override
  final _i1.GTime? dueAt;

  factory _$GUpdateTaskMetadataVars(
          [void Function(GUpdateTaskMetadataVarsBuilder)? updates]) =>
      (GUpdateTaskMetadataVarsBuilder()..update(updates))._build();

  _$GUpdateTaskMetadataVars._(
      {required this.taskId, required this.priority, this.dueAt})
      : super._();
  @override
  GUpdateTaskMetadataVars rebuild(
          void Function(GUpdateTaskMetadataVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateTaskMetadataVarsBuilder toBuilder() =>
      GUpdateTaskMetadataVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateTaskMetadataVars &&
        taskId == other.taskId &&
        priority == other.priority &&
        dueAt == other.dueAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateTaskMetadataVars')
          ..add('taskId', taskId)
          ..add('priority', priority)
          ..add('dueAt', dueAt))
        .toString();
  }
}

class GUpdateTaskMetadataVarsBuilder
    implements
        Builder<GUpdateTaskMetadataVars, GUpdateTaskMetadataVarsBuilder> {
  _$GUpdateTaskMetadataVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  _i1.GTaskPriority? _priority;
  _i1.GTaskPriority? get priority => _$this._priority;
  set priority(_i1.GTaskPriority? priority) => _$this._priority = priority;

  _i1.GTimeBuilder? _dueAt;
  _i1.GTimeBuilder get dueAt => _$this._dueAt ??= _i1.GTimeBuilder();
  set dueAt(_i1.GTimeBuilder? dueAt) => _$this._dueAt = dueAt;

  GUpdateTaskMetadataVarsBuilder();

  GUpdateTaskMetadataVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateTaskMetadataVars other) {
    _$v = other as _$GUpdateTaskMetadataVars;
  }

  @override
  void update(void Function(GUpdateTaskMetadataVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateTaskMetadataVars build() => _build();

  _$GUpdateTaskMetadataVars _build() {
    _$GUpdateTaskMetadataVars _$result;
    try {
      _$result = _$v ??
          _$GUpdateTaskMetadataVars._(
            taskId: BuiltValueNullFieldError.checkNotNull(
                taskId, r'GUpdateTaskMetadataVars', 'taskId'),
            priority: BuiltValueNullFieldError.checkNotNull(
                priority, r'GUpdateTaskMetadataVars', 'priority'),
            dueAt: _dueAt?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateTaskMetadataVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
