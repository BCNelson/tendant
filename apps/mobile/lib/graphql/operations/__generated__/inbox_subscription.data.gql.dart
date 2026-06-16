// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i3;
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_subscription.data.gql.g.dart';

abstract class GInboxEntryArrivedData
    implements Built<GInboxEntryArrivedData, GInboxEntryArrivedDataBuilder> {
  GInboxEntryArrivedData._();

  factory GInboxEntryArrivedData(
          [void Function(GInboxEntryArrivedDataBuilder b) updates]) =
      _$GInboxEntryArrivedData;

  static void _initializeBuilder(GInboxEntryArrivedDataBuilder b) =>
      b..G__typename = 'Subscription';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GInboxEntryArrivedData_inboxEntryArrived get inboxEntryArrived;
  static Serializer<GInboxEntryArrivedData> get serializer =>
      _$gInboxEntryArrivedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived,
            GInboxEntryArrivedData_inboxEntryArrivedBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived._();

  factory GInboxEntryArrivedData_inboxEntryArrived(
      [void Function(GInboxEntryArrivedData_inboxEntryArrivedBuilder b)
          updates]) = _$GInboxEntryArrivedData_inboxEntryArrived;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrivedBuilder b) =>
      b..G__typename = 'InboxEntry';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get kind;
  String get messageType;
  double get urgency;
  _i2.GTime get createdAt;
  _i2.GTime? get readAt;
  _i2.GTime? get dismissedAt;
  GInboxEntryArrivedData_inboxEntryArrived_item get item;
  static Serializer<GInboxEntryArrivedData_inboxEntryArrived> get serializer =>
      _$gInboxEntryArrivedDataInboxEntryArrivedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData_inboxEntryArrived.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxEntryArrivedData_inboxEntryArrived_item>
      get serializer => _i3.InlineFragmentSerializer<
              GInboxEntryArrivedData_inboxEntryArrived_item>(
            'GInboxEntryArrivedData_inboxEntryArrived_item',
            GInboxEntryArrivedData_inboxEntryArrived_item__base,
            {
              'ActionableTask':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
              'AgentAssignment':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
              'ApprovalRequest':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
              'AgentQuestion':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
              'PromotionProposal':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
              'FeedbackRequest':
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
            },
          );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__base
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__base,
            GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__base._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__base(
      [void Function(
              GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder b)
          updates]) = _$GInboxEntryArrivedData_inboxEntryArrived_item__base;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__baseBuilder b) =>
      b..G__typename = 'InboxItem';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxEntryArrivedData_inboxEntryArrived_item__base>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__base? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__base.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTaskBuilder
              b) =>
      b..G__typename = 'ActionableTask';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task get task;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsActionableTaskSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
    implements
        Built<
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  _i2.GTaskState get state;
  _i2.GTaskPriority get priority;
  _i2.GTime? get dueAt;
  _i2.GChainStage get currentStage;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsActionableTaskTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignmentBuilder
              b) =>
      b..G__typename = 'AgentAssignment';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GChainStage get stage;
  String get ask;
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
      get task;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentAssignmentSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
    implements
        Built<
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentAssignmentTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
            GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequestBuilder
              b) =>
      b..G__typename = 'ApprovalRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsApprovalRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestionBuilder
              b) =>
      b..G__typename = 'AgentQuestion';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get question;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsAgentQuestionSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
    implements
        Built<
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposalBuilder
              b) =>
      b..G__typename = 'PromotionProposal';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GAutonomyLevel get fromLevel;
  _i2.GAutonomyLevel get toLevel;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsPromotionProposalSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder>,
        GInboxEntryArrivedData_inboxEntryArrived_item {
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequestBuilder
              b) =>
      b..G__typename = 'FeedbackRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
      get task;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsFeedbackRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest
                .serializer,
            json,
          );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
    implements
        Built<
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task,
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task(
          [void Function(
                  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
                      b)
              updates]) =
      _$GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  static Serializer<
          GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task>
      get serializer =>
          _$gInboxEntryArrivedDataInboxEntryArrivedItemAsFeedbackRequestTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task
                .serializer,
            json,
          );
}
