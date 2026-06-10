// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.var.gql.dart'
    as _i3;

part 'update_task_metadata.req.gql.g.dart';

abstract class GUpdateTaskMetadataReq
    implements
        Built<GUpdateTaskMetadataReq, GUpdateTaskMetadataReqBuilder>,
        _i1.OperationRequest<_i2.GUpdateTaskMetadataData,
            _i3.GUpdateTaskMetadataVars> {
  GUpdateTaskMetadataReq._();

  factory GUpdateTaskMetadataReq(
          [void Function(GUpdateTaskMetadataReqBuilder b) updates]) =
      _$GUpdateTaskMetadataReq;

  static void _initializeBuilder(GUpdateTaskMetadataReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'UpdateTaskMetadata',
    )
    ..executeOnListen = true;

  @override
  _i3.GUpdateTaskMetadataVars get vars;
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
  _i2.GUpdateTaskMetadataData? Function(
    _i2.GUpdateTaskMetadataData?,
    _i2.GUpdateTaskMetadataData?,
  )? get updateResult;
  @override
  _i2.GUpdateTaskMetadataData? get optimisticResponse;
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
  _i2.GUpdateTaskMetadataData? parseData(Map<String, dynamic> json) =>
      _i2.GUpdateTaskMetadataData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GUpdateTaskMetadataData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GUpdateTaskMetadataData, _i3.GUpdateTaskMetadataVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GUpdateTaskMetadataReq> get serializer =>
      _$gUpdateTaskMetadataReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GUpdateTaskMetadataReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskMetadataReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GUpdateTaskMetadataReq.serializer,
        json,
      );
}
