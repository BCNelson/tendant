// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i3;
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'feedback.data.gql.g.dart';

abstract class GFeedbackRequestData
    implements Built<GFeedbackRequestData, GFeedbackRequestDataBuilder> {
  GFeedbackRequestData._();

  factory GFeedbackRequestData(
          [void Function(GFeedbackRequestDataBuilder b) updates]) =
      _$GFeedbackRequestData;

  static void _initializeBuilder(GFeedbackRequestDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GFeedbackRequestData_pendingDecision? get pendingDecision;
  static Serializer<GFeedbackRequestData> get serializer =>
      _$gFeedbackRequestDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestData.serializer,
        json,
      );
}

abstract class GFeedbackRequestData_pendingDecision {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime get createdAt;
  static Serializer<GFeedbackRequestData_pendingDecision> get serializer =>
      _i3.InlineFragmentSerializer<GFeedbackRequestData_pendingDecision>(
        'GFeedbackRequestData_pendingDecision',
        GFeedbackRequestData_pendingDecision__base,
        {
          'FeedbackRequest':
              GFeedbackRequestData_pendingDecision__asFeedbackRequest
        },
      );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestData_pendingDecision.serializer,
        json,
      );
}

abstract class GFeedbackRequestData_pendingDecision__base
    implements
        Built<GFeedbackRequestData_pendingDecision__base,
            GFeedbackRequestData_pendingDecision__baseBuilder>,
        GFeedbackRequestData_pendingDecision {
  GFeedbackRequestData_pendingDecision__base._();

  factory GFeedbackRequestData_pendingDecision__base(
      [void Function(GFeedbackRequestData_pendingDecision__baseBuilder b)
          updates]) = _$GFeedbackRequestData_pendingDecision__base;

  static void _initializeBuilder(
          GFeedbackRequestData_pendingDecision__baseBuilder b) =>
      b..G__typename = 'PendingDecision';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  _i2.GTime get createdAt;
  static Serializer<GFeedbackRequestData_pendingDecision__base>
      get serializer => _$gFeedbackRequestDataPendingDecisionBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision__base? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestData_pendingDecision__base.serializer,
        json,
      );
}

abstract class GFeedbackRequestData_pendingDecision__asFeedbackRequest
    implements
        Built<GFeedbackRequestData_pendingDecision__asFeedbackRequest,
            GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder>,
        GFeedbackRequestData_pendingDecision {
  GFeedbackRequestData_pendingDecision__asFeedbackRequest._();

  factory GFeedbackRequestData_pendingDecision__asFeedbackRequest(
      [void Function(
              GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder b)
          updates]) = _$GFeedbackRequestData_pendingDecision__asFeedbackRequest;

  static void _initializeBuilder(
          GFeedbackRequestData_pendingDecision__asFeedbackRequestBuilder b) =>
      b..G__typename = 'FeedbackRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  _i2.GTime get createdAt;
  String? get draftGuidance;
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task get task;
  BuiltList<GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>
      get messages;
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_context? get context;
  static Serializer<GFeedbackRequestData_pendingDecision__asFeedbackRequest>
      get serializer =>
          _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision__asFeedbackRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest.serializer,
        json,
      );
}

abstract class GFeedbackRequestData_pendingDecision__asFeedbackRequest_task
    implements
        Built<GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder> {
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task._();

  factory GFeedbackRequestData_pendingDecision__asFeedbackRequest_task(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
                      b)
              updates]) =
      _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_task;

  static void _initializeBuilder(
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  static Serializer<
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_task>
      get serializer =>
          _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision__asFeedbackRequest_task? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_task.serializer,
        json,
      );
}

abstract class GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
    implements
        Built<GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder> {
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages._();

  factory GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder
                      b)
              updates]) =
      _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages;

  static void _initializeBuilder(
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_messagesBuilder
              b) =>
      b..G__typename = 'FeedbackMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get role;
  String get content;
  _i2.GTime get createdAt;
  static Serializer<
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>
      get serializer =>
          _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestMessagesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
                .serializer,
            json,
          );
}

