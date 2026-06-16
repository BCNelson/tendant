// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_relations.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAddTaskRelationVars> _$gAddTaskRelationVarsSerializer =
    _$GAddTaskRelationVarsSerializer();
Serializer<GRemoveTaskRelationVars> _$gRemoveTaskRelationVarsSerializer =
    _$GRemoveTaskRelationVarsSerializer();

class _$GAddTaskRelationVarsSerializer
    implements StructuredSerializer<GAddTaskRelationVars> {
  @override
  final Iterable<Type> types = const [
    GAddTaskRelationVars,
    _$GAddTaskRelationVars
  ];
  @override
  final String wireName = 'GAddTaskRelationVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAddTaskRelationVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'fromTaskId',
      serializers.serialize(object.fromTaskId,
          specifiedType: const FullType(String)),
      'toTaskId',
      serializers.serialize(object.toTaskId,
          specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind,
          specifiedType: const FullType(_i1.GTaskRelationKind)),
    ];

    return result;
  }

  @override
  GAddTaskRelationVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAddTaskRelationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'fromTaskId':
          result.fromTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'toTaskId':
          result.toTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'kind':
          result.kind = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GTaskRelationKind))!
              as _i1.GTaskRelationKind;
          break;
      }
    }

    return result.build();
  }
}

class _$GRemoveTaskRelationVarsSerializer
    implements StructuredSerializer<GRemoveTaskRelationVars> {
  @override
  final Iterable<Type> types = const [
    GRemoveTaskRelationVars,
    _$GRemoveTaskRelationVars
  ];
  @override
  final String wireName = 'GRemoveTaskRelationVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRemoveTaskRelationVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'fromTaskId',
      serializers.serialize(object.fromTaskId,
          specifiedType: const FullType(String)),
      'toTaskId',
      serializers.serialize(object.toTaskId,
          specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind,
          specifiedType: const FullType(_i1.GTaskRelationKind)),
    ];

    return result;
  }

  @override
  GRemoveTaskRelationVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRemoveTaskRelationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'fromTaskId':
          result.fromTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'toTaskId':
          result.toTaskId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'kind':
          result.kind = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GTaskRelationKind))!
              as _i1.GTaskRelationKind;
          break;
      }
    }

    return result.build();
  }
}

class _$GAddTaskRelationVars extends GAddTaskRelationVars {
  @override
  final String fromTaskId;
  @override
  final String toTaskId;
  @override
  final _i1.GTaskRelationKind kind;

  factory _$GAddTaskRelationVars(
          [void Function(GAddTaskRelationVarsBuilder)? updates]) =>
      (GAddTaskRelationVarsBuilder()..update(updates))._build();

  _$GAddTaskRelationVars._(
      {required this.fromTaskId, required this.toTaskId, required this.kind})
      : super._();
  @override
  GAddTaskRelationVars rebuild(
          void Function(GAddTaskRelationVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAddTaskRelationVarsBuilder toBuilder() =>
      GAddTaskRelationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAddTaskRelationVars &&
        fromTaskId == other.fromTaskId &&
        toTaskId == other.toTaskId &&
        kind == other.kind;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fromTaskId.hashCode);
    _$hash = $jc(_$hash, toTaskId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAddTaskRelationVars')
          ..add('fromTaskId', fromTaskId)
          ..add('toTaskId', toTaskId)
          ..add('kind', kind))
        .toString();
  }
}

