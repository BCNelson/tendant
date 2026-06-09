// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pair_device.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPairDeviceVars> _$gPairDeviceVarsSerializer =
    _$GPairDeviceVarsSerializer();

class _$GPairDeviceVarsSerializer
    implements StructuredSerializer<GPairDeviceVars> {
  @override
  final Iterable<Type> types = const [GPairDeviceVars, _$GPairDeviceVars];
  @override
  final String wireName = 'GPairDeviceVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GPairDeviceVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'password',
      serializers.serialize(object.password,
          specifiedType: const FullType(String)),
      'displayName',
      serializers.serialize(object.displayName,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPairDeviceVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPairDeviceVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'password':
          result.password = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'displayName':
          result.displayName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPairDeviceVars extends GPairDeviceVars {
  @override
  final String password;
  @override
  final String displayName;

  factory _$GPairDeviceVars([void Function(GPairDeviceVarsBuilder)? updates]) =>
      (GPairDeviceVarsBuilder()..update(updates))._build();

  _$GPairDeviceVars._({required this.password, required this.displayName})
      : super._();
  @override
  GPairDeviceVars rebuild(void Function(GPairDeviceVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPairDeviceVarsBuilder toBuilder() => GPairDeviceVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPairDeviceVars &&
        password == other.password &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPairDeviceVars')
          ..add('password', password)
          ..add('displayName', displayName))
        .toString();
  }
}

class GPairDeviceVarsBuilder
    implements Builder<GPairDeviceVars, GPairDeviceVarsBuilder> {
  _$GPairDeviceVars? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  GPairDeviceVarsBuilder();

  GPairDeviceVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPairDeviceVars other) {
    _$v = other as _$GPairDeviceVars;
  }

  @override
  void update(void Function(GPairDeviceVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPairDeviceVars build() => _build();

  _$GPairDeviceVars _build() {
    final _$result = _$v ??
        _$GPairDeviceVars._(
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'GPairDeviceVars', 'password'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'GPairDeviceVars', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
