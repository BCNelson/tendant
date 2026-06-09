// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_subscription.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxItemArrivedData> _$gInboxItemArrivedDataSerializer =
    _$GInboxItemArrivedDataSerializer();
Serializer<GInboxItemArrivedData_inboxItemArrived__base>
    _$gInboxItemArrivedDataInboxItemArrivedBaseSerializer =
    _$GInboxItemArrivedData_inboxItemArrived__baseSerializer();
Serializer<GInboxItemArrivedData_inboxItemArrived__asAgentAssignment>
    _$gInboxItemArrivedDataInboxItemArrivedAsAgentAssignmentSerializer =
    _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentSerializer();
Serializer<GInboxItemArrivedData_inboxItemArrived__asApprovalRequest>
    _$gInboxItemArrivedDataInboxItemArrivedAsApprovalRequestSerializer =
    _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequestSerializer();
Serializer<GInboxItemArrivedData_inboxItemArrived__asAgentQuestion>
    _$gInboxItemArrivedDataInboxItemArrivedAsAgentQuestionSerializer =
    _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestionSerializer();
Serializer<GInboxItemArrivedData_inboxItemArrived__asPromotionProposal>
    _$gInboxItemArrivedDataInboxItemArrivedAsPromotionProposalSerializer =
    _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposalSerializer();

class _$GInboxItemArrivedDataSerializer
    implements StructuredSerializer<GInboxItemArrivedData> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData,
    _$GInboxItemArrivedData
  ];
  @override
  final String wireName = 'GInboxItemArrivedData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxItemArrivedData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'inboxItemArrived',
      serializers.serialize(object.inboxItemArrived,
          specifiedType:
              const FullType(GInboxItemArrivedData_inboxItemArrived)),
    ];

    return result;
  }

  @override
  GInboxItemArrivedData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxItemArrivedDataBuilder();

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
        case 'inboxItemArrived':
          result.inboxItemArrived = serializers.deserialize(value,
                  specifiedType:
                      const FullType(GInboxItemArrivedData_inboxItemArrived))!
              as GInboxItemArrivedData_inboxItemArrived;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__baseSerializer
    implements
        StructuredSerializer<GInboxItemArrivedData_inboxItemArrived__base> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData_inboxItemArrived__base,
    _$GInboxItemArrivedData_inboxItemArrived__base
  ];
  @override
  final String wireName = 'GInboxItemArrivedData_inboxItemArrived__base';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxItemArrivedData_inboxItemArrived__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxItemArrivedData_inboxItemArrived__baseBuilder();

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

class _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentSerializer
    implements
        StructuredSerializer<
            GInboxItemArrivedData_inboxItemArrived__asAgentAssignment> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
    _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment
  ];
  @override
  final String wireName =
      'GInboxItemArrivedData_inboxItemArrived__asAgentAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxItemArrivedData_inboxItemArrived__asAgentAssignment object,
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
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder();

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

class _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequestSerializer
    implements
        StructuredSerializer<
            GInboxItemArrivedData_inboxItemArrived__asApprovalRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
    _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest
  ];
  @override
  final String wireName =
      'GInboxItemArrivedData_inboxItemArrived__asApprovalRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxItemArrivedData_inboxItemArrived__asApprovalRequest object,
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
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder();

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

class _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestionSerializer
    implements
        StructuredSerializer<
            GInboxItemArrivedData_inboxItemArrived__asAgentQuestion> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
    _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion
  ];
  @override
  final String wireName =
      'GInboxItemArrivedData_inboxItemArrived__asAgentQuestion';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxItemArrivedData_inboxItemArrived__asAgentQuestion object,
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
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder();

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

class _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposalSerializer
    implements
        StructuredSerializer<
            GInboxItemArrivedData_inboxItemArrived__asPromotionProposal> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
    _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal
  ];
  @override
  final String wireName =
      'GInboxItemArrivedData_inboxItemArrived__asPromotionProposal';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxItemArrivedData_inboxItemArrived__asPromotionProposal object,
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
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder();

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

