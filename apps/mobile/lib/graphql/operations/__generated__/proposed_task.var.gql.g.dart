// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposed_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAcceptProposedTaskVars> _$gAcceptProposedTaskVarsSerializer =
    _$GAcceptProposedTaskVarsSerializer();
Serializer<GDismissProposedTaskVars> _$gDismissProposedTaskVarsSerializer =
    _$GDismissProposedTaskVarsSerializer();

class _$GAcceptProposedTaskVarsSerializer
    implements StructuredSerializer<GAcceptProposedTaskVars> {
  @override
  final Iterable<Type> types = const [
    GAcceptProposedTaskVars,
    _$GAcceptProposedTaskVars
  ];
  @override
  final String wireName = 'GAcceptProposedTaskVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAcceptProposedTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAcceptProposedTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptProposedTaskVarsBuilder();

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

class _$GDismissProposedTaskVarsSerializer
    implements StructuredSerializer<GDismissProposedTaskVars> {
  @override
  final Iterable<Type> types = const [
    GDismissProposedTaskVars,
    _$GDismissProposedTaskVars
  ];
  @override
  final String wireName = 'GDismissProposedTaskVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissProposedTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'taskId',
      serializers.serialize(object.taskId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.reason;
    if (value != null) {
      result
        ..add('reason')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GDismissProposedTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissProposedTaskVarsBuilder();

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
        case 'reason':
          result.reason = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptProposedTaskVars extends GAcceptProposedTaskVars {
  @override
  final String taskId;

  factory _$GAcceptProposedTaskVars(
          [void Function(GAcceptProposedTaskVarsBuilder)? updates]) =>
      (GAcceptProposedTaskVarsBuilder()..update(updates))._build();

  _$GAcceptProposedTaskVars._({required this.taskId}) : super._();
  @override
  GAcceptProposedTaskVars rebuild(
          void Function(GAcceptProposedTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptProposedTaskVarsBuilder toBuilder() =>
      GAcceptProposedTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptProposedTaskVars && taskId == other.taskId;
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
    return (newBuiltValueToStringHelper(r'GAcceptProposedTaskVars')
          ..add('taskId', taskId))
        .toString();
  }
}

class GAcceptProposedTaskVarsBuilder
    implements
        Builder<GAcceptProposedTaskVars, GAcceptProposedTaskVarsBuilder> {
  _$GAcceptProposedTaskVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  GAcceptProposedTaskVarsBuilder();

  GAcceptProposedTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptProposedTaskVars other) {
    _$v = other as _$GAcceptProposedTaskVars;
  }

  @override
  void update(void Function(GAcceptProposedTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptProposedTaskVars build() => _build();

  _$GAcceptProposedTaskVars _build() {
    final _$result = _$v ??
        _$GAcceptProposedTaskVars._(
          taskId: BuiltValueNullFieldError.checkNotNull(
              taskId, r'GAcceptProposedTaskVars', 'taskId'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDismissProposedTaskVars extends GDismissProposedTaskVars {
  @override
  final String taskId;
  @override
  final String? reason;

  factory _$GDismissProposedTaskVars(
          [void Function(GDismissProposedTaskVarsBuilder)? updates]) =>
      (GDismissProposedTaskVarsBuilder()..update(updates))._build();

  _$GDismissProposedTaskVars._({required this.taskId, this.reason}) : super._();
  @override
  GDismissProposedTaskVars rebuild(
          void Function(GDismissProposedTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissProposedTaskVarsBuilder toBuilder() =>
      GDismissProposedTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissProposedTaskVars &&
        taskId == other.taskId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissProposedTaskVars')
          ..add('taskId', taskId)
          ..add('reason', reason))
        .toString();
  }
}

class GDismissProposedTaskVarsBuilder
    implements
        Builder<GDismissProposedTaskVars, GDismissProposedTaskVarsBuilder> {
  _$GDismissProposedTaskVars? _$v;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GDismissProposedTaskVarsBuilder();

  GDismissProposedTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskId = $v.taskId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissProposedTaskVars other) {
    _$v = other as _$GDismissProposedTaskVars;
  }

  @override
  void update(void Function(GDismissProposedTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissProposedTaskVars build() => _build();

  _$GDismissProposedTaskVars _build() {
    final _$result = _$v ??
        _$GDismissProposedTaskVars._(
          taskId: BuiltValueNullFieldError.checkNotNull(
              taskId, r'GDismissProposedTaskVars', 'taskId'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