abstract class GFeedbackRequestData_pendingDecision__asFeedbackRequest_context
    implements
        Built<GFeedbackRequestData_pendingDecision__asFeedbackRequest_context,
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_contextBuilder> {
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_context._();

  factory GFeedbackRequestData_pendingDecision__asFeedbackRequest_context(
          [void Function(
                  GFeedbackRequestData_pendingDecision__asFeedbackRequest_contextBuilder
                      b)
              updates]) =
      _$GFeedbackRequestData_pendingDecision__asFeedbackRequest_context;

  static void _initializeBuilder(
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_contextBuilder
              b) =>
      b..G__typename = 'FeedbackContext';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  int get toolsRun;
  int get toolsFlagged;
  BuiltList<String> get agentStages;
  String? get handoffReason;
  int get activeGuidanceCount;
  BuiltList<String> get consulted;
  String get summary;
  static Serializer<
          GFeedbackRequestData_pendingDecision__asFeedbackRequest_context>
      get serializer =>
          _$gFeedbackRequestDataPendingDecisionAsFeedbackRequestContextSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_context
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestData_pendingDecision__asFeedbackRequest_context?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GFeedbackRequestData_pendingDecision__asFeedbackRequest_context
                .serializer,
            json,
          );
}

abstract class GSendFeedbackMessageData
    implements
        Built<GSendFeedbackMessageData, GSendFeedbackMessageDataBuilder> {
  GSendFeedbackMessageData._();

  factory GSendFeedbackMessageData(
          [void Function(GSendFeedbackMessageDataBuilder b) updates]) =
      _$GSendFeedbackMessageData;

  static void _initializeBuilder(GSendFeedbackMessageDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSendFeedbackMessageData_sendFeedbackMessage get sendFeedbackMessage;
  static Serializer<GSendFeedbackMessageData> get serializer =>
      _$gSendFeedbackMessageDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendFeedbackMessageData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendFeedbackMessageData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendFeedbackMessageData.serializer,
        json,
      );
}

abstract class GSendFeedbackMessageData_sendFeedbackMessage
    implements
        Built<GSendFeedbackMessageData_sendFeedbackMessage,
            GSendFeedbackMessageData_sendFeedbackMessageBuilder> {
  GSendFeedbackMessageData_sendFeedbackMessage._();

  factory GSendFeedbackMessageData_sendFeedbackMessage(
      [void Function(GSendFeedbackMessageData_sendFeedbackMessageBuilder b)
          updates]) = _$GSendFeedbackMessageData_sendFeedbackMessage;

  static void _initializeBuilder(
          GSendFeedbackMessageData_sendFeedbackMessageBuilder b) =>
      b..G__typename = 'FeedbackRequest';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String? get draftGuidance;
  BuiltList<GSendFeedbackMessageData_sendFeedbackMessage_messages> get messages;
  static Serializer<GSendFeedbackMessageData_sendFeedbackMessage>
      get serializer => _$gSendFeedbackMessageDataSendFeedbackMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendFeedbackMessageData_sendFeedbackMessage.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendFeedbackMessageData_sendFeedbackMessage? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendFeedbackMessageData_sendFeedbackMessage.serializer,
        json,
      );
}

abstract class GSendFeedbackMessageData_sendFeedbackMessage_messages
    implements
        Built<GSendFeedbackMessageData_sendFeedbackMessage_messages,
            GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder> {
  GSendFeedbackMessageData_sendFeedbackMessage_messages._();

  factory GSendFeedbackMessageData_sendFeedbackMessage_messages(
      [void Function(
              GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder b)
          updates]) = _$GSendFeedbackMessageData_sendFeedbackMessage_messages;

  static void _initializeBuilder(
          GSendFeedbackMessageData_sendFeedbackMessage_messagesBuilder b) =>
      b..G__typename = 'FeedbackMessage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get role;
  String get content;
  _i2.GTime get createdAt;
  static Serializer<GSendFeedbackMessageData_sendFeedbackMessage_messages>
      get serializer =>
          _$gSendFeedbackMessageDataSendFeedbackMessageMessagesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendFeedbackMessageData_sendFeedbackMessage_messages.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendFeedbackMessageData_sendFeedbackMessage_messages? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendFeedbackMessageData_sendFeedbackMessage_messages.serializer,
        json,
      );
}

