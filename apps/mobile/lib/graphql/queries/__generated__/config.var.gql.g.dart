// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GConfigKeysVars> _$gConfigKeysVarsSerializer =
    _$GConfigKeysVarsSerializer();
Serializer<GSetConfigEntryVars> _$gSetConfigEntryVarsSerializer =
    _$GSetConfigEntryVarsSerializer();
Serializer<GDeleteConfigEntryVars> _$gDeleteConfigEntryVarsSerializer =
    _$GDeleteConfigEntryVarsSerializer();

class _$GConfigKeysVarsSerializer
    implements StructuredSerializer<GConfigKeysVars> {
  @override
  final Iterable<Type> types = const [GConfigKeysVars, _$GConfigKeysVars];
  @override
  final String wireName = 'GConfigKeysVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GConfigKeysVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GConfigKeysVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GConfigKeysVarsBuilder().build();
  }
}

class _$GSetConfigEntryVarsSerializer
    implements StructuredSerializer<GSetConfigEntryVars> {
  @override
  final Iterable<Type> types = const [
    GSetConfigEntryVars,
    _$GSetConfigEntryVars
  ];
  @override
  final String wireName = 'GSetConfigEntryVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetConfigEntryVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'value',
      serializers.serialize(object.value,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GSetConfigEntryVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConfigEntryVarsBuilder();

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
        case 'value':
          result.value = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteConfigEntryVarsSerializer
    implements StructuredSerializer<GDeleteConfigEntryVars> {
  @override
  final Iterable<Type> types = const [
    GDeleteConfigEntryVars,
    _$GDeleteConfigEntryVars
  ];
  @override
  final String wireName = 'GDeleteConfigEntryVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteConfigEntryVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GDeleteConfigEntryVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteConfigEntryVarsBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GConfigKeysVars extends GConfigKeysVars {
  factory _$GConfigKeysVars([void Function(GConfigKeysVarsBuilder)? updates]) =>
      (GConfigKeysVarsBuilder()..update(updates))._build();

  _$GConfigKeysVars._() : super._();
  @override
  GConfigKeysVars rebuild(void Function(GConfigKeysVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConfigKeysVarsBuilder toBuilder() => GConfigKeysVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConfigKeysVars;
  }

  @override
  int get hashCode {
    return 54397390;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GConfigKeysVars').toString();
  }
}

class GConfigKeysVarsBuilder
    implements Builder<GConfigKeysVars, GConfigKeysVarsBuilder> {
  _$GConfigKeysVars? _$v;

  GConfigKeysVarsBuilder();

  @override
  void replace(GConfigKeysVars other) {
    _$v = other as _$GConfigKeysVars;
  }

  @override
  void update(void Function(GConfigKeysVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConfigKeysVars build() => _build();

  _$GConfigKeysVars _build() {
    final _$result = _$v ?? _$GConfigKeysVars._();
    replace(_$result);
    return _$result;
  }
}

class _$GSetConfigEntryVars extends GSetConfigEntryVars {
  @override
  final String key;
  @override
  final String value;

  factory _$GSetConfigEntryVars(
          [void Function(GSetConfigEntryVarsBuilder)? updates]) =>
      (GSetConfigEntryVarsBuilder()..update(updates))._build();

  _$GSetConfigEntryVars._({required this.key, required this.value}) : super._();
  @override
  GSetConfigEntryVars rebuild(
          void Function(GSetConfigEntryVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConfigEntryVarsBuilder toBuilder() =>
      GSetConfigEntryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConfigEntryVars &&
        key == other.key &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetConfigEntryVars')
          ..add('key', key)
          ..add('value', value))
        .toString();
  }
}

class GSetConfigEntryVarsBuilder
    implements Builder<GSetConfigEntryVars, GSetConfigEntryVarsBuilder> {
  _$GSetConfigEntryVars? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GSetConfigEntryVarsBuilder();

  GSetConfigEntryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConfigEntryVars other) {
    _$v = other as _$GSetConfigEntryVars;
  }

  @override
  void update(void Function(GSetConfigEntryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConfigEntryVars build() => _build();

  _$GSetConfigEntryVars _build() {
    final _$result = _$v ??
        _$GSetConfigEntryVars._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GSetConfigEntryVars', 'key'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'GSetConfigEntryVars', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDeleteConfigEntryVars extends GDeleteConfigEntryVars {
  @override
  final String key;

  factory _$GDeleteConfigEntryVars(
          [void Function(GDeleteConfigEntryVarsBuilder)? updates]) =>
      (GDeleteConfigEntryVarsBuilder()..update(updates))._build();

  _$GDeleteConfigEntryVars._({required this.key}) : super._();
  @override
  GDeleteConfigEntryVars rebuild(
          void Function(GDeleteConfigEntryVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteConfigEntryVarsBuilder toBuilder() =>
      GDeleteConfigEntryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteConfigEntryVars && key == other.key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteConfigEntryVars')
          ..add('key', key))
        .toString();
  }
}

class GDeleteConfigEntryVarsBuilder
    implements Builder<GDeleteConfigEntryVars, GDeleteConfigEntryVarsBuilder> {
  _$GDeleteConfigEntryVars? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  GDeleteConfigEntryVarsBuilder();

  GDeleteConfigEntryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteConfigEntryVars other) {
    _$v = other as _$GDeleteConfigEntryVars;
  }

  @override
  void update(void Function(GDeleteConfigEntryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteConfigEntryVars build() => _build();

  _$GDeleteConfigEntryVars _build() {
    final _$result = _$v ??
        _$GDeleteConfigEntryVars._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GDeleteConfigEntryVars', 'key'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
