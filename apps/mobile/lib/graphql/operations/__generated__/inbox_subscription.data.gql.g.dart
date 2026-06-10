// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_subscription.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxEntryArrivedData> _$gInboxEntryArrivedDataSerializer =
    _$GInboxEntryArrivedDataSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived>
    _$gInboxEntryArrivedDataInboxEntryArrivedSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrivedSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_itemSerializer();

class _$GInboxEntryArrivedDataSerializer
    implements StructuredSerializer<GInboxEntryArrivedData> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData,
    _$GInboxEntryArrivedData
  ];
  @override
  final String wireName = 'GInboxEntryArrivedData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxEntryArrivedData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'inboxEntryArrived',
      serializers.serialize(object.inboxEntryArrived,
          specifiedType:
              const FullType(GInboxEntryArrivedData_inboxEntryArrived)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxEntryArrivedDataBuilder();

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
        case 'inboxEntryArrived':
          result.inboxEntryArrived.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GInboxEntryArrivedData_inboxEntryArrived))!
              as GInboxEntryArrivedData_inboxEntryArrived);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrivedSerializer
    implements StructuredSerializer<GInboxEntryArrivedData_inboxEntryArrived> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived,
    _$GInboxEntryArrivedData_inboxEntryArrived
  ];
  @override
  final String wireName = 'GInboxEntryArrivedData_inboxEntryArrived';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxEntryArrivedData_inboxEntryArrived object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind, specifiedType: const FullType(String)),
      'urgency',
      serializers.serialize(object.urgency,
          specifiedType: const FullType(double)),
      'item',
      serializers.serialize(object.item,
          specifiedType:
              const FullType(GInboxEntryArrivedData_inboxEntryArrived_item)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxEntryArrivedData_inboxEntryArrivedBuilder();

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
              specifiedType: const FullType(String))! as String;
          break;
        case 'urgency':
          result.urgency = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'item':
          result.item.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GInboxEntryArrivedData_inboxEntryArrived_item))!
              as GInboxEntryArrivedData_inboxEntryArrived_item);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_itemSerializer
    implements
        StructuredSerializer<GInboxEntryArrivedData_inboxEntryArrived_item> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item,
    _$GInboxEntryArrivedData_inboxEntryArrived_item
  ];
  @override
  final String wireName = 'GInboxEntryArrivedData_inboxEntryArrived_item';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxEntryArrivedData_inboxEntryArrived_itemBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData extends GInboxEntryArrivedData {
  @override
  final String G__typename;
  @override
  final GInboxEntryArrivedData_inboxEntryArrived inboxEntryArrived;

  factory _$GInboxEntryArrivedData(
          [void Function(GInboxEntryArrivedDataBuilder)? updates]) =>
      (GInboxEntryArrivedDataBuilder()..update(updates))._build();

  _$GInboxEntryArrivedData._(
      {required this.G__typename, required this.inboxEntryArrived})
      : super._();
  @override
  GInboxEntryArrivedData rebuild(
          void Function(GInboxEntryArrivedDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedDataBuilder toBuilder() =>
      GInboxEntryArrivedDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxEntryArrivedData &&
        G__typename == other.G__typename &&
        inboxEntryArrived == other.inboxEntryArrived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, inboxEntryArrived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxEntryArrivedData')
          ..add('G__typename', G__typename)
          ..add('inboxEntryArrived', inboxEntryArrived))
        .toString();
  }
}

