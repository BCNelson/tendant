// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pair_device.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPairDeviceData> _$gPairDeviceDataSerializer =
    _$GPairDeviceDataSerializer();
Serializer<GPairDeviceData_pairDevice> _$gPairDeviceDataPairDeviceSerializer =
    _$GPairDeviceData_pairDeviceSerializer();
Serializer<GPairDeviceData_pairDevice_session>
    _$gPairDeviceDataPairDeviceSessionSerializer =
    _$GPairDeviceData_pairDevice_sessionSerializer();

class _$GPairDeviceDataSerializer
    implements StructuredSerializer<GPairDeviceData> {
  @override
  final Iterable<Type> types = const [GPairDeviceData, _$GPairDeviceData];
  @override
  final String wireName = 'GPairDeviceData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GPairDeviceData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'pairDevice',
      serializers.serialize(object.pairDevice,
          specifiedType: const FullType(GPairDeviceData_pairDevice)),
    ];

    return result;
  }

  @override
  GPairDeviceData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPairDeviceDataBuilder();

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
        case 'pairDevice':
          result.pairDevice.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GPairDeviceData_pairDevice))!
              as GPairDeviceData_pairDevice);
          break;
      }
    }

    return result.build();
  }
}

class _$GPairDeviceData_pairDeviceSerializer
    implements StructuredSerializer<GPairDeviceData_pairDevice> {
  @override
  final Iterable<Type> types = const [
    GPairDeviceData_pairDevice,
    _$GPairDeviceData_pairDevice
  ];
  @override
  final String wireName = 'GPairDeviceData_pairDevice';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPairDeviceData_pairDevice object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'session',
      serializers.serialize(object.session,
          specifiedType: const FullType(GPairDeviceData_pairDevice_session)),
      'token',
      serializers.serialize(object.token,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPairDeviceData_pairDevice deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPairDeviceData_pairDeviceBuilder();

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
        case 'session':
          result.session.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GPairDeviceData_pairDevice_session))!
              as GPairDeviceData_pairDevice_session);
          break;
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPairDeviceData_pairDevice_sessionSerializer
    implements StructuredSerializer<GPairDeviceData_pairDevice_session> {
  @override
  final Iterable<Type> types = const [
    GPairDeviceData_pairDevice_session,
    _$GPairDeviceData_pairDevice_session
  ];
  @override
  final String wireName = 'GPairDeviceData_pairDevice_session';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPairDeviceData_pairDevice_session object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'displayName',
      serializers.serialize(object.displayName,
          specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'lastSeenAt',
      serializers.serialize(object.lastSeenAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GPairDeviceData_pairDevice_session deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPairDeviceData_pairDevice_sessionBuilder();

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
        case 'displayName':
          result.displayName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'lastSeenAt':
          result.lastSeenAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GPairDeviceData extends GPairDeviceData {
  @override
  final String G__typename;
  @override
  final GPairDeviceData_pairDevice pairDevice;

  factory _$GPairDeviceData([void Function(GPairDeviceDataBuilder)? updates]) =>
      (GPairDeviceDataBuilder()..update(updates))._build();

  _$GPairDeviceData._({required this.G__typename, required this.pairDevice})
      : super._();
  @override
  GPairDeviceData rebuild(void Function(GPairDeviceDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPairDeviceDataBuilder toBuilder() => GPairDeviceDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPairDeviceData &&
        G__typename == other.G__typename &&
        pairDevice == other.pairDevice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, pairDevice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPairDeviceData')
          ..add('G__typename', G__typename)
          ..add('pairDevice', pairDevice))
        .toString();
  }
}

class GPairDeviceDataBuilder
    implements Builder<GPairDeviceData, GPairDeviceDataBuilder> {
  _$GPairDeviceData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GPairDeviceData_pairDeviceBuilder? _pairDevice;
  GPairDeviceData_pairDeviceBuilder get pairDevice =>
      _$this._pairDevice ??= GPairDeviceData_pairDeviceBuilder();
  set pairDevice(GPairDeviceData_pairDeviceBuilder? pairDevice) =>
      _$this._pairDevice = pairDevice;

  GPairDeviceDataBuilder() {
    GPairDeviceData._initializeBuilder(this);
  }

  GPairDeviceDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _pairDevice = $v.pairDevice.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPairDeviceData other) {
    _$v = other as _$GPairDeviceData;
  }

  @override
  void update(void Function(GPairDeviceDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPairDeviceData build() => _build();

  _$GPairDeviceData _build() {
    _$GPairDeviceData _$result;
    try {
      _$result = _$v ??
          _$GPairDeviceData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GPairDeviceData', 'G__typename'),
            pairDevice: pairDevice.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pairDevice';
        pairDevice.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPairDeviceData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPairDeviceData_pairDevice extends GPairDeviceData_pairDevice {
  @override
  final String G__typename;
  @override
  final GPairDeviceData_pairDevice_session session;
  @override
  final String token;

  factory _$GPairDeviceData_pairDevice(
          [void Function(GPairDeviceData_pairDeviceBuilder)? updates]) =>
      (GPairDeviceData_pairDeviceBuilder()..update(updates))._build();

  _$GPairDeviceData_pairDevice._(
      {required this.G__typename, required this.session, required this.token})
      : super._();
  @override
  GPairDeviceData_pairDevice rebuild(
          void Function(GPairDeviceData_pairDeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPairDeviceData_pairDeviceBuilder toBuilder() =>
      GPairDeviceData_pairDeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPairDeviceData_pairDevice &&
        G__typename == other.G__typename &&
        session == other.session &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, session.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPairDeviceData_pairDevice')
          ..add('G__typename', G__typename)
          ..add('session', session)
          ..add('token', token))
        .toString();
  }
}

class GPairDeviceData_pairDeviceBuilder
    implements
        Builder<GPairDeviceData_pairDevice, GPairDeviceData_pairDeviceBuilder> {
  _$GPairDeviceData_pairDevice? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GPairDeviceData_pairDevice_sessionBuilder? _session;
  GPairDeviceData_pairDevice_sessionBuilder get session =>
      _$this._session ??= GPairDeviceData_pairDevice_sessionBuilder();
  set session(GPairDeviceData_pairDevice_sessionBuilder? session) =>
      _$this._session = session;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  GPairDeviceData_pairDeviceBuilder() {
    GPairDeviceData_pairDevice._initializeBuilder(this);
  }

  GPairDeviceData_pairDeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _session = $v.session.toBuilder();
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPairDeviceData_pairDevice other) {
    _$v = other as _$GPairDeviceData_pairDevice;
  }

  @override
  void update(void Function(GPairDeviceData_pairDeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPairDeviceData_pairDevice build() => _build();

  _$GPairDeviceData_pairDevice _build() {
    _$GPairDeviceData_pairDevice _$result;
    try {
      _$result = _$v ??
          _$GPairDeviceData_pairDevice._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GPairDeviceData_pairDevice', 'G__typename'),
            session: session.build(),
            token: BuiltValueNullFieldError.checkNotNull(
                token, r'GPairDeviceData_pairDevice', 'token'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'session';
        session.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPairDeviceData_pairDevice', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPairDeviceData_pairDevice_session
    extends GPairDeviceData_pairDevice_session {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String displayName;
  @override
  final _i2.GTime createdAt;
  @override
  final _i2.GTime lastSeenAt;

  factory _$GPairDeviceData_pairDevice_session(
          [void Function(GPairDeviceData_pairDevice_sessionBuilder)?
              updates]) =>
      (GPairDeviceData_pairDevice_sessionBuilder()..update(updates))._build();

  _$GPairDeviceData_pairDevice_session._(
      {required this.G__typename,
      required this.id,
      required this.displayName,
      required this.createdAt,
      required this.lastSeenAt})
      : super._();
  @override
  GPairDeviceData_pairDevice_session rebuild(
          void Function(GPairDeviceData_pairDevice_sessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPairDeviceData_pairDevice_sessionBuilder toBuilder() =>
      GPairDeviceData_pairDevice_sessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPairDeviceData_pairDevice_session &&
        G__typename == other.G__typename &&
        id == other.id &&
        displayName == other.displayName &&
        createdAt == other.createdAt &&
        lastSeenAt == other.lastSeenAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPairDeviceData_pairDevice_session')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('createdAt', createdAt)
          ..add('lastSeenAt', lastSeenAt))
        .toString();
  }
}

class GPairDeviceData_pairDevice_sessionBuilder
    implements
        Builder<GPairDeviceData_pairDevice_session,
            GPairDeviceData_pairDevice_sessionBuilder> {
  _$GPairDeviceData_pairDevice_session? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i2.GTimeBuilder? _lastSeenAt;
  _i2.GTimeBuilder get lastSeenAt => _$this._lastSeenAt ??= _i2.GTimeBuilder();
  set lastSeenAt(_i2.GTimeBuilder? lastSeenAt) =>
      _$this._lastSeenAt = lastSeenAt;

  GPairDeviceData_pairDevice_sessionBuilder() {
    GPairDeviceData_pairDevice_session._initializeBuilder(this);
  }

  GPairDeviceData_pairDevice_sessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _displayName = $v.displayName;
      _createdAt = $v.createdAt.toBuilder();
      _lastSeenAt = $v.lastSeenAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPairDeviceData_pairDevice_session other) {
    _$v = other as _$GPairDeviceData_pairDevice_session;
  }

  @override
  void update(
      void Function(GPairDeviceData_pairDevice_sessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPairDeviceData_pairDevice_session build() => _build();

  _$GPairDeviceData_pairDevice_session _build() {
    _$GPairDeviceData_pairDevice_session _$result;
    try {
      _$result = _$v ??
          _$GPairDeviceData_pairDevice_session._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GPairDeviceData_pairDevice_session', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GPairDeviceData_pairDevice_session', 'id'),
            displayName: BuiltValueNullFieldError.checkNotNull(displayName,
                r'GPairDeviceData_pairDevice_session', 'displayName'),
            createdAt: createdAt.build(),
            lastSeenAt: lastSeenAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'lastSeenAt';
        lastSeenAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPairDeviceData_pairDevice_session', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
