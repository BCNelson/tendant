// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_metadata.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GUpdateTaskMetadataData> _$gUpdateTaskMetadataDataSerializer =
    _$GUpdateTaskMetadataDataSerializer();
Serializer<GUpdateTaskMetadataData_updateTaskMetadata>
    _$gUpdateTaskMetadataDataUpdateTaskMetadataSerializer =
    _$GUpdateTaskMetadataData_updateTaskMetadataSerializer();

class _$GUpdateTaskMetadataDataSerializer
    implements StructuredSerializer<GUpdateTaskMetadataData> {
  @override
  final Iterable<Type> types = const [
    GUpdateTaskMetadataData,
    _$GUpdateTaskMetadataData
  ];
  @override
  final String wireName = 'GUpdateTaskMetadataData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUpdateTaskMetadataData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'updateTaskMetadata',
      serializers.serialize(object.updateTaskMetadata,
          specifiedType:
              const FullType(GUpdateTaskMetadataData_updateTaskMetadata)),
    ];

    return result;
  }

  @override
  GUpdateTaskMetadataData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateTaskMetadataDataBuilder();

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
        case 'updateTaskMetadata':
          result.updateTaskMetadata.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GUpdateTaskMetadataData_updateTaskMetadata))!
              as GUpdateTaskMetadataData_updateTaskMetadata);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateTaskMetadataData_updateTaskMetadataSerializer
    implements
        StructuredSerializer<GUpdateTaskMetadataData_updateTaskMetadata> {
  @override
  final Iterable<Type> types = const [
    GUpdateTaskMetadataData_updateTaskMetadata,
    _$GUpdateTaskMetadataData_updateTaskMetadata
  ];
  @override
  final String wireName = 'GUpdateTaskMetadataData_updateTaskMetadata';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GUpdateTaskMetadataData_updateTaskMetadata object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'priority',
      serializers.serialize(object.priority,
          specifiedType: const FullType(_i2.GTaskPriority)),
    ];
    Object? value;
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.startsAt;
    if (value != null) {
      result
        ..add('startsAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.rank;
    if (value != null) {
      result
        ..add('rank')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    return result;
  }

  @override
  GUpdateTaskMetadataData_updateTaskMetadata deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateTaskMetadataData_updateTaskMetadataBuilder();

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
        case 'priority':
          result.priority = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskPriority))!
              as _i2.GTaskPriority;
          break;
        case 'dueAt':
          result.dueAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'startsAt':
          result.startsAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'rank':
          result.rank = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateTaskMetadataData extends GUpdateTaskMetadataData {
  @override
  final String G__typename;
  @override
  final GUpdateTaskMetadataData_updateTaskMetadata updateTaskMetadata;

  factory _$GUpdateTaskMetadataData(
          [void Function(GUpdateTaskMetadataDataBuilder)? updates]) =>
      (GUpdateTaskMetadataDataBuilder()..update(updates))._build();

  _$GUpdateTaskMetadataData._(
      {required this.G__typename, required this.updateTaskMetadata})
      : super._();
  @override
  GUpdateTaskMetadataData rebuild(
          void Function(GUpdateTaskMetadataDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateTaskMetadataDataBuilder toBuilder() =>
      GUpdateTaskMetadataDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateTaskMetadataData &&
        G__typename == other.G__typename &&
        updateTaskMetadata == other.updateTaskMetadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, updateTaskMetadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateTaskMetadataData')
          ..add('G__typename', G__typename)
          ..add('updateTaskMetadata', updateTaskMetadata))
        .toString();
  }
}

