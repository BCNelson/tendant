// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/queries/__generated__/config.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/queries/__generated__/config.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/queries/__generated__/config.var.gql.dart'
    as _i3;

part 'config.req.gql.g.dart';

abstract class GConfigKeysReq
    implements
        Built<GConfigKeysReq, GConfigKeysReqBuilder>,
        _i1.OperationRequest<_i2.GConfigKeysData, _i3.GConfigKeysVars> {
  GConfigKeysReq._();

  factory GConfigKeysReq([void Function(GConfigKeysReqBuilder b) updates]) =
      _$GConfigKeysReq;

  static void _initializeBuilder(GConfigKeysReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'ConfigKeys',
    )
    ..executeOnListen = true;

  @override
  _i3.GConfigKeysVars get vars;
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
  _i2.GConfigKeysData? Function(
    _i2.GConfigKeysData?,
    _i2.GConfigKeysData?,
  )? get updateResult;
  @override
  _i2.GConfigKeysData? get optimisticResponse;
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
  _i2.GConfigKeysData? parseData(Map<String, dynamic> json) =>
      _i2.GConfigKeysData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GConfigKeysData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GConfigKeysData, _i3.GConfigKeysVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GConfigKeysReq> get serializer =>
      _$gConfigKeysReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GConfigKeysReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConfigKeysReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GConfigKeysReq.serializer,
        json,
      );
}

abstract class GSetConfigEntryReq
    implements
        Built<GSetConfigEntryReq, GSetConfigEntryReqBuilder>,
        _i1.OperationRequest<_i2.GSetConfigEntryData, _i3.GSetConfigEntryVars> {
  GSetConfigEntryReq._();

  factory GSetConfigEntryReq(
          [void Function(GSetConfigEntryReqBuilder b) updates]) =
      _$GSetConfigEntryReq;

  static void _initializeBuilder(GSetConfigEntryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SetConfigEntry',
    )
    ..executeOnListen = true;

  @override
  _i3.GSetConfigEntryVars get vars;
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
  _i2.GSetConfigEntryData? Function(
    _i2.GSetConfigEntryData?,
    _i2.GSetConfigEntryData?,
  )? get updateResult;
  @override
  _i2.GSetConfigEntryData? get optimisticResponse;
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
  _i2.GSetConfigEntryData? parseData(Map<String, dynamic> json) =>
      _i2.GSetConfigEntryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSetConfigEntryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GSetConfigEntryData, _i3.GSetConfigEntryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSetConfigEntryReq> get serializer =>
      _$gSetConfigEntryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSetConfigEntryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConfigEntryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSetConfigEntryReq.serializer,
        json,
      );
}

abstract class GDeleteConfigEntryReq
    implements
        Built<GDeleteConfigEntryReq, GDeleteConfigEntryReqBuilder>,
        _i1.OperationRequest<_i2.GDeleteConfigEntryData,
            _i3.GDeleteConfigEntryVars> {
  GDeleteConfigEntryReq._();

  factory GDeleteConfigEntryReq(
          [void Function(GDeleteConfigEntryReqBuilder b) updates]) =
      _$GDeleteConfigEntryReq;

  static void _initializeBuilder(GDeleteConfigEntryReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'DeleteConfigEntry',
    )
    ..executeOnListen = true;

  @override
  _i3.GDeleteConfigEntryVars get vars;
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
  _i2.GDeleteConfigEntryData? Function(
    _i2.GDeleteConfigEntryData?,
    _i2.GDeleteConfigEntryData?,
  )? get updateResult;
  @override
  _i2.GDeleteConfigEntryData? get optimisticResponse;
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
  _i2.GDeleteConfigEntryData? parseData(Map<String, dynamic> json) =>
      _i2.GDeleteConfigEntryData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GDeleteConfigEntryData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GDeleteConfigEntryData, _i3.GDeleteConfigEntryVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GDeleteConfigEntryReq> get serializer =>
      _$gDeleteConfigEntryReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GDeleteConfigEntryReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteConfigEntryReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GDeleteConfigEntryReq.serializer,
        json,
      );
}
