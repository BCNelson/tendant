// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/feedback.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/feedback.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/feedback.var.gql.dart'
    as _i3;

part 'feedback.req.gql.g.dart';

abstract class GFeedbackRequestReq
    implements
        Built<GFeedbackRequestReq, GFeedbackRequestReqBuilder>,
        _i1
        .OperationRequest<_i2.GFeedbackRequestData, _i3.GFeedbackRequestVars> {
  GFeedbackRequestReq._();

  factory GFeedbackRequestReq(
          [void Function(GFeedbackRequestReqBuilder b) updates]) =
      _$GFeedbackRequestReq;

  static void _initializeBuilder(GFeedbackRequestReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'FeedbackRequest',
    )
    ..executeOnListen = true;

  @override
  _i3.GFeedbackRequestVars get vars;
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
  _i2.GFeedbackRequestData? Function(
    _i2.GFeedbackRequestData?,
    _i2.GFeedbackRequestData?,
  )? get updateResult;
  @override
  _i2.GFeedbackRequestData? get optimisticResponse;
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
  _i2.GFeedbackRequestData? parseData(Map<String, dynamic> json) =>
      _i2.GFeedbackRequestData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GFeedbackRequestData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GFeedbackRequestData, _i3.GFeedbackRequestVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GFeedbackRequestReq> get serializer =>
      _$gFeedbackRequestReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GFeedbackRequestReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GFeedbackRequestReq.serializer,
        json,
      );
}

abstract class GSendFeedbackMessageReq
    implements
        Built<GSendFeedbackMessageReq, GSendFeedbackMessageReqBuilder>,
        _i1.OperationRequest<_i2.GSendFeedbackMessageData,
            _i3.GSendFeedbackMessageVars> {
  GSendFeedbackMessageReq._();

  factory GSendFeedbackMessageReq(
          [void Function(GSendFeedbackMessageReqBuilder b) updates]) =
      _$GSendFeedbackMessageReq;

  static void _initializeBuilder(GSendFeedbackMessageReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SendFeedbackMessage',
    )
    ..executeOnListen = true;

  @override
  _i3.GSendFeedbackMessageVars get vars;
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
  _i2.GSendFeedbackMessageData? Function(
    _i2.GSendFeedbackMessageData?,
    _i2.GSendFeedbackMessageData?,
  )? get updateResult;
  @override
  _i2.GSendFeedbackMessageData? get optimisticResponse;
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
  _i2.GSendFeedbackMessageData? parseData(Map<String, dynamic> json) =>
      _i2.GSendFeedbackMessageData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSendFeedbackMessageData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GSendFeedbackMessageData,
      _i3.GSendFeedbackMessageVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSendFeedbackMessageReq> get serializer =>
      _$gSendFeedbackMessageReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSendFeedbackMessageReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendFeedbackMessageReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSendFeedbackMessageReq.serializer,
        json,
      );
}

abstract class GAcceptFeedbackGuidanceReq
    implements
        Built<GAcceptFeedbackGuidanceReq, GAcceptFeedbackGuidanceReqBuilder>,
        _i1.OperationRequest<_i2.GAcceptFeedbackGuidanceData,
            _i3.GAcceptFeedbackGuidanceVars> {
  GAcceptFeedbackGuidanceReq._();

  factory GAcceptFeedbackGuidanceReq(
          [void Function(GAcceptFeedbackGuidanceReqBuilder b) updates]) =
      _$GAcceptFeedbackGuidanceReq;

  static void _initializeBuilder(GAcceptFeedbackGuidanceReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'AcceptFeedbackGuidance',
    )
    ..executeOnListen = true;

  @override
  _i3.GAcceptFeedbackGuidanceVars get vars;
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
  _i2.GAcceptFeedbackGuidanceData? Function(
    _i2.GAcceptFeedbackGuidanceData?,
    _i2.GAcceptFeedbackGuidanceData?,
  )? get updateResult;
  @override
  _i2.GAcceptFeedbackGuidanceData? get optimisticResponse;
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
  _i2.GAcceptFeedbackGuidanceData? parseData(Map<String, dynamic> json) =>
      _i2.GAcceptFeedbackGuidanceData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GAcceptFeedbackGuidanceData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GAcceptFeedbackGuidanceData,
      _i3.GAcceptFeedbackGuidanceVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GAcceptFeedbackGuidanceReq> get serializer =>
      _$gAcceptFeedbackGuidanceReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GAcceptFeedbackGuidanceReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptFeedbackGuidanceReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GAcceptFeedbackGuidanceReq.serializer,
        json,
      );
}

abstract class GDismissFeedbackReq
    implements
        Built<GDismissFeedbackReq, GDismissFeedbackReqBuilder>,
        _i1
        .OperationRequest<_i2.GDismissFeedbackData, _i3.GDismissFeedbackVars> {
  GDismissFeedbackReq._();

  factory GDismissFeedbackReq(
          [void Function(GDismissFeedbackReqBuilder b) updates]) =
      _$GDismissFeedbackReq;

  static void _initializeBuilder(GDismissFeedbackReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'DismissFeedback',
    )
    ..executeOnListen = true;

  @override
  _i3.GDismissFeedbackVars get vars;
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
  _i2.GDismissFeedbackData? Function(
    _i2.GDismissFeedbackData?,
    _i2.GDismissFeedbackData?,
  )? get updateResult;
  @override
  _i2.GDismissFeedbackData? get optimisticResponse;
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
  _i2.GDismissFeedbackData? parseData(Map<String, dynamic> json) =>
      _i2.GDismissFeedbackData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GDismissFeedbackData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GDismissFeedbackData, _i3.GDismissFeedbackVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GDismissFeedbackReq> get serializer =>
      _$gDismissFeedbackReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GDismissFeedbackReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissFeedbackReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GDismissFeedbackReq.serializer,
        json,
      );
}
