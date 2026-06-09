// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/task_detail.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/task_detail.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/task_detail.var.gql.dart'
    as _i3;

part 'task_detail.req.gql.g.dart';

abstract class GTaskDetailReq
    implements
        Built<GTaskDetailReq, GTaskDetailReqBuilder>,
        _i1.OperationRequest<_i2.GTaskDetailData, _i3.GTaskDetailVars> {
  GTaskDetailReq._();

  factory GTaskDetailReq([void Function(GTaskDetailReqBuilder b) updates]) =
      _$GTaskDetailReq;

  static void _initializeBuilder(GTaskDetailReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'TaskDetail',
    )
    ..executeOnListen = true;

  @override
  _i3.GTaskDetailVars get vars;
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
  _i2.GTaskDetailData? Function(
    _i2.GTaskDetailData?,
    _i2.GTaskDetailData?,
  )? get updateResult;
  @override
  _i2.GTaskDetailData? get optimisticResponse;
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
  _i2.GTaskDetailData? parseData(Map<String, dynamic> json) =>
      _i2.GTaskDetailData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GTaskDetailData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GTaskDetailData, _i3.GTaskDetailVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GTaskDetailReq> get serializer =>
      _$gTaskDetailReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GTaskDetailReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GTaskDetailReq.serializer,
        json,
      );
}
