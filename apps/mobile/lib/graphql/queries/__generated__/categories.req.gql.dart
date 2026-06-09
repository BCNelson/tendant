// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/queries/__generated__/categories.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/queries/__generated__/categories.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/queries/__generated__/categories.var.gql.dart'
    as _i3;

part 'categories.req.gql.g.dart';

abstract class GCategoriesReq
    implements
        Built<GCategoriesReq, GCategoriesReqBuilder>,
        _i1.OperationRequest<_i2.GCategoriesData, _i3.GCategoriesVars> {
  GCategoriesReq._();

  factory GCategoriesReq([void Function(GCategoriesReqBuilder b) updates]) =
      _$GCategoriesReq;

  static void _initializeBuilder(GCategoriesReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'Categories',
    )
    ..executeOnListen = true;

  @override
  _i3.GCategoriesVars get vars;
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
  _i2.GCategoriesData? Function(
    _i2.GCategoriesData?,
    _i2.GCategoriesData?,
  )? get updateResult;
  @override
  _i2.GCategoriesData? get optimisticResponse;
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
  _i2.GCategoriesData? parseData(Map<String, dynamic> json) =>
      _i2.GCategoriesData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GCategoriesData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GCategoriesData, _i3.GCategoriesVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GCategoriesReq> get serializer =>
      _$gCategoriesReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GCategoriesReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCategoriesReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GCategoriesReq.serializer,
        json,
      );
}

abstract class GSetTaskCategoryReq
    implements
        Built<GSetTaskCategoryReq, GSetTaskCategoryReqBuilder>,
        _i1
        .OperationRequest<_i2.GSetTaskCategoryData, _i3.GSetTaskCategoryVars> {
  GSetTaskCategoryReq._();

  factory GSetTaskCategoryReq(
          [void Function(GSetTaskCategoryReqBuilder b) updates]) =
      _$GSetTaskCategoryReq;

  static void _initializeBuilder(GSetTaskCategoryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SetTaskCategory',
    )
    ..executeOnListen = true;

  @override
  _i3.GSetTaskCategoryVars get vars;
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
  _i2.GSetTaskCategoryData? Function(
    _i2.GSetTaskCategoryData?,
    _i2.GSetTaskCategoryData?,
  )? get updateResult;
  @override
  _i2.GSetTaskCategoryData? get optimisticResponse;
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
  _i2.GSetTaskCategoryData? parseData(Map<String, dynamic> json) =>
      _i2.GSetTaskCategoryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSetTaskCategoryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GSetTaskCategoryData, _i3.GSetTaskCategoryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSetTaskCategoryReq> get serializer =>
      _$gSetTaskCategoryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSetTaskCategoryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetTaskCategoryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSetTaskCategoryReq.serializer,
        json,
      );
}

abstract class GDeleteTaskCategoryReq
    implements
        Built<GDeleteTaskCategoryReq, GDeleteTaskCategoryReqBuilder>,
        _i1.OperationRequest<_i2.GDeleteTaskCategoryData,
            _i3.GDeleteTaskCategoryVars> {
  GDeleteTaskCategoryReq._();

  factory GDeleteTaskCategoryReq(
          [void Function(GDeleteTaskCategoryReqBuilder b) updates]) =
      _$GDeleteTaskCategoryReq;

  static void _initializeBuilder(GDeleteTaskCategoryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'DeleteTaskCategory',
    )
    ..executeOnListen = true;

  @override
  _i3.GDeleteTaskCategoryVars get vars;
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
  _i2.GDeleteTaskCategoryData? Function(
    _i2.GDeleteTaskCategoryData?,
    _i2.GDeleteTaskCategoryData?,
  )? get updateResult;
  @override
  _i2.GDeleteTaskCategoryData? get optimisticResponse;
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
  _i2.GDeleteTaskCategoryData? parseData(Map<String, dynamic> json) =>
      _i2.GDeleteTaskCategoryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GDeleteTaskCategoryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GDeleteTaskCategoryData, _i3.GDeleteTaskCategoryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GDeleteTaskCategoryReq> get serializer =>
      _$gDeleteTaskCategoryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GDeleteTaskCategoryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteTaskCategoryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GDeleteTaskCategoryReq.serializer,
        json,
      );
}
