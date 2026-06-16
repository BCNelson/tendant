// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_relations.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAddTaskRelationData> _$gAddTaskRelationDataSerializer =
    _$GAddTaskRelationDataSerializer();
Serializer<GAddTaskRelationData_addTaskRelation>
    _$gAddTaskRelationDataAddTaskRelationSerializer =
    _$GAddTaskRelationData_addTaskRelationSerializer();
Serializer<GAddTaskRelationData_addTaskRelation_from>
    _$gAddTaskRelationDataAddTaskRelationFromSerializer =
    _$GAddTaskRelationData_addTaskRelation_fromSerializer();
Serializer<GAddTaskRelationData_addTaskRelation_to>
    _$gAddTaskRelationDataAddTaskRelationToSerializer =
    _$GAddTaskRelationData_addTaskRelation_toSerializer();
Serializer<GRemoveTaskRelationData> _$gRemoveTaskRelationDataSerializer =
    _$GRemoveTaskRelationDataSerializer();

class _$GAddTaskRelationDataSerializer
    implements StructuredSerializer<GAddTaskRelationData> {
  @override
  final Iterable<Type> types = const [
    GAddTaskRelationData,
    _$GAddTaskRelationData
  ];
  @override
  final String wireName = 'GAddTaskRelationData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAddTaskRelationData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'addTaskRelation',
      serializers.serialize(object.addTaskRelation,
          specifiedType: const FullType(GAddTaskRelationData_addTaskRelation)),
    ];

    return result;
  }

  @override
  GAddTaskRelationData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAddTaskRelationDataBuilder();

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
        case 'addTaskRelation':
          result.addTaskRelation.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GAddTaskRelationData_addTaskRelation))!
              as GAddTaskRelationData_addTaskRelation);
          break;
      }
    }

    return result.build();
  }
}

class _$GAddTaskRelationData_addTaskRelationSerializer
    implements StructuredSerializer<GAddTaskRelationData_addTaskRelation> {
  @override
  final Iterable<Type> types = const [
    GAddTaskRelationData_addTaskRelation,
    _$GAddTaskRelationData_addTaskRelation
  ];
  @override
  final String wireName = 'GAddTaskRelationData_addTaskRelation';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAddTaskRelationData_addTaskRelation object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind,
          specifiedType: const FullType(_i2.GTaskRelationKind)),
      'from',
      serializers.serialize(object.from,
          specifiedType:
              const FullType(GAddTaskRelationData_addTaskRelation_from)),
      'to',
      serializers.serialize(object.to,
          specifiedType:
              const FullType(GAddTaskRelationData_addTaskRelation_to)),
    ];

    return result;
  }

  @override
  GAddTaskRelationData_addTaskRelation deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAddTaskRelationData_addTaskRelationBuilder();

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
        case 'kind':
          result.kind = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskRelationKind))!
              as _i2.GTaskRelationKind;
          break;
        case 'from':
          result.from.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GAddTaskRelationData_addTaskRelation_from))!
              as GAddTaskRelationData_addTaskRelation_from);
          break;
        case 'to':
          result.to.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GAddTaskRelationData_addTaskRelation_to))!
              as GAddTaskRelationData_addTaskRelation_to);
          break;
      }
    }

    return result.build();
  }
}

