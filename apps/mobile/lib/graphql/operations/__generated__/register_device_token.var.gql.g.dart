// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterDeviceTokenVars> _$gRegisterDeviceTokenVarsSerializer =
    _$GRegisterDeviceTokenVarsSerializer();
Serializer<GUnregisterDeviceTokenVars> _$gUnregisterDeviceTokenVarsSerializer =
    _$GUnregisterDeviceTokenVarsSerializer();

class _$GRegisterDeviceTokenVarsSerializer
    implements StructuredSerializer<GRegisterDeviceTokenVars> {
  @override
  final Iterable<Type> types = const [
    GRegisterDeviceTokenVars,
    _$GRegisterDeviceTokenVars
  ];
  @override
  final String wireName = 'GRegisterDeviceTokenVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterDeviceTokenVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'token',
      serializers.serialize(object.token,
          specifiedType: const FullType(String)),
      'platform',
      serializers.serialize(object.platform,
          specifiedType: const FullType(_i1.GDevicePlatform)),
    ];

    return result;
  }

  @override
  GRegisterDeviceTokenVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterDeviceTokenVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'platform':
          result.platform = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GDevicePlatform))!
              as _i1.GDevicePlatform;
          break;
      }
    }

    return result.build();
  }
}

class _$GUnregisterDeviceTokenVarsSerializer
    implements StructuredSerializer<GUnregisterDeviceTokenVars> {
  @override
  final Iterable<Type> types = const [
    GUnregisterDeviceTokenVars,
    _$GUnregisterDeviceTokenVars
  ];
  @override
  final String wireName = 'GUnregisterDeviceTokenVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUnregisterDeviceTokenVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'token',
      serializers.serialize(object.token,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GUnregisterDeviceTokenVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUnregisterDeviceTokenVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterDeviceTokenVars extends GRegisterDeviceTokenVars {
  @override
  final String token;
  @override
  final _i1.GDevicePlatform platform;

  factory _$GRegisterDeviceTokenVars(
          [void Function(GRegisterDeviceTokenVarsBuilder)? updates]) =>
      (GRegisterDeviceTokenVarsBuilder()..update(updates))._build();

  _$GRegisterDeviceTokenVars._({required this.token, required this.platform})
      : super._();
  @override
  GRegisterDeviceTokenVars rebuild(
          void Function(GRegisterDeviceTokenVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterDeviceTokenVarsBuilder toBuilder() =>
      GRegisterDeviceTokenVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterDeviceTokenVars &&
        token == other.token &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterDeviceTokenVars')
          ..add('token', token)
          ..add('platform', platform))
        .toString();
  }
}

class GRegisterDeviceTokenVarsBuilder
    implements
        Builder<GRegisterDeviceTokenVars, GRegisterDeviceTokenVarsBuilder> {
  _$GRegisterDeviceTokenVars? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  _i1.GDevicePlatform? _platform;
  _i1.GDevicePlatform? get platform => _$this._platform;
  set platform(_i1.GDevicePlatform? platform) => _$this._platform = platform;

  GRegisterDeviceTokenVarsBuilder();

  GRegisterDeviceTokenVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterDeviceTokenVars other) {
    _$v = other as _$GRegisterDeviceTokenVars;
  }

  @override
  void update(void Function(GRegisterDeviceTokenVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterDeviceTokenVars build() => _build();

  _$GRegisterDeviceTokenVars _build() {
    final _$result = _$v ??
        _$GRegisterDeviceTokenVars._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'GRegisterDeviceTokenVars', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'GRegisterDeviceTokenVars', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GUnregisterDeviceTokenVars extends GUnregisterDeviceTokenVars {
  @override
  final String token;

  factory _$GUnregisterDeviceTokenVars(
          [void Function(GUnregisterDeviceTokenVarsBuilder)? updates]) =>
      (GUnregisterDeviceTokenVarsBuilder()..update(updates))._build();

  _$GUnregisterDeviceTokenVars._({required this.token}) : super._();
  @override
  GUnregisterDeviceTokenVars rebuild(
          void Function(GUnregisterDeviceTokenVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUnregisterDeviceTokenVarsBuilder toBuilder() =>
      GUnregisterDeviceTokenVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUnregisterDeviceTokenVars && token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUnregisterDeviceTokenVars')
          ..add('token', token))
        .toString();
  }
}

class GUnregisterDeviceTokenVarsBuilder
    implements
        Builder<GUnregisterDeviceTokenVars, GUnregisterDeviceTokenVarsBuilder> {
  _$GUnregisterDeviceTokenVars? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GUnregisterDeviceTokenVarsBuilder();

  GUnregisterDeviceTokenVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUnregisterDeviceTokenVars other) {
    _$v = other as _$GUnregisterDeviceTokenVars;
  }

  @override
  void update(void Function(GUnregisterDeviceTokenVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUnregisterDeviceTokenVars build() => _build();

  _$GUnregisterDeviceTokenVars _build() {
    final _$result = _$v ??
        _$GUnregisterDeviceTokenVars._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'GUnregisterDeviceTokenVars', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