class _$GInboxItemArrivedData extends GInboxItemArrivedData {
  @override
  final String G__typename;
  @override
  final GInboxItemArrivedData_inboxItemArrived inboxItemArrived;

  factory _$GInboxItemArrivedData(
          [void Function(GInboxItemArrivedDataBuilder)? updates]) =>
      (GInboxItemArrivedDataBuilder()..update(updates))._build();

  _$GInboxItemArrivedData._(
      {required this.G__typename, required this.inboxItemArrived})
      : super._();
  @override
  GInboxItemArrivedData rebuild(
          void Function(GInboxItemArrivedDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedDataBuilder toBuilder() =>
      GInboxItemArrivedDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedData &&
        G__typename == other.G__typename &&
        inboxItemArrived == other.inboxItemArrived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, inboxItemArrived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxItemArrivedData')
          ..add('G__typename', G__typename)
          ..add('inboxItemArrived', inboxItemArrived))
        .toString();
  }
}

class GInboxItemArrivedDataBuilder
    implements Builder<GInboxItemArrivedData, GInboxItemArrivedDataBuilder> {
  _$GInboxItemArrivedData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxItemArrivedData_inboxItemArrived? _inboxItemArrived;
  GInboxItemArrivedData_inboxItemArrived? get inboxItemArrived =>
      _$this._inboxItemArrived;
  set inboxItemArrived(
          GInboxItemArrivedData_inboxItemArrived? inboxItemArrived) =>
      _$this._inboxItemArrived = inboxItemArrived;

  GInboxItemArrivedDataBuilder() {
    GInboxItemArrivedData._initializeBuilder(this);
  }

  GInboxItemArrivedDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _inboxItemArrived = $v.inboxItemArrived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxItemArrivedData other) {
    _$v = other as _$GInboxItemArrivedData;
  }

  @override
  void update(void Function(GInboxItemArrivedDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData build() => _build();

  _$GInboxItemArrivedData _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GInboxItemArrivedData', 'G__typename'),
          inboxItemArrived: BuiltValueNullFieldError.checkNotNull(
              inboxItemArrived, r'GInboxItemArrivedData', 'inboxItemArrived'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__base
    extends GInboxItemArrivedData_inboxItemArrived__base {
  @override
  final String G__typename;

  factory _$GInboxItemArrivedData_inboxItemArrived__base(
          [void Function(GInboxItemArrivedData_inboxItemArrived__baseBuilder)?
              updates]) =>
      (GInboxItemArrivedData_inboxItemArrived__baseBuilder()..update(updates))
          ._build();

  _$GInboxItemArrivedData_inboxItemArrived__base._({required this.G__typename})
      : super._();
  @override
  GInboxItemArrivedData_inboxItemArrived__base rebuild(
          void Function(GInboxItemArrivedData_inboxItemArrived__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedData_inboxItemArrived__baseBuilder toBuilder() =>
      GInboxItemArrivedData_inboxItemArrived__baseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedData_inboxItemArrived__base &&
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
            r'GInboxItemArrivedData_inboxItemArrived__base')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GInboxItemArrivedData_inboxItemArrived__baseBuilder
    implements
        Builder<GInboxItemArrivedData_inboxItemArrived__base,
            GInboxItemArrivedData_inboxItemArrived__baseBuilder> {
  _$GInboxItemArrivedData_inboxItemArrived__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxItemArrivedData_inboxItemArrived__baseBuilder() {
    GInboxItemArrivedData_inboxItemArrived__base._initializeBuilder(this);
  }

  GInboxItemArrivedData_inboxItemArrived__baseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxItemArrivedData_inboxItemArrived__base other) {
    _$v = other as _$GInboxItemArrivedData_inboxItemArrived__base;
  }

  @override
  void update(
      void Function(GInboxItemArrivedData_inboxItemArrived__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__base build() => _build();

  _$GInboxItemArrivedData_inboxItemArrived__base _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData_inboxItemArrived__base._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GInboxItemArrivedData_inboxItemArrived__base', 'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment
    extends GInboxItemArrivedData_inboxItemArrived__asAgentAssignment {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment(
          [void Function(
                  GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder)?
              updates]) =>
      (GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder()
            ..update(updates))
          ._build();

  _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignment rebuild(
          void Function(
                  GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder
      toBuilder() =>
          GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedData_inboxItemArrived__asAgentAssignment &&
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
            r'GInboxItemArrivedData_inboxItemArrived__asAgentAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder
    implements
        Builder<GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
            GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder> {
  _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder() {
    GInboxItemArrivedData_inboxItemArrived__asAgentAssignment
        ._initializeBuilder(this);
  }

  GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxItemArrivedData_inboxItemArrived__asAgentAssignment other) {
    _$v = other as _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment;
  }

  @override
  void update(
      void Function(
              GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignment build() => _build();

  _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxItemArrivedData_inboxItemArrived__asAgentAssignment',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxItemArrivedData_inboxItemArrived__asAgentAssignment',
              'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest
    extends GInboxItemArrivedData_inboxItemArrived__asApprovalRequest {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest(
          [void Function(
                  GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder)?
              updates]) =>
      (GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder()
            ..update(updates))
          ._build();

  _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequest rebuild(
          void Function(
                  GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder
      toBuilder() =>
          GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedData_inboxItemArrived__asApprovalRequest &&
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
            r'GInboxItemArrivedData_inboxItemArrived__asApprovalRequest')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder
    implements
        Builder<GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
            GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder> {
  _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder() {
    GInboxItemArrivedData_inboxItemArrived__asApprovalRequest
        ._initializeBuilder(this);
  }

  GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxItemArrivedData_inboxItemArrived__asApprovalRequest other) {
    _$v = other as _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest;
  }

  @override
  void update(
      void Function(
              GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequest build() => _build();

  _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxItemArrivedData_inboxItemArrived__asApprovalRequest',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxItemArrivedData_inboxItemArrived__asApprovalRequest',
              'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion
    extends GInboxItemArrivedData_inboxItemArrived__asAgentQuestion {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion(
          [void Function(
                  GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder)?
              updates]) =>
      (GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder()
            ..update(updates))
          ._build();

  _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestion rebuild(
          void Function(
                  GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder toBuilder() =>
      GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedData_inboxItemArrived__asAgentQuestion &&
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
            r'GInboxItemArrivedData_inboxItemArrived__asAgentQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder
    implements
        Builder<GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
            GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder> {
  _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder() {
    GInboxItemArrivedData_inboxItemArrived__asAgentQuestion._initializeBuilder(
        this);
  }

  GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxItemArrivedData_inboxItemArrived__asAgentQuestion other) {
    _$v = other as _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion;
  }

  @override
  void update(
      void Function(
              GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestion build() => _build();

  _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxItemArrivedData_inboxItemArrived__asAgentQuestion',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(id,
              r'GInboxItemArrivedData_inboxItemArrived__asAgentQuestion', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal
    extends GInboxItemArrivedData_inboxItemArrived__asPromotionProposal {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal(
          [void Function(
                  GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder)?
              updates]) =>
      (GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder()
            ..update(updates))
          ._build();

  _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposal rebuild(
          void Function(
                  GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder
      toBuilder() =>
          GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxItemArrivedData_inboxItemArrived__asPromotionProposal &&
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
            r'GInboxItemArrivedData_inboxItemArrived__asPromotionProposal')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder
    implements
        Builder<GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
            GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder> {
  _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder() {
    GInboxItemArrivedData_inboxItemArrived__asPromotionProposal
        ._initializeBuilder(this);
  }

  GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxItemArrivedData_inboxItemArrived__asPromotionProposal other) {
    _$v =
        other as _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal;
  }

  @override
  void update(
      void Function(
              GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposal build() =>
      _build();

  _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal _build() {
    final _$result = _$v ??
        _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxItemArrivedData_inboxItemArrived__asPromotionProposal',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxItemArrivedData_inboxItemArrived__asPromotionProposal',
              'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
