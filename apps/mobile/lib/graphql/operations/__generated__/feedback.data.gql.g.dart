// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GFeedbackRequestData> _$gFeedbackRequestDataSerializer =
    _$GFeedbackRequestDataSerializer();
Serializer<GFeedbackRequestData_pendingDecision__base>
    _$gFeedbackRequestDataPendingDecisionBaseSerializer =
    _$GFeedbackRequestData_pendingDecision__baseSerializer();
Serializer<GFeedbackRequestData_pendingDecision__asFeedbackRequest>
    _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestSerializer =
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequestSerializer();
Serializer<GFeedbackRequestData_pendingDecision__asFeedbackRequest_task>
    _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestTaskSerializer =
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskSerializer();
Serializer<GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>
    _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestMessagesSerializer =
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesSerializer();
Serializer<GSendFeedbackMessageData> _$gSendFeedbackMessageDataSerializer =
    _$GSendFeedbackMessageDataSerializer();
Serializer<GSendFeedbackMessageData_sendFeedbackMessage>
    _$gSendFeedbackMessageDataSendFeedbackMessageSerializer =
    _$GSendFeedbackMessageData_sendFeedbackMessageSerializer();
Serializer<GSendFeedbackMessageData_sendFeedbackMessage_messages>
    _$gSendFeedbackMessageDataSendFeedbackMessageMessagesSerializer =
    _$GSendFeedbackMessageData_sendFeedbackMessage_messagesSerializer();
Serializer<GAcceptFeedbackGuidanceData>
    _$gAcceptFeedbackGuidanceDataSerializer =
    _$GAcceptFeedbackGuidanceDataSerializer();
Serializer<GAcceptFeedbackGuidanceData_acceptFeedbackGuidance>
    _$gAcceptFeedbackGuidanceDataAcceptFeedbackGuidanceSerializer =
    _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceSerializer();
Serializer<GDismissFeedbackData> _$gDismissFeedbackDataSerializer =
    _$GDismissFeedbackDataSerializer();
Serializer<GDismissFeedbackData_dismissFeedback>
    _$gDismissFeedbackDataDismissFeedbackSerializer =
    _$GDismissFeedbackData_dismissFeedbackSerializer();

class _$GFeedbackRequestDataSerializer
    implements StructuredSerializer<GFeedbackRequestData> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestData,
    _$GFeedbackRequestData
  ];
  @override
  final String wireName = 'GFeedbackRequestData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GFeedbackRequestData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.pendingDecision;
    if (value != null) {
      result
        ..add('pendingDecision')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GFeedbackRequestData_pendingDecision)));
    }
    return result;
  }

  @override
  GFeedbackRequestData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GFeedbackRequestDataBuilder();

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
        case 'pendingDecision':
          result.pendingDecision = serializers.deserialize(value,
                  specifiedType:
                      const FullType(GFeedbackRequestData_pendingDecision))
              as GFeedbackRequestData_pendingDecision?;
          break;
      }
    }

    return result.build();
  }
}

