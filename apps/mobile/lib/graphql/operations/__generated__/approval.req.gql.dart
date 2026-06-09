// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/approval.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/approval.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/approval.var.gql.dart'
    as _i3;

part 'approval.req.gql.g.dart';

abstract class GPendingDecisionReq
    implements
        Built<GPendingDecisionReq, GPendingDecisionReqBuilder>,
        _i1
        .OperationRequest<_i2.GPendingDecisionData, _i3.GPendingDecisionVars> {
  GPendingDecisionReq._();

  factory GPendingDecisionReq(
          [void Function(GPendingDecisionReqBuilder b) updates]) =
      _$GPendingDecisionReq;

  static void _initializeBuilder(GPendingDecisionReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'PendingDecision',
    )
    ..executeOnListen = true;

  @override
  _i3.GPendingDecisionVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GPendingDecisionData? Function(
    _i2.GPendingDecisionData?,
    _i2.GPendingDecisionData?,
  )? get updateResult;
  @override
  _i2.GPendingDecisionData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GPendingDecisionData? parseData(Map<String, dynamic> json) =>
      _i2.GPendingDecisionData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GPendingDecisionData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GPendingDecisionData, _i3.GPendingDecisionVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GPendingDecisionReq> get serializer =>
      _$gPendingDecisionReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GPendingDecisionReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GPendingDecisionReq.serializer,
        json,
      );
}

abstract class GApproveArtifactReq
    implements
        Built<GApproveArtifactReq, GApproveArtifactReqBuilder>,
        _i1
        .OperationRequest<_i2.GApproveArtifactData, _i3.GApproveArtifactVars> {
  GApproveArtifactReq._();

  factory GApproveArtifactReq(
          [void Function(GApproveArtifactReqBuilder b) updates]) =
      _$GApproveArtifactReq;

  static void _initializeBuilder(GApproveArtifactReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'ApproveArtifact',
    )
    ..executeOnListen = true;

  @override
  _i3.GApproveArtifactVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GApproveArtifactData? Function(
    _i2.GApproveArtifactData?,
    _i2.GApproveArtifactData?,
  )? get updateResult;
  @override
  _i2.GApproveArtifactData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GApproveArtifactData? parseData(Map<String, dynamic> json) =>
      _i2.GApproveArtifactData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GApproveArtifactData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GApproveArtifactData, _i3.GApproveArtifactVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GApproveArtifactReq> get serializer =>
      _$gApproveArtifactReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GApproveArtifactReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GApproveArtifactReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GApproveArtifactReq.serializer,
        json,
      );
}

abstract class GRejectApprovalReq
    implements
        Built<GRejectApprovalReq, GRejectApprovalReqBuilder>,
        _i1.OperationRequest<_i2.GRejectApprovalData, _i3.GRejectApprovalVars> {
  GRejectApprovalReq._();

  factory GRejectApprovalReq(
          [void Function(GRejectApprovalReqBuilder b) updates]) =
      _$GRejectApprovalReq;

  static void _initializeBuilder(GRejectApprovalReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RejectApproval',
    )
    ..executeOnListen = true;

  @override
  _i3.GRejectApprovalVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GRejectApprovalData? Function(
    _i2.GRejectApprovalData?,
    _i2.GRejectApprovalData?,
  )? get updateResult;
  @override
  _i2.GRejectApprovalData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GRejectApprovalData? parseData(Map<String, dynamic> json) =>
      _i2.GRejectApprovalData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GRejectApprovalData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRejectApprovalData, _i3.GRejectApprovalVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRejectApprovalReq> get serializer =>
      _$gRejectApprovalReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRejectApprovalReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRejectApprovalReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRejectApprovalReq.serializer,
        json,
      );
}

abstract class GAnswerQuestionReq
    implements
        Built<GAnswerQuestionReq, GAnswerQuestionReqBuilder>,
        _i1.OperationRequest<_i2.GAnswerQuestionData, _i3.GAnswerQuestionVars> {
  GAnswerQuestionReq._();

  factory GAnswerQuestionReq(
          [void Function(GAnswerQuestionReqBuilder b) updates]) =
      _$GAnswerQuestionReq;

  static void _initializeBuilder(GAnswerQuestionReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'AnswerQuestion',
    )
    ..executeOnListen = true;

  @override
  _i3.GAnswerQuestionVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GAnswerQuestionData? Function(
    _i2.GAnswerQuestionData?,
    _i2.GAnswerQuestionData?,
  )? get updateResult;
  @override
  _i2.GAnswerQuestionData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GAnswerQuestionData? parseData(Map<String, dynamic> json) =>
      _i2.GAnswerQuestionData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GAnswerQuestionData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GAnswerQuestionData, _i3.GAnswerQuestionVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GAnswerQuestionReq> get serializer =>
      _$gAnswerQuestionReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GAnswerQuestionReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAnswerQuestionReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GAnswerQuestionReq.serializer,
        json,
      );
}
