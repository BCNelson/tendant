// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectors.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GConnectorsData> _$gConnectorsDataSerializer =
    _$GConnectorsDataSerializer();
Serializer<GConnectorsData_connectors> _$gConnectorsDataConnectorsSerializer =
    _$GConnectorsData_connectorsSerializer();
Serializer<GSetConnectorConfigData> _$gSetConnectorConfigDataSerializer =
    _$GSetConnectorConfigDataSerializer();
Serializer<GSetConnectorConfigData_setConnectorConfig>
    _$gSetConnectorConfigDataSetConnectorConfigSerializer =
    _$GSetConnectorConfigData_setConnectorConfigSerializer();
Serializer<GEnableConnectorData> _$gEnableConnectorDataSerializer =
    _$GEnableConnectorDataSerializer();
Serializer<GEnableConnectorData_enableConnector>
    _$gEnableConnectorDataEnableConnectorSerializer =
    _$GEnableConnectorData_enableConnectorSerializer();

class _$GConnectorsDataSerializer
    implements StructuredSerializer<GConnectorsData> {
  @override
  final Iterable<Type> types = const [GConnectorsData, _$GConnectorsData];
  @override
  final String wireName = 'GConnectorsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GConnectorsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'connectors',
      serializers.serialize(object.connectors,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GConnectorsData_connectors)])),
    ];

    return result;
  }

  @override
  GConnectorsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GConnectorsDataBuilder();

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
        case 'connectors':
          result.connectors.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GConnectorsData_connectors)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GConnectorsData_connectorsSerializer
    implements StructuredSerializer<GConnectorsData_connectors> {
  @override
  final Iterable<Type> types = const [
    GConnectorsData_connectors,
    _$GConnectorsData_connectors
  ];
  @override
  final String wireName = 'GConnectorsData_connectors';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GConnectorsData_connectors object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'connectorType',
      serializers.serialize(object.connectorType,
          specifiedType: const FullType(String)),
      'enabled',
      serializers.serialize(object.enabled,
          specifiedType: const FullType(bool)),
      'config',
      serializers.serialize(object.config,
          specifiedType: const FullType(_i2.JsonObject)),
    ];

    return result;
  }

  @override
  GConnectorsData_connectors deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GConnectorsData_connectorsBuilder();

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
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'connectorType':
          result.connectorType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'enabled':
          result.enabled = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
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

class _$GSetConnectorConfigDataSerializer
    implements StructuredSerializer<GSetConnectorConfigData> {
  @override
  final Iterable<Type> types = const [
    GSetConnectorConfigData,
    _$GSetConnectorConfigData
  ];
  @override
  final String wireName = 'GSetConnectorConfigData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetConnectorConfigData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'setConnectorConfig',
      serializers.serialize(object.setConnectorConfig,
          specifiedType:
              const FullType(GSetConnectorConfigData_setConnectorConfig)),
    ];

    return result;
  }

  @override
  GSetConnectorConfigData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConnectorConfigDataBuilder();

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
        case 'setConnectorConfig':
          result.setConnectorConfig.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GSetConnectorConfigData_setConnectorConfig))!
              as GSetConnectorConfigData_setConnectorConfig);
          break;
      }
    }

    return result.build();
  }
}

class _$GSetConnectorConfigData_setConnectorConfigSerializer
    implements
        StructuredSerializer<GSetConnectorConfigData_setConnectorConfig> {
  @override
  final Iterable<Type> types = const [
    GSetConnectorConfigData_setConnectorConfig,
    _$GSetConnectorConfigData_setConnectorConfig
  ];
  @override
  final String wireName = 'GSetConnectorConfigData_setConnectorConfig';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GSetConnectorConfigData_setConnectorConfig object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'connectorType',
      serializers.serialize(object.connectorType,
          specifiedType: const FullType(String)),
      'enabled',
      serializers.serialize(object.enabled,
          specifiedType: const FullType(bool)),
      'config',
      serializers.serialize(object.config,
          specifiedType: const FullType(_i2.JsonObject)),
    ];

    return result;
  }

  @override
  GSetConnectorConfigData_setConnectorConfig deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConnectorConfigData_setConnectorConfigBuilder();

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
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'connectorType':
          result.connectorType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'enabled':
          result.enabled = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
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

