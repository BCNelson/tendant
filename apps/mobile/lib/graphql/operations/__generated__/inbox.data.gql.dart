// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i2;
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i3;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox.data.gql.g.dart';

abstract class GInboxData implements Built<GInboxData, GInboxDataBuilder> {
  GInboxData._();

  factory GInboxData([void Function(GInboxDataBuilder b) updates]) =
      _$GInboxData;

  static void _initializeBuilder(GInboxDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GInboxData_inbox> get inbox;
  static Serializer<GInboxData> get serializer => _$gInboxDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData.serializer,
        json,
      );
}

abstract class GInboxData_inbox {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxData_inbox> get serializer =>
      _i2.InlineFragmentSerializer<GInboxData_inbox>(
        'GInboxData_inbox',
        GInboxData_inbox__base,
        {
          'AgentAssignment': GInboxData_inbox__asAgentAssignment,
          'ApprovalRequest': GInboxData_inbox__asApprovalRequest,
          'AgentQuestion': GInboxData_inbox__asAgentQuestion,
          'PromotionProposal': GInboxData_inbox__asPromotionProposal,
          'FeedbackRequest': GInboxData_inbox__asFeedbackRequest,
        },
      );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox.serializer,
        json,
      );
}

abstract class GInboxData_inbox__base
    implements
        Built<GInboxData_inbox__base, GInboxData_inbox__baseBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__base._();

  factory GInboxData_inbox__base(
          [void Function(GInboxData_inbox__baseBuilder b) updates]) =
      _$GInboxData_inbox__base;

  static void _initializeBuilder(GInboxData_inbox__baseBuilder b) =>
      b..G__typename = 'InboxItem';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxData_inbox__base> get serializer =>
      _$gInboxDataInboxBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__base? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__base.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asAgentAssignment
    implements
        Built<GInboxData_inbox__asAgentAssignment,
            GInboxData_inbox__asAgentAssignmentBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__asAgentAssignment._();

  factory GInboxData_inbox__asAgentAssignment(
      [void Function(GInboxData_inbox__asAgentAssignmentBuilder b)
          updates]) = _$GInboxData_inbox__asAgentAssignment;

  static void _initializeBuilder(
          GInboxData_inbox__asAgentAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i3.GChainStage get stage;
  String get ask;
  _i3.GTime get createdAt;
  GInboxData_inbox__asAgentAssignment_task get task;
  static Serializer<GInboxData_inbox__asAgentAssignment> get serializer =>
      _$gInboxDataInboxAsAgentAssignmentSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asAgentAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asAgentAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asAgentAssignment.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asAgentAssignment_task
    implements
        Built<GInboxData_inbox__asAgentAssignment_task,
            GInboxData_inbox__asAgentAssignment_taskBuilder> {
  GInboxData_inbox__asAgentAssignment_task._();

  factory GInboxData_inbox__asAgentAssignment_task(
      [void Function(GInboxData_inbox__asAgentAssignment_taskBuilder b)
          updates]) = _$GInboxData_inbox__asAgentAssignment_task;

  static void _initializeBuilder(
          GInboxData_inbox__asAgentAssignment_taskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  _i3.GTaskState get state;
  _i3.GChainStage get currentStage;
  static Serializer<GInboxData_inbox__asAgentAssignment_task> get serializer =>
      _$gInboxDataInboxAsAgentAssignmentTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asAgentAssignment_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asAgentAssignment_task? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asAgentAssignment_task.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asApprovalRequest
    implements
        Built<GInboxData_inbox__asApprovalRequest,
            GInboxData_inbox__asApprovalRequestBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__asApprovalRequest._();

  factory GInboxData_inbox__asApprovalRequest(
      [void Function(GInboxData_inbox__asApprovalRequestBuilder b)
          updates]) = _$GInboxData_inbox__asApprovalRequest;

  static void _initializeBuilder(
          GInboxData_inbox__asApprovalRequestBuilder b) =>
      b..G__typename = 'ApprovalRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i3.GTime get createdAt;
  static Serializer<GInboxData_inbox__asApprovalRequest> get serializer =>
      _$gInboxDataInboxAsApprovalRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asApprovalRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asApprovalRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asApprovalRequest.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asAgentQuestion
    implements
        Built<GInboxData_inbox__asAgentQuestion,
            GInboxData_inbox__asAgentQuestionBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__asAgentQuestion._();

  factory GInboxData_inbox__asAgentQuestion(
          [void Function(GInboxData_inbox__asAgentQuestionBuilder b) updates]) =
      _$GInboxData_inbox__asAgentQuestion;

  static void _initializeBuilder(GInboxData_inbox__asAgentQuestionBuilder b) =>
      b..G__typename = 'AgentQuestion';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i3.GTime get createdAt;
  String get question;
  static Serializer<GInboxData_inbox__asAgentQuestion> get serializer =>
      _$gInboxDataInboxAsAgentQuestionSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asAgentQuestion.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asAgentQuestion? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asAgentQuestion.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asPromotionProposal
    implements
        Built<GInboxData_inbox__asPromotionProposal,
            GInboxData_inbox__asPromotionProposalBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__asPromotionProposal._();

  factory GInboxData_inbox__asPromotionProposal(
      [void Function(GInboxData_inbox__asPromotionProposalBuilder b)
          updates]) = _$GInboxData_inbox__asPromotionProposal;

  static void _initializeBuilder(
          GInboxData_inbox__asPromotionProposalBuilder b) =>
      b..G__typename = 'PromotionProposal';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i3.GTime get createdAt;
  _i3.GAutonomyLevel get fromLevel;
  _i3.GAutonomyLevel get toLevel;
  static Serializer<GInboxData_inbox__asPromotionProposal> get serializer =>
      _$gInboxDataInboxAsPromotionProposalSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asPromotionProposal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asPromotionProposal? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asPromotionProposal.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asFeedbackRequest
    implements
        Built<GInboxData_inbox__asFeedbackRequest,
            GInboxData_inbox__asFeedbackRequestBuilder>,
        GInboxData_inbox {
  GInboxData_inbox__asFeedbackRequest._();

  factory GInboxData_inbox__asFeedbackRequest(
      [void Function(GInboxData_inbox__asFeedbackRequestBuilder b)
          updates]) = _$GInboxData_inbox__asFeedbackRequest;

  static void _initializeBuilder(
          GInboxData_inbox__asFeedbackRequestBuilder b) =>
      b..G__typename = 'FeedbackRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i3.GTime get createdAt;
  GInboxData_inbox__asFeedbackRequest_task get task;
  static Serializer<GInboxData_inbox__asFeedbackRequest> get serializer =>
      _$gInboxDataInboxAsFeedbackRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asFeedbackRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asFeedbackRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asFeedbackRequest.serializer,
        json,
      );
}

abstract class GInboxData_inbox__asFeedbackRequest_task
    implements
        Built<GInboxData_inbox__asFeedbackRequest_task,
            GInboxData_inbox__asFeedbackRequest_taskBuilder> {
  GInboxData_inbox__asFeedbackRequest_task._();

  factory GInboxData_inbox__asFeedbackRequest_task(
      [void Function(GInboxData_inbox__asFeedbackRequest_taskBuilder b)
          updates]) = _$GInboxData_inbox__asFeedbackRequest_task;

  static void _initializeBuilder(
          GInboxData_inbox__asFeedbackRequest_taskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  static Serializer<GInboxData_inbox__asFeedbackRequest_task> get serializer =>
      _$gInboxDataInboxAsFeedbackRequestTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxData_inbox__asFeedbackRequest_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxData_inbox__asFeedbackRequest_task? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxData_inbox__asFeedbackRequest_task.serializer,
        json,
      );
}
