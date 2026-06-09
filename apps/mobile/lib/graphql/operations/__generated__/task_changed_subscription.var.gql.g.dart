// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_changed_subscription.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskChangedVars> _$gTaskChangedVarsSerializer =
    _$GTaskChangedVarsSerializer();

class _$GTaskChangedVarsSerializer
    implements StructuredSerializer<GTaskChangedVars> {
  @override
  final Iterable<Type> types = const [GTaskChangedVars, _$GTaskChangedVars];
  @override
  final String wireName = 'GTaskChangedVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskChangedVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.taskId;
    if (value != null) {
      result
        ..add('taskId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GTaskChangedVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'taskId':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskChangedVars extends GTaskChangedVars {
  @override
  final String? taskId;

  factory _$GTaskChangedVars(
          [void Function(GTaskChangedVarsBuilder)? updates]) =>
      (GTaskChangedVarsBuilder()..update(updates))._build();

  _$GTaskChangedVars._({this.taskId}) : super._();
  @override
  GTaskChangedVars rebuild(void Function(GTaskChangedVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedVarsBuilder toBuilder() =>
      GTaskChangedVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedVars && taskId == other.taskId;
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
    return (newBuiltValueToStringHelper(r'GTaskChangedVars')
          ..add('taskId', taskId))
        .toString();
  }
}

class GTaskChangedVarsBuilder
    implements Builder<GTaskChangedVars, GTaskChangedVarsBuilder> {
  _$GTaskChangedVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  GTaskChangedVarsBuilder();

  GTaskChangedVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskChangedVars other) {
    _$v = other as _$GTaskChangedVars;
  }

  @override
  void update(void Function(GTaskChangedVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedVars build() => _build();

  _$GTaskChangedVars _build() {
    final _$result = _$v ??
        _$GTaskChangedVars._(
          taskId: taskId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