class GUpdateTaskMetadataDataBuilder
    implements
        Builder<GUpdateTaskMetadataData, GUpdateTaskMetadataDataBuilder> {
  _$GUpdateTaskMetadataData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GUpdateTaskMetadataData_updateTaskMetadataBuilder? _updateTaskMetadata;
  GUpdateTaskMetadataData_updateTaskMetadataBuilder get updateTaskMetadata =>
      _$this._updateTaskMetadata ??=
          GUpdateTaskMetadataData_updateTaskMetadataBuilder();
  set updateTaskMetadata(
          GUpdateTaskMetadataData_updateTaskMetadataBuilder?
              updateTaskMetadata) =>
      _$this._updateTaskMetadata = updateTaskMetadata;

  GUpdateTaskMetadataDataBuilder() {
    GUpdateTaskMetadataData._initializeBuilder(this);
  }

  GUpdateTaskMetadataDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _updateTaskMetadata = $v.updateTaskMetadata.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateTaskMetadataData other) {
    _$v = other as _$GUpdateTaskMetadataData;
  }

  @override
  void update(void Function(GUpdateTaskMetadataDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateTaskMetadataData build() => _build();

  _$GUpdateTaskMetadataData _build() {
    _$GUpdateTaskMetadataData _$result;
    try {
      _$result = _$v ??
          _$GUpdateTaskMetadataData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GUpdateTaskMetadataData', 'G__typename'),
            updateTaskMetadata: updateTaskMetadata.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'updateTaskMetadata';
        updateTaskMetadata.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateTaskMetadataData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUpdateTaskMetadataData_updateTaskMetadata
    extends GUpdateTaskMetadataData_updateTaskMetadata {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskPriority priority;
  @override
  final _i2.GTime? dueAt;
  @override
  final _i2.GTime? startsAt;
  @override
  final double? rank;

  factory _$GUpdateTaskMetadataData_updateTaskMetadata(
          [void Function(GUpdateTaskMetadataData_updateTaskMetadataBuilder)?
              updates]) =>
      (GUpdateTaskMetadataData_updateTaskMetadataBuilder()..update(updates))
          ._build();

  _$GUpdateTaskMetadataData_updateTaskMetadata._(
      {required this.G__typename,
      required this.id,
      required this.priority,
      this.dueAt,
      this.startsAt,
      this.rank})
      : super._();
  @override
  GUpdateTaskMetadataData_updateTaskMetadata rebuild(
          void Function(GUpdateTaskMetadataData_updateTaskMetadataBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateTaskMetadataData_updateTaskMetadataBuilder toBuilder() =>
      GUpdateTaskMetadataData_updateTaskMetadataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateTaskMetadataData_updateTaskMetadata &&
        G__typename == other.G__typename &&
        id == other.id &&
        priority == other.priority &&
        dueAt == other.dueAt &&
        startsAt == other.startsAt &&
        rank == other.rank;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GUpdateTaskMetadataData_updateTaskMetadata')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('priority', priority)
          ..add('dueAt', dueAt)
          ..add('startsAt', startsAt)
          ..add('rank', rank))
        .toString();
  }
}

class GUpdateTaskMetadataData_updateTaskMetadataBuilder
    implements
        Builder<GUpdateTaskMetadataData_updateTaskMetadata,
            GUpdateTaskMetadataData_updateTaskMetadataBuilder> {
  _$GUpdateTaskMetadataData_updateTaskMetadata? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTaskPriority? _priority;
  _i2.GTaskPriority? get priority => _$this._priority;
  set priority(_i2.GTaskPriority? priority) => _$this._priority = priority;

  _i2.GTimeBuilder? _dueAt;
  _i2.GTimeBuilder get dueAt => _$this._dueAt ??= _i2.GTimeBuilder();
  set dueAt(_i2.GTimeBuilder? dueAt) => _$this._dueAt = dueAt;

  _i2.GTimeBuilder? _startsAt;
  _i2.GTimeBuilder get startsAt => _$this._startsAt ??= _i2.GTimeBuilder();
  set startsAt(_i2.GTimeBuilder? startsAt) => _$this._startsAt = startsAt;

  double? _rank;
  double? get rank => _$this._rank;
  set rank(double? rank) => _$this._rank = rank;

  GUpdateTaskMetadataData_updateTaskMetadataBuilder() {
    GUpdateTaskMetadataData_updateTaskMetadata._initializeBuilder(this);
  }

  GUpdateTaskMetadataData_updateTaskMetadataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _startsAt = $v.startsAt?.toBuilder();
      _rank = $v.rank;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateTaskMetadataData_updateTaskMetadata other) {
    _$v = other as _$GUpdateTaskMetadataData_updateTaskMetadata;
  }

  @override
  void update(
      void Function(GUpdateTaskMetadataData_updateTaskMetadataBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateTaskMetadataData_updateTaskMetadata build() => _build();

  _$GUpdateTaskMetadataData_updateTaskMetadata _build() {
    _$GUpdateTaskMetadataData_updateTaskMetadata _$result;
    try {
      _$result = _$v ??
          _$GUpdateTaskMetadataData_updateTaskMetadata._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GUpdateTaskMetadataData_updateTaskMetadata', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GUpdateTaskMetadataData_updateTaskMetadata', 'id'),
            priority: BuiltValueNullFieldError.checkNotNull(priority,
                r'GUpdateTaskMetadataData_updateTaskMetadata', 'priority'),
            dueAt: _dueAt?.build(),
            startsAt: _startsAt?.build(),
            rank: rank,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
        _$failedField = 'startsAt';
        _startsAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateTaskMetadataData_updateTaskMetadata',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
