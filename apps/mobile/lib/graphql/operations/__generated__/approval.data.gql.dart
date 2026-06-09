// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i4;
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i3;
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'approval.data.gql.g.dart';

abstract class GPendingDecisionData
    implements Built<GPendingDecisionData, GPendingDecisionDataBuilder> {
  GPendingDecisionData._();

  factory GPendingDecisionData(
          [void Function(GPendingDecisionDataBuilder b) updates]) =
      _$GPendingDecisionData;

  static void _initializeBuilder(GPendingDecisionDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GPendingDecisionData_pendingDecision? get pendingDecision;
  static Serializer<GPendingDecisionData> get serializer =>
      _$gPendingDecisionDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime get createdAt;
  static Serializer<GPendingDecisionData_pendingDecision> get serializer =>
      _i3.InlineFragmentSerializer<GPendingDecisionData_pendingDecision>(
        'GPendingDecisionData_pendingDecision',
        GPendingDecisionData_pendingDecision__base,
        {
          'ApprovalRequest':
              GPendingDecisionData_pendingDecision__asApprovalRequest,
          'AgentQuestion':
              GPendingDecisionData_pendingDecision__asAgentQuestion,
        },
      );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision__base
    implements
        Built<GPendingDecisionData_pendingDecision__base,
            GPendingDecisionData_pendingDecision__baseBuilder>,
        GPendingDecisionData_pendingDecision {
  GPendingDecisionData_pendingDecision__base._();

  factory GPendingDecisionData_pendingDecision__base(
      [void Function(GPendingDecisionData_pendingDecision__baseBuilder b)
          updates]) = _$GPendingDecisionData_pendingDecision__base;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__baseBuilder b) =>
      b..G__typename = 'PendingDecision';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  _i2.GTime get createdAt;
  static Serializer<GPendingDecisionData_pendingDecision__base>
      get serializer => _$gPendingDecisionDataPendingDecisionBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__base.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__base? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision__base.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest
    implements
        Built<GPendingDecisionData_pendingDecision__asApprovalRequest,
            GPendingDecisionData_pendingDecision__asApprovalRequestBuilder>,
        GPendingDecisionData_pendingDecision {
  GPendingDecisionData_pendingDecision__asApprovalRequest._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest(
      [void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequestBuilder b)
          updates]) = _$GPendingDecisionData_pendingDecision__asApprovalRequest;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequestBuilder b) =>
      b..G__typename = 'ApprovalRequest';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  _i2.GTime get createdAt;
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool get tool;
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload get payload;
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation?
      get overseerEvaluation;
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation?
      get gateScriptEvaluation;
  static Serializer<GPendingDecisionData_pendingDecision__asApprovalRequest>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_tool
    implements
        Built<GPendingDecisionData_pendingDecision__asApprovalRequest_tool,
            GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder> {
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_tool(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
              b) =>
      b..G__typename = 'Tool';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  String get globalUri;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_tool>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestToolSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_tool.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_tool? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_tool.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_payload {
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload>
      get serializer => _i3.InlineFragmentSerializer<
              GPendingDecisionData_pendingDecision__asApprovalRequest_payload>(
            'GPendingDecisionData_pendingDecision__asApprovalRequest_payload',
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
            {
              'Artifact':
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
              'Mandate':
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
            },
          );

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_payload?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
    implements
        Built<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder>,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload {
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder
              b) =>
      b..G__typename = 'ApprovalPayload';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadBaseSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
    implements
        Built<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder>,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload {
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder
              b) =>
      b..G__typename = 'Artifact';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get kind;
  _i4.JsonObject get content;
  String? get recipient;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadAsArtifactSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
    implements
        Built<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder>,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload {
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder
              b) =>
      b..G__typename = 'Mandate';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get goal;
  _i4.JsonObject get constraints;
  _i4.JsonObject get guardrails;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadAsMandateSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
    implements
        Built<
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation,
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder> {
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
              b) =>
      b..G__typename = 'OverseerEvaluation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get verdict;
  String get summary;
  BuiltList<String> get consideredFields;
  String get modelId;
  String get provider;
  int get tokensIn;
  int get tokensOut;
  double get estimatedCostUsd;
  _i2.GTime get at;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestOverseerEvaluationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
    implements
        Built<
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation,
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder> {
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation._();

  factory GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
                      b)
              updates]) =
      _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
              b) =>
      b..G__typename = 'GateScriptEvaluation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get verdict;
  String get summary;
  BuiltList<String> get consideredFields;
  BuiltList<String> get hostcallTrace;
  int get scriptVersion;
  _i2.GTime get at;
  static Serializer<
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsApprovalRequestGateScriptEvaluationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
                .serializer,
            json,
          );
}

abstract class GPendingDecisionData_pendingDecision__asAgentQuestion
    implements
        Built<GPendingDecisionData_pendingDecision__asAgentQuestion,
            GPendingDecisionData_pendingDecision__asAgentQuestionBuilder>,
        GPendingDecisionData_pendingDecision {
  GPendingDecisionData_pendingDecision__asAgentQuestion._();

  factory GPendingDecisionData_pendingDecision__asAgentQuestion(
      [void Function(
              GPendingDecisionData_pendingDecision__asAgentQuestionBuilder b)
          updates]) = _$GPendingDecisionData_pendingDecision__asAgentQuestion;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asAgentQuestionBuilder b) =>
      b..G__typename = 'AgentQuestion';

  @override
  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  @override
  String get id;
  @override
  _i2.GTime get createdAt;
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker get asker;
  String get question;
  String? get disclosureClass;
  static Serializer<GPendingDecisionData_pendingDecision__asAgentQuestion>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsAgentQuestionSerializer;

  @override
  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asAgentQuestion.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asAgentQuestion? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision__asAgentQuestion.serializer,
        json,
      );
}

