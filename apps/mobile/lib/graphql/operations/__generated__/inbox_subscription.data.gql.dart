// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_subscription.data.gql.g.dart';

abstract class GInboxItemArrivedData
    implements Built<GInboxItemArrivedData, GInboxItemArrivedDataBuilder> {
  GInboxItemArrivedData._();

  factory GInboxItemArrivedData(
          [void Function(GInboxItemArrivedDataBuilder b) updates]) =
      _$GInboxItemArrivedData;

  static void _initializeBuilder(GInboxItemArrivedDataBuilder b) =>
      b..G__typename = 'Subscription';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GInboxItemArrivedData_inboxItemArrived get inboxItemArrived;
  static Serializer<GInboxItemArrivedData> get serializer =>
      _$gInboxItemArrivedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxItemArrivedData_inboxItemArrived> get serializer =>
      _i2.InlineFragmentSerializer<GInboxItemArrivedData_inboxItemArrived>(
        'GInboxItemArrivedData_inboxItemArrived',
        GInboxItemArrivedData_inboxItemArrived__base,
        {
          'AgentAssignment':
              GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
          'ApprovalRequest':
              GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
          'AgentQuestion':
              GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
          'PromotionProposal':
              GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
          'FeedbackRequest':
              GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest,
        },
      );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__base
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__base,
            GInboxItemArrivedData_inboxItemArrived__baseBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__base._();

  factory GInboxItemArrivedData_inboxItemArrived__base(
      [void Function(GInboxItemArrivedData_inboxItemArrived__baseBuilder b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__base;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__baseBuilder b) =>
      b..G__typename = 'InboxItem';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__base>
      get serializer => _$gInboxItemArrivedDataInboxItemArrivedBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__base? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__base.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__asAgentAssignment
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
            GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignment._();

  factory GInboxItemArrivedData_inboxItemArrived__asAgentAssignment(
      [void Function(
              GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder
                  b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__asAgentAssignment;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__asAgentAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__asAgentAssignment>
      get serializer =>
          _$gInboxItemArrivedDataInboxItemArrivedAsAgentAssignmentSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__asAgentAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__asAgentAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__asAgentAssignment.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__asApprovalRequest
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
            GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequest._();

  factory GInboxItemArrivedData_inboxItemArrived__asApprovalRequest(
      [void Function(
              GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder
                  b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__asApprovalRequest;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__asApprovalRequestBuilder b) =>
      b..G__typename = 'ApprovalRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__asApprovalRequest>
      get serializer =>
          _$gInboxItemArrivedDataInboxItemArrivedAsApprovalRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__asApprovalRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__asApprovalRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__asApprovalRequest.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__asAgentQuestion
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
            GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestion._();

  factory GInboxItemArrivedData_inboxItemArrived__asAgentQuestion(
      [void Function(
              GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__asAgentQuestion;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__asAgentQuestionBuilder b) =>
      b..G__typename = 'AgentQuestion';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__asAgentQuestion>
      get serializer =>
          _$gInboxItemArrivedDataInboxItemArrivedAsAgentQuestionSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__asAgentQuestion.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__asAgentQuestion? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__asAgentQuestion.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__asPromotionProposal
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
            GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposal._();

  factory GInboxItemArrivedData_inboxItemArrived__asPromotionProposal(
      [void Function(
              GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder
                  b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__asPromotionProposal;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__asPromotionProposalBuilder
              b) =>
      b..G__typename = 'PromotionProposal';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__asPromotionProposal>
      get serializer =>
          _$gInboxItemArrivedDataInboxItemArrivedAsPromotionProposalSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__asPromotionProposal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__asPromotionProposal? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__asPromotionProposal.serializer,
        json,
      );
}

abstract class GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest
    implements
        Built<GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest,
            GInboxItemArrivedData_inboxItemArrived__asFeedbackRequestBuilder>,
        GInboxItemArrivedData_inboxItemArrived {
  GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest._();

  factory GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest(
      [void Function(
              GInboxItemArrivedData_inboxItemArrived__asFeedbackRequestBuilder
                  b)
          updates]) = _$GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest;

  static void _initializeBuilder(
          GInboxItemArrivedData_inboxItemArrived__asFeedbackRequestBuilder b) =>
      b..G__typename = 'FeedbackRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest>
      get serializer =>
          _$gInboxItemArrivedDataInboxItemArrivedAsFeedbackRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest.serializer,
        json,
      );
}
