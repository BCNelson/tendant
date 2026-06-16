// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxFeedData> _$gInboxFeedDataSerializer =
    _$GInboxFeedDataSerializer();
Serializer<GInboxFeedData_inboxFeed> _$gInboxFeedDataInboxFeedSerializer =
    _$GInboxFeedData_inboxFeedSerializer();
Serializer<GInboxFeedData_inboxFeed_entries>
    _$gInboxFeedDataInboxFeedEntriesSerializer =
    _$GInboxFeedData_inboxFeed_entriesSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__base>
    _$gInboxFeedDataInboxFeedEntriesItemBaseSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__baseSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asActionableTask>
    _$gInboxFeedDataInboxFeedEntriesItemAsActionableTaskSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTaskSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asActionableTask_task>
    _$gInboxFeedDataInboxFeedEntriesItemAsActionableTaskTaskSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment>
    _$gInboxFeedDataInboxFeedEntriesItemAsAgentAssignmentSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task>
    _$gInboxFeedDataInboxFeedEntriesItemAsAgentAssignmentTaskSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asApprovalRequest>
    _$gInboxFeedDataInboxFeedEntriesItemAsApprovalRequestSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequestSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asAgentQuestion>
    _$gInboxFeedDataInboxFeedEntriesItemAsAgentQuestionSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestionSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asPromotionProposal>
    _$gInboxFeedDataInboxFeedEntriesItemAsPromotionProposalSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposalSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest>
    _$gInboxFeedDataInboxFeedEntriesItemAsFeedbackRequestSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestSerializer();
Serializer<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task>
    _$gInboxFeedDataInboxFeedEntriesItemAsFeedbackRequestTaskSerializer =
    _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskSerializer();

class _$GInboxFeedDataSerializer
    implements StructuredSerializer<GInboxFeedData> {
  @override
  final Iterable<Type> types = const [GInboxFeedData, _$GInboxFeedData];
  @override
  final String wireName = 'GInboxFeedData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GInboxFeedData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'inboxFeed',
      serializers.serialize(object.inboxFeed,
          specifiedType: const FullType(GInboxFeedData_inboxFeed)),
    ];

    return result;
  }

  @override
  GInboxFeedData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxFeedDataBuilder();

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
        case 'inboxFeed':
          result.inboxFeed.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GInboxFeedData_inboxFeed))!
              as GInboxFeedData_inboxFeed);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeedSerializer
    implements StructuredSerializer<GInboxFeedData_inboxFeed> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed,
    _$GInboxFeedData_inboxFeed
  ];
  @override
  final String wireName = 'GInboxFeedData_inboxFeed';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxFeedData_inboxFeed object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'entries',
      serializers.serialize(object.entries,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GInboxFeedData_inboxFeed_entries)])),
    ];
    Object? value;
    value = object.nextCursor;
    if (value != null) {
      result
        ..add('nextCursor')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GInboxFeedData_inboxFeed deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxFeedData_inboxFeedBuilder();

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
        case 'nextCursor':
          result.nextCursor = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'entries':
          result.entries.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GInboxFeedData_inboxFeed_entries)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeed_entriesSerializer
    implements StructuredSerializer<GInboxFeedData_inboxFeed_entries> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries,
    _$GInboxFeedData_inboxFeed_entries
  ];
  @override
  final String wireName = 'GInboxFeedData_inboxFeed_entries';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxFeedData_inboxFeed_entries object,
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
          specifiedType: const FullType(GInboxFeedData_inboxFeed_entries_item)),
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
  GInboxFeedData_inboxFeed_entries deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxFeedData_inboxFeed_entriesBuilder();

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
                  specifiedType:
                      const FullType(GInboxFeedData_inboxFeed_entries_item))!
              as GInboxFeedData_inboxFeed_entries_item;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__baseSerializer
    implements
        StructuredSerializer<GInboxFeedData_inboxFeed_entries_item__base> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__base,
    _$GInboxFeedData_inboxFeed_entries_item__base
  ];
  @override
  final String wireName = 'GInboxFeedData_inboxFeed_entries_item__base';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxFeedData_inboxFeed_entries_item__baseBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asActionableTaskSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asActionableTask> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asActionableTask,
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTask
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asActionableTask';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asActionableTask object,
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
              GInboxFeedData_inboxFeed_entries_item__asActionableTask_task)),
    ];

    return result;
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder();

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
                      GInboxFeedData_inboxFeed_entries_item__asActionableTask_task))!
              as GInboxFeedData_inboxFeed_entries_item__asActionableTask_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asActionableTask_task> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asActionableTask_task,
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asActionableTask_task object,
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
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignment> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
    _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asAgentAssignment object,
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
              GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task)),
    ];

    return result;
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder();

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
                      GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task))!
              as GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task,
    _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task object,
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
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequestSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asApprovalRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
    _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asApprovalRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asApprovalRequest object,
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
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestionSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asAgentQuestion> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
    _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asAgentQuestion';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asAgentQuestion object,
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
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposalSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asPromotionProposal> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
    _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asPromotionProposal object,
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
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder();

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