abstract class GAcceptFeedbackGuidanceData
    implements
        Built<GAcceptFeedbackGuidanceData, GAcceptFeedbackGuidanceDataBuilder> {
  GAcceptFeedbackGuidanceData._();

  factory GAcceptFeedbackGuidanceData(
          [void Function(GAcceptFeedbackGuidanceDataBuilder b) updates]) =
      _$GAcceptFeedbackGuidanceData;

  static void _initializeBuilder(GAcceptFeedbackGuidanceDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance?
      get acceptFeedbackGuidance;
  static Serializer<GAcceptFeedbackGuidanceData> get serializer =>
      _$gAcceptFeedbackGuidanceDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptFeedbackGuidanceData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptFeedbackGuidanceData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptFeedbackGuidanceData.serializer,
        json,
      );
}

abstract class GAcceptFeedbackGuidanceData_acceptFeedbackGuidance
    implements
        Built<GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
            GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder> {
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance._();

  factory GAcceptFeedbackGuidanceData_acceptFeedbackGuidance(
      [void Function(
              GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder b)
          updates]) = _$GAcceptFeedbackGuidanceData_acceptFeedbackGuidance;

  static void _initializeBuilder(
          GAcceptFeedbackGuidanceData_acceptFeedbackGuidanceBuilder b) =>
      b..G__typename = 'AgentGuidance';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get note;
  _i2.GGuidanceScope get scope;
  String? get agentConfigId;
  static Serializer<GAcceptFeedbackGuidanceData_acceptFeedbackGuidance>
      get serializer =>
          _$gAcceptFeedbackGuidanceDataAcceptFeedbackGuidanceSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptFeedbackGuidanceData_acceptFeedbackGuidance.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptFeedbackGuidanceData_acceptFeedbackGuidance? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptFeedbackGuidanceData_acceptFeedbackGuidance.serializer,
        json,
      );
}

abstract class GDismissFeedbackData
    implements Built<GDismissFeedbackData, GDismissFeedbackDataBuilder> {
  GDismissFeedbackData._();

  factory GDismissFeedbackData(
          [void Function(GDismissFeedbackDataBuilder b) updates]) =
      _$GDismissFeedbackData;

  static void _initializeBuilder(GDismissFeedbackDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GDismissFeedbackData_dismissFeedback get dismissFeedback;
  static Serializer<GDismissFeedbackData> get serializer =>
      _$gDismissFeedbackDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissFeedbackData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissFeedbackData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissFeedbackData.serializer,
        json,
      );
}

abstract class GDismissFeedbackData_dismissFeedback
    implements
        Built<GDismissFeedbackData_dismissFeedback,
            GDismissFeedbackData_dismissFeedbackBuilder> {
  GDismissFeedbackData_dismissFeedback._();

  factory GDismissFeedbackData_dismissFeedback(
      [void Function(GDismissFeedbackData_dismissFeedbackBuilder b)
          updates]) = _$GDismissFeedbackData_dismissFeedback;

  static void _initializeBuilder(
          GDismissFeedbackData_dismissFeedbackBuilder b) =>
      b..G__typename = 'PendingDecision';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GDismissFeedbackData_dismissFeedback> get serializer =>
      _$gDismissFeedbackDataDismissFeedbackSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissFeedbackData_dismissFeedback.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissFeedbackData_dismissFeedback? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissFeedbackData_dismissFeedback.serializer,
        json,
      );
}
