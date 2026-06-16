// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskDetailVars> _$gTaskDetailVarsSerializer =
    _$GTaskDetailVarsSerializer();
Serializer<GTaskLinkVars> _$gTaskLinkVarsSerializer =
    _$GTaskLinkVarsSerializer();

class _$GTaskDetailVarsSerializer
    implements StructuredSerializer<GTaskDetailVars> {
  @override
  final Iterable<Type> types = const [GTaskDetailVars, _$GTaskDetailVars];
  @override
  final String wireName = 'GTaskDetailVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskDetailVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GTaskDetailVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskLinkVarsSerializer implements StructuredSerializer<GTaskLinkVars> {
  @override
  final Iterable<Type> types = const [GTaskLinkVars, _$GTaskLinkVars];
  @override
  final String wireName = 'GTaskLinkVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskLinkVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GTaskLinkVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GTaskLinkVarsBuilder().build();
  }
}

class _$GTaskDetailVars extends GTaskDetailVars {
  @override
  final String id;

  factory _$GTaskDetailVars([void Function(GTaskDetailVarsBuilder)? updates]) =>
      (GTaskDetailVarsBuilder()..update(updates))._build();

  _$GTaskDetailVars._({required this.id}) : super._();
  @override
  GTaskDetailVars rebuild(void Function(GTaskDetailVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailVarsBuilder toBuilder() => GTaskDetailVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailVars && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskDetailVars')..add('id', id))
        .toString();
  }
}

class GTaskDetailVarsBuilder
    implements Builder<GTaskDetailVars, GTaskDetailVarsBuilder> {
  _$GTaskDetailVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GTaskDetailVarsBuilder();

  GTaskDetailVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailVars other) {
    _$v = other as _$GTaskDetailVars;
  }

  @override
  void update(void Function(GTaskDetailVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailVars build() => _build();

  _$GTaskDetailVars _build() {
    final _$result = _$v ??
        _$GTaskDetailVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskLinkVars extends GTaskLinkVars {
  factory _$GTaskLinkVars([void Function(GTaskLinkVarsBuilder)? updates]) =>
      (GTaskLinkVarsBuilder()..update(updates))._build();

  _$GTaskLinkVars._() : super._();
  @override
  GTaskLinkVars rebuild(void Function(GTaskLinkVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskLinkVarsBuilder toBuilder() => GTaskLinkVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskLinkVars;
  }

  @override
  int get hashCode {
    return 343030072;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GTaskLinkVars').toString();
  }
}

class GTaskLinkVarsBuilder
    implements Builder<GTaskLinkVars, GTaskLinkVarsBuilder> {
  _$GTaskLinkVars? _$v;

  GTaskLinkVarsBuilder();

  @override
  void replace(GTaskLinkVars other) {
    _$v = other as _$GTaskLinkVars;
  }

  @override
  void update(void Function(GTaskLinkVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskLinkVars build() => _build();

  _$GTaskLinkVars _build() {
    final _$result = _$v ?? _$GTaskLinkVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
