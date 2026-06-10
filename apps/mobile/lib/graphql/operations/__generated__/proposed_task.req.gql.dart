// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/proposed_task.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/proposed_task.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/proposed_task.var.gql.dart'
    as _i3;

part 'proposed_task.req.gql.g.dart';

abstract class GAcceptProposedTaskReq
    implements
        Built<GAcceptProposedTaskReq, GAcceptProposedTaskReqBuilder>,
        _i1.OperationRequest<_i2.GAcceptProposedTaskData,
            _i3.GAcceptProposedTaskVars> {
  GAcceptProposedTaskReq._();

  factory GAcceptProposedTaskReq(
          [void Function(GAcceptProposedTaskReqBuilder b) updates]) =
      _$GAcceptProposedTaskReq;

  static void _initializeBuilder(GAcceptProposedTaskReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'AcceptProposedTask',
    )
    ..executeOnListen = true;

  @override
  _i3.GAcceptProposedTaskVars get vars;
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
  _i2.GAcceptProposedTaskData? Function(
    _i2.GAcceptProposedTaskData?,
    _i2.GAcceptProposedTaskData?,
  )? get updateResult;
  @override
  _i2.GAcceptProposedTaskData? get optimisticResponse;
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
  _i2.GAcceptProposedTaskData? parseData(Map<String, dynamic> json) =>
      _i2.GAcceptProposedTaskData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GAcceptProposedTaskData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GAcceptProposedTaskData, _i3.GAcceptProposedTaskVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GAcceptProposedTaskReq> get serializer =>
      _$gAcceptProposedTaskReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GAcceptProposedTaskReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptProposedTaskReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GAcceptProposedTaskReq.serializer,
        json,
      );
}

abstract class GDismissProposedTaskReq
    implements
        Built<GDismissProposedTaskReq, GDismissProposedTaskReqBuilder>,
        _i1.OperationRequest<_i2.GDismissProposedTaskData,
            _i3.GDismissProposedTaskVars> {
  GDismissProposedTaskReq._();

  factory GDismissProposedTaskReq(
          [void Function(GDismissProposedTaskReqBuilder b) updates]) =
      _$GDismissProposedTaskReq;

  static void _initializeBuilder(GDismissProposedTaskReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'DismissProposedTask',
    )
    ..executeOnListen = true;

  @override
  _i3.GDismissProposedTaskVars get vars;
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
  _i2.GDismissProposedTaskData? Function(
    _i2.GDismissProposedTaskData?,
    _i2.GDismissProposedTaskData?,
  )? get updateResult;
  @override
  _i2.GDismissProposedTaskData? get optimisticResponse;
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
  _i2.GDismissProposedTaskData? parseData(Map<String, dynamic> json) =>
      _i2.GDismissProposedTaskData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GDismissProposedTaskData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GDismissProposedTaskData,
      _i3.GDismissProposedTaskVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GDismissProposedTaskReq> get serializer =>
      _$gDismissProposedTaskReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GDismissProposedTaskReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissProposedTaskReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GDismissProposedTaskReq.serializer,
        json,
      );
}
