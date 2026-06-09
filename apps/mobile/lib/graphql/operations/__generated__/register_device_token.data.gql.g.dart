// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterDeviceTokenData> _$gRegisterDeviceTokenDataSerializer =
    _$GRegisterDeviceTokenDataSerializer();
Serializer<GUnregisterDeviceTokenData> _$gUnregisterDeviceTokenDataSerializer =
    _$GUnregisterDeviceTokenDataSerializer();

class _$GRegisterDeviceTokenDataSerializer
    implements StructuredSerializer<GRegisterDeviceTokenData> {
  @override
  final Iterable<Type> types = const [
    GRegisterDeviceTokenData,
    _$GRegisterDeviceTokenData
  ];
  @override
  final String wireName = 'GRegisterDeviceTokenData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterDeviceTokenData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'registerDeviceToken',
      serializers.serialize(object.registerDeviceToken,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GRegisterDeviceTokenData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterDeviceTokenDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'registerDeviceToken':
          result.registerDeviceToken = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GUnregisterDeviceTokenDataSerializer
    implements StructuredSerializer<GUnregisterDeviceTokenData> {
  @override
  final Iterable<Type> types = const [
    GUnregisterDeviceTokenData,
    _$GUnregisterDeviceTokenData
  ];
  @override
  final String wireName = 'GUnregisterDeviceTokenData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUnregisterDeviceTokenData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'unregisterDeviceToken',
      serializers.serialize(object.unregisterDeviceToken,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GUnregisterDeviceTokenData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUnregisterDeviceTokenDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'unregisterDeviceToken':
          result.unregisterDeviceToken = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterDeviceTokenData extends GRegisterDeviceTokenData {
  @override
  final String G__typename;
  @override
  final bool registerDeviceToken;

  factory _$GRegisterDeviceTokenData(
          [void Function(GRegisterDeviceTokenDataBuilder)? updates]) =>
      (GRegisterDeviceTokenDataBuilder()..update(updates))._build();

  _$GRegisterDeviceTokenData._(
      {required this.G__typename, required this.registerDeviceToken})
      : super._();
  @override
  GRegisterDeviceTokenData rebuild(
          void Function(GRegisterDeviceTokenDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterDeviceTokenDataBuilder toBuilder() =>
      GRegisterDeviceTokenDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterDeviceTokenData &&
        G__typename == other.G__typename &&
        registerDeviceToken == other.registerDeviceToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, registerDeviceToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterDeviceTokenData')
          ..add('G__typename', G__typename)
          ..add('registerDeviceToken', registerDeviceToken))
        .toString();
  }
}

class GRegisterDeviceTokenDataBuilder
    implements
        Builder<GRegisterDeviceTokenData, GRegisterDeviceTokenDataBuilder> {
  _$GRegisterDeviceTokenData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _registerDeviceToken;
  bool? get registerDeviceToken => _$this._registerDeviceToken;
  set registerDeviceToken(bool? registerDeviceToken) =>
      _$this._registerDeviceToken = registerDeviceToken;

  GRegisterDeviceTokenDataBuilder() {
    GRegisterDeviceTokenData._initializeBuilder(this);
  }

  GRegisterDeviceTokenDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _registerDeviceToken = $v.registerDeviceToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterDeviceTokenData other) {
    _$v = other as _$GRegisterDeviceTokenData;
  }

  @override
  void update(void Function(GRegisterDeviceTokenDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterDeviceTokenData build() => _build();

  _$GRegisterDeviceTokenData _build() {
    final _$result = _$v ??
        _$GRegisterDeviceTokenData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GRegisterDeviceTokenData', 'G__typename'),
          registerDeviceToken: BuiltValueNullFieldError.checkNotNull(
              registerDeviceToken,
              r'GRegisterDeviceTokenData',
              'registerDeviceToken'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GUnregisterDeviceTokenData extends GUnregisterDeviceTokenData {
  @override
  final String G__typename;
  @override
  final bool unregisterDeviceToken;

  factory _$GUnregisterDeviceTokenData(
          [void Function(GUnregisterDeviceTokenDataBuilder)? updates]) =>
      (GUnregisterDeviceTokenDataBuilder()..update(updates))._build();

  _$GUnregisterDeviceTokenData._(
      {required this.G__typename, required this.unregisterDeviceToken})
      : super._();
  @override
  GUnregisterDeviceTokenData rebuild(
          void Function(GUnregisterDeviceTokenDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUnregisterDeviceTokenDataBuilder toBuilder() =>
      GUnregisterDeviceTokenDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUnregisterDeviceTokenData &&
        G__typename == other.G__typename &&
        unregisterDeviceToken == other.unregisterDeviceToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, unregisterDeviceToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUnregisterDeviceTokenData')
          ..add('G__typename', G__typename)
          ..add('unregisterDeviceToken', unregisterDeviceToken))
        .toString();
  }
}

class GUnregisterDeviceTokenDataBuilder
    implements
        Builder<GUnregisterDeviceTokenData, GUnregisterDeviceTokenDataBuilder> {
  _$GUnregisterDeviceTokenData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _unregisterDeviceToken;
  bool? get unregisterDeviceToken => _$this._unregisterDeviceToken;
  set unregisterDeviceToken(bool? unregisterDeviceToken) =>
      _$this._unregisterDeviceToken = unregisterDeviceToken;

  GUnregisterDeviceTokenDataBuilder() {
    GUnregisterDeviceTokenData._initializeBuilder(this);
  }

  GUnregisterDeviceTokenDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _unregisterDeviceToken = $v.unregisterDeviceToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUnregisterDeviceTokenData other) {
    _$v = other as _$GUnregisterDeviceTokenData;
  }

  @override
  void update(void Function(GUnregisterDeviceTokenDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUnregisterDeviceTokenData build() => _build();

  _$GUnregisterDeviceTokenData _build() {
    final _$result = _$v ??
        _$GUnregisterDeviceTokenData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GUnregisterDeviceTokenData', 'G__typename'),
          unregisterDeviceToken: BuiltValueNullFieldError.checkNotNull(
              unregisterDeviceToken,
              r'GUnregisterDeviceTokenData',
              'unregisterDeviceToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
