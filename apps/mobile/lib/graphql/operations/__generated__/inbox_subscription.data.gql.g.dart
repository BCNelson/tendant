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
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__base>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemBaseSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__baseSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsActionableTaskSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsActionableTaskTaskSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentAssignmentSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentSerializer();
Serializer<
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentAssignmentTaskSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsApprovalRequestSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentQuestionSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsPromotionProposalSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalSerializer();
Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsFeedbackRequestSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestSerializer();
Serializer<
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task>
    _$gInboxEntryArrivedDataInboxEntryArrivedItemAsFeedbackRequestTaskSerializer =
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskSerializer();

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
      'messageType',
      serializers.serialize(object.messageType,
          specifiedType: const FullType(String)),
      'urgency',
      serializers.serialize(object.urgency,
          specifiedType: const FullType(double)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'item',
      serializers.serialize(object.item,
          specifiedType:
              const FullType(GInboxEntryArrivedData_inboxEntryArrived_item)),
    ];
    Object? value;
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
        case 'messageType':
          result.messageType = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'urgency':
          result.urgency = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
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
        case 'item':
          result.item = serializers.deserialize(value,
                  specifiedType: const FullType(
                      GInboxEntryArrivedData_inboxEntryArrived_item))!
              as GInboxEntryArrivedData_inboxEntryArrived_item;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__baseSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__base> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__base,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__base
  ];
  @override
  final String wireName = 'GInboxEntryArrivedData_inboxEntryArrived_item__base';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder();

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

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'task',
      serializers.serialize(object.task,
          specifiedType: const FullType(
              GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder();

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
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task))!
              as GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
          object,
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
          specifiedType: const FullType(_i2.GTaskState)),
      'priority',
      serializers.serialize(object.priority,
          specifiedType: const FullType(_i2.GTaskPriority)),
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i2.GChainStage)),
    ];
    Object? value;
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder();

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
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
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
        case 'currentStage':
          result.currentStage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GChainStage))!
              as _i2.GChainStage;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i2.GChainStage)),
      'ask',
      serializers.serialize(object.ask, specifiedType: const FullType(String)),
      'task',
      serializers.serialize(object.task,
          specifiedType: const FullType(
              GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder();

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
                  specifiedType: const FullType(_i2.GChainStage))!
              as _i2.GChainStage;
          break;
        case 'ask':
          result.ask = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task))!
              as GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
          object,
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
          specifiedType: const FullType(_i2.GTaskState)),
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i2.GChainStage)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder();

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
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
          break;
        case 'currentStage':
          result.currentStage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GChainStage))!
              as _i2.GChainStage;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest object,
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
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder();

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

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'question',
      serializers.serialize(object.question,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder();

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
        case 'question':
          result.question = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'fromLevel',
      serializers.serialize(object.fromLevel,
          specifiedType: const FullType(_i2.GAutonomyLevel)),
      'toLevel',
      serializers.serialize(object.toLevel,
          specifiedType: const FullType(_i2.GAutonomyLevel)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder();

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
        case 'fromLevel':
          result.fromLevel = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAutonomyLevel))!
              as _i2.GAutonomyLevel;
          break;
        case 'toLevel':
          result.toLevel = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAutonomyLevel))!
              as _i2.GAutonomyLevel;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'task',
      serializers.serialize(object.task,
          specifiedType: const FullType(
              GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task)),
    ];

    return result;
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder();

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
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task))!
              as GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskSerializer
    implements
        StructuredSerializer<
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task,
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
  ];
  @override
  final String wireName =
      'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
          object,
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
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder();

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
  final String messageType;
  @override
  final double urgency;
  @override
  final _i2.GTime createdAt;
  @override
  final _i2.GTime? readAt;
  @override
  final _i2.GTime? dismissedAt;
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
      required this.messageType,
      required this.urgency,
      required this.createdAt,
      this.readAt,
      this.dismissedAt,
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
        messageType == other.messageType &&
        urgency == other.urgency &&
        createdAt == other.createdAt &&
        readAt == other.readAt &&
        dismissedAt == other.dismissedAt &&
        item == other.item;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jc(_$hash, urgency.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, dismissedAt.hashCode);
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
          ..add('messageType', messageType)
          ..add('urgency', urgency)
          ..add('createdAt', createdAt)
          ..add('readAt', readAt)
          ..add('dismissedAt', dismissedAt)
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

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  double? _urgency;
  double? get urgency => _$this._urgency;
  set urgency(double? urgency) => _$this._urgency = urgency;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i2.GTimeBuilder? _readAt;
  _i2.GTimeBuilder get readAt => _$this._readAt ??= _i2.GTimeBuilder();
  set readAt(_i2.GTimeBuilder? readAt) => _$this._readAt = readAt;

  _i2.GTimeBuilder? _dismissedAt;
  _i2.GTimeBuilder get dismissedAt =>
      _$this._dismissedAt ??= _i2.GTimeBuilder();
  set dismissedAt(_i2.GTimeBuilder? dismissedAt) =>
      _$this._dismissedAt = dismissedAt;

  GInboxEntryArrivedData_inboxEntryArrived_item? _item;
  GInboxEntryArrivedData_inboxEntryArrived_item? get item => _$this._item;
  set item(GInboxEntryArrivedData_inboxEntryArrived_item? item) =>
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
      _messageType = $v.messageType;
      _urgency = $v.urgency;
      _createdAt = $v.createdAt.toBuilder();
      _readAt = $v.readAt?.toBuilder();
      _dismissedAt = $v.dismissedAt?.toBuilder();
      _item = $v.item;
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
            messageType: BuiltValueNullFieldError.checkNotNull(messageType,
                r'GInboxEntryArrivedData_inboxEntryArrived', 'messageType'),
            urgency: BuiltValueNullFieldError.checkNotNull(urgency,
                r'GInboxEntryArrivedData_inboxEntryArrived', 'urgency'),
            createdAt: createdAt.build(),
            readAt: _readAt?.build(),
            dismissedAt: _dismissedAt?.build(),
            item: BuiltValueNullFieldError.checkNotNull(
                item, r'GInboxEntryArrivedData_inboxEntryArrived', 'item'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'readAt';
        _readAt?.build();
        _$failedField = 'dismissedAt';
        _dismissedAt?.build();
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

class _$GInboxEntryArrivedData_inboxEntryArrived_item__base
    extends GInboxEntryArrivedData_inboxEntryArrived_item__base {
  @override
  final String G__typename;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__base(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__base._(
      {required this.G__typename})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__base rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder toBuilder() =>
      GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxEntryArrivedData_inboxEntryArrived_item__base &&
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
            r'GInboxEntryArrivedData_inboxEntryArrived_item__base')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder
    implements
        Builder<GInboxEntryArrivedData_inboxEntryArrived_item__base,
            GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__base._initializeBuilder(
        this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxEntryArrivedData_inboxEntryArrived_item__base other) {
    _$v = other as _$GInboxEntryArrivedData_inboxEntryArrived_item__base;
  }

  @override
  void update(
      void Function(GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__base build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__base _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__base._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__base',
              'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
      task;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask._(
      {required this.G__typename, required this.id, required this.task})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask &&
        G__typename == other.G__typename &&
        id == other.id &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('task', task))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder
    implements
        Builder<GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder?
      _task;
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
      get task => _$this._task ??=
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder();
  set task(
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask _build() {
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask',
                'id'),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GTaskPriority priority;
  @override
  final _i2.GTime? dueAt;
  @override
  final _i2.GChainStage currentStage;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      required this.state,
      required this.priority,
      this.dueAt,
      required this.currentStage})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title &&
        state == other.state &&
        priority == other.priority &&
        dueAt == other.dueAt &&
        currentStage == other.currentStage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('state', state)
          ..add('priority', priority)
          ..add('dueAt', dueAt)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  _i2.GTaskPriority? _priority;
  _i2.GTaskPriority? get priority => _$this._priority;
  set priority(_i2.GTaskPriority? priority) => _$this._priority = priority;

  _i2.GTimeBuilder? _dueAt;
  _i2.GTimeBuilder get dueAt => _$this._dueAt ??= _i2.GTimeBuilder();
  set dueAt(_i2.GTimeBuilder? dueAt) => _$this._dueAt = dueAt;

  _i2.GChainStage? _currentStage;
  _i2.GChainStage? get currentStage => _$this._currentStage;
  set currentStage(_i2.GChainStage? currentStage) =>
      _$this._currentStage = currentStage;

  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _state = $v.state;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _currentStage = $v.currentStage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
          other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
      build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
      _build() {
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
        _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
              ._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'title'),
            state: BuiltValueNullFieldError.checkNotNull(
                state,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'state'),
            priority: BuiltValueNullFieldError.checkNotNull(
                priority,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'priority'),
            dueAt: _dueAt?.build(),
            currentStage: BuiltValueNullFieldError.checkNotNull(
                currentStage,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
                'currentStage'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GChainStage stage;
  @override
  final String ask;
  @override
  final GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
      task;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment._(
      {required this.G__typename,
      required this.id,
      required this.stage,
      required this.ask,
      required this.task})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment &&
        G__typename == other.G__typename &&
        id == other.id &&
        stage == other.stage &&
        ask == other.ask &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, ask.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('stage', stage)
          ..add('ask', ask)
          ..add('task', task))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GChainStage? _stage;
  _i2.GChainStage? get stage => _$this._stage;
  set stage(_i2.GChainStage? stage) => _$this._stage = stage;

  String? _ask;
  String? get ask => _$this._ask;
  set ask(String? ask) => _$this._ask = ask;

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder?
      _task;
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
      get task => _$this._task ??=
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder();
  set task(
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _stage = $v.stage;
      _ask = $v.ask;
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment _build() {
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment',
                'id'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment',
                'stage'),
            ask: BuiltValueNullFieldError.checkNotNull(
                ask,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment',
                'ask'),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GChainStage currentStage;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task &&
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
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  _i2.GChainStage? _currentStage;
  _i2.GChainStage? get currentStage => _$this._currentStage;
  set currentStage(_i2.GChainStage? currentStage) =>
      _$this._currentStage = currentStage;

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
      get _$this {
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
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
          other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
      build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
      _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task',
              'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task',
              'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task',
              'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(
              currentStage,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task',
              'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest &&
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
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
            GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder
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
      GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest',
              'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String question;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion._(
      {required this.G__typename, required this.id, required this.question})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion &&
        G__typename == other.G__typename &&
        id == other.id &&
        question == other.question;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, question.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('question', question))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder
    implements
        Builder<GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _question;
  String? get question => _$this._question;
  set question(String? question) => _$this._question = question;

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _question = $v.question;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion',
              'id'),
          question: BuiltValueNullFieldError.checkNotNull(
              question,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion',
              'question'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GAutonomyLevel fromLevel;
  @override
  final _i2.GAutonomyLevel toLevel;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal._(
      {required this.G__typename,
      required this.id,
      required this.fromLevel,
      required this.toLevel})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal &&
        G__typename == other.G__typename &&
        id == other.id &&
        fromLevel == other.fromLevel &&
        toLevel == other.toLevel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fromLevel.hashCode);
    _$hash = $jc(_$hash, toLevel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('fromLevel', fromLevel)
          ..add('toLevel', toLevel))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GAutonomyLevel? _fromLevel;
  _i2.GAutonomyLevel? get fromLevel => _$this._fromLevel;
  set fromLevel(_i2.GAutonomyLevel? fromLevel) => _$this._fromLevel = fromLevel;

  _i2.GAutonomyLevel? _toLevel;
  _i2.GAutonomyLevel? get toLevel => _$this._toLevel;
  set toLevel(_i2.GAutonomyLevel? toLevel) => _$this._toLevel = toLevel;

  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _fromLevel = $v.fromLevel;
      _toLevel = $v.toLevel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
          other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
      _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal',
              'id'),
          fromLevel: BuiltValueNullFieldError.checkNotNull(
              fromLevel,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal',
              'fromLevel'),
          toLevel: BuiltValueNullFieldError.checkNotNull(
              toLevel,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal',
              'toLevel'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
      task;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest._(
      {required this.G__typename, required this.id, required this.task})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest &&
        G__typename == other.G__typename &&
        id == other.id &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('task', task))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder?
      _task;
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
      get task => _$this._task ??=
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder();
  set task(
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest build() =>
      _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest _build() {
    _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest _$result;
    try {
      _$result = _$v ??
          _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest',
                'id'),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
    extends GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;

  factory _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder)?
              updates]) =>
      (GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task._(
      {required this.G__typename, required this.id, required this.title})
      : super._();
  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task rebuild(
          void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
      toBuilder() =>
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task &&
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
            r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
    implements
        Builder<
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder> {
  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder() {
    GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
        ._initializeBuilder(this);
  }

  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
      get _$this {
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
  void replace(
      GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
          other) {
    _$v = other
        as _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task;
  }

  @override
  void update(
      void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
      build() => _build();

  _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
      _build() {
    final _$result = _$v ??
        _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task',
              'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task',
              'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