class _$GEnableConnectorDataSerializer
    implements StructuredSerializer<GEnableConnectorData> {
  @override
  final Iterable<Type> types = const [
    GEnableConnectorData,
    _$GEnableConnectorData
  ];
  @override
  final String wireName = 'GEnableConnectorData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GEnableConnectorData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'enableConnector',
      serializers.serialize(object.enableConnector,
          specifiedType: const FullType(GEnableConnectorData_enableConnector)),
    ];

    return result;
  }

  @override
  GEnableConnectorData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GEnableConnectorDataBuilder();

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
        case 'enableConnector':
          result.enableConnector.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GEnableConnectorData_enableConnector))!
              as GEnableConnectorData_enableConnector);
          break;
      }
    }

    return result.build();
  }
}

class _$GEnableConnectorData_enableConnectorSerializer
    implements StructuredSerializer<GEnableConnectorData_enableConnector> {
  @override
  final Iterable<Type> types = const [
    GEnableConnectorData_enableConnector,
    _$GEnableConnectorData_enableConnector
  ];
  @override
  final String wireName = 'GEnableConnectorData_enableConnector';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GEnableConnectorData_enableConnector object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'enabled',
      serializers.serialize(object.enabled,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GEnableConnectorData_enableConnector deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GEnableConnectorData_enableConnectorBuilder();

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
        case 'id':
          result.id = serializers.deserialize(value,
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

class _$GConnectorsData extends GConnectorsData {
  @override
  final String G__typename;
  @override
  final BuiltList<GConnectorsData_connectors> connectors;

  factory _$GConnectorsData([void Function(GConnectorsDataBuilder)? updates]) =>
      (GConnectorsDataBuilder()..update(updates))._build();

  _$GConnectorsData._({required this.G__typename, required this.connectors})
      : super._();
  @override
  GConnectorsData rebuild(void Function(GConnectorsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConnectorsDataBuilder toBuilder() => GConnectorsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConnectorsData &&
        G__typename == other.G__typename &&
        connectors == other.connectors;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, connectors.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GConnectorsData')
          ..add('G__typename', G__typename)
          ..add('connectors', connectors))
        .toString();
  }
}

class GConnectorsDataBuilder
    implements Builder<GConnectorsData, GConnectorsDataBuilder> {
  _$GConnectorsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GConnectorsData_connectors>? _connectors;
  ListBuilder<GConnectorsData_connectors> get connectors =>
      _$this._connectors ??= ListBuilder<GConnectorsData_connectors>();
  set connectors(ListBuilder<GConnectorsData_connectors>? connectors) =>
      _$this._connectors = connectors;

  GConnectorsDataBuilder() {
    GConnectorsData._initializeBuilder(this);
  }

  GConnectorsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _connectors = $v.connectors.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GConnectorsData other) {
    _$v = other as _$GConnectorsData;
  }

  @override
  void update(void Function(GConnectorsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConnectorsData build() => _build();

  _$GConnectorsData _build() {
    _$GConnectorsData _$result;
    try {
      _$result = _$v ??
          _$GConnectorsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GConnectorsData', 'G__typename'),
            connectors: connectors.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'connectors';
        connectors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GConnectorsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GConnectorsData_connectors extends GConnectorsData_connectors {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String connectorType;
  @override
  final bool enabled;
  @override
  final _i2.JsonObject config;

  factory _$GConnectorsData_connectors(
          [void Function(GConnectorsData_connectorsBuilder)? updates]) =>
      (GConnectorsData_connectorsBuilder()..update(updates))._build();

  _$GConnectorsData_connectors._(
      {required this.G__typename,
      required this.id,
      required this.connectorType,
      required this.enabled,
      required this.config})
      : super._();
  @override
  GConnectorsData_connectors rebuild(
          void Function(GConnectorsData_connectorsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConnectorsData_connectorsBuilder toBuilder() =>
      GConnectorsData_connectorsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConnectorsData_connectors &&
        G__typename == other.G__typename &&
        id == other.id &&
        connectorType == other.connectorType &&
        enabled == other.enabled &&
        config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, connectorType.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GConnectorsData_connectors')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('connectorType', connectorType)
          ..add('enabled', enabled)
          ..add('config', config))
        .toString();
  }
}

class GConnectorsData_connectorsBuilder
    implements
        Builder<GConnectorsData_connectors, GConnectorsData_connectorsBuilder> {
  _$GConnectorsData_connectors? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _connectorType;
  String? get connectorType => _$this._connectorType;
  set connectorType(String? connectorType) =>
      _$this._connectorType = connectorType;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  _i2.JsonObject? _config;
  _i2.JsonObject? get config => _$this._config;
  set config(_i2.JsonObject? config) => _$this._config = config;

  GConnectorsData_connectorsBuilder() {
    GConnectorsData_connectors._initializeBuilder(this);
  }

  GConnectorsData_connectorsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _connectorType = $v.connectorType;
      _enabled = $v.enabled;
      _config = $v.config;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GConnectorsData_connectors other) {
    _$v = other as _$GConnectorsData_connectors;
  }

  @override
  void update(void Function(GConnectorsData_connectorsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConnectorsData_connectors build() => _build();

  _$GConnectorsData_connectors _build() {
    final _$result = _$v ??
        _$GConnectorsData_connectors._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GConnectorsData_connectors', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GConnectorsData_connectors', 'id'),
          connectorType: BuiltValueNullFieldError.checkNotNull(
              connectorType, r'GConnectorsData_connectors', 'connectorType'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'GConnectorsData_connectors', 'enabled'),
          config: BuiltValueNullFieldError.checkNotNull(
              config, r'GConnectorsData_connectors', 'config'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GSetConnectorConfigData extends GSetConnectorConfigData {
  @override
  final String G__typename;
  @override
  final GSetConnectorConfigData_setConnectorConfig setConnectorConfig;

  factory _$GSetConnectorConfigData(
          [void Function(GSetConnectorConfigDataBuilder)? updates]) =>
      (GSetConnectorConfigDataBuilder()..update(updates))._build();

  _$GSetConnectorConfigData._(
      {required this.G__typename, required this.setConnectorConfig})
      : super._();
  @override
  GSetConnectorConfigData rebuild(
          void Function(GSetConnectorConfigDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConnectorConfigDataBuilder toBuilder() =>
      GSetConnectorConfigDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConnectorConfigData &&
        G__typename == other.G__typename &&
        setConnectorConfig == other.setConnectorConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, setConnectorConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetConnectorConfigData')
          ..add('G__typename', G__typename)
          ..add('setConnectorConfig', setConnectorConfig))
        .toString();
  }
}

class GSetConnectorConfigDataBuilder
    implements
        Builder<GSetConnectorConfigData, GSetConnectorConfigDataBuilder> {
  _$GSetConnectorConfigData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSetConnectorConfigData_setConnectorConfigBuilder? _setConnectorConfig;
  GSetConnectorConfigData_setConnectorConfigBuilder get setConnectorConfig =>
      _$this._setConnectorConfig ??=
          GSetConnectorConfigData_setConnectorConfigBuilder();
  set setConnectorConfig(
          GSetConnectorConfigData_setConnectorConfigBuilder?
              setConnectorConfig) =>
      _$this._setConnectorConfig = setConnectorConfig;

  GSetConnectorConfigDataBuilder() {
    GSetConnectorConfigData._initializeBuilder(this);
  }

  GSetConnectorConfigDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _setConnectorConfig = $v.setConnectorConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConnectorConfigData other) {
    _$v = other as _$GSetConnectorConfigData;
  }

  @override
  void update(void Function(GSetConnectorConfigDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConnectorConfigData build() => _build();

  _$GSetConnectorConfigData _build() {
    _$GSetConnectorConfigData _$result;
    try {
      _$result = _$v ??
          _$GSetConnectorConfigData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSetConnectorConfigData', 'G__typename'),
            setConnectorConfig: setConnectorConfig.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'setConnectorConfig';
        setConnectorConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSetConnectorConfigData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSetConnectorConfigData_setConnectorConfig
    extends GSetConnectorConfigData_setConnectorConfig {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String connectorType;
  @override
  final bool enabled;
  @override
  final _i2.JsonObject config;

  factory _$GSetConnectorConfigData_setConnectorConfig(
          [void Function(GSetConnectorConfigData_setConnectorConfigBuilder)?
              updates]) =>
      (GSetConnectorConfigData_setConnectorConfigBuilder()..update(updates))
          ._build();

  _$GSetConnectorConfigData_setConnectorConfig._(
      {required this.G__typename,
      required this.id,
      required this.connectorType,
      required this.enabled,
      required this.config})
      : super._();
  @override
  GSetConnectorConfigData_setConnectorConfig rebuild(
          void Function(GSetConnectorConfigData_setConnectorConfigBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConnectorConfigData_setConnectorConfigBuilder toBuilder() =>
      GSetConnectorConfigData_setConnectorConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConnectorConfigData_setConnectorConfig &&
        G__typename == other.G__typename &&
        id == other.id &&
        connectorType == other.connectorType &&
        enabled == other.enabled &&
        config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, connectorType.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GSetConnectorConfigData_setConnectorConfig')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('connectorType', connectorType)
          ..add('enabled', enabled)
          ..add('config', config))
        .toString();
  }
}

class GSetConnectorConfigData_setConnectorConfigBuilder
    implements
        Builder<GSetConnectorConfigData_setConnectorConfig,
            GSetConnectorConfigData_setConnectorConfigBuilder> {
  _$GSetConnectorConfigData_setConnectorConfig? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _connectorType;
  String? get connectorType => _$this._connectorType;
  set connectorType(String? connectorType) =>
      _$this._connectorType = connectorType;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  _i2.JsonObject? _config;
  _i2.JsonObject? get config => _$this._config;
  set config(_i2.JsonObject? config) => _$this._config = config;

  GSetConnectorConfigData_setConnectorConfigBuilder() {
    GSetConnectorConfigData_setConnectorConfig._initializeBuilder(this);
  }

  GSetConnectorConfigData_setConnectorConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _connectorType = $v.connectorType;
      _enabled = $v.enabled;
      _config = $v.config;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConnectorConfigData_setConnectorConfig other) {
    _$v = other as _$GSetConnectorConfigData_setConnectorConfig;
  }

  @override
  void update(
      void Function(GSetConnectorConfigData_setConnectorConfigBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConnectorConfigData_setConnectorConfig build() => _build();

  _$GSetConnectorConfigData_setConnectorConfig _build() {
    final _$result = _$v ??
        _$GSetConnectorConfigData_setConnectorConfig._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GSetConnectorConfigData_setConnectorConfig', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GSetConnectorConfigData_setConnectorConfig', 'id'),
          connectorType: BuiltValueNullFieldError.checkNotNull(connectorType,
              r'GSetConnectorConfigData_setConnectorConfig', 'connectorType'),
          enabled: BuiltValueNullFieldError.checkNotNull(enabled,
              r'GSetConnectorConfigData_setConnectorConfig', 'enabled'),
          config: BuiltValueNullFieldError.checkNotNull(
              config, r'GSetConnectorConfigData_setConnectorConfig', 'config'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GEnableConnectorData extends GEnableConnectorData {
  @override
  final String G__typename;
  @override
  final GEnableConnectorData_enableConnector enableConnector;

  factory _$GEnableConnectorData(
          [void Function(GEnableConnectorDataBuilder)? updates]) =>
      (GEnableConnectorDataBuilder()..update(updates))._build();

  _$GEnableConnectorData._(
      {required this.G__typename, required this.enableConnector})
      : super._();
  @override
  GEnableConnectorData rebuild(
          void Function(GEnableConnectorDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GEnableConnectorDataBuilder toBuilder() =>
      GEnableConnectorDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GEnableConnectorData &&
        G__typename == other.G__typename &&
        enableConnector == other.enableConnector;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, enableConnector.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GEnableConnectorData')
          ..add('G__typename', G__typename)
          ..add('enableConnector', enableConnector))
        .toString();
  }
}

class GEnableConnectorDataBuilder
    implements Builder<GEnableConnectorData, GEnableConnectorDataBuilder> {
  _$GEnableConnectorData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GEnableConnectorData_enableConnectorBuilder? _enableConnector;
  GEnableConnectorData_enableConnectorBuilder get enableConnector =>
      _$this._enableConnector ??= GEnableConnectorData_enableConnectorBuilder();
  set enableConnector(
          GEnableConnectorData_enableConnectorBuilder? enableConnector) =>
      _$this._enableConnector = enableConnector;

  GEnableConnectorDataBuilder() {
    GEnableConnectorData._initializeBuilder(this);
  }

  GEnableConnectorDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _enableConnector = $v.enableConnector.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GEnableConnectorData other) {
    _$v = other as _$GEnableConnectorData;
  }

  @override
  void update(void Function(GEnableConnectorDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GEnableConnectorData build() => _build();

  _$GEnableConnectorData _build() {
    _$GEnableConnectorData _$result;
    try {
      _$result = _$v ??
          _$GEnableConnectorData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GEnableConnectorData', 'G__typename'),
            enableConnector: enableConnector.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'enableConnector';
        enableConnector.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GEnableConnectorData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GEnableConnectorData_enableConnector
    extends GEnableConnectorData_enableConnector {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final bool enabled;

  factory _$GEnableConnectorData_enableConnector(
          [void Function(GEnableConnectorData_enableConnectorBuilder)?
              updates]) =>
      (GEnableConnectorData_enableConnectorBuilder()..update(updates))._build();

  _$GEnableConnectorData_enableConnector._(
      {required this.G__typename, required this.id, required this.enabled})
      : super._();
  @override
  GEnableConnectorData_enableConnector rebuild(
          void Function(GEnableConnectorData_enableConnectorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GEnableConnectorData_enableConnectorBuilder toBuilder() =>
      GEnableConnectorData_enableConnectorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GEnableConnectorData_enableConnector &&
        G__typename == other.G__typename &&
        id == other.id &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GEnableConnectorData_enableConnector')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('enabled', enabled))
        .toString();
  }
}

class GEnableConnectorData_enableConnectorBuilder
    implements
        Builder<GEnableConnectorData_enableConnector,
            GEnableConnectorData_enableConnectorBuilder> {
  _$GEnableConnectorData_enableConnector? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  GEnableConnectorData_enableConnectorBuilder() {
    GEnableConnectorData_enableConnector._initializeBuilder(this);
  }

  GEnableConnectorData_enableConnectorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GEnableConnectorData_enableConnector other) {
    _$v = other as _$GEnableConnectorData_enableConnector;
  }

  @override
  void update(
      void Function(GEnableConnectorData_enableConnectorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GEnableConnectorData_enableConnector build() => _build();

  _$GEnableConnectorData_enableConnector _build() {
    final _$result = _$v ??
        _$GEnableConnectorData_enableConnector._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GEnableConnectorData_enableConnector', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GEnableConnectorData_enableConnector', 'id'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'GEnableConnectorData_enableConnector', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
