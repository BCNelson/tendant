// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_state.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GMarkInboxReadData> _$gMarkInboxReadDataSerializer =
    _$GMarkInboxReadDataSerializer();
Serializer<GMarkInboxReadData_markInboxRead>
    _$gMarkInboxReadDataMarkInboxReadSerializer =
    _$GMarkInboxReadData_markInboxReadSerializer();
Serializer<GDismissInboxMessageData> _$gDismissInboxMessageDataSerializer =
    _$GDismissInboxMessageDataSerializer();
Serializer<GDismissInboxMessageData_dismissInboxMessage>
    _$gDismissInboxMessageDataDismissInboxMessageSerializer =
    _$GDismissInboxMessageData_dismissInboxMessageSerializer();

class _$GMarkInboxReadDataSerializer
    implements StructuredSerializer<GMarkInboxReadData> {
  @override
  final Iterable<Type> types = const [GMarkInboxReadData, _$GMarkInboxReadData];
  @override
  final String wireName = 'GMarkInboxReadData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GMarkInboxReadData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'markInboxRead',
      serializers.serialize(object.markInboxRead,
          specifiedType: const FullType(GMarkInboxReadData_markInboxRead)),
    ];

    return result;
  }

  @override
  GMarkInboxReadData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GMarkInboxReadDataBuilder();

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
        case 'markInboxRead':
          result.markInboxRead.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GMarkInboxReadData_markInboxRead))!
              as GMarkInboxReadData_markInboxRead);
          break;
      }
    }

    return result.build();
  }
}

