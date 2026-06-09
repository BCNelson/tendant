// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectors.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GConnectorsVars> _$gConnectorsVarsSerializer =
    _$GConnectorsVarsSerializer();
Serializer<GSetConnectorConfigVars> _$gSetConnectorConfigVarsSerializer =
    _$GSetConnectorConfigVarsSerializer();
Serializer<GEnableConnectorVars> _$gEnableConnectorVarsSerializer =
    _$GEnableConnectorVarsSerializer();

class _$GConnectorsVarsSerializer
    implements StructuredSerializer<GConnectorsVars> {
  @override
  final Iterable<Type> types = const [GConnectorsVars, _$GConnectorsVars];
  @override
  final String wireName = 'GConnectorsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GConnectorsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GConnectorsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GConnectorsVarsBuilder().build();
  }
}

class _$GSetConnectorConfigVarsSerializer
    implements StructuredSerializer<GSetConnectorConfigVars> {
  @override
  final Iterable<Type> types = const [
    GSetConnectorConfigVars,
    _$GSetConnectorConfigVars
  ];
  @override
  final String wireName = 'GSetConnectorConfigVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetConnectorConfigVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'connectorId',
      serializers.serialize(object.connectorId,
          specifiedType: const FullType(String)),
      'config',
      serializers.serialize(object.config,
          specifiedType: const FullType(_i2.JsonObject)),
    ];

    return result;
  }

  @override
  GSetConnectorConfigVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConnectorConfigVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'connectorId':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'config':
          result.config = serializers.deserialize(value,
              specifiedType: const FullType(_i2.JsonObject))! as _i2.JsonObject;
          break;
      }
    }

    return result.build();
  }
}

class _$GEnableConnectorVarsSerializer
    implements StructuredSerializer<GEnableConnectorVars> {
  @override
  final Iterable<Type> types = const [
    GEnableConnectorVars,
    _$GEnableConnectorVars
  ];
  @override
  final String wireName = 'GEnableConnectorVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GEnableConnectorVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'connectorId',
      serializers.serialize(object.connectorId,
          specifiedType: const FullType(String)),
      'enabled',
      serializers.serialize(object.enabled,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GEnableConnectorVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GEnableConnectorVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'connectorId':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'enabled':
          result.enabled = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GConnectorsVars extends GConnectorsVars {
  factory _$GConnectorsVars([void Function(GConnectorsVarsBuilder)? updates]) =>
      (GConnectorsVarsBuilder()..update(updates))._build();

  _$GConnectorsVars._() : super._();
  @override
  GConnectorsVars rebuild(void Function(GConnectorsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConnectorsVarsBuilder toBuilder() => GConnectorsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConnectorsVars;
  }

  @override
  int get hashCode {
    return 1024250070;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GConnectorsVars').toString();
  }
}

class GConnectorsVarsBuilder
    implements Builder<GConnectorsVars, GConnectorsVarsBuilder> {
  _$GConnectorsVars? _$v;

  GConnectorsVarsBuilder();

  @override
  void replace(GConnectorsVars other) {
    _$v = other as _$GConnectorsVars;
  }

  @override
  void update(void Function(GConnectorsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConnectorsVars build() => _build();

  _$GConnectorsVars _build() {
    final _$result = _$v ?? _$GConnectorsVars._();
    replace(_$result);
    return _$result;
  }
}

class _$GSetConnectorConfigVars extends GSetConnectorConfigVars {
  @override
  final String connectorId;
  @override
  final _i2.JsonObject config;

  factory _$GSetConnectorConfigVars(
          [void Function(GSetConnectorConfigVarsBuilder)? updates]) =>
      (GSetConnectorConfigVarsBuilder()..update(updates))._build();

  _$GSetConnectorConfigVars._({required this.connectorId, required this.config})
      : super._();
  @override
  GSetConnectorConfigVars rebuild(
          void Function(GSetConnectorConfigVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConnectorConfigVarsBuilder toBuilder() =>
      GSetConnectorConfigVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConnectorConfigVars &&
        connectorId == other.connectorId &&
        config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, connectorId.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetConnectorConfigVars')
          ..add('connectorId', connectorId)
          ..add('config', config))
        .toString();
  }
}

class GSetConnectorConfigVarsBuilder
    implements
        Builder<GSetConnectorConfigVars, GSetConnectorConfigVarsBuilder> {
  _$GSetConnectorConfigVars? _$v;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  _i2.JsonObject? _config;
  _i2.JsonObject? get config => _$this._config;
  set config(_i2.JsonObject? config) => _$this._config = config;

  GSetConnectorConfigVarsBuilder();

  GSetConnectorConfigVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _connectorId = $v.connectorId;
      _config = $v.config;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConnectorConfigVars other) {
    _$v = other as _$GSetConnectorConfigVars;
  }

  @override
  void update(void Function(GSetConnectorConfigVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConnectorConfigVars build() => _build();

  _$GSetConnectorConfigVars _build() {
    final _$result = _$v ??
        _$GSetConnectorConfigVars._(
          connectorId: BuiltValueNullFieldError.checkNotNull(
              connectorId, r'GSetConnectorConfigVars', 'connectorId'),
          config: BuiltValueNullFieldError.checkNotNull(
              config, r'GSetConnectorConfigVars', 'config'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GEnableConnectorVars extends GEnableConnectorVars {
  @override
  final String connectorId;
  @override
  final bool enabled;

  factory _$GEnableConnectorVars(
          [void Function(GEnableConnectorVarsBuilder)? updates]) =>
      (GEnableConnectorVarsBuilder()..update(updates))._build();

  _$GEnableConnectorVars._({required this.connectorId, required this.enabled})
      : super._();
  @override
  GEnableConnectorVars rebuild(
          void Function(GEnableConnectorVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GEnableConnectorVarsBuilder toBuilder() =>
      GEnableConnectorVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GEnableConnectorVars &&
        connectorId == other.connectorId &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, connectorId.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GEnableConnectorVars')
          ..add('connectorId', connectorId)
          ..add('enabled', enabled))
        .toString();
  }
}

class GEnableConnectorVarsBuilder
    implements Builder<GEnableConnectorVars, GEnableConnectorVarsBuilder> {
  _$GEnableConnectorVars? _$v;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  GEnableConnectorVarsBuilder();

  GEnableConnectorVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _connectorId = $v.connectorId;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GEnableConnectorVars other) {
    _$v = other as _$GEnableConnectorVars;
  }

  @override
  void update(void Function(GEnableConnectorVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GEnableConnectorVars build() => _build();

  _$GEnableConnectorVars _build() {
    final _$result = _$v ??
        _$GEnableConnectorVars._(
          connectorId: BuiltValueNullFieldError.checkNotNull(
              connectorId, r'GEnableConnectorVars', 'connectorId'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'GEnableConnectorVars', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