class _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
    _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest object,
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
              GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task)),
    ];

    return result;
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder();

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
                      GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task))!
              as GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskSerializer
    implements
        StructuredSerializer<
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task> {
  @override
  final Iterable<Type> types = const [
    GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task,
    _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
  ];
  @override
  final String wireName =
      'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task object,
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
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder();

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

class _$GInboxFeedData extends GInboxFeedData {
  @override
  final String G__typename;
  @override
  final GInboxFeedData_inboxFeed inboxFeed;

  factory _$GInboxFeedData([void Function(GInboxFeedDataBuilder)? updates]) =>
      (GInboxFeedDataBuilder()..update(updates))._build();

  _$GInboxFeedData._({required this.G__typename, required this.inboxFeed})
      : super._();
  @override
  GInboxFeedData rebuild(void Function(GInboxFeedDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedDataBuilder toBuilder() => GInboxFeedDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData &&
        G__typename == other.G__typename &&
        inboxFeed == other.inboxFeed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, inboxFeed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxFeedData')
          ..add('G__typename', G__typename)
          ..add('inboxFeed', inboxFeed))
        .toString();
  }
}

class GInboxFeedDataBuilder
    implements Builder<GInboxFeedData, GInboxFeedDataBuilder> {
  _$GInboxFeedData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxFeedData_inboxFeedBuilder? _inboxFeed;
  GInboxFeedData_inboxFeedBuilder get inboxFeed =>
      _$this._inboxFeed ??= GInboxFeedData_inboxFeedBuilder();
  set inboxFeed(GInboxFeedData_inboxFeedBuilder? inboxFeed) =>
      _$this._inboxFeed = inboxFeed;

  GInboxFeedDataBuilder() {
    GInboxFeedData._initializeBuilder(this);
  }

  GInboxFeedDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _inboxFeed = $v.inboxFeed.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxFeedData other) {
    _$v = other as _$GInboxFeedData;
  }

  @override
  void update(void Function(GInboxFeedDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData build() => _build();

  _$GInboxFeedData _build() {
    _$GInboxFeedData _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GInboxFeedData', 'G__typename'),
            inboxFeed: inboxFeed.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inboxFeed';
        inboxFeed.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxFeedData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed extends GInboxFeedData_inboxFeed {
  @override
  final String G__typename;
  @override
  final String? nextCursor;
  @override
  final BuiltList<GInboxFeedData_inboxFeed_entries> entries;

  factory _$GInboxFeedData_inboxFeed(
          [void Function(GInboxFeedData_inboxFeedBuilder)? updates]) =>
      (GInboxFeedData_inboxFeedBuilder()..update(updates))._build();

  _$GInboxFeedData_inboxFeed._(
      {required this.G__typename, this.nextCursor, required this.entries})
      : super._();
  @override
  GInboxFeedData_inboxFeed rebuild(
          void Function(GInboxFeedData_inboxFeedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeedBuilder toBuilder() =>
      GInboxFeedData_inboxFeedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed &&
        G__typename == other.G__typename &&
        nextCursor == other.nextCursor &&
        entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxFeedData_inboxFeed')
          ..add('G__typename', G__typename)
          ..add('nextCursor', nextCursor)
          ..add('entries', entries))
        .toString();
  }
}

class GInboxFeedData_inboxFeedBuilder
    implements
        Builder<GInboxFeedData_inboxFeed, GInboxFeedData_inboxFeedBuilder> {
  _$GInboxFeedData_inboxFeed? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ListBuilder<GInboxFeedData_inboxFeed_entries>? _entries;
  ListBuilder<GInboxFeedData_inboxFeed_entries> get entries =>
      _$this._entries ??= ListBuilder<GInboxFeedData_inboxFeed_entries>();
  set entries(ListBuilder<GInboxFeedData_inboxFeed_entries>? entries) =>
      _$this._entries = entries;

  GInboxFeedData_inboxFeedBuilder() {
    GInboxFeedData_inboxFeed._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _nextCursor = $v.nextCursor;
      _entries = $v.entries.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxFeedData_inboxFeed other) {
    _$v = other as _$GInboxFeedData_inboxFeed;
  }

  @override
  void update(void Function(GInboxFeedData_inboxFeedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed build() => _build();

  _$GInboxFeedData_inboxFeed _build() {
    _$GInboxFeedData_inboxFeed _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GInboxFeedData_inboxFeed', 'G__typename'),
            nextCursor: nextCursor,
            entries: entries.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        entries.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxFeedData_inboxFeed', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries
    extends GInboxFeedData_inboxFeed_entries {
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
  final GInboxFeedData_inboxFeed_entries_item item;

  factory _$GInboxFeedData_inboxFeed_entries(
          [void Function(GInboxFeedData_inboxFeed_entriesBuilder)? updates]) =>
      (GInboxFeedData_inboxFeed_entriesBuilder()..update(updates))._build();

  _$GInboxFeedData_inboxFeed_entries._(
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
  GInboxFeedData_inboxFeed_entries rebuild(
          void Function(GInboxFeedData_inboxFeed_entriesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entriesBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entriesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries &&
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
    return (newBuiltValueToStringHelper(r'GInboxFeedData_inboxFeed_entries')
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

class GInboxFeedData_inboxFeed_entriesBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries,
            GInboxFeedData_inboxFeed_entriesBuilder> {
  _$GInboxFeedData_inboxFeed_entries? _$v;

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

  GInboxFeedData_inboxFeed_entries_item? _item;
  GInboxFeedData_inboxFeed_entries_item? get item => _$this._item;
  set item(GInboxFeedData_inboxFeed_entries_item? item) => _$this._item = item;

  GInboxFeedData_inboxFeed_entriesBuilder() {
    GInboxFeedData_inboxFeed_entries._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entriesBuilder get _$this {
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
  void replace(GInboxFeedData_inboxFeed_entries other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries;
  }

  @override
  void update(void Function(GInboxFeedData_inboxFeed_entriesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries build() => _build();

  _$GInboxFeedData_inboxFeed_entries _build() {
    _$GInboxFeedData_inboxFeed_entries _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed_entries._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GInboxFeedData_inboxFeed_entries', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GInboxFeedData_inboxFeed_entries', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'GInboxFeedData_inboxFeed_entries', 'kind'),
            messageType: BuiltValueNullFieldError.checkNotNull(messageType,
                r'GInboxFeedData_inboxFeed_entries', 'messageType'),
            urgency: BuiltValueNullFieldError.checkNotNull(
                urgency, r'GInboxFeedData_inboxFeed_entries', 'urgency'),
            createdAt: createdAt.build(),
            readAt: _readAt?.build(),
            dismissedAt: _dismissedAt?.build(),
            item: BuiltValueNullFieldError.checkNotNull(
                item, r'GInboxFeedData_inboxFeed_entries', 'item'),
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
            r'GInboxFeedData_inboxFeed_entries', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__base
    extends GInboxFeedData_inboxFeed_entries_item__base {
  @override
  final String G__typename;

  factory _$GInboxFeedData_inboxFeed_entries_item__base(
          [void Function(GInboxFeedData_inboxFeed_entries_item__baseBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__baseBuilder()..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__base._({required this.G__typename})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__base rebuild(
          void Function(GInboxFeedData_inboxFeed_entries_item__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__baseBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__baseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__base &&
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
            r'GInboxFeedData_inboxFeed_entries_item__base')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__baseBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__base,
            GInboxFeedData_inboxFeed_entries_item__baseBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GInboxFeedData_inboxFeed_entries_item__baseBuilder() {
    GInboxFeedData_inboxFeed_entries_item__base._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entries_item__baseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxFeedData_inboxFeed_entries_item__base other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__base;
  }

  @override
  void update(
      void Function(GInboxFeedData_inboxFeed_entries_item__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__base build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__base _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__base._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__base', 'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asActionableTask
    extends GInboxFeedData_inboxFeed_entries_item__asActionableTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final GInboxFeedData_inboxFeed_entries_item__asActionableTask_task task;

  factory _$GInboxFeedData_inboxFeed_entries_item__asActionableTask(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask._(
      {required this.G__typename, required this.id, required this.task})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__asActionableTask &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asActionableTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('task', task))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asActionableTask,
            GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder? _task;
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
      get task => _$this._task ??=
          GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder();
  set task(
          GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asActionableTask._initializeBuilder(
        this);
  }

  GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder get _$this {
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
  void replace(GInboxFeedData_inboxFeed_entries_item__asActionableTask other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asActionableTask;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask _build() {
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTask _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed_entries_item__asActionableTask._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask',
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
            r'GInboxFeedData_inboxFeed_entries_item__asActionableTask',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task
    extends GInboxFeedData_inboxFeed_entries_item__asActionableTask_task {
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

  factory _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      required this.state,
      required this.priority,
      this.dueAt,
      required this.currentStage})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
      toBuilder() =>
          GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxFeedData_inboxFeed_entries_item__asActionableTask_task &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task')
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

class GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asActionableTask_task,
            GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task? _$v;

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

  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asActionableTask_task
        ._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
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
      GInboxFeedData_inboxFeed_entries_item__asActionableTask_task other) {
    _$v =
        other as _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task build() =>
      _build();

  _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task _build() {
    _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'title'),
            state: BuiltValueNullFieldError.checkNotNull(
                state,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'state'),
            priority: BuiltValueNullFieldError.checkNotNull(
                priority,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'priority'),
            dueAt: _dueAt?.build(),
            currentStage: BuiltValueNullFieldError.checkNotNull(
                currentStage,
                r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
                'currentStage'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GInboxFeedData_inboxFeed_entries_item__asActionableTask_task',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment
    extends GInboxFeedData_inboxFeed_entries_item__asAgentAssignment {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GChainStage stage;
  @override
  final String ask;
  @override
  final GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task task;

  factory _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment._(
      {required this.G__typename,
      required this.id,
      required this.stage,
      required this.ask,
      required this.task})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__asAgentAssignment &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('stage', stage)
          ..add('ask', ask)
          ..add('task', task))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment? _$v;

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

  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder? _task;
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
      get task => _$this._task ??=
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder();
  set task(
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asAgentAssignment._initializeBuilder(
        this);
  }

  GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder get _$this {
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
  void replace(GInboxFeedData_inboxFeed_entries_item__asAgentAssignment other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment _build() {
    _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment',
                'id'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage,
                r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment',
                'stage'),
            ask: BuiltValueNullFieldError.checkNotNull(
                ask,
                r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment',
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
            r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
    extends GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task {
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

  factory _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
      toBuilder() =>
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task,
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task? _$v;

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

  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
        ._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
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
      GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task other) {
    _$v = other
        as _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task build() =>
      _build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task',
              'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task',
              'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task',
              'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(
              currentStage,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task',
              'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest
    extends GInboxFeedData_inboxFeed_entries_item__asApprovalRequest {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequest rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__asApprovalRequest &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asApprovalRequest')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
            GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asApprovalRequest._initializeBuilder(
        this);
  }

  GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxFeedData_inboxFeed_entries_item__asApprovalRequest other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequest build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__asApprovalRequest',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxFeedData_inboxFeed_entries_item__asApprovalRequest',
              'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion
    extends GInboxFeedData_inboxFeed_entries_item__asAgentQuestion {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String question;

  factory _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion._(
      {required this.G__typename, required this.id, required this.question})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestion rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__asAgentQuestion &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asAgentQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('question', question))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
            GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _question;
  String? get question => _$this._question;
  set question(String? question) => _$this._question = question;

  GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asAgentQuestion._initializeBuilder(
        this);
  }

  GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder get _$this {
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
  void replace(GInboxFeedData_inboxFeed_entries_item__asAgentQuestion other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestion build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentQuestion',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(id,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentQuestion', 'id'),
          question: BuiltValueNullFieldError.checkNotNull(
              question,
              r'GInboxFeedData_inboxFeed_entries_item__asAgentQuestion',
              'question'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal
    extends GInboxFeedData_inboxFeed_entries_item__asPromotionProposal {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GAutonomyLevel fromLevel;
  @override
  final _i2.GAutonomyLevel toLevel;

  factory _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal._(
      {required this.G__typename,
      required this.id,
      required this.fromLevel,
      required this.toLevel})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposal rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder
      toBuilder() =>
          GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxFeedData_inboxFeed_entries_item__asPromotionProposal &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('fromLevel', fromLevel)
          ..add('toLevel', toLevel))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
            GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal? _$v;

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

  GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asPromotionProposal
        ._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder get _$this {
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
      GInboxFeedData_inboxFeed_entries_item__asPromotionProposal other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposal build() =>
      _build();

  _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal',
              'id'),
          fromLevel: BuiltValueNullFieldError.checkNotNull(
              fromLevel,
              r'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal',
              'fromLevel'),
          toLevel: BuiltValueNullFieldError.checkNotNull(
              toLevel,
              r'GInboxFeedData_inboxFeed_entries_item__asPromotionProposal',
              'toLevel'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest
    extends GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task task;

  factory _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest._(
      {required this.G__typename, required this.id, required this.task})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder toBuilder() =>
      GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('task', task))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder? _task;
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
      get task => _$this._task ??=
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder();
  set task(
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder?
              task) =>
      _$this._task = task;

  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest._initializeBuilder(
        this);
  }

  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder get _$this {
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
  void replace(GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest other) {
    _$v = other as _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest build() => _build();

  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest _build() {
    _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest _$result;
    try {
      _$result = _$v ??
          _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest',
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
            r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
    extends GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;

  factory _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder)?
              updates]) =>
      (GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder()
            ..update(updates))
          ._build();

  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task._(
      {required this.G__typename, required this.id, required this.title})
      : super._();
  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task rebuild(
          void Function(
                  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
      toBuilder() =>
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task &&
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
            r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
    implements
        Builder<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task,
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder> {
  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder() {
    GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
        ._initializeBuilder(this);
  }

  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
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
      GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task other) {
    _$v = other
        as _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task;
  }

  @override
  void update(
      void Function(
              GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task build() =>
      _build();

  _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task _build() {
    final _$result = _$v ??
        _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task',
              'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task',
              'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
