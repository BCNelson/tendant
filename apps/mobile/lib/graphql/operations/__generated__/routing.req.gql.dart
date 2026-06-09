// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/routing.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/routing.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/routing.var.gql.dart'
    as _i3;

part 'routing.req.gql.g.dart';

abstract class GTaskStageSlotsReq
    implements
        Built<GTaskStageSlotsReq, GTaskStageSlotsReqBuilder>,
        _i1.OperationRequest<_i2.GTaskStageSlotsData, _i3.GTaskStageSlotsVars> {
  GTaskStageSlotsReq._();

  factory GTaskStageSlotsReq(
          [void Function(GTaskStageSlotsReqBuilder b) updates]) =
      _$GTaskStageSlotsReq;

  static void _initializeBuilder(GTaskStageSlotsReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'TaskStageSlots',
    )
    ..executeOnListen = true;

  @override
  _i3.GTaskStageSlotsVars get vars;
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
  _i2.GTaskStageSlotsData? Function(
    _i2.GTaskStageSlotsData?,
    _i2.GTaskStageSlotsData?,
  )? get updateResult;
  @override
  _i2.GTaskStageSlotsData? get optimisticResponse;
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
  _i2.GTaskStageSlotsData? parseData(Map<String, dynamic> json) =>
      _i2.GTaskStageSlotsData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GTaskStageSlotsData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GTaskStageSlotsData, _i3.GTaskStageSlotsVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GTaskStageSlotsReq> get serializer =>
      _$gTaskStageSlotsReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GTaskStageSlotsReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GTaskStageSlotsReq.serializer,
        json,
      );
}

abstract class GAgentConfigsReq
    implements
        Built<GAgentConfigsReq, GAgentConfigsReqBuilder>,
        _i1.OperationRequest<_i2.GAgentConfigsData, _i3.GAgentConfigsVars> {
  GAgentConfigsReq._();

  factory GAgentConfigsReq([void Function(GAgentConfigsReqBuilder b) updates]) =
      _$GAgentConfigsReq;

  static void _initializeBuilder(GAgentConfigsReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'AgentConfigs',
    )
    ..executeOnListen = true;

  @override
  _i3.GAgentConfigsVars get vars;
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
  _i2.GAgentConfigsData? Function(
    _i2.GAgentConfigsData?,
    _i2.GAgentConfigsData?,
  )? get updateResult;
  @override
  _i2.GAgentConfigsData? get optimisticResponse;
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
  _i2.GAgentConfigsData? parseData(Map<String, dynamic> json) =>
      _i2.GAgentConfigsData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GAgentConfigsData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GAgentConfigsData, _i3.GAgentConfigsVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GAgentConfigsReq> get serializer =>
      _$gAgentConfigsReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GAgentConfigsReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentConfigsReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GAgentConfigsReq.serializer,
        json,
      );
}