class _$GMarkInboxReadData_markInboxReadSerializer
    implements StructuredSerializer<GMarkInboxReadData_markInboxRead> {
  @override
  final Iterable<Type> types = const [
    GMarkInboxReadData_markInboxRead,
    _$GMarkInboxReadData_markInboxRead
  ];
  @override
  final String wireName = 'GMarkInboxReadData_markInboxRead';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GMarkInboxReadData_markInboxRead object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.seenAt;
    if (value != null) {
      result
        ..add('seenAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.readAt;
    if (value != null) {
      result
        ..add('readAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.dismissedAt;
    if (value != null) {
      result
        ..add('dismissedAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    return result;
  }

  @override
  GMarkInboxReadData_markInboxRead deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GMarkInboxReadData_markInboxReadBuilder();

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
        case 'seenAt':
          result.seenAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'readAt':
          result.readAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'dismissedAt':
          result.dismissedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissInboxMessageDataSerializer
    implements StructuredSerializer<GDismissInboxMessageData> {
  @override
  final Iterable<Type> types = const [
    GDismissInboxMessageData,
    _$GDismissInboxMessageData
  ];
  @override
  final String wireName = 'GDismissInboxMessageData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissInboxMessageData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'dismissInboxMessage',
      serializers.serialize(object.dismissInboxMessage,
          specifiedType:
              const FullType(GDismissInboxMessageData_dismissInboxMessage)),
    ];

    return result;
  }

  @override
  GDismissInboxMessageData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissInboxMessageDataBuilder();

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
        case 'dismissInboxMessage':
          result.dismissInboxMessage.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GDismissInboxMessageData_dismissInboxMessage))!
              as GDismissInboxMessageData_dismissInboxMessage);
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissInboxMessageData_dismissInboxMessageSerializer
    implements
        StructuredSerializer<GDismissInboxMessageData_dismissInboxMessage> {
  @override
  final Iterable<Type> types = const [
    GDismissInboxMessageData_dismissInboxMessage,
    _$GDismissInboxMessageData_dismissInboxMessage
  ];
  @override
  final String wireName = 'GDismissInboxMessageData_dismissInboxMessage';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GDismissInboxMessageData_dismissInboxMessage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.seenAt;
    if (value != null) {
      result
        ..add('seenAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.readAt;
    if (value != null) {
      result
        ..add('readAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.dismissedAt;
    if (value != null) {
      result
        ..add('dismissedAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    return result;
  }

  @override
  GDismissInboxMessageData_dismissInboxMessage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissInboxMessageData_dismissInboxMessageBuilder();

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
        case 'seenAt':
          result.seenAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'readAt':
          result.readAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'dismissedAt':
          result.dismissedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GMarkInboxReadData extends GMarkInboxReadData {
  @override
  final String G__typename;
  @override
  final GMarkInboxReadData_markInboxRead markInboxRead;

  factory _$GMarkInboxReadData(
          [void Function(GMarkInboxReadDataBuilder)? updates]) =>
      (GMarkInboxReadDataBuilder()..update(updates))._build();

  _$GMarkInboxReadData._(
      {required this.G__typename, required this.markInboxRead})
      : super._();
  @override
  GMarkInboxReadData rebuild(
          void Function(GMarkInboxReadDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GMarkInboxReadDataBuilder toBuilder() =>
      GMarkInboxReadDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GMarkInboxReadData &&
        G__typename == other.G__typename &&
        markInboxRead == other.markInboxRead;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, markInboxRead.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GMarkInboxReadData')
          ..add('G__typename', G__typename)
          ..add('markInboxRead', markInboxRead))
        .toString();
  }
}

class GMarkInboxReadDataBuilder
    implements Builder<GMarkInboxReadData, GMarkInboxReadDataBuilder> {
  _$GMarkInboxReadData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GMarkInboxReadData_markInboxReadBuilder? _markInboxRead;
  GMarkInboxReadData_markInboxReadBuilder get markInboxRead =>
      _$this._markInboxRead ??= GMarkInboxReadData_markInboxReadBuilder();
  set markInboxRead(GMarkInboxReadData_markInboxReadBuilder? markInboxRead) =>
      _$this._markInboxRead = markInboxRead;

  GMarkInboxReadDataBuilder() {
    GMarkInboxReadData._initializeBuilder(this);
  }

  GMarkInboxReadDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _markInboxRead = $v.markInboxRead.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GMarkInboxReadData other) {
    _$v = other as _$GMarkInboxReadData;
  }

  @override
  void update(void Function(GMarkInboxReadDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GMarkInboxReadData build() => _build();

  _$GMarkInboxReadData _build() {
    _$GMarkInboxReadData _$result;
    try {
      _$result = _$v ??
          _$GMarkInboxReadData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GMarkInboxReadData', 'G__typename'),
            markInboxRead: markInboxRead.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'markInboxRead';
        markInboxRead.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GMarkInboxReadData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GMarkInboxReadData_markInboxRead
    extends GMarkInboxReadData_markInboxRead {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime? seenAt;
  @override
  final _i2.GTime? readAt;
  @override
  final _i2.GTime? dismissedAt;

  factory _$GMarkInboxReadData_markInboxRead(
          [void Function(GMarkInboxReadData_markInboxReadBuilder)? updates]) =>
      (GMarkInboxReadData_markInboxReadBuilder()..update(updates))._build();

  _$GMarkInboxReadData_markInboxRead._(
      {required this.G__typename,
      required this.id,
      this.seenAt,
      this.readAt,
      this.dismissedAt})
      : super._();
  @override
  GMarkInboxReadData_markInboxRead rebuild(
          void Function(GMarkInboxReadData_markInboxReadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GMarkInboxReadData_markInboxReadBuilder toBuilder() =>
      GMarkInboxReadData_markInboxReadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GMarkInboxReadData_markInboxRead &&
        G__typename == other.G__typename &&
        id == other.id &&
        seenAt == other.seenAt &&
        readAt == other.readAt &&
        dismissedAt == other.dismissedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, seenAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, dismissedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GMarkInboxReadData_markInboxRead')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('seenAt', seenAt)
          ..add('readAt', readAt)
          ..add('dismissedAt', dismissedAt))
        .toString();
  }
}

class GMarkInboxReadData_markInboxReadBuilder
    implements
        Builder<GMarkInboxReadData_markInboxRead,
            GMarkInboxReadData_markInboxReadBuilder> {
  _$GMarkInboxReadData_markInboxRead? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _seenAt;
  _i2.GTimeBuilder get seenAt => _$this._seenAt ??= _i2.GTimeBuilder();
  set seenAt(_i2.GTimeBuilder? seenAt) => _$this._seenAt = seenAt;

  _i2.GTimeBuilder? _readAt;
  _i2.GTimeBuilder get readAt => _$this._readAt ??= _i2.GTimeBuilder();
  set readAt(_i2.GTimeBuilder? readAt) => _$this._readAt = readAt;

  _i2.GTimeBuilder? _dismissedAt;
  _i2.GTimeBuilder get dismissedAt =>
      _$this._dismissedAt ??= _i2.GTimeBuilder();
  set dismissedAt(_i2.GTimeBuilder? dismissedAt) =>
      _$this._dismissedAt = dismissedAt;

  GMarkInboxReadData_markInboxReadBuilder() {
    GMarkInboxReadData_markInboxRead._initializeBuilder(this);
  }

  GMarkInboxReadData_markInboxReadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _seenAt = $v.seenAt?.toBuilder();
      _readAt = $v.readAt?.toBuilder();
      _dismissedAt = $v.dismissedAt?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GMarkInboxReadData_markInboxRead other) {
    _$v = other as _$GMarkInboxReadData_markInboxRead;
  }

  @override
  void update(void Function(GMarkInboxReadData_markInboxReadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GMarkInboxReadData_markInboxRead build() => _build();

  _$GMarkInboxReadData_markInboxRead _build() {
    _$GMarkInboxReadData_markInboxRead _$result;
    try {
      _$result = _$v ??
          _$GMarkInboxReadData_markInboxRead._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GMarkInboxReadData_markInboxRead', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GMarkInboxReadData_markInboxRead', 'id'),
            seenAt: _seenAt?.build(),
            readAt: _readAt?.build(),
            dismissedAt: _dismissedAt?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'seenAt';
        _seenAt?.build();
        _$failedField = 'readAt';
        _readAt?.build();
        _$failedField = 'dismissedAt';
        _dismissedAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GMarkInboxReadData_markInboxRead', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDismissInboxMessageData extends GDismissInboxMessageData {
  @override
  final String G__typename;
  @override
  final GDismissInboxMessageData_dismissInboxMessage dismissInboxMessage;

  factory _$GDismissInboxMessageData(
          [void Function(GDismissInboxMessageDataBuilder)? updates]) =>
      (GDismissInboxMessageDataBuilder()..update(updates))._build();

  _$GDismissInboxMessageData._(
      {required this.G__typename, required this.dismissInboxMessage})
      : super._();
  @override
  GDismissInboxMessageData rebuild(
          void Function(GDismissInboxMessageDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissInboxMessageDataBuilder toBuilder() =>
      GDismissInboxMessageDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissInboxMessageData &&
        G__typename == other.G__typename &&
        dismissInboxMessage == other.dismissInboxMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, dismissInboxMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissInboxMessageData')
          ..add('G__typename', G__typename)
          ..add('dismissInboxMessage', dismissInboxMessage))
        .toString();
  }
}

class GDismissInboxMessageDataBuilder
    implements
        Builder<GDismissInboxMessageData, GDismissInboxMessageDataBuilder> {
  _$GDismissInboxMessageData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GDismissInboxMessageData_dismissInboxMessageBuilder? _dismissInboxMessage;
  GDismissInboxMessageData_dismissInboxMessageBuilder get dismissInboxMessage =>
      _$this._dismissInboxMessage ??=
          GDismissInboxMessageData_dismissInboxMessageBuilder();
  set dismissInboxMessage(
          GDismissInboxMessageData_dismissInboxMessageBuilder?
              dismissInboxMessage) =>
      _$this._dismissInboxMessage = dismissInboxMessage;

  GDismissInboxMessageDataBuilder() {
    GDismissInboxMessageData._initializeBuilder(this);
  }

  GDismissInboxMessageDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _dismissInboxMessage = $v.dismissInboxMessage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissInboxMessageData other) {
    _$v = other as _$GDismissInboxMessageData;
  }

  @override
  void update(void Function(GDismissInboxMessageDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissInboxMessageData build() => _build();

  _$GDismissInboxMessageData _build() {
    _$GDismissInboxMessageData _$result;
    try {
      _$result = _$v ??
          _$GDismissInboxMessageData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GDismissInboxMessageData', 'G__typename'),
            dismissInboxMessage: dismissInboxMessage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dismissInboxMessage';
        dismissInboxMessage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDismissInboxMessageData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDismissInboxMessageData_dismissInboxMessage
    extends GDismissInboxMessageData_dismissInboxMessage {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime? seenAt;
  @override
  final _i2.GTime? readAt;
  @override
  final _i2.GTime? dismissedAt;

  factory _$GDismissInboxMessageData_dismissInboxMessage(
          [void Function(GDismissInboxMessageData_dismissInboxMessageBuilder)?
              updates]) =>
      (GDismissInboxMessageData_dismissInboxMessageBuilder()..update(updates))
          ._build();

  _$GDismissInboxMessageData_dismissInboxMessage._(
      {required this.G__typename,
      required this.id,
      this.seenAt,
      this.readAt,
      this.dismissedAt})
      : super._();
  @override
  GDismissInboxMessageData_dismissInboxMessage rebuild(
          void Function(GDismissInboxMessageData_dismissInboxMessageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissInboxMessageData_dismissInboxMessageBuilder toBuilder() =>
      GDismissInboxMessageData_dismissInboxMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissInboxMessageData_dismissInboxMessage &&
        G__typename == other.G__typename &&
        id == other.id &&
        seenAt == other.seenAt &&
        readAt == other.readAt &&
        dismissedAt == other.dismissedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, seenAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, dismissedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GDismissInboxMessageData_dismissInboxMessage')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('seenAt', seenAt)
          ..add('readAt', readAt)
          ..add('dismissedAt', dismissedAt))
        .toString();
  }
}

class GDismissInboxMessageData_dismissInboxMessageBuilder
    implements
        Builder<GDismissInboxMessageData_dismissInboxMessage,
            GDismissInboxMessageData_dismissInboxMessageBuilder> {
  _$GDismissInboxMessageData_dismissInboxMessage? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _seenAt;
  _i2.GTimeBuilder get seenAt => _$this._seenAt ??= _i2.GTimeBuilder();
  set seenAt(_i2.GTimeBuilder? seenAt) => _$this._seenAt = seenAt;

  _i2.GTimeBuilder? _readAt;
  _i2.GTimeBuilder get readAt => _$this._readAt ??= _i2.GTimeBuilder();
  set readAt(_i2.GTimeBuilder? readAt) => _$this._readAt = readAt;

  _i2.GTimeBuilder? _dismissedAt;
  _i2.GTimeBuilder get dismissedAt =>
      _$this._dismissedAt ??= _i2.GTimeBuilder();
  set dismissedAt(_i2.GTimeBuilder? dismissedAt) =>
      _$this._dismissedAt = dismissedAt;

  GDismissInboxMessageData_dismissInboxMessageBuilder() {
    GDismissInboxMessageData_dismissInboxMessage._initializeBuilder(this);
  }

  GDismissInboxMessageData_dismissInboxMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _seenAt = $v.seenAt?.toBuilder();
      _readAt = $v.readAt?.toBuilder();
      _dismissedAt = $v.dismissedAt?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissInboxMessageData_dismissInboxMessage other) {
    _$v = other as _$GDismissInboxMessageData_dismissInboxMessage;
  }

  @override
  void update(
      void Function(GDismissInboxMessageData_dismissInboxMessageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissInboxMessageData_dismissInboxMessage build() => _build();

  _$GDismissInboxMessageData_dismissInboxMessage _build() {
    _$GDismissInboxMessageData_dismissInboxMessage _$result;
    try {
      _$result = _$v ??
          _$GDismissInboxMessageData_dismissInboxMessage._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GDismissInboxMessageData_dismissInboxMessage', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GDismissInboxMessageData_dismissInboxMessage', 'id'),
            seenAt: _seenAt?.build(),
            readAt: _readAt?.build(),
            dismissedAt: _dismissedAt?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'seenAt';
        _seenAt?.build();
        _$failedField = 'readAt';
        _readAt?.build();
        _$failedField = 'dismissedAt';
        _dismissedAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDismissInboxMessageData_dismissInboxMessage',
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
