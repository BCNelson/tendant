// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxData> _$gInboxDataSerializer = _$GInboxDataSerializer();
Serializer<GInboxData_inbox__base> _$gInboxDataInboxBaseSerializer =
    _$GInboxData_inbox__baseSerializer();
Serializer<GInboxData_inbox__asAgentAssignment>
    _$gInboxDataInboxAsAgentAssignmentSerializer =
    _$GInboxData_inbox__asAgentAssignmentSerializer();
Serializer<GInboxData_inbox__asAgentAssignment_task>
    _$gInboxDataInboxAsAgentAssignmentTaskSerializer =
    _$GInboxData_inbox__asAgentAssignment_taskSerializer();
Serializer<GInboxData_inbox__asApprovalRequest>
    _$gInboxDataInboxAsApprovalRequestSerializer =
    _$GInboxData_inbox__asApprovalRequestSerializer();
Serializer<GInboxData_inbox__asAgentQuestion>
    _$gInboxDataInboxAsAgentQuestionSerializer =
    _$GInboxData_inbox__asAgentQuestionSerializer();
Serializer<GInboxData_inbox__asPromotionProposal>
    _$gInboxDataInboxAsPromotionProposalSerializer =
    _$GInboxData_inbox__asPromotionProposalSerializer();
Serializer<GInboxData_inbox__asFeedbackRequest>
    _$gInboxDataInboxAsFeedbackRequestSerializer =
    _$GInboxData_inbox__asFeedbackRequestSerializer();
Serializer<GInboxData_inbox__asFeedbackRequest_task>
    _$gInboxDataInboxAsFeedbackRequestTaskSerializer =
    _$GInboxData_inbox__asFeedbackRequest_taskSerializer();

class _$GInboxDataSerializer implements StructuredSerializer<GInboxData> {
  @override
  final Iterable<Type> types = const [GInboxData, _$GInboxData];
  @override
  final String wireName = 'GInboxData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GInboxData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'inbox',
      serializers.serialize(object.inbox,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GInboxData_inbox)])),
    ];

    return result;
  }

  @override
  GInboxData deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxDataBuilder();

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
        case 'inbox':
          result.inbox.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GInboxData_inbox)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__baseSerializer
    implements StructuredSerializer<GInboxData_inbox__base> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__base,
    _$GInboxData_inbox__base
  ];
  @override
  final String wireName = 'GInboxData_inbox__base';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__baseBuilder();

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