class GAddTaskRelationVarsBuilder
    implements Builder<GAddTaskRelationVars, GAddTaskRelationVarsBuilder> {
  _$GAddTaskRelationVars? _$v;

  String? _fromTaskId;
  String? get fromTaskId => _$this._fromTaskId;
  set fromTaskId(String? fromTaskId) => _$this._fromTaskId = fromTaskId;

  String? _toTaskId;
  String? get toTaskId => _$this._toTaskId;
  set toTaskId(String? toTaskId) => _$this._toTaskId = toTaskId;

  _i1.GTaskRelationKind? _kind;
  _i1.GTaskRelationKind? get kind => _$this._kind;
  set kind(_i1.GTaskRelationKind? kind) => _$this._kind = kind;

  GAddTaskRelationVarsBuilder();

  GAddTaskRelationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fromTaskId = $v.fromTaskId;
      _toTaskId = $v.toTaskId;
      _kind = $v.kind;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAddTaskRelationVars other) {
    _$v = other as _$GAddTaskRelationVars;
  }

  @override
  void update(void Function(GAddTaskRelationVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAddTaskRelationVars build() => _build();

  _$GAddTaskRelationVars _build() {
    final _$result = _$v ??
        _$GAddTaskRelationVars._(
          fromTaskId: BuiltValueNullFieldError.checkNotNull(
              fromTaskId, r'GAddTaskRelationVars', 'fromTaskId'),
          toTaskId: BuiltValueNullFieldError.checkNotNull(
              toTaskId, r'GAddTaskRelationVars', 'toTaskId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'GAddTaskRelationVars', 'kind'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRemoveTaskRelationVars extends GRemoveTaskRelationVars {
  @override
  final String fromTaskId;
  @override
  final String toTaskId;
  @override
  final _i1.GTaskRelationKind kind;

  factory _$GRemoveTaskRelationVars(
          [void Function(GRemoveTaskRelationVarsBuilder)? updates]) =>
      (GRemoveTaskRelationVarsBuilder()..update(updates))._build();

  _$GRemoveTaskRelationVars._(
      {required this.fromTaskId, required this.toTaskId, required this.kind})
      : super._();
  @override
  GRemoveTaskRelationVars rebuild(
          void Function(GRemoveTaskRelationVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRemoveTaskRelationVarsBuilder toBuilder() =>
      GRemoveTaskRelationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRemoveTaskRelationVars &&
        fromTaskId == other.fromTaskId &&
        toTaskId == other.toTaskId &&
        kind == other.kind;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fromTaskId.hashCode);
    _$hash = $jc(_$hash, toTaskId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRemoveTaskRelationVars')
          ..add('fromTaskId', fromTaskId)
          ..add('toTaskId', toTaskId)
          ..add('kind', kind))
        .toString();
  }
}

class GRemoveTaskRelationVarsBuilder
    implements
        Builder<GRemoveTaskRelationVars, GRemoveTaskRelationVarsBuilder> {
  _$GRemoveTaskRelationVars? _$v;

  String? _fromTaskId;
  String? get fromTaskId => _$this._fromTaskId;
  set fromTaskId(String? fromTaskId) => _$this._fromTaskId = fromTaskId;

  String? _toTaskId;
  String? get toTaskId => _$this._toTaskId;
  set toTaskId(String? toTaskId) => _$this._toTaskId = toTaskId;

  _i1.GTaskRelationKind? _kind;
  _i1.GTaskRelationKind? get kind => _$this._kind;
  set kind(_i1.GTaskRelationKind? kind) => _$this._kind = kind;

  GRemoveTaskRelationVarsBuilder();

  GRemoveTaskRelationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fromTaskId = $v.fromTaskId;
      _toTaskId = $v.toTaskId;
      _kind = $v.kind;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRemoveTaskRelationVars other) {
    _$v = other as _$GRemoveTaskRelationVars;
  }

  @override
  void update(void Function(GRemoveTaskRelationVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRemoveTaskRelationVars build() => _build();

  _$GRemoveTaskRelationVars _build() {
    final _$result = _$v ??
        _$GRemoveTaskRelationVars._(
          fromTaskId: BuiltValueNullFieldError.checkNotNull(
              fromTaskId, r'GRemoveTaskRelationVars', 'fromTaskId'),
          toTaskId: BuiltValueNullFieldError.checkNotNull(
              toTaskId, r'GRemoveTaskRelationVars', 'toTaskId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'GRemoveTaskRelationVars', 'kind'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