class _$GFeedbackRequestData_pendingDecision__baseSerializer
    implements
        StructuredSerializer<GFeedbackRequestData_pendingDecision__base> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestData_pendingDecision__base,
    _$GFeedbackRequestData_pendingDecision__base
  ];
  @override
  final String wireName = 'GFeedbackRequestData_pendingDecision__base';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GFeedbackRequestData_pendingDecision__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GFeedbackRequestData_pendingDecision__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GFeedbackRequestData_pendingDecision__baseBuilder();

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
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequestSerializer
    implements
        StructuredSerializer<
            GFeedbackRequestData_pendingDecision__asFeedbackRequest> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestData_pendingDecision__asFeedbackRequest,
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest
  ];
  @override
  final String wireName =
      'GFeedbackRequestData_pendingDecision__asFeedbackRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GFeedbackRequestData_pendingDecision__asFeedbackRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'task',
      serializers.serialize(object.task,
          specifiedType: const FullType(
              GFeedbackRequestData_pendingDecision__asFeedbackRequest_task)),
      'messages',
      serializers.serialize(object.messages,
          specifiedType: const FullType(BuiltList, const [
            const FullType(
                GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages)
          ])),
    ];
    Object? value;
    value = object.draftGuidance;
    if (value != null) {
      result
        ..add('draftGuidance')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder();

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
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'draftGuidance':
          result.draftGuidance = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GFeedbackRequestData_pendingDecision__asFeedbackRequest_task))!
              as GFeedbackRequestData_pendingDecision__asFeedbackRequest_task);
          break;
        case 'messages':
          result.messages.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(
                    GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskSerializer
    implements
        StructuredSerializer<
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_task> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task
  ];
  @override
  final String wireName =
      'GFeedbackRequestData_pendingDecision__asFeedbackRequest_task';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GFeedbackRequestData_pendingDecision__asFeedbackRequest_task object,
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
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder();

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

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesSerializer
    implements
        StructuredSerializer<
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
  ];
  @override
  final String wireName =
      'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'role',
      serializers.serialize(object.role, specifiedType: const FullType(String)),
      'content',
      serializers.serialize(object.content,
          specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder();

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
        case 'role':
          result.role = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'content':
          result.content = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendFeedbackMessageDataSerializer
    implements StructuredSerializer<GSendFeedbackMessageData> {
  @override
  final Iterable<Type> types = const [
    GSendFeedbackMessageData,
    _$GSendFeedbackMessageData
  ];
  @override
  final String wireName = 'GSendFeedbackMessageData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendFeedbackMessageData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'sendFeedbackMessage',
      serializers.serialize(object.sendFeedbackMessage,
          specifiedType:
              const FullType(GSendFeedbackMessageData_sendFeedbackMessage)),
    ];

    return result;
  }

  @override
  GSendFeedbackMessageData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendFeedbackMessageDataBuilder();

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
        case 'sendFeedbackMessage':
          result.sendFeedbackMessage.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GSendFeedbackMessageData_sendFeedbackMessage))!
              as GSendFeedbackMessageData_sendFeedbackMessage);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendFeedbackMessageData_sendFeedbackMessageSerializer
    implements
        StructuredSerializer<GSendFeedbackMessageData_sendFeedbackMessage> {
  @override
  final Iterable<Type> types = const [
    GSendFeedbackMessageData_sendFeedbackMessage,
    _$GSendFeedbackMessageData_sendFeedbackMessage
  ];
  @override
  final String wireName = 'GSendFeedbackMessageData_sendFeedbackMessage';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GSendFeedbackMessageData_sendFeedbackMessage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'messages',
      serializers.serialize(object.messages,
          specifiedType: const FullType(BuiltList, const [
            const FullType(
                GSendFeedbackMessageData_sendFeedbackMessage_messages)
          ])),
    ];
    Object? value;
    value = object.draftGuidance;
    if (value != null) {
      result
        ..add('draftGuidance')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GSendFeedbackMessageData_sendFeedbackMessage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendFeedbackMessageData_sendFeedbackMessageBuilder();

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
        case 'draftGuidance':
          result.draftGuidance = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'messages':
          result.messages.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(
                    GSendFeedbackMessageData_sendFeedbackMessage_messages)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendFeedbackMessageData_sendFeedbackMessage_messagesSerializer
    implements
        StructuredSerializer<
            GSendFeedbackMessageData_sendFeedbackMessage_messages> {
  @override
  final Iterable<Type> types = const [
    GSendFeedbackMessageData_sendFeedbackMessage_messages,
    _$GSendFeedbackMessageData_sendFeedbackMessage_messages
  ];
  @override
  final String wireName =
      'GSendFeedbackMessageData_sendFeedbackMessage_messages';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GSendFeedbackMessageData_sendFeedbackMessage_messages object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'role',
      serializers.serialize(object.role, specifiedType: const FullType(String)),
      'content',
      serializers.serialize(object.content,
          specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GSendFeedbackMessageData_sendFeedbackMessage_messages deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder();

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
        case 'role':
          result.role = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'content':
          result.content = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptFeedbackGuidanceDataSerializer
    implements StructuredSerializer<GAcceptFeedbackGuidanceData> {
  @override
  final Iterable<Type> types = const [
    GAcceptFeedbackGuidanceData,
    _$GAcceptFeedbackGuidanceData
  ];
  @override
  final String wireName = 'GAcceptFeedbackGuidanceData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAcceptFeedbackGuidanceData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.acceptFeedbackGuidance;
    if (value != null) {
      result
        ..add('acceptFeedbackGuidance')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                GAcceptFeedbackGuidanceData_acceptFeedbackGuidance)));
    }
    return result;
  }

  @override
  GAcceptFeedbackGuidanceData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptFeedbackGuidanceDataBuilder();

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
        case 'acceptFeedbackGuidance':
          result.acceptFeedbackGuidance.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GAcceptFeedbackGuidanceData_acceptFeedbackGuidance))!
              as GAcceptFeedbackGuidanceData_acceptFeedbackGuidance);
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceSerializer
    implements
        StructuredSerializer<
            GAcceptFeedbackGuidanceData_acceptFeedbackGuidance> {
  @override
  final Iterable<Type> types = const [
    GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
    _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance
  ];
  @override
  final String wireName = 'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GAcceptFeedbackGuidanceData_acceptFeedbackGuidance object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'note',
      serializers.serialize(object.note, specifiedType: const FullType(String)),
      'scope',
      serializers.serialize(object.scope,
          specifiedType: const FullType(_i2.GGuidanceScope)),
    ];
    Object? value;
    value = object.agentConfigId;
    if (value != null) {
      result
        ..add('agentConfigId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder();

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
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'scope':
          result.scope = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GGuidanceScope))!
              as _i2.GGuidanceScope;
          break;
        case 'agentConfigId':
          result.agentConfigId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissFeedbackDataSerializer
    implements StructuredSerializer<GDismissFeedbackData> {
  @override
  final Iterable<Type> types = const [
    GDismissFeedbackData,
    _$GDismissFeedbackData
  ];
  @override
  final String wireName = 'GDismissFeedbackData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissFeedbackData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'dismissFeedback',
      serializers.serialize(object.dismissFeedback,
          specifiedType: const FullType(GDismissFeedbackData_dismissFeedback)),
    ];

    return result;
  }

  @override
  GDismissFeedbackData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissFeedbackDataBuilder();

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
        case 'dismissFeedback':
          result.dismissFeedback.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GDismissFeedbackData_dismissFeedback))!
              as GDismissFeedbackData_dismissFeedback);
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissFeedbackData_dismissFeedbackSerializer
    implements StructuredSerializer<GDismissFeedbackData_dismissFeedback> {
  @override
  final Iterable<Type> types = const [
    GDismissFeedbackData_dismissFeedback,
    _$GDismissFeedbackData_dismissFeedback
  ];
  @override
  final String wireName = 'GDismissFeedbackData_dismissFeedback';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissFeedbackData_dismissFeedback object,
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
  GDismissFeedbackData_dismissFeedback deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissFeedbackData_dismissFeedbackBuilder();

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

class _$GFeedbackRequestData extends GFeedbackRequestData {
  @override
  final String G__typename;
  @override
  final GFeedbackRequestData_pendingDecision? pendingDecision;

  factory _$GFeedbackRequestData(
          [void Function(GFeedbackRequestDataBuilder)? updates]) =>
      (GFeedbackRequestDataBuilder()..update(updates))._build();

  _$GFeedbackRequestData._({required this.G__typename, this.pendingDecision})
      : super._();
  @override
  GFeedbackRequestData rebuild(
          void Function(GFeedbackRequestDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestDataBuilder toBuilder() =>
      GFeedbackRequestDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GFeedbackRequestData &&
        G__typename == other.G__typename &&
        pendingDecision == other.pendingDecision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, pendingDecision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GFeedbackRequestData')
          ..add('G__typename', G__typename)
          ..add('pendingDecision', pendingDecision))
        .toString();
  }
}

class GFeedbackRequestDataBuilder
    implements Builder<GFeedbackRequestData, GFeedbackRequestDataBuilder> {
  _$GFeedbackRequestData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GFeedbackRequestData_pendingDecision? _pendingDecision;
  GFeedbackRequestData_pendingDecision? get pendingDecision =>
      _$this._pendingDecision;
  set pendingDecision(GFeedbackRequestData_pendingDecision? pendingDecision) =>
      _$this._pendingDecision = pendingDecision;

  GFeedbackRequestDataBuilder() {
    GFeedbackRequestData._initializeBuilder(this);
  }

  GFeedbackRequestDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _pendingDecision = $v.pendingDecision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GFeedbackRequestData other) {
    _$v = other as _$GFeedbackRequestData;
  }

  @override
  void update(void Function(GFeedbackRequestDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestData build() => _build();

  _$GFeedbackRequestData _build() {
    final _$result = _$v ??
        _$GFeedbackRequestData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GFeedbackRequestData', 'G__typename'),
          pendingDecision: pendingDecision,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GFeedbackRequestData_pendingDecision__base
    extends GFeedbackRequestData_pendingDecision__base {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;

  factory _$GFeedbackRequestData_pendingDecision__base(
          [void Function(GFeedbackRequestData_pendingDecision__baseBuilder)?
              updates]) =>
      (GFeedbackRequestData_pendingDecision__baseBuilder()..update(updates))
          ._build();

  _$GFeedbackRequestData_pendingDecision__base._(
      {required this.G__typename, required this.id, required this.createdAt})
      : super._();
  @override
  GFeedbackRequestData_pendingDecision__base rebuild(
          void Function(GFeedbackRequestData_pendingDecision__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestData_pendingDecision__baseBuilder toBuilder() =>
      GFeedbackRequestData_pendingDecision__baseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GFeedbackRequestData_pendingDecision__base &&
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
    return (newBuiltValueToStringHelper(
            r'GFeedbackRequestData_pendingDecision__base')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GFeedbackRequestData_pendingDecision__baseBuilder
    implements
        Builder<GFeedbackRequestData_pendingDecision__base,
            GFeedbackRequestData_pendingDecision__baseBuilder> {
  _$GFeedbackRequestData_pendingDecision__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GFeedbackRequestData_pendingDecision__baseBuilder() {
    GFeedbackRequestData_pendingDecision__base._initializeBuilder(this);
  }

  GFeedbackRequestData_pendingDecision__baseBuilder get _$this {
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
  void replace(GFeedbackRequestData_pendingDecision__base other) {
    _$v = other as _$GFeedbackRequestData_pendingDecision__base;
  }

  @override
  void update(
      void Function(GFeedbackRequestData_pendingDecision__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestData_pendingDecision__base build() => _build();

  _$GFeedbackRequestData_pendingDecision__base _build() {
    _$GFeedbackRequestData_pendingDecision__base _$result;
    try {
      _$result = _$v ??
          _$GFeedbackRequestData_pendingDecision__base._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GFeedbackRequestData_pendingDecision__base', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GFeedbackRequestData_pendingDecision__base', 'id'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GFeedbackRequestData_pendingDecision__base',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequest
    extends GFeedbackRequestData_pendingDecision__asFeedbackRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;
  @override
  final String? draftGuidance;
  @override
  final GFeedbackRequestData_pendingDecision__asFeedbackRequest_task task;
  @override
  final BuiltList<
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>
      messages;

  factory _$GFeedbackRequestData_pendingDecision__asFeedbackRequest(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder)?
              updates]) =>
      (GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder()
            ..update(updates))
          ._build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      this.draftGuidance,
      required this.task,
      required this.messages})
      : super._();
  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest rebuild(
          void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder toBuilder() =>
      GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GFeedbackRequestData_pendingDecision__asFeedbackRequest &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        draftGuidance == other.draftGuidance &&
        task == other.task &&
        messages == other.messages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, draftGuidance.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GFeedbackRequestData_pendingDecision__asFeedbackRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('draftGuidance', draftGuidance)
          ..add('task', task)
          ..add('messages', messages))
        .toString();
  }
}

class GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder
    implements
        Builder<GFeedbackRequestData_pendingDecision__asFeedbackRequest,
            GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder> {
  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  String? _draftGuidance;
  String? get draftGuidance => _$this._draftGuidance;
  set draftGuidance(String? draftGuidance) =>
      _$this._draftGuidance = draftGuidance;

  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder? _task;
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
      get task => _$this._task ??=
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder();
  set task(
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder?
              task) =>
      _$this._task = task;

  ListBuilder<GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>?
      _messages;
  ListBuilder<GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>
      get messages => _$this._messages ??= ListBuilder<
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>();
  set messages(
          ListBuilder<
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>?
              messages) =>
      _$this._messages = messages;

  GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder() {
    GFeedbackRequestData_pendingDecision__asFeedbackRequest._initializeBuilder(
        this);
  }

  GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _draftGuidance = $v.draftGuidance;
      _task = $v.task.toBuilder();
      _messages = $v.messages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GFeedbackRequestData_pendingDecision__asFeedbackRequest other) {
    _$v = other as _$GFeedbackRequestData_pendingDecision__asFeedbackRequest;
  }

  @override
  void update(
      void Function(
              GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest build() => _build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest _build() {
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest _$result;
    try {
      _$result = _$v ??
          _$GFeedbackRequestData_pendingDecision__asFeedbackRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest',
                'id'),
            createdAt: createdAt.build(),
            draftGuidance: draftGuidance,
            task: task.build(),
            messages: messages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();

        _$failedField = 'task';
        task.build();
        _$failedField = 'messages';
        messages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GFeedbackRequestData_pendingDecision__asFeedbackRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task
    extends GFeedbackRequestData_pendingDecision__asFeedbackRequest_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;

  factory _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder)?
              updates]) =>
      (GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder()
            ..update(updates))
          ._build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task._(
      {required this.G__typename, required this.id, required this.title})
      : super._();
  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task rebuild(
          void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
      toBuilder() =>
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GFeedbackRequestData_pendingDecision__asFeedbackRequest_task &&
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
            r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
    implements
        Builder<GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder> {
  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder() {
    GFeedbackRequestData_pendingDecision__asFeedbackRequest_task
        ._initializeBuilder(this);
  }

  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
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
      GFeedbackRequestData_pendingDecision__asFeedbackRequest_task other) {
    _$v =
        other as _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task;
  }

  @override
  void update(
      void Function(
              GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task build() =>
      _build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task _build() {
    final _$result = _$v ??
        _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_task',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_task',
              'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_task',
              'title'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
    extends GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String role;
  @override
  final String content;
  @override
  final _i2.GTime createdAt;

  factory _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder)?
              updates]) =>
      (GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder()
            ..update(updates))
          ._build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages._(
      {required this.G__typename,
      required this.id,
      required this.role,
      required this.content,
      required this.createdAt})
      : super._();
  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages rebuild(
          void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder
      toBuilder() =>
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages &&
        G__typename == other.G__typename &&
        id == other.id &&
        role == other.role &&
        content == other.content &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('role', role)
          ..add('content', content)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder
    implements
        Builder<
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder> {
  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder() {
    GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
        ._initializeBuilder(this);
  }

  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _role = $v.role;
      _content = $v.content;
      _createdAt = $v.createdAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages other) {
    _$v = other
        as _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages;
  }

  @override
  void update(
      void Function(
              GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages build() =>
      _build();

  _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages _build() {
    _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages _$result;
    try {
      _$result = _$v ??
          _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages',
                'id'),
            role: BuiltValueNullFieldError.checkNotNull(
                role,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages',
                'role'),
            content: BuiltValueNullFieldError.checkNotNull(
                content,
                r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages',
                'content'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendFeedbackMessageData extends GSendFeedbackMessageData {
  @override
  final String G__typename;
  @override
  final GSendFeedbackMessageData_sendFeedbackMessage sendFeedbackMessage;

  factory _$GSendFeedbackMessageData(
          [void Function(GSendFeedbackMessageDataBuilder)? updates]) =>
      (GSendFeedbackMessageDataBuilder()..update(updates))._build();

  _$GSendFeedbackMessageData._(
      {required this.G__typename, required this.sendFeedbackMessage})
      : super._();
  @override
  GSendFeedbackMessageData rebuild(
          void Function(GSendFeedbackMessageDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendFeedbackMessageDataBuilder toBuilder() =>
      GSendFeedbackMessageDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendFeedbackMessageData &&
        G__typename == other.G__typename &&
        sendFeedbackMessage == other.sendFeedbackMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, sendFeedbackMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendFeedbackMessageData')
          ..add('G__typename', G__typename)
          ..add('sendFeedbackMessage', sendFeedbackMessage))
        .toString();
  }
}

class GSendFeedbackMessageDataBuilder
    implements
        Builder<GSendFeedbackMessageData, GSendFeedbackMessageDataBuilder> {
  _$GSendFeedbackMessageData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSendFeedbackMessageData_sendFeedbackMessageBuilder? _sendFeedbackMessage;
  GSendFeedbackMessageData_sendFeedbackMessageBuilder get sendFeedbackMessage =>
      _$this._sendFeedbackMessage ??=
          GSendFeedbackMessageData_sendFeedbackMessageBuilder();
  set sendFeedbackMessage(
          GSendFeedbackMessageData_sendFeedbackMessageBuilder?
              sendFeedbackMessage) =>
      _$this._sendFeedbackMessage = sendFeedbackMessage;

  GSendFeedbackMessageDataBuilder() {
    GSendFeedbackMessageData._initializeBuilder(this);
  }

  GSendFeedbackMessageDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _sendFeedbackMessage = $v.sendFeedbackMessage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendFeedbackMessageData other) {
    _$v = other as _$GSendFeedbackMessageData;
  }

  @override
  void update(void Function(GSendFeedbackMessageDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendFeedbackMessageData build() => _build();

  _$GSendFeedbackMessageData _build() {
    _$GSendFeedbackMessageData _$result;
    try {
      _$result = _$v ??
          _$GSendFeedbackMessageData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSendFeedbackMessageData', 'G__typename'),
            sendFeedbackMessage: sendFeedbackMessage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sendFeedbackMessage';
        sendFeedbackMessage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSendFeedbackMessageData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendFeedbackMessageData_sendFeedbackMessage
    extends GSendFeedbackMessageData_sendFeedbackMessage {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String? draftGuidance;
  @override
  final BuiltList<GSendFeedbackMessageData_sendFeedbackMessage_messages>
      messages;

  factory _$GSendFeedbackMessageData_sendFeedbackMessage(
          [void Function(GSendFeedbackMessageData_sendFeedbackMessageBuilder)?
              updates]) =>
      (GSendFeedbackMessageData_sendFeedbackMessageBuilder()..update(updates))
          ._build();

  _$GSendFeedbackMessageData_sendFeedbackMessage._(
      {required this.G__typename,
      required this.id,
      this.draftGuidance,
      required this.messages})
      : super._();
  @override
  GSendFeedbackMessageData_sendFeedbackMessage rebuild(
          void Function(GSendFeedbackMessageData_sendFeedbackMessageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendFeedbackMessageData_sendFeedbackMessageBuilder toBuilder() =>
      GSendFeedbackMessageData_sendFeedbackMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendFeedbackMessageData_sendFeedbackMessage &&
        G__typename == other.G__typename &&
        id == other.id &&
        draftGuidance == other.draftGuidance &&
        messages == other.messages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, draftGuidance.hashCode);
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GSendFeedbackMessageData_sendFeedbackMessage')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('draftGuidance', draftGuidance)
          ..add('messages', messages))
        .toString();
  }
}

class GSendFeedbackMessageData_sendFeedbackMessageBuilder
    implements
        Builder<GSendFeedbackMessageData_sendFeedbackMessage,
            GSendFeedbackMessageData_sendFeedbackMessageBuilder> {
  _$GSendFeedbackMessageData_sendFeedbackMessage? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _draftGuidance;
  String? get draftGuidance => _$this._draftGuidance;
  set draftGuidance(String? draftGuidance) =>
      _$this._draftGuidance = draftGuidance;

  ListBuilder<GSendFeedbackMessageData_sendFeedbackMessage_messages>? _messages;
  ListBuilder<GSendFeedbackMessageData_sendFeedbackMessage_messages>
      get messages => _$this._messages ??=
          ListBuilder<GSendFeedbackMessageData_sendFeedbackMessage_messages>();
  set messages(
          ListBuilder<GSendFeedbackMessageData_sendFeedbackMessage_messages>?
              messages) =>
      _$this._messages = messages;

  GSendFeedbackMessageData_sendFeedbackMessageBuilder() {
    GSendFeedbackMessageData_sendFeedbackMessage._initializeBuilder(this);
  }

  GSendFeedbackMessageData_sendFeedbackMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _draftGuidance = $v.draftGuidance;
      _messages = $v.messages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendFeedbackMessageData_sendFeedbackMessage other) {
    _$v = other as _$GSendFeedbackMessageData_sendFeedbackMessage;
  }

  @override
  void update(
      void Function(GSendFeedbackMessageData_sendFeedbackMessageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendFeedbackMessageData_sendFeedbackMessage build() => _build();

  _$GSendFeedbackMessageData_sendFeedbackMessage _build() {
    _$GSendFeedbackMessageData_sendFeedbackMessage _$result;
    try {
      _$result = _$v ??
          _$GSendFeedbackMessageData_sendFeedbackMessage._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GSendFeedbackMessageData_sendFeedbackMessage', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GSendFeedbackMessageData_sendFeedbackMessage', 'id'),
            draftGuidance: draftGuidance,
            messages: messages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messages';
        messages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSendFeedbackMessageData_sendFeedbackMessage',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendFeedbackMessageData_sendFeedbackMessage_messages
    extends GSendFeedbackMessageData_sendFeedbackMessage_messages {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String role;
  @override
  final String content;
  @override
  final _i2.GTime createdAt;

  factory _$GSendFeedbackMessageData_sendFeedbackMessage_messages(
          [void Function(
                  GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder)?
              updates]) =>
      (GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder()
            ..update(updates))
          ._build();

  _$GSendFeedbackMessageData_sendFeedbackMessage_messages._(
      {required this.G__typename,
      required this.id,
      required this.role,
      required this.content,
      required this.createdAt})
      : super._();
  @override
  GSendFeedbackMessageData_sendFeedbackMessage_messages rebuild(
          void Function(
                  GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder toBuilder() =>
      GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendFeedbackMessageData_sendFeedbackMessage_messages &&
        G__typename == other.G__typename &&
        id == other.id &&
        role == other.role &&
        content == other.content &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GSendFeedbackMessageData_sendFeedbackMessage_messages')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('role', role)
          ..add('content', content)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder
    implements
        Builder<GSendFeedbackMessageData_sendFeedbackMessage_messages,
            GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder> {
  _$GSendFeedbackMessageData_sendFeedbackMessage_messages? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder() {
    GSendFeedbackMessageData_sendFeedbackMessage_messages._initializeBuilder(
        this);
  }

  GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _role = $v.role;
      _content = $v.content;
      _createdAt = $v.createdAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendFeedbackMessageData_sendFeedbackMessage_messages other) {
    _$v = other as _$GSendFeedbackMessageData_sendFeedbackMessage_messages;
  }

  @override
  void update(
      void Function(
              GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendFeedbackMessageData_sendFeedbackMessage_messages build() => _build();

  _$GSendFeedbackMessageData_sendFeedbackMessage_messages _build() {
    _$GSendFeedbackMessageData_sendFeedbackMessage_messages _$result;
    try {
      _$result = _$v ??
          _$GSendFeedbackMessageData_sendFeedbackMessage_messages._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GSendFeedbackMessageData_sendFeedbackMessage_messages',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GSendFeedbackMessageData_sendFeedbackMessage_messages', 'id'),
            role: BuiltValueNullFieldError.checkNotNull(
                role,
                r'GSendFeedbackMessageData_sendFeedbackMessage_messages',
                'role'),
            content: BuiltValueNullFieldError.checkNotNull(
                content,
                r'GSendFeedbackMessageData_sendFeedbackMessage_messages',
                'content'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSendFeedbackMessageData_sendFeedbackMessage_messages',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAcceptFeedbackGuidanceData extends GAcceptFeedbackGuidanceData {
  @override
  final String G__typename;
  @override
  final GAcceptFeedbackGuidanceData_acceptFeedbackGuidance?
      acceptFeedbackGuidance;

  factory _$GAcceptFeedbackGuidanceData(
          [void Function(GAcceptFeedbackGuidanceDataBuilder)? updates]) =>
      (GAcceptFeedbackGuidanceDataBuilder()..update(updates))._build();

  _$GAcceptFeedbackGuidanceData._(
      {required this.G__typename, this.acceptFeedbackGuidance})
      : super._();
  @override
  GAcceptFeedbackGuidanceData rebuild(
          void Function(GAcceptFeedbackGuidanceDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptFeedbackGuidanceDataBuilder toBuilder() =>
      GAcceptFeedbackGuidanceDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptFeedbackGuidanceData &&
        G__typename == other.G__typename &&
        acceptFeedbackGuidance == other.acceptFeedbackGuidance;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, acceptFeedbackGuidance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAcceptFeedbackGuidanceData')
          ..add('G__typename', G__typename)
          ..add('acceptFeedbackGuidance', acceptFeedbackGuidance))
        .toString();
  }
}

class GAcceptFeedbackGuidanceDataBuilder
    implements
        Builder<GAcceptFeedbackGuidanceData,
            GAcceptFeedbackGuidanceDataBuilder> {
  _$GAcceptFeedbackGuidanceData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder?
      _acceptFeedbackGuidance;
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder
      get acceptFeedbackGuidance => _$this._acceptFeedbackGuidance ??=
          GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder();
  set acceptFeedbackGuidance(
          GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder?
              acceptFeedbackGuidance) =>
      _$this._acceptFeedbackGuidance = acceptFeedbackGuidance;

  GAcceptFeedbackGuidanceDataBuilder() {
    GAcceptFeedbackGuidanceData._initializeBuilder(this);
  }

  GAcceptFeedbackGuidanceDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _acceptFeedbackGuidance = $v.acceptFeedbackGuidance?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptFeedbackGuidanceData other) {
    _$v = other as _$GAcceptFeedbackGuidanceData;
  }

  @override
  void update(void Function(GAcceptFeedbackGuidanceDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptFeedbackGuidanceData build() => _build();

  _$GAcceptFeedbackGuidanceData _build() {
    _$GAcceptFeedbackGuidanceData _$result;
    try {
      _$result = _$v ??
          _$GAcceptFeedbackGuidanceData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAcceptFeedbackGuidanceData', 'G__typename'),
            acceptFeedbackGuidance: _acceptFeedbackGuidance?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'acceptFeedbackGuidance';
        _acceptFeedbackGuidance?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAcceptFeedbackGuidanceData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance
    extends GAcceptFeedbackGuidanceData_acceptFeedbackGuidance {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String note;
  @override
  final _i2.GGuidanceScope scope;
  @override
  final String? agentConfigId;

  factory _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance(
          [void Function(
                  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder)?
              updates]) =>
      (GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder()
            ..update(updates))
          ._build();

  _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance._(
      {required this.G__typename,
      required this.id,
      required this.note,
      required this.scope,
      this.agentConfigId})
      : super._();
  @override
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance rebuild(
          void Function(
                  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder toBuilder() =>
      GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptFeedbackGuidanceData_acceptFeedbackGuidance &&
        G__typename == other.G__typename &&
        id == other.id &&
        note == other.note &&
        scope == other.scope &&
        agentConfigId == other.agentConfigId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, agentConfigId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('note', note)
          ..add('scope', scope)
          ..add('agentConfigId', agentConfigId))
        .toString();
  }
}

class GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder
    implements
        Builder<GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
            GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder> {
  _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  _i2.GGuidanceScope? _scope;
  _i2.GGuidanceScope? get scope => _$this._scope;
  set scope(_i2.GGuidanceScope? scope) => _$this._scope = scope;

  String? _agentConfigId;
  String? get agentConfigId => _$this._agentConfigId;
  set agentConfigId(String? agentConfigId) =>
      _$this._agentConfigId = agentConfigId;

  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder() {
    GAcceptFeedbackGuidanceData_acceptFeedbackGuidance._initializeBuilder(this);
  }

  GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _note = $v.note;
      _scope = $v.scope;
      _agentConfigId = $v.agentConfigId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptFeedbackGuidanceData_acceptFeedbackGuidance other) {
    _$v = other as _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance;
  }

  @override
  void update(
      void Function(GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance build() => _build();

  _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance _build() {
    final _$result = _$v ??
        _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance', 'id'),
          note: BuiltValueNullFieldError.checkNotNull(note,
              r'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance', 'note'),
          scope: BuiltValueNullFieldError.checkNotNull(scope,
              r'GAcceptFeedbackGuidanceData_acceptFeedbackGuidance', 'scope'),
          agentConfigId: agentConfigId,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDismissFeedbackData extends GDismissFeedbackData {
  @override
  final String G__typename;
  @override
  final GDismissFeedbackData_dismissFeedback dismissFeedback;

  factory _$GDismissFeedbackData(
          [void Function(GDismissFeedbackDataBuilder)? updates]) =>
      (GDismissFeedbackDataBuilder()..update(updates))._build();

  _$GDismissFeedbackData._(
      {required this.G__typename, required this.dismissFeedback})
      : super._();
  @override
  GDismissFeedbackData rebuild(
          void Function(GDismissFeedbackDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissFeedbackDataBuilder toBuilder() =>
      GDismissFeedbackDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissFeedbackData &&
        G__typename == other.G__typename &&
        dismissFeedback == other.dismissFeedback;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, dismissFeedback.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissFeedbackData')
          ..add('G__typename', G__typename)
          ..add('dismissFeedback', dismissFeedback))
        .toString();
  }
}

class GDismissFeedbackDataBuilder
    implements Builder<GDismissFeedbackData, GDismissFeedbackDataBuilder> {
  _$GDismissFeedbackData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GDismissFeedbackData_dismissFeedbackBuilder? _dismissFeedback;
  GDismissFeedbackData_dismissFeedbackBuilder get dismissFeedback =>
      _$this._dismissFeedback ??= GDismissFeedbackData_dismissFeedbackBuilder();
  set dismissFeedback(
          GDismissFeedbackData_dismissFeedbackBuilder? dismissFeedback) =>
      _$this._dismissFeedback = dismissFeedback;

  GDismissFeedbackDataBuilder() {
    GDismissFeedbackData._initializeBuilder(this);
  }

  GDismissFeedbackDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _dismissFeedback = $v.dismissFeedback.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissFeedbackData other) {
    _$v = other as _$GDismissFeedbackData;
  }

  @override
  void update(void Function(GDismissFeedbackDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissFeedbackData build() => _build();

  _$GDismissFeedbackData _build() {
    _$GDismissFeedbackData _$result;
    try {
      _$result = _$v ??
          _$GDismissFeedbackData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GDismissFeedbackData', 'G__typename'),
            dismissFeedback: dismissFeedback.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dismissFeedback';
        dismissFeedback.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDismissFeedbackData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDismissFeedbackData_dismissFeedback
    extends GDismissFeedbackData_dismissFeedback {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GDismissFeedbackData_dismissFeedback(
          [void Function(GDismissFeedbackData_dismissFeedbackBuilder)?
              updates]) =>
      (GDismissFeedbackData_dismissFeedbackBuilder()..update(updates))._build();

  _$GDismissFeedbackData_dismissFeedback._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GDismissFeedbackData_dismissFeedback rebuild(
          void Function(GDismissFeedbackData_dismissFeedbackBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissFeedbackData_dismissFeedbackBuilder toBuilder() =>
      GDismissFeedbackData_dismissFeedbackBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissFeedbackData_dismissFeedback &&
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
    return (newBuiltValueToStringHelper(r'GDismissFeedbackData_dismissFeedback')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GDismissFeedbackData_dismissFeedbackBuilder
    implements
        Builder<GDismissFeedbackData_dismissFeedback,
            GDismissFeedbackData_dismissFeedbackBuilder> {
  _$GDismissFeedbackData_dismissFeedback? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GDismissFeedbackData_dismissFeedbackBuilder() {
    GDismissFeedbackData_dismissFeedback._initializeBuilder(this);
  }

  GDismissFeedbackData_dismissFeedbackBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissFeedbackData_dismissFeedback other) {
    _$v = other as _$GDismissFeedbackData_dismissFeedback;
  }

  @override
  void update(
      void Function(GDismissFeedbackData_dismissFeedbackBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissFeedbackData_dismissFeedback build() => _build();

  _$GDismissFeedbackData_dismissFeedback _build() {
    final _$result = _$v ??
        _$GDismissFeedbackData_dismissFeedback._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GDismissFeedbackData_dismissFeedback', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GDismissFeedbackData_dismissFeedback', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
