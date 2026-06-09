// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.var.gql.dart'
    as _i3;

part 'task_changed_subscription.req.gql.g.dart';

abstract class GTaskChangedReq
    implements
        Built<GTaskChangedReq, GTaskChangedReqBuilder>,
        _i1.OperationRequest<_i2.GTaskChangedData, _i3.GTaskChangedVars> {
  GTaskChangedReq._();

  factory GTaskChangedReq([void Function(GTaskChangedReqBuilder b) updates]) =
      _$GTaskChangedReq;

  static void _initializeBuilder(GTaskChangedReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'TaskChanged',
    )
    ..executeOnListen = true;

  @override
  _i3.GTaskChangedVars get vars;
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
  _i2.GTaskChangedData? Function(
    _i2.GTaskChangedData?,
    _i2.GTaskChangedData?,
  )? get updateResult;
  @override
  _i2.GTaskChangedData? get optimisticResponse;
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
  _i2.GTaskChangedData? parseData(Map<String, dynamic> json) =>
      _i2.GTaskChangedData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GTaskChangedData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GTaskChangedData, _i3.GTaskChangedVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GTaskChangedReq> get serializer =>
      _$gTaskChangedReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GTaskChangedReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GTaskChangedReq.serializer,
        json,
      );
}