class _$GAddTaskRelationData_addTaskRelation_fromSerializer
    implements StructuredSerializer<GAddTaskRelationData_addTaskRelation_from> {
  @override
  final Iterable<Type> types = const [
    GAddTaskRelationData_addTaskRelation_from,
    _$GAddTaskRelationData_addTaskRelation_from
  ];
  @override
  final String wireName = 'GAddTaskRelationData_addTaskRelation_from';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAddTaskRelationData_addTaskRelation_from object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAddTaskRelationData_addTaskRelation_from deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAddTaskRelationData_addTaskRelation_fromBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GAddTaskRelationData_addTaskRelation_toSerializer
    implements StructuredSerializer<GAddTaskRelationData_addTaskRelation_to> {
  @override
  final Iterable<Type> types = const [
    GAddTaskRelationData_addTaskRelation_to,
    _$GAddTaskRelationData_addTaskRelation_to
  ];
  @override
  final String wireName = 'GAddTaskRelationData_addTaskRelation_to';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAddTaskRelationData_addTaskRelation_to object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAddTaskRelationData_addTaskRelation_to deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAddTaskRelationData_addTaskRelation_toBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GRemoveTaskRelationDataSerializer
    implements StructuredSerializer<GRemoveTaskRelationData> {
  @override
  final Iterable<Type> types = const [
    GRemoveTaskRelationData,
    _$GRemoveTaskRelationData
  ];
  @override
  final String wireName = 'GRemoveTaskRelationData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRemoveTaskRelationData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'removeTaskRelation',
      serializers.serialize(object.removeTaskRelation,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GRemoveTaskRelationData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRemoveTaskRelationDataBuilder();

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
        case 'removeTaskRelation':
          result.removeTaskRelation = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GAddTaskRelationData extends GAddTaskRelationData {
  @override
  final String G__typename;
  @override
  final GAddTaskRelationData_addTaskRelation addTaskRelation;

  factory _$GAddTaskRelationData(
          [void Function(GAddTaskRelationDataBuilder)? updates]) =>
      (GAddTaskRelationDataBuilder()..update(updates))._build();

  _$GAddTaskRelationData._(
      {required this.G__typename, required this.addTaskRelation})
      : super._();
  @override
  GAddTaskRelationData rebuild(
          void Function(GAddTaskRelationDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAddTaskRelationDataBuilder toBuilder() =>
      GAddTaskRelationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAddTaskRelationData &&
        G__typename == other.G__typename &&
        addTaskRelation == other.addTaskRelation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, addTaskRelation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAddTaskRelationData')
          ..add('G__typename', G__typename)
          ..add('addTaskRelation', addTaskRelation))
        .toString();
  }
}

class GAddTaskRelationDataBuilder
    implements Builder<GAddTaskRelationData, GAddTaskRelationDataBuilder> {
  _$GAddTaskRelationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GAddTaskRelationData_addTaskRelationBuilder? _addTaskRelation;
  GAddTaskRelationData_addTaskRelationBuilder get addTaskRelation =>
      _$this._addTaskRelation ??= GAddTaskRelationData_addTaskRelationBuilder();
  set addTaskRelation(
          GAddTaskRelationData_addTaskRelationBuilder? addTaskRelation) =>
      _$this._addTaskRelation = addTaskRelation;

  GAddTaskRelationDataBuilder() {
    GAddTaskRelationData._initializeBuilder(this);
  }

  GAddTaskRelationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _addTaskRelation = $v.addTaskRelation.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAddTaskRelationData other) {
    _$v = other as _$GAddTaskRelationData;
  }

  @override
  void update(void Function(GAddTaskRelationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAddTaskRelationData build() => _build();

  _$GAddTaskRelationData _build() {
    _$GAddTaskRelationData _$result;
    try {
      _$result = _$v ??
          _$GAddTaskRelationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAddTaskRelationData', 'G__typename'),
            addTaskRelation: addTaskRelation.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'addTaskRelation';
        addTaskRelation.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAddTaskRelationData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAddTaskRelationData_addTaskRelation
    extends GAddTaskRelationData_addTaskRelation {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskRelationKind kind;
  @override
  final GAddTaskRelationData_addTaskRelation_from from;
  @override
  final GAddTaskRelationData_addTaskRelation_to to;

  factory _$GAddTaskRelationData_addTaskRelation(
          [void Function(GAddTaskRelationData_addTaskRelationBuilder)?
              updates]) =>
      (GAddTaskRelationData_addTaskRelationBuilder()..update(updates))._build();

  _$GAddTaskRelationData_addTaskRelation._(
      {required this.G__typename,
      required this.id,
      required this.kind,
      required this.from,
      required this.to})
      : super._();
  @override
  GAddTaskRelationData_addTaskRelation rebuild(
          void Function(GAddTaskRelationData_addTaskRelationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAddTaskRelationData_addTaskRelationBuilder toBuilder() =>
      GAddTaskRelationData_addTaskRelationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAddTaskRelationData_addTaskRelation &&
        G__typename == other.G__typename &&
        id == other.id &&
        kind == other.kind &&
        from == other.from &&
        to == other.to;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAddTaskRelationData_addTaskRelation')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('kind', kind)
          ..add('from', from)
          ..add('to', to))
        .toString();
  }
}

class GAddTaskRelationData_addTaskRelationBuilder
    implements
        Builder<GAddTaskRelationData_addTaskRelation,
            GAddTaskRelationData_addTaskRelationBuilder> {
  _$GAddTaskRelationData_addTaskRelation? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTaskRelationKind? _kind;
  _i2.GTaskRelationKind? get kind => _$this._kind;
  set kind(_i2.GTaskRelationKind? kind) => _$this._kind = kind;

  GAddTaskRelationData_addTaskRelation_fromBuilder? _from;
  GAddTaskRelationData_addTaskRelation_fromBuilder get from =>
      _$this._from ??= GAddTaskRelationData_addTaskRelation_fromBuilder();
  set from(GAddTaskRelationData_addTaskRelation_fromBuilder? from) =>
      _$this._from = from;

  GAddTaskRelationData_addTaskRelation_toBuilder? _to;
  GAddTaskRelationData_addTaskRelation_toBuilder get to =>
      _$this._to ??= GAddTaskRelationData_addTaskRelation_toBuilder();
  set to(GAddTaskRelationData_addTaskRelation_toBuilder? to) => _$this._to = to;

  GAddTaskRelationData_addTaskRelationBuilder() {
    GAddTaskRelationData_addTaskRelation._initializeBuilder(this);
  }

  GAddTaskRelationData_addTaskRelationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _kind = $v.kind;
      _from = $v.from.toBuilder();
      _to = $v.to.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAddTaskRelationData_addTaskRelation other) {
    _$v = other as _$GAddTaskRelationData_addTaskRelation;
  }

  @override
  void update(
      void Function(GAddTaskRelationData_addTaskRelationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAddTaskRelationData_addTaskRelation build() => _build();

  _$GAddTaskRelationData_addTaskRelation _build() {
    _$GAddTaskRelationData_addTaskRelation _$result;
    try {
      _$result = _$v ??
          _$GAddTaskRelationData_addTaskRelation._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GAddTaskRelationData_addTaskRelation', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GAddTaskRelationData_addTaskRelation', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'GAddTaskRelationData_addTaskRelation', 'kind'),
            from: from.build(),
            to: to.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'from';
        from.build();
        _$failedField = 'to';
        to.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAddTaskRelationData_addTaskRelation',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAddTaskRelationData_addTaskRelation_from
    extends GAddTaskRelationData_addTaskRelation_from {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GAddTaskRelationData_addTaskRelation_from(
          [void Function(GAddTaskRelationData_addTaskRelation_fromBuilder)?
              updates]) =>
      (GAddTaskRelationData_addTaskRelation_fromBuilder()..update(updates))
          ._build();

  _$GAddTaskRelationData_addTaskRelation_from._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GAddTaskRelationData_addTaskRelation_from rebuild(
          void Function(GAddTaskRelationData_addTaskRelation_fromBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAddTaskRelationData_addTaskRelation_fromBuilder toBuilder() =>
      GAddTaskRelationData_addTaskRelation_fromBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAddTaskRelationData_addTaskRelation_from &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GAddTaskRelationData_addTaskRelation_from')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GAddTaskRelationData_addTaskRelation_fromBuilder
    implements
        Builder<GAddTaskRelationData_addTaskRelation_from,
            GAddTaskRelationData_addTaskRelation_fromBuilder> {
  _$GAddTaskRelationData_addTaskRelation_from? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GAddTaskRelationData_addTaskRelation_fromBuilder() {
    GAddTaskRelationData_addTaskRelation_from._initializeBuilder(this);
  }

  GAddTaskRelationData_addTaskRelation_fromBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAddTaskRelationData_addTaskRelation_from other) {
    _$v = other as _$GAddTaskRelationData_addTaskRelation_from;
  }

  @override
  void update(
      void Function(GAddTaskRelationData_addTaskRelation_fromBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GAddTaskRelationData_addTaskRelation_from build() => _build();

  _$GAddTaskRelationData_addTaskRelation_from _build() {
    final _$result = _$v ??
        _$GAddTaskRelationData_addTaskRelation_from._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GAddTaskRelationData_addTaskRelation_from', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAddTaskRelationData_addTaskRelation_from', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAddTaskRelationData_addTaskRelation_to
    extends GAddTaskRelationData_addTaskRelation_to {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GAddTaskRelationData_addTaskRelation_to(
          [void Function(GAddTaskRelationData_addTaskRelation_toBuilder)?
              updates]) =>
      (GAddTaskRelationData_addTaskRelation_toBuilder()..update(updates))
          ._build();

  _$GAddTaskRelationData_addTaskRelation_to._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GAddTaskRelationData_addTaskRelation_to rebuild(
          void Function(GAddTaskRelationData_addTaskRelation_toBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAddTaskRelationData_addTaskRelation_toBuilder toBuilder() =>
      GAddTaskRelationData_addTaskRelation_toBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAddTaskRelationData_addTaskRelation_to &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GAddTaskRelationData_addTaskRelation_to')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GAddTaskRelationData_addTaskRelation_toBuilder
    implements
        Builder<GAddTaskRelationData_addTaskRelation_to,
            GAddTaskRelationData_addTaskRelation_toBuilder> {
  _$GAddTaskRelationData_addTaskRelation_to? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GAddTaskRelationData_addTaskRelation_toBuilder() {
    GAddTaskRelationData_addTaskRelation_to._initializeBuilder(this);
  }

  GAddTaskRelationData_addTaskRelation_toBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAddTaskRelationData_addTaskRelation_to other) {
    _$v = other as _$GAddTaskRelationData_addTaskRelation_to;
  }

  @override
  void update(
      void Function(GAddTaskRelationData_addTaskRelation_toBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAddTaskRelationData_addTaskRelation_to build() => _build();

  _$GAddTaskRelationData_addTaskRelation_to _build() {
    final _$result = _$v ??
        _$GAddTaskRelationData_addTaskRelation_to._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GAddTaskRelationData_addTaskRelation_to', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAddTaskRelationData_addTaskRelation_to', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRemoveTaskRelationData extends GRemoveTaskRelationData {
  @override
  final String G__typename;
  @override
  final bool removeTaskRelation;

  factory _$GRemoveTaskRelationData(
          [void Function(GRemoveTaskRelationDataBuilder)? updates]) =>
      (GRemoveTaskRelationDataBuilder()..update(updates))._build();

  _$GRemoveTaskRelationData._(
      {required this.G__typename, required this.removeTaskRelation})
      : super._();
  @override
  GRemoveTaskRelationData rebuild(
          void Function(GRemoveTaskRelationDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRemoveTaskRelationDataBuilder toBuilder() =>
      GRemoveTaskRelationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRemoveTaskRelationData &&
        G__typename == other.G__typename &&
        removeTaskRelation == other.removeTaskRelation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, removeTaskRelation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRemoveTaskRelationData')
          ..add('G__typename', G__typename)
          ..add('removeTaskRelation', removeTaskRelation))
        .toString();
  }
}

class GRemoveTaskRelationDataBuilder
    implements
        Builder<GRemoveTaskRelationData, GRemoveTaskRelationDataBuilder> {
  _$GRemoveTaskRelationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _removeTaskRelation;
  bool? get removeTaskRelation => _$this._removeTaskRelation;
  set removeTaskRelation(bool? removeTaskRelation) =>
      _$this._removeTaskRelation = removeTaskRelation;

  GRemoveTaskRelationDataBuilder() {
    GRemoveTaskRelationData._initializeBuilder(this);
  }

  GRemoveTaskRelationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _removeTaskRelation = $v.removeTaskRelation;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRemoveTaskRelationData other) {
    _$v = other as _$GRemoveTaskRelationData;
  }

  @override
  void update(void Function(GRemoveTaskRelationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRemoveTaskRelationData build() => _build();

  _$GRemoveTaskRelationData _build() {
    final _$result = _$v ??
        _$GRemoveTaskRelationData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GRemoveTaskRelationData', 'G__typename'),
          removeTaskRelation: BuiltValueNullFieldError.checkNotNull(
              removeTaskRelation,
              r'GRemoveTaskRelationData',
              'removeTaskRelation'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
