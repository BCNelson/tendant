// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GConfigKeysData> _$gConfigKeysDataSerializer =
    _$GConfigKeysDataSerializer();
Serializer<GConfigKeysData_configKeys> _$gConfigKeysDataConfigKeysSerializer =
    _$GConfigKeysData_configKeysSerializer();
Serializer<GSetConfigEntryData> _$gSetConfigEntryDataSerializer =
    _$GSetConfigEntryDataSerializer();
Serializer<GSetConfigEntryData_setConfigEntry>
    _$gSetConfigEntryDataSetConfigEntrySerializer =
    _$GSetConfigEntryData_setConfigEntrySerializer();
Serializer<GDeleteConfigEntryData> _$gDeleteConfigEntryDataSerializer =
    _$GDeleteConfigEntryDataSerializer();

class _$GConfigKeysDataSerializer
    implements StructuredSerializer<GConfigKeysData> {
  @override
  final Iterable<Type> types = const [GConfigKeysData, _$GConfigKeysData];
  @override
  final String wireName = 'GConfigKeysData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GConfigKeysData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'configKeys',
      serializers.serialize(object.configKeys,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GConfigKeysData_configKeys)])),
    ];

    return result;
  }

  @override
  GConfigKeysData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GConfigKeysDataBuilder();

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
        case 'configKeys':
          result.configKeys.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GConfigKeysData_configKeys)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GConfigKeysData_configKeysSerializer
    implements StructuredSerializer<GConfigKeysData_configKeys> {
  @override
  final Iterable<Type> types = const [
    GConfigKeysData_configKeys,
    _$GConfigKeysData_configKeys
  ];
  @override
  final String wireName = 'GConfigKeysData_configKeys';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GConfigKeysData_configKeys object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'type',
      serializers.serialize(object.type, specifiedType: const FullType(String)),
      'description',
      serializers.serialize(object.description,
          specifiedType: const FullType(String)),
      'reload',
      serializers.serialize(object.reload,
          specifiedType: const FullType(String)),
      'sensitive',
      serializers.serialize(object.sensitive,
          specifiedType: const FullType(bool)),
      'dbConfigurable',
      serializers.serialize(object.dbConfigurable,
          specifiedType: const FullType(bool)),
      'hotReloadable',
      serializers.serialize(object.hotReloadable,
          specifiedType: const FullType(bool)),
      'overridden',
      serializers.serialize(object.overridden,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.readonlyReason;
    if (value != null) {
      result
        ..add('readonlyReason')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.defaultValue;
    if (value != null) {
      result
        ..add('defaultValue')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.effectiveValue;
    if (value != null) {
      result
        ..add('effectiveValue')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GConfigKeysData_configKeys deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GConfigKeysData_configKeysBuilder();

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
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'reload':
          result.reload = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'sensitive':
          result.sensitive = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'dbConfigurable':
          result.dbConfigurable = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'hotReloadable':
          result.hotReloadable = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'readonlyReason':
          result.readonlyReason = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'defaultValue':
          result.defaultValue = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'effectiveValue':
          result.effectiveValue = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'overridden':
          result.overridden = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GSetConfigEntryDataSerializer
    implements StructuredSerializer<GSetConfigEntryData> {
  @override
  final Iterable<Type> types = const [
    GSetConfigEntryData,
    _$GSetConfigEntryData
  ];
  @override
  final String wireName = 'GSetConfigEntryData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetConfigEntryData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'setConfigEntry',
      serializers.serialize(object.setConfigEntry,
          specifiedType: const FullType(GSetConfigEntryData_setConfigEntry)),
    ];

    return result;
  }

  @override
  GSetConfigEntryData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConfigEntryDataBuilder();

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
        case 'setConfigEntry':
          result.setConfigEntry.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GSetConfigEntryData_setConfigEntry))!
              as GSetConfigEntryData_setConfigEntry);
          break;
      }
    }

    return result.build();
  }
}

