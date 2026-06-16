// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/task_relations.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/task_relations.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/task_relations.var.gql.dart'
    as _i3;

part 'task_relations.req.gql.g.dart';

abstract class GAddTaskRelationReq
    implements
        Built<GAddTaskRelationReq, GAddTaskRelationReqBuilder>,
        _i1
        .OperationRequest<_i2.GAddTaskRelationData, _i3.GAddTaskRelationVars> {
  GAddTaskRelationReq._();

  factory GAddTaskRelationReq(
          [void Function(GAddTaskRelationReqBuilder b) updates]) =
      _$GAddTaskRelationReq;

  static void _initializeBuilder(GAddTaskRelationReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'AddTaskRelation',
    )
    ..executeOnListen = true;

  @override
  _i3.GAddTaskRelationVars get vars;
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
  _i2.GAddTaskRelationData? Function(
    _i2.GAddTaskRelationData?,
    _i2.GAddTaskRelationData?,
  )? get updateResult;
  @override
  _i2.GAddTaskRelationData? get optimisticResponse;
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
  _i2.GAddTaskRelationData? parseData(Map<String, dynamic> json) =>
      _i2.GAddTaskRelationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GAddTaskRelationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GAddTaskRelationData, _i3.GAddTaskRelationVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GAddTaskRelationReq> get serializer =>
      _$gAddTaskRelationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GAddTaskRelationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GAddTaskRelationReq.serializer,
        json,
      );
}

abstract class GRemoveTaskRelationReq
    implements
        Built<GRemoveTaskRelationReq, GRemoveTaskRelationReqBuilder>,
        _i1.OperationRequest<_i2.GRemoveTaskRelationData,
            _i3.GRemoveTaskRelationVars> {
  GRemoveTaskRelationReq._();

  factory GRemoveTaskRelationReq(
          [void Function(GRemoveTaskRelationReqBuilder b) updates]) =
      _$GRemoveTaskRelationReq;

  static void _initializeBuilder(GRemoveTaskRelationReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RemoveTaskRelation',
    )
    ..executeOnListen = true;

  @override
  _i3.GRemoveTaskRelationVars get vars;
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
  _i2.GRemoveTaskRelationData? Function(
    _i2.GRemoveTaskRelationData?,
    _i2.GRemoveTaskRelationData?,
  )? get updateResult;
  @override
  _i2.GRemoveTaskRelationData? get optimisticResponse;
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
  _i2.GRemoveTaskRelationData? parseData(Map<String, dynamic> json) =>
      _i2.GRemoveTaskRelationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GRemoveTaskRelationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRemoveTaskRelationData, _i3.GRemoveTaskRelationVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRemoveTaskRelationReq> get serializer =>
      _$gRemoveTaskRelationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRemoveTaskRelationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRemoveTaskRelationReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRemoveTaskRelationReq.serializer,
        json,
      );
}