class GInboxEntryArrivedDataBuilder
    implements Builder<GInboxEntryArrivedData, GInboxEntryArrivedDataBuilder> {
  _$GInboxEntryArrivedData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxEntryArrivedData_inboxEntryArrivedBuilder? _inboxEntryArrived;
  GInboxEntryArrivedData_inboxEntryArrivedBuilder get inboxEntryArrived =>
      _$this._inboxEntryArrived ??=
          GInboxEntryArrivedData_inboxEntryArrivedBuilder();
  set inboxEntryArrived(
          GInboxEntryArrivedData_inboxEntryArrivedBuilder? inboxEntryArrived) =>
      _$this._inboxEntryArrived = inboxEntryArrived;

  GInboxEntryArrivedDataBuilder() {
    GInboxEntryArrivedData._initializeBuilder(this);
  }

  GInboxEntryArrivedDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _inboxEntryArrived = $v.inboxEntryArrived.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxEntryArrivedData other) {
    _$v = other as _$GInboxEntryArrivedData;
  }

  @override
  void update(void Function(GInboxEntryArrivedDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData build() => _build();

  _$GInboxEntryArrivedData _build() {
    _$GInboxEntryArrivedData _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GInboxEntryArrivedData', 'G__typename'),
            inboxEntryArrived: inboxEntryArrived.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inboxEntryArrived';
        inboxEntryArrived.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived
    extends GInboxEntryArrivedData_inboxEntryArrived {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String kind;
  @override
  final double urgency;
  @override
  final GInboxEntryArrivedData_inboxEntryArrived_item item;

  factory _$GInboxEntryArrivedData_inboxEntryArrived(
          [void Function(GInboxEntryArrivedData_inboxEntryArrivedBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrivedBuilder()..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived._(
      {required this.G__typename,
      required this.id,
      required this.kind,
      required this.urgency,
      required this.item})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived rebuild(
          void Function(GInboxEntryArrivedData_inboxEntryArrivedBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrivedBuilder toBuilder() =>
      GInboxEntryArrivedData_inboxEntryArrivedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxEntryArrivedData_inboxEntryArrived &&
        G__typename == other.G__typename &&
        id == other.id &&
        kind == other.kind &&
        urgency == other.urgency &&
        item == other.item;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, urgency.hashCode);
    _$hash = $jc(_$hash, item.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('kind', kind)
          ..add('urgency', urgency)
          ..add('item', item))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrivedBuilder
    implements
        Builder<GInboxEntryArrivedData_inboxEntryArrived,
            GInboxEntryArrivedData_inboxEntryArrivedBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  double? _urgency;
  double? get urgency => _$this._urgency;
  set urgency(double? urgency) => _$this._urgency = urgency;

  GInboxEntryArrivedData_inboxEntryArrived_itemBuilder? _item;
  GInboxEntryArrivedData_inboxEntryArrived_itemBuilder get item =>
      _$this._item ??= GInboxEntryArrivedData_inboxEntryArrived_itemBuilder();
  set item(GInboxEntryArrivedData_inboxEntryArrived_itemBuilder? item) =>
      _$this._item = item;

  GInboxEntryArrivedData_inboxEntryArrivedBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrivedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _kind = $v.kind;
      _urgency = $v.urgency;
      _item = $v.item.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxEntryArrivedData_inboxEntryArrived other) {
    _$v = other as _$GInboxEntryArrivedData_inboxEntryArrived;
  }

  @override
  void update(
      void Function(GInboxEntryArrivedData_inboxEntryArrivedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived _build() {
    _$GInboxEntryArrivedData_inboxEntryArrived _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData_inboxEntryArrived._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxEntryArrivedData_inboxEntryArrived', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxEntryArrivedData_inboxEntryArrived', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'GInboxEntryArrivedData_inboxEntryArrived', 'kind'),
            urgency: BuiltValueNullFieldError.checkNotNull(urgency,
                r'GInboxEntryArrivedData_inboxEntryArrived', 'urgency'),
            item: item.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'item';
        item.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData_inboxEntryArrived',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item
    extends GInboxEntryArrivedData_inboxEntryArrived_item {
  @override
  final String G__typename;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item(
          [void Function(GInboxEntryArrivedData_inboxEntryArrived_itemBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_itemBuilder()..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item._({required this.G__typename})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item rebuild(
          void Function(GInboxEntryArrivedData_inboxEntryArrived_itemBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_itemBuilder toBuilder() =>
      GInboxEntryArrivedData_inboxEntryArrived_itemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxEntryArrivedData_inboxEntryArrived_item &&
        G__typename == other.G__typename;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_itemBuilder
    implements
        Builder<GInboxEntryArrivedData_inboxEntryArrived_item,
            GInboxEntryArrivedData_inboxEntryArrived_itemBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxEntryArrivedData_inboxEntryArrived_itemBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_itemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxEntryArrivedData_inboxEntryArrived_item other) {
    _$v = other as _$GInboxEntryArrivedData_inboxEntryArrived_item;
  }

  @override
  void update(
      void Function(GInboxEntryArrivedData_inboxEntryArrived_itemBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item', 'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
