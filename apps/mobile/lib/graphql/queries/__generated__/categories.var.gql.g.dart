// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCategoriesVars> _$gCategoriesVarsSerializer =
    _$GCategoriesVarsSerializer();
Serializer<GSetTaskCategoryVars> _$gSetTaskCategoryVarsSerializer =
    _$GSetTaskCategoryVarsSerializer();
Serializer<GDeleteTaskCategoryVars> _$gDeleteTaskCategoryVarsSerializer =
    _$GDeleteTaskCategoryVarsSerializer();

class _$GCategoriesVarsSerializer
    implements StructuredSerializer<GCategoriesVars> {
  @override
  final Iterable<Type> types = const [GCategoriesVars, _$GCategoriesVars];
  @override
  final String wireName = 'GCategoriesVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCategoriesVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GCategoriesVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GCategoriesVarsBuilder().build();
  }
}

class _$GSetTaskCategoryVarsSerializer
    implements StructuredSerializer<GSetTaskCategoryVars> {
  @override
  final Iterable<Type> types = const [
    GSetTaskCategoryVars,
    _$GSetTaskCategoryVars
  ];
  @override
  final String wireName = 'GSetTaskCategoryVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetTaskCategoryVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i2.GSetTaskCategoryInput)),
    ];

    return result;
  }

  @override
  GSetTaskCategoryVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetTaskCategoryVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GSetTaskCategoryInput))!
              as _i2.GSetTaskCategoryInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteTaskCategoryVarsSerializer
    implements StructuredSerializer<GDeleteTaskCategoryVars> {
  @override
  final Iterable<Type> types = const [
    GDeleteTaskCategoryVars,
    _$GDeleteTaskCategoryVars
  ];
  @override
  final String wireName = 'GDeleteTaskCategoryVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteTaskCategoryVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GDeleteTaskCategoryVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteTaskCategoryVarsBuilder();

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

class _$GCategoriesVars extends GCategoriesVars {
  factory _$GCategoriesVars([void Function(GCategoriesVarsBuilder)? updates]) =>
      (GCategoriesVarsBuilder()..update(updates))._build();

  _$GCategoriesVars._() : super._();
  @override
  GCategoriesVars rebuild(void Function(GCategoriesVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCategoriesVarsBuilder toBuilder() => GCategoriesVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCategoriesVars;
  }

  @override
  int get hashCode {
    return 997817131;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GCategoriesVars').toString();
  }
}

class GCategoriesVarsBuilder
    implements Builder<GCategoriesVars, GCategoriesVarsBuilder> {
  _$GCategoriesVars? _$v;

  GCategoriesVarsBuilder();

  @override
  void replace(GCategoriesVars other) {
    _$v = other as _$GCategoriesVars;
  }

  @override
  void update(void Function(GCategoriesVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCategoriesVars build() => _build();

  _$GCategoriesVars _build() {
    final _$result = _$v ?? _$GCategoriesVars._();
    replace(_$result);
    return _$result;
  }
}

class _$GSetTaskCategoryVars extends GSetTaskCategoryVars {
  @override
  final _i2.GSetTaskCategoryInput input;

  factory _$GSetTaskCategoryVars(
          [void Function(GSetTaskCategoryVarsBuilder)? updates]) =>
      (GSetTaskCategoryVarsBuilder()..update(updates))._build();

  _$GSetTaskCategoryVars._({required this.input}) : super._();
  @override
  GSetTaskCategoryVars rebuild(
          void Function(GSetTaskCategoryVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetTaskCategoryVarsBuilder toBuilder() =>
      GSetTaskCategoryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetTaskCategoryVars && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetTaskCategoryVars')
          ..add('input', input))
        .toString();
  }
}

class GSetTaskCategoryVarsBuilder
    implements Builder<GSetTaskCategoryVars, GSetTaskCategoryVarsBuilder> {
  _$GSetTaskCategoryVars? _$v;

  _i2.GSetTaskCategoryInputBuilder? _input;
  _i2.GSetTaskCategoryInputBuilder get input =>
      _$this._input ??= _i2.GSetTaskCategoryInputBuilder();
  set input(_i2.GSetTaskCategoryInputBuilder? input) => _$this._input = input;

  GSetTaskCategoryVarsBuilder();

  GSetTaskCategoryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetTaskCategoryVars other) {
    _$v = other as _$GSetTaskCategoryVars;
  }

  @override
  void update(void Function(GSetTaskCategoryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetTaskCategoryVars build() => _build();

  _$GSetTaskCategoryVars _build() {
    _$GSetTaskCategoryVars _$result;
    try {
      _$result = _$v ??
          _$GSetTaskCategoryVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSetTaskCategoryVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDeleteTaskCategoryVars extends GDeleteTaskCategoryVars {
  @override
  final String key;

  factory _$GDeleteTaskCategoryVars(
          [void Function(GDeleteTaskCategoryVarsBuilder)? updates]) =>
      (GDeleteTaskCategoryVarsBuilder()..update(updates))._build();

  _$GDeleteTaskCategoryVars._({required this.key}) : super._();
  @override
  GDeleteTaskCategoryVars rebuild(
          void Function(GDeleteTaskCategoryVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteTaskCategoryVarsBuilder toBuilder() =>
      GDeleteTaskCategoryVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteTaskCategoryVars && key == other.key;
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
    return (newBuiltValueToStringHelper(r'GDeleteTaskCategoryVars')
          ..add('key', key))
        .toString();
  }
}

class GDeleteTaskCategoryVarsBuilder
    implements
        Builder<GDeleteTaskCategoryVars, GDeleteTaskCategoryVarsBuilder> {
  _$GDeleteTaskCategoryVars? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  GDeleteTaskCategoryVarsBuilder();

  GDeleteTaskCategoryVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteTaskCategoryVars other) {
    _$v = other as _$GDeleteTaskCategoryVars;
  }

  @override
  void update(void Function(GDeleteTaskCategoryVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteTaskCategoryVars build() => _build();

  _$GDeleteTaskCategoryVars _build() {
    final _$result = _$v ??
        _$GDeleteTaskCategoryVars._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GDeleteTaskCategoryVars', 'key'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