abstract class GPendingDecisionData_pendingDecision__asAgentQuestion_asker
    implements
        Built<GPendingDecisionData_pendingDecision__asAgentQuestion_asker,
            GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder> {
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker._();

  factory GPendingDecisionData_pendingDecision__asAgentQuestion_asker(
      [void Function(
              GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
                  b)
          updates]) = _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker;

  static void _initializeBuilder(
          GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
              b) =>
      b..G__typename = 'Principal';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get displayName;
  static Serializer<GPendingDecisionData_pendingDecision__asAgentQuestion_asker>
      get serializer =>
          _$gPendingDecisionDataPendingDecisionAsAgentQuestionAskerSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionData_pendingDecision__asAgentQuestion_asker.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionData_pendingDecision__asAgentQuestion_asker? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionData_pendingDecision__asAgentQuestion_asker.serializer,
        json,
      );
}

abstract class GApproveArtifactData
    implements Built<GApproveArtifactData, GApproveArtifactDataBuilder> {
  GApproveArtifactData._();

  factory GApproveArtifactData(
          [void Function(GApproveArtifactDataBuilder b) updates]) =
      _$GApproveArtifactData;

  static void _initializeBuilder(GApproveArtifactDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GApproveArtifactData_approveArtifact get approveArtifact;
  static Serializer<GApproveArtifactData> get serializer =>
      _$gApproveArtifactDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GApproveArtifactData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GApproveArtifactData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GApproveArtifactData.serializer,
        json,
      );
}

abstract class GApproveArtifactData_approveArtifact
    implements
        Built<GApproveArtifactData_approveArtifact,
            GApproveArtifactData_approveArtifactBuilder> {
  GApproveArtifactData_approveArtifact._();

  factory GApproveArtifactData_approveArtifact(
      [void Function(GApproveArtifactData_approveArtifactBuilder b)
          updates]) = _$GApproveArtifactData_approveArtifact;

  static void _initializeBuilder(
          GApproveArtifactData_approveArtifactBuilder b) =>
      b..G__typename = 'PendingDecision';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GApproveArtifactData_approveArtifact> get serializer =>
      _$gApproveArtifactDataApproveArtifactSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GApproveArtifactData_approveArtifact.serializer,
        this,
      ) as Map<String, dynamic>);

  static GApproveArtifactData_approveArtifact? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GApproveArtifactData_approveArtifact.serializer,
        json,
      );
}

abstract class GRejectApprovalData
    implements Built<GRejectApprovalData, GRejectApprovalDataBuilder> {
  GRejectApprovalData._();

  factory GRejectApprovalData(
          [void Function(GRejectApprovalDataBuilder b) updates]) =
      _$GRejectApprovalData;

  static void _initializeBuilder(GRejectApprovalDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRejectApprovalData_rejectApproval get rejectApproval;
  static Serializer<GRejectApprovalData> get serializer =>
      _$gRejectApprovalDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRejectApprovalData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRejectApprovalData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRejectApprovalData.serializer,
        json,
      );
}

abstract class GRejectApprovalData_rejectApproval
    implements
        Built<GRejectApprovalData_rejectApproval,
            GRejectApprovalData_rejectApprovalBuilder> {
  GRejectApprovalData_rejectApproval._();

  factory GRejectApprovalData_rejectApproval(
      [void Function(GRejectApprovalData_rejectApprovalBuilder b)
          updates]) = _$GRejectApprovalData_rejectApproval;

  static void _initializeBuilder(GRejectApprovalData_rejectApprovalBuilder b) =>
      b..G__typename = 'PendingDecision';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GRejectApprovalData_rejectApproval> get serializer =>
      _$gRejectApprovalDataRejectApprovalSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRejectApprovalData_rejectApproval.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRejectApprovalData_rejectApproval? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRejectApprovalData_rejectApproval.serializer,
        json,
      );
}

abstract class GAnswerQuestionData
    implements Built<GAnswerQuestionData, GAnswerQuestionDataBuilder> {
  GAnswerQuestionData._();

  factory GAnswerQuestionData(
          [void Function(GAnswerQuestionDataBuilder b) updates]) =
      _$GAnswerQuestionData;

  static void _initializeBuilder(GAnswerQuestionDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GAnswerQuestionData_answerQuestion get answerQuestion;
  static Serializer<GAnswerQuestionData> get serializer =>
      _$gAnswerQuestionDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAnswerQuestionData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAnswerQuestionData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAnswerQuestionData.serializer,
        json,
      );
}

abstract class GAnswerQuestionData_answerQuestion
    implements
        Built<GAnswerQuestionData_answerQuestion,
            GAnswerQuestionData_answerQuestionBuilder> {
  GAnswerQuestionData_answerQuestion._();

  factory GAnswerQuestionData_answerQuestion(
      [void Function(GAnswerQuestionData_answerQuestionBuilder b)
          updates]) = _$GAnswerQuestionData_answerQuestion;

  static void _initializeBuilder(GAnswerQuestionData_answerQuestionBuilder b) =>
      b..G__typename = 'PendingDecision';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GAnswerQuestionData_answerQuestion> get serializer =>
      _$gAnswerQuestionDataAnswerQuestionSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAnswerQuestionData_answerQuestion.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAnswerQuestionData_answerQuestion? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAnswerQuestionData_answerQuestion.serializer,
        json,
      );
}