class _$GSetConfigEntryData_setConfigEntrySerializer
    implements StructuredSerializer<GSetConfigEntryData_setConfigEntry> {
  @override
  final Iterable<Type> types = const [
    GSetConfigEntryData_setConfigEntry,
    _$GSetConfigEntryData_setConfigEntry
  ];
  @override
  final String wireName = 'GSetConfigEntryData_setConfigEntry';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetConfigEntryData_setConfigEntry object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'overridden',
      serializers.serialize(object.overridden,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.effectiveValue;
    if (value != null) {
      result
        ..add('effectiveValue')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GSetConfigEntryData_setConfigEntry deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetConfigEntryData_setConfigEntryBuilder();

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
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'effectiveValue':
          result.effectiveValue = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'overridden':
          result.overridden = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteConfigEntryDataSerializer
    implements StructuredSerializer<GDeleteConfigEntryData> {
  @override
  final Iterable<Type> types = const [
    GDeleteConfigEntryData,
    _$GDeleteConfigEntryData
  ];
  @override
  final String wireName = 'GDeleteConfigEntryData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteConfigEntryData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'deleteConfigEntry',
      serializers.serialize(object.deleteConfigEntry,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GDeleteConfigEntryData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteConfigEntryDataBuilder();

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
        case 'deleteConfigEntry':
          result.deleteConfigEntry = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GConfigKeysData extends GConfigKeysData {
  @override
  final String G__typename;
  @override
  final BuiltList<GConfigKeysData_configKeys> configKeys;

  factory _$GConfigKeysData([void Function(GConfigKeysDataBuilder)? updates]) =>
      (GConfigKeysDataBuilder()..update(updates))._build();

  _$GConfigKeysData._({required this.G__typename, required this.configKeys})
      : super._();
  @override
  GConfigKeysData rebuild(void Function(GConfigKeysDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConfigKeysDataBuilder toBuilder() => GConfigKeysDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConfigKeysData &&
        G__typename == other.G__typename &&
        configKeys == other.configKeys;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, configKeys.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GConfigKeysData')
          ..add('G__typename', G__typename)
          ..add('configKeys', configKeys))
        .toString();
  }
}

class GConfigKeysDataBuilder
    implements Builder<GConfigKeysData, GConfigKeysDataBuilder> {
  _$GConfigKeysData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GConfigKeysData_configKeys>? _configKeys;
  ListBuilder<GConfigKeysData_configKeys> get configKeys =>
      _$this._configKeys ??= ListBuilder<GConfigKeysData_configKeys>();
  set configKeys(ListBuilder<GConfigKeysData_configKeys>? configKeys) =>
      _$this._configKeys = configKeys;

  GConfigKeysDataBuilder() {
    GConfigKeysData._initializeBuilder(this);
  }

  GConfigKeysDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _configKeys = $v.configKeys.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GConfigKeysData other) {
    _$v = other as _$GConfigKeysData;
  }

  @override
  void update(void Function(GConfigKeysDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConfigKeysData build() => _build();

  _$GConfigKeysData _build() {
    _$GConfigKeysData _$result;
    try {
      _$result = _$v ??
          _$GConfigKeysData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GConfigKeysData', 'G__typename'),
            configKeys: configKeys.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configKeys';
        configKeys.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GConfigKeysData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GConfigKeysData_configKeys extends GConfigKeysData_configKeys {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String type;
  @override
  final String description;
  @override
  final String reload;
  @override
  final bool sensitive;
  @override
  final bool dbConfigurable;
  @override
  final bool hotReloadable;
  @override
  final String? readonlyReason;
  @override
  final String? defaultValue;
  @override
  final String? effectiveValue;
  @override
  final bool overridden;

  factory _$GConfigKeysData_configKeys(
          [void Function(GConfigKeysData_configKeysBuilder)? updates]) =>
      (GConfigKeysData_configKeysBuilder()..update(updates))._build();

  _$GConfigKeysData_configKeys._(
      {required this.G__typename,
      required this.key,
      required this.type,
      required this.description,
      required this.reload,
      required this.sensitive,
      required this.dbConfigurable,
      required this.hotReloadable,
      this.readonlyReason,
      this.defaultValue,
      this.effectiveValue,
      required this.overridden})
      : super._();
  @override
  GConfigKeysData_configKeys rebuild(
          void Function(GConfigKeysData_configKeysBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GConfigKeysData_configKeysBuilder toBuilder() =>
      GConfigKeysData_configKeysBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GConfigKeysData_configKeys &&
        G__typename == other.G__typename &&
        key == other.key &&
        type == other.type &&
        description == other.description &&
        reload == other.reload &&
        sensitive == other.sensitive &&
        dbConfigurable == other.dbConfigurable &&
        hotReloadable == other.hotReloadable &&
        readonlyReason == other.readonlyReason &&
        defaultValue == other.defaultValue &&
        effectiveValue == other.effectiveValue &&
        overridden == other.overridden;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, reload.hashCode);
    _$hash = $jc(_$hash, sensitive.hashCode);
    _$hash = $jc(_$hash, dbConfigurable.hashCode);
    _$hash = $jc(_$hash, hotReloadable.hashCode);
    _$hash = $jc(_$hash, readonlyReason.hashCode);
    _$hash = $jc(_$hash, defaultValue.hashCode);
    _$hash = $jc(_$hash, effectiveValue.hashCode);
    _$hash = $jc(_$hash, overridden.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GConfigKeysData_configKeys')
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('type', type)
          ..add('description', description)
          ..add('reload', reload)
          ..add('sensitive', sensitive)
          ..add('dbConfigurable', dbConfigurable)
          ..add('hotReloadable', hotReloadable)
          ..add('readonlyReason', readonlyReason)
          ..add('defaultValue', defaultValue)
          ..add('effectiveValue', effectiveValue)
          ..add('overridden', overridden))
        .toString();
  }
}

class GConfigKeysData_configKeysBuilder
    implements
        Builder<GConfigKeysData_configKeys, GConfigKeysData_configKeysBuilder> {
  _$GConfigKeysData_configKeys? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _reload;
  String? get reload => _$this._reload;
  set reload(String? reload) => _$this._reload = reload;

  bool? _sensitive;
  bool? get sensitive => _$this._sensitive;
  set sensitive(bool? sensitive) => _$this._sensitive = sensitive;

  bool? _dbConfigurable;
  bool? get dbConfigurable => _$this._dbConfigurable;
  set dbConfigurable(bool? dbConfigurable) =>
      _$this._dbConfigurable = dbConfigurable;

  bool? _hotReloadable;
  bool? get hotReloadable => _$this._hotReloadable;
  set hotReloadable(bool? hotReloadable) =>
      _$this._hotReloadable = hotReloadable;

  String? _readonlyReason;
  String? get readonlyReason => _$this._readonlyReason;
  set readonlyReason(String? readonlyReason) =>
      _$this._readonlyReason = readonlyReason;

  String? _defaultValue;
  String? get defaultValue => _$this._defaultValue;
  set defaultValue(String? defaultValue) => _$this._defaultValue = defaultValue;

  String? _effectiveValue;
  String? get effectiveValue => _$this._effectiveValue;
  set effectiveValue(String? effectiveValue) =>
      _$this._effectiveValue = effectiveValue;

  bool? _overridden;
  bool? get overridden => _$this._overridden;
  set overridden(bool? overridden) => _$this._overridden = overridden;

  GConfigKeysData_configKeysBuilder() {
    GConfigKeysData_configKeys._initializeBuilder(this);
  }

  GConfigKeysData_configKeysBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _type = $v.type;
      _description = $v.description;
      _reload = $v.reload;
      _sensitive = $v.sensitive;
      _dbConfigurable = $v.dbConfigurable;
      _hotReloadable = $v.hotReloadable;
      _readonlyReason = $v.readonlyReason;
      _defaultValue = $v.defaultValue;
      _effectiveValue = $v.effectiveValue;
      _overridden = $v.overridden;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GConfigKeysData_configKeys other) {
    _$v = other as _$GConfigKeysData_configKeys;
  }

  @override
  void update(void Function(GConfigKeysData_configKeysBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GConfigKeysData_configKeys build() => _build();

  _$GConfigKeysData_configKeys _build() {
    final _$result = _$v ??
        _$GConfigKeysData_configKeys._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GConfigKeysData_configKeys', 'G__typename'),
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GConfigKeysData_configKeys', 'key'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'GConfigKeysData_configKeys', 'type'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'GConfigKeysData_configKeys', 'description'),
          reload: BuiltValueNullFieldError.checkNotNull(
              reload, r'GConfigKeysData_configKeys', 'reload'),
          sensitive: BuiltValueNullFieldError.checkNotNull(
              sensitive, r'GConfigKeysData_configKeys', 'sensitive'),
          dbConfigurable: BuiltValueNullFieldError.checkNotNull(
              dbConfigurable, r'GConfigKeysData_configKeys', 'dbConfigurable'),
          hotReloadable: BuiltValueNullFieldError.checkNotNull(
              hotReloadable, r'GConfigKeysData_configKeys', 'hotReloadable'),
          readonlyReason: readonlyReason,
          defaultValue: defaultValue,
          effectiveValue: effectiveValue,
          overridden: BuiltValueNullFieldError.checkNotNull(
              overridden, r'GConfigKeysData_configKeys', 'overridden'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GSetConfigEntryData extends GSetConfigEntryData {
  @override
  final String G__typename;
  @override
  final GSetConfigEntryData_setConfigEntry setConfigEntry;

  factory _$GSetConfigEntryData(
          [void Function(GSetConfigEntryDataBuilder)? updates]) =>
      (GSetConfigEntryDataBuilder()..update(updates))._build();

  _$GSetConfigEntryData._(
      {required this.G__typename, required this.setConfigEntry})
      : super._();
  @override
  GSetConfigEntryData rebuild(
          void Function(GSetConfigEntryDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConfigEntryDataBuilder toBuilder() =>
      GSetConfigEntryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConfigEntryData &&
        G__typename == other.G__typename &&
        setConfigEntry == other.setConfigEntry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, setConfigEntry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetConfigEntryData')
          ..add('G__typename', G__typename)
          ..add('setConfigEntry', setConfigEntry))
        .toString();
  }
}

class GSetConfigEntryDataBuilder
    implements Builder<GSetConfigEntryData, GSetConfigEntryDataBuilder> {
  _$GSetConfigEntryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSetConfigEntryData_setConfigEntryBuilder? _setConfigEntry;
  GSetConfigEntryData_setConfigEntryBuilder get setConfigEntry =>
      _$this._setConfigEntry ??= GSetConfigEntryData_setConfigEntryBuilder();
  set setConfigEntry(
          GSetConfigEntryData_setConfigEntryBuilder? setConfigEntry) =>
      _$this._setConfigEntry = setConfigEntry;

  GSetConfigEntryDataBuilder() {
    GSetConfigEntryData._initializeBuilder(this);
  }

  GSetConfigEntryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _setConfigEntry = $v.setConfigEntry.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConfigEntryData other) {
    _$v = other as _$GSetConfigEntryData;
  }

  @override
  void update(void Function(GSetConfigEntryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConfigEntryData build() => _build();

  _$GSetConfigEntryData _build() {
    _$GSetConfigEntryData _$result;
    try {
      _$result = _$v ??
          _$GSetConfigEntryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSetConfigEntryData', 'G__typename'),
            setConfigEntry: setConfigEntry.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'setConfigEntry';
        setConfigEntry.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSetConfigEntryData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSetConfigEntryData_setConfigEntry
    extends GSetConfigEntryData_setConfigEntry {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String? effectiveValue;
  @override
  final bool overridden;

  factory _$GSetConfigEntryData_setConfigEntry(
          [void Function(GSetConfigEntryData_setConfigEntryBuilder)?
              updates]) =>
      (GSetConfigEntryData_setConfigEntryBuilder()..update(updates))._build();

  _$GSetConfigEntryData_setConfigEntry._(
      {required this.G__typename,
      required this.key,
      this.effectiveValue,
      required this.overridden})
      : super._();
  @override
  GSetConfigEntryData_setConfigEntry rebuild(
          void Function(GSetConfigEntryData_setConfigEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetConfigEntryData_setConfigEntryBuilder toBuilder() =>
      GSetConfigEntryData_setConfigEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetConfigEntryData_setConfigEntry &&
        G__typename == other.G__typename &&
        key == other.key &&
        effectiveValue == other.effectiveValue &&
        overridden == other.overridden;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, effectiveValue.hashCode);
    _$hash = $jc(_$hash, overridden.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetConfigEntryData_setConfigEntry')
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('effectiveValue', effectiveValue)
          ..add('overridden', overridden))
        .toString();
  }
}

class GSetConfigEntryData_setConfigEntryBuilder
    implements
        Builder<GSetConfigEntryData_setConfigEntry,
            GSetConfigEntryData_setConfigEntryBuilder> {
  _$GSetConfigEntryData_setConfigEntry? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _effectiveValue;
  String? get effectiveValue => _$this._effectiveValue;
  set effectiveValue(String? effectiveValue) =>
      _$this._effectiveValue = effectiveValue;

  bool? _overridden;
  bool? get overridden => _$this._overridden;
  set overridden(bool? overridden) => _$this._overridden = overridden;

  GSetConfigEntryData_setConfigEntryBuilder() {
    GSetConfigEntryData_setConfigEntry._initializeBuilder(this);
  }

  GSetConfigEntryData_setConfigEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _effectiveValue = $v.effectiveValue;
      _overridden = $v.overridden;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetConfigEntryData_setConfigEntry other) {
    _$v = other as _$GSetConfigEntryData_setConfigEntry;
  }

  @override
  void update(
      void Function(GSetConfigEntryData_setConfigEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetConfigEntryData_setConfigEntry build() => _build();

  _$GSetConfigEntryData_setConfigEntry _build() {
    final _$result = _$v ??
        _$GSetConfigEntryData_setConfigEntry._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GSetConfigEntryData_setConfigEntry', 'G__typename'),
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GSetConfigEntryData_setConfigEntry', 'key'),
          effectiveValue: effectiveValue,
          overridden: BuiltValueNullFieldError.checkNotNull(
              overridden, r'GSetConfigEntryData_setConfigEntry', 'overridden'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDeleteConfigEntryData extends GDeleteConfigEntryData {
  @override
  final String G__typename;
  @override
  final bool deleteConfigEntry;

  factory _$GDeleteConfigEntryData(
          [void Function(GDeleteConfigEntryDataBuilder)? updates]) =>
      (GDeleteConfigEntryDataBuilder()..update(updates))._build();

  _$GDeleteConfigEntryData._(
      {required this.G__typename, required this.deleteConfigEntry})
      : super._();
  @override
  GDeleteConfigEntryData rebuild(
          void Function(GDeleteConfigEntryDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteConfigEntryDataBuilder toBuilder() =>
      GDeleteConfigEntryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteConfigEntryData &&
        G__typename == other.G__typename &&
        deleteConfigEntry == other.deleteConfigEntry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, deleteConfigEntry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteConfigEntryData')
          ..add('G__typename', G__typename)
          ..add('deleteConfigEntry', deleteConfigEntry))
        .toString();
  }
}

class GDeleteConfigEntryDataBuilder
    implements Builder<GDeleteConfigEntryData, GDeleteConfigEntryDataBuilder> {
  _$GDeleteConfigEntryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _deleteConfigEntry;
  bool? get deleteConfigEntry => _$this._deleteConfigEntry;
  set deleteConfigEntry(bool? deleteConfigEntry) =>
      _$this._deleteConfigEntry = deleteConfigEntry;

  GDeleteConfigEntryDataBuilder() {
    GDeleteConfigEntryData._initializeBuilder(this);
  }

  GDeleteConfigEntryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _deleteConfigEntry = $v.deleteConfigEntry;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteConfigEntryData other) {
    _$v = other as _$GDeleteConfigEntryData;
  }

  @override
  void update(void Function(GDeleteConfigEntryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteConfigEntryData build() => _build();

  _$GDeleteConfigEntryData _build() {
    final _$result = _$v ??
        _$GDeleteConfigEntryData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GDeleteConfigEntryData', 'G__typename'),
          deleteConfigEntry: BuiltValueNullFieldError.checkNotNull(
              deleteConfigEntry,
              r'GDeleteConfigEntryData',
              'deleteConfigEntry'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
