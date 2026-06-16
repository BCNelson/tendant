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

part 'inbox.data.gql.g.dart';

abstract class GInboxFeedData
    implements Built<GInboxFeedData, GInboxFeedDataBuilder> {
  GInboxFeedData._();

  factory GInboxFeedData([void Function(GInboxFeedDataBuilder b) updates]) =
      _$GInboxFeedData;

  static void _initializeBuilder(GInboxFeedDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GInboxFeedData_inboxFeed get inboxFeed;
  static Serializer<GInboxFeedData> get serializer =>
      _$gInboxFeedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed
    implements
        Built<GInboxFeedData_inboxFeed, GInboxFeedData_inboxFeedBuilder> {
  GInboxFeedData_inboxFeed._();

  factory GInboxFeedData_inboxFeed(
          [void Function(GInboxFeedData_inboxFeedBuilder b) updates]) =
      _$GInboxFeedData_inboxFeed;

  static void _initializeBuilder(GInboxFeedData_inboxFeedBuilder b) =>
      b..G__typename = 'InboxFeedPage';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String? get nextCursor;
  BuiltList<GInboxFeedData_inboxFeed_entries> get entries;
  static Serializer<GInboxFeedData_inboxFeed> get serializer =>
      _$gInboxFeedDataInboxFeedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries
    implements
        Built<GInboxFeedData_inboxFeed_entries,
            GInboxFeedData_inboxFeed_entriesBuilder> {
  GInboxFeedData_inboxFeed_entries._();

  factory GInboxFeedData_inboxFeed_entries(
          [void Function(GInboxFeedData_inboxFeed_entriesBuilder b) updates]) =
      _$GInboxFeedData_inboxFeed_entries;

  static void _initializeBuilder(GInboxFeedData_inboxFeed_entriesBuilder b) =>
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
  GInboxFeedData_inboxFeed_entries_item get item;
  static Serializer<GInboxFeedData_inboxFeed_entries> get serializer =>
      _$gInboxFeedDataInboxFeedEntriesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxFeedData_inboxFeed_entries_item> get serializer =>
      _i3.InlineFragmentSerializer<GInboxFeedData_inboxFeed_entries_item>(
        'GInboxFeedData_inboxFeed_entries_item',
        GInboxFeedData_inboxFeed_entries_item__base,
        {
          'ActionableTask':
              GInboxFeedData_inboxFeed_entries_item__asActionableTask,
          'AgentAssignment':
              GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
          'ApprovalRequest':
              GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
          'AgentQuestion':
              GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
          'PromotionProposal':
              GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
          'FeedbackRequest':
              GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
        },
      );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__base
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__base,
            GInboxFeedData_inboxFeed_entries_item__baseBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__base._();

  factory GInboxFeedData_inboxFeed_entries_item__base(
      [void Function(GInboxFeedData_inboxFeed_entries_item__baseBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__base;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__baseBuilder b) =>
      b..G__typename = 'InboxItem';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__base>
      get serializer => _$gInboxFeedDataInboxFeedEntriesItemBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__base? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__base.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asActionableTask
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asActionableTask,
            GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asActionableTask._();

  factory GInboxFeedData_inboxFeed_entries_item__asActionableTask(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asActionableTask;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asActionableTaskBuilder b) =>
      b..G__typename = 'ActionableTask';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task get task;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asActionableTask>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsActionableTaskSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asActionableTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asActionableTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asActionableTask.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asActionableTask_task
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asActionableTask_task,
            GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder> {
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task._();

  factory GInboxFeedData_inboxFeed_entries_item__asActionableTask_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
                      b)
              updates]) =
      _$GInboxFeedData_inboxFeed_entries_item__asActionableTask_task;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asActionableTask_taskBuilder
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
          GInboxFeedData_inboxFeed_entries_item__asActionableTask_task>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsActionableTaskTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asActionableTask_task.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asActionableTask_task? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asActionableTask_task.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asAgentAssignment
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment._();

  factory GInboxFeedData_inboxFeed_entries_item__asAgentAssignment(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GChainStage get stage;
  String get ask;
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task get task;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsAgentAssignmentSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asAgentAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task,
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder> {
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task._();

  factory GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
                      b)
              updates]) =
      _$GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  static Serializer<
          GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsAgentAssignmentTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task
                .serializer,
            json,
          );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asApprovalRequest
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
            GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequest._();

  factory GInboxFeedData_inboxFeed_entries_item__asApprovalRequest(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asApprovalRequest;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asApprovalRequestBuilder b) =>
      b..G__typename = 'ApprovalRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asApprovalRequest>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsApprovalRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asApprovalRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asApprovalRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asApprovalRequest.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asAgentQuestion
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
            GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestion._();

  factory GInboxFeedData_inboxFeed_entries_item__asAgentQuestion(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asAgentQuestion;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asAgentQuestionBuilder b) =>
      b..G__typename = 'AgentQuestion';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get question;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asAgentQuestion>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsAgentQuestionSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asAgentQuestion.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asAgentQuestion? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asAgentQuestion.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asPromotionProposal
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
            GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposal._();

  factory GInboxFeedData_inboxFeed_entries_item__asPromotionProposal(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder
                  b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asPromotionProposal;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asPromotionProposalBuilder
              b) =>
      b..G__typename = 'PromotionProposal';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GAutonomyLevel get fromLevel;
  _i2.GAutonomyLevel get toLevel;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asPromotionProposal>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsPromotionProposalSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asPromotionProposal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asPromotionProposal? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asPromotionProposal.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder>,
        GInboxFeedData_inboxFeed_entries_item {
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest._();

  factory GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest(
      [void Function(
              GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder b)
          updates]) = _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequestBuilder b) =>
      b..G__typename = 'FeedbackRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task get task;
  static Serializer<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsFeedbackRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest.serializer,
        json,
      );
}

abstract class GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
    implements
        Built<GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task,
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder> {
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task._();

  factory GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task(
          [void Function(
                  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
                      b)
              updates]) =
      _$GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task;

  static void _initializeBuilder(
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_taskBuilder
              b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  static Serializer<
          GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task>
      get serializer =>
          _$gInboxFeedDataInboxFeedEntriesItemAsFeedbackRequestTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task
                .serializer,
            json,
          );
}
