// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_state.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GMarkInboxReadVars> _$gMarkInboxReadVarsSerializer =
    _$GMarkInboxReadVarsSerializer();
Serializer<GDismissInboxMessageVars> _$gDismissInboxMessageVarsSerializer =
    _$GDismissInboxMessageVarsSerializer();

class _$GMarkInboxReadVarsSerializer
    implements StructuredSerializer<GMarkInboxReadVars> {
  @override
  final Iterable<Type> types = const [GMarkInboxReadVars, _$GMarkInboxReadVars];
  @override
  final String wireName = 'GMarkInboxReadVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GMarkInboxReadVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GMarkInboxReadVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GMarkInboxReadVarsBuilder();

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

class _$GDismissInboxMessageVarsSerializer
    implements StructuredSerializer<GDismissInboxMessageVars> {
  @override
  final Iterable<Type> types = const [
    GDismissInboxMessageVars,
    _$GDismissInboxMessageVars
  ];
  @override
  final String wireName = 'GDismissInboxMessageVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissInboxMessageVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GDismissInboxMessageVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissInboxMessageVarsBuilder();

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

class _$GMarkInboxReadVars extends GMarkInboxReadVars {
  @override
  final String id;

  factory _$GMarkInboxReadVars(
          [void Function(GMarkInboxReadVarsBuilder)? updates]) =>
      (GMarkInboxReadVarsBuilder()..update(updates))._build();

  _$GMarkInboxReadVars._({required this.id}) : super._();
  @override
  GMarkInboxReadVars rebuild(
          void Function(GMarkInboxReadVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GMarkInboxReadVarsBuilder toBuilder() =>
      GMarkInboxReadVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GMarkInboxReadVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GMarkInboxReadVars')..add('id', id))
        .toString();
  }
}

class GMarkInboxReadVarsBuilder
    implements Builder<GMarkInboxReadVars, GMarkInboxReadVarsBuilder> {
  _$GMarkInboxReadVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GMarkInboxReadVarsBuilder();

  GMarkInboxReadVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GMarkInboxReadVars other) {
    _$v = other as _$GMarkInboxReadVars;
  }

  @override
  void update(void Function(GMarkInboxReadVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GMarkInboxReadVars build() => _build();

  _$GMarkInboxReadVars _build() {
    final _$result = _$v ??
        _$GMarkInboxReadVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GMarkInboxReadVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDismissInboxMessageVars extends GDismissInboxMessageVars {
  @override
  final String id;

  factory _$GDismissInboxMessageVars(
          [void Function(GDismissInboxMessageVarsBuilder)? updates]) =>
      (GDismissInboxMessageVarsBuilder()..update(updates))._build();

  _$GDismissInboxMessageVars._({required this.id}) : super._();
  @override
  GDismissInboxMessageVars rebuild(
          void Function(GDismissInboxMessageVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissInboxMessageVarsBuilder toBuilder() =>
      GDismissInboxMessageVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissInboxMessageVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GDismissInboxMessageVars')
          ..add('id', id))
        .toString();
  }
}

class GDismissInboxMessageVarsBuilder
    implements
        Builder<GDismissInboxMessageVars, GDismissInboxMessageVarsBuilder> {
  _$GDismissInboxMessageVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GDismissInboxMessageVarsBuilder();

  GDismissInboxMessageVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissInboxMessageVars other) {
    _$v = other as _$GDismissInboxMessageVars;
  }

  @override
  void update(void Function(GDismissInboxMessageVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissInboxMessageVars build() => _build();

  _$GDismissInboxMessageVars _build() {
    final _$result = _$v ??
        _$GDismissInboxMessageVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GDismissInboxMessageVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
