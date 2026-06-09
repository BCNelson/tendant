// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/tasks.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/tasks.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/tasks.var.gql.dart'
    as _i3;

part 'tasks.req.gql.g.dart';

abstract class GTasksReq
    implements
        Built<GTasksReq, GTasksReqBuilder>,
        _i1.OperationRequest<_i2.GTasksData, _i3.GTasksVars> {
  GTasksReq._();

  factory GTasksReq([void Function(GTasksReqBuilder b) updates]) = _$GTasksReq;

  static void _initializeBuilder(GTasksReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'Tasks',
    )
    ..executeOnListen = true;

  @override
  _i3.GTasksVars get vars;
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
  _i2.GTasksData? Function(
    _i2.GTasksData?,
    _i2.GTasksData?,
  )? get updateResult;
  @override
  _i2.GTasksData? get optimisticResponse;
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
  _i2.GTasksData? parseData(Map<String, dynamic> json) =>
      _i2.GTasksData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GTasksData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GTasksData, _i3.GTasksVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GTasksReq> get serializer => _$gTasksReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GTasksReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GTasksReq.serializer,
        json,
      );
}