class _$GInboxData_inbox__asAgentAssignmentSerializer
    implements StructuredSerializer<GInboxData_inbox__asAgentAssignment> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asAgentAssignment,
    _$GInboxData_inbox__asAgentAssignment
  ];
  @override
  final String wireName = 'GInboxData_inbox__asAgentAssignment';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asAgentAssignment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i3.GChainStage)),
      'ask',
      serializers.serialize(object.ask, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i3.GTime)),
      'task',
      serializers.serialize(object.task,
          specifiedType:
              const FullType(GInboxData_inbox__asAgentAssignment_task)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asAgentAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asAgentAssignmentBuilder();

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
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GChainStage))!
              as _i3.GChainStage;
          break;
        case 'ask':
          result.ask = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTime))! as _i3.GTime);
          break;
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GInboxData_inbox__asAgentAssignment_task))!
              as GInboxData_inbox__asAgentAssignment_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asAgentAssignment_taskSerializer
    implements StructuredSerializer<GInboxData_inbox__asAgentAssignment_task> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asAgentAssignment_task,
    _$GInboxData_inbox__asAgentAssignment_task
  ];
  @override
  final String wireName = 'GInboxData_inbox__asAgentAssignment_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asAgentAssignment_task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i3.GTaskState)),
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i3.GChainStage)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asAgentAssignment_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asAgentAssignment_taskBuilder();

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
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTaskState))! as _i3.GTaskState;
          break;
        case 'currentStage':
          result.currentStage = serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GChainStage))!
              as _i3.GChainStage;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asApprovalRequestSerializer
    implements StructuredSerializer<GInboxData_inbox__asApprovalRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asApprovalRequest,
    _$GInboxData_inbox__asApprovalRequest
  ];
  @override
  final String wireName = 'GInboxData_inbox__asApprovalRequest';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asApprovalRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i3.GTime)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asApprovalRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asApprovalRequestBuilder();

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
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTime))! as _i3.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asAgentQuestionSerializer
    implements StructuredSerializer<GInboxData_inbox__asAgentQuestion> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asAgentQuestion,
    _$GInboxData_inbox__asAgentQuestion
  ];
  @override
  final String wireName = 'GInboxData_inbox__asAgentQuestion';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asAgentQuestion object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i3.GTime)),
      'question',
      serializers.serialize(object.question,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asAgentQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asAgentQuestionBuilder();

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
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTime))! as _i3.GTime);
          break;
        case 'question':
          result.question = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asPromotionProposalSerializer
    implements StructuredSerializer<GInboxData_inbox__asPromotionProposal> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asPromotionProposal,
    _$GInboxData_inbox__asPromotionProposal
  ];
  @override
  final String wireName = 'GInboxData_inbox__asPromotionProposal';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asPromotionProposal object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i3.GTime)),
      'fromLevel',
      serializers.serialize(object.fromLevel,
          specifiedType: const FullType(_i3.GAutonomyLevel)),
      'toLevel',
      serializers.serialize(object.toLevel,
          specifiedType: const FullType(_i3.GAutonomyLevel)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asPromotionProposal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asPromotionProposalBuilder();

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
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTime))! as _i3.GTime);
          break;
        case 'fromLevel':
          result.fromLevel = serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GAutonomyLevel))!
              as _i3.GAutonomyLevel;
          break;
        case 'toLevel':
          result.toLevel = serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GAutonomyLevel))!
              as _i3.GAutonomyLevel;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asFeedbackRequestSerializer
    implements StructuredSerializer<GInboxData_inbox__asFeedbackRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asFeedbackRequest,
    _$GInboxData_inbox__asFeedbackRequest
  ];
  @override
  final String wireName = 'GInboxData_inbox__asFeedbackRequest';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asFeedbackRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i3.GTime)),
      'task',
      serializers.serialize(object.task,
          specifiedType:
              const FullType(GInboxData_inbox__asFeedbackRequest_task)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asFeedbackRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asFeedbackRequestBuilder();

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
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i3.GTime))! as _i3.GTime);
          break;
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GInboxData_inbox__asFeedbackRequest_task))!
              as GInboxData_inbox__asFeedbackRequest_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData_inbox__asFeedbackRequest_taskSerializer
    implements StructuredSerializer<GInboxData_inbox__asFeedbackRequest_task> {
  @override
  final Iterable<Type> types = const [
    GInboxData_inbox__asFeedbackRequest_task,
    _$GInboxData_inbox__asFeedbackRequest_task
  ];
  @override
  final String wireName = 'GInboxData_inbox__asFeedbackRequest_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxData_inbox__asFeedbackRequest_task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxData_inbox__asFeedbackRequest_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxData_inbox__asFeedbackRequest_taskBuilder();

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
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxData extends GInboxData {
  @override
  final String G__typename;
  @override
  final BuiltList<GInboxData_inbox> inbox;

  factory _$GInboxData([void Function(GInboxDataBuilder)? updates]) =>
      (GInboxDataBuilder()..update(updates))._build();

  _$GInboxData._({required this.G__typename, required this.inbox}) : super._();
  @override
  GInboxData rebuild(void Function(GInboxDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxDataBuilder toBuilder() => GInboxDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData &&
        G__typename == other.G__typename &&
        inbox == other.inbox;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, inbox.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxData')
          ..add('G__typename', G__typename)
          ..add('inbox', inbox))
        .toString();
  }
}

class GInboxDataBuilder implements Builder<GInboxData, GInboxDataBuilder> {
  _$GInboxData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GInboxData_inbox>? _inbox;
  ListBuilder<GInboxData_inbox> get inbox =>
      _$this._inbox ??= ListBuilder<GInboxData_inbox>();
  set inbox(ListBuilder<GInboxData_inbox>? inbox) => _$this._inbox = inbox;

  GInboxDataBuilder() {
    GInboxData._initializeBuilder(this);
  }

  GInboxDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _inbox = $v.inbox.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData other) {
    _$v = other as _$GInboxData;
  }

  @override
  void update(void Function(GInboxDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData build() => _build();

  _$GInboxData _build() {
    _$GInboxData _$result;
    try {
      _$result = _$v ??
          _$GInboxData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GInboxData', 'G__typename'),
            inbox: inbox.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inbox';
        inbox.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__base extends GInboxData_inbox__base {
  @override
  final String G__typename;

  factory _$GInboxData_inbox__base(
          [void Function(GInboxData_inbox__baseBuilder)? updates]) =>
      (GInboxData_inbox__baseBuilder()..update(updates))._build();

  _$GInboxData_inbox__base._({required this.G__typename}) : super._();
  @override
  GInboxData_inbox__base rebuild(
          void Function(GInboxData_inbox__baseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__baseBuilder toBuilder() =>
      GInboxData_inbox__baseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__base && G__typename == other.G__typename;
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
    return (newBuiltValueToStringHelper(r'GInboxData_inbox__base')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GInboxData_inbox__baseBuilder
    implements Builder<GInboxData_inbox__base, GInboxData_inbox__baseBuilder> {
  _$GInboxData_inbox__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxData_inbox__baseBuilder() {
    GInboxData_inbox__base._initializeBuilder(this);
  }

  GInboxData_inbox__baseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__base other) {
    _$v = other as _$GInboxData_inbox__base;
  }

  @override
  void update(void Function(GInboxData_inbox__baseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__base build() => _build();

  _$GInboxData_inbox__base _build() {
    final _$result = _$v ??
        _$GInboxData_inbox__base._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GInboxData_inbox__base', 'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asAgentAssignment
    extends GInboxData_inbox__asAgentAssignment {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i3.GChainStage stage;
  @override
  final String ask;
  @override
  final _i3.GTime createdAt;
  @override
  final GInboxData_inbox__asAgentAssignment_task task;

  factory _$GInboxData_inbox__asAgentAssignment(
          [void Function(GInboxData_inbox__asAgentAssignmentBuilder)?
              updates]) =>
      (GInboxData_inbox__asAgentAssignmentBuilder()..update(updates))._build();

  _$GInboxData_inbox__asAgentAssignment._(
      {required this.G__typename,
      required this.id,
      required this.stage,
      required this.ask,
      required this.createdAt,
      required this.task})
      : super._();
  @override
  GInboxData_inbox__asAgentAssignment rebuild(
          void Function(GInboxData_inbox__asAgentAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asAgentAssignmentBuilder toBuilder() =>
      GInboxData_inbox__asAgentAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asAgentAssignment &&
        G__typename == other.G__typename &&
        id == other.id &&
        stage == other.stage &&
        ask == other.ask &&
        createdAt == other.createdAt &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, ask.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxData_inbox__asAgentAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('stage', stage)
          ..add('ask', ask)
          ..add('createdAt', createdAt)
          ..add('task', task))
        .toString();
  }
}

class GInboxData_inbox__asAgentAssignmentBuilder
    implements
        Builder<GInboxData_inbox__asAgentAssignment,
            GInboxData_inbox__asAgentAssignmentBuilder> {
  _$GInboxData_inbox__asAgentAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i3.GChainStage? _stage;
  _i3.GChainStage? get stage => _$this._stage;
  set stage(_i3.GChainStage? stage) => _$this._stage = stage;

  String? _ask;
  String? get ask => _$this._ask;
  set ask(String? ask) => _$this._ask = ask;

  _i3.GTimeBuilder? _createdAt;
  _i3.GTimeBuilder get createdAt => _$this._createdAt ??= _i3.GTimeBuilder();
  set createdAt(_i3.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GInboxData_inbox__asAgentAssignment_taskBuilder? _task;
  GInboxData_inbox__asAgentAssignment_taskBuilder get task =>
      _$this._task ??= GInboxData_inbox__asAgentAssignment_taskBuilder();
  set task(GInboxData_inbox__asAgentAssignment_taskBuilder? task) =>
      _$this._task = task;

  GInboxData_inbox__asAgentAssignmentBuilder() {
    GInboxData_inbox__asAgentAssignment._initializeBuilder(this);
  }

  GInboxData_inbox__asAgentAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _stage = $v.stage;
      _ask = $v.ask;
      _createdAt = $v.createdAt.toBuilder();
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asAgentAssignment other) {
    _$v = other as _$GInboxData_inbox__asAgentAssignment;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asAgentAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asAgentAssignment build() => _build();

  _$GInboxData_inbox__asAgentAssignment _build() {
    _$GInboxData_inbox__asAgentAssignment _$result;
    try {
      _$result = _$v ??
          _$GInboxData_inbox__asAgentAssignment._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxData_inbox__asAgentAssignment', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxData_inbox__asAgentAssignment', 'id'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GInboxData_inbox__asAgentAssignment', 'stage'),
            ask: BuiltValueNullFieldError.checkNotNull(
                ask, r'GInboxData_inbox__asAgentAssignment', 'ask'),
            createdAt: createdAt.build(),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GInboxData_inbox__asAgentAssignment',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asAgentAssignment_task
    extends GInboxData_inbox__asAgentAssignment_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;
  @override
  final _i3.GTaskState state;
  @override
  final _i3.GChainStage currentStage;

  factory _$GInboxData_inbox__asAgentAssignment_task(
          [void Function(GInboxData_inbox__asAgentAssignment_taskBuilder)?
              updates]) =>
      (GInboxData_inbox__asAgentAssignment_taskBuilder()..update(updates))
          ._build();

  _$GInboxData_inbox__asAgentAssignment_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GInboxData_inbox__asAgentAssignment_task rebuild(
          void Function(GInboxData_inbox__asAgentAssignment_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asAgentAssignment_taskBuilder toBuilder() =>
      GInboxData_inbox__asAgentAssignment_taskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asAgentAssignment_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title &&
        state == other.state &&
        currentStage == other.currentStage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxData_inbox__asAgentAssignment_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GInboxData_inbox__asAgentAssignment_taskBuilder
    implements
        Builder<GInboxData_inbox__asAgentAssignment_task,
            GInboxData_inbox__asAgentAssignment_taskBuilder> {
  _$GInboxData_inbox__asAgentAssignment_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  _i3.GTaskState? _state;
  _i3.GTaskState? get state => _$this._state;
  set state(_i3.GTaskState? state) => _$this._state = state;

  _i3.GChainStage? _currentStage;
  _i3.GChainStage? get currentStage => _$this._currentStage;
  set currentStage(_i3.GChainStage? currentStage) =>
      _$this._currentStage = currentStage;

  GInboxData_inbox__asAgentAssignment_taskBuilder() {
    GInboxData_inbox__asAgentAssignment_task._initializeBuilder(this);
  }

  GInboxData_inbox__asAgentAssignment_taskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asAgentAssignment_task other) {
    _$v = other as _$GInboxData_inbox__asAgentAssignment_task;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asAgentAssignment_taskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asAgentAssignment_task build() => _build();

  _$GInboxData_inbox__asAgentAssignment_task _build() {
    final _$result = _$v ??
        _$GInboxData_inbox__asAgentAssignment_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GInboxData_inbox__asAgentAssignment_task', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GInboxData_inbox__asAgentAssignment_task', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GInboxData_inbox__asAgentAssignment_task', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GInboxData_inbox__asAgentAssignment_task', 'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(currentStage,
              r'GInboxData_inbox__asAgentAssignment_task', 'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asApprovalRequest
    extends GInboxData_inbox__asApprovalRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i3.GTime createdAt;

  factory _$GInboxData_inbox__asApprovalRequest(
          [void Function(GInboxData_inbox__asApprovalRequestBuilder)?
              updates]) =>
      (GInboxData_inbox__asApprovalRequestBuilder()..update(updates))._build();

  _$GInboxData_inbox__asApprovalRequest._(
      {required this.G__typename, required this.id, required this.createdAt})
      : super._();
  @override
  GInboxData_inbox__asApprovalRequest rebuild(
          void Function(GInboxData_inbox__asApprovalRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asApprovalRequestBuilder toBuilder() =>
      GInboxData_inbox__asApprovalRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asApprovalRequest &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxData_inbox__asApprovalRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GInboxData_inbox__asApprovalRequestBuilder
    implements
        Builder<GInboxData_inbox__asApprovalRequest,
            GInboxData_inbox__asApprovalRequestBuilder> {
  _$GInboxData_inbox__asApprovalRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i3.GTimeBuilder? _createdAt;
  _i3.GTimeBuilder get createdAt => _$this._createdAt ??= _i3.GTimeBuilder();
  set createdAt(_i3.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GInboxData_inbox__asApprovalRequestBuilder() {
    GInboxData_inbox__asApprovalRequest._initializeBuilder(this);
  }

  GInboxData_inbox__asApprovalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asApprovalRequest other) {
    _$v = other as _$GInboxData_inbox__asApprovalRequest;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asApprovalRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asApprovalRequest build() => _build();

  _$GInboxData_inbox__asApprovalRequest _build() {
    _$GInboxData_inbox__asApprovalRequest _$result;
    try {
      _$result = _$v ??
          _$GInboxData_inbox__asApprovalRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxData_inbox__asApprovalRequest', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxData_inbox__asApprovalRequest', 'id'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GInboxData_inbox__asApprovalRequest',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asAgentQuestion
    extends GInboxData_inbox__asAgentQuestion {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i3.GTime createdAt;
  @override
  final String question;

  factory _$GInboxData_inbox__asAgentQuestion(
          [void Function(GInboxData_inbox__asAgentQuestionBuilder)? updates]) =>
      (GInboxData_inbox__asAgentQuestionBuilder()..update(updates))._build();

  _$GInboxData_inbox__asAgentQuestion._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.question})
      : super._();
  @override
  GInboxData_inbox__asAgentQuestion rebuild(
          void Function(GInboxData_inbox__asAgentQuestionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asAgentQuestionBuilder toBuilder() =>
      GInboxData_inbox__asAgentQuestionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asAgentQuestion &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        question == other.question;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, question.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxData_inbox__asAgentQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('question', question))
        .toString();
  }
}

class GInboxData_inbox__asAgentQuestionBuilder
    implements
        Builder<GInboxData_inbox__asAgentQuestion,
            GInboxData_inbox__asAgentQuestionBuilder> {
  _$GInboxData_inbox__asAgentQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i3.GTimeBuilder? _createdAt;
  _i3.GTimeBuilder get createdAt => _$this._createdAt ??= _i3.GTimeBuilder();
  set createdAt(_i3.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  String? _question;
  String? get question => _$this._question;
  set question(String? question) => _$this._question = question;

  GInboxData_inbox__asAgentQuestionBuilder() {
    GInboxData_inbox__asAgentQuestion._initializeBuilder(this);
  }

  GInboxData_inbox__asAgentQuestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _question = $v.question;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asAgentQuestion other) {
    _$v = other as _$GInboxData_inbox__asAgentQuestion;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asAgentQuestionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asAgentQuestion build() => _build();

  _$GInboxData_inbox__asAgentQuestion _build() {
    _$GInboxData_inbox__asAgentQuestion _$result;
    try {
      _$result = _$v ??
          _$GInboxData_inbox__asAgentQuestion._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxData_inbox__asAgentQuestion', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxData_inbox__asAgentQuestion', 'id'),
            createdAt: createdAt.build(),
            question: BuiltValueNullFieldError.checkNotNull(
                question, r'GInboxData_inbox__asAgentQuestion', 'question'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxData_inbox__asAgentQuestion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asPromotionProposal
    extends GInboxData_inbox__asPromotionProposal {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i3.GTime createdAt;
  @override
  final _i3.GAutonomyLevel fromLevel;
  @override
  final _i3.GAutonomyLevel toLevel;

  factory _$GInboxData_inbox__asPromotionProposal(
          [void Function(GInboxData_inbox__asPromotionProposalBuilder)?
              updates]) =>
      (GInboxData_inbox__asPromotionProposalBuilder()..update(updates))
          ._build();

  _$GInboxData_inbox__asPromotionProposal._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.fromLevel,
      required this.toLevel})
      : super._();
  @override
  GInboxData_inbox__asPromotionProposal rebuild(
          void Function(GInboxData_inbox__asPromotionProposalBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asPromotionProposalBuilder toBuilder() =>
      GInboxData_inbox__asPromotionProposalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asPromotionProposal &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        fromLevel == other.fromLevel &&
        toLevel == other.toLevel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, fromLevel.hashCode);
    _$hash = $jc(_$hash, toLevel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxData_inbox__asPromotionProposal')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('fromLevel', fromLevel)
          ..add('toLevel', toLevel))
        .toString();
  }
}

class GInboxData_inbox__asPromotionProposalBuilder
    implements
        Builder<GInboxData_inbox__asPromotionProposal,
            GInboxData_inbox__asPromotionProposalBuilder> {
  _$GInboxData_inbox__asPromotionProposal? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i3.GTimeBuilder? _createdAt;
  _i3.GTimeBuilder get createdAt => _$this._createdAt ??= _i3.GTimeBuilder();
  set createdAt(_i3.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i3.GAutonomyLevel? _fromLevel;
  _i3.GAutonomyLevel? get fromLevel => _$this._fromLevel;
  set fromLevel(_i3.GAutonomyLevel? fromLevel) => _$this._fromLevel = fromLevel;

  _i3.GAutonomyLevel? _toLevel;
  _i3.GAutonomyLevel? get toLevel => _$this._toLevel;
  set toLevel(_i3.GAutonomyLevel? toLevel) => _$this._toLevel = toLevel;

  GInboxData_inbox__asPromotionProposalBuilder() {
    GInboxData_inbox__asPromotionProposal._initializeBuilder(this);
  }

  GInboxData_inbox__asPromotionProposalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _fromLevel = $v.fromLevel;
      _toLevel = $v.toLevel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asPromotionProposal other) {
    _$v = other as _$GInboxData_inbox__asPromotionProposal;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asPromotionProposalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asPromotionProposal build() => _build();

  _$GInboxData_inbox__asPromotionProposal _build() {
    _$GInboxData_inbox__asPromotionProposal _$result;
    try {
      _$result = _$v ??
          _$GInboxData_inbox__asPromotionProposal._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxData_inbox__asPromotionProposal', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxData_inbox__asPromotionProposal', 'id'),
            createdAt: createdAt.build(),
            fromLevel: BuiltValueNullFieldError.checkNotNull(fromLevel,
                r'GInboxData_inbox__asPromotionProposal', 'fromLevel'),
            toLevel: BuiltValueNullFieldError.checkNotNull(
                toLevel, r'GInboxData_inbox__asPromotionProposal', 'toLevel'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxData_inbox__asPromotionProposal',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asFeedbackRequest
    extends GInboxData_inbox__asFeedbackRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i3.GTime createdAt;
  @override
  final GInboxData_inbox__asFeedbackRequest_task task;

  factory _$GInboxData_inbox__asFeedbackRequest(
          [void Function(GInboxData_inbox__asFeedbackRequestBuilder)?
              updates]) =>
      (GInboxData_inbox__asFeedbackRequestBuilder()..update(updates))._build();

  _$GInboxData_inbox__asFeedbackRequest._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.task})
      : super._();
  @override
  GInboxData_inbox__asFeedbackRequest rebuild(
          void Function(GInboxData_inbox__asFeedbackRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asFeedbackRequestBuilder toBuilder() =>
      GInboxData_inbox__asFeedbackRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asFeedbackRequest &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxData_inbox__asFeedbackRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('task', task))
        .toString();
  }
}

class GInboxData_inbox__asFeedbackRequestBuilder
    implements
        Builder<GInboxData_inbox__asFeedbackRequest,
            GInboxData_inbox__asFeedbackRequestBuilder> {
  _$GInboxData_inbox__asFeedbackRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i3.GTimeBuilder? _createdAt;
  _i3.GTimeBuilder get createdAt => _$this._createdAt ??= _i3.GTimeBuilder();
  set createdAt(_i3.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GInboxData_inbox__asFeedbackRequest_taskBuilder? _task;
  GInboxData_inbox__asFeedbackRequest_taskBuilder get task =>
      _$this._task ??= GInboxData_inbox__asFeedbackRequest_taskBuilder();
  set task(GInboxData_inbox__asFeedbackRequest_taskBuilder? task) =>
      _$this._task = task;

  GInboxData_inbox__asFeedbackRequestBuilder() {
    GInboxData_inbox__asFeedbackRequest._initializeBuilder(this);
  }

  GInboxData_inbox__asFeedbackRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asFeedbackRequest other) {
    _$v = other as _$GInboxData_inbox__asFeedbackRequest;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asFeedbackRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asFeedbackRequest build() => _build();

  _$GInboxData_inbox__asFeedbackRequest _build() {
    _$GInboxData_inbox__asFeedbackRequest _$result;
    try {
      _$result = _$v ??
          _$GInboxData_inbox__asFeedbackRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxData_inbox__asFeedbackRequest', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxData_inbox__asFeedbackRequest', 'id'),
            createdAt: createdAt.build(),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GInboxData_inbox__asFeedbackRequest',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxData_inbox__asFeedbackRequest_task
    extends GInboxData_inbox__asFeedbackRequest_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;

  factory _$GInboxData_inbox__asFeedbackRequest_task(
          [void Function(GInboxData_inbox__asFeedbackRequest_taskBuilder)?
              updates]) =>
      (GInboxData_inbox__asFeedbackRequest_taskBuilder()..update(updates))
          ._build();

  _$GInboxData_inbox__asFeedbackRequest_task._(
      {required this.G__typename, required this.id, required this.title})
      : super._();
  @override
  GInboxData_inbox__asFeedbackRequest_task rebuild(
          void Function(GInboxData_inbox__asFeedbackRequest_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxData_inbox__asFeedbackRequest_taskBuilder toBuilder() =>
      GInboxData_inbox__asFeedbackRequest_taskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxData_inbox__asFeedbackRequest_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxData_inbox__asFeedbackRequest_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class GInboxData_inbox__asFeedbackRequest_taskBuilder
    implements
        Builder<GInboxData_inbox__asFeedbackRequest_task,
            GInboxData_inbox__asFeedbackRequest_taskBuilder> {
  _$GInboxData_inbox__asFeedbackRequest_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GInboxData_inbox__asFeedbackRequest_taskBuilder() {
    GInboxData_inbox__asFeedbackRequest_task._initializeBuilder(this);
  }

  GInboxData_inbox__asFeedbackRequest_taskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxData_inbox__asFeedbackRequest_task other) {
    _$v = other as _$GInboxData_inbox__asFeedbackRequest_task;
  }

  @override
  void update(
      void Function(GInboxData_inbox__asFeedbackRequest_taskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxData_inbox__asFeedbackRequest_task build() => _build();

  _$GInboxData_inbox__asFeedbackRequest_task _build() {
    final _$result = _$v ??
        _$GInboxData_inbox__asFeedbackRequest_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GInboxData_inbox__asFeedbackRequest_task', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GInboxData_inbox__asFeedbackRequest_task', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GInboxData_inbox__asFeedbackRequest_task', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
